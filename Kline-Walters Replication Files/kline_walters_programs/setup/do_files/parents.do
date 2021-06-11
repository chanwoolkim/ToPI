********* THIS PROGRAM FORMATS THE PARENT INTERVIEW DATA ***********

***************************************************************
******** SET UP STATA *****************************************
***************************************************************

*Basic Stata setup
clear all
set mem 500m
set more off

*Set working directories
local drive="/Users/Chris/projects/head_start"
local dict="`drive'/site_heterogeneity/programs/dictionaries"
local raw="`drive'/data/raw_data"
local statafiles="`drive'/data/stata_files"

*Switches to choose which parts of program to run
local readraw=1
local setup=1
local standardize=1

*************************************************************
******* READ IN RAW FILES USING DICTIONARIES ****************
************************************************************

if `readraw'==1 {

	cd "`raw'"

	foreach f in 02 04 06 14 22 26 02 {
	
		clear
		infile using "`dict'/da29462-00`f'.dct"
		compress
		save "`statafiles'/da29462-00`f'.dta", replace
	
	}

}

*******************************************************
******* SET UP PARENT INTERVIEW FILES *****************
*******************************************************

if `setup'==1 {

	******Demographic file********************
	use "`statafiles'/da29462-0002.dta", clear
	gen X_bothparents=d_bbio_withch
	gen X_male=d_cf_chsex01==0
	gen X_black=d_chrace3==2
	gen X_hisp=d_chrace3==3
	gen X_spanish=d_lang_hm==1
	gen X_mom_dropout=d_mothhighed3==1
	gen X_mom_college=d_mothhighed3==3
	gen X_mom_married=d_moth_marstat==2
	gen X_sped=d_pi_specneeds_f02==1
	gen X_mom_teen=d_teenmom==1
	gen X_urban=d_urban==1
	keep hsis_childid X_*
	save "`statafiles'/baseline_demos_temp.dta", replace
	
	
	******BASELINE Survey for income**********
	use "`statafiles'/da29462-0004.dta", clear
	gen faminc=p1allin if p1allin!=. & p1allin!=99999 & p1allin!=99998 & p1allin!=99997
	gen X_loginc=log(faminc)
	gen X_m_loginc=X_loginc==.
	replace X_loginc=0 if X_loginc==.
	gen X_income=exp(X_loginc) if X_m_loginc!=1
	replace X_income=125 if X_income==. & p1inall==2
	replace X_income=375 if X_income==. & p1inall==3
	replace X_income=1250 if X_income==. & p1inall==4
	replace X_income=1750 if X_income==. & p1inall==5
	replace X_income=2250 if X_income==. & p1inall==6
	replace X_income=2500 if X_income==. & p1inall==7
	gen X_m_income=X_income==.
	replace X_income=0 if X_income==.	
	gen adults_hh=p1adinh if p1adinh<97 & p1adinh!=.
	gen kids_hh=p1chinh if p1chinh<97 & p1chinh!=.
	gen mother_work=p1workmo if p1workmo<97 & p1workmo!=.
	keep hsis_childid faminc X_* adults_hh kids_hh mother_work
	merge 1:1 hsis_childid using "`statafiles'/baseline_demos_temp.dta"
	drop _merge
	save "`statafiles'/baseline_demos.dta", replace


	*******************************************************************
	***** YEARLY FILES ON HS PARTICIPATION, NONCOG OUTCOMES, AND HEALTH STATUS **********

	local y=2
	foreach n in 04 06 14 22 26 {

		use "`statafiles'/da29462-00`n'.dta", clear
		
	
		*tag period
		gen year="_0`y'"
	
		*Drop non-respondents (these people answered no questions)
		drop if p1mo==.
	
		******HEAD START QUESTIONS****************
		cap gen hs_enroll=p3enrol==1 if p3enrol!=9 & p3enrol!=.
		gen arrangement_parent=""
		replace arrangement_parent="H" if d_focarr==7 & d_focarr!=.
		replace arrangement_parent="P" if (d_focarr==1 | d_focarr>=8) & d_focarr!=.
		replace arrangement_parent="N" if (d_focarr!=1 & d_focarr<7) & d_focarr!=.
		
		****NONCOGNITIVE QUESTIONS:  EDIT THIS, AND GET SIGNS RIGHT
		gen noncog_takes_care=p4belong==1 if p4belong!=8 & p4belong!=9 & p4belong!=.
		gen noncog_asks_help=p4assist==1 if p4assist!=8 & p4assist!=9 & p4assist!=.
		gen noncog_helps_tasks=p4helps==1 if p4helps!=8 & p4helps!=9 & p4helps!=.
		gen noncog_makes_friends=p1freas==1 if p1freas!=8 & p1freas!=9 & p1freas!=.
		gen noncog_enjoys_learning=p1enjlr==1 if p1enjlr!=8 & p1enjlr!=9 & p1enjlr!=.
		gen noncog_tempter_tantrums=-1*(p1tempr==1) if p1tempr!=8 & p1tempr!=9 & p1tempr!=.
		gen noncog_cant_concentrate=-1*(p1noatt==1) if p1noatt!=8 & p1noatt!=9 & p1noatt!=.
		gen noncog_restless=-1*(p1fidgt==1) if p1fidgt!=8 & p1fidgt!=9 & p1fidgt!=.
		gen noncog_imagination=p1imagi==1 if p1imagi!=8 & p1imagi!=9 & p1imagi!=.
		gen noncog_hits=-1*(p1fight==1) if p1fight!=8 & p1fight!=9 & p1fight!=. 
		gen noncog_accepts_ideas=p1fride==1 if p1fride!=8 & p1fride!=9 & p1fride!=.

		***Special ed status
		gen special_doctor=p1doc==1 if p1doc!=8 & p1doc!=9 & p1doc!=.
		
		foreach x of varlist noncog_* {
			gen has_`x'=`x'!=.
		}
		
		gen hs_temp=1
		keep hsis_childid childcohort childresultgroup has_* year hs_* noncog_* arrangement_parent special_doctor
		drop hs_temp
		sort hsis_childid
		save "`statafiles'/parentsurveylong_0`y'.dta", replace
		local ++y
	}

}


*******************************************************
****** STACK OUTCOME DATA ****************************
*******************************************************

if `standardize'==1 {


	****PARENTS SURVEY:  NONCOG

	use "`statafiles'/parentsurveylong_02.dta", clear
	foreach n of numlist 3/6 {
		append using "`statafiles'/parentsurveylong_0`n'.dta"
	}
	
	
	****EXTRACT PARENT-REPORTED HS ENROLLMENT
	preserve
	keep hsis_childid year hs_enroll arrangement_parent
	reshape wide hs_enroll arrangement_parent, i(hsis_childid) j(year) string
	sort hsis_childid
	save "`statafiles'/parent_reported_enrollment.dta", replace
	restore
	
	***PARENTS SURVEY:  RESHAPE FOR NONCOG OUTCOMES
		
	gen grade="PK1"
	replace grade="BL" if (childcohort==4 & year=="_02") | (childcohort==3 & year=="_02")
	replace grade="PK1" if childcohort==3 & year=="_03"
	replace grade="PK2" if (childcohort==4 & year=="_03") | (childcohort==3 & year=="_04")
	replace grade="K" if (childcohort==4 & year=="_04") | (childcohort==3 & year=="_05")
	replace grade="1" if (childcohort==4 & year=="_05") | (childcohort==3 & year=="_06")
	foreach x of varlist noncog_* {
		gen c_`x'=.
		foreach cohort of numlist 3/4 {
			foreach year of numlist 2/6 {
			
				count if childresultgroup==3 & childcohort==`cohort' & year=="_0`year'"
				sum `x' if childresultgroup==3 & childcohort==`cohort' & year=="_0`year'"
				replace c_`x'=(`x'-r(mean))/r(sd) if childcohort==`cohort' & year=="_0`year'"
				
			}
		}
	}
	keep hsis_childid c_* has_* year special_doctor
	egen Y_noncog=rmean(c_*)
	egen N_Y_noncog=rsum(has_*)
	gen t=year
	


	
	
	keep hsis_childid Y_noncog N_Y_noncog t special_doctor
	reshape wide Y_noncog N_Y_noncog special_doctor, i(hsis_childid) j(t) string
	gen X_baseline_noncog=Y_noncog_03
	gen X_m_baseline_noncog=X_baseline_noncog==.
	replace X_baseline_noncog=0 if X_baseline_noncog==.
	save "`statafiles'/noncogwide.dta", replace

}

