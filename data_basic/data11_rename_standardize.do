* --------------------------------------- *
* Data for aggregate pile treatment effects
* Author: Chanwool Kim
* --------------------------------------- *
 
clear all

* EHS (by program type)

foreach t of global ehs_type {
	cd "$data_working"
	use "ehs`t'-merge.dta", clear

	*Black already exists (race==2)
	*bw already exists (in grams)
	*poverty not available
	*m_edu weird, as if it was standardized
	
	rename norm_home_*14 norm_home_*1y
	rename norm_home_*36 norm_home_*3y
	
	rename norm_kidi_*14 norm_kidi_*1y
	rename norm_kidi_*24 norm_kidi_*2y //it is only norm_kidi_total24

	rename ppvt36 ppvt3y

	rename norm_bayley_*24	norm_bayley_*2y
	rename norm_bayley_*36	norm_bayley_*3y
	rename norm_cbcl_*120 	norm_cbcl_*10y
	
	keep id R D norm_home_* video* ppvt* $covariates poverty bw ///
		home14_* home36_* norm_kidi_* norm_bayley_* norm_cbcl_* black

	foreach var of varlist video* ppvt*  {
	sum `var'
	replace `var'= (`var'-r(mean))/r(sd)
	}

	
*	save ehs`t'-homevideo-agg-pile, replace
	save ehs`t'-topi, replace								//attempt to use a single dataset
}

* IHDP

use "ihdp-merge.dta", clear

rename norm_home_*12 norm_home_*1y
rename norm_home_*36 norm_home_*3y

rename norm_kidi_*12 norm_kidi_*1y
rename norm_kidi_*24 norm_kidi_*2y

rename kidi12_* kidi1y_*
rename kidi24_* kidi2y_*

rename norm_sameroff_*12 norm_sameroff_*1y
rename norm_sameroff_*36 norm_sameroff_*3y

rename norm_sameroff12_* norm_sameroff1y_*
rename norm_sameroff36_* norm_sameroff3y_*

rename ppvt36 ppvt3y
rename sb36 sb3y

rename norm_bayley_*24	norm_bayley_*2y

rename cbcl60_* cbcl5y_*
rename cbcl96_* cbcl8y_*

keep id R D norm_home_* ppvt* video* sb* $covariates bw bwg home12_* home36_* ///
norm_kidi_* kidi* norm_sameroff* norm_bayley_* cbcl*  poverty black

foreach var of varlist ppvt* video* sb* kidi* cbcl* {
sum `var'
replace `var'= (`var'-r(mean))/r(sd)
}

*save ihdp-homevideo-agg-pile, replace
save ihdp-topi, replace										//attempt to use a single dataset

*keep if bwg == 0
*save ihdplow-homevideo-agg-pile, replace
*use ihdp-homevideo-agg-pile, clear
*keep if bwg == 1
*save ihdphigh-homevideo-agg-pile, replace

* ABC

use "abc-merge.dta", clear

rename norm_home_*6	 norm_home_*6m
rename norm_home_*18 norm_home_*1y
rename norm_home_*42 norm_home_*3y
rename sb36 sb3y

rename norm_pari_*6	 norm_pari_*1y
rename norm_pari_*18 norm_pari_*2y

rename norm_pari6_*  norm_pari1y_*
rename norm_pari18_* norm_pari2y_*

rename norm_pase_*66 norm_pase_*5y6m
rename norm_pase_*96 norm_pase_*8y

rename norm_bayley_*24	norm_bayley_*2y
rename norm_bayley_*36	norm_bayley_*3y

rename cbcl96_*	cbcl8y_*

keep id R D norm_home_* video* sb* $covariates ///
bw home18_* home42_* norm_pari* norm_pase* norm_bayley_* cbcl*  poverty black

foreach var of varlist video* sb* cbcl* {
sum `var'
replace `var'= (`var'-r(mean))/r(sd)
}

*save abc-homevideo-agg-pile, replace
save abc-topi, replace										//attempt to use a single dataset

* CARE (by home visit & both)

foreach t of global care_type {
	use "care`t'-merge.dta", clear

	rename norm_home_*18 norm_home_*1y
	rename norm_home_*42 norm_home_*3y
	rename sb36 sb3y
	
	rename norm_bayley_*24	norm_bayley_*2y
	rename norm_bayley_*36	norm_bayley_*3y

	rename cbcl96_*	cbcl8y_*

	keep id R D norm_home_* sb* $covariates bw home18_* home42_* norm_bayley_* cbcl* poverty black

	foreach var of varlist sb* cbcl* {
	sum `var'
	replace `var'= (`var'-r(mean))/r(sd)
	}
	
*	save care`t'-homevideo-agg-pile, replace
	save care`t'-topi, replace
}
