/*
If you would like to automatically setup the ADO path to use the package in this repo
1) Navigate Stata to have its current working directoy in the rebo root (not in code/)
2) Execute
do code/setup_ado.do
*/

* This file shows three examples. Each can be turned off by changing
*  if 1{
* to 
*  if 0{
*  around the appropriate section

* Header
clear all
mac drop _all
//if run in batch-mode then set this doesn't force trying to make 2 logs
cap log close _all
cap log using "usage.log", replace
set graphics `= cond("`c(mode)'"=="batch", "off", "on")'
version 12
set scheme s2mono
set more off
set matsize 11000
mata: mata set matafavor speed
set tracedepth 2
set trace off


* Re-doing the maing example from -synth-
sysuse smoking, clear
tsset state year
label variable year "Year"
label variable cigsale "Cigarette sales per capita (in packs)"

compress
qui describe, varlist
global orig_vars "`r(varlist)'"
global tper 1989

if 1{
* The main example in -help synth- for California with the first post-treatment period being 1989
synth_runner cigsale beer(1984(1)1988) lnincome(1972(1)1988) retprice age15to24 cigsale(1988) cigsale(1980) cigsale(1975), ///
	trunit(3) trperiod(${tper}) gen_vars
ereturn list
di (e(pval_joint_post_std)*e(n_pl)+1)/(e(n_pl)+1) //p-value if truly random
mat li e(treat_control)


single_treatment_graphs, trlinediff(-1) raw_gname(cigsale1_raw) effects_gname(cigsale1_effects) ///
	effects_ylabels(-30(10)30) effects_ymax(35) effects_ymin(-35)

effect_graphs , trlinediff(-1) tc_gname(cigsale1_tc) effect_gname(cigsale1_effect)
	
pval_graphs , pvals_gname(cigsale1_pval) pvals_std_gname(cigsale1_pval_t)
keep $orig_vars
}

** Same treatment, matched a bit differently
if 1{
gen byte D = (state==3 & year>=${tper})
synth_runner cigsale beer(1984(1)1988) lnincome(1972(1)1988) retprice age15to24, ///
	trunit(3) trperiod(${tper}) trends training_propr(`=13/19') pre_limit_mult(10) ///
	gen_vars aggfile_v(aggfile_v.dta) aggfile_w(aggfile_w.dta)
ereturn list
di "Proportion of control units that have a higher RMSPE than the treated unit in the validtion period:"
di round(`e(avg_val_rmspe_p)', 0.001)
mat li e(treat_control)

single_treatment_graphs, scaled raw_gname(cigsale2_raw) effects_gname(cigsale2_effects)
effect_graphs , scaled tc_gname(cigsale2_tc) effect_gname(cigsale2_effect)
pval_graphs , pvals_gname(cigsale2_pval) pvals_std_gname(cigsale2_pval_t)
keep $orig_vars
erase aggfile_v.dta
erase aggfile_w.dta
}

**Now a more complicated example.
*Use a treatment indicator variable, multiple treated units, dynamic predictors, and dropping interfering units
if 1{
cap program drop my_pred
program my_pred, rclass
	args tyear
	return local predictors "beer(`=`tyear'-4'(1)`=`tyear'-1') lnincome(`=`tyear'-4'(1)`=`tyear'-1')"
end
cap program drop my_drop_units
program my_drop_units
	args tunit
	
	if `tunit'==39 qui drop if inlist(state,21,38)
	if `tunit'==3 qui drop if state==21
end
//with t in {1988,1989} we consistently have at least 12 pre-t years
cap program drop my_xperiod
program my_xperiod, rclass
	args tyear
	
	return local xperiod "`=`tyear'-12'(1)`=`tyear'-1'"
end

cap program drop my_mspeperiod
program my_mspeperiod, rclass
	args tyear
	
	return local mspeperiod "`=`tyear'-12'(1)`=`tyear'-1'"
end

gen byte D = (state==3 & year>=1989) | (state==7 & year>=1988) //Georgia
synth_runner cigsale retprice age15to24, d(D) pred_prog(my_pred) ///
	trends training_propr(`=13/18') drop_units_prog(my_drop_units) xperiod_prog(my_xperiod) mspeperiod_prog(my_mspeperiod)
ereturn list
mat li e(treat_control)
effect_graphs ,  tc_gname(cigsale3_tc) effect_gname(cigsale3_effect)
pval_graphs , pvals_gname(cigsale3_pval) pvals_std_gname(cigsale3_pval_t)
keep $orig_vars
}


*Save the named graphs to disk
if 1{
qui graph dir, memory
local grphs "`r(list)'"
foreach gname of local grphs{
	if "`gname'"=="Graph" continue //these are unnamed ones
	qui graph save `gname' "`gname'.gph", replace
	qui graph export "`gname'.eps", name(`gname') replace
	qui graph export "`gname'.pdf", name(`gname') replace
}
}



cap noisily log close
