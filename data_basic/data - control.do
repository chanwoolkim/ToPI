* ------------------------------------- *
* Preliminary data preparation - controls
* Author: Chanwool Kim
* Date Created: 22 Mar 2017
* Last Update: 14 Jan 2018
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

drop if missing(pag)

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
state
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

* ---- *
* Impute

foreach p in ehs ihdp abc {
	foreach t of global measure {
		cd "${data_`t'}"
		use `p'-`t'-control, clear
		
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
		
		save `p'-`t'-control, replace
	}
}
