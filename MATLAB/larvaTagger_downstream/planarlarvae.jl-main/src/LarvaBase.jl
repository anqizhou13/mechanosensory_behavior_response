module LarvaBase

using OrderedCollections: OrderedDict
using Meshes
using StaticArrays: SVector

export Records, derivedtype, getrecord,
       LarvaID, Time, TimeSeries, Larvae, Runs, Collection,
       map′, zip′, filterlarvae,
       eachtimeseries, eachstate,
       Path, getx, gety, getz, close_reverse,
       xmin, xmax, ymin, ymax, bounds,
       tmin, tmax, times, larvatrack,
       OutlineGeometry, SpineGeometry, geometry, centroid,
       Outline, Spine, outline, spine,
       # unstable API
       vertices′,
       PointSeries,
       SpineOutline,
       AbstractSpine, AbstractOutline, AbstractTags,
       RecordSelector, RecordAspect, HasRecord, HasSpine, HasOutline,
       # discrete behaviors
       BehaviorTags, Tags

include("records.jl")
include("geometries.jl")
include("tags.jl")

end
