* ------------------------------- *
* Data preparation - homogenisation
* Author: Chanwool Kim
* Date Created: 4 Jul 2017
* Last Update: 2 Nov 2017
* ------------------------------- *

clear all

label define mage 1 "Adult" 0 "Teenage"
label define medu 1 "Graduated high school or above" 0 "Some high school or below"
label define pov 1 "Over poverty line" 0 "Under poverty line"
label define race 1 "White" 0 "Non-white"

* -------------- *
* Early Head Start

cd "$data_ehs"
use "std-ehs.dta", clear

* Income
rename POV4 poverty
label var poverty "Poverty line (original data from EHS)"
label val poverty pov

keep id treat poverty

cd "$data_home"
merge 1:1 id using "ehs-home-control", nogen nolabel

* Mother's age
gen m_age_g = .
replace m_age_g = 1 if m_age >= 19 & !missing(m_age)
replace m_age_g = 0 if m_age <= 18 & !missing(m_age)
label var m_age_g "Mother's age at birth"
label val m_age_g mage

* Mother's education
gen m_edu_g = .
replace m_edu_g = 1 if m_edu >= 2 & !missing(m_edu)
replace m_edu_g = 0 if m_edu == 1 & !missing(m_edu)
label var m_edu_g "Mother's education"
label val m_edu_g medu

* Race
gen race_g = .
replace race_g = 1 if race == 1 & !missing(race)
replace race_g = 0 if race >= 2 & !missing(race)
label var race_g "Race (estimated from mother's race)"
label val race_g race

cd "${homo_path}/working"
save ehs-control-homo, replace

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_ihdp"
use "base-ihdp.dta", clear

rename admin_treat	treat
rename ihdp			id

gen income = .
replace income = 0 if (f_work40wk == 0 | f_work40wk == .) & (m_work4m == 0) & income == .

// Because income was divided in groups, we multiply by mean value of each group
replace income = 2500 if hh_inc1y_i61 == 1
replace income = 6250 if hh_inc1y_i61 == 2
replace income = 8750 if hh_inc1y_i61 == 3
replace income = 12500 if hh_inc1y_i61 == 4
replace income = 17500 if hh_inc1y_i61 == 5
replace income = 22500 if hh_inc1y_i61 == 6
replace income = 30000 if hh_inc1y_i61 == 7
replace income = 42500 if hh_inc1y_i61 == 8
replace income = 50000 if hh_inc1y_i61 == 9 // note this is unbounded, but does not change our analysis

rename hh_num1y hh_num

keep id treat income hh_num

// This is 1985, so divide according to poverty line guideline in 1985
gen poverty = .
replace poverty = 1 if !missing(income) & !missing(hh_num)
replace poverty = 0 if income <= 5250 // being conservative: regardless of value on number of people
replace poverty = 0 if income <= 7050 & hh_num == 2
replace poverty = 0 if income <= 8850 & hh_num == 3
replace poverty = 0 if income <= 10650 & hh_num == 4
replace poverty = 0 if income <= 12450 & hh_num == 5
replace poverty = 0 if income <= 14250 & hh_num == 6
replace poverty = 0 if income <= 16050 & hh_num == 7
replace poverty = 0 if income <= 17850 & hh_num == 8
replace poverty = 0 if income <= 19650 & hh_num == 9
replace poverty = 0 if income <= 21450 & hh_num == 10
replace poverty = 0 if income <= 23250 & hh_num == 11
replace poverty = 0 if income <= 25050 & hh_num == 12
replace poverty = 0 if income <= 26850 & hh_num == 13
replace poverty = 0 if income <= 28650 & hh_num == 14

label var poverty "Poverty line"
label val poverty pov

cd "$data_home"
merge 1:1 id using "ihdp-home-control", nogen nolabel

* Mother's age
gen m_age_g = .
replace m_age_g = 1 if m_age >= 19 & !missing(m_age)
replace m_age_g = 0 if m_age <= 18 & !missing(m_age)
label var m_age_g "Mother's age at birth"
label val m_age_g mage

* Mother's education
gen m_edu_g = .
replace m_edu_g = 1 if m_edu >= 3 & !missing(m_edu)
replace m_edu_g = 0 if m_edu <= 2 & !missing(m_edu)
label var m_edu_g "Mother's education"
label val m_edu_g medu

* Race
gen race_g = .
replace race_g = 1 if race == 2 & !missing(race)
replace race_g = 0 if race == 1 & !missing(race)
replace race_g = 0 if race >= 3 & !missing(race)
label var race_g "Race (estimated from mother's race)"
label val race_g race

cd "${homo_path}/working"
save ihdp-control-homo, replace

* --------- *
* Abecedarian

cd "$data_abc"
use "append-abccare.dta", clear

keep if program == "abc"
keep id treat income_c hh_num0y6m hh_sibs_base f_home0y
rename hh_num0y6m hh_num
rename f_home0y f_home
gen hh_child = hh_sibs_base + 1

/*
Notes
-----
The income codes come from the preschool codebooks. They define the codes as follows:

	1  = No income
	2  = Under $1000
	3  = $1000 to $2000
	4  = $2000 to $3000
	5  = $3000 to $4000
	6  = $4000 to $5000
	7  = $5000 to $6000
	8  = $6000 to $7000
	9  = $7000 to $8000
	10 = $8000 to $9000
	11 = $9000 to $10000
	12 = $10000 to $11000
	13 = $11000 to $12000
	14 = $12000 to $13000
	15 = $13000 to $14000
	16 = Over $14000
	17 = Unknown
*/

gen income = .
replace income = 0 if income_c == 1
replace income = 500 if income_c == 2
replace income = 1500 if income_c == 3
replace income = 2500 if income_c == 4
replace income = 3500 if income_c == 5
replace income = 4500 if income_c == 6
replace income = 5500 if income_c == 7
replace income = 6500 if income_c == 8
replace income = 7500 if income_c == 9
replace income = 8500 if income_c == 10
replace income = 9500 if income_c == 11
replace income = 10500 if income_c == 12
replace income = 11500 if income_c == 13
replace income = 12500 if income_c == 14
replace income = 13500 if income_c == 15
replace income = 14000 if income_c == 16

/*
Notes:
1. The ABC codebook describes income (income_c) as "parent's annual income". 
Thus, we don't know if it is pre/post taxes, if it includes
transfers, it it is earned income, who are the contributors, etc.

However, Peg Burchinal said to treat all ambiguous income as labor income.
*/

// This is 1972, so divide according to poverty line guideline in 1972
// https://www.census.gov/data/tables/time-series/demo/income-poverty/historical-poverty-thresholds.html
// Use "father at home" to instrument head of household
gen poverty = .
replace poverty = 1 if !missing(income) & !missing(hh_num)
replace poverty = 0 if income <= 2087 // being conservative: regardless of value on number of people
replace poverty = 0 if income <= 3159 & f_home == 1
replace poverty = 0 if income <= 3390 & f_home == 1 & hh_num == 3 & hh_child == 1
replace poverty = 0 if income <= 3583 & f_home == 1 & hh_num == 3 & hh_child >= 2
replace poverty = 0 if income <= 4393 & f_home == 1 & hh_num == 4 & hh_child == 1
replace poverty = 0 if income <= 4241 & f_home == 1 & hh_num == 4 & hh_child == 2
replace poverty = 0 if income <= 4456 & f_home == 1 & hh_num == 4 & hh_child >= 3
replace poverty = 0 if income <= 5287 & f_home == 1 & hh_num == 5 & hh_child == 1
replace poverty = 0 if income <= 5118 & f_home == 1 & hh_num == 5 & hh_child == 2
replace poverty = 0 if income <= 4989 & f_home == 1 & hh_num == 5 & hh_child == 3
replace poverty = 0 if income <= 5096 & f_home == 1 & hh_num == 5 & hh_child >= 4
replace poverty = 0 if income <= 6012 & f_home == 1 & hh_num == 6 & hh_child == 1
replace poverty = 0 if income <= 5885 & f_home == 1 & hh_num == 6 & hh_child == 2
replace poverty = 0 if income <= 5757 & f_home == 1 & hh_num == 6 & hh_child == 3
replace poverty = 0 if income <= 5586 & f_home == 1 & hh_num == 6 & hh_child == 4
replace poverty = 0 if income <= 5672 & f_home == 1 & hh_num == 6 & hh_child >= 5
replace poverty = 0 if income <= 7611 & f_home == 1 & hh_num >= 7 & hh_child == 1
replace poverty = 0 if income <= 7462 & f_home == 1 & hh_num >= 7 & hh_child == 2
replace poverty = 0 if income <= 7334 & f_home == 1 & hh_num >= 7 & hh_child == 3
replace poverty = 0 if income <= 7164 & f_home == 1 & hh_num >= 7 & hh_child == 4
replace poverty = 0 if income <= 6907 & f_home == 1 & hh_num >= 7 & hh_child == 5
replace poverty = 0 if income <= 6844 & f_home == 1 & hh_num >= 7 & hh_child >= 6
replace poverty = 0 if income <= 2845 & f_home == 0
replace poverty = 0 if income <= 3027 & f_home == 0 & hh_num == 3 & hh_child == 1
replace poverty = 0 if income <= 3348 & f_home == 0 & hh_num == 3 & hh_child >= 2
replace poverty = 0 if income <= 4306 & f_home == 0 & hh_num == 4 & hh_child == 1
replace poverty = 0 if income <= 4286 & f_home == 0 & hh_num == 4 & hh_child == 2
replace poverty = 0 if income <= 4241 & f_home == 0 & hh_num == 4 & hh_child >= 3
replace poverty = 0 if income <= 5139 & f_home == 0 & hh_num == 5 & hh_child == 1
replace poverty = 0 if income <= 5118 & f_home == 0 & hh_num == 5 & hh_child == 2
replace poverty = 0 if income <= 5075 & f_home == 0 & hh_num == 5 & hh_child == 3
replace poverty = 0 if income <= 4904 & f_home == 0 & hh_num == 5 & hh_child >= 4
replace poverty = 0 if income <= 5927 & f_home == 0 & hh_num == 6 & hh_child == 1
replace poverty = 0 if income <= 5885 & f_home == 0 & hh_num == 6 & hh_child == 2
replace poverty = 0 if income <= 5842 & f_home == 0 & hh_num == 6 & hh_child == 3
replace poverty = 0 if income <= 5650 & f_home == 0 & hh_num == 6 & hh_child == 4
replace poverty = 0 if income <= 5478 & f_home == 0 & hh_num == 6 & hh_child >= 5
replace poverty = 0 if income <= 7419 & f_home == 0 & hh_num >= 7 & hh_child == 1
replace poverty = 0 if income <= 7398 & f_home == 0 & hh_num >= 7 & hh_child == 2
replace poverty = 0 if income <= 7334 & f_home == 0 & hh_num >= 7 & hh_child == 3
replace poverty = 0 if income <= 7143 & f_home == 0 & hh_num >= 7 & hh_child == 4
replace poverty = 0 if income <= 6994 & f_home == 0 & hh_num >= 7 & hh_child == 5
replace poverty = 0 if income <= 6652 & f_home == 0 & hh_num >= 7 & hh_child >= 6

label var poverty "Poverty line"
label val poverty pov

cd "$data_home"
merge 1:1 id using "abc-home-control", nogen nolabel

* Mother's age
gen m_age_g = .
replace m_age_g = 1 if m_age >= 19 & !missing(m_age)
replace m_age_g = 0 if m_age <= 18 & !missing(m_age)
label var m_age_g "Mother's age at birth"
label val m_age_g mage

* Mother's education
gen m_edu_g = .
replace m_edu_g = 1 if m_edu >= 2 & !missing(m_edu)
replace m_edu_g = 0 if m_edu == 1 & !missing(m_edu)
label var m_edu_g "Mother's education"
label val m_edu_g medu

* Race
gen race_g = .
replace race_g = 1 if race == 2 & !missing(race)
replace race_g = 0 if race == 1 & !missing(race)
replace race_g = 0 if race == 3 & !missing(race)
label var race_g "Race (estimated from mother's race)"
label val race_g race

keep if program == "abc"

cd "${homo_path}/working"
save abc-control-homo, replace

* -- *
* CARE

cd "$data_abc"
use "append-abccare.dta", clear

keep if program == "care"
keep id treat income income_c hh_num0y hh_sibs_base f_home0y
rename hh_num0y hh_num
rename f_home0y f_home
gen hh_child = hh_sibs_base + 1

/*
Notes
-----
The income codes come from the preschool codebooks. They define the codes as follows:

	1  = No income
	2  = Under $1000
	3  = $1000 to $2000
	4  = $2000 to $3000
	5  = $3000 to $4000
	6  = $4000 to $5000
	7  = $5000 to $6000
	8  = $6000 to $7000
	9  = $7000 to $8000
	10 = $8000 to $9000
	11 = $9000 to $10000
	12 = $10000 to $11000
	13 = $11000 to $12000
	14 = $12000 to $13000
	15 = $13000 to $14000
	16 = Over $14000
	17 = Unknown
*/

replace income = 0 if income_c == 1 & income == .
replace income = 500 if income_c == 2 & income == .
replace income = 1500 if income_c == 3 & income == .
replace income = 2500 if income_c == 4 & income == .
replace income = 3500 if income_c == 5 & income == .
replace income = 4500 if income_c == 6 & income == .
replace income = 5500 if income_c == 7 & income == .
replace income = 6500 if income_c == 8 & income == .
replace income = 7500 if income_c == 9 & income == .
replace income = 8500 if income_c == 10 & income == .
replace income = 9500 if income_c == 11 & income == .
replace income = 10500 if income_c == 12 & income == .
replace income = 11500 if income_c == 13 & income == .
replace income = 12500 if income_c == 14 & income == .
replace income = 13500 if income_c == 15 & income == .
replace income = 14000 if income_c == 16 & income == .

/*
Notes:
1. The ABC codebook describes income (income_c) as "parent's annual income". 
Thus, we don't know if it is pre/post taxes, if it includes
transfers, it it is earned income, who are the contributors, etc.

However, Peg Burchinal said to treat all ambiguous income as labor income.
*/

// This is 1978, so divide according to poverty line guideline in 1978
// https://www.census.gov/data/tables/time-series/demo/income-poverty/historical-poverty-thresholds.html
// Use "father at home" to instrument head of household
gen poverty = .
replace poverty = 1 if !missing(income) & !missing(hh_num)
replace poverty = 0 if income <= 3253 // being conservative: regardless of value on number of people
replace poverty = 0 if income <= 4924 & f_home == 1
replace poverty = 0 if income <= 5284 & f_home == 1 & hh_num == 3 & hh_child == 1
replace poverty = 0 if income <= 5585 & f_home == 1 & hh_num == 3 & hh_child >= 2
replace poverty = 0 if income <= 6847 & f_home == 1 & hh_num == 4 & hh_child == 1
replace poverty = 0 if income <= 6610 & f_home == 1 & hh_num == 4 & hh_child == 2
replace poverty = 0 if income <= 6945 & f_home == 1 & hh_num == 4 & hh_child >= 3
replace poverty = 0 if income <= 8240 & f_home == 1 & hh_num == 5 & hh_child == 1
replace poverty = 0 if income <= 7976 & f_home == 1 & hh_num == 5 & hh_child == 2
replace poverty = 0 if income <= 7775 & f_home == 1 & hh_num == 5 & hh_child == 3
replace poverty = 0 if income <= 7943 & f_home == 1 & hh_num == 5 & hh_child >= 4
replace poverty = 0 if income <= 9370 & f_home == 1 & hh_num == 6 & hh_child == 1
replace poverty = 0 if income <= 9172 & f_home == 1 & hh_num == 6 & hh_child == 2
replace poverty = 0 if income <= 8973 & f_home == 1 & hh_num == 6 & hh_child == 3
replace poverty = 0 if income <= 8707 & f_home == 1 & hh_num == 6 & hh_child == 4
replace poverty = 0 if income <= 8841 & f_home == 1 & hh_num == 6 & hh_child >= 5
replace poverty = 0 if income <= 11863 & f_home == 1 & hh_num >= 7 & hh_child == 1
replace poverty = 0 if income <= 11630 & f_home == 1 & hh_num >= 7 & hh_child == 2
replace poverty = 0 if income <= 11430 & f_home == 1 & hh_num >= 7 & hh_child == 3
replace poverty = 0 if income <= 11166 & f_home == 1 & hh_num >= 7 & hh_child == 4
replace poverty = 0 if income <= 10766 & f_home == 1 & hh_num >= 7 & hh_child == 5
replace poverty = 0 if income <= 10667 & f_home == 1 & hh_num >= 7 & hh_child >= 6
replace poverty = 0 if income <= 4434 & f_home == 0
replace poverty = 0 if income <= 4717 & f_home == 0 & hh_num == 3 & hh_child == 1
replace poverty = 0 if income <= 5218 & f_home == 0 & hh_num == 3 & hh_child >= 2
replace poverty = 0 if income <= 6712 & f_home == 0 & hh_num == 4 & hh_child == 1
replace poverty = 0 if income <= 6681 & f_home == 0 & hh_num == 4 & hh_child == 2
replace poverty = 0 if income <= 6610 & f_home == 0 & hh_num == 4 & hh_child >= 3
replace poverty = 0 if income <= 8010 & f_home == 0 & hh_num == 5 & hh_child == 1
replace poverty = 0 if income <= 7976 & f_home == 0 & hh_num == 5 & hh_child == 2
replace poverty = 0 if income <= 7910 & f_home == 0 & hh_num == 5 & hh_child == 3
replace poverty = 0 if income <= 7643 & f_home == 0 & hh_num == 5 & hh_child >= 4
replace poverty = 0 if income <= 9238 & f_home == 0 & hh_num == 6 & hh_child == 1
replace poverty = 0 if income <= 9172 & f_home == 0 & hh_num == 6 & hh_child == 2
replace poverty = 0 if income <= 9105 & f_home == 0 & hh_num == 6 & hh_child == 3
replace poverty = 0 if income <= 8807 & f_home == 0 & hh_num == 6 & hh_child == 4
replace poverty = 0 if income <= 8538 & f_home == 0 & hh_num == 6 & hh_child >= 5
replace poverty = 0 if income <= 11564 & f_home == 0 & hh_num >= 7 & hh_child == 1
replace poverty = 0 if income <= 11530 & f_home == 0 & hh_num >= 7 & hh_child == 2
replace poverty = 0 if income <= 11430 & f_home == 0 & hh_num >= 7 & hh_child == 3
replace poverty = 0 if income <= 11133 & f_home == 0 & hh_num >= 7 & hh_child == 4
replace poverty = 0 if income <= 10901 & f_home == 0 & hh_num >= 7 & hh_child == 5
replace poverty = 0 if income <= 10368 & f_home == 0 & hh_num >= 7 & hh_child >= 6

label var poverty "Poverty line"
label val poverty pov

cd "$data_home"
merge 1:1 id using "abc-home-control", nogen nolabel

* Mother's age
gen m_age_g = .
replace m_age_g = 1 if m_age >= 19 & !missing(m_age)
replace m_age_g = 0 if m_age <= 18 & !missing(m_age)
label var m_age_g "Mother's age at birth"
label val m_age_g mage

* Mother's education
gen m_edu_g = .
replace m_edu_g = 1 if m_edu >= 2 & !missing(m_edu)
replace m_edu_g = 0 if m_edu == 1 & !missing(m_edu)
label var m_edu_g "Mother's education"
label val m_edu_g medu

* Race
gen race_g = .
replace race_g = 1 if race == 2 & !missing(race)
replace race_g = 0 if race == 1 & !missing(race)
replace race_g = 0 if race == 3 & !missing(race)
label var race_g "Race (estimated from mother's race)"
label val race_g race

keep if program == "care"

cd "${homo_path}/working"
save care-control-homo, replace
