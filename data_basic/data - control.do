* ------------------------------------- *
* Preliminary data preparation - controls
* Author: Chanwool Kim
* Date Created: 22 Mar 2017
* Last Update: 2 Nov 2017
* ------------------------------------- *

clear all

* -------------- *
* Early Head Start

cd "$data_ehs"
use "std-ehs.dta", clear

* PPVT
rename ppvt3 ppvt36
rename ppvt5 ppvt48
rename ppvt10 ppvt120

* Control
rename m_age0 m_age
rename HGCG m_edu
rename male sex
drop race
rename m_race0 race
rename m_wj2 m_iq
gen bw = wt0 * 1000

gen black = .
replace black = 1 if race == 2
replace black = 0 if !missing(race) & race != 2

gen hispanic = .
replace hispanic = 1 if race == 3
replace hispanic = 0 if !missing(race) & race != 3

gen mf = .
replace mf = 1 if LIVEARR == 1
replace mf = 0 if !missing(LIVEARR) & LIVEARR != 1
label var mf "Mother lives with father of infant or a boyfriend"

egen sibling = rowtotal(NCHLD05 NCHLD617), missing
label var sibling "Number of siblings (total of kids 0-5 and 6-17)"

#delimit ;
keep id
treat
ppvt36
ppvt48
ppvt120
m_age
m_edu
sibling
m_iq
race
black
hispanic
sex
gestage
mf
bw
;
#delimit cr

foreach t of global measure {
	cd "${data_`t'}"
	save ehs-`t'-control, replace
}

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_ihdp"
use "base-ihdp.dta", clear

rename admin_treat	treat
rename ihdp			id

gen bwg = .
replace bwg = 1 if bwg_sumscore == "H"
replace bwg = 0 if bwg_sumscore == "L"

* PPVT
rename ppvt3y ppvt36
rename ppvt5y ppvt60
rename ppvt8y ppvt96
rename ppvt18y ppvt216

* SB
rename sb3y sb36

rename m_age_base m_age
rename birth_mdeg m_edu
rename hh_sibs0y sibling
rename m_iq0y m_iq

* Control
gen male = .
replace male = 1 if sex == "M"
replace male = 0 if sex == "F"
drop sex
rename male sex
rename birth_weight bw

gen black = .
replace black = 1 if race == 1
replace black = 0 if !missing(race) & race != 1

gen hispanic = .
replace hispanic = 1 if race == 3
replace hispanic = 0 if !missing(race) & race != 3

gen mf = .
replace mf = 1 if birth_mlivs == 1
replace mf = 0 if !missing(birth_mlivs) & birth_mlivs != 1
label var mf "Mother lives with father of infant or a boyfriend"

#delimit ;
keep id
treat
bwg
ppvt36
ppvt60
ppvt96
ppvt216
sb36
m_age
m_edu
sibling
m_iq
race
black
hispanic
sex
gestage
mf
bw
;
#delimit cr

foreach t of global measure {
	cd "${data_`t'}"
	save ihdp-`t'-control, replace
}

* ------ *
* ABC/CARE

cd "$data_abc"
use "append-abccare.dta", clear

* SB
rename sb2y sb24
rename sb3y sb36
rename sb4y sb48
rename sb5y sb60
rename sb7y sb84

rename m_age0y m_age
rename m_deg0y m_edu
rename m_iq0y m_iq
rename f_home0y mf
rename hh_sibs0y sibling
drop sex
rename male sex

gen hispanic = .
replace hispanic = 1 if HISPANC2 == 1
replace hispanic = 0 if !missing(HISPANC2) & HISPANC2 != 1

gen bw = birthweight * 453.592

#delimit ;
keep id
treat
program
sb24
sb36
sb48
sb60
sb84
m_age
m_edu
sibling
m_iq
race
black
hispanic
sex
gestage
mf
bw
;
#delimit cr

foreach t of global measure {
	cd "${data_`t'}"
	save abc-`t'-control, replace
}

