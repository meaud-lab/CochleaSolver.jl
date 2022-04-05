struct SineParameters{T1,T2,T3,T4}
    omega::T1
    mag::T2
    phi::T3
    tOff::T4
    function SineParameters(omega::T1, mag::T2, phi::T3, tOff::T4) where {T1,T2,T3,T4}
        return new{T1,T2,T3,T4}(omega, mag, phi, tOff)
    end
end

function SineParameters(d::Dict)
    mag = abs.(d["v"] * d["Force_correction"])
    phi = angle.(d["v"] * d["Force_correction"])
    tOff = d["Nperiod"] * 2π / d["omega"]
    return SineParameters(d["omega"], mag, phi, tOff)
end

function sine!(V, p, t)
    if t < 0
        V .*= 0
    elseif t < p.tOff
        @. V = p.mag * sin(p.omega * t + p.phi)
    else
        V .*= 0
    end
end