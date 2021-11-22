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

* Price
rename ccare_cost26m	price_care26

#delimit ;
keep id
treat
ppvt36
ppvt48
ppvt120
price_care
;
#delimit cr

cd "$data_working"
save ehs-outcome, replace

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_raw"
use "base-ihdp.dta", clear

drop if missing(pag)

rename admin_treat	treat
rename ihdp			id

* PPVT
rename ppvt3y ppvt36
rename ppvt5y ppvt60
rename ppvt8y ppvt96
rename ppvt18y ppvt216

* SB
rename sb3y sb36

* Price
rename care_oth3y_i55a	price_care36

#delimit ;
keep id
treat
ppvt36
ppvt60
ppvt96
ppvt216
sb36
price_care
;
#delimit cr

cd "$data_working"
save ihdp-outcome, replace

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

#delimit ;
keep id
treat
sb24
sb36
sb48
sb60
sb84
;
#delimit cr

cd "$data_working"
save abc-outcome, replace
