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
rename P2V_ENG2 D
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

* Poverty and mother's education
tab poverty
tab m_edu
gen hs=.
replace hs=1 if m_edu==1 | m_edu==2
replace hs=2 if m_edu==3		
gen H=.
replace H=4140/6000 if D==1
replace H=0 if D==0
* https://eclkc.ohs.acf.hhs.gov/programs/article/early-head-start-program-options
gen twin=0

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
hs
H
twin
;
#delimit cr

cd "$data_working"
save ehs-control, replace

* --------- *
* Abecedarian

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

keep if program == "abc"
drop random
drop income

/*
	   Notes
	   -----
	   The income codes come from the preschool codebooks.
	   They define the codes as follows:

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
	   1. The ABC codebook describes income (income_c) as "parent's annual income."
	   Thus, we do not know if it is pre/post taxes, if it includes transfers,
	   if it is earned income, who are the contributors, etc.

	   However, Peg Burchinal said to treat all ambiguous income as labor income.

	   This is 1972, so divide according to the poverty line guideline in 1972
	   https://www.census.gov/data/tables/time-series/demo/income-poverty/historical-poverty-thresholds.html
	   Use "father at home" to instrument head of household
*/

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

rename f_home mf
drop hh_child hh_num

cd "$data_working"
save abc-control, replace

* ---- *
* Impute

foreach p in $programs {
	cd "$data_working"
	use `p'-control, clear

	quietly { 
		reg m_age m_edu sibling m_iq black sex gestage mf
		local df_r = e(df_r)
		predict m_age_p, xb
		gen m_age_r = m_age - m_age_p
		qui sum m_age_r
		local var_r = r(Var)
		sum m_age_p
		replace m_age_p = r(mean) if missing(m_age_p)
		replace m_age_p = m_age_p + rnormal()*sqrt(`var_r'/`df_r')
		replace m_age = m_age_p if missing(m_age)

		reg m_edu m_age sibling m_iq black sex gestage mf
		local df_r = e(df_r)
		predict m_edu_p, xb
		gen m_edu_r = m_edu - m_edu_p
		qui sum m_edu_r
		local var_r = r(Var)
		sum m_edu_p
		replace m_edu_p = r(mean) if missing(m_edu_p)
		replace m_edu_p = m_edu_p + rnormal()*sqrt(`var_r'/`df_r')
		replace m_edu = m_edu_p if missing(m_edu)

		reg sibling m_age m_edu m_iq black sex gestage mf
		local df_r = e(df_r)
		predict sibling_p, xb
		gen sibling_r = sibling - sibling_p
		qui sum sibling_r
		local var_r = r(Var)
		sum sibling_p
		replace sibling_p = r(mean) if missing(sibling_p)
		replace sibling_p = sibling_p + rnormal()*sqrt(`var_r'/`df_r')
		replace sibling = sibling_p if missing(sibling)

		reg m_iq m_age m_edu sibling black sex gestage mf
		local df_r = e(df_r)
		predict m_iq_p, xb
		gen m_iq_r = m_iq - m_iq_p
		qui sum m_iq_r
		local var_r = r(Var)
		sum m_iq_p
		replace m_iq_p = r(mean) if missing(m_iq_p)
		replace m_iq_p = m_iq_p + rnormal()*sqrt(`var_r'/`df_r')
		replace m_iq = m_iq_p if missing(m_iq)

		reg black m_age m_edu sibling m_iq sex gestage mf
		local df_r = e(df_r)
		predict black_p, xb
		gen black_r = black - black_p
		qui sum black_r
		local var_r = r(Var)
		sum black_p
		replace black_p = r(mean) if missing(black_p)
		replace black_p = black_p + rnormal()*sqrt(`var_r'/`df_r')
		replace black = black_p if missing(black)

		reg sex m_age m_edu sibling m_iq black gestage mf
		local df_r = e(df_r)
		predict sex_p, xb
		gen sex_r = sex - sex_p
		qui sum sex_r
		local var_r = r(Var)
		sum sex_p
		replace sex_p = r(mean) if missing(sex_p)
		replace sex_p = sex_p + rnormal()*sqrt(`var_r'/`df_r')
		replace sex = sex_p if missing(sex)

		reg gestage m_age m_edu sibling m_iq black gestage mf
		local df_r = e(df_r)
		predict gestage_p, xb
		gen gestage_r = gestage - gestage_p
		qui sum gestage_r
		local var_r = r(Var)
		sum gestage_p
		replace gestage_p = r(mean) if missing(gestage_p)
		replace gestage_p = gestage_p + rnormal()*sqrt(`var_r'/`df_r')
		replace gestage = gestage_p if missing(gestage)

		reg mf m_age m_edu sibling m_iq black sex gestage
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
