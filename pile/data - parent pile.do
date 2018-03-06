* ------------------------------------ *
* Data for parent pile treatment effects
* Author: Chanwool Kim
* Date Created: 26 Jan 2018
* Last Update: 4 Mar 2018
* ------------------------------------ *

clear all

* EHS (by program type)

foreach t of global ehs_type {
	cd "$data_parent"
	use "ehs`t'-parent-merge.dta", clear

	rename norm_kidi_*14 norm_kidi_*1y
	rename norm_kidi_*24 norm_kidi_*2y
	
	cd "$pile_working"
	save ehs`t'-parent-pile, replace
}

* IHDP

cd "$data_parent"
use "ihdp-parent-merge.dta", clear

rename norm_kidi_*12 norm_kidi_*1y
rename norm_kidi_*24 norm_kidi_*2y
	
rename kidi12_* kidi1y_*
rename kidi24_* kidi2y_*
	
rename norm_sameroff_*12 norm_sameroff_*1y
rename norm_sameroff_*36 norm_sameroff_*3y

rename norm_sameroff12_* norm_sameroff1y_*
rename norm_sameroff36_* norm_sameroff3y_*
	
cd "$pile_working"
save ihdp-parent-pile, replace

* ABC

cd "$data_parent"
use "abc-parent-merge.dta", clear

rename norm_pari_*6	 norm_pari_*1y
rename norm_pari_*18 norm_pari_*2y

rename norm_pari6_*  norm_pari1y_*
rename norm_pari18_* norm_pari2y_*

rename norm_pase_*66 norm_pase_*5y6m
rename norm_pase_*96 norm_pase_*8y

cd "$pile_working"
save abc-parent-pile, replace
