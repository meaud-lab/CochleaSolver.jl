
struct Excitation{T1,T2}
    stimulus!::T1
    stimulus_parameters::T2
    function Excitation(stim, params)
        return new{typeof(stim),typeof(params)}(stim, params)
    end
end

"""
    Excitation(d::Dict)

switch to determine the type of loading and construct appropriate parameter types. 
"""
function Excitation(d::Dict)
    typeLoading = d["typeLoading"]
    if typeLoading == 0 #click
        p = ClickParams(d)
        f = click!
    elseif typeLoading == 1 #sinusoid
        p = SineParams(d)
        f = sine!
    elseif typeLoading == 2 # riased sinusoid
        p = RaisedSineParams(d)
        f = raisedsine!
    elseif typeLoading == 3 #two tones, raised sine
        p = TwoToneParams(d)
        f = twotone!
    elseif typeLoading == 4
        p = GaussianEnvelopeParams(d)
        f = gaussianenv!
    elseif typeLoading == 9 # two tone suppression
        p = TwoToneParams(d)
        f = twotonesuppression!
    elseif typeLoading == 10
        p = ToneBurstParams(d)
        f = toneburst!
    end
    return Excitation(f, p)
end