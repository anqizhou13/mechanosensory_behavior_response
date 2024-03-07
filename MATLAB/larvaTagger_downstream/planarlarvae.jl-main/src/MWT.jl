"""
The MWT module currently features basic routines to manipulate MWT-derived data, including
Choreography and *trx.mat* files. It was initially intended to organize the development of
fixes for the observed jitters and frame drops caused by the LabView version of MWT in the
single-processor regime.

Someday, the module may be recycled to implement the low-level interface to the raw MWT
output files (*.blobs*, *.summary*).
"""
module MWT

using ..LarvaBase: LarvaBase as Larva
using ..Datasets: Datasets
using StatsBase
using Meshes

export fixmwtdata

function mode(xs)
    @assert !isempty(xs)
    low, high = minimum(xs), maximum(xs)
    binbreaks = (low - .5):1:nextfloat(high + .5)
    h = fit(Histogram, xs, binbreaks)
    counts = h.weights
    x = low - 1 + argmax(counts)
    return x
end

"""
Floating point times are assumed to be in seconds. Convert to milliseconds/Int.
"""
toms(t::AbstractFloat) = round(Int, 1e3 * t)
toms(t::Int) = t

seconds(t::AbstractFloat) = t
seconds(t::Int) = t * 1e-3

frameintervals(times::Vector{<:AbstractFloat}) = frameintervals(toms.(times))
frameintervals(times::Vector{Int}) = diff(times)
"""
    frameinterval(timestamps)

Mode of the distribution of frame intervals. In milliseconds.
"""
frameinterval(times) = mode(frameintervals(times))

phaselocking(timestamps1::AbstractVector,
             timestamps2::AbstractVector,
             frame_interval,
            ) = phaselocking(toms.(timestamps1), toms.(timestamps2), 1e3 * frame_interval)
function phaselocking(timestamps1::Vector{Int}, timestamps2::Vector{Int}, frame_interval)
    mn, sd1 = phaselocking(timestamps1 ./ frame_interval)
    _, sd2 = phaselocking(timestamps2 ./ frame_interval; mean_phase=mn)
    return (sd1, sd2)
end
function phaselocking(normalized_t::Vector{Float64}; mean_phase::Union{Nothing, Float64}=nothing)
    phases = @. 2 * (normalized_t - trunc(normalized_t)) - 1
    if isnothing(mean_phase)
        # mean
        x = mean(cospi.(phases))
        y = mean(sinpi.(phases))
        mean_phase = atan(y, x) / pi
    end
    # standard deviation
    delta_phase = phases .- mean_phase
    if 0 < mean_phase
        @. delta_phase[delta_phase < -1] += 2
    elseif mean_phase < 0
        @. delta_phase[1 < delta_phase] -= 2
    end
    var = sum(delta_phase.^2) / (length(delta_phase) - 1)
    return mean_phase, sqrt(var)
end

interpolate(x1::T, x2::T, lambda) where {T<:AbstractFloat} = (1 - lambda) * x1 + lambda * x2
interpolate(x1::T,
            x2::T,
            lambda,
           ) where {T<:AbstractArray} = @. (1 - lambda) * x1 + lambda * x2
function interpolate(geometry1::T, geometry2::T, lambda) where {T<:Larva.SpineGeometry}
    x1, y1 = collect.(zip(coordinates.(Larva.vertices′(geometry1))...))
    x2, y2 = collect.(zip(coordinates.(Larva.vertices′(geometry2))...))
    return convert(typeof(geometry1),
                   Larva.PointSeries(interpolate(x1, x2, lambda),
                                     interpolate(y1, y2, lambda)))
end
function interpolate(tags1::T, tags2::T, lambda) where {T<:Larva.AbstractTags}
    lambda <= 0.5 ? tags1 : tags2
end
function interpolate(state1::T, state2::T, lambda) where {T<:NamedTuple}
    features = []
    for (x1, x2) in zip(state1, state2)
        x = interpolate(x1, x2, lambda) # outlines not supported
        push!(features, x)
    end
    return T(tuple(features...))
end
function interpolate(step1::Tuple{A, B}, step2::Tuple{A, B}, lambda) where {A,B}
    a1, b1 = step1
    a2, b2 = step2
    (interpolate(a1, a2, lambda), interpolate(b1, b2, lambda))
end

function interpolate(ts::Vector{T}, xs::Vector{X}, ts′::Vector{T}) where {T<:Real,X}
    @assert issorted(ts)
    xs′= Vector{Tuple{T, X}}()
    sizehint!(xs′, length(ts′))
    for t in ts′
        t = round(t; digits=4)
        inext = searchsortedfirst(ts, t)
        tnext, xnext = ts[inext], xs[inext]
        x = if tnext == t
            xnext
        else
            @assert 1 < inext # we need iprev=inext-1
            tprev, xprev = ts[inext-1], xs[inext-1]
            interpolate(xprev, xnext, (t - tprev) / (tnext - tprev))
        end
        push!(xs′, (t, x))
    end
    return xs′
end

"""
    fixmwtdata(track; anchor_time, frame_interval=0.04, nframes=nothing)

Interpolate frames at `nframes` time points evenly spaced around time `anchor_time`.

All features in `track` must be supported by the 3-arg `interpolate`.

Compulsory argument `anchor_time` is keyworded for backward compatibility
"""
function fixmwtdata(
        track::Larva.TimeSeries;
        anchor_time::Larva.Time,
        frame_interval=0.04,
        nframes=nothing,
    )
    times = Larva.times(track)
    @assert issorted(times)
    tstart, tstop = times[1], times[end]
    @assert tstart < anchor_time < tstop
    istart = trunc(Int, (tstart - anchor_time) / frame_interval)
    istop  = trunc(Int, (tstop - anchor_time) / frame_interval)
    if !isnothing(nframes)
        nframes_before = trunc(nframes / 2)
        nframes_after = nframes - 1 - nframes_before
        istart = max(-nframes_before, istart)
        istop = min(nframes_after, istop)
    end
    grid = istart:istop
    @assert !isempty(grid)
    # if interpolating FIMTrack data instead of MWT data
    # (see issue https://gitlab.pasteur.fr/nyx/TaggingBackends/-/issues/20):
    #times = round.(times; digits=4)
    # interpolate at target timepoints
    series = empty(track)
    sizehint!(series, length(grid))
    for i in grid
        t = round(anchor_time + i * frame_interval; digits=4)
        inext = searchsortedfirst(times, t)
        tnext, xnext = track[inext]
        x = if tnext == t
            xnext
        else
            @assert 1 < inext # we need iprev=inext-1
            tprev, xprev = track[inext-1]
            interpolate(xprev, xnext, (t - tprev) / (tnext - tprev))
        end
        push!(series, (t, x))
    end
    return series
end

end
