"""
Legacy code from LarvaTagger.jl, replaced by Formats.jl

Requires `LarvaModel` defintion currently in `formats.jl`.
"""
formats = Dict(Formats.Chore=>:chore, Formats.Trxmat=>:trx, Formats.FIMTrack=>:fimtrack, Formats.JSONLabels=>:json)

function loadfile_legacy(path)
    # TODO: refactor
    fmt = formats[guessfileformat(path)] # adapted
    hastags = false
    existingtags, tagcolors = Set{Symbol}(), nothing
    data, metadata, run = nothing, nothing, nothing
    if fmt === :trx
        data = read_trxmat((:spine=>Spine, :outline=>Outline, :tags=>BehaviorTags), path)
        hastags = true
    elseif fmt === :chore
        data = read_chore_files((:spine=>Spine, :outline=>Outline), path)
    elseif fmt === :json
        data, metadata, existingtags, tagcolors = read_json_labels(path)
        run = first(keys(data))
        hastags = true
    elseif fmt === :fimtrack
        @info "Assuming 30 fps for FIMTrack v2 csv files"
        data = read_fimtrack((:spine=>Spine, :outline=>Outline), path; framerate=30) # modified
    else
        return ()
    end
    if data isa PlanarLarvae.Runs
        @assert length(data) == 1
        data = first(values(data))
    end
    # tracks
    times = PlanarLarvae.times(data)
    if data isa PlanarLarvae.Larvae
        tracks = [LarvaModel(id, ts, times) for (id, ts) in pairs(data)]
    else
        tracks = [LarvaModel(track, times) for track in data]
    end
    # tags
    if hastags && isempty(existingtags)
        for track in tracks
            for (_, state) in track.fullstates
                union!(existingtags, convert(Set, state.tags))
            end
        end
    end
    # dataset
    if isnothing(metadata) || isempty(metadata)
        metadata = extract_metadata_from_filepath(path)
        run = get!(metadata, :date_time, "NA")
    end
    output = Dataset([Run(run; metadata...)])
    #
    if isnothing(tagcolors)
        return (tracks=tracks, timestamps=times, tags=existingtags, output=output)
    else
        return (tracks=tracks, timestamps=times, tags=existingtags, tagcolors=tagcolors, output=output)
    end
end

function read_json_labels(path)
    run = decodelabels!(PlanarLarvae.Datasets.from_json_file(Run, path))
    labelspec = run.attributes[:labels]
    labelset = Symbol.(labelspec[:names])
    tagcolors = labelspec[:colors]
    #
    existingtags = labelset
    metadata = sort_metadata(run.attributes[:metadata])
    if isempty(metadata)
        @warn "No metadata found"
    end
    #
    datadir = dirname(path)
    datafile = Datasets.getdependencies(run, path)[1]
    datafmt = formats[guessfileformat(datafile)]
    data′= nothing
    if datafmt === :trx
        data′= read_trxmat((:spine=>Spine, :outline=>Outline), datafile)
    elseif datafmt === :chore
        data′= read_chore_files((:spine=>Spine, :outline=>Outline), datafile)
    else datafmt === :fimtrack
        @info "Assuming 30 fps for FIMTrack v2 csv files"
        data′= read_fimtrack((:spine=>Spine, :outline=>Outline), datafile; framerate=30) # modified
        data′= Dataset([Run(run.id, data′)])
    end
    @assert length(data′) == 1
    runid = first(keys(data′))
    if runid != run.id
        @error "Run IDs do not match: \"$(run.id)\" vs \"$runid\""
    end
    recordtype = PlanarLarvae.derivedtype((:spine=>Spine, :outline=>Outline, :tags=>BehaviorTags))
    data = PlanarLarvae.Runs{recordtype}()
    data[runid] = PlanarLarvae.Larvae{recordtype}()
    for (id, track′) in pairs(data′[runid])
        newtimeseries = PlanarLarvae.TimeSeries{recordtype}()
        if id in keys(run)
            track = run[id]
            tags = track[:labels]
            for i in 1:length(track.timestamps)
                t = track.timestamps[i]
                tags′= BehaviorTags(labelset, begin
                    l = tags[i]
                    (l isa Vector) ? Symbol.(l) : [Symbol(l)]
                end)
                t′, state = if track′ isa Track
                    t′= track′.timestamps[i]
                    state = NamedTuple(track′[t′])
                    t′, state
                else
                    track′[i]
                end
                @assert abs(t - t′) < .01
                push!(newtimeseries, (t′, (spine=state.spine, outline=state.outline, tags=tags′)))
            end
        elseif track′ isa Track
            for t′ in track′.timestamps
                push!(newtimeseries, (t′, (spine=track′[:spine, t′], outline=track′[:outline, t′], tags=BehaviorTags(labelset, Symbol[]))))
            end
        else
            for (t′, state) in track′
                push!(newtimeseries, (t′, (spine=state.spine, outline=state.outline, tags=BehaviorTags(labelset, Symbol[]))))
            end
        end
        if isempty(newtimeseries)
            @warn "Empty time series" track=id labelled=(id in keys(run))
        else
            data[runid][id] = newtimeseries
        end
    end
    return data, metadata, existingtags, tagcolors
end
