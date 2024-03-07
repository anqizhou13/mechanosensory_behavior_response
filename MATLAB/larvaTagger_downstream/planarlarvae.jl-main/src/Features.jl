module Features

using ..LarvaBase: LarvaBase as Larva
using Statistics
using Meshes

export bodylength, medianbodylength, spine5, normalize_spines

bodylength(state::NamedTuple) = bodylength(Larva.spine(state))
bodylength(spine::Larva.SpineGeometry) = bodylength(Larva.vertices′(spine))
bodylength(spine::AbstractVector) = mapreduce(v->sqrt(v[1]^2 + v[2]^2), +, diff(spine))

function medianbodylength(tracks::AbstractVector; n::Int=100)
    # adapted from `medianlarvasize` in LarvaTagger.jl/src/models.jl
    lengths = Float64[]
    sizehint!(lengths, n)
    for _ in 1:n
        track = tracks[rand(1:end)]
        _, state = track[rand(1:end)]
        body_length = bodylength(state)
        push!(lengths, body_length)
    end
    return median(lengths)
end

"""
    spine5(state_or_spine)

Get the 5-point spine.
"""
spine5(state::NamedTuple) = spine5(Larva.spine(state))
spine5(spine::Larva.SpineGeometry) = spine5(Larva.vertices′(spine))
spine5(spine::AbstractVector{<:Point}) = spine5(coordinates.(spine))
function spine5(spine::AbstractVector)
    if length(spine) == 5
        spine
    elseif length(spine) == 11
        [spine[1],
         (spine[3] + spine[4]) / 2,
         spine[6],
         (spine[8] + spine[9]) / 2,
         spine[11]]
    else
        throw("Spine size not supported: $(size(spine))")
    end
end

flatten_chain(points) = collect(Iterators.flatten(points))

function normalize_spines(spines, scale=1; mask=nothing, swapheadtail=false)
    # center
    refspines = isnothing(mask) ? spines : spines[mask]
    p0 = mean([Larva.midpoint(s) for s in refspines])
    spines = [[p - p0 for p in s] for s in spines]
    # rotate (align the mean tail-head axis)
    refspines = isnothing(mask) ? spines : spines[mask]
    v = mean([s[end] - s[1] for s in refspines])
    v /= sqrt(sum(v .* v))
    c, s = v ./ scale # ...and scale at the same time, using the rotation matrix
    rot = [ c  s ;
           -s  c ] # clockwise rotation
    spines = [[rot * p for p in s] for s in spines]
    #
    if swapheadtail
        spines = reverse.(spines)
    end
    spines = vcat((permutedims ∘ flatten_chain).(spines)...)
    spines
end

end
