"""
    tmin(timeseries)
    tmax(timeseries)

Minimum and maximum timestamp in a time series.

See also [`bounds`](@ref).
"""
function tmin end
function tmax end

"""
    xmin(geometry)
    xmax(geometry)
    ymin(geometry)
    ymax(geometry)

Minimum or maximum x or y coordinate.

See also [`bounds`](@ref).
"""
function xmin end
function xmax end
function ymin end
function ymax end

"""
    bounds(geometries)

Bounding box in time and space.
Returns `(tmin, xmin, ymin)` and `(tmax, xmax, ymax)` combined into a couple.

See also [`tmin`](@ref), `tmax`, [`xmin`](@ref), `xmax`, `ymin`, `ymax`.
"""
function bounds end

"""
    Path(vec)

A wrapper for points serialized into a vector.
For example, a `Path{2}` wraps `[x1, y1, x2, y2, ..., xN, yN]`.

This wrapper is used for datatype conversion when reading spines and outlines from ascii
files.

It can also be used as internal point data for `Polygon` types.
"""
struct Path{Dim,F,V<:AbstractVector{F}} <: AbstractVector{Point{Dim,F}}
    v::V

    function Path{Dim,F,V}(v::V) where {Dim,F,V<:AbstractVector{F}}
        isempty(v)          && throw(ArgumentError("path is empty"))
        0 < length(v) % Dim && throw(DimensionMismatch("the number of coordinates is not a
                                                       multiple of the number of dimensions"))
        new{Dim,F,V}(v)
    end
    Path{Dim,F}(v::V) where {Dim,F,V<:AbstractVector{F}} = Path{Dim,F,V}(v)
    Path{Dim}(v::AbstractVector) where {Dim} = Path{Dim, eltype(v)}(v)
end

"""
    getx(geometry)
    gety(geometry)
    getz(geometry)

x/y/z coordinates of the vertices of a geometry of collection of geometries.
Vertices are taken from internal representations and include duplicates if any.

Inner boundaries are omitted, if any.
"""
function getx end
function gety end
function getz end

"""
    points(path)

Conversion of a path to a vector of points.
Also available as `convert`.

See also [`Path`](@ref).
"""
function points end

"""
    PointSeries(x, y)

Datatype for 2D paths and shapes.
Simple alternative to `Chain`- and `PolyArea`-based datatypes.

See also [`Outline`](@ref) and [`Spine`](@ref).
"""
struct PointSeries{F} <: AbstractVector{Point{2,F}}
    x::Vector{F}
    y::Vector{F}

    function PointSeries{F}(x, y) where F
        isempty(x) && throw(ArgumentError("series is empty"))
        length(x) == length(y) || throw(DimensionMismatch("numbers of x coordinates and y coordinates do not match"))
        new{F}(x, y)
    end
    PointSeries{F}(p::Path{2}) where F = PointSeries{F}(getx(p), gety(p))
end

abstract type AbstractSpine end
abstract type AbstractOutline end

"""
    outline(larvashape)
    outline(PointType, larvashape)

Getter for outlines.

When the desired point type is given, the outline is returned as an
`AbstractVector{PointType}`, ideally a `Vector{PointType}` (see also [`vertices′`](@ref)).
Otherwise, the representation is left unchanged.
"""
function outline end

"""
    spine(larvashape)
    spine(PointType, larvashape)

Getter for spines.

When the desired point type is given, the spine is returned as an
`AbstractVector{PointType}`, ideally a `Vector{PointType}` (see also [`vertices′`](@ref)).
Otherwise, the representation is left unchanged.
"""
function spine end

"""
    const SpineGeometry{F,V} = Meshes.Chain{2,F,V}

Default `SpineGeometry` is `SpineGeometry{Float64,Vector{Meshes.Point2}}`.
"""
const SpineGeometry{F,V} = Chain{2,F,V}

"""
    const OutlineGeometry{F,V} = Meshes.PolyArea{2,F,Meshes.Chain{2,F,V}}

Default `OutlineGeometry` is `OutlineGeometry{Float64,Vector{Meshes.Point2}}`.
"""
const OutlineGeometry{F,V} = PolyArea{2,F,Chain{2,F,V}}

"""
Default type for individual outlines,
as [Meshes.jl](https://github.com/JuliaGeometry/Meshes.jl) `PolyArea`s.
Coordinates are `Float64`-encoded.

See also [`RawOutline`](@ref Main.PlanarLarvae.Chore.RawOutline) and
[`Outlinef`](@ref Main.PlanarLarvae.Chore.Outlinef).
"""
const Outline = OutlineGeometry{Float64,Vector{Point2}}

"""
Default type for individual spines,
as [Meshes.jl](https://github.com/JuliaGeometry/Meshes.jl) `Chain`s.
Coordinates are `Float64`-encoded.

See also [`RawSpine`](@ref Main.PlanarLarvae.Chore.RawSpine) and
[`Spinef`](@ref Main.PlanarLarvae.Chore.Spinef).
"""
const Spine = SpineGeometry{Float64,Vector{Point2}}

"""
    vertices′(V, geometry)

Vertices as an `AbstractVector{V}`, or preferably a `Vector{V}`, where `V` is the desired
vertex type.
"""
function vertices′ end

# deprecated
"""
Deprecated. Use `(:spine=>Spine, :outline=>Outline)` instead.

See also [`Records`](@ref).
"""
struct SpineOutline
    spine::Spine
    outline::Outline
end

"""
[Meshes.jl](https://github.com/JuliaGeometry/Meshes.jl) `Geometry` representation of a spine
or outline.

`Spine` and `Outline` may become wrappers around their respective current types, instead of
being type aliases.
This function will unwrap, and should be used from now on, wherever a `Geometry` is
expected.
"""
function geometry end

"""
    centroid(state)
    centroid(geometrylike)

Central point of a larva's body, chosen as the midpoint along the spine if a spine is
available, or as the geometrical center of the outline.

See also `Meshes.jl` `centroid` function.
"""
function centroid end

"""
    larvatrack(timeseries)

Trajectory of a larva, as a series of 2D points.
"""
function larvatrack end

############## implementation ##############

# fallback implementations
getx(v::AbstractVector{<:Point}) = [coordinates(p)[1] for p in v]
gety(v::AbstractVector{<:Point}) = [coordinates(p)[2] for p in v]
getz(v::AbstractVector{<:Point}) = [coordinates(p)[3] for p in v]

## Path

Path(v::AbstractVector) = Path{2}(v)

getx(p::Path{1}) = p.v
getx(p::Path{2}) = p.v[1:2:end]
getx(p::Path{3}) = p.v[1:3:end]
gety(p::Path{2}) = p.v[2:2:end]
gety(p::Path{3}) = p.v[2:3:end]
getz(p::Path{3}) = p.v[3:3:end]

points(p::Path{1,F}) where {F} = Point{1,F}.(getx(p))
points(p::Path{2,F}) where {F} = Point{2,F}.(zip(getx(p), gety(p)))
points(p::Path{3,F}) where {F} = Point{3,F}.(zip(getx(p), gety(p), getz(p)))

Base.length(p::Path{Dim}) where {Dim} = div(length(p.v), Dim)

Base.size(p::Path) = (length(p),)

Base.getindex(p::Path{Dim,F}, i::Int) where {Dim,F} = Point{Dim,F}(convert(SVector{Dim,F}, p.v[(i-1)*Dim+1:i*Dim]))

function Base.setindex!(p::Path{Dim,F}, v::Point{Dim,F}, i::Int) where {Dim,F}
    p.v[(i-1)*Dim+1:i*Dim] = coordinates(v)
    return p
end

Base.IndexStyle(::Type{<:Path}) = IndexLinear()

Base.iterate(p::Path) = iterate(points(p))

function Base.reverse(p::Path{Dim,F,V}) where {Dim,F,V<:AbstractVector{F}}
    v = similar(p.v)
    for i in 1:length(p)
        v[end-i*Dim+1:end-(i-1)*Dim] = p.v[(i-1)*Dim+1:i*Dim]
    end
    return Path{Dim,F,V}(v)
end

close_reverse(p) = close(reverse(p))

function close_reverse(p::Path{Dim,F,V}) where {Dim,F,V<:AbstractVector{F}}
    v = V(undef, length(p.v)+Dim)
    for i in 1:length(p)
        v[(i-1)*Dim+1:i*Dim] = p.v[end-i*Dim+1:end-(i-1)*Dim]
    end
    v[end-Dim+1:end] = p.v[end-Dim+1:end] # close
    return Path{Dim,F,V}(v)
end

Base.close(p::Path{Dim}) where {Dim} = typeof(p)([p.v; p.v[1:Dim]])

Meshes.isclosed(p::Path{Dim}) where {Dim} = p.v[1:Dim] == p.v[end-Dim+1:end]

Base.convert(::Type{V}, p::Path{Dim,F,V}) where {Dim,F,V<:Vector{F}} = p.v
Base.convert(T::Type{<:Vector{Point{Dim,F}}}, p::Path{Dim,F}) where {Dim,F} = convert(T, points(p))
Base.convert(T::Type{Path{Dim,F,V}}, p::Path{Dim}) where {Dim,F,V<:AbstractVector{F}} = T(convert(V, p.v))

function Meshes.boundingbox(p::Path{2,F}) where {F}
    xmin, xmax = extrema(getx(p))
    ymin, ymax = extrema(gety(p))
    Box(Point{2,F}(xmin, ymin), Point{2,F}(xmax, ymax))
end

Meshes.PolyArea(outer::P, inners=P[]; fix=true) where {Dim,P<:Path{Dim}} = PolyArea{Dim}(outer, inners; fix=fix)
Meshes.PolyArea{Dim}(outer::P, inners=P[]; fix=true) where {Dim,F,P<:Path{Dim,F}} = PolyArea{Dim,F}(outer, inners; fix=fix)
Meshes.PolyArea{Dim,F}(outer::P, inners=P[]; fix=true) where {Dim,F,P<:Path{Dim,F}} = PolyArea{Dim,F,Chain{Dim,F,P}}(outer, inners; fix=fix)
Meshes.PolyArea{Dim,F,C}(outer::P, inners=P[]; fix=true) where {Dim,F,P<:Path{Dim,F},C<:Chain{Dim,F,P}} = PolyArea{Dim,F,C}(C(close_reverse(outer)), (C ∘ close).(inners), fix)

Base.convert(T::Type{PolyArea{Dim,F,C}}, p::Path{Dim}) where {Dim,F,C<:Chain{Dim,F}} = T(convert(C, close_reverse(p)), C[], true)

Meshes.Chain(p::Path{Dim}) where {Dim} = Chain{Dim}(p)
Meshes.Chain{Dim}(p::Path{Dim,F}) where {Dim,F} = Chain{Dim,F}(p)
Meshes.Chain{Dim,F}(p::Path{Dim,F}) where {Dim,F} = Chain{Dim,F,typeof(p)}(p)

Base.convert(T::Type{Chain{Dim,F,V}}, p::Path{Dim}) where {Dim,F,V<:AbstractVector{Point{Dim,F}}} = T(convert(V, p))

"""
    vertices′(geometry)

Give the internal representation of vertices (vector of points).
If any, inner boundaries are omitted.
Unlike `vertices`, duplicate vertices are included.

This is a workaround for `vertices` applied to `Chain` and derivatives like `PolyArea`.
With these datatypes, `vertices` systematically removes the last vertex of closed chains.
"""
vertices′(p::PolyArea) = vertices′(p.outer)
vertices′(c::Chain) = c.vertices
vertices′(g) = vertices′(geometry(g))

getx(p::Polytope{K,1}) where {K} = getx(vertices′(p))
getx(p::Polytope{K,2}) where {K} = getx(vertices′(p))
getx(p::Polytope{K,3}) where {K} = getx(vertices′(p))
gety(p::Polytope{K,2}) where {K} = gety(vertices′(p))
gety(p::Polytope{K,3}) where {K} = gety(vertices′(p))
getz(p::Polytope{K,3}) where {K} = getz(vertices′(p))

## PointSeries

PointSeries(x::V, y::V) where {F,V<:AbstractVector{F}} = PointSeries{F}(x, y)

PointSeries(p::Path{2,F}) where {F} = PointSeries{F}(p)
PointSeries(v::AbstractVector{<:AbstractFloat}) = PointSeries(Path{2}(v))
#PointSeries(v::AbstractVector{<:Point{2}}) = PointSeries...

Base.convert(T::Type{<:PointSeries}, p::Path{2}) = T(p)
Base.convert(T::Type{<:PointSeries}, v::AbstractVector{<:AbstractFloat}) = T(v)
Base.convert(::Type{Chain{2,F}}, p::PointSeries{F}) where {F} = convert(Chain{2,F,Vector{Point{2,F}}}, p)
Base.convert(T::Type{<:Chain{2,F,V}}, p::PointSeries{F}) where {F,V<:AbstractVector{Point{2,F}}} = T(convert(V, p))
Base.convert(T::Type{PolyArea{2,F,C}}, p::PointSeries{F}) where {F,C<:Chain{2,F}} = T(convert(C, close_reverse(p)::PointSeries{F}), C[], true)

getx(o::PointSeries) = o.x
gety(o::PointSeries) = o.y

Base.length(o::PointSeries) = length(getx(o))
Base.size(o::PointSeries) = size(getx(o))

Base.getindex(o::PointSeries{F}, i::Int) where {F} = Point{2,F}(getindex(getx(o), i), getindex(gety(o), i))

function Base.setindex!(o::PointSeries, v, i::Int)
    o.x[i], o.y[i] = coordinates(v)
    return o
end

Base.IndexStyle(::Type{<:PointSeries}) = IndexLinear()

centroid(shape::PointSeries{F}) where {F} = Point{2,F}(sum(shape.x) / length(shape), sum(shape.y) / length(shape))

function Base.close(shape::PointSeries{F}) where {F}
    close′(v) = [v; first(v)]
    PointSeries{F}(close′(getx(shape)), close′(gety(shape)))
end

Base.reverse(shape::PointSeries{F}) where {F} = PointSeries{F}(reverse(getx(shape)), reverse(gety(shape)))

Meshes.boundingbox(shape::PointSeries{F}) where {F} = boundingbox(convert(Vector{Point{2,F}}, shape))

## Others

asvec(p::Point) = coordinates(p)

"""
    eachtimeseries(collection)
    eachtimeseries(f, collection)

Iterator over all timeseries in `collection`, optionally applying function `f` to each
timeseries.
"""
eachtimeseries(timeseries::TimeSeries) = [timeseries]
eachtimeseries(tracks::Larvae) = values(tracks)
eachtimeseries(f::Function, sample::Runs) = (f(track)
                                             for tracks in values(sample)
                                             for track in values(tracks)
                                            )
# fallback implementations; high risk of StackOverflowError
eachtimeseries(f::Function, collection) = Iterators.map(f, eachtimeseries(collection))
eachtimeseries(collection) = eachtimeseries(identity, collection)

"""
    times(collection)

Vector of sorted timestamps.
"""
times(track::TimeSeries) = [t for (t,_) in track]
function times(collection)
    sort′ = unique ∘ sort ∘ collect ∘ Iterators.flatten
    sort′(eachtimeseries(collection) do timeseries
              (t for (t,_) in timeseries)
          end)
end

"""
    eachstate(collection)
    eachstate(f, collection)

Iterator over all instantaneous states (static representations of a larva) in `collection`,
optionally applying function `f` to each state.
"""
eachstate(f::Function, timeseries::TimeSeries) = Iterators.map(timeseries) do (_, state)
    f(state)
end
eachstate(f::Function, tracks::Larvae) = (f(state)
                                          for track in values(tracks)
                                          for (_, state) in track
                                         )
eachstate(f::Function, sample::Runs) = (f(state)
                                        for tracks in values(sample)
                                        for track in values(tracks)
                                        for (_, state) in track
                                       )
# fallback implementations
eachstate(f::Function, collection) = Iterators.map(f, eachstate(collection))
eachstate(collection) = eachstate(identity, collection)

tmin(series::TimeSeries)::Time = series[1][1]
tmax(series::TimeSeries)::Time = series[end][1]

# fallback implementations
xmin(shape) = minimum(getx(shape))
xmax(shape) = maximum(getx(shape))
ymin(shape) = minimum(gety(shape))
ymax(shape) = maximum(gety(shape))

tmin(collection::Collection) = minimum(eachtimeseries(tmin, collection))
tmax(collection::Collection) = maximum(eachtimeseries(tmax, collection))
xmin(collection::Collection) = minimum(eachstate(xmin, collection))
xmax(collection::Collection) = maximum(eachstate(xmax, collection))
ymin(collection::Collection) = minimum(eachstate(ymin, collection))
ymax(collection::Collection) = maximum(eachstate(ymax, collection))

# fallback implementation
bounds(o) = (
             (tmin(o), xmin(o), ymin(o)),
             (tmax(o), xmax(o), ymax(o)),
            )

function bounds(data::Collection{<:Polytope})
    bb = boundingbox(collect(eachstate(data)))
    xmin, ymin = coordinates(minimum(bb))
    xmax, ymax = coordinates(maximum(bb))
    return (
            (tmin(data), xmin, ymin),
            (tmax(data), xmax, ymax),
           )
end

# TODO: report missing implementation of `boundingbox` for `CircularArray`
Meshes.boundingbox(p::PolyArea) = boundingbox(first(chains(p)))

## Type piracy?

# fallbacks
#Meshes.isclosed(v::AbstractVector{<:Point}) = first(v) == last(v)
Base.close(v::Vector{<:Number}) = [collect(v); first(v)]
Base.close(v::Vector{<:Point}) = [collect(v); first(v)]

## spine/outline

# `SpineOutline` is deprecated
SpineOutline(t::NamedTuple) = SpineOutline(t.spine, t.outline)

spine(so::SpineOutline) = so.spine
outline(so::SpineOutline) = so.outline

function outline(v::AbstractVector{<:Point}; reverse=true)
    PolyArea(Chain(close(reverse ? reverse(v) : v)))
end
function outline(v::Vector{Float64}; reverse=true)
    p = Path(v)
    p = reverse ? close_reverse(p) : close(p)
    PolyArea(Chain(convert(Vector{Point2}, p)))
end

spine(v::AbstractVector{<:Point}) = Chain(v)
spine(v::Vector{Float64}) = Chain(convert(Vector{Point2}, Path(v)))

spine(snapshot::NamedTuple; name=:spine) = getrecord(snapshot, HasSpine(name))
outline(snapshot::NamedTuple; name=:outline) = getrecord(snapshot, HasOutline(name))

geometry(s::SpineGeometry) = s
geometry(o::OutlineGeometry) = o

##

Meshes.boundingbox(record::RecordSelector, snapshot::NamedTuple) = boundingbox(geometry(getrecord(snapshot, record)))
Meshes.boundingbox(::Type{HasOutline}, snapshot::NamedTuple) = boundingbox(HasOutline(), snapshot)

function Meshes.boundingbox(record::RecordSelector, collection::Collection{<:NamedTuple})
    boundingbox(collect(eachstate(snapshot -> boundingbox(record, snapshot), collection)))
end
Meshes.boundingbox(record::Type{<:RecordAspect}, collection::Collection{<:NamedTuple}) = boundingbox(record(), collection)

function bounds(collection::Collection{<:NamedTuple}; shape=:outline)
    bb = boundingbox(HasRecord(shape), collection)
    xmin, ymin = coordinates(minimum(bb))
    xmax, ymax = coordinates(maximum(bb))
    return (
            (tmin(collection), xmin, ymin),
            (tmax(collection), xmax, ymax),
           )
end

midpoint(spine) = midpoint(geometry(spine)::SpineGeometry)
midpoint(spine::SpineGeometry) = midpoint(vertices(spine))

function midpoint(spine::Vector{<:Point})
    n = length(spine)
    if n % 2 == 0
        3 < n || throw(ErrorException("too few points in spine"))
        @debug "spine with even number of points ($n)"
        m = div(n, 2)
        return Point((asvec(spine[m]) + asvec(spine[m+1])) / 2)
    else
        2 < n || throw(ErrorException("too few points in spine"))
        return spine[div(n + 1, 2)]
    end
end

function midpoint(spine::Vector{<:AbstractVector{<:AbstractFloat}})
    n = length(spine)
    if n % 2 == 0
        3 < n || throw(ErrorException("too few points in spine"))
        @debug "spine with even number of points ($n)"
        m = div(n, 2)
        return (spine[m] + spine[m+1]) / 2
    else
        2 < n || throw(ErrorException("too few points in spine"))
        return spine[div(n + 1, 2)]
    end
end

# will be redundant once Spine <: AbstractSpine
centroid(spine::AbstractSpine) = midpoint(spine)
centroid(spine::Spine) = midpoint(spine)

# deprecated
centroid(so::SpineOutline) = midpoint(spine(so))

# fallback
centroid(g::Geometry) = Meshes.centroid(g)

centroid(record::HasSpine, snapshot::NamedTuple) = midpoint(getrecord(snapshot, record))
centroid(record::RecordSelector, snapshot::NamedTuple) = centroid(getrecord(snapshot, record))
centroid(R::Type{<:RecordAspect}, snapshot) = centroid(R(), snapshot)

function centroid(snapshot::NamedTuple)
    c = nothing
    try
        c = centroid(HasSpine, snapshot)
    catch
        c = centroid(HasOutline, snapshot)
    end
    return c
end

larvatrack(ts::Vector{Tuple{T,S}}) where {T,S} = [centroid(state) for (_, state) in ts]
larvatrack(ts::Vector) = centroid.(ts)

vertices′(::Type{P}, v::AbstractVector{<:P}) where {P} = v
vertices′(T, c::Chain) = vertices′(T, c.vertices)
vertices′(T, p::PolyArea) = vertices′(T, p.outer)
vertices′(T, g::Geometry) = vertices′(T, vertices′(Point, g))
vertices′(::Union{Type{SVector}, Type{SVector{Dim}}, Type{SVector{Dim,T}}},
          v::AbstractVector{Point{Dim,T}},
         ) where {Dim,T} = asvec.(v)
vertices′(::Union{Type{Vector}, Type{Vector{T}}},
          v::AbstractVector{Point{Dim,T}},
         ) where {Dim,T} = (collect ∘ asvec).(v)

outline(::Type{T}, o::OutlineGeometry) where {T} = vertices′(T, o)
spine(::Type{T}, s::SpineGeometry) where {T} = vertices′(T, s)
outline(::Type{T}, p::Path) where {T} = convert(Vector{T}, p)
spine(::Type{T}, p::Path) where {T} = convert(Vector{T}, p)
function outline(T, o)
    o′ = outline(o)
    if o′ isa typeof(o)
        @error "fix point evaluation for outline($T, ::$(typeof(o)))"
        throw(MethodError(outline, (T, o)))
    end
    return outline(T, o′)
end
function spine(T, s)
    s′ = spine(s)
    if s′ isa typeof(s)
        @error "fix point evaluation for spine($T, ::$(typeof(s)))"
        throw(MethodError(spine, (T, s)))
    end
    return spine(T, s′)
end

