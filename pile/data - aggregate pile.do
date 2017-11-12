* --------------------------------------- *
* Data for aggregate pile treatment effects
* Author: Chanwool Kim
* Date Created: 13 Sep 2017
* Last Update: 2 Nov 2017
* --------------------------------------- *

clear all

cd "$data_home"

* EHS (by program type)

foreach t of global ehs_type {
	use "ehs`t'-home-agg-merge.dta", clear

	rename norm_home_*14 norm_home_*1y
	rename norm_home_*36 norm_home_*3y
	
	drop norm_home_develop*
	
	save ehs`t'-home-agg-pile, replace
}

* IHDP (by birth weight group)

foreach t of global ihdp_type {
	use "ihdp`t'-home-agg-merge.dta", clear

	rename norm_home_*12 norm_home_*1y
	rename norm_home_*36 norm_home_*3y
	
	save ihdp`t'-home-agg-pile, replace
}

* ABC

use "abc-home-agg-merge.dta", clear

rename norm_home_*18 norm_home_*1y
rename norm_home_*42 norm_home_*3y

save abc-home-agg-pile, replace

* CARE (by home visit & both)

foreach t of global care_type {
	use "care`t'-home-agg-merge.dta", clear

	rename norm_home_*18 norm_home_*1y
	rename norm_home_*42 norm_home_*3y
	
	save care`t'-home-agg-pile, replace
}
