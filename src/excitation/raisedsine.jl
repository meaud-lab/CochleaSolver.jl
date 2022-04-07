struct RaisedSineParams{T1,T2,T3,T4,T5,T6}
    omega::T1
    mag::T2
    phi::T3
    tR::T4
    tOn::T5
    t0::T6
    function RaisedSineParams(omega::T1, mag::T2, phi::T3, tR::T4, tOn::T5) where {T1,T2,T3,T4,T5}
        t0 = tOn - tR
        return new{T1,T2,T3,T4,T5,typeof(t0)}(omega, mag, phi, tR, tOn, t0)
    end
end

function RaisedSineParams(d::Dict)
    omega = d["omega"]
    mag = abs.(d["v"] .* d["Force_correction"])
    phi = angle.(d["v"] .* d["Force_correction"])
    tR = d["tR"]
    tOn = d["tOn"]
    return RaisedSineParams(omega, mag, phi, tR, tOn)
end

"""
    raisedsine!(V,t, )

    Computes raised sine excitation for state space vector V at time t
"""
function raisedsine!(V, p, t)
    if t < 0
        V .= zero(V)
    elseif t < p.tR
        V = p.mag .* sin.(p.omega .* t .+ p.phi) * (1 .+ cos.(π .* (t .- p.tR) ./ p.tR)) ./ 2
    elseif t < p.t0
        V = p.mag .* sin.(p.omega .* t .+ p.phi)
    elseif t < p.tOn
        V = p.mag .* sin.(p.omega .* t .+ p.phi) * (1 .+ cos.(π .* (t .- p.t0) ./ p.tR)) ./ 2
    else
        V .= zero(V)
    end
end
