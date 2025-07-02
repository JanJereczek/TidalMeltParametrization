include("intro.jl")
using DelimitedFiles, CairoMakie, KernelDensity, Polynomials, SpecialFunctions

data = readdlm(datadir("raw/tides/Thwaites.csv"), ',')
nvar, nt = size(data)

# data_amery = readdlm(datadir("raw/tides/Amery_sparse.xlsx"))

lw1, lw2 = 2, 4
cmap = cgrad(:seaborn_colorblind, range(0, stop = 1, length = 7))
set_theme!(theme_latexfonts())
fig = Figure(size = (1000, 500), fontsize = 24)
ax_lines = Axis(fig[1, 1:2])
ax_pdf = Axis(fig[1, 3])
ax_cdf = Axis(fig[1, 3])

ax_lines.xlabel = "Time (1)"
ax_lines.ylabel = "Sea suface height anomaly (cm)"

ax_pdf.yticklabelsvisible = false
ax_pdf.yticksvisible = false
ax_pdf.xlabel = "Probability density (1)"
ax_pdf.xticklabelcolor = cmap[1]
ax_pdf.xtickcolor = cmap[1]
ax_pdf.xlabelcolor = cmap[1]
ax_pdf.xaxisposition = :top
xlims!(ax_pdf, -1f-3, 1.1f-2)

ax_cdf.xticklabelcolor = cmap[2]
ax_cdf.xtickcolor = cmap[2]
ax_cdf.xlabelcolor = cmap[2]
ax_cdf.yaxisposition = :right
ax_cdf.ylabel = "Sea suface height anomaly (cm)"
ax_cdf.xlabel = "Normalized cumulative density (1)"
xlims!(ax_cdf, -1f-1, 1.1)

[ylims!(ax, (-100, 100)) for ax in (ax_lines, ax_pdf, ax_cdf)]

delta_ssh = Float32.(data[nvar, 2:nt])
pdf = kde(delta_ssh)
lines!(ax_lines, view(data, nvar, 2:nt), label = "Tide + IBE")
density!(ax_pdf, view(data, nvar, 2:nt), direction = :y, color = cmap[1])
norm_cdf = cumsum(pdf.density)
norm_cdf ./= maximum(norm_cdf)
lines!(ax_cdf, norm_cdf, pdf.x, color = cmap[2], linewidth = lw2, label = "target")

lines!(ax_cdf, polyref(pdf.x, pref), pdf.x, color = :gray50, linewidth = lw2,
    linestyle = :dash, label = "poly")
lines!(ax_cdf, normal_cdf(pdf.x, 0, 40), pdf.x, color = :black, linewidth = lw2,
    linestyle = :dash, label = "erf")
axislegend(ax_cdf, position = :rb)
# lines!(ax_cdf, sigmoid.(pdf.x, -5f-2), pdf.x, color = :black, linewidth = lw2, linestyle = :dash)
# lines!(ax_cdf, natan.(pdf.x, 5f-2), pdf.x, color = cmap[3])
# lines!(ax_cdf, poly.(pdf.x), pdf.x, color = cmap[3], linewidth = lw2)
fig
save(plotsdir("polyref_trajectory.png"), fig)

H0 = 0
H1 = 100
m = 200 / (H1 - H0)
p = 100 - m * H1

H = -20:0.01:120
H_tides = m .* H .+ p
fig2 = Figure(size = (600, 400))
ax = Axis(fig2[1, 1])
lines!(ax, H, (H_tides .+ 100) ./ 200, label = "linear")
lines!(ax, H, polyref(H_tides, pref), label = "poly")
lines!(ax, H, normal_cdf(H_tides, 0, 40), label = "erf")
axislegend(ax, position = :rb)
ax.xlabel = "Height above floatation (m)"
ax.ylabel = "Grounded fraction (1)"
xlims!(ax, (H0, H1))
ylims!(ax, (-0.1, 1.1))
save(plotsdir("pmpt-comparison.png"), fig2)