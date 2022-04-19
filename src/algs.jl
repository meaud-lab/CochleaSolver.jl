using DifferentialEquations
"""
    solver_alg(d::Dict)

Switch to determine which algorithm to use for the ode solver. Default is RadauIIA5.
"""
function solver_alg(d::Dict)
    solver = d["ODE_SOLVER"]
    ## MATLAB translations
    if solver == "ode23"
        return BS3()
    elseif solver == "ode45"
        return DP5()
    elseif solver == "ode23s"
        return Rosenbrock23(autodiff=false)
    elseif solver == "ode113"
        return VCABM()
    elseif solver == "ode15s"
        return QNDF()
    elseif solver == "ode23t"
        return Trapezoid()
    elseif solver == "ode23tb"
        return TRBDF2()
    elseif solver == "ode15i"
        return IDA()

        ## Julia-specific algs
    elseif solver == "RadauIIA5"
        @warn "RadauIIA5 chosen; may be inaccurate for some simulations"
        return RadauIIA5(autodiff=false)
    elseif solver == "Rosenbrock23"
        return Rosenbrock23(autodiff=false)
    elseif solver == "Tsit5"
        return Tsit5()
    elseif solver == "ORK256"
        return ORK256()
    elseif solver == "Rodas4"
        return Rodas4()
    elseif solver == "Vern7"
        return Vern7()
    elseif solver == "KenCarp4"
        return KenCarp4(autodiff=false)
    elseif solver == "TRBDF2"
        return TRBDF2(autodiff=false)
    else #Default
        @warn "Default alg chosen"
        @warn "RadauIIA5 chosen; may be inaccurate for some simulations"
        return RadauIIA5(autodiff=false)
    end
end