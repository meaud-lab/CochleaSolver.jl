using CochleaSolver
using Test
using LazyArtifacts
using Pkg.Artifacts
using MAT: matread

function safe_rm(file; force=false)
    # work-around for JuliaLang/julia#29658 JuliaLang/julia#39457
    if Sys.iswindows()
        t = Timer(10)
        while true
            try
                rm(file, force=force)
                break
            catch err
                err isa Base.IOError || rethrow()
                if isopen(t)
                    @error "rm failed. Retrying" ex = err
                    GC.gc()
                else
                    rethrow()
                end
                sleep(1)
            end
        end
    else
        rm(file, force=force)
    end
end

@testset "CochleaSolver.jl" begin
    @testset "excitation/" begin
        @testset "raisedsine.jl" begin
            ndof = rand(3000:50000, 1)[1]
            t = abs(randn())
            dict = Dict(
                "omega" => abs(randn()) * 100e3 * π,
                "v" => rand(ComplexF64, ndof),
                "Force_correction" => randn(),
                "tR" => t,
                "tOn" => abs(randn()) + t
            )
            testparams = RaisedSineParams(dict)

            #dummy check fields
            @test testparams isa RaisedSineParams
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
            @test all(raisedsine!(testv, testparams, -rand(Float64, 1)[1]) .== 0)
        end

        @testset "click.jl" begin
            ndof = rand(3000:50000, 1)[1]
            v = rand(ComplexF64, ndof)
            t = abs(randn())
            dict = Dict(
                "v" => v,
                "Timpulse" => t
            )
            testparams = ClickParams(dict)

            @test testparams isa ClickParams
            @test testparams.Timpulse == t

            testv = Vector{Float64}(undef, ndof)
            @test all(click!(testv, testparams, -0.1) .== 0)
            @test all(click!(testv, testparams, 0) .== v)
            @test all(click!(testv, testparams, t / 2) .== v)
            @test all(click!(testv, testparams, t) .== 0)
            @test all(click!(testv, testparams, t * 2) .== 0)
        end

        @testset "gaussianenvelope" begin
            ndof = rand(3000:50000, 1)[1]
            v = rand(ComplexF64, ndof)
            F0 = rand(ComplexF64, ndof)
            t = abs(randn())
            σ = abs(randn())
            dict = Dict(
                "typeLoading" => 4,
                "v" => v,
                "t0_GaussEnv" => t,
                "sigma_GaussEnv" => σ,
                "F0" => F0
            )
            testparams = GaussianEnvelopeParams(dict)

            @test testparams isa GaussianEnvelopeParams
            testv = Vector{ComplexF64}(undef, ndof)
            @test all(gaussianenv!(testv, testparams, 0.0) .== v)
        end

        @testset "sine" begin
            ndof = rand(3000:50000, 1)[1]
            v = rand(ComplexF64, ndof)
            dict = Dict(
                "v" => v,
                "Force_correction" => randn(),
                "Nperiod" => rand(1:100),
                "omega" => rand(1:25e3)
            )

            testparams = SineParams(dict)
            tOff = testparams.tOff

            @test testparams isa SineParams
            testv = Vector{ComplexF64}(undef, ndof)
            @test all(sine!(testv, testparams, -1.0) .== 0)
            @test all(sine!(testv, testparams, tOff + 1.0) .== 0)
        end

        @testset "toneburst" begin
            ndof = rand(3000:50000, 1)[1]
            v = rand(ComplexF64, ndof)
            dict = Dict(
                "v" => v,
                "Force_correction" => randn(),
                "tR" => rand(1:100),
                "T_Stimulus" => rand(1:100),
                "omega" => rand(1:25e3)
            )

            testparams = ToneBurstParams(dict)

            @test testparams isa ToneBurstParams
            testv = Vector{ComplexF64}(undef, ndof)
            @test all(toneburst!(testv, testparams, -1.0) .== 0)
            @test all(toneburst!(testv, testparams, testparams.T_Stimulus + 1.0) .== 0)
        end

        @testset "twotone" begin
            ndof = rand(3000:50000)
            v = rand(ComplexF64, ndof)
            dict = Dict(
                "v" => v,
                "Force_correction" => rand(2),
                "tR" => rand(1:100),
                "tOn" => rand(1:100),
                "omega1" => rand(1:25e3),
                "omega2" => rand(1:25e3)
            )

            testparams = TwoToneParams(dict)

            @test testparams isa TwoToneParams
            testv = Vector{ComplexF64}(undef, ndof)
            @test all(twotone!(testv, testparams, -1.0) .== 0)
            @test all(twotone!(testv, testparams, testparams.tOn + 1.0) .== 0)
        end
    end

    @testset "Full Model Tests" begin
        @testset "Pure Tone" begin
            art_dir = input_file = expected_out = nothing
            try
                @test isdir(ensure_artifact_installed("Pure_Tone", "../Artifacts.toml"))
                art_dir = joinpath(artifact"Pure_Tone", "Pure Tone")
                input_file = joinpath(art_dir, "IN_FullMesh_PT_F0_20kHz.mat")
                expected_out = matread(joinpath(art_dir, "OUT_FullMesh_PT_F0_20kHz.mat"))
            catch
                @error "Unable to load Pure Tone Artifact. All further Pure Tone tests are expected to fail."
            end

            @time @test solve_cochlea(input_file) == 0
            @test isfile("julia_solver.log")
            @test isfile("julia_soln.mat")

            soln = try
                matread("julia_soln.mat")
            catch
                @error "Unable to read Pure Tone output file."
            end

            @test soln["T"] ≈ expected_out["T"]

            safe_rm("julia_soln.mat", force=true)
            safe_rm("julia_solver.log", force=true)
        end
    end
end