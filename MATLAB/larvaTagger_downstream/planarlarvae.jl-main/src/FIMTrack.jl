module FIMTrack

using ..LarvaBase
using ..Datasets
using Meshes
using DelimitedFiles
using OrderedCollections

export read_fimtrack

"""
    read_fimtrack(filepath)
    read_fimtrack(specifications, path)
    read_fimtrack(...; framerate=nothing, pixelsize=nothing)

Load data records from FIMTrack v2 *table.csv* files.

Data record specifications can be passed in the shape of a tuple of pairs, with record name
first, and desired data type second.

Return type is [`Vector{Track}`](@ref Main.PlanarLarvae.Datasets.Track).

If specified, `framerate` should be in frames per second and `pixelsize` in micrometers.
Timestamps are eventually expressed in seconds and space coordinates in millimeters.
"""
function read_fimtrack end

function read_fimtrack(filepath::String; kwargs...)
    feature_specs, larva_specs, table = preload_fimtrack(filepath)
    return postload_fimtrack(feature_specs, larva_specs, table; kwargs...)
end

function read_fimtrack(specs, filepath::String; radii=nothing, kwargs...)
    feature_specs, larva_specs, table = preload_fimtrack(filepath)
    feature_specs′ = OrderedSet{Symbol}()
    for (feature, _) in specs
        if feature === :outline
            if isnothing(radii)
                union!(feature_specs′, (:head, :spinepoint, :tail, :radius))
            else
                union!(feature_specs′, (:head, :spinepoint, :tail))
            end
        elseif feature === :spine
            union!(feature_specs′, (:head, :spinepoint, :tail))
        else
            push!(feature_specs′, feature)
        end
    end
    if !isnothing(radii) && haskey(kwargs, :pixelsize)
        pixelsize = kwargs[:pixelsize]
        if !isnothing(pixelsize)
            radii .*= (pixelsize * 1e-3)
        end
    end
    feature_specs″ = typeof(feature_specs)(feature=>type
                                           for (feature, type) in feature_specs
                                           if feature in feature_specs′)
    tracks = postload_fimtrack(feature_specs″, larva_specs, table; kwargs...)
    tracks′ = Track[]
    for track in tracks
        track′ = Track(track.id, track.timestamps)
        for (feature, type) in specs
            if feature === :spine
                record = read_spines(type, track.states)
            elseif feature === :outline
                if isnothing(radii)
                    record = read_outlines(type, track.states)
                else
                    record = read_outlines(type, track.states, radii)
                end
            else
                record = track[feature]
            end
            track′[feature] = if eltype(record) === type
                record
            else
                [convert(type, item) for item in record]
            end
        end
        push!(tracks′, track′)
    end
    return tracks′
end

function read_spines(typehint, records)
    [read_spine(typehint, head, spinepoint, tail)
     for (head, spinepoint, tail) in zip(records[:head],
                                         records[:spinepoint],
                                         records[:tail])]
end

read_spine(::Type{T}, args...) where {F,T<:Chain{2,F}} = convert(T, read_spine(PointSeries{F}, args...))

function read_spine(T::Type{<:PointSeries}, head, spinepoint, tail)
    hx, hy = head.coords
    tx, ty = tail.coords
    T([hx; spinepoint.x; tx], [hy; spinepoint.y; ty])
end

function read_outlines(typehint, records)
    [read_outline(typehint, head, spinepoint, radius, tail)
     for (head, spinepoint, radius, tail) in zip(records[:head],
                                                 records[:spinepoint],
                                                 records[:radius],
                                                 records[:tail])]
end

function read_outlines(typehint, records, radii)
    [read_outline(typehint, head, spinepoint, radii, tail)
     for (head, spinepoint, tail) in zip(records[:head],
                                         records[:spinepoint],
                                         records[:tail])]
end

function read_outline(T::Type{PolyArea{D,F,C}}, args...) where {D,F,C<:Chain{D,F}}
    T(read_outline(C, args...), C[], false)
end

function read_outline(C::Type{Chain{D,F,V}}, args...) where {D,F,V<:Vector{Point{D,F}}}
    C(read_outline(V, args...))
end

function read_outline(::Type{Vector{Point2}}, head, spinepoints, radii, tail)
    outline = Vector{Point2}(undef, length(spinepoints) * 2 + 3)
    outline[1] = head
    outline[end] = head
    prev = head
    for (i, curr) in enumerate(spinepoints)
        next = i < length(spinepoints) ? spinepoints[i+1] : tail
        radius = radii[i]
        0 < radius || @debug "null radius"
        v1 = norm(prev - curr)
        v2 = norm(curr - next)
        x3, y3 = norm(v1 + v2)
        v4 = Vec(-y3, x3) # CCW
        v = radius * v4
        outline[1+i] = curr + v
        outline[end-i] = curr - v
        prev = curr
    end
    outline[2+length(spinepoints)] = tail
    return outline
end

function norm(v)
    x, y = v
    x == 0 && y == 0 && return Vec(x, y)
    n = sqrt(x * x + y * y)
    return Vec(x / n, y / n)
end

const FIMTrackData = OrderedDict{Symbol, Dict{LarvaID, Any}}

function preload_fimtrack(filepath::String)
    endswith(filepath, ".csv") || @warn "FIMTrack .csv files are supported only"
    table = readdlm(filepath, ',')
    larva_ids = [parse(LarvaID, col[7:end-1]) for col in table[1, 2:end]]
    raw_feature_ranges = group_rows(table[:, 1])
    @debug raw_feature_ranges
    feature_specs = group_raw_features(raw_feature_ranges)
    @debug feature_specs
    larva_specs = larva_ranges(larva_ids, raw_feature_ranges, table)
    @debug larva_specs
    return feature_specs, larva_specs, table
end

function postload_fimtrack(feature_specs, larva_specs, table; kwargs...)
    astracks(larva_specs,
             group_features(feature_specs, larva_specs, table);
             kwargs...)
end

function astracks(larva_specs, features; framerate=nothing, pixelsize=nothing)
    if !isnothing(pixelsize)
        # pixelsize is initially expressed in μm and we want millimeters
        pixelsize *= 1e-3
    end
    tracks = Track[]
    for (id, t0, t1) in larva_specs
        t0, t1 = Time(t0-1), Time(t1-1)
        larva_times = collect(isnothing(framerate) ? (t0:t1) : (t0/framerate:1/framerate:t1/framerate))
        larva_features = OrderedDict(ftrname => scale(ftrdata[id], pixelsize)
                                     for (ftrname, ftrdata) in pairs(features)
                                     if id in keys(ftrdata))
        push!(tracks, Track(id, larva_times, larva_features))
    end
    return tracks
end

scale(ftrdata, ::Nothing) = ftrdata

scale(ftrdata::Vector, pixelsize::Number) = [scale(x, pixelsize) for x in ftrdata]

scale(ftrdata::Vector{<:Number}, pixelsize::Number) = ftrdata .* pixelsize

scale(ftrdata::Point, pixelsize::Number) = Point(ftrdata.coords .* pixelsize)

scale(ftrdata::PointSeries, pixelsize::Number) = PointSeries(ftrdata.x .* pixelsize, ftrdata.y .* pixelsize)

function larva_ranges(larva_ids, feature_ranges, table)
    _, start, stop = feature_ranges[1] # any feature
    nsteps = stop - start + 1
    larva_specs = Tuple{LarvaID, Int, Int}[]
    for (i, larva_id) in enumerate(larva_ids)
        col = i + 1
        any_record = table[start:stop, col]
        series_start = findfirst(x -> x != "", any_record)
        if isnothing(series_start)
            series_start = 1
        end
        undefined_from = findfirst(==(""), any_record[series_start:end])
        series_stop = isnothing(undefined_from) ? nsteps : series_start + undefined_from - 2
        push!(larva_specs, (larva_id, series_start, series_stop))
    end
    return larva_specs
end

function group_rows(rownames)
    @assert rownames[1] == ""
    feature_ranges = Tuple{String, Int, Int}[]
    k = k0 = 2
    raw_ftr = nothing
    curr_ftr, _ = split(rownames[k], '(')
    while k < length(rownames)
        k = k + 1
        raw_ftr, _ = split(rownames[k], '(')
        # assume rows are ordered by features and timestamps
        if raw_ftr != curr_ftr
            k1 = k - 1
            push!(feature_ranges, (curr_ftr, k0, k1))
            k0 = k
            curr_ftr = raw_ftr
        end
    end
    if raw_ftr != feature_ranges[end][1]
        push!(feature_ranges, (raw_ftr, k0, k))
    end
    return feature_ranges
end

function group_raw_features(raw_feature_ranges)
    combined_features = OrderedDict{Symbol, Tuple{Int, Int, Int, Int, Int}}()
    k = 0
    while k < length(raw_feature_ranges)
        k = k + 1
        group_first_feature, start, stop = raw_feature_ranges[k]
        nsteps = stop - start + 1
        parts = split(group_first_feature, '_')
        npts = ndims = 1
        p = length(parts)
        if parts[p] == "x"
            ndims = 2
            p = p - 1
            k = k + 1
            next_feature, _, next_stop = raw_feature_ranges[k]
            @assert endswith(next_feature, "_y")
            @assert next_stop == stop + nsteps
            stop = next_stop
        end
        if parts[p] == "1"
            p = p - 1
            while true
                npts = npts + 1
                k = k + ndims
                expected_suffix = ndims == 2 ? "_$(npts)_y" : "_$(npts)"
                if k <= length(raw_feature_ranges)
                    next_feature, _, next_stop = raw_feature_ranges[k]
                else
                    next_feature = ""
                end
                if endswith(next_feature, expected_suffix)
                    @assert next_stop == stop + ndims * nsteps
                    stop = next_stop
                else
                    npts = npts - 1
                    k = k - ndims
                    break
                end
            end
        end
        feature = join(parts[1:p], "_")
        @assert stop - start + 1 == nsteps * ndims * npts
        combined_features[Symbol(feature)] = (start, stop, nsteps, ndims, npts)
    end
    return combined_features
end

const known_booleans = (:in_collision,
                        :is_coiled,
                        :is_well_oriented,
                        :go_phase,
                        :left_bended,
                        :right_bended,
                       )

function recordtype(feature, ndims, npts; coordtype=Float32, defaulttype=Float64)
    # coordtype could be UInt16 per default
    if feature in known_booleans
        Bool
    elseif 1 < npts
        if ndims == 2
            PointSeries{coordtype}
        else
            Vector{defaulttype}
        end
    else
        if 1 < ndims
            Point{ndims, coordtype}
        else
            defaulttype
        end
    end
end

function eltype′ end
eltype′(T) = eltype(T)
eltype′(::Type{Point{Dim, T}}) where {Dim, T} = T
eltype′(::Type{PointSeries{T}}) where {T} = T
eltype′(::Type{Union{Missing, T}}) where {T} = T

function group_features(feature_specs, larva_specs, table)
    data = FIMTrackData()
    for (feature, specs) in pairs(feature_specs)
        _, _, _, ndims, npts = specs
        T = recordtype(feature, ndims, npts)
        data′ = group_features(T, specs, larva_specs, table)
        if isnothing(data′)
            data′ = group_features(Union{Missing, T}, specs, larva_specs, table)
            @assert !isnothing(data′)
        end
        data[feature] = data′
    end
    return data
end

function group_features(T, ftr_specs, larva_specs, table)
    ret = Dict{LarvaID, Vector{T}}()
    ftr_start, ftr_stop, _, _, _ = ftr_specs
    for (i, specs′) in enumerate(larva_specs)
        col = i + 1
        series = table[ftr_start:ftr_stop, col]
        id, series_start, series_stop = specs′
        x = T[]
        x = pack!(x, ftr_specs, series_start, series_stop, series)
        isnothing(x) && return
        ret[id] = x
    end
    return ret
end

function pack!(ret::Vector{T}, ftr_specs::Tuple, series_start, series_stop, data) where {T}
    V = eltype′(T)
    _, _, nsteps, ndims, npts = ftr_specs
    for step in series_start:series_stop
        record = data[step:nsteps*ndims:end]
        x = try
            V.(record)
        catch
            try
                push!(ret, missing)
            catch
                return
            end
            continue
        end
        @assert length(x) == npts
        if ndims == 2
            y = V.(data[nsteps+step:nsteps*ndims:end])
            @assert length(y) == npts
            pack!(ret, x, y)
        else
            pack!(ret, x)
        end
    end
    return ret
end

pack!(ret::Vector{T}, args...) where {T} = push!(ret, pack(T, args...))

pack(::Type{Union{Missing, T}}, x) where {T} = pack(T, x)
pack(::Type{T}, x::T) where {T} = x
pack(T, x) = T(x)
pack(T, x, y) = T(x, y)
function pack(::Type{T}, x::AbstractVector{T}) where {T}
    @assert length(x) == 1
    return x[1]
end
function pack(P::Type{Point{Dim, T}}, x::Vector{T}, y::Vector{T}) where {Dim, T}
    @assert length(x) == length(y) == 1
    P(x[1], y[1])
end

end
