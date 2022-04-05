struct ClickParams{T1,T2}
    Timpulse::T1
    v::T2
end

function ClickParams(d::Dict)
    return clickParams{typeof(d["Timpulse"]),typeof(d["v"])}(d["Timpulse"], d["v"])
end

function click!(V, p, t)
    if t < 0
        V .*= 0
    elseif t < p.Timpulse
        V = p.V
    else
        V .*= 0
    end
end