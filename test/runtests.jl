using CochleaSolver
using Test

# @testset "CochleaSolver.jl" begin
@testset "excitation/" begin
    @testset "raisedsine.jl" begin
        ndof = rand(3000:50000, 1)[1]
        t = rand(Float64, 1)[1]
        dict = Dict(
            "omega" => rand(1)[1] * 100e3 * π,
            "v" => rand(ComplexF64, ndof),
            "Force_correction" => rand(Float64, 1)[1],
            "tR" => t,
            "tOn" => rand(Float64, 1)[1] + t
        )
        testparams = RaisedSineParams(dict)

        #dummy check fields
        @test testparams.omega == dict["omega"]
        @test testparams.tR == dict["tR"]
        @test testparams.tOn == dict["tOn"]
        @test testparams.t0 == dict["tOn"] - dict["tR"]
        @test testparams.t0 >= 0 #probably a problem with random param generation

        # test mag/phase generation
        v = dict["v"] .* dict["Force_correction"]
        @test testparams.mag == abs.(v)
        @test testparams.phi == angle.(v)


        testv = Vector{Float64}(undef, ndof)
        #t<0
        @test all(raisedSine!(testv, testparams, -rand(Float64, 1)[1]) .== 0)

    end
end
