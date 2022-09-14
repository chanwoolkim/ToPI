* ------------------------------------------- *
* Preliminary data preparation - labor measures
* Author: Chanwool Kim
* ------------------------------------------- *

clear all

* -------------- *
* Early Head Start

cd "$data_raw"
use "std-ehs.dta", clear

* Household total income
rename hh_inc5 labor_hh_inc60
rename hh_inc10 labor_hh_inc120

* Mother currently employed
rename m_work0 labor_m_work0
rename EVERWORK labor_m_work26 // technically this is 0-26m, but will say this for now
rename m_work10 labor_m_work120

* Mother's average work hour
rename TOTHRSW labor_m_workhour26

#delimit ;
keep id
treat
labor_hh_inc*
labor_m_work*
;
#delimit cr

cd "$data_working"
save ehs-labor, replace

* --------- *
* Abecedarian

cd "$data_raw"
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

rename *0y *0
rename *1y6m *18
rename *2y6m *30
rename *3y6m *42
rename *4y6m *54
rename *8y *96
rename *12y *144
rename *15y *180
rename *5y *60
rename *21y *252

cd "$data_working"
save abc-labor, replace
