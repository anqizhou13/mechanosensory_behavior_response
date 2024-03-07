abstract type AbstractTags{T} <: AbstractSet{T} end

"""
    Tags(all_tag_names, mask)
    Tags(all_tag_names, selected_tag_names)
    const BehaviorTags = Tags{Symbol}

Set of tags, encoded as an comprehensive list of tags combined with an indicator array.

Tag names can be either strings or symbols.

Duplicates in `all_tag_names` are not removed but should not affect `AbstractSet`
functionalities.

See also [`Records`](@ref).
"""
struct Tags{T} <: AbstractTags{T}
    names::Vector{T} # comprehensive list of tag names (String or Symbol)
    indicators::BitArray # indicator array

    function Tags{T}(names, indicators) where {T}
        length(names) == length(indicators) || throw(ArgumentError("not as many tag names as indicators"))
        new{T}(names, indicators)
    end
end

const BehaviorTags = Tags{Symbol}

## implementation

Tags(names, indicators) = Tags{eltype(names)}(names, indicators)

function Tags{T}(
        all_tags::Vector{T},
        selected_tags::Vector{T},
    ) where {T}
    isempty(all_tags) && throw(ArgumentError("no tags defined"))
    n = length(all_tags)
    indicators = falses(n)
    for tag in selected_tags
        i = findfirst(==(tag), all_tags)
        isnothing(i) && throw(ArgumentError("selected tag not found in comprehensive list of tags"))
        indicators[i] = true
    end
    Tags{T}(all_tags, indicators)
end
Tags(all_tags::Vector{T}, selected_tags::Vector{T}) where {T} = Tags{T}(all_tags, selected_tags)

Tags{T}(all_tags::Vector{T}) where {T} = Tags{T}(all_tags, falses(length(all_tags)))
Tags(all_tags::Vector{T}) where {T} = Tags{T}(all_tags)

Base.isempty(tags::Tags) = !any(tags.indicators)
Base.length(tags::Tags) = count(tags.indicators)

Base.emptymutable(tags::Tags{T}, ::Type{T}) where {T} = Tags(tags.names)
Base.copymutable(tags::Tags) = Tags(tags.names, copy(tags.indicators))

# allow different sources
Base.:(==)(tags::Tags{T}, tags′::Tags{T}) where {T} = tags.names == tags′.names && tags.indicators == tags′.indicators
# override https://github.com/JuliaLang/julia/blob/3bf9d1773144bc4943232dc2ffaac307a700853d/base/abstractset.jl#L428
Base.:(==)(tags::Tags{T}, itr::AbstractSet{T}) where {T} = all(∈(tags), itr)

function Base.empty!(tags::Tags)
    tags.indicators .= false
    return tags
end

function Base.:(∈)(tag::T, tags::Tags{T}) where {T}
    i = findfirst(==(tag), tags.names)
    isnothing(i) && throw(KeyError("unknown tag: \"$tag\""))
    return tags.indicators[i]
end

function set_indicator!(tags::Tags{T}, tag::T, bool::Bool) where {T}
    i = findfirst(==(tag), tags.names)
    isnothing(i) && throw(KeyError("unknown tag: \"$tag\""))
    tags.indicators[i] = bool
end

set_indicator!(tags::Tags, i::Int, bool::Bool) = (tags.indicators[i] = bool)

Base.push!(tags::Tags{T}, tag::T) where {T} = set_indicator!(tags, tag, true)
Base.delete!(tags::Tags{T}, tag::T) where {T} = set_indicator!(tags, tag, false)

check_compatibility(tags, tags′) = tags.names === tags′.names || throw(ArgumentError("lists of tags do not come from the same source"))

function Base.union!(tags::Tags{T}, tags′::Tags{T}) where {T}
    check_compatibility(tags, tags′)
    tags.indicators .|= tags′.indicators
    return tags
end

function Base.intersect!(tags::Tags{T}, tags′::Tags{T}) where {T}
    check_compatibility(tags, tags′)
    tags.indicators .&= tags′.indicators
    return tags
end

function Base.union!(tags::Tags, itr)
    # override https://github.com/JuliaLang/julia/blob/3bf9d1773144bc4943232dc2ffaac307a700853d/base/abstractset.jl#L94-L101
    for x in itr
        push!(tags, x)
    end
    return tags
end

# partially override https://github.com/JuliaLang/julia/blob/3bf9d1773144bc4943232dc2ffaac307a700853d/base/abstractset.jl#L130
Base.intersect(tags::Tags{T}, tags′::Tags{T}) where {T} = intersect!(Base.copymutable(tags), tags′)

function Base.setdiff!(tags::Tags{T}, tags′::Tags{T}) where {T}
    check_compatibility(tags, tags′)
    tags.indicators[tags′.indicators] .= false
    return tags
end

function Base.symdiff!(tags::Tags{T}, tags′::Tags{T}) where {T}
    check_compatibility(tags, tags′)
    int = tags.indicators .& tags′.indicators
    tags.indicators .|= tags′.indicators
    @. tags.indicators &= ~int
    return tags
end

function Base.issubset(tags::Tags{T}, tags′::Tags{T}) where {T}
    # override https://github.com/JuliaLang/julia/blob/3bf9d1773144bc4943232dc2ffaac307a700853d/base/abstractset.jl#L279-L296
    check_compatibility(tags, tags′)
    return all(tags′.indicators[tags.indicators])
end

Base.issubset(tags::Tags{T}, tags′::AbstractSet{T}) where {T} = issubset(convert(Set{T}, tags), tags′)

function Base.:(⊊)(tags::Tags{T}, tags′::Tags{T}) where {T}
    check_compatibility(tags, tags′)
    return all(tags′.indicators[tags.indicators]) && !all(tags.indicators[tags′.indicators])
end

Base.:(⊊)(tags::Tags{T}, tags′::AbstractSet{T}) where {T} = convert(Set{T}, tags) ⊊ tags′

function Base.isdisjoint(tags::Tags{T}, tags′::Tags{T}) where {T}
    # override https://github.com/JuliaLang/julia/blob/3bf9d1773144bc4943232dc2ffaac307a700853d/base/abstractset.jl#L412-L424
    check_compatibility(tags, tags′)
    return !any(tags.indicators .& tags′.indicators)
end

Base.isdisjoint(tags::Tags{T}, tags′::AbstractSet{T}) where {T} = isdisjoint(convert(Set{T}, tags), tags′)

#Base.IndexStyle(::Type{<:Tags}) = IndexLinear()

#setindex!(tags::Tags, i::Int, bool::Bool) = (tags.indicators[i] = bool)

function Base.show(io::IO, ::MIME"text/plain", tags::Tags)
    println(io, length(tags.names), "-element Tags:")
    for (ind, tag) in zip(tags.indicators, tags.names)
        println(io, " [", ind ? "X" : " ", "] ", tag)
    end
end

function Base.show(io::IO, tags::Tags)
    if get(io, :compact, false)
        str = ["Tag{"]
        itr = tags.names[tags.indicators]
        if !isempty(itr)
            tag = itr[1]
            push!(str, "\"$tag\"")
            for tag in itr[2:end]
                push!(str, ", \"$tag\"")
            end
        end
    else
        str = ["$(length(tags.names))-element Tag{"]
        itr = tags.names[tags.indicators]
        if !isempty(itr)
            tag = itr[1]
            push!(str, "\"$tag\"")
            for tag in itr[2:end]
                push!(str, ", \"$tag\"")
            end
        end
    end
    push!(str, "}")
    print(io, str...)
end

Base.convert(::Type{Vector{T}}, tags::Tags{T}) where {T} = tags.names[tags.indicators]
Base.convert(::Type{Vector}, tags::Tags{T}) where {T} = convert(Vector{T}, tags)

Base.collect(tags::Tags) = convert(Vector, tags)

Base.convert(::Type{Set{T}}, tags::Tags{T}) where {T} = Set(tags.names[tags.indicators])
Base.convert(::Type{Set}, tags::Tags{T}) where {T} = convert(Set{T}, tags)

Base.convert(::Type{Vector{T}}, tags::Tags) where {T} = T.(convert(Vector, tags))
Base.convert(::Type{Set{T}}, tags::Tags) where {T} = Set{T}(convert(Vector{T}, tags))
