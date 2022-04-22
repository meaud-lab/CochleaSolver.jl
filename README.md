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
julia> Pkg.add("https://github.com/mikerouleau/CochleaSolver.jl")
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

julia -e 'using Pkg; Pkg.add("https://github.com/mikerouleau/CochleaSolver.jl")'

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

Afterwards, load the output data file (currently "julia_soln.mat") and finish post-processing as necessary in MATLAB.
