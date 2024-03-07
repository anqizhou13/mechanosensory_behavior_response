using PlanarLarvae, PlanarLarvae.Chore, PlanarLarvae.Trxmat, PlanarLarvae.FIMTrack,
      PlanarLarvae.Datasets, PlanarLarvae.Formats, PlanarLarvae.Features, PlanarLarvae.MWT,
      PlanarLarvae.Dataloaders
using Test
using Meshes
using StaticArrays
using OrderedCollections
import JSON3 as JSON

include("makedata.jl")

if isempty(ARGS) || "all" in ARGS
    all_tests = true
else
    all_tests = false
end

flat_outline = [156.375, 120.625, 156.375, 120.750, 156.375, 120.875, 156.375, 121.000, 156.375, 121.125, 156.500, 121.125, 156.500, 121.250, 156.500, 121.375, 156.625, 121.375, 156.625, 121.375, 156.750, 121.375, 156.875, 121.375, 156.875, 121.375, 157.000, 121.250, 157.000, 121.250, 157.000, 121.125, 157.125, 121.125, 157.125, 121.000, 157.125, 120.875, 157.250, 120.875, 157.250, 120.750, 157.250, 120.625, 157.250, 120.500, 157.250, 120.375, 157.375, 120.375, 157.375, 120.250, 157.375, 120.125, 157.375, 120.000, 157.500, 120.000, 157.500, 119.875, 157.500, 119.750, 157.500, 119.625, 157.500, 119.500, 157.500, 119.375, 157.625, 119.375, 157.625, 119.250, 157.625, 119.125, 157.625, 119.000, 157.625, 118.875, 157.625, 118.750, 157.500, 118.750, 157.500, 118.750, 157.375, 118.750, 157.375, 118.750, 157.250, 118.875, 157.250, 118.875, 157.125, 118.875, 157.125, 119.000, 157.000, 119.000, 157.000, 119.125, 157.000, 119.250, 156.875, 119.250, 156.875, 119.375, 156.750, 119.375, 156.750, 119.500, 156.750, 119.625, 156.625, 119.625, 156.625, 119.750, 156.625, 119.875, 156.625, 120.000, 156.500, 120.000, 156.500, 120.125, 156.500, 120.250, 156.500, 120.375, 156.500, 120.500]
flat_spine = [156.591, 121.397, 156.687, 121.293, 156.725, 121.059, 156.798, 120.764, 156.879, 120.456, 156.959, 120.148, 157.069, 119.819, 157.156, 119.531, 157.288, 119.229, 157.407, 118.943, 157.525, 118.752]
outline_x = flat_outline[1:2:end]
outline_y = flat_outline[2:2:end]
pair_outline = zip(outline_x, outline_y)
circular_outline = [collect(pair_outline); (outline_x[1], outline_y[1])]
outlinef_x = Float32.(outline_x)
outlinef_y = Float32.(outline_y)
flat_outlinef = Float32.(flat_outline)

path = PlanarLarvae.Path(flat_outline)
pointseries = PointSeries(outline_x, outline_y)

pointvec = reverse(Point2.(pair_outline)) # counter-clockwise
polygon = PolyArea(Chain(close(pointvec)))
outline = PlanarLarvae.outline(flat_outline)

target = make_test_data("chore_sample_outline")
target′ = make_test_data("chore_sample_spine")
if all_tests || "Geometries" in ARGS || "Base" in ARGS || "Chore" in ARGS || "Records" in ARGS
    data = read_outline(target)
    data′ = read_spine(target′)
end

spine = PlanarLarvae.spine(flat_spine)

target″ = make_test_data("sample_trxmat_file_small")
spine_outline = SpineOutline(spine, outline)

if all_tests || "Geometries" in ARGS ||  "Base" in ARGS || "Trxmat" in ARGS
    data_with_tags = read_trxmat((:spine=>Spine, :outline=>Outline, :tags=>BehaviorTags),
                                 artifact"sample_trxmat_file_small")
end

if all_tests || "Records" in ARGS || "Base" in ARGS
@testset "Records.jl" begin
    t = LinRange(.08, .96, 23)
    x = rand(Float64, 23)
    virtualtrack = collect(zip(t, x))
    @test times(virtualtrack) == t
    @test map′(x′->x′.+1, virtualtrack) == collect(zip(t, x.+1))
    run = "20150701_105504"
    larvae = data[run]
    ts = times(larvae)
    @test extrema(ts) == (3.675, 120.162)
    @test issorted(ts) && length(unique(ts)) == length(ts)
    @test times(map′(vertices, data)[run]) == ts
    data″ = filterlarvae((_,ts) -> tmin(ts)<=6, data)
    @test collect(keys(data″[run])) == UInt16[0x0007, 0x001d, 0x0022, 0x0028, 0x002a, 0x002c, 0x002e, 0x0031, 0x003c, 0x003e, 0x0040, 0x0044, 0x004a, 0x004f, 0x0052, 0x0060, 0x006d, 0x0072, 0x0079, 0x008b]
    id = 0x0007
    outline′ = data[run][id]
    spine′ = data′[run][id]
    spine_outline′ = zip′(derivedtype((:spine=>Spine, :outline=>Outline)), (spine′, outline′))
    spine_outline″ = zip′(derivedtype((:outline=>Outline, :spine=>Spine)), (outline′, spine′))
    @test map′(PlanarLarvae.spine, spine_outline′) == map′(PlanarLarvae.spine, spine_outline″)
    @test map′(PlanarLarvae.outline, spine_outline′) == map′(PlanarLarvae.outline, spine_outline″)
    reftrack = Point2[Point(70.831, 87.169), Point(70.98, 87.208), Point(71.115, 87.26), Point(71.047, 87.266), Point(71.322, 87.364), Point(71.087, 87.288), Point(71.098, 87.277), Point(71.18, 87.32), Point(71.331, 87.356), Point(71.421, 87.387), Point(71.422, 87.386), Point(71.58, 87.409), Point(71.886, 87.474), Point(71.565, 87.423), Point(71.568, 87.421), Point(71.479, 87.391), Point(71.556, 87.421), Point(71.784, 87.452), Point(71.874, 87.486), Point(71.923, 87.472), Point(72.023, 87.497), Point(71.877, 87.483), Point(72.064, 87.518), Point(71.741, 87.469), Point(72.108, 87.531), Point(72.306, 87.569), Point(72.313, 87.562), Point(72.308, 87.567), Point(72.323, 87.552), Point(72.299, 87.576), Point(72.361, 87.576), Point(72.102, 87.523), Point(72.201, 87.549), Point(72.65, 87.663), Point(72.418, 87.582), Point(72.248, 87.565), Point(72.347, 87.591), Point(72.247, 87.566), Point(72.362, 87.576), Point(72.297, 87.578), Point(72.444, 87.618), Point(72.338, 87.593), Point(72.462, 87.685), Point(72.33, 87.642), Point(72.436, 87.605), Point(72.477, 87.621), Point(72.532, 87.615), Point(72.591, 87.626), Point(72.539, 87.604), Point(72.58, 87.615), Point(72.577, 87.628), Point(72.58, 87.614), Point(72.668, 87.622), Point(72.582, 87.613), Point(72.538, 87.601), Point(72.591, 87.604), Point(72.573, 87.572), Point(72.516, 87.552), Point(72.516, 87.552), Point(72.428, 87.543), Point(72.293, 87.506), Point(72.447, 87.517), Point(72.325, 87.488), Point(72.316, 87.496), Point(72.399, 87.539), Point(72.337, 87.538), Point(72.391, 87.547), Point(72.431, 87.569), Point(72.432, 87.568), Point(72.445, 87.558), Point(72.501, 87.565), Point(72.268, 87.482), Point(72.066, 87.434), Point(71.999, 87.439), Point(71.891, 87.422), Point(71.884, 87.428), Point(71.944, 87.431), Point(71.911, 87.402), Point(71.94, 87.434), Point(71.825, 87.425), Point(71.896, 87.479), Point(71.978, 87.522), Point(71.963, 87.537), Point(71.999, 87.625), Point(72.01, 87.676), Point(71.987, 87.637), Point(72.01, 87.676), Point(72.067, 87.745), Point(72.009, 87.803), Point(71.962, 87.85), Point(71.978, 87.896), Point(71.938, 87.875), Point(71.958, 87.917), Point(71.957, 87.918), Point(72.018, 88.107), Point(72.135, 88.422), Point(72.135, 88.423), Point(72.095, 88.279), Point(72.102, 88.261), Point(72.113, 88.302), Point(72.098, 88.273), Point(72.158, 88.525), Point(72.132, 88.66), Point(72.144, 88.917), Point(72.125, 88.687), Point(72.17, 89.039), Point(72.166, 89.081), Point(72.17, 89.078), Point(72.175, 89.196), Point(72.175, 89.199), Point(72.155, 89.095), Point(72.192, 89.556), Point(72.196, 89.677), Point(72.205, 89.668), Point(72.205, 89.668), Point(72.196, 89.678), Point(72.205, 89.669), Point(72.205, 89.794), Point(72.243, 90.116), Point(72.218, 90.031), Point(72.256, 90.219), Point(72.27, 90.282), Point(72.257, 90.211), Point(72.236, 90.138), Point(72.22, 90.155), Point(72.228, 90.271), Point(72.231, 90.392), Point(72.236, 90.384), Point(72.232, 90.517), Point(72.245, 90.501), Point(72.229, 90.396), Point(72.218, 90.407), Point(72.239, 90.497), Point(72.256, 90.619), Point(72.253, 90.621), Point(72.256, 90.618), Point(72.286, 90.651), Point(72.328, 90.733), Point(72.324, 90.676), Point(72.342, 90.721), Point(72.305, 90.638), Point(72.322, 90.677), Point(72.333, 90.666), Point(72.353, 90.771), Point(72.358, 90.766)]
    @test larvatrack(spine′) == reftrack
    @test larvatrack(spine_outline′) == reftrack
    @test larvatrack(outline′) != reftrack
    _, state = spine_outline′[1]
    @test PlanarLarvae.outline(SVector, state) == SVector{2, Float64}[[69.875, 86.5], [69.875, 86.375], [69.875, 86.375], [70.0, 86.25], [70.125, 86.25], [70.125, 86.375], [70.25, 86.375], [70.375, 86.375], [70.375, 86.5], [70.5, 86.5], [70.5, 86.625], [70.625, 86.625], [70.75, 86.625], [70.75, 86.75], [70.875, 86.75], [71.0, 86.75], [71.0, 86.875], [71.125, 86.875], [71.25, 86.875], [71.375, 86.875], [71.375, 87.0], [71.5, 87.0], [71.625, 87.0], [71.625, 87.125], [71.75, 87.125], [71.875, 87.125], [72.0, 87.125], [72.0, 87.25], [72.125, 87.25], [72.25, 87.25], [72.25, 87.375], [72.375, 87.375], [72.375, 87.375], [72.5, 87.5], [72.5, 87.5], [72.5, 87.625], [72.5, 87.625], [72.5, 87.75], [72.375, 87.75], [72.25, 87.75], [72.125, 87.75], [72.0, 87.75], [71.875, 87.75], [71.75, 87.75], [71.75, 87.75], [71.625, 87.875], [71.5, 87.875], [71.375, 87.875], [71.375, 87.75], [71.25, 87.75], [71.125, 87.75], [71.0, 87.75], [71.0, 87.625], [70.875, 87.625], [70.75, 87.625], [70.625, 87.625], [70.625, 87.5], [70.5, 87.5], [70.5, 87.375], [70.375, 87.375], [70.25, 87.375], [70.25, 87.25], [70.125, 87.25], [70.125, 87.125], [70.0, 87.125], [70.0, 87.0], [69.875, 87.0], [69.875, 86.875], [69.875, 86.875], [69.75, 86.75], [69.75, 86.625], [69.75, 86.625], [69.75, 86.5], [69.875, 86.5]]
    @test PlanarLarvae.spine(SVector, state) == SVector{2, Float64}[[72.508, 87.587], [72.252, 87.54], [71.874, 87.484], [71.502, 87.43], [71.14, 87.297], [70.831, 87.169], [70.546, 87.016], [70.299, 86.828], [70.059, 86.636], [69.879, 86.495], [69.727, 86.493]]
end
end

if all_tests || "Geometries" in ARGS || "Base" in ARGS
@testset "Geometries.jl" begin

    @testset "PointSeries" begin
        @test_throws ArgumentError PointSeries(Float32[], Float32[])
        @test_throws DimensionMismatch PointSeries(outlinef_x, outlinef_y[1:2])

        series″ = convert(PointSeries, flat_outlinef)
        @test getx(series″) == outlinef_x
        @test gety(series″) == outlinef_y
        @test_throws Union{MethodError,BoundsError} getz(series″)

        series′ = PointSeries(flat_outlinef)
        @test IndexStyle(series′) == IndexLinear()
        @test eltype(series′) == Point2f
        @test length(series′) == 65
        @test series′ == series″

        local series = PointSeries(copy(outlinef_x), copy(outlinef_y))
        @test series == series′
        #@test series[end] == Point2f(156.500, 120.500)
        # TODO: decide whether to allow mutation or not
        series[5] = Point2f(0, 0)
        i = 0
        for p in series # test iteration
            x, y = coordinates(p)
            i += 1
            if i == 3
                @test x == Float32(156.375) && y == Float32(120.875)
            elseif i == 5
                @test x == 0 && y == 0
            end
        end
        @test series != series′

        series = PointSeries(outline_x, outline_y)
        @test close(series) == PointSeries(close(outline_x), close(outline_y))
    end

    @testset "Path" begin
        local path′ = PlanarLarvae.Path(copy(flat_outlinef))
        @test convert(typeof(path), path′) == path
        @test convert(typeof(flat_outlinef), path′) == flat_outlinef
        @test getx(path) == outline_x
        @test gety(path) == outline_y
        @test_throws Union{MethodError,BoundsError} getz(path)
        @test getx(PlanarLarvae.Path{1}(outline_x)) === outline_x
        p3 = PlanarLarvae.Path{3}(1:6)
        @test getx(p3) == [1,4] && gety(p3) == [2,5] && getz(p3) == [3,6]
        @test length(path) == 65
        @test length(close(path)) == length(path) + 1
        @test isclosed(close(path)) && isclosed(close_reverse(path))
        @test Vector{Point2}(close_reverse(path)) == close(reverse(path))
        @test IndexStyle(path) == IndexLinear()
        @test path[end] == Point(156.500, 120.500)
        @test all(enumerate(path)) do (i, p)
            p == Point(outline_x[i], outline_y[i])
        end
        # TODO: decide whether to allow mutation or not
        path′[end] = Point2f(150, 130)
        @test path′[end] == Point2f(150.000, 130.000)
    end

    @testset "PolyArea" begin
        @test vertices(polygon.outer) == pointvec
        @test outline == polygon
        @test PolyArea(path) == outline
        @test getx(outline) == close(reverse(outline_x))
        @test gety(outline) == close(reverse(outline_y))
        #@test convert(Outline, path) == outline
    end

    @testset "boundingbox" begin
        for outline in (path, pointseries, outline)
            bb = boundingbox(outline)
            (xmin, ymin) = coordinates(minimum(bb))
            (xmax, ymax) = coordinates(maximum(bb))
            @test xmin == 156.375 && xmax == 157.625 && ymin == 118.750 && ymax == 121.375
            (tmin, xmin′, ymin′), (tmax, xmax′, ymax′) = bounds([(100.0, path)])
            @test tmin == tmax == 100.0
            @test xmin == xmin′ && xmax == xmax′ && ymin == ymin′ && ymax == ymax′
        end

        (tmin, xmin, ymin), (tmax, xmax, ymax) = bounds(data)
        @test tmin == 3.675 && tmax == 120.162
        @test xmin == Float32(26.750) && xmax == Float32(226.250)
        @test ymin == Float32(20.750) && ymax == Float32(233.000)

        (tmin, xmin, ymin), (tmax, xmax, ymax) = bounds(data_with_tags)
        @test tmin ≈ 5.428 && tmax ≈ 119.358
        @test xmin ≈ 30.874999999999996 && xmax ≈ 199.74999999999997
        @test ymin ≈ 17.252741205607798 && ymax ≈ 214.36951758878436

        @test_throws KeyError bounds([(3.994, (spine=spine,))])
    end
end
end

if all_tests || "Tags" in ARGS || "Base" in ARGS
@testset "BehaviorTags.jl" begin
    for (t, tags) in enumerate((String[], ["run"], ["hunch", "roll"]))
        btags = Tags(string.(PlanarLarvae.Trxmat.behavior_tags), tags)
        stags = Set(tags)
        @test "cast" ∉ btags
        @test btags == stags
        @test (btags ∪ ["cast"]) == (stags ∪ ["cast"])
        @test issubset(btags, btags)
        @test issubset(btags, stags)
        @test btags ⊊ (btags ∪ ["cast"])
        @test btags ⊊ (stags ∪ ["cast"])
        @test (btags ∩ ["roll"]) == (stags ∩ ["roll"])
        @test (btags ∪ ["cast"]) ∩ (btags ∪ ["back"]) == btags
        @test (btags ∪ Set(["cast"])) ∩ (stags ∪ ["back"]) == btags
        @test isdisjoint(btags, Tags(btags.names) ∪ ["back"])
        @test isdisjoint(btags, Set(["back", "cast"]))
        @test setdiff(btags ∪ ["cast"], btags ∪ ["back"]) == Set(["cast"])
        @test setdiff(btags ∪ ["cast"], stags ∪ ["back"]) == Set(["cast"])
        @test symdiff(btags ∪ ["cast"], btags ∪ ["back"]) == Set(["cast", "back"])
        @test symdiff(btags ∪ ["cast"], stags ∪ ["back"]) == Set(["cast", "back"])
        if t == 1
            @test string(btags) == "25-element Tag{}"
        elseif t == 2
            @test string(btags) == "25-element Tag{\"run\"}"
        elseif t == 3
            @test string(btags) == "25-element Tag{\"hunch\", \"roll\"}"
        end
    end
end
end

if all_tests || "Chore" in ARGS
@testset "Chore.jl" begin
    @testset "RawOutline" begin
        local data = read_outline(RawOutline, target)
        @test typeof(data) == PlanarLarvae.Runs{RawOutline}
        @test length(data) == 1 && haskey(data, "20150701_105504")
        outline′ = data["20150701_105504"]
        @test length(outline′) == 337 && haskey(outline′, 956)
        outline″ = outline′[956]
        @test length(outline″) == 21
        timestamp, outline‴ = outline″[end]
        @test timestamp == 120.162
        @test outline‴ == flat_outlinef
    end

    @testset "PointSeries" begin
        local data = read_outline(PointSeries{Float64}, target)
        @test typeof(data) == PlanarLarvae.Runs{PointSeries{Float64}}
        i = 0
        for (larva_id, outline′) in pairs(data["20150701_105504"])
            i += 1
            if i == 2
                @test Int(larva_id) == 3
                timestamp, outline″ = outline′[2]
                @test timestamp == 18.069
                v7 = outline″[7]
                x7 = coordinates(v7)[1]
                @test Float64(x7) == 50.375
            end
        end
    end

    @testset "PolyArea" begin
        dataf = read_outline(Outlinef, target)
        @test typeof(dataf) == PlanarLarvae.Runs{Outlinef}
        outline′ = dataf["20150701_105504"]
        outline″ = outline′[956]
        timestamp, outline‴ = outline″[end]
        @test outline‴ == PolyArea(Chain(close_reverse(PlanarLarvae.Path(flat_outlinef))))

        # default global `data`
        @test typeof(data) == PlanarLarvae.Runs{Outline}
        outline′ = data["20150701_105504"]
        outline″ = outline′[956]
        timestamp, outline‴ = outline″[end]
        @test outline‴ == outline
        @test length(collect(eachstate(data))) == 134186
    end

    @testset "Spine" begin
        @test length(data′) == 1 && haskey(data′, "20150701_105504")
        larvae = data′["20150701_105504"]
        @test length(collect(eachstate(larvae))) == 134186
        _, spine′ = larvae[956][end]
        @test vertices(spine′) == vertices(spine)
        @test all(vertices(spine)[2:end]) do p
            p ∈ outline
        end
    end

    @testset "SpineOutline" begin
        @test PlanarLarvae.centroid(spine_outline) == Point(156.959, 120.148)
        outline_target = find_chore_files(target)
        spine_target = find_chore_files(target′)
        common_path_target = find_chore_files(target[1:end-length(".outline")])
        dir_target = find_chore_files(dirname(target))
        @test outline_target == spine_target == common_path_target == dir_target
        data_with_dir_target = read_chore_files(SpineOutline, dirname(target))
        @test PlanarLarvae.Chore.unzip′(data_with_dir_target)[2] == data
        sample_files = joinpath(artifact"chore_sample_output", "chore_sample_output")
        data_as_named_tuples = read_chore_files((:spine=>Spine, :outline=>Outline), sample_files)
        @test map′(SpineOutline, data_as_named_tuples) == data_with_dir_target
        # example from README
        run, larvae = first(data_as_named_tuples)
        larva_id, track = first(larvae)
        timestamp, spine_outline_ = first(track)
        @test typeof(spine_outline_) == NamedTuple{(:spine, :outline), Tuple{Spine, Outline}}
    end
end
end

if all_tests || "Trxmat" in ARGS
@testset "Trxmat.jl" begin
    @test find_trxmat_file(target″) == target″
    data″ = read_trxmat(SpineOutline, target″)
    @test typeof(data″) == PlanarLarvae.Runs{SpineOutline}
    @test length(data″) == 1 && haskey(data″, "20140918_170215")
    data‴ = data″["20140918_170215"]
    t″, spine_outline″ = data‴[813][end]
    spine″ = PlanarLarvae.spine(spine_outline″)
    outline″ = PlanarLarvae.outline(spine_outline″)
    @test vertices(PlanarLarvae.spine(spine_outline″)) == Point2[Point(133.033, 116.376), Point(133.184, 116.268), Point(133.52, 116.188), Point(133.916, 116.038), Point(134.344, 115.843), Point(134.747, 115.685), Point(135.187, 115.5), Point(135.617, 115.368), Point(136.117, 115.25), Point(136.654, 115.155), Point(136.903, 115.051)]
    t‴, outline‴ = read_trxmat(Outline, target″)["20140918_170215"][813][end]
    @test t″ == t‴ && outline″ == outline‴
    @test find_trxmat_file(dirname(target″)) == target″
    data_with_dir_target = read_trxmat(SpineOutline, dirname(target″))
    @test data_with_dir_target == data″
    @test map′(SpineOutline, data_with_tags) == data″
    data_with_selected_tags = read_trxmat((:tags=>Tags([:hunch, :back, :run, :roll, :cast]),), target″)
    # example from README, adapted for sample_trxmat_file_small
    larvastate = first(eachstate(data_with_tags))
    @test string(larvastate.tags) == "25-element Tag{\"run\", \"run_large\", \"run_strong\"}"
end
end

if all_tests || "Datasets" in ARGS
@testset "Datasets.jl" begin
    runid, trackid = "20150701_105504", 512
    json = raw"""
{
  "runs": {
    "20150701_105504": {
      "metadata": {
        "id": "20150701_105504"
      },
      "genotype": "FCF_attP2_1500062",
      "effector": "UAS_Chrimson_Venus_X_0070",
      "protocol": "r_LED50_30s2x15s30s#n#n#n@100",
      "data": [
        {
          "id": "512",
          "t": [
            66.675,
            66.755,
            66.856,
            66.949,
            67.039,
            67.115,
            67.196
          ],
          "labels": [
            "crawl",
            "bend",
            "back",
            "stop",
            "undecided",
            "hunch",
            "roll"
          ]
        }
      ]
    }
  }
}
"""
    labels = PlanarLarvae.Datasets.from_json(json)
    @test length(labels) == 1 && haskey(labels, runid)
    tracks = labels[runid]
    @test length(tracks) == 1 && haskey(tracks, trackid)
    track = tracks[trackid]
    @test length(track[:timestamps]) == 7 && haskey(track, 66.755)
    @test length(track.states) == 1 && haskey(track, :labels)
    @test length(track[:labels]) == 7
    labels′ = Dataset([Run(runid,
                           [Track(trackid,
                                  [66.675, 66.755, 66.856, 66.949, 67.039, 67.115, 67.196],
                                  Dict(:labels=>["crawl", "bend", "back", "stop",
                                                 "undecided", "hunch", "roll"]))];
                           genotype="FCF_attP2_1500062",
                           effector="UAS_Chrimson_Venus_X_0070",
                           protocol="r_LED50_30s2x15s30s#n#n#n@100")])
    show_str = string(labels′)
    # Julia 1.6 specific:
    show_str = replace(show_str, "Vector{T} where T" => "Vector")
    @test show_str * "\n" == """Dataset with 1 run:
Run("20150701_105504") with 1 track
Track(0x0200, OrderedDict{Symbol, Any}(), [66.675, 66.755, 66.856, 66.949, 67.039, 67.115, 67.196], OrderedDict{Symbol, Vector}(:labels => ["crawl", "bend", "back", "stop", "undecided", "hunch", "roll"]))
with metadata: OrderedDict{Symbol, Any} with 3 entries:
  :genotype => "FCF_attP2_1500062"
  :effector => "UAS_Chrimson_Venus_X_0070"
  :protocol => "r_LED50_30s2x15s30s#n#n#n@100"
"""
    @test JSON.write(labels′) == "{\"runs\":{\"20150701_105504\":{\"metadata\":{\"id\":\"20150701_105504\",\"genotype\":\"FCF_attP2_1500062\",\"effector\":\"UAS_Chrimson_Venus_X_0070\",\"protocol\":\"r_LED50_30s2x15s30s#n#n#n@100\"},\"units\":{\"t\":\"s\"},\"data\":[{\"id\":\"512\",\"t\":[66.675,66.755,66.856,66.949,67.039,67.115,67.196],\"labels\":[\"crawl\",\"bend\",\"back\",\"stop\",\"undecided\",\"hunch\",\"roll\"]}]}}}"

    @test labels′[runid][trackid][66.755] == Dict(:labels=>"bend")
    labels′[runid][trackid][66.755] = Dict(:labels=>"crawl")
    @test labels′[runid][trackid][:labels, 66.755] == "crawl"
    labels′[runid][trackid][:labels, 66.755] = "stop"
    @test labels′[runid][trackid][66.755] == Dict(:labels=>"stop")

    run = labels′[runid]
    track = run[trackid]
    @test_throws ArgumentError track[:large] = [false, true]
    track[:large] = [true, true, true, true, false, true, true]
    @test haskey(track, :large) && haskey(track, :labels)
    delete!(track, :labels)
    @test haskey(track, :large) && !haskey(track, :labels)
    @test_throws KeyError labels′[runid][trackid][:labels]
    empty!(track)
    @test isempty(track) && !haskey(track, :large)
    @test_throws KeyError labels′[runid][trackid][:large]
    empty!(run)
    @test !haskey(labels′[runid], trackid) && isempty(labels′[runid])
    @test_throws KeyError run[trackid]
    @test_throws KeyError (run[20] = Track(21))
    run[20] = Track(20)
    run[21] = Track(21)
    @test length(labels′[runid]) == 2
    delete!(run, 20)
    @test length(labels′[runid]) == 1 && haskey(run, 21)
    empty!(labels′)
    @test !haskey(labels′, runid) && isempty(labels′)
    @test_throws KeyError labels′[runid]
    @test_throws KeyError (labels′["foo"] = Run("bar"))
    labels′["foo"] = Run("foo")
    labels′["bar"] = Run("bar")
    delete!(labels′, "foo")
    @test length(labels′) == 1

    filepath = "screens/t15/FCF_attP2_1500062@UAS_Chrimson_Venus_X_0070/r_LED50_30s2x15s30s#n#n#n@100/20150701_105504/Point_dynamics_t15_FCF_attP2_1500062_UAS_Chrimson_Venus_X_0070_r_LED50_30s2x15s30s#n#n#n_larva_id_20150701_105504_larva_number_1.txt"
    metadata = extract_metadata_from_filepath(filepath)
    @test haskey(metadata, :tracker) && metadata[:tracker] == "t15"
    @test haskey(metadata, :genotype) && metadata[:genotype] == "FCF_attP2_1500062"
    @test haskey(metadata, :effector) && metadata[:effector] == "UAS_Chrimson_Venus_X_0070"
    @test haskey(metadata, :protocol) && metadata[:protocol] == "r_LED50_30s2x15s30s#n#n#n@100"
    @test haskey(metadata, :date_time) && metadata[:date_time] == "20150701_105504"

    labels′= Dataset([Run(runid,
                          [Track(trackid,
                                 [66.675, 66.755, 66.856, 66.949, 67.039, 67.115, 67.196],
                                 Dict(:labels=>["crawl","crawl",["crawl","small"],"stop",
                                                ["crawl","small"],["crawl","small"],"crawl",
                                               ]))])])
    labels″= encodelabels(labels′)
    @test haskey(labels″.attributes, :labels)
    @test labels″.attributes[:labels] == ["crawl","small","stop"]
    @test labels″[runid][trackid][:labels] == [1,1,[1,2],3,[1,2],[1,2],1]
    @test decodelabels(labels″, true) == labels′

    labels″[runid].attributes[:labels] = Dict(:names => pop!(labels″.attributes, :labels))
    @test encodelabels(labels″) == labels″
    @test decodelabels(labels″[runid], true) == labels′[runid]
    labels‴ = deepcopy(labels′)
    labels‴[runid].attributes[:labels] = labels″[runid].attributes[:labels]
    @test decodelabels(labels″) == labels‴

    json_file = "test.labels"
    formatted_labels = """
{
   "metadata": {
                  "id": "20150701_105504"
               },
      "units": {
                  "t": "s"
               },
     "labels": {
                  "names": [
                             "crawl",
                             "small",
                             "stop"
                           ]
               },
       "data": [
                 {
                        "id": "512",
                         "t": [66.675,66.755,66.856,66.949,67.039,67.115,67.196],
                    "labels": [1,1,[1,2],3,[1,2],[1,2],1]
                 }
               ]
}"""
    Datasets.to_json_file(json_file, labels″)
    @test read(json_file, String) == formatted_labels
    # add/move attributes (order matters)
    labels‴ = deepcopy(labels″)
    attributes = labels‴[runid].attributes
    #attributes[:metadata] = OrderedDict{Symbol, Any}(:id => runid)
    attributes[:units] = OrderedDict{Symbol, String}(:t => "s")
    attributes[:labels] = pop!(attributes, :labels)
    delete!(labels‴.attributes, :labels)
    #
    @test Datasets.from_json_file(json_file) == labels‴

    labels′[runid][trackid].attributes[:labels] = nothing
    @test_logs (:warn, "Attribute \"labels\" conflicts with record name") JSON.write(labels′)
    delete!(labels′[runid][trackid].attributes, :labels)

    labels′[runid][trackid].attributes[:attr] = labels′[runid][trackid].timestamps
    @test_logs (:warn, "Attribute \"attr\" may be improperly deserialized as a record/timeseries") JSON.write(labels′)
    delete!(labels′[runid][trackid].attributes, :attr)

    labels′[runid][trackid].states[:record] = Float64[]
    @test_logs (:warn, "Record \"record\" does not match timestamps and may be deserialized as an attribute") JSON.write(labels′)
    delete!(labels′[runid][trackid].states, :record)

    labels′[runid].attributes[:data] = nothing
    @test_logs (:warn, "Name \"data\" conflicts with native attribute") JSON.write(labels′)
    delete!(labels′[runid].attributes, :data)

    labels′.attributes[:labels] = ["run", "bend", "back"]
    labels′.attributes[:metadata] = Dict{Symbol, Any}(:expert => "FL")
    try
        rm(runid; recursive=true)
    catch
    end
    Datasets.to_json_file("{}/predicted.labels", labels′; makedirs=true)
    json_file = "$(runid)/predicted.labels"
    @test isdir(runid) && isfile(json_file)
    deserialized = Datasets.from_json_file(Run, json_file)
    @test deserialized isa Run && haskey(deserialized.attributes, :labels)

    timestamps = [66.675, 66.755, 66.856, 66.949, 67.039, 67.115, 67.196]
    labelseries = ["crawl", "bend", "back", "stop", "undecided", "hunch", "roll"]
    labelseries′= fill("other", length(labelseries))
    labels = Run(runid,
                 [Track(trackid-1, timestamps, Dict(:labels=>labelseries′)),
                  Track(trackid, timestamps, Dict(:labels=>labelseries′)),
                  Track(trackid+1, timestamps, Dict(:labels=>labelseries′)),
                 ])
    labels.attributes[:labels] = Dict(:names=>["other"], :colors=>["gray"])
    labels′= Run(runid, [Track(trackid, timestamps, Dict(:labels=>labelseries))])
    labels″= mergelabels!(labels, labels′)
    @test labels″ === labels && length(labels″.tracks) == 3
    @test labels.attributes[:labels] isa Vector{String} && Set(labelseries) ⊆ Set(labels.attributes[:labels]) && "other" ∈ labels.attributes[:labels]
    @test labels[trackid-1][:labels] == labelseries′ && labels[trackid][:labels] == labelseries && labels[trackid+1][:labels] == labelseries′

    labels′[trackid-1] = Track(trackid-1, [timestamps[end]], Dict(:labels=>["crawl"]))
    labels‴= Datasets.expand!(labels′, labels, Dict(:labels=>"new behavior"))
    @test labels‴ === labels′ && length(labels‴.tracks) == 3
    @test labels′.attributes[:labels] == labelseries
    @test labels′[trackid-1] == Track(trackid-1, timestamps,
                                      Dict(:labels=>["new behavior", "new behavior", "new behavior", "new behavior", "new behavior", "new behavior", "crawl"]))
    @test labels′[trackid] == Track(trackid, timestamps, Dict(:labels=>labelseries))
    @test labels′[trackid+1] == Track(trackid+1, timestamps,
                                      Dict(:labels=>["new behavior", "new behavior", "new behavior", "new behavior", "new behavior", "new behavior", "new behavior"]))

    appendlabel!(labels′, "original"; ignore=["new behavior"])
    @test haskey(labels′.attributes, :secondarylabels) && labels′.attributes[:secondarylabels] == ["original"]
    labels″= labels′[trackid-1][:labels]
    @test labels″[end-1] == "new behavior" && labels″[end] == ["crawl", "original"]
    appendlabel!(labels′, "extra"; attrname=:labels, ignore=["original"])
    labels″= labels′[trackid-1][:labels]
    @test labels″[end-1] == ["new behavior", "extra"] && labels″[end] == ["crawl", "original"]

    function define()
        none = String[]
        labels′= Run(runid,
                     [Track(trackid, timestamps, Dict(:labels=>[none, none, none, none, "crawl", none, "new"])),
                      Track(trackid+1, timestamps, Dict(:labels=>[["crawl", "edited"], none, ["turn", "edited"], ["turn", "edited"], none, none, none]))])
        labels′.attributes[:secondarylabels] = ["edited"]
        labels = Run(runid,
                     [Track(trackid, timestamps, Dict(:labels=>["crawl", "crawl", "crawl", "turn", "turn", "turn", "turn"])),
                      Track(trackid+1, timestamps, Dict(:labels=>["crawl", "crawl", "crawl", "crawl", "crawl", "back", "back"]))])
        labels.attributes[:labels] = Dict(:names=>["crawl", "turn", "back"], :colors=>["#ff0000", "#00ff00", "#0000ff"])
        return labels, labels′
    end
    labels, labels′= define()
    labels′.attributes[:secondarylabels] = ["crawl"]
    @test_throws Exception mergelabels!(labels, labels′)
    labels, labels′= define()
    mergelabels!(labels, labels′) do labels
        labels isa Vector && "edited" ∈ labels
    end
    labels′= Run(runid,
                 [Track(trackid, timestamps, Dict(:labels=>["crawl", "crawl", "crawl", "turn", "turn", "turn", "turn"])),
                  Track(trackid+1, timestamps, Dict(:labels=>[["crawl", "edited"], "crawl", ["turn", "edited"], ["turn", "edited"], "crawl", "back", "back"]))])
    #labels′.attributes[:labels] = Dict(:names=>["crawl", "turn", "back"], :colors=>["#ff0000", "#00ff00", "#0000ff"])
    labels′.attributes[:labels] = ["crawl", "turn", "back", "new"]
    labels′.attributes[:secondarylabels] = ["edited"]
    @test labels == labels′

    spine = Dict(:filename => "20150701_105504@FCF_attP2_1500062@UAS_Chrimson_Venus_X_0070@t15@r_LED50_30s2x15s30s#n#n#n@100.spine", :sha1 => "0ab4ba414c03b2644811808674bfa234092f8948")
    outline = Dict(:filename => "20150701_105504@FCF_attP2_1500062@UAS_Chrimson_Venus_X_0070@t15@r_LED50_30s2x15s30s#n#n#n@100.outline", :sha1 => "98f89ac0fca3e0cca667175a1a49ac01d8346ba7")
    dataset = Run(runid)
    dataset.attributes[:dependencies] = [outline]
    dataset′= Run(runid)
    dataset′.attributes[:dependencies] = [outline, spine]
    @test_logs (:warn, "Data dependencies do not fully match") match_mode=:any shareddependencies(dataset, dataset′)
    dataset.attributes[:dependencies] = [spine, outline]
    @test shareddependencies(dataset, dataset′)
    delete!(dataset.attributes, :dependencies)
    @test !shareddependencies(dataset, dataset′)

    dataset = Dataset([Run(runid,
                           [Track(1,
                                  Datasets.Timestamp[56.2, 56.3, 56.4],
                                  :record=>[1, 2, 3]),
                            Track(2,
                                  Datasets.Timestamp[59.8, 60, 60.2, 61.8, 62, 62.2],
                                  :record=>[1, 2, 3, 4, 5, 6])])])
    cropped_dataset = Datasets.segment(dataset, 60, 62)
    cropped_run = first(values(cropped_dataset))
    cropped_track = first(values(cropped_run))
    @test length(cropped_dataset) == 1 && length(cropped_run) == 1
    expected_track = Track(2, Datasets.Timestamp[60, 60.2, 61.8, 62], :record=>[2, 3, 4, 5])
    @test cropped_track == expected_track

end
end


if all_tests || "FIMTrack" in ARGS
@testset "FIMTrack.jl" begin

    csvtable = make_test_data("sample_collision_dataset")
    tracks= read_fimtrack(csvtable)
    @test [track.id for track in tracks] == UInt16[14, 18]
    track = tracks[1]
    @test collect(keys(track.states)) == [:mom, :area, :perimeter, :head, :spinepoint, :tail, :radius, :in_collision]
    @test track.timestamps == 0:113
    spine = track[:spinepoint]
    @test length(spine) == 114 && spine isa Vector{PointSeries{Float32}}
    @test spine[1] == [Point2f(238, 237), Point2f(239, 221), Point2f(237, 206), Point2f(236, 191), Point2f(234, 175)]
    @test track[:in_collision] isa Vector{Bool}

    csvtable = make_test_data("sample_fimtrack_table")
    tracks = read_fimtrack((:spine=>Spine, :outline=>Outline), csvtable; framerate=30)
    @test [track.id for track in tracks] == UInt16.(0:31)
    @test tracks[end-1].timestamps[end] == 1807 / 30
    track = tracks[end]
    @test collect(keys(track.states)) == [:spine, :outline]
    @test track.timestamps == 1735 / 30 : 1 / 30 : 1781 / 30
    spine = track[:spine, 1781 / 30]
    @test spine isa Chain{2,Float64} && spine.vertices == [Point(1061, 50), Point(1054, 49), Point(1048, 49), Point(1042, 48), Point(1040, 45)]

    tracks = read_fimtrack(csvtable)
    track = tracks[1]
    @test collect(keys(track.states)) == [:mom, :mom_dst, :acc_dst, :dst_to_origin, :area, :perimeter, :spine_length, :bending, :head, :spinepoint, :tail, :radius, :is_coiled, :is_well_oriented, :go_phase, :left_bended, :right_bended, :mov_direction, :velocity, :acceleration]
    @test all(ftr -> track[ftr] isa Vector{Bool},
              (:is_coiled, :is_well_oriented, :left_bended, :right_bended))
    @test all(ftr -> track[ftr] isa Vector{Union{Missing, Bool}}, (:go_phase,))

    path = tempname(; cleanup=false) * ".csv"
    write(path,
""",larva(8)
head_x(0),554
head_y(0),536
spinepoint_1_x(0),548
spinepoint_1_y(0),532
spinepoint_2_x(0),548
spinepoint_2_y(0),540
spinepoint_3_x(0),542
spinepoint_3_y(0),548
tail_x(0),540
tail_y(0),548
radius_1(0),2.41648
radius_2(0),1.3656
radius_3(0),0""")
    single_outline = read_fimtrack((:outline=>Outline,), path; radii=[1.7 2 1.7])
    single_outline = single_outline[1][:outline, 0.0]
    _, p1, p2, p3, _, p4, p5, p6 = vertices(single_outline)
    d1 = collect(p6 - p1)
    d2 = collect(p5 - p2)
    d3 = collect(p4 - p3)
    @test round(d1 ⋅ d1; digits=3) == 11.56 &&
          round(d2 ⋅ d2; digits=3) == 16 &&
          round(d3 ⋅ d3; digits=3) == 11.56
    rm(path)

    tracks = read_fimtrack((:spine=>Spine, :outline=>Outline), csvtable; framerate=30, pixelsize=73)
    round′(p) = Point([round(coord; digits=3) for coord in p.coords])
    spine1 = [Point(45.99, 33.799), Point(46.72, 34.675), Point(46.428, 35.77),
              Point(46.647, 36.719), Point(47.377, 37.376)]
    outline1 = [Point(45.99, 33.799), Point(46.984, 34.617), Point(46.821, 35.777),
                Point(46.943, 36.544), Point(47.377, 37.376), Point(46.351, 36.894),
                Point(46.035, 35.763), Point(46.456, 34.733), Point(45.99, 33.799)]
    @test round′.(tracks[1][:spine, 0.0].vertices) == spine1
    @test round′.(tracks[1][:outline, 0.0].outer.vertices) == outline1

end
end

if all_tests || "Formats" in ARGS
@testset "Formats.jl" begin

    larva1 = [(1.0, (; r=1)), (2.0, (; r=2)), (3.0, (; r=3)), (4.0, (; r=4))]
    run1 = OrderedDict([LarvaID(1) => larva1, LarvaID(2) => larva1])
    larva2 = Track(Datasets.TrackID(1), [2.0, 3.0], OrderedDict(:labels=>[:a, :b]))
    run2 = Run("NA", [larva2])
    run2.attributes[:labels] = [:a, :b]

    run3 = appendtags(run1, run2)
    @test collect(keys(run3)) == [LarvaID(1), LarvaID(2)]
    larva3 = run3[LarvaID(1)]
    notags = BehaviorTags([:a, :b], Symbol[])
    taga = BehaviorTags([:a, :b], [:a])
    tagb = BehaviorTags([:a, :b], [:b])
    larva4 = [(1.0, (r=1, tags=notags)),
              (2.0, (r=2, tags=taga)),
              (3.0, (r=3, tags=tagb)),
              (4.0, (r=4, tags=notags))]
    @test larva3 == larva4
    larva3′= run3[LarvaID(2)]
    larva4′= [(1.0, (r=1, tags=notags)),
              (2.0, (r=2, tags=notags)),
              (3.0, (r=3, tags=notags)),
              (4.0, (r=4, tags=notags))]
    @test larva3′== larva4′

    chore = load(make_test_data("chore_auto_dependency"))
    run = getrun(chore)
    @test run.id == "20140918_170215"
    metadata = getmetadata(chore)
    @test metadata[:genotype] == "GMR_SS02113"
    @test metadata[:effector] == "UAS_Chrimson_Venus_X_0070"
    @test metadata[:tracker] == "t15"
    @test metadata[:protocol] == "r_LED100_30s2x15s30s#n#n#n"
    larvaids = UInt16[0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0008, 0x0009, 0x000a, 0x000b, 0x000d, 0x000f, 0x0010, 0x0011, 0x0014, 0x0015, 0x0016, 0x0018, 0x001a, 0x001b, 0x001c, 0x0021, 0x0026, 0x0027, 0x0028, 0x002c, 0x002e, 0x003a, 0x0045, 0x0053, 0x0069, 0x006f, 0x0082, 0x00b1, 0x0125, 0x012a, 0x012e, 0x0146, 0x01e9, 0x01ea, 0x01f9, 0x02cb, 0x031a, 0x032d, 0x0342, 0x0343]
    @test collect(keys(run.tracks)) == larvaids
    @test isempty(getlabels(chore)[:names])

    trxmat = load(make_test_data("trxmat_exported_dependency"))
    @test getrun(trxmat).id == "20140918_170215"
    alltags = [:back, :back_large, :back_strong, :back_weak, :cast, :cast_large, :cast_strong, :cast_weak, :hunch, :hunch_large, :hunch_strong, :hunch_weak, :roll, :roll_large, :roll_strong, :roll_weak, :run, :run_large, :run_strong, :run_weak, :small_motion, :stop, :stop_large, :stop_strong, :stop_weak]
    @test Set(getlabels(trxmat)[:names]) == Set(alltags)
    larvaids = UInt16[0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0008, 0x0009, 0x000a, 0x000b, 0x000d, 0x000f, 0x0011, 0x0014, 0x0015, 0x0016, 0x0018, 0x001a, 0x001b, 0x0021, 0x0026, 0x0027, 0x0028, 0x002c, 0x002e, 0x003a, 0x0082, 0x012e, 0x01e9, 0x01f9, 0x032d]
    @test collect(keys(getrun(trxmat).tracks)) == larvaids

    include("formats.jl")
    include("formats_legacy.jl")

    for file in ("chore_auto", "trxmat_exported", "fimtrack_manual")

        file = make_test_data("$(file)_labels")
        ret_legacy = loadfile_legacy(file)
        ret = loadfile(file)
        for (track, track_legacy) in zip(ret[:tracks], ret_legacy[:tracks])
            ids_equal = track.id == track_legacy.id
            alignedsteps_equal = track.alignedsteps == track_legacy.alignedsteps
            paths_equal = track.path == track_legacy.path
            fullstates_equal = track.fullstates == track_legacy.fullstates
            @test ids_equal && alignedsteps_equal && paths_equal && fullstates_equal
        end
        @test ret[:timestamps] == ret_legacy[:timestamps]
        @test ret[:tags] == ret_legacy[:tags]
        @test ret[:tagcolors] == ret_legacy[:tagcolors]
        @test ret[:output] == ret_legacy[:output]

    end

    anyfile = make_test_data("chore_auto_labels")
    dir = dirname(anyfile)
    @test Set([basename(f.source) for f in labelledfiles(dir)]) == Set(["chore_auto.labels", "fimtrack_manual.labels", "trxmat_exported.labels"])
    testfile1 = joinpath(dir, "empty_test_file.json")
    testfile2 = joinpath(dir, "copy.json")
    Base.Filesystem.touch(testfile1)
    Base.Filesystem.cp(anyfile, testfile2; force=true)
    files = @test_logs (:info, "Multiple label files for a same data dependency") match_mode=:any labelledfiles(dir)
    @test Set([basename(f.source) for f in files]) == Set(["copy.json", "fimtrack_manual.labels", "trxmat_exported.labels"])
    for tmp in (testfile1, testfile2)
        Base.Filesystem.rm(tmp)
    end

    @test Formats.from_mwt(preload(make_test_data("chore_auto_labels")))
    @test Formats.from_mwt(preload(make_test_data("trxmat_exported_labels")))
    @test !Formats.from_mwt(preload(make_test_data("fimtrack_manual_labels")))

    path = tempname(; cleanup=false) * ".csv"
    write(path,
""",larva(8)
head_x(0),554
head_y(0),536
spinepoint_1_x(0),548
spinepoint_1_y(0),532
spinepoint_2_x(0),548
spinepoint_2_y(0),540
spinepoint_3_x(0),542
spinepoint_3_y(0),548
tail_x(0),540
tail_y(0),548
radius_1(0),2.41648
radius_2(0),1.3656
radius_3(0),0""")
    camera = Dict{String, Any}("framerate" => 1)
    overrides = Dict{String, Any}("radius_1" => 1.7, "radius_2" => 2, "radius_3" => 1.7)
    metadata = Dict{Symbol, Any}(:camera => camera, :overrides => overrides)
    single_outline = load(path; metadata=metadata)
    single_outline = single_outline.run[8][:outline, 0.0]
    _, p1, p2, p3, _, p4, p5, p6 = vertices(single_outline)
    d1 = collect(p6 - p1)
    d2 = collect(p5 - p2)
    d3 = collect(p4 - p3)
    @test round(d1 ⋅ d1; digits=3) == 11.56 &&
          round(d2 ⋅ d2; digits=3) == 16 &&
          round(d3 ⋅ d3; digits=3) == 11.56

    camera["pixelsize"] = 73
    single_outline = load(path; metadata=metadata)
    single_outline = single_outline.run[8][:outline, 0.0]
    round′(p) = Point([round(coord; digits=3) for coord in p.coords])
    outline1 = [Point(554.0, 536.0), Point(548.802, 533.499), Point(549.897, 540.632),
                Point(542.76, 549.521), Point(540.0, 548.0), Point(541.24, 546.479),
                Point(546.103, 539.368), Point(547.198, 530.501), Point(554.0, 536.0)]
    @test round′.(single_outline.outer.vertices) == outline1

    rm(path)

    file = load(make_test_data("fimtrack_manual_labels"); framerate=30)
    @assert file.run.attributes[:labels][:names] == ["collision", "run", "bend", "stop"] && collect(keys(file.run)) == UInt16[0x0006, 0x0003, 0x0002]
    setdefaultlabel!(file, "new behavior")
    @test file.run.attributes[:labels] == ["collision", "run", "bend", "stop", "new behavior"]
    @test collect(keys(file.run)) == UInt16[0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0007, 0x0008, 0x0009, 0x000a, 0x000b, 0x000c, 0x000d, 0x000e, 0x000f, 0x0010, 0x0011, 0x0012, 0x0013, 0x0014, 0x0015, 0x0016, 0x0017, 0x0018, 0x0019, 0x001a, 0x001b, 0x001c, 0x001d, 0x001e, 0x001f]
    @test all(label -> label == "new behavior", file.run[0x0000][:labels])

    labelfile = make_test_data("chore_auto_labels")
    spinefile = joinpath(dirname(labelfile),
                         "20140918_170215@GMR_SS02113@UAS_Chrimson_Venus_X_0070@t15@r_LED100_30s2x15s30s#n#n#n@100.spine")
    spinefile, labelfile = preload(spinefile), preload(labelfile)
    files = find_associated_files(spinefile)
    @test length(files) == 2 && files[1] === spinefile
    @test endswith(files[2].source, ".outline")
    files = find_associated_files(labelfile)
    @test length(files) == 3 && files[1] === labelfile
    @test splitext(files[2].source)[2] in (".spine", ".outline")
    @test splitext(files[3].source)[2] in (".spine", ".outline")

end
end

if all_tests || "Features" in ARGS
@testset "Features.jl" begin

    spine = [Point2(0, 0), Point2(.25, .25), Point2(.5, .5), Point2(.75, .75), Point2(1, 1)]
    @test bodylength(spine) == sqrt(2)
    @test medianbodylength([[(0.0, (; spine=Spine(spine)))]]) == sqrt(2)
    @test all(normalize_spines([coordinates.(spine)], sqrt(2) / 2) .- Float64[-1 0 -.5 0 0 0 .5 0 1 0]) do x
        x * x < 1e-16
    end
    @test Point.(spine5([Point2(0, 0), Point2(.1, .1), Point2(.2, .2), Point2(.3, .3), Point2(.4, .4), Point2(.5, .5), Point2(.6, .6), Point2(.7, .7), Point2(.8, .8), Point2(.9, .9), Point2(1, 1)])) == spine

end
end

if all_tests || "MWT" in ARGS
@testset "MWT.jl" begin

    spine_tag_data = read_trxmat((:spine=>Spine, :tags=>BehaviorTags),
                                 artifact"sample_trxmat_file_small")

    #t0 = 0.032
    #@test round(timegridstart(spine_tag_data), digits=14) == t0
    #track = spine_tag_data["20140918_170215"][0x014]
    #alignedsteps, framedrops = aligntimesteps(track, astuple=true)
    #@test all(x -> trunc(x - round(x), digits=12) == 0, alignedsteps ./ 0.04)
    #reconstructed_data = Features.recover_dropped_frames([PlanarLarvae.spine(state) for (_, state) in track], framedrops)
    #@test length(reconstructed_data) == round(Int, (alignedsteps[end] - alignedsteps[1]) / 0.04) + 1
    #fixed_run = fixmwtdata(spine_tag_data["20140918_170215"])
    #spine_tag_data′= Formats.asrun("20140918_170215", spine_tag_data["20140918_170215"])
    #fixed_run′= fixmwtdata(spine_tag_data′)
    #@test fixed_run == Formats.astimeseries(fixed_run′)

    track = spine_tag_data["20140918_170215"][0x014]
    anchor_time, frame = track[20]
    interpolated_track = fixmwtdata(track; anchor_time=anchor_time, nframes=30)
    @test PlanarLarvae.times(interpolated_track) == 28.183:.04:29.343
    @test interpolated_track[16] == track[20]

    # end of timeseries that caused a numerical precision bug in equivalent Python code
    # (LarvaTagger.jl#65)
    breaking_timeseries = [157.256, 157.339, 157.426, 157.504, 157.584, 157.668, 157.746, 157.822, 157.918, 157.999, 158.081, 158.161, 158.244, 158.322, 158.414, 158.491, 158.577, 158.654, 158.728, 158.823, 158.89, 158.982, 159.066, 159.155, 159.23, 159.314]
    breaking_timeseries = collect(zip(breaking_timeseries, breaking_timeseries))
    # the expression below was expected to break, but actually did not; because the bug did
    # not affect the Julia code:
    fixmwtdata(breaking_timeseries;
               anchor_time=158.414, frame_interval=0.1, nframes=20)

end
end

if all_tests || "Dataloaders" in ARGS
@testset "Dataloaders.jl" begin

    dataset = joinpath(artifact"sample_training_dataset", "sample_training_dataset")
    repo1 = Repository(dataset)
    @test all(file -> basename(file.source) == "groundtruth.label", Dataloaders.files(repo1))
    window1 = TimeWindow(2, 10)
    index1 = ratiobasedsampling(["roll", "¬roll"], 1)
    loader1 = DataLoader(repo1, window1, index1)
    buildindex(loader1; verbose=false)
    @test length(index1.maxcounts) == length(index1.targetcounts) == length(repo1) == 4
    @test Dataloaders.total(index1.maxcounts) == Dict(["stop", "stop_large", "stop_strong"] => 1587, ["cast", "cast_weak", "small_motion"] => 5126, ["back", "back_weak", "small_motion"] => 750, ["run", "run_weak", "small_motion"] => 6573, ["cast", "cast_large", "cast_strong"] => 55595, ["back", "back_large", "back_strong"] => 3270, ["small_motion", "stop", "stop_weak"] => 431, ["roll", "roll_large", "roll_strong"] => 52, ["hunch", "hunch_weak", "small_motion"] => 67, ["hunch", "hunch_large", "hunch_strong"] => 71, ["run", "run_large", "run_strong"] => 140927, ["roll", "roll_weak", "small_motion"] => 7)
    @test Dataloaders.total(index1.targetcounts) == Dict(["stop", "stop_large", "stop_strong"] => 0, ["cast", "cast_weak", "small_motion"] => 0, ["back", "back_weak", "small_motion"] => 0, ["run", "run_weak", "small_motion"] => 2, ["cast", "cast_large", "cast_strong"] => 16, ["back", "back_large", "back_strong"] => 0, ["small_motion", "stop", "stop_weak"] => 0, ["roll", "roll_large", "roll_strong"] => 52, ["hunch", "hunch_weak", "small_motion"] => 0, ["hunch", "hunch_large", "hunch_strong"] => 0, ["run", "run_large", "run_strong"] => 40, ["roll", "roll_weak", "small_motion"] => 7)
    Dataloaders.sample(loader1, :tags; verbose=false) do i, _, _, segments
        @test length(segments) == [17, 27, 21, 52][i]
    end
    repo2 = Repository(joinpath(dataset, "**.label"))
    window2 = TimeWindow(5, 10; maggotuba_compatibility=true)
    index2 = ratiobasedsampling(["run", "cast", "stop", "back", "hunch"], 2,
                                prioritylabel("small_motion"; verbose=false))
    loader2 = DataLoader(repo2, window2, index2)
    buildindex(loader2; unload=true, verbose=false)
    @test length(index2.maxcounts) == length(index2.targetcounts) == length(repo2) == 4
    @test Dataloaders.total(index2.maxcounts) == Dict(["stop", "stop_large", "stop_strong"] => 1213, ["cast", "cast_weak", "small_motion"] => 4151, ["back", "back_weak", "small_motion"] => 601, ["run", "run_weak", "small_motion"] => 5189, ["cast", "cast_large", "cast_strong"] => 44140, ["back", "back_large", "back_strong"] => 2816, ["small_motion", "stop", "stop_weak"] => 354, ["roll", "roll_large", "roll_strong"] => 10, ["hunch", "hunch_weak", "small_motion"] => 50, ["hunch", "hunch_large", "hunch_strong"] => 50, ["run", "run_large", "run_strong"] => 112655)
    @test Dataloaders.total(index2.targetcounts) == Dict(["stop", "stop_large", "stop_strong"] => 0, ["cast", "cast_weak", "small_motion"] => 200, ["back", "back_weak", "small_motion"] => 200, ["run", "run_weak", "small_motion"] => 200, ["cast", "cast_large", "cast_strong"] => 0, ["back", "back_large", "back_strong"] => 0, ["small_motion", "stop", "stop_weak"] => 200, ["roll", "roll_large", "roll_strong"] => 0, ["hunch", "hunch_weak", "small_motion"] => 50, ["hunch", "hunch_large", "hunch_strong"] => 50, ["run", "run_large", "run_strong"] => 0)
    Dataloaders.sample(loader2, :tags; verbose=false) do i, _, _, segments
        @test length(segments) == [251, 234, 198, 217][i]
    end
    repo3 = Repository(joinpath(dataset, "**", "g.*"))
    @test Dataloaders.filepaths(repo3) == Dataloaders.filepaths(repo2)

end
end
