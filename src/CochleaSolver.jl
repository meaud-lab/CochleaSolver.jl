module CochleaSolver

# Excitation
include("excitation/excitation.jl")
export Excitation

include("excitation/raisedsine.jl")
export RaisedSineParams, raisedsine!

include("excitation/click.jl")
export ClickParams, click!

include("excitation/sine.jl")
export SineParams, sine!

include("excitation/twotone.jl")
export TwoToneParams, twotone!, twotonesuppression!

include("excitation/gaussianenvelope.jl")
export GaussianEnvelopeParams, gaussianenv!

include("excitation/toneburst.jl")
export ToneBurstParams, toneburst!

# Solver
include("algs.jl")
export solver_alg

include("solve.jl")
export solve_cochlea

end
