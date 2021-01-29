* ------------------------------ *
* Data preparation - subpopulation
* Author: Chanwool Kim
* ------------------------------- *

clear all

label define race 1 "White" 0 "Black"

* -------------- *
* Early Head Start

foreach t of global ehs_type {

	cd "$data_analysis"
	use "ehs`t'-homo-merge.dta", clear

	* Race
	drop race_g
	gen race_g = .
	replace race_g = 1 if race == 1 & !missing(race)
	replace race_g = 0 if race == 2 & !missing(race)
	label var race_g "Race (estimated from mother's race)"
	label val race_g race

	save ehs`t'-subpop-merge, replace
}

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_analysis"
use "ihdp-homo-merge.dta", clear

* Race
drop race_g
gen race_g = .
replace race_g = 1 if race == 2 & !missing(race)
replace race_g = 0 if race == 1 & !missing(race)
label var race_g "Race (estimated from mother's race)"
label val race_g race

save ihdp-subpop-merge, replace

* --------- *
* Abecedarian

cd "$data_analysis"
use "abc-homo-merge.dta", clear

* Race
drop race_g
gen race_g = .
replace race_g = 1 if race == 2 & !missing(race)
replace race_g = 0 if race == 1 & !missing(race)
label var race_g "Race (estimated from mother's race)"
label val race_g race

save abc-subpop-merge, replace

* -- *
* CARE

foreach t of global care_type {
	cd "$data_analysis"
	use "care`t'-homo-merge.dta", clear

	* Race
	drop race_g
	gen race_g = .
	replace race_g = 1 if race == 2 & !missing(race)
	replace race_g = 0 if race == 1 & !missing(race)
	label var race_g "Race (estimated from mother's race)"
	label val race_g race

	save care`t'-subpop-merge, replace
}
