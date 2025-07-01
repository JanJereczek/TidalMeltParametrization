include("intro.jl")
using DelimitedFiles, CairoMakie, KernelDensity, Polynomials

data = readdlm(datadir("raw/tides/Thwaites.csv"), ',')
nvar, nt = size(data)

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
lines!(ax_cdf, norm_cdf, pdf.x, color = cmap[2], linewidth = lw2)

lines!(ax_cdf, polyref(pdf.x, pref), pdf.x, color = :black, linewidth = lw2, linestyle = :dash)
# lines!(ax_cdf, sigmoid.(pdf.x, -5f-2), pdf.x, color = :black, linewidth = lw2, linestyle = :dash)
# lines!(ax_cdf, natan.(pdf.x, 5f-2), pdf.x, color = cmap[3])
# lines!(ax_cdf, poly.(pdf.x), pdf.x, color = cmap[3], linewidth = lw2)

save(plotsdir("polyref_trajectory.png"), fig)