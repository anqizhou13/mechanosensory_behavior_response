"""
The Dataloaders module is a generic sampler of time segments for tracking or tagging data
files.

A dataloader is supported by a window construct for sampling and selecting time segments,
and a time segment index that can store pointers to all time segments in a database, or
emulate some global knowledge for databases that are too large to be fully indexed.

The default design is optimized for tracking data stored as json .label files.
"""
module Dataloaders

using ..LarvaBase: LarvaBase, times
using ..Datasets: Track, TrackID
using ..Formats
using ..MWT: interpolate
using Random

export DataLoader, Repository, TimeWindow, ratiobasedsampling, buildindex, sample,
       extendedlength, prioritylabel

"""
The default window type defines a time segment as the time of a segment-specific reference
point called anchor point. This anchor point is a defined time point (that does not need to
be interpolated). The associated segment is additionally characterized by its past and future
extent from the anchor point.

A window is in charge of interpolating or downsampling the time series data within a segment.
A time segment may also provide discrete behavioral information, typically sourced at the
anchor time only.

Interpolation/downsampling is automatically implemented for any datatype that features a
`samplerate` attribute.

A few assumptions and design choices are made:
* a window has access to the entire track hence the `indicator` function called to identify
  anchor points and related data (discrete behavior);
* discrete behavioral information (labels/tags) are provided as `Datasets.Track` data
  structures.
"""
struct TimeWindow
    durationbefore
    durationafter
    marginbefore
    marginafter
    samplerate
end

TimeWindow(duration) = TimeWindow(duration, nothing)
function TimeWindow(duration, samplerate; maggotuba_compatibility=false)
    0 < duration || throw("Non-positive time window duration")
    0 < samplerate || throw("Non-positive sampling frequency")
    margin = maggotuba_compatibility ? duration : 0
    TimeWindow(.5duration, .5duration, margin, margin, samplerate)
end

Base.length(w::TimeWindow) = round(Int, (w.durationbefore + w.durationafter) * w.samplerate) + 1

function extendedlength(w::TimeWindow)
    extendedduration = w.durationbefore + w.marginbefore + w.durationafter + w.marginafter
    round(Int, extendedduration * w.samplerate) + 1
end

struct TimeSegment
    trackid
    anchortime
    window
    class
    timeseries
end

Base.length(s::TimeSegment) = length(s.window)
extendedlength(s::TimeSegment) = extendedlength(s.window)
Base.minimum(s::TimeSegment) = round(s.anchortime - s.window.durationbefore; digits=4)
Base.maximum(s::TimeSegment) = round(s.anchortime + s.window.durationafter; digits=4)
extendedmin(s::TimeSegment) = round(s.anchortime - s.window.durationbefore - s.window.marginbefore; digits=4)
extendedmax(s::TimeSegment) = round(s.anchortime + s.window.durationafter + s.window.marginafter; digits=4)

LarvaBase.times(s::TimeSegment) = [round(t; digits=4) for t in range(minimum(s), maximum(s); length=length(s))]
extendedtimes(s::TimeSegment) = [round(t; digits=4) for t in range(extendedmin(s), extendedmax(s); length=extendedlength(s))]
LarvaBase.times(w::TimeWindow, t) = times(TimeSegment(nothing, t, w, nothing, nothing))
extendedtimes(w::TimeWindow, t) = extendedtimes(TimeSegment(nothing, t, w, nothing, nothing))

function indicator(window, track)
    ts = times(track)
    t0, t1 = first(ts), last(ts)
    t0′= round(t0 + window.durationbefore + window.marginbefore; digits=4)
    t1′= round(t1 - window.durationafter - window.marginafter; digits=4)
    range(searchsortedfirst(ts, t0′), searchsortedlast(ts, t1′);
          step=1) # explicit step arg is required by julia 1.6
end

function indicator(window::TimeWindow, segment::TimeSegment)
    @assert window === segment.window
    m = round(Int, window.marginbefore * window.samplerate)
    n = length(window)
    range(m + 1, m + n; step=1)
end

function segment(file, window, trackid, step, class)
    ts = times(Formats.getnativerepr(file)[trackid])
    @assert 1 < step < length(ts)
    @inbounds anchortime = round(ts[step]; digits=4)
    segmentdata = if isnothing(window.samplerate)
        throw("Not implemented")
    else
        window.durationafter == window.durationbefore || throw("Not implemented: asymmetric window")
        file′= isa(file, Formats.JSONLabels) ? file.dependencies[1] : file
        timeseries = gettimeseries(file′)[trackid]
        ts, xs = [t for (t, _) in timeseries], [x for (_, x) in timeseries]
        interpolate(ts, xs, extendedtimes(window, anchortime))
    end
    @assert length(segmentdata) == extendedlength(window)
    TimeSegment(trackid, anchortime, window, class, segmentdata)
end

struct Repository
    root::String
    files::Vector{Formats.PreloadedFile}
end

function Repository(root::String, pattern::Regex; basename_only::Bool=false)
    root = expanduser(root)
    files = String[]
    for (dir, _, files′) in walkdir(root; follow_symlinks=true)
        for file′ in files′
            file = joinpath(dir, file′)
            if !isnothing(Base.match(pattern, basename_only ? file′ : file))
                push!(files, file)
            end
        end
    end
    Repository(root, preload.(files))
end

function Repository(root::String, fileselector::Function)
    Repository(root, labelledfiles(root; selection_rule=fileselector))
end

function Repository(root)
    if '*' in root
        parts = splitpath(root)
        i = findfirst(f -> '*' in f, parts)
        root = joinpath(parts[1:i-1]...) # splatting is required by julia 1.6
        pattern = joinpath(parts[i:end]...)
        if startswith(pattern, "**.")
            Repository(root, r".*[.]" * Regex(pattern[4:end]); basename_only=true)
        elseif startswith(pattern, "**/") # what about Windows paths?
            Repository(root, Regex(pattern[4:end]); basename_only=true)
        else
            Repository(root, Regex(pattern))
        end
    else
        Repository(root, collect(labelledfiles(root)))
    end
end

Base.isempty(repo::Repository) = isempty(repo.files)
Base.length(repo::Repository) = length(repo.files)
Base.getindex(repo::Repository, i) = repo.files[i]

root(repo::Repository) = repo.root
files(repo::Repository) = repo.files
filepaths(repo) = [relpath(file.source, root(repo)) for file in files(repo)]

struct DataLoader
    repository
    window
    index
end

root(loader::DataLoader) = root(loader.repository)
files(loader::DataLoader) = files(loader.repository)

function countlabels(loader::DataLoader; unload=false)
    countlabels(loader.repository, loader.window; unload=unload)
end

function countlabels(repository, window; unload=false)
    Count = Dict{Union{String, Vector{String}}, Int}
    counts = Dict{Formats.PreloadedFile, Count}()
    ch = Channel() do ch
        foreach(files(repository)) do file
            put!(ch, file)
        end
    end
    c = Threads.Condition()
    Threads.foreach(ch) do file
        counts′= Count()
        for track in values(getrun(file))
            labelsequence = track[:labels][indicator(window, track)]
            for label in labelsequence
                counts′[label] = get(counts′, label, 0) + 1
            end
        end
        unload && unload!(file; gc=true)
        lock(c)
        try
            counts[file] = counts′
        finally
            unlock(c)
        end
    end
    return counts
end

function total(counts)
    iterator = values(counts)
    counts′, state = iterate(iterator)
    counts′= copy(counts′)
    next = iterate(iterator, state)
    while !isnothing(next)
        counts″, state = next
        for (label, count) in pairs(counts″)
            counts′[label] = get(counts′, label, 0) + count
        end
        next = iterate(iterator, state)
    end
    return counts′
end

total(counts::Dict{<:Any, Int}) = counts

mutable struct LazyIndex
    maxcounts
    targetcounts
    sampler
end

LazyIndex(sampler) = LazyIndex(nothing, nothing, sampler)

function Base.length(ix::LazyIndex)
    isnothing(ix.targetcounts) && throw("index has not been built yet")
    sum(Iterators.flatten(values.(values(ix.targetcounts))))
end

abstract type RatioBasedSampling end

struct ClassRatios <: RatioBasedSampling
    selectors
    majority_minority_ratio
    seed
end

struct IntraClassRatios <: RatioBasedSampling
    selectors
    majority_minority_ratio
    intraclass
    seed
end

function ratiobasedsampling(selectors, majority_minority_ratio; seed=nothing)
    LazyIndex(ClassRatios(asselectors(selectors), majority_minority_ratio, seed))
end

function ratiobasedsampling(selectors, majority_minority_ratio, intraclass; seed=nothing)
    intraclass = if intraclass isa Pair
        Dict(asselector(intraclass.first) => intraclass.second)
    else
        Dict(asselector(selector) => f for (selector, f) in intraclass)
    end
    LazyIndex(IntraClassRatios(asselectors(selectors), majority_minority_ratio, intraclass,
                               seed))
end

init!(sampler) = isnothing(sampler.seed) || Random.seed!(sampler.seed)

classtype(sampler::RatioBasedSampling) = classtype(sampler.selectors)
classtype(::AbstractDict{T, <:Any}) where {T} = T

abstract type LabelSelector end

struct PlainLabel{T} <: LabelSelector
    label::T
    complement::Bool
end

function PlainLabel(label::String)
    if label[1] == '¬'
        PlainLabel(label[nextind(label, 1):end], true)
    else
        PlainLabel(label, false)
    end
end

struct LabelPattern <: LabelSelector
    pattern::Regex
end

function match end # hides Base.match

match(sel::PlainLabel{T}, label::T) where {T} = (sel.complement ? (≠) : (==))(sel.label, label)
match(sel::PlainLabel{T}, labels::AbstractVector{T}) where {T} = (sel.complement ? (∉) : (∈))(sel.label, labels)

match(sel::LabelPattern, label::String) = !isnothing(Base.match(sel.pattern, label))
match(sel::LabelPattern, labels::AbstractVector{String}) = !all(label -> isnothing(Base.match(sel.pattern, label)), labels)

match(sel::Pair{Symbol, <:LabelSelector}, label) = match(sel.second, label)

function match(sel::LabelSelector, labels)
    for label in labels
        if match(sel, label)
            return label
        end
    end
end

function match(selectors, label)
    for (key, selector) in pairs(asselectors(selectors))
        if match(selector, label)
            return key
        end
    end
end

function indicator(selector::LabelSelector, labelsequence::AbstractVector)
    [i for (i, label) in enumerate(labelsequence) if !isnothing(match(selector, label))]
end
indicator(selector::LabelSelector, track::Track) = indicator(selector, track[:labels])

asselectors(selectors::AbstractDict{Symbol, <:LabelSelector}) = selectors
asselectors(label::Union{String, Symbol}) = Dict(asselector(label))
asselectors(labels::AbstractVector{<:Union{String, Symbol}}) = Dict(asselector(label) for label in labels)
asselectors(regexes::AbstractDict{Symbol, Regex}) = Dict(asselector(regex) for regex in pairs(regexes))

asselector(selector::Pair{Symbol, <:LabelSelector}) = selector
asselector(label::String) = Symbol(label) => PlainLabel(label)
asselector(label::Symbol) = label => PlainLabel(string(label))
asselector(regex::Pair{Symbol, Regex}) = regex.first => LabelPattern(regex.second)

asselectors(sampler::RatioBasedSampling) = sampler.selectors
asselectors(index::LazyIndex) = asselectors(index.sampler)

function groupby(selectors, labelcounts)
    selectors = asselectors(selectors)
    totalcounts = total(labelcounts) # may already be done
    T = eltype(keys(selectors))
    T′= Set{eltype(keys(totalcounts))}
    classcounts = Dict{T, Int}()
    classes = Dict{T, T′}()
    for (label, count) in totalcounts
        class = match(selectors, label)
        if !isnothing(class)
            classcounts[class] = get(classcounts, class, 0) + count
            push!(get!(classes, class, T′()), label)
        end
    end
    return classcounts, classes
end

const TRXMAT_ACTION_LABELS = ["back", "cast", "hunch", "roll", "run", "stop"]
const TRXMAT_ACTION_MODIFIERS = Dict(:strong=>r"_strong$", :weak=>r"_weak$")

function countthresholds(counts, selectors, majority_minority_ratio)
    totalcounts = total(counts)
    classcounts, classes = groupby(selectors, totalcounts)
    isempty(classcounts) && @error "Not any specified label found" selectors totalcounts
    mincount, maxcount = countthresholds(classcounts, majority_minority_ratio)
    return mincount, maxcount, classcounts, classes
end

function countthresholds(counts, majority_minority_ratio)
    minoritylabel, mincount = first(counts)
    for (label, count) in pairs(counts)
        if count == 0
            @warn "Label not found" label
        elseif count < mincount
            minoritylabel, mincount = label, count
        end
    end
    maxcount = round(Int, majority_minority_ratio * mincount)
    return mincount, maxcount
end

function countthresholds(sampler::RatioBasedSampling, counts)
    countthresholds(counts, sampler.selectors, sampler.majority_minority_ratio)
end

function buildindex(loader::DataLoader; kwargs...)
    buildindex(loader.index, loader.repository, loader.window; kwargs...)
end

function buildindex(ix::LazyIndex, repository, window; unload=false, verbose=true)
    ix.maxcounts = countlabels(repository, window; unload=unload)
    ix.targetcounts = buildindex(ix.sampler, ix)
    if verbose
        maxcounts = total(ix.maxcounts)
        targetcounts = total(ix.targetcounts)
        table = [((label isa Vector ? Symbol(Symbol.(label)) : Symbol(label))
                  => (count => get(targetcounts, label, 0)))
                 for (label, count) in pairs(maxcounts)]
        @info "Sample sizes (observed => selected):" table...
    end
end

function buildindex(sampler::RatioBasedSampling, ix)
    counts = ix.maxcounts
    globalratios = ratio(sampler, total(counts))
    targetcounts = empty(counts)
    for (file, counts′) in pairs(counts)
        targetcounts[file] = targetcounts′= empty(counts′)
        for (label, count) in pairs(counts′)
            targetcounts′[label] = if label in keys(globalratios)
                round(Int, count * globalratios[label])
            else
                0
            end
        end
    end
    @debug "Target ratios and counts" ratios=globalratios counts=targetcounts
    return targetcounts
end

function ratio(counts::AbstractDict{T, Int}; lower::Int=0, upper::Int=typemax(Int),
    ) where {T}
    mincount, maxcount = lower, upper
    ratios = Dict{T, Rational{Int}}()
    for (class, count) in pairs(counts)
        targetcount = maxcount < count ? maxcount : count < mincount ? 0 : count
        ratios[class] = targetcount // count
    end
    return ratios
end

function ungroupby(::Type{T′}, classes, classratios) where {T′}
    T = eltype(first(values(classes)))
    ratios = Dict{T, T′}()
    for (class, labels) in pairs(classes)
        foreach(labels) do label
            ratios[label] = classratios[class]
        end
    end
    return ratios
end
ungroupby(class, values::Dict{<:Any, T}) where {T} = ungroupby(T, class, values)

function ratio(mincount::Int, maxcount::Int, classcounts, classes)
    classratios = ratio(classcounts; lower=mincount, upper=maxcount)
    ungroupby(classes, classratios)
end
ratio(sampler::ClassRatios, counts) = ratio(countthresholds(sampler, counts)...)

function ratio(sampler::IntraClassRatios, counts)
    totalcounts = total(counts)
    mincount, maxcount, classcounts, classes = countthresholds(sampler, counts)
    classratios = ratio(classcounts; lower=mincount, upper=maxcount)
    ratios = ungroupby(Float64, classes, classratios)
    for (class, labels) in pairs(classes)
        for (selector, f) in pairs(sampler.intraclass)
            if !isnothing(match(selector, labels))
                updatedratios = f(class,
                                  classratios[class],
                                  Dict(label => totalcounts[label] for label in labels);
                                  lower=mincount,
                                  upper=maxcount)
                isnothing(updatedratios) || merge!(ratios, updatedratios)
            end
        end
    end
    return ratios
end

function prioritylabel(label; verbose=true)
    speciallabel = label
    selector = asselector(label)
    function priority_include(class, ratio, counts; lower=0, upper=typemax(Int))
        maxothers = 0
        preincluded = 0
        maxinclusions = 0
        ratios = Dict{eltype(keys(counts)), typeof(ratio)}()
        for (label, count) in pairs(counts)
            if match(selector, label)
                preincluded += round(Int, ratio * count)
                maxinclusions += count
            else
                maxothers += count
            end
        end
        inclusions = min(maxinclusions, upper)
        if 0 < preincluded < inclusions
            others = min(maxothers, upper) - inclusions
            if verbose
                @info "Explicit inclusions (initially selected => eventually selected):" class=class priority_tag=speciallabel with_priority_tag=(preincluded=>inclusions) without_priority_tag=(maxothers=>others)
            end
            priorityratio = inclusions / maxinclusions
            newratio = others / maxothers
            foreach(keys(counts)) do label
                ratios[label] = match(selector, label) ? priorityratio : newratio
            end
        end
        return ratios
    end
    return selector => priority_include
end

function sample(f, loader::DataLoader, features=:spine; kwargs...)
    ch = Channel() do ch
        state = nothing
        for (i, file) in enumerate(files(loader))
            state = presample(state, file, loader.window, loader.index)
            put!(ch, (i, file, state))
        end
    end
    Threads.foreach(ch) do (i, file, state)
        segments = sample(file, loader.window, loader.index, features; kwargs...)
        f(i, file, state, filter(!isnothing, segments))
        empty!(segments)
        unload!(file; gc=true)
    end
end

function sample(file::Formats.PreloadedFile, window, ix::LazyIndex, features; kwargs...)
    init!(ix.sampler)
    sample(ix.sampler, file, window, ix.targetcounts[file], features; kwargs...)
end

function sample(sampler, file, window, counts, features; verbose=false)
    # generate an index for the present file as a collection of pointers (pairs of track
    # number and time step index) for each behavioral class
    T = eltype(keys(counts))
    T′= Tuple{TrackID, Int, Symbol}
    run = getrun(file)
    index = Dict{T, Vector{T′}}()
    for (trackid, track) in pairs(run)
        labels = track[:labels]
        ind = collect(indicator(window, track))
        for step in ind
            label = labels[step]
            class = match(sampler, label)
            isnothing(class) && continue
            labelindex = get!(index, label, T′[])
            push!(labelindex, (trackid, step, class))
        end
    end

    if verbose
        observedcounts = Dict(label=>length(pointers) for (label, pointers) in index)
        @info "In file: $(file.source)\nSample sizes (observed => selected):" [(label isa Vector ? Symbol(Symbol.(label)) : Symbol(label)) => (count => get(counts, label, 0)) for (label, count) in pairs(observedcounts)]...
    end

    # pick time segments at random to achieve the desired class counts
    for (label, count) in pairs(counts)
        label in keys(index) || continue
        pointers = shuffle(index[label])
        # counts should not exceed the actual numbers
        index[label] = pointers[1:count]
    end
    index = sort(vcat(values(index)...))

    # load the data dependencies if any, skipping the data that are not requested
    # TODO: make `drop_record!(::JSONLabels)` manage the data dependencies as well,
    #       with e.g. spine/outline files removed from the list of dependencies if not
    #       needed, or `drop_record!` simply applied to a trx.mat file
    if features isa Symbol
        features = Set([features])
    end
    @assert :outline ∉ features
    if file isa Formats.JSONLabels
        Formats.getdependencies!(file)
        for file′ in file.dependencies
            if isempty(file′.timeseries)
                Formats.drop_outlines!(file′)
                :spine ∈ features || Formats.drop_spines!(file′)
                :tags  ∈ features || Formats.drop_record!(file′, :tags)
            end
            Formats.load!(file′)
        end
    elseif isempty(file.timeseries)
        for capability in (:spine, :outline, :tags)
            capability in file.capabilities && capability ∉ features && Formats.drop_record!(file, capability)
        end
    end

    # normalize the timestamps
    Formats.normalize_timestamps(file)

    # return an iterator over all time segments
    map(index) do (trackid, step, class)
        segment(file, window, trackid, step, class)
    end
end

function presample(state, file::Formats.PreloadedFile, window, ix::LazyIndex)
    presample(ix.sampler, state, file, window, ix.targetcounts[file])
end
presample(_, ::Nothing, _, _, counts) = (0, sum(values(counts)))
presample(_, cumulatedcount, _, _, counts) = (sum(cumulatedcount), sum(values(counts)))

end
