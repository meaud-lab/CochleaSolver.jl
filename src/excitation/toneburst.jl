struct ToneBurstParams{T1,T2,T3,T4,T5}
    omega::T1
    mag::T2
    phi::T3
    tR::T4
    T_Stimulus::T5
    function ToneBurstParams(omega::T1, mag::T2, phi::T3, tR::T4, T_Stimulus::T5) where {T1,T2,T3,T4,T5}
        return new{T1,T2,T3,T4,T5}(omega, mag, phi, tR, T_Stimulus)
    end
end

function ToneBurstParams(d::Dict)
    omega = d["omega"]
    mag = abs.(d["v"] .* d["Force_correction"])
    phi = angle.(d["v"] .* d["Force_correction"])
    tR = d["tR"]
    T_Stimulus = d["T_Stimulus"]
    return ToneBurstParams(omega, mag, phi, tR, T_Stimulus)
end

function toneburst!(V, p, t)
    if t < 0
        V = zero(V)
    elseif t < p.T_Stimulus
        V = p.mag .* sin(p.omega * t + p.phi) * (1 + cos(π * (t - p.tR) / p.tR)) / 2
    else
        V = zero(V)
    end
end