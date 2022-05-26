# CochleaSolver.jl

[![Build Status](https://github.com/mikerouleau/CochleaSolver.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/mikerouleau/CochleaSolver.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/mikerouleau/CochleaSolver.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/mikerouleau/CochleaSolver.jl)


## Overview
This package is intended to be an alternative solver for the cochlea model used by the [Meaud lab](https://sites.gatech.edu/meaud/) at Georgia Institute of Technology.

## Installation
### Local
Installation is similar to other Julia packages. From the REPL, 
```sh
julia> using Pkg
julia> Pkg.add(url="https://github.com/mikerouleau/CochleaSolver.jl")
```
### PACE
PACE has excellent [docs](https://docs.pace.gatech.edu/software/julia/) that can help get started with Julia on PACE. For basic installation of this package in the global environment, the following PBS script is given as a guide:
```
#PBS -N julia_cochlea_install
#PBS -A <your group account here!>
#PBS -l nodes=1:ppn=1
#PBS -l walltime=01:00:00
#PBS -j oe

cd $PBS_O_WORKDIR
module load gcc/8.3.0 julia/1.7.2

julia -e 'using Pkg; Pkg.add(url="https://github.com/mikerouleau/CochleaSolver.jl")'

```

For each job that uses this package after installation, don't forget to add `module load gcc/8.3.0 julia/1.7.2` in your PBS script.

## Use
To minimize the need for other team members to use Julia, the package is set up to read a MATLAB data file (*.mat) that describes the model, solve the appropriate ODE, and save the result as a MATLAB data file for further processing.

The input data file must define a large number of variables that describe the problem, depending on the type of excitation. These variables are the subject of future documentation, but are generally the global variables that already exist in the MATLAB solver.

The current recommended method of MATLAB integration is to use a system call to start Julia and run a Julia script that looks something like:

```julia
using CochleaSolver
solve_cochlea("input_datafile.mat")
```

Afterwards, load the output data file (defaults to "julia_soln.mat") and finish post-processing as necessary in MATLAB.

## Inputs
Aside from pointing the solver to the proper input MAT-file (see [Use](#use) for example), all inputs are passed as variables within that MAT-file. The required inputs depend primarily on excitation type, but several are common to all excitations. All input variable names are case-sensitive and are adopted from the existing MATLAB variable names.
### Common
Required inputs for all excitations include:
  * JuliaOutFilename (String) - output filename
  * options (MATLAB ODEoptions type) - ODE Solver options
  * tspan (Vector{Real}) - points to save solution at
  * ODE_SOLVER (String) - ODE solver to use
  * N (Int) - DOF?
  * nMechTotal (Int)
  * nElecTotal (Int)
  * elecLongCoupling (Int)
  * electricalModel (Int)
  * A1
  * A2
  * Ce
  * Y_HB
  * B0
  * X0
  * deltaX
  * q
  * IhbNLFactor
  * Y_FesNL
  * P0
  * withMassMatrix
  * typeLoading (Int) - excitation type

### Excitation-specific
#### Click (typeLoading = 0)
  * Timpulse
  * v
#### Sine (typeLoading = 1)
  * Force_correction
  * Nperiod
  * omega
  * v
#### Raised Sine (typeLoading = 2)
  * Force_correction
  * omega
  * tR
  * tOn
  * v
#### Two Tone (typeLoading = 3 or 9)
  * Force_correction
  * omega1
  * omega2
  * tR
  * tOn
  * v
#### Gaussian Envelope (typeLoading = 4)
  * t0_GaussEnv
  * sigma_GaussEnv
  * F0
  * v
#### Tone Burst (typeLoading = 10)
  * Force_correction
  * omega
  * tR
  * T_Stimulus
  * v

### Optional Inputs
  * JuliaOutFilename (String) - path to output *.mat file. Default is "julia_soln.mat"
  * logfile (String) - path to desired log file. Default is "julia_solver.log"

## Testing
A test suite can be run by simply running
```julia
(Cochlea Solver) Pkg> test
```
