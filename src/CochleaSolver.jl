module CochleaSolver

# include("originalsolver.jl")
# export solve_cochlea

# Excitation
include("excitation/raisedsine.jl")
export RaisedSineParams, raisedSine!

include("excitation/click.jl")
export ClickParams, click!

include("excitation/sine.jl")
export SineParameters, sine!

include("excitation/twotone.jl")
export TwoToneParameters, twotone!, twotonesuppression!

include("solve.jl")
export solvecochlea

end
