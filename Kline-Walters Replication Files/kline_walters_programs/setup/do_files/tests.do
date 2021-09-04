********* THIS PROGRAM FORMATS THE TEST SCORE DATA ***********

***************************************************************
******** SET UP STATA *****************************************
***************************************************************


*Basic Stata setup
clear all
set mem 500m
cap set trace off
set more off

*Set working directories
local drive="/Users/Chris/projects/head_start"
local dict="`drive'/site_heterogeneity/programs/dictionaries"
local raw="`drive'/data/raw_data"
local statafiles="`drive'/data/stata_files"


*************************************************************
******* READ IN RAW FILES USING DICTIONARIES ****************
************************************************************

if `readraw'==1 {

	cd "`raw'"

	foreach f in 03 05 13 21 25 {
	
		clear
		infile using "`dict'/da29462-00`f'.dct"
		compress
		save "`statafiles'/da29462-00`f'.dta", replace

	}

}

*******************************************************
******* SET UP TEST SCORE FILES*************************
*******************************************************

******** TEST SCORE FILES *****************************

if `setup'==1 {

	********FALL 2002********************

	use "`statafiles'/da29462-0003.dta", clear

	*Define year
	gen year="_02"
	gen grade="BL"


	*PPVT percentile score
	gen ppvt_ptile=irt_ppvtstdzpct
	gen ppvt_irt=irt_ppvtml
	gen wj3_irt=s_wj3word_w

	*Define Macros
	local idvars = "grade hsis_raprogid hsis_racntrid hsis_childid childcohort childresultgroup crossover noshow period a1chage d_fallspr_testlang  d_ca_ageattesting year"
	local e_tests = "s_wj3oralcomprehension s_elisraw s_wj3spelling s_wj3applied"
	local s_tests = "s_tvipsfraw s_selisraw s_wmword s_wmdictation s_wmapplied"
	local es_tests = "s_ppvtsfraw s_colorscore s_drawscore s_wj3word s_bearscore s_bookscore"

	*Dummies for non-missing tests
	
	foreach x of varlist `es_tests' {
		gen has_`x'=`x'!=.
	}

	foreach x of varlist `s_tests' {
		gen has_`x'=`x'!=. if  d_fallspr_testlang==1
	}

	foreach x of varlist `e_tests' {
		gen has_`x'=`x'!=. if  d_fallspr_testlang==0
	}

	egen has_share=rowmean(has*)
	gen has_all=has_share==1
	


	keep `idvars' `e_tests' `s_tests' `es_tests' has_* ppvt* *wj*_w *wm*_w
	save "`statafiles'/fall2002long.dta", replace
	

	********SPRING 2003********************

	use "`statafiles'/da29462-0005.dta", clear

	*Define year
	gen year="_03"
	gen grade="PK1" if childcohort==3
	replace grade="PK2" if childcohort==4
	
	
	*PPVT percentile score
	gen ppvt_ptile=irt_ppvtstdzpct
	gen ppvt_irt=irt_ppvtml

	*Define Macros
	local idvars = "grade hsis_raprogid hsis_racntrid hsis_childid childcohort childresultgroup crossover noshow period a1chage d_fallspr_testlang  d_ca_ageattesting year"
	local s_tests = "s_tvipsfraw s_wmword"
	local es_tests = "s_wj3oralcomprehension s_elisraw s_wj3spelling s_wj3applied s_ppvtsfraw s_colorscore s_drawscore s_wj3word s_bearscore s_bookscore"

	*Dummies for non-missing tests
	
	foreach x of varlist `es_tests' {
		gen has_`x'=`x'!=.
	}

	foreach x of varlist `s_tests' {
		gen has_`x'=`x'!=. if  d_fallspr_testlang==1
	}

	egen has_share=rowmean(has*)
	gen has_all=has_share==1
	
	

	keep `idvars' `s_tests' `es_tests' has_* ppvt* *wj*_w *wm*_w
	save "`statafiles'/spring2003long.dta", replace

	********SPRING 2004********************

	use "`statafiles'/da29462-0013.dta", clear

	*Define year
	gen year="_04"
	gen grade="PK2" if childcohort==3
	replace grade="K" if childcohort==4

	*PPVT percentile score
	gen ppvt_ptile=irt_ppvtstdzpct
	gen ppvt_irt=irt_ppvtml
	
		
	*Define Macros
	local idvars = "grade hsis_raprogid hsis_racntrid hsis_childid childcohort childresultgroup crossover noshow period a1chage d_fallspr_testlang  d_ca_ageattesting year"

	local s_tests = "s_tvipsfraw s_wmword"
	local 3_tests = "s_colorscore s_drawscore s_bearscore s_bookscore"
	local 4_tests = "s_wj3wordattack s_wj3quantconcept s_wj3quantnumber s_writingsample"	
	local 34_tests = "s_ppvtsfraw s_wj3oralcomprehension s_elisraw s_letternamingscore s_wj3word s_wj3spelling s_wj3applied"

	*Dummies for non-missing tests
	
	foreach x of varlist `3_tests' {
		gen has_`x'=`x'!=. if childcohort==3
	}

	foreach x of varlist `4_tests' {
		gen has_`x'=`x'!=. if childcohort==4
	}

	foreach x of varlist `s_tests' {
		gen has_`x'=`x'!=. if  d_fallspr_testlang==1
	}

	foreach x of varlist `34_tests' {
		gen has_`x'=`x'!=.	
	}

	egen has_share=rowmean(has*)
	gen has_all=has_share==1

	keep `idvars' `s_tests' `3_tests' `4_tests' `34_tests' has_* ppvt* *wj*_w *wm*_w
	save "`statafiles'/spring2004long.dta", replace


	********SPRING 2005********************

	use "`statafiles'/da29462-0021.dta", clear

	*Define year
	gen year="_05"
	gen grade="K" if childcohort==3
	replace grade="1" if childcohort==4
	
	*PPVT percentile score
	gen ppvt_ptile=irt_ppvtstdzpct
	gen ppvt_irt=irt_ppvtml

			
	*Define Macros
	local idvars = "grade hsis_raprogid hsis_racntrid hsis_childid childcohort childresultgroup crossover noshow period a1chage d_fallspr_testlang  d_ca_ageattesting year"

	local s_tests = "s_tvipsfraw s_wmword"
	local 3_tests = "s_elisraw s_letternamingscore s_writingsample"
	local 4_tests = "s_wj3passagecomprehension s_wj3writingsample s_wj3calculation"	
	local 34_tests = "s_ppvtsfraw s_wj3oralcomprehension s_wj3wordattack s_wj3word s_wj3spelling s_wj3applied s_wj3quantconcept s_wj3quantnumber"

	*Dummies for non-missing tests
	
	foreach x of varlist `3_tests' {
		gen has_`x'=`x'!=. if childcohort==3
	}

	foreach x of varlist `4_tests' {
		gen has_`x'=`x'!=. if childcohort==4
	}

	foreach x of varlist `s_tests' {
		gen has_`x'=`x'!=. if  d_fallspr_testlang==1
	}

	foreach x of varlist `34_tests' {
		gen has_`x'=`x'!=.	
	}

	egen has_share=rowmean(has*)
	gen has_all=has_share==1

	keep `idvars' `s_tests' `3_tests' `4_tests' `34_tests' has_* ppvt* *wj*_w *wm*_w
	save "`statafiles'/spring2005long.dta", replace

	********SPRING 2006********************

	use "`statafiles'/da29462-0025.dta", clear

	*Define year
	gen year="_06"
	gen grade="1" if childcohort==3
	
	*PPVT percentile score
	gen ppvt_ptile=irt_ppvtstdzpct
	gen ppvt_irt=irt_ppvtml
	
	*Define Macros
	local idvars = "grade hsis_raprogid hsis_racntrid hsis_childid childcohort childresultgroup crossover noshow period a1chage d_fallspr_testlang  d_ca_ageattesting year"
	local s_tests = "s_tvipsfraw s_wmword"
	local es_tests = "s_ppvtsfraw s_wj3oralcomprehension s_wj3wordattack s_wj3word s_wj3passagecomprehension s_wj3spelling s_wj3writingsample s_wj3applied s_wj3quantconcept s_wj3quantnumber s_wj3calculation"

	*Dummies for non-missing tests
	
	foreach x of varlist `s_tests' {
		gen has_`x'=`x'!=. if  d_fallspr_testlang==1
	}

	foreach x of varlist `es_tests' {
		gen has_`x'=`x'!=.	
	}

	egen has_share=rowmean(has*)
	gen has_all=has_share==1

	keep `idvars' `s_tests' `es_tests' has_* ppvt* *wj*_w *wm*_w
	save "`statafiles'/spring2006long.dta", replace


	*******COMBINE TEST FILES**********************

	use "`statafiles'/fall2002long.dta", clear
	foreach n of numlist 2003/2006 {
		append using "`statafiles'/spring`n'long.dta"
	}

	save "`statafiles'/testscoreslong.dta", replace

}


********************************************************
******* CREATE STANDARDIZED TEST SCORE OUTCOMES ********
********************************************************

if `standardize'==1 {


	use "`statafiles'/testscoreslong.dta", clear


	foreach x of varlist s_* {
		gen c_`x'=.
		foreach cohort of numlist 3/4 {
			foreach year of numlist 2/6 {
			
				count if childresultgroup==3 & childcohort==`cohort' & year=="_0`year'"
				sum `x' if childresultgroup==3 & childcohort==`cohort' & year=="_0`year'"
				replace c_`x'=(`x'-r(mean))/r(sd) if childcohort==`cohort' & year=="_0`year'"
				
			}
		}
	}
	
	keep hsis_childid hsis_racntrid hsis_raprogid childcohort childresultgroup crossover noshow period ///
	c_s_* s_* has_s_* ppvt_ptile ppvt_irt grade d_fallspr_testlang *wj*_w *wm*_w
	
	egen Y=rmean(c_s_*)
	egen N_Y=rsum(has_s_*)
	gen t=""
	replace t="_02" if period=="FALL 2002"
	replace t="_03" if period=="SPRING 2003"
	replace t="_04" if period=="SPRING 2004"
	replace t="_05" if period=="SPRING 2005"
	replace t="_06" if period=="SPRING 2006"
	
	keep hsis_childid hsis_racntrid hsis_raprogid childcohort childresultgroup crossover noshow d_fallspr_testlang t Y N_Y c_s_ppvtsfraw ppvt_ptile ppvt_irt *wj*_w *wm*_w
	reshape wide Y N_Y c_s_ppvtsfraw ppvt_ptile ppvt_irt *wj*_w *wm*_w, i(hsis_childid) j(t) string
	gen X_baseline_cog=Y_02
	replace X_baseline_cog=. if X_baseline_cog==.
	save "`statafiles'/testscoreswide.dta", replace

	/*
	keep hsis_childid hsis_racntrid hsis_raprogid childcohort childresultgroup noshow crossover
	duplicates drop
	sort hsis_childid
	save "`statafiles'\adminvars.dta", replace
	*/

}
