# Preliminaries
Before submitting an issue, please check (with `x` in brackets) that you:
- [ x] Are using the newest release (see [here](https://github.com/bquistorff/synth_runner/releases) for latest release version number).
- [ x] Have checked that the examples in the help work.
- [ x] Have read the help ([HTML version](https://rawgit.com/bquistorff/synth_runner/master/code/ado/synth_runner.html)).
- [ x] Have checked that there is not already an existing issues for what you are reporting.
- [ x] Have check running synth directly for one of the treated units works.

# Expected behavior and actual behavior
Described what you expected to see and what you actually see

Running synth_runner on multiple treated units with different lengths of the treatment I am unable to save the w() and v() files 

# Steps to reproduce the problem

Please include a [minimal, complete, and verifiable example](https://stackoverflow.com/help/mcve). If possible, use system-provided or generated data. Otherwise please link to data so that the example can be verified by others. Format the code with an initial and final line of three backticks(`) for readability (see [GitHub's markdown formatting](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet))

I am using the data of your third example, with a simpler model, adding the option to save the w() and v() files
> synth_runner cigsale retprice age15to24, d(D) gen_vars aggfile_v(aggfile_v.dta) aggfile_w(aggfile_w.dta)

Stata returns the following in red:
> Can only keep if one period in which units receive treatment

Btw, it works if I modify the data to have multiple treated units with the same duration of the treatment

# System information

* Stata version and flavor (e.g. v14 MP): Stata 15 SE
* OS type and version (e.g. Windows 10): Windows 10
* synth_runner version: 1.6.0

