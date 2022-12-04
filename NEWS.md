The transfer of CochleaSolver.jl to meaud-lab has been completed. The new path is
git@github.com:meaud-lab/CochleaSolver.jl.git

For v0.4.3, the significant changes include
1.	New repository location (stays with lab instead of my personal account)
2.	Addition to the lab registry (refer to it by name instead of path, better version resolution and tracking)
3.	Improved logging regarding mass matrices

## For master/stable branch users:
The recommended way to reflect this update is to add the MeaudLabRegistry to your registry list in Julia. The process is identical on Windows/Mac/Linux:
From a fresh Julia REPL session, first remove the old path by removing the package from the working environment

`julia>]`

`pkg>rm CochleaSolver`

running

`pkg>st`

should reflect that CochleaSolver has been removed from the environment

then add MeaudLabRegistry to the registry list

`pkg>registry add git@github.com:meaud-lab/MeaudLabRegistry.git`

and add CochleaSolver back by name

`pkg>add CochleaSolver`

`pkg>st`

should reflect that v0.4.3 (latest) release of CochleaSolver.jl is installed.

Updates are done the same as before, via `pkg>up`

There have been some significant upstream precompilation improvements, so this would be a good time to update/upgrade your packages.


## For developers:
After following the master branch directions, you can check out a specific branch similar to the previous method. Since we are using a custom registry, we can use the name of the package instead of the git path. E.g. to check out the dev branch,

`pkg>add CochleaSolver#dev`
