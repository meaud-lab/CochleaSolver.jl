using DifferentialEquations
"""
    solver_alg(d::Dict)

Switch to determine which algorithm to use for the ode solver. Default is RadauIIA5.
"""
function solver_alg(d::Dict)
    if "ODE_SOLVER" ∈ keys(d)
        solver = d["ODE_SOLVER"]
    else
        solver = "default"
    end

    ## MATLAB translations
    if solver == "ode23" #no mass_matrix
        solver = "ode23/BS3"
        solverfun = BS3()
    elseif solver == "ode45" #no mass_matrix
        solver = "ode45/DP5"
        solverfun = DP5()
    elseif solver == "ode23s"
        solver = "ode23s/Rosenbrock23"
        solverfun = Rosenbrock23(autodiff=false)
    elseif solver == "ode113" #no mass_matrix
        solver = "ode113/VCABM"
        solverfun = VCABM()
    elseif solver == "ode15s"
        solver = "ode15s/QNDF"
        solverfun = QNDF(autodiff=false)
    elseif solver == "ode23t"
        solver = "ode23t/Trapezoid"
        solverfun = Trapezoid(autodiff=false)
    elseif solver == "ode23tb" #no mass_matrix
        solver = "ode23tb/TRBDF2"
        solverfun = TRBDF2()
    elseif solver == "ode15i" #no mass_matrix
        solver = "ode15i/DFBDF"
        solverfun = DFBDF()

        ## Julia-specific algs
    elseif solver == "RadauIIA5"
        @warn "RadauIIA5 chosen; may be inaccurate for some simulations"
        solverfun = RadauIIA5(autodiff=false)
    elseif solver == "Rosenbrock23"
        solverfun = Rosenbrock23(autodiff=false)
    elseif solver == "Tsit5" #no mass_matrix
        solverfun = Tsit5()
    elseif solver == "ORK256" #no mass_matrix
        solverfun = ORK256()
    elseif solver == "Rodas4"
        solverfun = Rodas4(autodiff=false)
    elseif solver == "Vern7" #no mass_matrix
        solverfun = Vern7()
    elseif solver == "KenCarp4" #no mass_matrix
        solverfun = KenCarp4()
    elseif solver == "TRBDF2"
        solverfun = TRBDF2(autodiff=false)
    else #Default
        @warn "Default alg chosen"
        @warn "RadauIIA5 chosen; may be inaccurate for some simulations"
        solver = "RadauIIA5"
        solverfun = RadauIIA5(autodiff=false)
    end

    @info "using $solver solver"
    return solverfun
end