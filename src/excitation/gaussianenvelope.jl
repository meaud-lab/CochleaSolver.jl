struct GaussianEnvelope{T1,T2,T3,T4}
    t0::T1
    sigma::T2
    F0::T3
    v::T4
    function GaussianEnvelope(t::T1, s::T2, f::T3, v::T4) where {T1,T2,T3,T4}
        return new{T1,T2,T3,T4}(t, s, f, v)
    end
end


function GaussianEnvelope(d::Dict)
    t0 = d["t0_GaussEnv"]
    sigma = d["sigma_GaussEnv"]
    F0 = d["F0"]
    v = d["v"]
    return GaussianEnvelope(t0, sigma, F0, v)
end

function gaussianenv!(V, p, t)
    V = p.v * exp.(-0.5 * ((t - p.t0) ./ p.sigma) .^ 2 .* sin.(p.F0 * 2π .* t))
end
