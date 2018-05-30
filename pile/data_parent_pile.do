* ------------------------------------ *
* Data for parent pile treatment effects
* Author: Chanwool Kim
* ------------------------------------ *

clear all

* EHS (by program type)

foreach t of global ehs_type {
	cd "$data_working"
	use "ehs`t'-merge.dta", clear

	rename norm_kidi_*14 norm_kidi_*1y
	rename norm_kidi_*24 norm_kidi_*2y

	keep id R D norm_kidi_* $covariates

	cd "$data_analysis"
	save ehs`t'-parent-pile, replace
}

* IHDP

cd "$data_working"
use "ihdp-merge.dta", clear

rename norm_kidi_*12 norm_kidi_*1y
rename norm_kidi_*24 norm_kidi_*2y

rename kidi12_* kidi1y_*
rename kidi24_* kidi2y_*

rename norm_sameroff_*12 norm_sameroff_*1y
rename norm_sameroff_*36 norm_sameroff_*3y

rename norm_sameroff12_* norm_sameroff1y_*
rename norm_sameroff36_* norm_sameroff3y_*

keep id R D norm_kidi_* kidi* norm_sameroff* $covariates

cd "$data_analysis"
save ihdp-parent-pile, replace

* ABC

cd "$data_working"
use "abc-merge.dta", clear

rename norm_pari_*6	 norm_pari_*1y
rename norm_pari_*18 norm_pari_*2y

rename norm_pari6_*  norm_pari1y_*
rename norm_pari18_* norm_pari2y_*

rename norm_pase_*66 norm_pase_*5y6m
rename norm_pase_*96 norm_pase_*8y

keep id R D norm_pari* norm_pase* $covariates

cd "$data_analysis"
save abc-parent-pile, replace
