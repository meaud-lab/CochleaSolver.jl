using MAT
using DifferentialEquations
using Statistics
using LinearAlgebra

struct ExcitationParams{T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12}
    N::Int64
    nMechTotal::Int64
    nElecTotal::Int64
    elecLongCoupling::Int64
    electricalModel::Int64
    A1::T1
    A2::T2
    dCe::T3
    Y_HB::T4
    B0::T5
    X0::T6
    deltaX::T7
    q::T8
    IhbNLFactor::T9
    Y_FesNL::T10
    P0::T11
    withMassMatrix::Bool #TODO is this hard-coded into solver?!
    Nl::Int64
    excitation::T12 #Julia type
    ny0::Int64
    nuHB::Int64
end

function ExcitationParams(input::Dict)
    excitation = Excitation(input)
    Nl = 4 #number of Gaussian integration points
    #deconstruct stuff here
    N = Int(input["N"])
    nMechTotal = Int64(input["nMechTotal"])
    nElecTotal = Int64(input["nElecTotal"])
    elecLongCoupling = Int64(input["elecLongCoupling"])
    electricalModel = Int64(input["electricalModel"])
    A1 = input["A1"]
    A2 = input["A2"]
    dCe = input["Ce"]
    Y_HB = input["Y_HB"]
    B0 = input["B0"]
    X0 = input["X0"]
    deltaX = input["deltaX"]
    q = input["q"]
    IhbNLFactor = input["IhbNLFactor"]
    Y_FesNL = input["Y_FesNL"]
    P0 = input["P0"]
    withMassMatrix = input["withMassMatrix"]
    return ExcitationParams(N, nMechTotal, nElecTotal, elecLongCoupling, electricalModel, A1, A2, dCe, Y_HB, B0, X0, deltaX, q, IhbNLFactor, Y_FesNL, P0, withMassMatrix, Nl, excitation, length(input["y0"]), size(Y_HB[1], 1))
end



function solve_cochlea(file)
    # if length(ARGS) > 0 && isfile(ARGS[1])
    #     file = ARGS[1]
    # else
    #     @error "Provide input .MAT file as cmd line arg!"
    #     # showhelp() #TODO
    # end

    matdata = matread(file)

    prob = build_problem(matdata)
    alg = solver_alg(matdata)

    options = matdata["options"]
    rtol = options["RelTol"]
    atol = options["AbsTol"]
    jpattern = options["JPattern"]

    soltime = @elapsed sol = solve(
        prob,
        alg,
        progress=true,
        reltol=rtol,
        abstol=atol,
        jac_prototype=jpattern,
        save_everystep=false
    )

    #save
    if "JuliaOutFilename" ∈ keys(matdata)
        outputfile = matdata["JuliaOutFilename"]
    else
        outputfile = "julia_soln.mat"
    end

    matopen(outputfile, "w") do file
        write(file, "Y", sol.u)
        write(file, "T", sol.t)
        write(file, "soltime", soltime)
    end
    return 0
end



function build_problem(d::Dict)
    params = ExcitationParams(d)
    fun! = dxFENonLinearVector3!

    odefun = ODEFunction(fun!, mass_matrix=d["options"]["Mass"])

    tspan = (d["tspan"][1], d["tspan"][end])
    problem = ODEProblem{true}(odefun, d["y0"], tspan, params, saveat=d["tspan"])
    return problem
end


function dxFENonLinearVector3!(dxdt, x, p, t)
    dispX = @view x[p.nMechTotal+1:2*p.nMechTotal]
    FesNL = zeros(p.nElecTotal, 1)

    uHB = Vector{Float64}(undef, p.nuHB)
    @inbounds for l = 1:p.Nl
        mul!(uHB, p.Y_HB[l], dispX)

        # Compute MET current
        Ihb = zeros(p.N - 1, 1)
        boolBigHB = abs2.(uHB) .> 1e-44
        Ihb[boolBigHB] = p.B0[boolBigHB, l] .* (1 ./ (1 .+ exp.(-(uHB[boolBigHB] .- p.X0[boolBigHB, l]) ./ p.deltaX[boolBigHB, l])) .- p.P0) .- p.q[boolBigHB, l] .* uHB[boolBigHB]
        Ihb .*= p.IhbNLFactor[:, l]

        # Compute nonlinear force vector
        FesNL .+= p.Y_FesNL[l] * Ihb

    end # end gauss

    dxdt[1:p.nMechTotal] = p.A1 * x

    dxdt[p.nMechTotal+1:2*p.nMechTotal] = x[1:p.nMechTotal]
    if (p.elecLongCoupling == 1 && any(p.electricalModel ∈ [2, 3])) || p.withMassMatrix
        dxdt[2*p.nMechTotal+1:2*p.nMechTotal+p.nElecTotal] = (p.A2 * x .- FesNL)
    else
        dxdt[2*p.nMechTotal+1:2*p.nMechTotal+p.nElecTotal] = p.dCe \ (A2 * x .- FesNL)
    end

    dxdt .+= p.excitation.stimulus!(Vector{Float64}(undef, p.ny0), p.excitation.stimulus_parameters, t)
end