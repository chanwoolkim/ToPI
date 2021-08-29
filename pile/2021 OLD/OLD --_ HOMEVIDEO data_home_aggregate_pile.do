* --------------------------------------- *
* Data for aggregate pile treatment effects
* Author: Chanwool Kim
* --------------------------------------- *

clear all

* EHS (by program type)

foreach t of global ehs_type {
	cd "$data_working"
	use "ehs`t'-merge.dta", clear

	rename norm_home_*14 norm_home_*1y
	rename norm_home_*36 norm_home_*3y

	rename ppvt36 ppvt3y

	keep id R D norm_home_* ppvt* noncog video_factor* $covariates bw

	cd "$data_analysis"
	save ehs`t'-home-agg-pile, replace
}

* IHDP

cd "$data_working"
use "ihdp-merge.dta", clear

rename norm_home_*12 norm_home_*1y
rename norm_home_*36 norm_home_*3y

rename ppvt36 ppvt3y
rename sb36 sb3y

keep id R D norm_home_* ppvt* sb* noncog video_factor* $covariates bw bwg

cd "$data_analysis"
save ihdp-home-agg-pile, replace

keep if bwg == 0
save ihdplow-home-agg-pile, replace
use ihdp-home-agg-pile, clear
keep if bwg == 1
save ihdphigh-home-agg-pile, replace

* ABC

cd "$data_working"
use "abc-merge.dta", clear

rename norm_home_*6	 norm_home_*6m
rename norm_home_*18 norm_home_*1y
rename norm_home_*42 norm_home_*3y

rename sb36 sb3y

keep id R D norm_home_* sb* video_factor* $covariates bw

cd "$data_analysis"
save abc-home-agg-pile, replace

* CARE (by home visit & both)

foreach t of global care_type {
	cd "$data_working"
	use "care`t'-merge.dta", clear

	rename norm_home_*18 norm_home_*1y
	rename norm_home_*42 norm_home_*3y

	rename sb36 sb3y

	keep id R D norm_home_* sb* noncog  $covariates bw

	cd "$data_analysis"
	save care`t'-home-agg-pile, replace
}
