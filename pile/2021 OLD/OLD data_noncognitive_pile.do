* ------------------------------------ *
* Data for parent pile treatment effects
* Author: Chanwool Kim
* ------------------------------------ *

clear all

* EHS (by program type)

foreach t of global ehs_type {
	cd "$data_working"
	use "ehs`t'-merge.dta", clear

	rename norm_bayley_*24	norm_bayley_*2y
	rename norm_bayley_*36	norm_bayley_*3y
	rename norm_cbcl_*120 	norm_cbcl_*10y

	keep id R D norm_bayley_* norm_cbcl_* $covariates

	cd "$data_analysis"
	save ehs`t'-noncog-pile, replace
}

* IHDP

cd "$data_working"
use "ihdp-merge.dta", clear

rename norm_bayley_*24	norm_bayley_*2y

rename cbcl60_* cbcl5y_*
rename cbcl96_* cbcl8y_*

keep id R D norm_bayley_* cbcl* $covariates

cd "$data_analysis"
save ihdp-noncog-pile, replace

* ABC

cd "$data_working"
use "abc-merge.dta", clear

rename norm_bayley_*24	norm_bayley_*2y
rename norm_bayley_*36	norm_bayley_*3y

rename cbcl96_*	cbcl8y_*

keep id R D norm_bayley_* cbcl* $covariates

cd "$data_analysis"
save abc-noncog-pile, replace

* CARE

foreach t of global care_type {
	cd "$data_working"
	use "care`t'-merge.dta", clear

	rename norm_bayley_*24	norm_bayley_*2y
	rename norm_bayley_*36	norm_bayley_*3y

	rename cbcl96_*	cbcl8y_*

	keep id R D norm_bayley_* cbcl* $covariates

	cd "$data_analysis"
	save care`t'-noncog-pile, replace
}
