"""
Larva identification number as found in *.outline*, *.spine* and *trx.mat* files.
"""
const LarvaID = UInt16

"""
Timestamp (alias for `Float64`).
"""
const Time = Float64

"""
    TimeSeries{T}

Time series, or series of timestamp-`T` pairs.
`T` typically is a geometry (larva shape).
"""
const TimeSeries{T} = Vector{Tuple{Time, T}}

"""
    Larvae{T}

Dictionnary of larva tracks with larva IDs as keys.
`T` typically is a geometry (larva shape).
"""
const Larvae{T} = OrderedDict{LarvaID, TimeSeries{T}}

"""
    Runs{T}

Dictionnary of runs with date_time as keys.
`T` typically is a geometry (larva shape).
"""
const Runs{T} = OrderedDict{String, Larvae{T}}

const Collection{T} = Union{TimeSeries{T}, Larvae{T}, Runs{T}}

"""
    const Records{N} = NTuple{N, Pair{Symbol, Data} where Data}

Specification for data records to be passed as first argument to functions such as
`read_chore_files` and `read_trxmat`.

Example:
```julia
(:spine=>Spine, :outline=>Outline)
```

See also [`derivedtype`](@ref).
"""
const Records{N} = NTuple{N, Pair{Symbol}}

"""
    derivedtype(T)

Data record type of terminal elements associated with record specifications `T`.

Examples:
```julia
derivedtype(Outline) == Outline
derivedtype((:spine=>Spine, :outline=>Outline)) == NamedTuple{(:spine, :outline), Tuple{Spine, Outline}}
```

See also [`Records`](@ref).
"""
function derivedtype end

"""
    map′(f, collection)

Functor on terminal elements `T` of collections such as `Runs{T}`, `Larvae{T}` and
`TimeSeries{T}`.
Returns a same collection with elements of type `map′(::T)`.
Time stability is enforced.

See also [`zip′`](@ref).
"""
function map′ end

"""
    zip′(::Type{T}, ::Collection{T1}, ..., ::Collection{Tn}))

Multi-argument functor on terminal elements of type `T1`, ..., `Tn`.
Corresponding terminal elements are combined using `T(::T1, ..., ::Tn)`.

Return type is `Collection{T}`.
Type stability is enforced.

See also [`map′`](@ref).
"""
function zip′ end

"""
    filterlarvae(predicate, collection)

Copy a collection excluding the larvae for which the boolean function `predicate` returns
`false`.
`predicate` takes two input arguments:
the larva ID and a timeseries of states (or track).

Empty subcollections are excluded as well. Only the top collection can be returned empty.
"""
function filterlarvae end

## implementation

derivedtype(T) = typeof(T)
derivedtype(T::Union{DataType, UnionAll}) = T
function derivedtype(specs::NTuple{N, Pair{Symbol}}) where {N}
    attrs, types = zip(specs...)
    return NamedTuple{tuple(attrs...), Tuple{(derivedtype(t) for t in types)...}}
end
function derivedtype(specs::AbstractDict{Symbol})
    return NamedTuple{tuple(keys(specs)...), Tuple{(derivedtype.(values(specs)))...}}
end

function return_eltype(f, collection::Collection)
    elem = first(eachstate(collection))
    return typeof(f(elem))
end

map′(f, collection::Collection) = map′(f, return_eltype(f, collection), collection)

function map′(f, T::DataType, sample::Runs)
    sample′ = Runs{T}()
    for (run, larvae) in pairs(sample)
        sample′[run] = map′(f, T, larvae)
    end
    return sample′
end

function map′(f, T::DataType, larvae::Larvae)
    larvae′ = Larvae{T}()
    for (id, track) in pairs(larvae)
        larvae′[id] = map′(f, T, track)
    end
    return larvae′
end

function map′(f, T::DataType, track::TimeSeries)
    n = length(track)
    track′ = TimeSeries{T}(undef, n)
    for i in 1:n
        t, state = track[i]
        track′[i] = (t, f(state))
    end
    return track′
end

function zip′(::Type{T}, args::NTuple{N, Runs{T′} where T′}) where {T<:NamedTuple, N}
    @assert !isempty(args)
    arg = args[1]
    m = length(arg)
    all(==(m), length.(args)) || throw(ArgumentError("runs do not match"))
    zipped = Runs{T}()
    for run in keys(arg)
        zipped[run] = zip′(T, tuple((arg′[run] for arg′ in args)...))
    end
    return zipped
end

function zip′(::Type{T}, args::NTuple{N, Larvae{T′} where T′}) where {T<:NamedTuple, N}
    @assert !isempty(args)
    arg = args[1]
    n = length(arg)
    all(==(n), length.(args)) || throw(ArgumentError("ids do not match"))
    zipped = Larvae{T}()
    for id in keys(arg)
        zipped[id] = zip′(T, tuple((arg′[id] for arg′ in args)...))
    end
    return zipped
end

function zip′(::Type{T}, args::NTuple{N, TimeSeries{T′} where T′}) where {T<:NamedTuple, N}
    @assert !isempty(args)
    arg = args[1]
    n = length(arg)
    all(==(n), length.(args)) || throw(ArgumentError("timestamps do not match"))
    zipped = TimeSeries{T}(undef, n)
    for i in 1:n
        t, args′ = zip((arg′[i] for arg′ in args)...)
        t′ = t[1]
        all(==(t′), t) || throw(ArgumentError("timestamps do not match"))
        zipped[i] = (t′, T(tuple(args′...)))
    end
    return zipped
end

zip′(specs::Records, read::Function, files...) = zip′(derivedtype(specs), tuple((read(spec, files...) for (_, spec) in specs)...))

function filterlarvae(predicate, data::AbstractDict)
    data′ = typeof(data)()
    for (key, subset) in pairs(data)
        subset′ = filterlarvae(predicate, subset)
        if !isempty(subset′)
            data′[key] = subset′
        end
    end
    return data′
end

function filterlarvae(predicate, larvae::Larvae{T}) where {T}
    larvae′ = Larvae{T}()
    for (id, track) in pairs(larvae)
        if predicate(id, track)
            larvae′[id] = track
        end
    end
    return larvae′
end

"""
    abstract type RecordSelector end
    abstract type RecordAspect <: RecordSelector end
    struct HasRecord  <: RecordSelector ... end
    struct HasSpine   <: RecordAspect   ... end
    struct HasOutline <: RecordAspect   ... end

Aspect types, whose main purpose is to avoid type piracy.
"""
abstract type RecordSelector end
abstract type RecordAspect <: RecordSelector end

struct HasRecord <: RecordSelector
    name::Symbol
end

struct HasOutline <: RecordAspect
    name::Symbol
    HasOutline(name=:outline) = new(name)
end

struct HasSpine <: RecordAspect
    name::Symbol
    HasSpine(name=:spine) = new(name)
end

function getrecord(snapshot::NamedTuple, record::RecordSelector)
    haskey(snapshot, record.name) || throw(KeyError("no such record: \"$(record.name)\""))
    get(snapshot, record.name, undef)
end
getrecord(snapshot::NamedTuple, R::Type{<:RecordAspect}) = getrecord(snapshot, R())
