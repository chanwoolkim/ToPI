* ------------------------------------- *
* Preliminary data preparation - controls
* Author: Chanwool Kim
* ------------------------------------- *

clear all

* -------------- *
* Early Head Start

cd "$data_raw"
use "std-ehs.dta", clear

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

rename POV4 poverty
label var poverty "Income Above Poverty line (original data from EHS)"
label val poverty pov

rename TOTHRSW hours_worked
rename WORKQ8 	m_work1
rename EVERWORK m_work2

rename home_total3 home3y_original 

#delimit ;
keep id
treat
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
poverty
hours_worked
m_work1
m_work2
home3y_original 
;
#delimit cr

cd "$data_working"
save ehs-control, replace

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_raw"
use "base-ihdp.dta", clear

rename admin_treat	treat
rename ihdp			id

** ** Poverty
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

label var poverty "Income Above Poverty line"
label val poverty pov
** **

* Control
gen bwg = .
replace bwg = 1 if bwg_sumscore == "H"
replace bwg = 0 if bwg_sumscore == "L"

rename m_age_base m_age
rename birth_mdeg m_edu
*AH: this is from the original .do files creating IHDP-base...
recode m_edu (1=1) (2=1) (3=2) (4=3) (5=3)
label define m_edu 1 "< 12th Grade" 2 "High School Graduate" 3 "Some College or more"
label values m_edu m_edu
rename hh_sibs0y sibling
rename m_iq0y m_iq

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

rename homto_36_sumscore home3y_original 

#delimit ;
keep id
treat
bwg
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
state
poverty
twin
pag
m_work3y
home3y_original 
;
#delimit cr

cd "$data_working"
save ihdp-control, replace

* ------ *
* ABC/CARE

cd "$data_raw"
use "append-abccare.dta", clear

* Control
rename m_age0y m_age
rename m_deg0y m_edu
rename m_iq0y m_iq
rename hh_sibs0y sibling
drop sex
rename male sex
rename f_home0y f_home


gen hispanic = .
replace hispanic = 1 if HISPANC2 == 1
replace hispanic = 0 if !missing(HISPANC2) & HISPANC2 != 1

gen bw = birthweight * 453.592

rename hh_num0y6m hh_num
gen hh_child = hh_sibs_base + 1

rename home3y6m home3y6m_original

#delimit ;
keep id
treat
random
program
m_age
m_edu
sibling
m_iq
race
black
hispanic
sex
gestage
f_home
bw
hh_child
hh_num
f_home
income
income_c
home3y6m_original
;
#delimit cr

cd "$data_working"
save abc-control, replace

** ** CARE
keep if program == "care"
drop treat
gen treat = random != 0
drop random

** ** Poverty
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
** **
** **
drop hh_child hh_num
rename f_home mf

save care-control, replace

** ** ABC
use abc-control, clear
keep if program == "abc"
drop random
drop income //(the original data_homo file did not keep it)
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
** **
rename f_home mf
drop hh_child hh_num
save abc-control, replace
** **

* ---- *
* Impute

foreach p in ehs ihdp abc care {
	cd "$data_working"
	use `p'-control, clear

	quietly { 
		reg m_age m_edu sibling m_iq race sex gestage mf
		local df_r = e(df_r)
		predict m_age_p, xb
		gen m_age_r = m_age - m_age_p
		qui sum m_age_r
		local var_r = r(Var)
		sum m_age_p
		replace m_age_p = r(mean) if missing(m_age_p)
		replace m_age_p = m_age_p + rnormal()*sqrt(`var_r'/`df_r')
		replace m_age = m_age_p if missing(m_age)

		reg m_edu m_age sibling m_iq race sex gestage mf
		local df_r = e(df_r)
		predict m_edu_p, xb
		gen m_edu_r = m_edu - m_edu_p
		qui sum m_edu_r
		local var_r = r(Var)
		sum m_edu_p
		replace m_edu_p = r(mean) if missing(m_edu_p)
		replace m_edu_p = m_edu_p + rnormal()*sqrt(`var_r'/`df_r')
		replace m_edu = m_edu_p if missing(m_edu)

		reg sibling m_age m_edu m_iq race sex gestage mf
		local df_r = e(df_r)
		predict sibling_p, xb
		gen sibling_r = sibling - sibling_p
		qui sum sibling_r
		local var_r = r(Var)
		sum sibling_p
		replace sibling_p = r(mean) if missing(sibling_p)
		replace sibling_p = sibling_p + rnormal()*sqrt(`var_r'/`df_r')
		replace sibling = sibling_p if missing(sibling)

		reg m_iq m_age m_edu sibling race sex gestage mf
		local df_r = e(df_r)
		predict m_iq_p, xb
		gen m_iq_r = m_iq - m_iq_p
		qui sum m_iq_r
		local var_r = r(Var)
		sum m_iq_p
		replace m_iq_p = r(mean) if missing(m_iq_p)
		replace m_iq_p = m_iq_p + rnormal()*sqrt(`var_r'/`df_r')
		replace m_iq = m_iq_p if missing(m_iq)

		reg race m_age m_edu sibling m_iq sex gestage mf
		local df_r = e(df_r)
		predict race_p, xb
		gen race_r = race - race_p
		qui sum race_r
		local var_r = r(Var)
		sum race_p
		replace race_p = r(mean) if missing(race_p)
		replace race_p = race_p + rnormal()*sqrt(`var_r'/`df_r')
		replace race = race_p if missing(race)

		reg sex m_age m_edu sibling m_iq race gestage mf
		local df_r = e(df_r)
		predict sex_p, xb
		gen sex_r = sex - sex_p
		qui sum sex_r
		local var_r = r(Var)
		sum sex_p
		replace sex_p = r(mean) if missing(sex_p)
		replace sex_p = sex_p + rnormal()*sqrt(`var_r'/`df_r')
		replace sex = sex_p if missing(sex)

		reg gestage m_age m_edu sibling m_iq race gestage mf
		local df_r = e(df_r)
		predict gestage_p, xb
		gen gestage_r = gestage - gestage_p
		qui sum gestage_r
		local var_r = r(Var)
		sum gestage_p
		replace gestage_p = r(mean) if missing(gestage_p)
		replace gestage_p = gestage_p + rnormal()*sqrt(`var_r'/`df_r')
		replace gestage = gestage_p if missing(gestage)

		reg mf m_age m_edu sibling m_iq race sex gestage
		local df_r = e(df_r)
		predict mf_p, xb
		gen mf_r = mf - mf_p
		qui sum mf_r
		local var_r = r(Var)
		sum mf_p
		replace mf_p = r(mean) if missing(mf_p)
		replace mf_p = mf_p + rnormal()*sqrt(`var_r'/`df_r')
		replace mf = mf_p if missing(mf)

		drop *_p *_r
	}

	save `p'-control, replace
}
