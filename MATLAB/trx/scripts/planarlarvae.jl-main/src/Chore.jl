module Chore

using ..LarvaBase
using Meshes

export RawOutline, RawSpine,
       Outlinef, Spinef,
       read_outline, read_spine,
       read_chore_files,
       find_chore_files,
       parse_filename

"""
Data type of individual outlines as initially parsed when reading *.outline* files.

See also [`Outline`](@ref) and [`Outlinef`](@ref).
"""
const RawOutline = Vector{Float32}
const EncapsulatedOutline = LarvaBase.Path{2,Float32,RawOutline}

"""
Data type of individual spines as initially parsed when reading *.spine* files.

See also [`Spine`](@ref) and [`Spinef`](@ref).
"""
const RawSpine = Vector{Float64}
const EncapsulatedSpine = LarvaBase.Path{2,Float64,RawSpine}

# """
# Default type for individual outlines,
# as [Meshes.jl](https://github.com/JuliaGeometry/Meshes.jl) `PolyArea`s.
# Coordinates are `Float64`-encoded.

# See also [`RawOutline`](@ref) and [`Outlinef`](@ref).
# """
# const Outline = OutlineGeometry{Float64,Vector{Point2}}

#const Outlinef = OutlineGeometry{Float32,Vector{Point2f}}
"""
Type for individual outlines,
as [Meshes.jl](https://github.com/JuliaGeometry/Meshes.jl) `PolyArea`s.
Coordinates are `Float32`-encoded.

See also [`RawOutline`](@ref) and [`Outline`](@ref).
"""
const Outlinef = OutlineGeometry{Float32,EncapsulatedOutline}

# """
# Default type for individual spines,
# as [Meshes.jl](https://github.com/JuliaGeometry/Meshes.jl) `Chain`s.
# Coordinates are `Float64`-encoded.

# See also [`RawSpine`](@ref) and [`Spinef`](@ref).
# """
# const Spine = SpineGeometry{Float64,Vector{Point2}}

"""
Type for individual spines,
as [Meshes.jl](https://github.com/JuliaGeometry/Meshes.jl) `Chain`s.
Coordinates are `Float32`-encoded.

See also [`RawSpine`](@ref) and [`Spine`](@ref).
"""
const Spinef = SpineGeometry{Float32,Vector{Point2f}}

"""
    read_outline(filepath)
    read_outline(T::DataType, filepath)

Load a *Choreography* *.outline* file.
If a directory path is passed, exactly one *.outline* file should be found in the directory.

A type constructor for individual outlines can be passed as first argument.
Return type is `Runs{T}`.

Example:
```julia
runs = read_outline(Outlinef, myfile)
```

See also [`RawOutline`](@ref), [`Outline`](@ref) and [`Outlinef`](@ref).

Note:
A *.outline* file contains data for a single run.
A single-key dictionnary of runs is returned anyway.
"""
function read_outline end

"""
    read_spine(filepath)
    read_spine(T::DataType, filepath)

Load a *Choreography* *.spine* file.
If a directory path is passed, exactly one *.spine* file should be found in the directory.

A type constructor for individual outlines can be passed as first argument.
Return type is `Runs{T}`.

Example:
```julia
runs = read_spine(Spinef, myfile)
```

See also [`RawSpine`](@ref), [`Spine`](@ref) and [`Spinef`](@ref).

Note:
A *.spine* file contains data for a single run.
A single-key dictionnary of runs is returned anyway.
"""
function read_spine end

"""
    read_chore_files(dirpath)
    read_chore_files(filepath)
    read_chore_files(specifications, path)

Load corresponding *.outline* and *.spine* files.

Return type is `Runs{T}` where `T = derivedtype(specifications)`.

See also [`Records`](@ref) for data record specifications.
"""
function read_chore_files end

"""
    find_chore_files(dirpath)
    find_chore_files(filepath)

Find the *.outline* and *.spine* files (paths returned in this order) in a directory, or
corresponding to a *.outline* or *.spine* file.
"""
function find_chore_files end

## implementation

Base.:(==)(so::SpineOutline, so′::SpineOutline) = spine(so) == spine(so′) && outline(so) == outline(so′)

function parse_outline(F::Type, T::Type, line)
    date_time, larva_id, timestamp, outline... = split(line)
    larva_id = parse(LarvaID, larva_id)
    timestamp = parse(Time, timestamp)
    outline = convert(T, LarvaBase.Path(parse.(F, outline)))
    return date_time, larva_id, timestamp, outline
end

function read_outline(F::Type, T::Type, filepath)
    outlines = Runs{T}()
    for line in eachline(filepath)
        date_time, larva_id, timestamp, outline = parse_outline(F, T, line)
        if !haskey(outlines, date_time)
            outlines[date_time] = Larvae{T}()
        end
        outlines′ = outlines[date_time]
        if !haskey(outlines′, larva_id)
            outlines′[larva_id] = TimeSeries{T}()
        end
        outlines″ = outlines′[larva_id]
        push!(outlines″, (timestamp, outline))
    end
    return outlines
end

read_outline(T::Type, filepath) = read_outline(Float32, T, filepath)
read_outline(filepath) = read_outline(Outline, filepath)

read_spine(T::Type, filepath) = read_outline(Float64, T, filepath)
read_spine(filepath) = read_spine(Spine, filepath)

function find_chore_files(path::String)
    if isdir(path)
        files = readdir(path)
        spine_file = [joinpath(path, fp) for fp in files if endswith(fp, ".spine")]
        outline_file = [joinpath(path, fp) for fp in files if endswith(fp, ".outline")]
        if length(outline_file) == 1 && length(spine_file) == 1
            spine_file = spine_file[1]
            outline_file = outline_file[1]
            if outline_file[1:end-length("outline")] != spine_file[1:end-length("spine")]
                @warn "spine and outline filenames do not match"
            end
        else
            if isempty(outline_file)
                throw(SystemError("no outline file found", 2))
            elseif isempty(spine_file)
                throw(SystemError("no spine file found", 2))
            elseif 1 < length(outline_file)
                throw(ErrorException("multiple outline files found"))
            elseif 1 < length(outline_file)
                throw(ErrorException("multiple spine files found"))
            end
            @assert false # should never be reached
        end
    elseif endswith(path, ".spine")
        spine_file = path
        outline_file = spine_file[1:end-length("spine")] * "outline"
    elseif endswith(path, ".outline")
        outline_file = path
        spine_file = outline_file[1:end-length("outline")] * "spine"
    elseif isfile(path * ".outline")
        outline_file = path * ".outline"
        spine_file = path * ".spine"
    elseif isfile(path)
        throw(ErrorException("cannot determine whether file is spine or outline"))
    else
        throw(SystemError("no such file or directory: $path", 2))
    end
    return outline_file, spine_file
end

read_chore_files(::Type{<:Spine}, outline_file::String, spine_file::String) = read_spine(spine_file)
read_chore_files(::Type{<:Outline}, outline_file::String, spine_file::String) = read_outline(outline_file)

read_chore_files(specs::Records, outline_file::String, spine_file::String) = zip′(specs, read_chore_files, outline_file, spine_file)

read_chore_files(T, filepath::String) = read_chore_files(T, find_chore_files(filepath)...)

# copied from Datasets.jl
function is_date_time(s)
    try
        date, time = split(s, '_')
        return length(date) == 8 && length(time) == 6 && all(isdigit, date) && all(isdigit, time)
    catch
        return false
    end
end
is_protocol(s) = count(==('#'), s) == 3
is_tracker(s) = 1 < length(s) && s[1] == 't' && all(isdigit, s[2:end])

function parse_filename(filepath::String)
    metadata = Dict{Symbol, String}()
    filename = basename(filepath)
    stem, ext = splitext(filename)
    if ext == ".spine" || ext == ".outline"
        parts = split(stem, '@')
        if length(parts) == 6
            metadata[:date_time] = parts[1]
            metadata[:genotype] = parts[2]
            metadata[:effector] = parts[3]
            metadata[:tracker] = parts[4]
            metadata[:protocol] = parts[5]
            @assert is_date_time(metadata[:date_time])
            @assert is_tracker(metadata[:tracker])
            @assert is_protocol(metadata[:protocol])
        else
            @warn "Failed to identify metadata in file stem: \"$stem\""
        end
    else
        @assert is_date_time(filename)
        metadata[:date_time] = filename
    end
    return metadata
end

# deprecated

function read_chore_files(::Type{SpineOutline}, filepath::String)
    outline_file, spine_file = find_chore_files(filepath)
    outlines = read_outline(outline_file)
    spines = read_spine(spine_file)
    return zip′(SpineOutline, spines, outlines)
end

function LarvaBase.zip′(T::Type{<:SpineOutline}, spines::Runs{<:Spine}, outlines::Runs{<:Outline})
    runs = Runs{T}()
    for run in keys(outlines)
        run ∈ keys(spines) || throw(KeyError("no spines found for run: \"$run\""))
        larvae = Larvae{T}()
        spines′, outlines′ = spines[run], outlines[run]
        for id in keys(outlines′)
            id ∈ keys(spines′) || throw(KeyError("no spines found for larva: \"$id\""))
            spines″, outlines″ = spines′[id], outlines′[id]
            length(spines″) == length(outlines″) || throw(ArgumentError("spines and outlines do not match"))
            n = length(outlines″)
            spines_outlines = TimeSeries{T}(undef, n)
            for i in 1:n
                t′, spine = spines″[i]
                t, outline = outlines″[i]
                t == t′ || throw(ArgumentError("spines and outlines do not match"))
                spines_outlines[i] = (t, T(spine, outline))
            end
            larvae[id] = spines_outlines
        end
        runs[run] = larvae
    end
    return runs
end

function unzip′(spines_outlines::Runs{SpineOutline})
    spines, outlines = Runs{Spine}(), Runs{Outline}()
    for (run, spines_outlines′) in pairs(spines_outlines)
        spines[run] = spines′ = Larvae{Spine}()
        outlines[run] = outlines′ = Larvae{Outline}()
        for (id, spines_outlines″) in pairs(spines_outlines′)
            n = length(spines_outlines″)
            spines′[id] = spines″ = TimeSeries{Spine}(undef, n)
            outlines′[id] = outlines″ = TimeSeries{Outline}(undef, n)
            for i in 1:n
                t, spine_outline = spines_outlines″[i]
                spines″[i] = (t, spine(spine_outline))
                outlines″[i] = (t, outline(spine_outline))
            end
        end
    end
    return spines, outlines
end

end
