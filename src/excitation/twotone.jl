struct TwoToneParams{T1,T2,T3,T4,T5,T6,T7}
    omega::T1
    mag::T2
    phi::T3
    force::T4
    tR::T5
    tOn::T6
    t0::T7
    function TwoToneParams(omega::T1, mag::T2, phi::T3, force::T4, tR::T5, tOn::T6) where {T1,T2,T3,T4,T5,T6}
        t0 = tOn - tR
        return new{T1,T2,T3,T4,T5,T6,typeof(t0)}(omega, mag, phi, force, tR, tOn, t0)
    end
end

function TwoToneParams(d::Dict)
    force = Vector(undef, 2) #TODO: specify type
    force[1] = d["v"] .* d["Force_correction"][1]
    force[2] = d["v"] .* d["Force_correction"][2]
    mag = map(x -> abs.(x), force)
    phi = map(x -> angle.(x), force)
    omega = [d["omega1"], d["omega2"]]
    if ~(d["tR"] < (d["tOn"] - d["tR"]) < d["tOn"])
        @warn "Something looks off with your time parameters" d["tOn"] d["tR"]
    end
    return TwoToneParams(omega, mag, phi, force, d["tR"], d["tOn"])
end

function twotone!(V, p, t)
    if t < 0
        V = zero(V)
    elseif t < p.tR
        V = @. sin(p.omega[1] * t + p.phi[1]) * (1 + cos(π * (t / p.tR - 1))) / 2 * p.mag[1] #V1
        @. V += sin(p.omega[2] * t + p.phi[2]) * (1 + cos.(π * (t / p.tR - 1))) / 2 * p.mag[2] #V2
    elseif t < p.t0
        V = @. sin(p.omega[1] * t + p.phi[1]) * p.mag[1]
        @. V += sin(p.omega[2] * t + p.phi[2]) * p.mag[2]
    elseif t < p.tOn
        V = @. sin(p.omega[1] * t + p.phi[1]) * (1 + cos(π * (t - p.t0) / p.tR)) / 2 * p.mag[1] #V1
        @. V += sin(p.omega[2] * t + p.phi[2]) * (1 + cos.(π * (t - p.t0) / p.tR)) / 2 * p.mag[2] #V2
    else
        V = zero(V)
    end
end

twotonesuppression!(V, t, p) = twotone!(V, t, p)
