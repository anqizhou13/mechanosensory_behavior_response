"""
Code borrowed from LarvaTagger.jl
"""
const TimeStep = Int
const PathOrOutline = Vector{Any} # modified

struct LarvaModel
    id::LarvaID
    alignedsteps::Vector{TimeStep}
    path::PathOrOutline
    fullstates::PlanarLarvae.TimeSeries{<:NamedTuple}
    #usertags::AbstractObservable{Dict{TimeStep, UserTags}}
end

function LarvaModel(id::LarvaID, timeseries::PlanarLarvae.TimeSeries{<:NamedTuple}, times::Vector{PlanarLarvae.Time})
    alignedsteps = map(timeseries) do (t, _)
        findfirst(t′-> abs(t - t′) < TIME_PRECISION, times)
    end
    path = coordinates.(larvatrack(timeseries))
    #usertags = Observable(Dict{TimeStep, UserTags}())
    LarvaModel(id, alignedsteps, path, timeseries)#, usertags)
end

function LarvaModel(track::Track, times::Vector{PlanarLarvae.Time})
    alignedsteps = map(track.timestamps) do t
        findfirst(t′-> abs(t - t′) < TIME_PRECISION, times)
    end
    path = coordinates.(larvatrack(track[:spine]))
    #usertags = Observable(Dict{TimeStep, UserTags}())
    LarvaModel(track.id,
               alignedsteps,
               path,
               astimeseries(track),
               #usertags,
              )
end

function loadfile(path)
    file = Formats.load(path)
    data = isempty(file.run) ? file.timeseries : file.run
    # tracks
    times = PlanarLarvae.times(data)
    if file isa Formats.FIMTrack
        tracks = [LarvaModel(track, times) for track in values(getrun(file))]
    else
        tracks = [LarvaModel(id, ts, times) for (id, ts) in pairs(gettimeseries(file))]
    end
    # dataset
    metadata = getmetadata(file)
    if isempty(metadata)
        metadata = extract_metadata_from_filepath(path)
        run = get!(metadata, :date_time, "NA")
    else
        run = file.run.id
    end
    output = Dataset([Run(run; metadata...)])
    #
    labels = getlabels(file)
    existingtags = labels[:names]
    if haskey(labels, :colors)
        tagcolors = labels[:colors]
        return (tracks=tracks, timestamps=times, tags=existingtags, tagcolors=tagcolors, output=output)
    else
        return (tracks=tracks, timestamps=times, tags=existingtags, output=output)
    end
end
