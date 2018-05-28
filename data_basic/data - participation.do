* ------------------------------------------ *
* Preliminary data preparation - participation
* Author: Chanwool Kim
* ------------------------------------------ *

clear all

* -------------- *
* Early Head Start

cd "$data_raw"
use "std-ehs.dta", clear

rename treat R

rename P2V_ENG2 D

tab D, mi
replace D = 1 if (D > 0 & D != .)
sum D
tab D R, col

keep id program_type R D

// refer to the ehs participation folder for additional code

cd "$data_working"
save ehs-participation, replace

use ehs-participation, clear

keep if program_type == 1
save ehscenter-participation, replace

use ehs-participation, clear
keep if program_type == 2
save ehshome-participation, replace

use ehs-participation, clear
keep if program_type == 3
save ehsmixed-participation, replace

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_raw"
use "base-ihdp.dta", clear

rename admin_treat treat
rename ihdp	id
rename treat R

* Participation in IHDP
* careprm_ihdp3 "Primary care was IHDP CDC, ages 2y6m-3y"
* caresec_ihdp3 "Secondary care was IHDP CDC, ages 2y6m-3y"
* careter_ihdp3 "Tertiary child care was IHDP CDC, at age 2y6m-3y"

gen D = .
replace D = 0 if careprm_ihdp3 == 0 | caresec_ihdp3 == 0 | careter_ihdp3 == 0
replace D = 1 if careprm_ihdp3 == 1 | caresec_ihdp3 == 1 | careter_ihdp3 == 1

sum D // 1002 obs
tab D R, col

gen bwg = .
replace bwg = 1 if bwg_sumscore == "H"
replace bwg = 0 if bwg_sumscore == "L"

keep id bwg R D

cd "$data_working"
save ihdp-participation, replace

* --------- *
* Abecedarian

cd "$data_raw"
use "append-abccare.dta", clear

keep if program == "abc"
keep id program R D P

cd "$data_working"
save abc-participation, replace

* -- *
* CARE

cd "$data_raw"
use "append-abccare.dta", clear

keep if program == "care"

drop R
gen R = random != 0
gen Dany = D == 1 | homevisit > 0
tab Dany
drop D
rename Dany D

keep id program R D

cd "$data_working"
save care-participation, replace

cd "$data_raw"
use "append-abccare.dta", clear

keep if program == "care"

drop R
keep if random == 0 | random == 2
gen R = random == 2
gen Dboth = D == 1 & homevisit > 0
tab Dboth
drop D
rename Dboth D

keep id program R D

cd "$data_working"
save careboth-participation, replace

cd "$data_raw"
use "append-abccare.dta", clear

keep if program == "care"

drop R
keep if random == 0 | random == 3
gen R = random == 3
gen Dhome = D == 0 & homevisit > 0
tab Dhome
drop D
rename Dhome D

keep id R D program

cd "$data_working"
save carehome-participation, replace
