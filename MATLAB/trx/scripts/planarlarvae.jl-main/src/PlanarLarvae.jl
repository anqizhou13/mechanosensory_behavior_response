module PlanarLarvae

include("LarvaBase.jl")
include("Chore.jl")
include("Trxmat.jl")
include("Datasets.jl")
include("FIMTrack.jl")
include("Formats.jl")
include("Features.jl")
include("MWT.jl")

using .LarvaBase

export Records, derivedtype, getrecord,
       LarvaID,# Time, TimeSeries, Larvae, Runs,
       map′, zip′, filterlarvae,
       # discrete behaviors
       BehaviorTags, Tags,
       # shapes and tracks
       eachtimeseries, eachstate, larvatrack,
       Path, getx, gety, getz,
       xmin, xmax, ymin, ymax, bounds,
       tmin, tmax, times,
       geometry, close_reverse, centroid,
       Outline, Spine, outline, spine,
       OutlineGeometry, SpineGeometry,
       # unstable API
       vertices′,
       PointSeries,
       SpineOutline,
       AbstractSpine, AbstractOutline, AbstractTags,
       RecordSelector, RecordAspect, HasRecord, HasSpine, HasOutline

end
