using DrWatson
@quickactivate "TidalMeltParametrization"

# Here you may include files from the source directory
include(srcdir("nonlinearities.jl"))

println(
"""
Currently active project is: $(projectname())

Path of active project: $(projectdir())
"""
)
