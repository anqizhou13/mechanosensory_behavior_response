"""
The `Formats` module features a unified `load` function for all file formats,
encapsulating types that can be used to specialize/test for a specific format,
and utilities to convert the original dictionary-based collections (of runs and larvae)
to/fro datatypes defined in the `Datasets` module.

Some defaults are also set here, so as to uniformize data across the multiple formats.
"""
module Formats

using ..LarvaBase: LarvaBase, Spine, Outline, BehaviorTags, derivedtype
using ..Chore: read_chore_files, parse_filename, find_chore_files
using ..Trxmat: read_trxmat, checktrxmat
using ..FIMTrack: read_fimtrack
using ..Datasets
using OrderedCollections: OrderedDict

export guessfileformat, preload, load, drop_record!, gettimeseries, astimeseries,
       getrun, asrun, getmetadata, getlabels, getdependencies, appendtags, TIME_PRECISION,
       labelledfiles, unload!, setdefaultlabel!, getprimarylabels, getsecondarylabels,
       find_associated_files

const TIME_PRECISION = 0.001

"""
`PreloadedFile` encapsulates every supported data file formats, and typically memoize
the computation of the `Run` representation of the data from the dictionary-based
representation or vice-versa, depending on the preferred underlying representation.
"""
abstract type PreloadedFile end
mutable struct Chore <: PreloadedFile
    source::String
    capabilities
    timeseries::LarvaBase.Larvae
    run::Run
end
mutable struct Trxmat <: PreloadedFile
    source::String
    capabilities
    timeseries::LarvaBase.Larvae
    run::Run
    labels::Vector{Symbol}
end
mutable struct FIMTrack <: PreloadedFile
    source::String
    capabilities
    timeseries::LarvaBase.Larvae
    run::Run
    framerate::Number
    pixelsize::Union{Nothing, Number}
    overrides::AbstractDict{Symbol}
end
mutable struct JSONLabels <: PreloadedFile
    source::String
    capabilities
    timeseries::LarvaBase.Larvae
    run::Run
    dependencies::Vector{PreloadedFile}
end

larvafile(T, path, capabilities, args...) = T(path,
                                              capabilities,
                                              LarvaBase.Larvae{derivedtype(capabilities)}(),
                                              Run("NA"),
                                              args...)

const spine_outline = (:spine=>Spine, :outline=>Outline)
const spine_outline_tags = (:spine=>Spine, :outline=>Outline, :tags=>BehaviorTags)

Chore(path::String) = larvafile(Chore, path, spine_outline)
Trxmat(path::String; tags=Symbol[]) = larvafile(Trxmat, path, spine_outline_tags, tags)
FIMTrack(path::String; framerate=1, pixelsize=nothing, overrides=nothing
        ) = larvafile(FIMTrack, path, spine_outline, framerate, pixelsize,
                      isnothing(overrides) ? Dict{Symbol, Any}() : overrides)
JSONLabels(path::String) = larvafile(JSONLabels, path, spine_outline_tags, PreloadedFile[])

"""
    guessfileformat(filepath; fail=false, shallow=false)

Read the first bytes of a file and guess its format.

Formats are returned as [`PreloadedFile`](@ref) concrete types.

If the format cannot be guessed and `fail` is `false`, `nothing` is returned; else an error
is thrown.

`shallow=true` allows skipping a time-consuming check for the presence of the `trx` record
in *trx.mat* files.
"""
function guessfileformat(path::String; fail::Bool=false, shallow::Bool=false)
    _, ext = splitext(path)
    if ext in trxmat_ext
        head((==)("MATLAB 7.3 MAT-file"), path, 19) && (shallow || checktrxmat(path)) && return Trxmat
    elseif ext in chore_ext
        head(r"^[0-9]{8}_[0-9]{6}\s[0-9]$", path, 17) && return Chore
    elseif ext in labels_ext
        head(r"^\{\s*\"metadata\":\s*{\s*\"id\":", path, ',') && return JSONLabels
    elseif ext in fimtrack_ext
        head(r"^,larva\([0-9]$", path, 8) && return FIMTrack
    end
    fail && throw("Cannot determine format for file: $path")
end

const chore_ext = (".outline",".spine")
const trxmat_ext = (".mat",)
const fimtrack_ext = (".csv",)
const labels_ext = (".json",".label",".labels",".nyxlabel")

head(pattern::Regex, s::IOStream, n) = head(s, n) do s
    !isnothing(match(pattern, s))
end
head(f::Function, s::IOStream, n::Int) = f(String(read(s, n)))
head(f::Function, s::IOStream, c::Char) = f(readuntil(s, c))
head(f, path::String, n) = open(path) do s
    head(f, s, n)
end

"""
    preload(filepath)
    preload(filetype, filepath)
    preload(FIMTrack, filepath; framerate=30, pixelsize=nothing)

Preload file at `filepath`, guessing its format or following concrete
[`PreloadedFile`](@ref) type `filetype`.

Depending on the file type, optional keyword arguments are admitted.

For example, for FIMTrack v2 csv files, arguments `framerate` (in frames per second) and
`pixelsize` (in μm) can be passed.
"""
function preload end

function preload(::Type{Chore}, path::String; kwargs...)
    file = Chore(path)
    metadata = parse_filename(path)
    file.run = Run(get(metadata, :date_time, "NA"); metadata...)
    return file
end
function preload(::Type{FIMTrack}, path::String;
                 framerate=nothing, pixelsize=nothing, overrides=nothing, metadata=nothing)
    if isnothing(framerate)
        if !isnothing(metadata) && haskey(metadata, :camera)
            metadata[:camera] = camera = Datasets.coerce_dict(metadata[:camera])
            if haskey(camera, :framerate)
                framerate = camera[:framerate]
            end
        end
        if isnothing(framerate)
            @info "Assuming 30-fps frame rate for FIMTrack v2 csv files"
            framerate = 30
        end
    end
    if isnothing(pixelsize) && !isnothing(metadata) && haskey(metadata, :camera)
        metadata[:camera] = camera = Datasets.coerce_dict(metadata[:camera])
        if haskey(camera, :pixelsize)
            pixelsize = camera[:pixelsize]
        end
    end
    if isnothing(overrides) && !isnothing(metadata) && haskey(metadata, :overrides)
        metadata[:overrides] = overrides = Datasets.coerce_dict(metadata[:overrides])
    end
    FIMTrack(path; framerate=framerate, pixelsize=pixelsize, overrides=overrides)
end
preload(T::DataType, path::String; kwargs...) = T(path)
preload(path::String; shallow::Bool=false, kwargs...) = preload(guessfileformat(path; fail=true, shallow=shallow), path; kwargs...)

function drop_record!(file::PreloadedFile, record::Symbol)
    @assert isempty(file.timeseries)
    file.capabilities = OrderedDict(recordname=>recordtype
                                    for (recordname, recordtype) in file.capabilities
                                    if recordname !== record)
    file.timeseries = LarvaBase.Larvae{derivedtype(file.capabilities)}()
    return file
end

drop_spines!(file) = drop_record!(file, :spine)
drop_outlines!(file) = drop_record!(file, :outline)

"""
    getmetadata(preloadedfile)

Metadata table as an `OrderedDict`. Only string attributes are included.
"""
function getmetadata(file)
    isempty(file.run) && isempty(file.timeseries) && load!(file)
    attributes = file.run.attributes
    return sort_metadata(get(attributes, :metadata, OrderedDict{Symbol, String}()))
end

"""
    getlabels(preloadedfile)

Dictionary of label-related data. Unique label names (`Vector{Symbol}`) are available at key
`:names`. Color information may also be available at key `:colors`.
"""
function getlabels end

getlabels(file; fail=false) = fail ? throw("no tags found") : Dict(:names=>Symbol[])
function getlabels(file::Trxmat; fail=false)
    if isempty(file.labels)
        isempty(file.timeseries) && load!(file)
        try
            timeseries = first(values(file.timeseries))
            _, state = first(timeseries)
            file.labels = state.tags.names
        catch
            fail && rethrow()
            return Dict(:names=>Symbol[])
        end
    end
    return Dict(:names=>file.labels)
end
function getlabels(file::JSONLabels; fail=false)
    isempty(file.run) && load!(file)
    #labels = file.run.attributes[:labels]
    _, recordname = Datasets.getlabels(file.run)
    labels = file.run.attributes[recordname]
    if !(labels isa AbstractDict)
        labels = Dict{Symbol, Vector}(:names=>labels)
    end
    if eltype(labels[:names]) !== Symbol
        labels[:names] = Symbol.(labels[:names])
    end
    return labels
end

getprimarylabels(file) = getlabels(file)[:names]
getprimarylabels(file::JSONLabels) = Datasets.getprimarylabels(file.run)

getsecondarylabels(file::JSONLabels) = Datasets.getsecondarylabels(file.run)

"""
    getnativerepr(preloadedfile)

Load timeseries data from file in the format preferred at low-level, either
[`Larvae`](@ref Main.PlanarLarvae.LarvaBase.Larvae) or
[`Run`](@ref Main.PlanarLarvae.Datasets.Run).
"""
function getnativerepr end

getnativerepr(file::Chore) = gettimeseries(file)
getnativerepr(file::Trxmat) = gettimeseries(file)
getnativerepr(file::FIMTrack) = getrun(file)
# note: labels files with no data dependencies may be broken
getnativerepr(file::JSONLabels) = isempty(file.dependencies) ? getrun(file) : getnativerepr(file.dependencies[1])

"""
    gettimeseries(preloadedfile)

Dictionary-based representation of the data.
Tracks are vectors of time-state couples, with states encoded as named tuples.

See also type [`Larvae`](@ref Main.PlanarLarvae.LarvaBase.Larvae).
"""
function gettimeseries end

function gettimeseries(file; shallow=false)
    if isempty(file.timeseries)
        isempty(file.run) && load!(file)
        if isempty(file.timeseries)
            file.timeseries = astimeseries(file.run)
        end
    end
    return file.timeseries
end
function gettimeseries(file::JSONLabels; shallow=false)
    timeseries = file.timeseries
    if isempty(timeseries)
        isempty(file.dependencies) && getdependencies!(file)
        timeseries = gettimeseries(file.dependencies[1])
        if !shallow
            file.timeseries = timeseries = appendtags(timeseries, file.run)
        end
    end
    return timeseries
end

"""
    getrun(preloadedfile)

[`Run`](@ref Main.PlanarLarvae.Datasets.Run)-based representation of the data.
"""
function getrun end

function getrun′(file)
    if isempty(file.run)
        isempty(file.timeseries) && load!(file)
        if isempty(file.run)
            file.run = asrun(file.run.id, file.timeseries, file.run.attributes)
        end
    end
    return file.run
end
getrun(file; shallow::Bool=true) = getrun′(file)
function getrun(file::JSONLabels; shallow::Bool=true)
    shallow || throw("deep load not implemented for json label files")
    getrun′(file)
end

"""
    getdependencies(preloadedfile)

Vector of associated track data file names.
"""
getdependencies(file) = String[]
getdependencies(path::String) = getdependencies(preload(path))
function getdependencies(file::JSONLabels)
    isempty(file.run) && load!(file)
    return Datasets.getdependencies(file.run, file.source)
end

"""
    getdependencies!(preloadedfile)

Vector of associated track data file names.

Unlike [`getdependencies`](@ref), this function pre-loads all the data dependencies.
"""
function getdependencies!(file::JSONLabels)
    deps = getdependencies(file)
    @assert !isempty(deps)
    file.dependencies = preload.(deps; metadata=get(file.run.attributes, :metadata, nothing))
    deps
end

# conversion utilities

coerce_capabilities(caps) = caps
coerce_capabilities(caps::AbstractDict) = tuple(pairs(caps)...)

asnamedtuple(states, i) = NamedTuple(key=>val[i] for (key, val) in pairs(states))

function astimeseries(track::Track)
    firststate = asnamedtuple(track.states, 1)
    T = typeof(firststate)
    timeseries = LarvaBase.TimeSeries{T}()
    for (i, t) in enumerate(track.timestamps)
        push!(timeseries, (t, asnamedtuple(track.states, i)))
    end
    return timeseries
end

function astimeseries(run::Run)
    track = first(values(run.tracks))
    firststate = asnamedtuple(track.states, 1)
    T = typeof(firststate)
    larvae = OrderedDict{LarvaBase.LarvaID, LarvaBase.TimeSeries{T}}()
    for track in values(run.tracks)
        larvae[track.id] = timeseries = LarvaBase.TimeSeries{T}()
        for (i, t) in enumerate(track.timestamps)
            push!(timeseries, (t, asnamedtuple(track.states, i)))
        end
    end
    return larvae
end

LarvaBase.eachtimeseries(run::Run) = astimeseries(run)

function appendtags(timeseries, run)
    alllabels, _ = Datasets.getlabels(run)#run.attributes[:labels]
    if alllabels isa AbstractDict
        alllabels = alllabels[:names]
    end
    if eltype(alllabels) !== Symbol
        alllabels = Symbol.(alllabels)
    end
    notags = BehaviorTags(alllabels, Symbol[])
    #
    _, example_records = first(first(values(timeseries)))
    recordnames = collect(keys(example_records))
    tags_field = findfirst(name -> name === :tags, recordnames)
    if isnothing(tags_field)
        push!(recordnames, :tags)
        records = collect(Any, values(example_records))
        push!(records, BehaviorTags(Symbol[]))
        newrecordtype = NamedTuple{tuple(recordnames...), typeof(tuple(records...))}
    else
        newrecordtype = typeof(example_records)
    end
    newtimeseries = LarvaBase.Larvae{newrecordtype}()
    for (id, track) in pairs(timeseries)
        newtrack = LarvaBase.TimeSeries{newrecordtype}()
        if id in keys(run)
            track′= run[id]
            labels = track′[:labels]
            times′= LarvaBase.times(track′)
            j = 1
            t′ = times′[j]
            for (t, state) in track
                if abs(t - t′) < TIME_PRECISION
                    tags = BehaviorTags(alllabels, begin
                                            l = labels[j]
                                            l isa Vector ? (isempty(l) ? Symbol[] : Symbol.(l)) : [Symbol(l)]
                                        end)
                    j += 1
                    t′= length(times′) < j ? Inf : times′[j]
                else
                    tags = notags
                end
                newstate = collect(Any, values(state))
                if isnothing(tags_field)
                    push!(newstate, tags)
                else
                    newstate[tags_field] = tags
                end
                push!(newtrack, (t, newrecordtype(newstate)))
            end
        else
            for (t, state) in track
                newstate = collect(Any, values(state))
                if isnothing(tags_field)
                    push!(newstate, notags)
                else
                    newstate[tags_field] = notags
                end
                push!(newtrack, (t, newrecordtype(newstate)))
            end
        end
        newtimeseries[id] = newtrack
    end
    return newtimeseries
end

function asrun(runid::Datasets.RunID, timeseries::LarvaBase.Larvae,
        attributes::Datasets.Attributes=Datasets.ConcreteAttributes())
    tracks = Track[]
    timetype = nothing
    recordtypes = nothing
    for (trackid, trackdata) in pairs(timeseries)
        if isnothing(recordtypes)
            example_timestamp, example_state = first(trackdata) # @assert !isempty(trackdata)
            timetype = typeof(example_timestamp)
            recordtypes = OrderedDict(fieldname=>typeof(field) for (fieldname, field) in pairs(example_state))
        end
        n = length(timeseries)
        timestamps = timetype[]
        sizehint!(timestamps, n)
        records = OrderedDict{Symbol, Vector}()
        for (recordname, recordtype) in pairs(recordtypes)
            records[recordname] = record = recordtype[]
            sizehint!(record, n)
        end
        for (timestamp, state) in trackdata
            push!(timestamps, timestamp)
            for (recordname, record) in pairs(records)
                push!(record, state[recordname])
            end
        end
        push!(tracks, Track(trackid, timestamps, records))
    end
    return Run(runid, attributes, tracks)
end


"""
    load(path::String)

Load spines, outlines and behavior tags from data files of any supported type and return a
concrete [`PreloadedFile`](@ref) object.

Data dependencies are lazily loaded.

Behavior tags are silently omitted if missing.
"""
function load(path::String; spines=true, outlines=true, kwargs...)
    @assert isfile(path)
    file = preload(path; kwargs...)
    spines || drop_spines!(file)
    outlines || drop_outlines!(file)
    load!(file)
end

"""
    load!(preloadedFile)

Actually load a pre-loaded file, as returned by [`preload`](@ref).

See also [`load`](@ref).
"""
function load!(file::Chore)
    Timeseries = typeof(file.timeseries)
    runs = read_chore_files(coerce_capabilities(file.capabilities), file.source)
    @assert length(runs) == 1
    runid, file.timeseries = first(pairs(runs))
    @assert file.timeseries isa Timeseries
    if file.run.id == "NA"
        file.run = Run(runid, file.run.attributes, file.run.tracks)
    end
    @assert file.run.id == runid
    return file
end

function load!(file::Trxmat)
    Timeseries = typeof(file.timeseries)
    runs = read_trxmat(coerce_capabilities(file.capabilities), file.source)
    @assert length(runs) == 1
    runid, file.timeseries = first(pairs(runs))
    @assert file.timeseries isa Timeseries
    @assert isempty(file.run)# && file.run.id == "NA"
    file.run = Run(runid)
    return file
end

function load!(file::FIMTrack)
    kwargs = Dict{Symbol, Any}()
    overrides = file.overrides
    if :radius_1 in keys(overrides) && :radius_2 in keys(overrides) && :radius_3 in keys(overrides)
        :radius_4 in keys(overrides) && throw("overrides radius_4 and more not supported")
        kwargs[:radii] = [overrides[:radius_1], overrides[:radius_2], overrides[:radius_3]]
    end
    file.run = Run("NA",
                   read_fimtrack(coerce_capabilities(file.capabilities),
                                 file.source;
                                 framerate=file.framerate,
                                 pixelsize=file.pixelsize,
                                 kwargs...))
    metadata = get!(OrderedDict{Symbol, Any}, file.run.attributes, :metadata)
    camera = get!(OrderedDict{Symbol, Any}, metadata, :camera)
    camera[:framerate] = file.framerate
    if !isnothing(file.pixelsize)
        camera[:pixelsize] = file.pixelsize
    end
    units = get!(OrderedDict{Symbol, String}, file.run.attributes, :units)
    units[:t] = "s"
    units[:framerate] = "fps"
    if !isnothing(file.pixelsize)
        units[:pixelsize] = "μm"
    end
    return file
end

function load!(file::JSONLabels)
    file.run = decodelabels!(Datasets.from_json_file(Run, file.source))
    return file
end

"""
    unload!(loadedfile)

Unload timeseries data to free memory space.
"""
function unload!(file::Formats.JSONLabels; gc=false)
    for dep in file.dependencies
        unload!(dep)
    end
    empty!(file.dependencies)
    empty!(file.timeseries)
    empty!(file.run)
    gc && GC.gc()
    return file
end
function unload!(file; gc=false)
    empty!(file.timeseries)
    empty!(file.run)
    gc && GC.gc()
    return file
end

"""
    labelledfiles(repository, chunks=false)
    labelledfiles(...; selection_rule=nothing, shallow=false)

List all labelled files (*trx.mat* and *.label* files) found in a repository.

If multiple JSON *.label* files with common data dependencies are found in a directory,
only the last *.label* file is listed, unless `chunks` is `true` (the various files are
assumed to address different tracks in the same data file).

Data dependencies are also omitted.

The returned files are of type [`PreloadedFile`](@ref).

`selection_rule` is a boolean function that takes a filename as input argument, and returns
`true` if the file is to be included. This can be used to speed up the filtering of labelled
files.

The `shallow` argument is passed to [`guessfileformat`](@ref).
"""
function labelledfiles(repository::String=".", chunks::Bool=false;
        selection_rule=nothing, shallow=false)
    files = Vector{PreloadedFile}[]
    for (parent, _, children) in walkdir(repository; follow_symlinks=true)
        deps = Dict{String, Vector{JSONLabels}}()
        files′= PreloadedFile[]
        for file in children
            isnothing(selection_rule) || selection_rule(file) || continue
            file′ = try
                preload(joinpath(parent, file); shallow=shallow)
            catch
                continue
            end
            if file′ isa Trxmat || file′ isa JSONLabels
                push!(files′, file′)
                if file′ isa JSONLabels
                    for dep in getdependencies(file′)
                        push!(get!(()->JSONLabels[], deps, dep), file′)
                    end
                end
            end
        end
        conflicting = JSONLabels[]
        if !chunks
            for (dep, files″) in pairs(deps)
                if 1 < length(files″)
                    for f in files″[1:end-1]
                        push!(conflicting, f)
                    end
                    @info "Multiple label files for a same data dependency" dir=parent dependency=basename(dep) labelfiles=[basename(f.source) for f in files″]
                end
            end
        end
        filter!(f -> f.source ∉ keys(deps) && f ∉ conflicting, files′)
        push!(files, files′)
    end
    return Iterators.flatten(files)
end

"""
    from_mwt(preloadedfile)

Tell whether the data in the file derive from MWT (`true`) or not (`false`).
"""
function from_mwt end

from_mwt(file::Chore) = true
from_mwt(file::Trxmat) = true
from_mwt(file::FIMTrack) = false
function from_mwt(file::JSONLabels)
    if isempty(file.dependencies)
        try
            getdependencies!(file)
        catch
            # note: labels files with no data dependencies may be broken
            return false
        end
    end
    from_mwt(file.dependencies[1])
end

# asemptytracks(run_or_timeseries) = [Track(trackid, LarvaBase.times(trackdata))
#                                     for (trackid, trackdata) in pairs(run_or_timeseries)]
#
# asemptytracks(file::PreloadedFile) = asemptytracks(getnativerepr(file))

"""
    setdefaultlabel!(label_file_or_run, label_for_untagged_data)

Assign a label/tag to the unlabelled/untagged data.

All the data points defined in the data dependencies of the label file are considered, and
not only those defined in the label file.
"""
function setdefaultlabel!(run::Run, defaultlabel; attrname=(:labels, :names), filepath=nothing)
    deps = Datasets.getdependencies(run, filepath)
    fullrun = if isempty(deps)
        run
    else
        dependency = preload(deps[1])
        getrun(dependency)
    end
    Datasets.setdefaultlabel!(run, fullrun, defaultlabel; attrname=attrname)
end

function setdefaultlabel!(file::JSONLabels, defaultlabel; attrname=(:labels, :names))
    deps = getdependencies!(file)
    fullrun = if isempty(deps)
        getrun(file)
    else
        dependency = file.dependencies[1]
        getrun(dependency)
    end
    Datasets.setdefaultlabel!(getrun(file), fullrun, defaultlabel; attrname=attrname)
    return file
end

"""
    find_associated_files(file::PreloadedFile) -> Vector{PreloadedFile}

List the data files associated with the input data file, along with the input file.

The concept of *associated files* include:
* the data dependencies of a *.label* file;
* the associated *.spine* file for a *.outline* file, and conversely;

This helper function will become more useful with data formats such as MWT raw output,
that include possibly multiple *.blobs* files, a *.summary* file, etc.

The returned array of files can be muted.
"""
find_associated_files(file::String) = find_associated_files(preload(file))

function find_associated_files(files::AbstractVector)
    unique(Iterators.flatmap(find_associated_files, files)) do f
        f.source
    end
end

find_associated_files(file::PreloadedFile) = PreloadedFile[file]

function find_associated_files(file::JSONLabels)
    getdependencies!(file)
    # if dependencies are other json label files, the set of associated files should be
    # recursively expanded. As such a case is not supposed to occur, we just check and throw
    # and error instead
    if any(f -> f isa JSONLabels, file.dependencies)
        throw("JSON label file found as data dependency; recursively expanding the list of data dependencies is not implemented yet")
    end
    return PreloadedFile[file, file.dependencies...]
end

function find_associated_files(file::Chore)
    files = PreloadedFile[file]
    outlinefile, spinefile = find_chore_files(file.source)
    sibling = file.source == outlinefile ? spinefile : outlinefile
    if isfile(sibling)
        push!(files, preload(sibling))
    else
        @warn "Cannot find sibling file" sibling
    end
    return files
end

"""
    normalize_timestamps(file::PreloadedFile; digits=4)

Ensure timestamps are 4-decimal at most.
"""
function normalize_timestamps(file, ts=nothing; digits=4)
    normalize_run_timestamps(file, ts; digits=digits)
end

function normalize_timestamps(file::Union{Chore, Trxmat}, ts=nothing; digits=4)
    normalize_timeseries_timestamps(file, ts; digits=digits)
end

function normalize_timestamps(file::JSONLabels, ts=nothing; digits=4)
    run = normalize_run_timestamps(file, ts; digits=digits)
    ts = Dict(track.id => track.timestamps for track in values(run))
    isempty(file.dependencies) && Formats.getdependencies!(file)
    for file′ in file.dependencies
        normalize_timestamps(file′, ts; digits=digits)
    end
    return run
end

function normalize_timeseries_timestamps(file, ts=nothing; digits=4)
    isempty(file.timeseries) && load!(file)
    timeseries = gettimeseries(file)
    @assert isempty(file.run)
    if isnothing(ts)
        for (trackid, track) in pairs(timeseries)
            track = [(round(t; digits=digits), v) for (t, v) in track]
            timeseries[trackid] = track
        end
    else
        for (trackid, track) in pairs(timeseries)
            if trackid ∉ keys(ts)
                @debug "Skipping track #$trackid"
                continue
            end
            ts′= ts[trackid]
            if length(track) != length(ts′)
                @debug "Unequal numbers of time steps"
                # we assume `ts` is a segment (successive timestamps in `track`)
                i = searchsortedfirst(LarvaBase.times(track), ts′[1])
                t0 = round(track[i][1]; digits=digits)
                if ts′[1] != t0 && 1 < i
                    i -= 1
                    t0 = round(track[i][1]; digits=digits)
                end
                j = i + length(ts′) - 1
                t1 = round(track[j][1]; digits=digits)
                if t0 == ts′[1] && t1 == ts′[end]
                    track = track[i:j]
                else
                    t0=[t for (t, _) in track[i-1:i+1]]; t1=[t for (t, _) in track[j-1:j+1]]
                    @debug "Cannot find segment ends in extended timeseries" t0[1] t0[2] t0[3] t0′=ts′[1] t1[1] t1[2] t1[3] t1′=ts′[end]
                    throw("Cannot find contiguous timestamps")
                end
            end
            timeseries[trackid] = [(t, v) for (t, (_, v)) in zip(ts′, track)]
        end
    end
    return timeseries
end

function normalize_run_timestamps(file, ts=nothing; digits=4)
    isempty(file.run) && load!(file)
    run = getrun(file)
    @assert isempty(file.timeseries)
    if isnothing(ts)
        for track in values(run)
            for (i, t) in enumerate(track.timestamps)
                track.timestamps[i] = round(t; digits=digits)
            end
        end
    else
        for track in values(run)
            ts′= ts[track.id]
            length(track.timestamps) == length(ts′) || throw("unequal numbers of time steps")
            for (i, t) in enumerate(ts′)
                track.timestamps[i] = t
            end
        end
    end
    return run
end

end
