* ------------------------------------------- *
* Preliminary data preparation - labor measures
* Author: Chanwool Kim
* Date Created: 29 Jun 2017
* Last Update: 4 Mar 2017
* ------------------------------------------- *

clear all

* -------------- *
* Early Head Start

cd "$data_ehs"
use "std-ehs.dta", clear

* Household total income

rename hh_inc5	labor_hh_inc60
rename hh_inc10	labor_hh_inc120

* Mother currently employed
rename m_work0	labor_m_work0
rename EVERWORK	labor_m_work26 //technically this is 0-26m, but will say this for now
rename m_work10	labor_m_work120

* Mother's average work hour
rename TOTHRSW	labor_m_workhour26

#delimit ;
keep id
treat
labor_hh_inc*
labor_m_work*
;
#delimit cr

cd "$data_labor"
save ehs-labor-item, replace

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_ihdp"
use "base-ihdp.dta", clear

rename admin_treat	treat
rename ihdp			id

* Household total income
foreach age in 1y 2y 3y 4y 5y 6y6m 8y {
	rename hh_inc`age' labor_hh_inc`age'
}

* Household labor income
gen labor_hh_wage2y = .
gen labor_hh_wage3y = .
gen labor_hh_wage4y = .
gen labor_hh_wage5y = .
gen labor_hh_wage6y6m = .
gen labor_hh_wage8y = .

local inc2y 	hh_inc2y_i63a
local inc3y 	hh_inc3y_i95a
local inc4y 	hh_inc4y_i99a
local inc5y 	hh_inc5y_i100a
local inc6y6m 	hh_inc6y6m_i107a
local inc8y 	hh_inc8y_i92a

* Inflation is calculated using the BLS' inflation calculator:
* http://data.bls.gov/cgi-bin/cpicalc.pl

local inf2y 	2.14
local inf3y 	2.07
local inf4y 	1.98
local inf5y 	1.89	// 1989-to-2015 multiplier
local inf6y6m 	1.76	// midpoint between 1990 and 1991 multiplier
local inf8y		1.67	// 1992-to-2015 multiplier

foreach age in 2y 3y 4y 5y 6y6m 8y {
	replace labor_hh_wage`age' = 2500 * `inf`age'' if `inc`age'' == 1
	replace labor_hh_wage`age' = 6250 * `inf`age'' if `inc`age'' == 2
	replace labor_hh_wage`age' = 8750 * `inf`age'' if `inc`age'' == 3
	replace labor_hh_wage`age' = 12500 * `inf`age'' if `inc`age'' == 4
	replace labor_hh_wage`age' = 17500 * `inf`age'' if `inc`age'' == 5
	replace labor_hh_wage`age' = 22500 * `inf`age'' if `inc`age'' == 6
	replace labor_hh_wage`age' = 30000 * `inf`age'' if `inc`age'' == 7
	replace labor_hh_wage`age' = 42500 * `inf`age'' if `inc`age'' == 8
	replace labor_hh_wage`age' = 50000 * `inf`age'' if `inc`age'' == 9
	
	label var labor_hh_wage`age' "Household year labor income (2015 USD), age `age'"
	sum labor_hh_wage`age'
}

* Mother currently employed
foreach age in 1y6m 2y 2y6m 3y 40wk 4m 4y 5y 6y6m 8m 8y {
	rename m_work`age' labor_m_work`age'
}

* Mother's average work hour
foreach age in 1y6m 2y 2y6m 3y 4y 5y 6y6m 8y {
	rename m_workhour`age' labor_m_workhour`age'
}

* Father currently employed
foreach age in 40wk 1y 2y 3y 4y 5y 6y6m 8y {
	rename f_work`age' labor_f_work`age'
}

#delimit ;
keep id
treat
labor_hh_inc*
labor_hh_wage*
labor_m_work*
labor_m_workhour*
labor_f_work*
;
#delimit cr

rename *40wk	*0
rename *4m		*4
rename *8m		*8
rename *1y		*12
rename *1y6m	*18
rename *2y		*24
rename *2y6m	*30
rename *3y		*36
rename *4y		*48
rename *5y		*60
rename *6y6m	*78
rename *8y		*96

cd "$data_labor"
save ihdp-labor-item, replace

* --------- *
* Abecedarian

cd "$data_abc"
use "append-abccare.dta", clear

* Household total income
foreach age in 0y 8y 12y 15y {
	rename hh_inc`age' labor_hh_inc`age'
}

* Household labor income
foreach age in 0y 1y6m 2y6m 3y6m 4y6m 5y 8y 12y 15y 21y {
	rename p_inc`age' labor_hh_wage`age'
}

* Mother currently employed
foreach age in 0y 1y6m 2y6m 3y6m 4y6m 5y 12y 21y {
	rename m_work`age' labor_m_work`age'
}

* Father currently employed
foreach age in 0y 21y {
	rename f_work`age' labor_f_work`age'
}

#delimit ;
keep id
treat
program
labor_hh_inc*
labor_hh_wage*
labor_m_work*
labor_f_work*
;
#delimit cr

rename *0y		*0
rename *1y6m	*18
rename *2y6m	*30
rename *3y6m	*42
rename *4y6m	*54
rename *8y		*96
rename *12y		*144
rename *15y		*180
rename *5y		*60
rename *21y		*252

cd "$data_labor"
save abc-labor-item, replace
