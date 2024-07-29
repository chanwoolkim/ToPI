* ------------------------------------- *
* Preliminary data preparation - outcomes
* Author: Chanwool Kim
* ------------------------------------- *

clear all

* -------------- *
* Early Head Start

cd "$data_raw"
use "std-ehs.dta", clear

* PPVT
rename ppvt3 ppvt36
rename ppvt5 ppvt48
rename ppvt10 ppvt120

rename ppvt36 ppvt3y
clonevar iq_orig = ppvt3y

foreach var of varlist ppvt*  {
	sum `var'
	replace `var'= (`var'-r(mean))/r(sd)
}

* Price
rename ccare_cost26m	price_care26

#delimit ;
keep id
treat
ppvt3y
iq_orig
ppvt48
ppvt120
price_care
;
#delimit cr

cd "$data_working"
save ehs-outcome, replace

* - *
* ABC

cd "$data_raw"
use "append-abccare.dta", clear

* SB
rename sb2y sb24
rename sb3y sb36
rename sb4y sb48
rename sb5y sb60
rename sb7y sb84

rename sb36 sb3y

clonevar iq_orig = sb3y

foreach var of varlist sb* {
	sum `var'
	replace `var'= (`var'-r(mean))/r(sd)
}

#delimit ;
keep id
treat
program
sb24
sb3y
iq_orig
sb48
sb60
sb84
;
#delimit cr

keep if program == "abc"

cd "$data_working"
save abc-outcome, replace
