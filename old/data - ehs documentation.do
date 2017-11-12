* ------------------ *
* Data - using EHS doc
* Author: Chanwool Kim
* Date Created: 26 Apr 2017
* Last Update: 27 Jun 2017
* ------------------ *

clear all
set more off

global data_ehs		: env data_ehs
global data_ihdp	: env data_ihdp
global data_abc		: env data_abc
global data_home	: env klmshare

local ehs_home_types	total warm nonpun verb harsh inenviro exenviro lang

* -------------- *
* Early Head Start

cd "$data_ehs"
use "std-ehs.dta", clear

* HOME total score
rename home_total14m	home_total14
rename home_total2	home_total24
rename home_total3	home_total36

* HOME warmth
rename home_emot14m	home_warm14
rename home_emot24m	home_warm24
rename B3P_WARM		home_warm36

* HOME parental lack of hostility
rename home_nonpun14m	home_nonpun14
rename home_nonpun24m	home_nonpun24

* HOME parental verbal skills
rename home_verb14m	home_verb14
rename home_verb24m	home_verb24

* HOME harsh scale
rename harshscale3	home_harsh36

* HOME internal environment
rename B3P_INPH		home_inenviro36

* HOME external environment
rename home_scale3	home_exenviro36

* HOME lang & cog stimulation
rename home_lang14m	home_lang14
rename home_lang24m	home_lang24
rename home_lang3	home_lang36

drop home_lang

#delimit ;
keep id
treat
home_total14
home_total24
home_total36
home_warm14
home_warm24
home_warm36
home_lang14
home_lang24
home_lang36
home_nonpun14
home_nonpun24
home_verb14
home_verb24
home_exenviro36
home_harsh36
home_inenviro36
;
#delimit cr

* Normalise to have in-group sample mean 0 and variance 1
foreach t of local ehs_home_types {
	foreach m of numlist 14 24 36 {
	capture egen norm_home_`t'`m' = std(home_`t'`m')
	}
}

cd "$data_home"
save ehs-home-ehs, replace

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_ihdp"
use "merge-ihdp.dta", clear

rename ihdp	id

foreach num of numlist 1/45 {
	rename va`num'_f22	home12_`num'
	recode home12_`num' (2 = 0)
}

foreach num of numlist 1/55 {
	rename v`num'_f56	home36_`num'
}

* HOME total score
rename homto_12_sumscore	home_total12
rename homto_36_sumscore	home_total36

* HOME warmth
egen home_warm12 = rowtotal(home12_1 home12_2 home12_3 home12_8 home12_9 home12_10 home12_11), mi
egen home_warm36 = rowtotal(home36_17 home36_30 home36_31), mi

* HOME parental lack of hostility
egen home_nonpun12 = rowtotal(home12_12 home12_13 home12_14 home12_16 home12_17), mi

* HOME parental verbal skills
egen home_verb12 = rowtotal(home12_4 home12_5 home12_6), mi

* HOME harsh scale
recode home36_52 (1 = 0) (0 = 1)
recode home36_53 (1 = 0) (0 = 1)
recode home36_54 (1 = 0) (0 = 1)
egen home_harsh361 = rowtotal(home36_52 home36_53 home36_54), mi

* HOME internal environment
egen home_inenviro36 = rowtotal(home36_21 home36_25), mi

* HOME external environment
egen home_exenviro36 = rowtotal(home36_19 home36_20 home36_23), mi

* HOME lang & cog stimulation
egen home_lang12 = rowtotal(home12_18 home12_26 home12_27 home12_28 home12_29 home12_30 home12_31 home12_33 home12_34 home12_36 home12_42 home12_45), mi
egen home_lang36 = rowtotal(home36_3 home36_7 home36_8 home36_11 home36_13 home36_27 home36_28 home36_29 home36_33 home36_36 home36_48), mi

#delimit ;
keep id
home_total*
home_warm*
home_lang*
home_nonpun*
home_verb*
home_exenviro*
home_harsh*
home_inenviro*
;
#delimit cr

* Normalise to have in-group sample mean 0 and variance 1
foreach t of local ehs_home_types {
	foreach m of numlist 12 36 {
	capture egen norm_home_`t'`m' = std(home_`t'`m')
	}
}

cd "$data_home"
save ihdp-home-ehs, replace

* --------- *
* Abecedarian

cd "$data_abc"
use "append-abccare.dta", clear

* Recode 2 to 0

local age0to3	6 18 30
foreach age of local age0to3 {
	foreach n of numlist 1/45 {
		replace hs`age'i`n' = 0 if hs`age'i`n' > 1 & !missing(hs`age'i`n')
		rename hs`age'i`n'	home`age'_`n'
	}
}

local age3to6	42 54
foreach age of local age3to6 {
	foreach n of numlist 1/80 {
		replace hs`age'i`n' = 0 if hs`age'i`n' > 1 & !missing(hs`age'i`n')
		rename hs`age'i`n'	home`age'_`n'
	}
}

foreach n of numlist 1/85 {
	replace hsepi`n' = 0 if hsepi`n' > 1 & !missing(hsepi`n')
	rename hsepi`n'	home80_`n'
}

* HOME total score
rename home0y6m	home_total6
rename home1y6m	home_total18
rename home2y6m	home_total30
rename home3y6m	home_total42
rename home4y6m	home_total54
rename home8y	home_total80

foreach m of numlist 6 18 30 {
	* HOME warmth
	egen home_warm`m' = rowtotal(home`m'_1 home`m'_2 home`m'_3 home`m'_8 home`m'_9 home`m'_10 home`m'_11), mi
	
	* HOME parental lack of hostility
	egen home_nonpun`m' = rowtotal(home`m'_12 home`m'_13 home`m'_14 home`m'_16 home`m'_17), mi
	
	* HOME parental verbal skills
	egen home_verb`m' = rowtotal(home`m'_4 home`m'_5 home`m'_6), mi
		
	* HOME lang & cog stimulation
	egen home_lang`m' = rowtotal(home`m'_18 home`m'_26 home`m'_27 home`m'_28 home`m'_29 home`m'_30 home`m'_31 home`m'_33 home`m'_34 home`m'_36 home`m'_42 home`m'_45), mi
}

foreach m of numlist 42 54 {
	* HOME warmth
	egen home_warm`m' = rowtotal(home`m'_66 home`m'_65 home`m'_67), mi
		
	* HOME harsh scale
	recode home`m'_46 (1 = 0) (0 = 1)
	recode home`m'_47 (1 = 0) (0 = 1)
	recode home`m'_48 (1 = 0) (0 = 1)
	egen home_harsh`m' = rowtotal(home`m'_46 home`m'_47 home`m'_48), mi
	
	* HOME internal environment
	egen home_inenviro`m' = rowtotal(home`m'_36 home`m'_41), mi
	
	* HOME external environment
	egen home_exenviro`m' = rowtotal(home`m'_34 home`m'_35 home`m'_39), mi
	
	* HOME lang & cog stimulation
	egen home_lang`m' = rowtotal(home`m'_5 home`m'_12 home`m'_13 home`m'_23 home`m'_25 home`m'_61 home`m'_62 home`m'_22 home`m'_28 home`m'_42), mi
}

#delimit ;
keep id
treat
program
home_total*
home_warm*
home_lang*
home_nonpun*
home_verb*
home_exenviro*
home_harsh*
home_inenviro*
;
#delimit cr

* Normalise to have in-group sample mean 0 and variance 1
foreach t of local ehs_home_types {
	foreach y of numlist 6 18 30 42 54 {
	capture egen norm_home_`t'`y' = std(home_`t'`y')
	}
}

cd "$data_home"
save abc-home-ehs, replace
