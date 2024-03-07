module Datasets

using ..LarvaBase: LarvaBase, LarvaID
using OrderedCollections: OrderedDict
using StructTypes
import JSON3
import JSON3 as JSON
using SHA: sha1

export Dataset, Run, Track, extract_metadata_from_filepath, sort_metadata,
       encodelabels, encodelabels!, decodelabels, decodelabels!, mergelabels!, appendlabel!,
       shareddependencies #, pushdependency!, getdependencies, setdefaultlabel!

const Attributes = AbstractDict{Symbol, Any}
const ConcreteAttributes = Dict{Symbol, Any} # ConcreteAttributes() as default argument value
const Dict′ = OrderedDict{Symbol, Any}

const AbstractTrackID = Integer
const TrackID = LarvaID
const Timestamp = Float64

"""
    Track(id; attributes...)
    Track(id, timestamps; attributes...)
    Track(id, timestamps, states; attributes...)
    Track(id, attributes, timestamps, states)

Specialized datatype for moving objects as timeseries, similar to type alias
[`TimeSeries`](@ref Main.PlanarLarvae.LarvaBase.TimeSeries), with metadata stored in
attribute `attributes`), and dedicated JSON serialization.

The `states` dictionary attribute stores the data records, that align with the `timestamps`
attribute in the number of elements.

A `Track` dictionary-like object can be indexed:

* by timestamp (type `Float64`): elements are dictionaries of record-value pairs,
* by record (type `Symbol`): elements are vectors with as many elements as the `timestamps`
  attribute,
* or by record (first) and timestamp (second): elements are single record values.

See also [`Run`](@ref).
"""
struct Track
    id::TrackID
    attributes::Attributes
    timestamps::Vector{Timestamp}
    states::OrderedDict{Symbol, Vector}

    function Track(id::AbstractTrackID,
            attributes::Attributes,
            timestamps::Vector{Timestamp},
            states::OrderedDict{Symbol, <:Vector})
        n = length(timestamps)
        for (record, timeseries) in pairs(states)
            length(timeseries) == n || throw(ArgumentError("record \"$(record)\" does not match timestamps"))
        end
        new(TrackID(id), attributes, timestamps, states)
    end
end

const RunID = String

"""
    Run(id; metadata...)
    Run(id, tracks; metadata...)
    Run(id, attributes, tracks)

Dictionary-like datatype for tracks/larvae, similar to type alias
[`Larvae`](@ref Main.PlanarLarvae.LarvaBase.Larvae), with metadata and dedicated JSON
serialization.

Splatted keyword arguments are stored as an `OrderedDict` in `attributes[:metadata]`.

See also [`Track`](@ref) and [`Dataset`](@ref).
"""
struct Run <: AbstractDict{AbstractTrackID, Track}
    id::RunID
    attributes::Attributes
    tracks::OrderedDict{TrackID, Track}
end

"""
    Dataset(runs=Run[]; attributes...)
    Dataset(attributes, runs)

Dictionary-like datatype for runs, similar to type alias
[`Runs`](@ref Main.PlanarLarvae.LarvaBase.Runs), with metadata.

See also [`Run`](@ref).
"""
struct Dataset <: AbstractDict{RunID, Run}
    attributes::Attributes
    runs::OrderedDict{RunID, Run}
end

function Track(id::AbstractTrackID,
        timestamps::Vector{Timestamp},
        states::OrderedDict{Symbol, <:Vector};
        kwargs...)
    Track(id, Dict′(kwargs), timestamps, states)
end
Track(id::AbstractTrackID, timestamps::Vector{Timestamp}, states; kwargs...) = Track(id, timestamps, OrderedDict{Symbol, Vector}(states); kwargs...)
Track(id::AbstractTrackID, timestamps::Vector{Timestamp}; kwargs...) = Track(id, timestamps, OrderedDict{Symbol, Vector}(); kwargs...)
Track(id::AbstractTrackID; kwargs...) = Track(id, Timestamp[]; kwargs...)

to_dict(coll::AbstractDict) = coll
to_dict(vec) = OrderedDict([(elem.id, elem) for elem in vec])

function to_vec(coll::OrderedDict{K,V}) where {K,V}
    vec = V[]
    for (k, v) in pairs(coll)
        k === v.id || throw(KeyError("key $(k) differs from value id $(v.id)"))
        push!(vec, v)
    end
    return vec
end

Run(id::RunID, attributes::Attributes, tracks::Vector{Track}) = Run(id, attributes, to_dict(tracks))
function Run(id::RunID, tracks; kwargs...)
    attributes = isempty(kwargs) ? Dict′() : Dict′(:metadata => Dict′(kwargs))
    Run(id, attributes, tracks)
end
Run(id::RunID; kwargs...) = Run(id, Track[]; kwargs...)

Dataset(attributes::Attributes, runs::Vector{Run}) = Dataset(attributes, to_dict(runs))
Dataset(runs=Run[]; kwargs...) = Dataset(Dict′(kwargs), runs)

Base.:(==)(d1::Dataset, d2::Dataset) = d1.attributes == d2.attributes && d1.runs == d2.runs
Base.:(==)(r1::Run, r2::Run) = r1.id == r2.id && r1.attributes == r2.attributes && r1.tracks == r2.tracks
Base.:(==)(t1::Track, t2::Track) = t1.id == t2.id && t1.attributes == t2.attributes && t1.timestamps == t2.timestamps && t1.states == t2.states

Base.isempty(track::Track) = isempty(track.timestamps) || isempty(track.states)
Base.isempty(run::Run) = isempty(run.tracks)
Base.isempty(dataset::Dataset) = isempty(dataset.runs)

Base.empty!(track::Track) = empty!(track.states)
Base.empty!(run::Run) = empty!(run.tracks)
Base.empty!(dataset::Dataset) = empty!(dataset.runs)

Base.length(run::Run) = length(run.tracks)
Base.length(dataset::Dataset) = length(dataset.runs)

function Base.getindex(track::Track, timestamp::Timestamp)
    index = findfirst(==(timestamp), track.timestamps)
    return OrderedDict([(record, track.states[record][index]) for record in keys(track.states)])
end
function Base.getindex(track::Track, record::Symbol)
    if record === :timestamps
        track.timestamps
    else
        track.states[record]
    end
end
function Base.getindex(track::Track, record::Symbol, timestamp::Timestamp)
    index = findfirst(==(timestamp), track.timestamps)
    return track.states[record][index]
end
Base.getindex(run::Run, track::AbstractTrackID) = run.tracks[TrackID(track)]
Base.getindex(dataset::Dataset, run::RunID) = dataset.runs[run]

function Base.setindex!(track::Track, value, record::Symbol, timestamp::Timestamp)
    index = findfirst(==(timestamp), track.timestamps)
    track.states[record][index] = value
    return track
end
function Base.setindex!(track::Track, state::AbstractDict{Symbol, <:Any}, timestamp::Timestamp)
    index = findfirst(==(timestamp), track.timestamps)
    for record in keys(state)
        track.states[record][index] = state[record]
    end
    return track
end
function Base.setindex!(track::Track, timeseries::Vector, record::Symbol)
    length(timeseries) == length(track.timestamps) || throw(ArgumentError("record \"$(record)\" does not match timestamps"))
    track.states[record] = timeseries
    return track
end
function Base.setindex!(run::Run, track::Track, id::AbstractTrackID)
    id = TrackID(id)
    id == track.id || throw(KeyError("track id $(track.id) does not equal key $(id)"))
    run.tracks[id] = track
    return run
end
function Base.setindex!(dataset::Dataset, run::Run, id::RunID)
    id == run.id || throw(KeyError("track id $(run.id) does not equal key $(id)"))
    dataset.runs[id] = run
    return dataset
end

Base.haskey(track::Track, timestamp::Timestamp) = any(==(timestamp), track.timestamps)
Base.haskey(track::Track, record::Symbol) = record === :timestamps || haskey(track.states, record)
# function Base.haskey(track::Track, record::Symbol, timestamp::Timestamp)
#     haskey(track.states, record) && haskey(track, timestamp)
# end
Base.haskey(run::Run, track::AbstractTrackID) = haskey(run.tracks, TrackID(track))
Base.haskey(dataset::Dataset, run::RunID) = haskey(dataset.runs, run)

function Base.delete!(track::Track, record::Symbol)
    record === :timestamps && throw(KeyError("cannot delete the timestamps attribute"))
    delete!(track.states, record)
    return track
end
function Base.delete!(run::Run, track::AbstractTrackID)
    delete!(run.tracks, TrackID(track))
    return run
end
function Base.delete!(dataset::Dataset, run::RunID)
    delete!(dataset.runs, run)
    return dataset
end

Base.keys(run::Run) = keys(run.tracks)
Base.keys(dataset::Dataset) = keys(dataset.runs)

Base.values(run::Run) = values(run.tracks)
Base.values(dataset::Dataset) = values(dataset.runs)

Base.pairs(run::Run) = pairs(run.tracks)
Base.pairs(dataset::Dataset) = pairs(dataset.runs)

function Base.show(io::IO, mime::MIME"text/plain", dataset::Dataset)
    if isempty(dataset)
        println(io, "Dataset()")
    else
        nruns = length(dataset)
        write(io, "Dataset with $nruns run$(nruns == 1 ? "" : "s"):")
        for run in values(dataset)
            write(io, "\n")
            show(io, mime, run)
        end
        if !isempty(dataset.attributes)
            write(io, "\n---------------\nGlobal dataset attributes:  ")
            show(io, mime, dataset.attributes)
        end
    end
end

function Base.show(io::IO, mime::MIME"text/plain", run::Run)
    if isempty(run) && isempty(run.attributes)
        write(io, "Run(\"$(run.id)\")")
    else
        ntracks = length(run)
        write(io, "Run(\"$(run.id)\") with $ntracks track$(ntracks == 1 ? "" : "s")")
        for track in values(run)
            write(io, "\n")
            show(io, mime, track)
        end
        attributes = copy(run.attributes)
        metadata = pop!(attributes, :metadata, Dict′())
        if !isempty(metadata)
            write(io, "\nwith metadata: ")
            show(io, mime, metadata)
        end
        if !isempty(attributes)
            write(io, "\nwith attributes: ")
            show(io, mime, attributes)
        end
    end
end

Base.show(io::IO, dataset::Dataset) = show(io, "text/plain", dataset)
Base.show(io::IO, run::Run) = show(io, "text/plain", run)

# TODO: find out why `lowertype` seems to impact `construct` only
const DictType = Dict{String, Any}

coerce_dict(d::Dict′) = d
coerce_dict(d) = Dict′(Symbol(key)=>value for (key, value) in pairs(d))

function getdict!(d, child)
    dict = d[child]
    if eltype(keys(dict)) !== Symbol
        d[child] = dict = coerce_dict(dict)
    end
    return dict
end

StructTypes.StructType(::Type{Track}) = StructTypes.CustomStruct()
StructTypes.lowertype(::Type{Track}) = DictType

function StructTypes.lower(track::Track)
    repr = Dict′()
    repr[:id] = string(track.id)
    n = length(track.timestamps)
    for attribute in keys(track.attributes)
        if haskey(track, attribute)
            @warn "Attribute \"$(attribute)\" conflicts with record name"
        else
            value = track.attributes[attribute]
            if value isa Vector && length(value) == n
                @warn "Attribute \"$(attribute)\" may be improperly deserialized as a record/timeseries"
            end
            repr[attribute] = value
        end
    end
    # assume timestamps are in seconds and set time precision equal to 1ms
    repr[:t] = (x -> round(x; digits=3)).(track.timestamps)
    for (record, array) in pairs(track.states)
        length(array) == n || @warn "Record \"$(record)\" does not match timestamps and may be deserialized as an attribute"
        repr[record] = array
    end
    return repr
end

StructTypes.StructType(::Type{Run}) = StructTypes.CustomStruct()
StructTypes.lowertype(::Type{Run}) = DictType

function StructTypes.lower(run::Run)
    attributes = copy(run.attributes)
    repr = Dict′()
    repr[:metadata] = if :metadata in keys(attributes)
        Dict′(:id => run.id, pop!(attributes, :metadata)...) # push :id first
    else
        Dict′(:id => run.id)
    end
    repr[:units] = pop!(run.attributes, :units, OrderedDict(:t => "s"))
    for attr in keys(attributes)
        if haskey(attributes, :data)
            @warn "Name \"data\" conflicts with native attribute"
        else
            repr[attr] = attributes[attr]
        end
    end
    repr[:data] = isempty(run.tracks) ? Track[] : to_vec(run.tracks)
    return repr
end

StructTypes.StructType(::Type{Dataset}) = StructTypes.CustomStruct()
StructTypes.lowertype(::Type{Dataset}) = DictType

function StructTypes.lower(dataset::Dataset)
    repr = Dict′()
    for attribute in keys(dataset.attributes)
        if attribute === :runs
            @warn "Name \"runs\" conflicts with native attribute"
        else
            repr[attribute] = dataset.attributes[attribute]
        end
    end
    if !isempty(dataset.runs)
        repr[:runs] = OrderedDict(key=>StructTypes.lower(value) for (key, value) in pairs(dataset.runs))
    end
    return repr
end

"""
    Datasets.from_json_file(filename)
    Datasets.from_json_file(Dataset, filename)
    Datasets.from_json_file(Run, filename)

Deserialize a JSON file into a `Dataset` or `Run` object.

See also [`Datasets.to_json_file`](@ref).
"""
function from_json_file end

function from_json_file(filename)
    # for backward compatibility: return a dataset made of a single run
    run = from_json_file(Run, filename)
    return Dataset([run])
end

from_json(source) = from_json(Dataset, source)

function from_json_file(::Type{T}, filename) where {T}
    json = read(filename, String)
    return JSON.read(json, T)
end

from_json(::Type{T}, source) where {T} = JSON.read(source, T)

function StructTypes.construct(::Type{Dataset}, dict::Dict)
    attributes = dict = coerce_dict(dict)
    runs_dict = pop!(dict, :runs, Dict{String, Any}())
    isempty(runs_dict) && @debug "No runs found"
    runs = Run[]
    for run in values(runs_dict)
        push!(runs, StructTypes.construct(Run, run))
    end
    return Dataset(attributes, runs)
end

function StructTypes.construct(::Type{Run}, dict::Dict)
    dict = coerce_dict(dict)
    attributes = Dict′() # separate dictionary to control the order
    metadata = coerce_dict(pop!(dict, :metadata))
    id = pop!(metadata, :id)
    if !isempty(metadata)
        attributes[:metadata] = metadata
    end
    try
        units = coerce_dict(pop!(dict, :units))
        attributes[:units] = units
    catch
    end
    tracks_array = pop!(dict, :data)
    @assert tracks_array isa Vector
    isempty(tracks_array) && @debug "No tracks found in run \"$(id)\""
    tracks = [StructTypes.construct(Track, track) for track in tracks_array]
    for (attr, value) in pairs(dict)
        attributes[attr] = value isa Dict ? coerce_dict(value) : value
    end
    return Run(id, attributes, isempty(tracks) ? Track[] : tracks)
end

function StructTypes.construct(::Type{Track}, dict::Dict)
    dict = coerce_dict(dict)
    id = parse(TrackID, pop!(dict, :id))
    timestamps = convert(Vector{Timestamp}, pop!(dict, :t))
    n = length(timestamps)
    attributes = Dict′()
    states = OrderedDict{Symbol, Vector}()
    for (key, value) in pairs(dict)
        if value isa Vector && length(value) == n
            states[key] = coerce_eltype(value)
        else
            attributes[key] = value
        end
    end
    return Track(id, attributes, timestamps, states)
end

function coerce_eltype(values::Vector)
    if isempty(values)
        values
    else
        T = Any
        for value in values
            if isbits(value) || (value isa String)
                T = typeof(value)
            else
                T = eltype(value)
            end
            T === Any || break
        end
        return coerce_eltype.(T, values)
    end
end

function coerce_eltype(::Type{T}, value) where {T}
    value isa Vector ? convert.(T, value) : convert(T, value)
end

# modified prettifying

prettify(out, str; depth=Inf, kw...) = prettify(out, str, 0, 0, depth; kw...)

function prettify(out::IO, str::String, indent, offset, depth=Inf; kw...)
    # modified copy of JSON3.pretty
    # see:
    # https://github.com/quinnj/JSON3.jl/blob/33a037055e4eac58d5caf360b4903d4a5e51e0c2/src/pretty.jl
    buf = codeunits(str)
    len = length(buf)
    if len == 0
        return
    end
    pos = 1
    b = JSON3.getbyte(buf, pos)
    if depth < 1
        Base.write(out, str)
    elseif b == UInt8('{')
        Base.write(out, "{\n")

        obj = JSON3.read(str; kw...)

        if length(obj) == 0
            Base.write(out, "}")
            return
        end

        ks = collect(keys(obj))
        maxlen = maximum(map(sizeof, ks)) + 5
        indent += 1

        i = 1
        for (key, value) in obj
            Base.write(out, "  "^indent)
            Base.write(out, lpad("\"$(key)\"" * ": ", maxlen + offset, ' '))
            prettify(out, JSON3.write(value; kw...), indent, maxlen + offset, depth-1; kw...)
            if i == length(obj)
                indent -= 1
                Base.write(out, "\n" * ("  "^indent * " "^offset) * "}")
            else
                Base.write(out, ",\n")
                i += 1
            end
        end
    elseif b == UInt8('[')
        Base.write(out, "[\n")

        arr = JSON3.read(str; kw...)

        if length(arr) == 0
            Base.write(out, "]")
            return
        end

        indent += 1

        for (i, val) in enumerate(arr)
            Base.write(out, "  "^indent * " "^offset)
            prettify(out, JSON3.write(val; kw...), indent, offset, depth-1; kw...)
            if i == length(arr)
                indent -= 1
                Base.write(out, "\n" * ("  "^indent * " "^offset) * "]")
            else
                Base.write(out, ",\n")
            end
        end
    else
        Base.write(out, str)
    end
    return
end

"""
    Datasets.to_json_file(filename, dataset_or_run)

Serialize a `Dataset` or `Run` object into a JSON file.

See also [`Datasets.from_json_file`](@ref).
"""
function to_json_file end

function to_json_file(filenames, dataset::Dataset; kwargs...)
    for (filename, runid) in zip(filenames, keys(dataset))
        to_json_file(filename, dataset, runid; kwargs...)
    end
end

function to_json_file(filename::String, dataset::Dataset; kwargs...)
    if occursin("{}", filename)
        filenames = [replace(filename, "{}" => runid) for runid in keys(dataset)]
        to_json_file(filenames, dataset; kwargs...)
    else
        length(dataset) == 1 || error("Multi-run datasets not implemented")
        runid = first(keys(dataset))
        to_json_file(filename, dataset, runid; kwargs...)
    end
end

function to_json_file(filename::String, dataset::Dataset, runid::RunID; kwargs...)
    run = dataset[runid]
    for attr in keys(dataset.attributes)
        if attr === :metadata
            global_metadata = dataset.attributes[:metadata]
            if !isempty(global_metadata)
                metadata = get!(run.attributes, :metadata, typeof(global_metadata)())
                for attr′ in keys(global_metadata)
                    if attr′ in keys(metadata)
                        @info "Global metadata attribute overriden" run=run.id attr=attr′
                    else
                        metadata[attr′] = global_metadata[attr′]
                    end
                end
            end
        elseif attr ∉ keys(run.attributes)
            run.attributes[attr] = dataset.attributes[attr]
        end
    end
    to_json_file(filename, run; kwargs...)
end

function to_json_file(filename::String, run::Run; makedirs::Bool=false)
    if makedirs
        dir = dirname(filename)
        if !isempty(dir) && !isdir(dir)
            mkpath(dir)
        end
    end
    open(filename, "w") do f
        write_json(f, run)
    end
end

function to_json_file(filename::String, object)
    open(filename, "w") do f
        write_json(f, object)
    end
end

write_json(stream, run::Run) = prettify(stream, JSON3.write(run); depth=3)
write_json(stream, obj) = JSON3.pretty(stream, JSON3.write(obj))

# metadata

function is_date_time(s)
    try
        date, time = split(s, '_')
        return length(date) == 8 && length(time) == 6 && all(isdigit, date) && all(isdigit, time)
    catch
        return false
    end
end

is_protocol(s) = count(==('#'), s) == 3
is_genotype_effector(s) = count(==('@'), s) == 1
is_tracker(s) = 1 < length(s) && s[1] == 't' && all(isdigit, s[2:end])

function sort_metadata(metadata)
    # should we include object metadata such as :camera?
    standardkeys = (:tracker, :genotype, :effector, :protocol, :date_time, :filename)
    md = OrderedDict{Symbol, String}(key => metadata[key]
                                     for key in standardkeys if key in keys(metadata))
    for key in keys(metadata)
        key in standardkeys || metadata[key] isa String && (md[key] = metadata[key])
    end
    return md
end

function extract_metadata_from_filepath(filepath; sort=true)
    if sort
        return sort_metadata(extract_metadata_from_filepath(filepath; sort=false))
    end
    metadata = Dict{Symbol, String}()
    parts = splitpath(filepath)
    # filename
    if !is_date_time(parts[end])
        filename = pop!(parts)
        metadata[:filename] = filename
        isempty(parts) && return metadata
    end
    # date_time
    date_time = pop!(parts)
    is_date_time(date_time) || return metadata
    metadata[:date_time] = date_time
    isempty(parts) && return metadata
    # protocol
    protocol = pop!(parts)
    is_protocol(protocol) || return metadata
    metadata[:protocol] = protocol
    isempty(parts) && return metadata
    # genotype and effector
    genotype_effector = pop!(parts)
    is_genotype_effector(genotype_effector) || return metadata
    metadata[:genotype], metadata[:effector] = split(genotype_effector, '@')
    isempty(parts) && return metadata
    # tracker
    tracker = pop!(parts)
    is_tracker(tracker) || return metadata
    metadata[:tracker] = tracker
    return metadata
end

# tags/labels

"""
    encodelabels(dataset; attrname=((:labels, :secondarylabels), :names), labels=nothing)
    encodelabels!(dataset; attrname=((:labels, :secondarylabels), :names), labels=nothing)

Integer-encode the labels found in dataset `dataset`.

Labels are expected to be found as record `attrname[1][1]` in the leaf `Track` objects.

All attribute names specified in `attrname` are used to look up for label names in the
object metadata instead. `attrname[1]` can be a single or multiple top attribute names, while
`attrname[2]` is used to address a nested attribute in the case the label metadata are a
dictionary instead of an array.
To pass multiple top attribute names and no nested attribute names, wrap them in a singleton:
`attrname=((:topattrname1, :topattrname2), )`

A unique label array can be specified as argument `labels`, to override the list of labels
found in the dataset.

See also [`decodelabels`](@ref).
"""
function encodelabels end

"""
    decodelabels(dataset, delete_top_attr=false; attrname=((:labels, :secondarylabels), :names), labels=nothing)
    decodelabels!(dataset, delete_top_attr=false; attrname=((:labels, :secondarylabels), :names), labels=nothing)

Decode integer-encoded labels found in dataset `dataset`.

If `delete_top_attr` is `true`, attribute `attrname[1]` or attributes in `attrname[1]` are
removed from the attributes.

See also [`encodelabels`](@ref).
"""
function decodelabels end

function uniquelabels(dataset::Dataset; recordname=:labels)
    labels = nothing
    for run in values(dataset)
        labels′= uniquelabels(run; recordname=recordname)
        labels = isnothing(labels) ? labels′ : unique([labels; labels′])
    end
    return labels
end

function uniquelabels(run::Run; recordname=:labels)
    labels = nothing
    for track in values(run)
        try
            labels′= track[recordname]
            isempty(labels′) && continue
            anylabel = labels′[1]
            (anylabel isa Integer || anylabel isa Vector{<:Integer}) && return
            labels′= uniquelabels(labels′)
            labels = isnothing(labels) ? labels′ : unique([labels; labels′])
        catch
        end
    end
    return labels
end

function uniquelabels(labels::Vector)
    labeltype = String
    labelset = labeltype[]
    for label in labels
        if label isa labeltype
            label in labelset || push!(labelset, label)
        else
            @assert label isa Vector{labeltype}
            labels′= label
            for label in labels′
                label in labelset || push!(labelset, label)
            end
        end
    end
    return labelset
end

"""
    const LABEL_ATTRIBUTE_NAMES = ((:labels, :secondarylabels), :names)

Default names of label-related attributes.
"""
const LABEL_ATTRIBUTE_NAMES = ((:labels, :secondarylabels), :names)

function getlabelrecordname(attrname)
    if !(attrname isa Symbol)
        # attrname == ((:labels, :secondarylabels), :names)
        attrname = attrname[1]
        if !(attrname isa Symbol)
            # attrname == (:labels, :secondarylabels)
            attrname = attrname[1]
        end
    end
    return attrname
end

getprimarylabels(dataset) = getprimarylabels(dataset.attributes)
function getprimarylabels(attributes::Attributes, attrname=LABEL_ATTRIBUTE_NAMES)
    # only labels from attributes
    subattr = nothing
    if !(attrname isa Symbol)
        # attrname == ((:labels, :secondarylabels), :names)
        if 1 < length(attrname)
            subattr = attrname[2]
        end
        attrname = attrname[1]
        if !(attrname isa Symbol)
            # attrname == (:labels, :secondarylabels)
            attrname = attrname[1]
        end
    end
    labels = nothing
    if haskey(attributes, attrname)
        labels = attributes[attrname]
        if labels isa AbstractDict
            labels = labels[subattr]
        end
        if labels isa Vector
            if !isempty(labels)
                labels = [labels...]
            end
        else
            labels = [labels]
        end
        @assert labels isa Vector{String} || labels isa Vector{Symbol}
    end
    return labels
end

getsecondarylabels(dataset) = getsecondarylabels(dataset.attributes)
function getsecondarylabels(attributes::Attributes, attrname=LABEL_ATTRIBUTE_NAMES)
    # only labels from attributes
    labels = nothing
    if !(attrname isa Symbol)
        # attrname == ((:labels, :secondarylabels), :names)
        subattr = nothing
        if 1 < length(attrname)
            subattr = attrname[2]
        end
        attrname = attrname[1]
        if !(attrname isa Symbol) && 1 < length(attrname)
            # attrname == (:labels, :secondarylabels)
            attrname = attrname[2]
            if haskey(attributes, attrname)
                labels = attributes[attrname]
                if labels isa AbstractDict
                    labels = labels[subattr]
                end
                if labels isa Vector
                    labels = [labels...]
                else
                    labels = [labels]
                end
                @assert labels isa Vector{String} || labels isa Vector{Symbol}
            end
        end
    end
    return labels
end

function getlabels(attributes::Attributes, attrname)
    # only labels from attributes
    primarylabels = getprimarylabels(attributes, attrname)
    secondarylabels = getsecondarylabels(attributes, attrname)
    if isnothing(secondarylabels)
        primarylabels
    elseif !isnothing(primarylabels)
        vcat(primarylabels, secondarylabels)
    end
end

# in practice, with default store==true, `getlabels` can mutate its first argument;
# `getlabels!` is an alias that is explicit about this fact
getlabels!(dataset; attrname=LABEL_ATTRIBUTE_NAMES) = getlabels(dataset; attrname=attrname)

function getlabels(dataset; labels=nothing, attrname=LABEL_ATTRIBUTE_NAMES, store::Bool=true)
    attributes = dataset.attributes
    topattr = recordname = getlabelrecordname(attrname)
    secondarylabels = getsecondarylabels(attributes, attrname)
    if isnothing(labels)
        labels = getprimarylabels(attributes, attrname)
        if isnothing(labels)
            labels = uniquelabels(dataset; recordname=recordname)
            if !isnothing(secondarylabels)
                filter!(label -> label ∉ secondarylabels, labels)
            end
        end
    end
    if store && !haskey(attributes, topattr) && !isnothing(labels)
        attributes[topattr] = labels
    end
    if !isnothing(secondarylabels)
        labels = vcat(labels, secondarylabels)
    end
    return labels, recordname
end

function encodelabels(label::T, labelset::Vector{T}) where {T}
    ix = findfirst(==(label), labelset)
    isnothing(ix) && error("Unexpected label")
    ix
end
function encodelabels(labels::Vector{T}, labelset::Vector{T}) where {T}
    if isempty(labels)
        Int[]
    else
        [encodelabels(label, labelset) for label in labels]
    end
end

function encodelabels(labelseries::Vector, labelset::Vector)
    encodedlabels = Union{Int, Vector{Int}}[]
    for label in labelseries
        push!(encodedlabels, encodelabels(label, labelset))
    end
    return encodedlabels
end

function encodelabels(dataset; labels=nothing, attrname=LABEL_ATTRIBUTE_NAMES)
    encodelabels!(deepcopy(dataset); labels=labels, attrname=attrname)
end

function encodelabels!(dataset::Dataset; labels=nothing, attrname=LABEL_ATTRIBUTE_NAMES)
    labels, recordname = getlabels(dataset; labels=labels, attrname=attrname)
    if !isnothing(labels)
        for run in values(dataset)
            encodelabels!(run; labels=labels, attrname=recordname, storelabels=false)
        end
    end
    return dataset
end

function encodelabels!(run::Run; labels=nothing, attrname=LABEL_ATTRIBUTE_NAMES,
        storelabels::Bool=true)
    labels, recordname = getlabels(run; labels=labels, attrname=attrname, store=storelabels)
    if !isnothing(labels)
        for track in values(run)
            try
                track[recordname] = encodelabels(track[recordname], labels)
            catch e
                @warn "Encoding labels failed" run=run.id track=track.id error=e
            end
        end
    end
    return run
end

decodelabels(encodedlabel::Integer, labelset::Vector) = labelset[encodedlabel]
decodelabels(encodedlabels::Vector{<:Integer}, labelset::Vector{T}) where {T} = T[decodelabels(label, labelset) for label in encodedlabels]

function decodelabels(encodedlabels::Vector, labelset::Vector{T}) where {T}
    labels = Union{T, Vector{T}}[]
    for label in encodedlabels
        if label isa Vector && isempty(label)
            # if empty, eltype(label) may not be Int and dispatch fails
            push!(labels, T[])
        else
            push!(labels, decodelabels(label, labelset))
        end
    end
    return labels
end

function decodelabels(dataset, delete_top_attr::Bool=false;
        labels=nothing, attrname=LABEL_ATTRIBUTE_NAMES)
    decodelabels!(deepcopy(dataset), delete_top_attr; attrname=attrname, labels=labels)
end

function decodelabels!(dataset, delete_top_attr::Bool=false;
        labels=nothing, attrname=LABEL_ATTRIBUTE_NAMES)
    attributes = dataset.attributes
    if isnothing(labels)
        labels = getlabels(attributes, attrname)
    end
    # the record name is also the primary top attribute name
    topattr = getlabelrecordname(attrname)
    decodelabels!(dataset, labels, isnothing(labels) ? attrname : topattr)
    if delete_top_attr && haskey(attributes, topattr)
        delete!(attributes, topattr)
    end
    return dataset
end

function decodelabels!(dataset::Dataset, labels, attrname)
    for run in values(dataset)
        decodelabels!(run; labels=labels, attrname=attrname)
    end
    return dataset
end

function decodelabels!(run::Run, labels, attrname)
    recordname = getlabelrecordname(attrname)
    if labels_encoded(run, recordname)
        if isempty(labels)
            labels = getlabels(run.attributes, attrname)
        end
        for track in values(run)
            try
                track[recordname] = decodelabels(track[recordname], labels)
            catch e
                @warn "Decoding labels failed" run=run.id track=track.id error=e
            end
        end
    end
    return run
end

function labels_encoded(run::Run, recordname::Symbol=:labels)
    for track in values(run)
        try
            labels = track[recordname]
            k = findfirst(!isempty, labels)
            isnothing(k) && continue
            anylabel = labels[k]
            anylabel isa Integer || anylabel isa Vector{<:Integer} || return false
        catch
            continue
        end
    end
    return true
end

"""
    segment(track_run_or_dataset, t0, t1)
    segment(outputfile, inputfile, t0, t1)

Crop the timeseries to time segment `[t0, t1]`.

`inputfile` is a file path; `outputfile` is a filename. The output file is written in the
same directory as the input file.
"""
function segment(track::Track, t0::Real, t1::Real)
    I = @. t0 <= track.timestamps <= t1
    timestamps = track.timestamps[I]
    states = copy(track.states)
    for (record, timeseries) in pairs(track.states)
        states[record] = timeseries[I]
    end
    return Track(track.id, track.attributes, timestamps, states)
end

function segment(run::Run, t0, t1)
    tracks = empty(run.tracks)
    for (trackid, track) in pairs(run.tracks)
        track = segment(track, t0, t1)
        isempty(track) || (tracks[trackid] = track)
    end
    return Run(run.id, run.attributes, tracks)
end

function segment(dataset::Dataset, t0, t1)
    runs = empty(dataset.runs)
    for (runid, run) in pairs(dataset.runs)
        run = segment(run, t0, t1)
        isempty(run) || (runs[runid] = run)
    end
    return Dataset(dataset.attributes, runs)
end

function segment(::Type{T}, outfile::String, infile::String, t0, t1) where {T}
    basename(outfile) == outfile || throw("Paths are not allowed for output file")
    outfile = joinpath(dirname(infile), outfile)
    run_or_dataset = from_json_file(T, infile)
    run_or_dataset = segment(run_or_dataset, t0, t1)
    to_json_file(outfile, run_or_dataset)
end

segment(outfile::String, infile::String, t0, t1) = segment(Run, outfile, infile, t0, t1)

"""
    expand!(run, run′, defaultstate)

Expand a run so that it features the same tracks and time steps as a second run, using a
default state for the missing time steps.

Beware labels are not processed in a specific way. In particular, the `:labels` attribute is
not updated to reflect the possibly newly introduced label from the default state.
"""
function expand!(run::Run, run′::Run, defaultstate)
    run.id == run′.id || error("Run IDs do not match")
    newtracks = OrderedDict{TrackID, Track}()
    for (trackid, track′) in pairs(run′)
        timestamps′= track′.timestamps
        if trackid ∈ keys(run)
            track = run[trackid]
            timestamps = track.timestamps
            if timestamps == timestamps′
                newtracks[trackid] = track
            else
                expanded_timestamps = collect(sort(union(timestamps, timestamps′)))
                newtracks[trackid] = Track(trackid, expanded_timestamps,
                                           Dict(feature=>[(t ∈ timestamps ? track[feature, t] : value)
                                                          for t in expanded_timestamps]
                                                for (feature, value) in pairs(defaultstate)))
            end
        else
            newtracks[trackid] = Track(trackid, timestamps′,
                                       Dict(feature=>fill(value, size(timestamps′))
                                            for (feature, value) in defaultstate))
        end
    end
    empty!(run.tracks)
    for (trackid, track) in pairs(newtracks)
        run.tracks[trackid] = track
    end
    return run
end

"""
    mergelabels!(run, run′)
    mergelabels!(predicate, run, run′)

Overwrite labels/tags in `run` with those defined in `run′`.
Empty labels are considered undefined.

Optionally, insertions are ruled by a predicate function that takes the label(s) from `run′`
as input and returns true to allow insertion or false otherwise.

For example:

```@example
mergelabels!(automatically_labeled, manually_labeled) do labels
    labels isa Vector && "edited" ∈ labels
end
```
"""
function mergelabels!(predicate, run::Run, run′::Run; attrname=LABEL_ATTRIBUTE_NAMES)
    run.id == run′.id || error("Run IDs do not match")
    # prepare label specifications
    decodelabels!(run)
    decodelabels!(run′)
    getlabels!(run; attrname=attrname)
    getlabels!(run′; attrname=attrname)
    # extend `run`'s primary label specifications
    topattr = recordname = getlabelrecordname(attrname)
    labelspec′ = run′.attributes[topattr]
    if haskey(run.attributes, topattr)
        labelspec = run.attributes[topattr]
        if labelspec != labelspec′
            labels = getprimarylabels(run.attributes, attrname)
            labels′= getprimarylabels(run′.attributes, attrname)
            if labels == labels′
                if !(labelspec isa AbstractDict) && (labelspec′ isa AbstractDict)
                    run.attributes[topattr] = labelspec = labelspec′
                end
            else
                for label in labels′
                    if label ∉ labels
                        if labelspec isa AbstractDict
                            # data loss; we cannot infer the other specs
                            run.attributes[topattr] = labelspec = labels
                        end
                        push!(labelspec, label)
                    end
                end
            end
        end
    else
        run.attributes[topattr] = labelspec = labelspec′
    end
    # extend `run`'s secondary label specifications
    secondarylabels = getsecondarylabels(run.attributes, attrname)
    secondarylabels′= getsecondarylabels(run′.attributes, attrname)
    if !isnothing(secondarylabels′) && secondarylabels != secondarylabels′
        secondarylabels = isnothing(secondarylabels) ? secondarylabels′ : vcat(secondarylabels, secondarylabels′)
        attrname′= attrname[1][2]
        run.attributes[attrname′] = secondarylabels
    end
    # check there is no overlap
    if !isnothing(secondarylabels)
        primarylabels = getprimarylabels(run.attributes, attrname)
        common = Set(primarylabels) ∩ Set(secondarylabels)
        isempty(common) || error("Some labels are both primary and secondary: $(join(common, ", "))")
    end
    # overwrite the individual data points
    recordnames = collect(keys(first(values(run)).states))
    recordname = topattr
    for (trackid, track′) in pairs(run′)
        if trackid ∉ keys(run)
            if collect(keys(track′.states)) == recordnames
                run[trackid] = track′
                continue
            else
                error("`mergelabels!` expects to find all the tracks of the second run in the first one")
            end
        end
        track = run[trackid]
        labels = track[recordname]
        labels′= track′[recordname]
        length(labels) == length(labels′) || error("`mergelabels!` expects the corresponding tracks to be defined on the same time support")
        if eltype(labels) === String
            track[recordname] = labels = convert(Vector{Union{String, Vector{String}}}, labels)
        end
        for (i, label) in enumerate(labels′)
            if predicate(label)
                labels[i] = label
            end
        end
    end
    return run
end

mergelabels!(run::Run, run′::Run; kwargs...) = mergelabels!(!isempty, run, run′; kwargs...)

"""
    setdefaultlabel!(run, fullrun, defaultlabel)

Expand over the tracks and time steps defined in another run (see [`Datasets.expand!`](@ref))
and assign a default label/tag to the unlabelled/untagged data.
"""
function setdefaultlabel!(run::Run, fullrun::Run, defaultlabel; attrname=(:labels, :names))
    run.id == fullrun.id || error("Run IDs do not match")
    decodelabels!(run)
    definedlabels, recordname = getlabels(run; attrname=attrname)
    attrname = recordname

    if fullrun !== run
        Datasets.expand!(run, fullrun, Dict(recordname=>defaultlabel))

        if defaultlabel ∉ definedlabels
            # data loss if attribute is a Dict; cannot infer additional specs
            run.attributes[attrname] = push!(definedlabels, defaultlabel)
        end
    end

    for track in values(run.tracks)
        labels = track[recordname]
        labels[isempty.(labels)] .= defaultlabel
    end
    return run
end

# for keys and labels
coerce(::Type, _) = throw("not implemented error")
coerce(::Type{T}, a::Union{T, Vector{T}}) where {T} = a
coerce(::Type{Symbol}, a::Union{String, SubString{String}}) = Symbol(a)
coerce(::Type{Symbol}, a::Union{Vector{String}, Vector{SubString{String}}}) = Symbol.(a)
coerce(::Type{String}, a::Union{Symbol, SubString{String}}) = string(a)
coerce(::Type{String}, a::Union{Vector{Symbol}, Vector{SubString{String}}}) = string.(a)
coerce(ref::AbstractVector, a) = coerce(eltype(ref), a)
coerce(ref, a) = coerce(typeof(ref), a)

"""
    appendlabel!(run, label; recordname=:labels, attrname=(:secondarylabels, :names), ignore=String[], ifempty=true)

Append a label to existing labels, at every track steps.
Per default, the label to append is considered secondary, meaning it is represented appart in
the metadata. Secondary labels are recorded as such in metadata, so that they can be
distinguished from primary labels.

Argument `ignore` lists uncompatible labels that prevent the label to be appended.

Argument `ifempty`, if set to false, additionally allows preventing the specified label to be
appended in cases the label is explicitly undefined with an empty list of labels.
"""
function appendlabel!(run::Run, label::Union{Symbol, String};
        recordname=:labels, attrname=(:secondarylabels, :names), ignore=String[],
        ifempty=true)
    decodelabels!(run)
    topattr = attrname isa Symbol ? attrname : attrname[1]
    labels = if topattr== recordname
        getlabels(run; attrname=attrname)[1]
    elseif haskey(run.attributes, topattr)
        run.attributes[topattr]
    else
        run.attributes[topattr] = [label]
    end
    if labels isa AbstractDict
        @assert !isa(attrname, Symbol) "Argument type error"
        labels′= labels
        labels = labels[attrname[2]]
        if 1 < length(labels′)
            label = coerce(labels, label)
            label ∈ labels || error("Cannot append label to multi-attribute labels")
        end
    end
    label = coerce(labels, label)
    if label ∉ labels
        run.attributes[topattr] = push!(labels, label)
    end
    #
    ignore = coerce(labels, ignore)
    ignore = push!(Set(ignore), label)
    for track in values(run.tracks)
        labels = track[recordname]
        for (i, existinglabel) in enumerate(labels)
            if isa(existinglabel, Vector)
                if isempty(existinglabel)
                    if ifempty
                        labels[i] = label # not a vector
                    end
                elseif isempty(existinglabel ∩ ignore)
                    push!(existinglabel, label)
                end
            else
                if existinglabel ∉ ignore
                    try
                        labels[i] = [existinglabel, label]
                    catch
                        T = eltype(labels)
                        labels = track[recordname] = convert(Vector{Union{T, Vector{T}}}, labels)
                        labels[i] = [existinglabel, label]
                    end
                end
            end
        end
    end
    return run
end

# data dependencies

# handle JSON-deserialized data (convert keys and convert to array)
object_or_array_of_objects(arr::Vector{<:AbstractDict{Symbol}}) = arr
function object_or_array_of_objects(obj)
    arr = obj isa Vector ? obj : [obj]
    return [Dict(Symbol(key)=>val for (key, val) in pairs(obj)) for obj in arr]
end

checksum(filename) = bytes2hex(open(sha1, filename))

as_dependency(datafile) = Dict(:filename=>basename(datafile), :sha1=>checksum(datafile))

function pushdependency!(dataset::Dataset, datafile)
    @assert length(dataset) == 1
    run = first(values(dataset))
    pushdependency!(run, datafile)
    return dataset
end

function pushdependency!(run::Run, datafile::String)
    if haskey(run.attributes, :dependencies)
        deps = object_or_array_of_objects(run.attributes[:dependencies])
        dep = as_dependency(datafile)
        if (deps isa Vector && dep in deps) || dep == deps
            @debug "Dependency already registered" dependency=dep
        else
            push!(deps, dep)
        end
        run.attributes[:dependencies] = deps
    else
        run.attributes[:dependencies] = as_dependency(datafile)
    end
    return run
end

function getdependencies(dataset::Dataset, args...)
    @assert length(dataset) == 1
    run = first(values(dataset))
    getdependencies(run, args...)
end

function getdependencies(run::Run, filepath=nothing)
    deps = String[]
    for dep in object_or_array_of_objects(run.attributes[:dependencies])
        datafile = dep[:filename]
        if !isnothing(filepath)
            dirpath = isdir(filepath) ? filepath : dirname(filepath)
            datafile = joinpath(dirpath, datafile)
        end
        checksum(datafile) == dep[:sha1] || error("checksums differ for file: $(datafile)")
        push!(deps, datafile)
    end
    return deps
end

"""
    shareddependencies(run, run′; extend=false)

Compare two runs/assays' dependencies.

Returns `true` if the dependencies fully match, or a run's dependencies are all included in
the other run's dependencies.
In the latter case, a warning message is issued.
Argument `extend` also applies to this particular case, and ensures the most complete set of
dependencies is replicated in all runs.
"""
function shareddependencies(run, run′; extend=false)
    deps, deps2 = try
        run.attributes[:dependencies], run′.attributes[:dependencies]
    catch
        return false
    end
    filename(d) = d[:filename]
    deps = deps isa Vector ? sort(coerce_dict.(deps); by=filename) : [deps]
    deps2 = deps2 isa Vector ? sort(coerce_dict.(deps2); by=filename) : [deps2]
    if deps != deps2
        # here we allow cases where a file's dependencies are only a subset of the other
        # file's dependencies. This is known to happen with Choreography files
        if issubset(deps, deps2) || issubset(deps2, deps)
            @warn "Data dependencies do not fully match" dependencies1=deps dependencies2=deps2
            if extend
                if issubset(deps, deps2)
                    run.attributes[:dependencies] = deps2
                else
                    run′.attributes[:dependencies] = deps
                end
            end
        else
            @error "Data dependencies do not match" dependencies1=deps dependencies2=deps2
            return false
        end
    end
    return true
end

# LarvaBase extensions

LarvaBase.times(track::Track) = track.timestamps
LarvaBase.times(run::Run) = unique(sort(collect(Iterators.flatten(LarvaBase.times(track) for track in values(run.tracks)))))

end
