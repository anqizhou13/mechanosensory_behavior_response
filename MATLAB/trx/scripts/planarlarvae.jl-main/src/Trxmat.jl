module Trxmat

using ..LarvaBase
using MAT

export TrxMatFile, read_trxmat, read_trxmat_var, find_trxmat_file

"""
Handle of a *trx.mat* file.

Note:
HDF5-based (v7) *.mat* files are supported only.
"""
const TrxMatFile = MAT.MAT_HDF5.MatlabHDF5File

"""
    read_trxmat(filepath)
    read_trxmat(dirpath)
    read_trxmat(specifications, path)

Load data records from *trx.mat* files.
Default filename is "trx.mat" if the path to a directory is given.

Data record specifications can be passed in the shape of a datatype or a tuple of pairs.
Return type is `Runs{T}` where `T = derivedtype(specifications)`.

Example:
```julia
runs = read_trxmat((:outline=>Outline, :tags=>BehaviorTags), myfile)
```

Note:
*trx.mat* files usually contain data of a single run, identified by a date_time string.
"""
function read_trxmat end

"""
    read_trxmat_var(specification, file)

Read a single data record from an opened *trx.mat* file.
Return type is `Vector{Vector{T}}` where `T = derivedtype(specification)`.
"""
function read_trxmat_var end

"""
    find_trxmat_file(path)

Find a *trx.mat* file in the designated directory.
Returns filepath as a `String`.

Admissible *trx.mat* files exhibit the *.mat* extension and the *trx* substring in the stem.
If multiple such files are found, the one with the shortest name is returned.
"""
function find_trxmat_file end

## implementation

read_trxmat_var(varname::String, file::TrxMatFile) = read(file, "trx/$varname")

function read_spines(T::Type, file::TrxMatFile)
    spines_x = read_trxmat_var("x_spine", file)
    spines_y = read_trxmat_var("y_spine", file)
    m = size(spines_x, 1)
    @assert size(spines_x, 2) == 1 && size(spines_y) == (m, 1)
    # TODO: make spines a generator (Channel?)
    spines = Vector{Vector{T}}(undef, m)
    for j in 1:m
        spines_x′ = spines_x[j,1]
        spines_y′ = spines_y[j,1]
        @assert size(spines_x′) == size(spines_y′)
        n = size(spines_x′, 1)
        spines′ = Vector{T}(undef, n)
        for k in 1:n
            spine_x::Vector{Float64} = spines_x′[k,:]
            spine_y::Vector{Float64} = spines_y′[k,:]
            spine = convert(T, PointSeries(spine_x, spine_y))
            spines′[k] = spine
        end
        #push!(spines, spines′)
        spines[j] = spines′
    end
    return spines
end

function read_outlines(T::Type, file::TrxMatFile)
    outlines_x = read_trxmat_var("x_contour", file)
    outlines_y = read_trxmat_var("y_contour", file)
    m = size(outlines_x, 1)
    @assert size(outlines_x, 2) == 1 && size(outlines_y) == (m, 1)
    # TODO: make outlines a generator (Channel?)
    outlines = Vector{Vector{T}}(undef, m)
    for j in 1:m
        outlines_x′ = outlines_x[j,1]
        outlines_y′ = outlines_y[j,1]
        @assert size(outlines_x′) == size(outlines_y′)
        n, p = size(outlines_x′)
        outlines′ = Vector{T}(undef, n)
        for k in 1:n
            outline_x::Vector{Float64} = outlines_x′[k,:]
            outline_y::Vector{Float64} = outlines_y′[k,:]
            q = findfirst(isnan.(outline_x))
            if isnothing(q)
                q = p
            else
                @assert 1 < q && all(isnan, outline_y[q:end])
                q -= 1
            end
            outline_x, outline_y = outline_x[1:q], outline_y[1:q]
            @assert !any(isnan, outline_y)
            outline = convert(T, PointSeries(outline_x, outline_y))
            outlines′[k] = outline
        end
        #push!(outlines, outlines′)
        outlines[j] = outlines′
    end
    return outlines
end

function asvector(v)
    @assert size(v, 2) == 1
    return vec(v)
end

function read_date_time(file::TrxMatFile)
    dates_times = read_trxmat_var("id", file)
    date_time = dates_times[1]
    @assert all((==)(date_time), dates_times)
    return date_time
end

function read_larva_ids(file::TrxMatFile)
    ids = read_trxmat_var("numero_larva_num", file)
    return convert(Vector{LarvaID}, asvector(ids))
end

function read_timestamps(file::TrxMatFile)
    t′ = asvector(read_trxmat_var("t", file))
    t = Vector{Vector{Time}}(undef, length(t′))
    for (i, t″) in enumerate(t′)
        t[i] = convert(Vector{Time}, asvector(t″))
    end
    return t
end

read_trxmat_var(T::Type{<:Spine}, file::TrxMatFile) = read_spines(T, file)
read_trxmat_var(T::Type{<:Outline}, file::TrxMatFile) = read_outlines(T, file)

function read_trxmat(T, filepath::String)
    T′ = derivedtype(T)
    runs = Runs{T′}() # actually a single run
    larvae = Larvae{T′}()
    file = matopen(find_trxmat_file(filepath))
    try
        date_time = read_date_time(file)
        larva_ids = read_larva_ids(file)
        timestamps = read_timestamps(file)
        vars = read_trxmat_var(T, file)
        @assert length(larva_ids) == length(timestamps) == length(vars)
        runs[date_time] = larvae
        for (larva_id, ts, vs) in zip(larva_ids, timestamps, vars)
            @assert length(ts) == length(vs)
            larva_data = TimeSeries{T′}(collect(zip(ts, vs)))
            larvae[larva_id] = larva_data
        end
    finally
        close(file)
    end
    return runs
end

function find_trxmat_file(path::String)
    if isdir(path)
        files = readdir(path; join=false, sort=false)
        trxmatfiles = [joinpath(path, f) for f in files if endswith(f, ".mat") && occursin("trx", f)]
        if isempty(trxmatfiles)
            throw(SystemError("no trx.mat files found in: $path"))
        elseif 1 < length(trxmatfiles)
            sort!(trxmatfiles; by=length)
            @info "Multiple trx.mat files found" dir=path files=trxmatfiles
        end
        return trxmatfiles[1]
    else
        isfile(path) || throw(SystemError("no such file or directory: $path", 2))
        return path
    end
end

function read_behavior_tags(tags, file::TrxMatFile)
    reftags = isa(tags, BehaviorTags) ? tags : BehaviorTags(tags) # ensure attribute `names` is memory-shared
    T = typeof(reftags)
    rettags = nothing
    for (t, tag) in enumerate(reftags.names)
        binary_tags = asvector(read_trxmat_var(string(tag), file))
        m = length(binary_tags)
        if isnothing(rettags)
            rettags = Vector{Vector{T}}(undef, m)
            for i in 1:m
                binary_tags′ = asvector(binary_tags[i])
                n = length(binary_tags′)
                rettags[i] = rettags′ = Vector{T}(undef, n)
                for j in 1:n
                    rettags′[j] = rettags″ = Base.copymutable(reftags)
                    if binary_tags′[j] == 1
                        LarvaBase.set_indicator!(rettags″, t, true)
                    end
                end
            end
        else
            @assert m == length(rettags)
            for i = 1:m
                rettags′ = rettags[i]
                binary_tags′ = asvector(binary_tags[i])
                n = length(binary_tags′)
                @assert n == length(rettags′)
                for j in 1:n
                    if binary_tags′[j] == 1
                        LarvaBase.set_indicator!(rettags′[j], t, true)
                    end
                end
            end
        end
    end
    return rettags
end

behavior_tags = [
                 :back,
                 :back_large,
                 :back_strong,
                 :back_weak,
                 :cast,
                 :cast_large,
                 :cast_strong,
                 :cast_weak,
                 :hunch,
                 :hunch_large,
                 :hunch_strong,
                 :hunch_weak,
                 :roll,
                 :roll_large,
                 :roll_strong,
                 :roll_weak,
                 :run,
                 :run_large,
                 :run_strong,
                 :run_weak,
                 :small_motion,
                 :stop_large,
                 :stop_strong,
                 :stop_weak,
                ]

read_behavior_tags(file::TrxMatFile) = read_behavior_tags(behavior_tags, file)

read_trxmat_var(tags::Tags, file::TrxMatFile) = read_behavior_tags(tags, file)
read_trxmat_var(::Type{<:Tags}, file::TrxMatFile) = read_behavior_tags(file)

read_trxmat_var(specs::Records, file::TrxMatFile) = zip′(specs, read_trxmat_var, file)

function LarvaBase.zip′(::Type{T}, attrs::NTuple{N, Vector{Vector{T′}} where T′}) where {T<:NamedTuple, N}
    @assert !isempty(attrs)
    a = attrs[1]
    m = length(a)
    @assert all((==)(m), length.(attrs))
    zipped = Vector{Vector{T}}(undef, m)
    for i in 1:m
        n = length(a[i])
        b′ = [b[i] for b in attrs]
        @assert all((==)(n), length.(b′))
        zipped[i] = zipped′ = Vector{T}(undef, n)
        for j in 1:n
            zipped′[j] = T(tuple((b″[j] for b″ in b′)...))
        end
    end
    return zipped
end

## deprecated

function LarvaBase.zip′(::Type{T}, a::Vector{Vector{A}}, b::Vector{Vector{B}}) where {T, A, B}
    m = length(a)
    @assert m == length(b)
    ab = Vector{Vector{T}}(undef, m)
    for i in 1:m
        a′, b′ = a[i], b[i]
        n = length(a′)
        @assert n == length(b′)
        ab[i] = ab′ = Vector{T}(undef, n)
        for j in 1:n
            ab′[j] = T(a′[j], b′[j])
        end
    end
    return ab
end

function read_trxmat_var(T::Type{<:SpineOutline}, file::TrxMatFile)
    spines = read_trxmat_var(Spine, file)
    outlines = read_trxmat_var(Outline, file)
    return zip′(T, spines, outlines)
end

end
