
sigmoid(x, a) = 1 / (1 + exp(a*x))
natan(x, a) = (atan(a * x) + pi / 2) / pi
# poly = fit(pdf.x, norm_cdf, 6)

struct PolyRef{T<:AbstractFloat}
    x0::T
    x1::T
    y0::T
    y1::T
    n::Int
    g::Vector{Int}
end

const poly_ref_coeffs = [
    [3, -2],
    [10, -15, 6],
    [35, -84, 70, -20]]

function PolyRef(x0, x1, y0, y1; n = 2)
    return PolyRef(x0, x1, y0, y1, n, poly_ref_coeffs[n])
end

function polyref(x, p::PolyRef)
    (; x0, x1, y0, y1, g, n) = p
    y = fill(y0, length(x))
    for i in eachindex(g)
        @. y .+= (y1- y0) * g[i] * ((x - x0) / (x1-x0)) ^ (n + i)
    end
    return y
end

pref = PolyRef(-100., 100., 0., 1., n=2)