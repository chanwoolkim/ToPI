* --------------------------------------------------------------------------------------------------------- *
* Mediation analysis																						*
* Author: Chanwool Kim																						*
* Last upgrade Jan 2021 by AH																				*
* output:																									*
	*long_prod_ME	production function estimates with an interaction, correcting for measurement error		*			
	*short_prod_ME	production function estimates with an interaction, correcting for measurement error		*
	*short_med_NME	mediation estimates, not correcting for measurement error								*
* -------------------------------------------------------------------------------------------------------- 	*

*create matrices within the loop

***************************
* Set Matrices and macros *
***************************
* NOTATION:
*prod: 		production function
*med:		mediation
*long:		using an interaction
*short:		not using an interaction
*ME:		correcting for measurement error
*NME		not correcting for measurement error

clear all
global bsamples 101
set matsize $bsamples
local program_names_rownames ""EHS(Center) - PPVT" "EHS(Home) - PPVT" "EHS(Mixed) - PPVT" "EHS(All) - PPVT" "IHDP - PPVT" "IHDP - SB" "ABC - SB" "CARE (Both) - SB" "CARE (Home) - SB" "CARE (All) - SB""
local long_prod_colnames 	theta theta_dup R R_dup theta_R theta_R_dup
local short_prod_colnames 	theta theta_dup R R_dup

*Long Production Function ME
qui matrix long_prod_ME_coef_se = J(10, 6, .)
qui matrix colnames long_prod_ME_coef_se = `long_prod_colnames'
qui matrix rownames long_prod_ME_coef_se = `program_names_rownames'
qui matrix long_prod_ME_p = J(10, 6, .)
qui matrix colnames long_prod_ME_p = `long_prod_colnames'
qui matrix rownames long_prod_ME_p = `program_names_rownames'

*Long Production Function NME
qui matrix long_prod_NME_coef_se = J(10, 6, .)
qui matrix colnames long_prod_NME_coef_se = `long_prod_colnames' //same names
qui matrix rownames long_prod_NME_coef_se = `program_names_rownames'
qui matrix long_prod_NME_p = J(10, 6, .)
qui matrix colnames long_prod_NME_p = `long_prod_colnames'
qui matrix rownames long_prod_NME_p = `program_names_rownames'

*Short Production Function ME
qui matrix short_prod_ME_coef_se = J(10, 4, .)
qui matrix colnames short_prod_ME_coef_se = `short_prod_colnames'
qui matrix rownames short_prod_ME_coef_se = `program_names_rownames'
qui matrix short_prod_ME_p = J(10, 4, .)
qui matrix colnames short_prod_ME_p = `short_prod_colnames'
qui matrix rownames short_prod_ME_p = `program_names_rownames'

*Short Production Function NME
qui matrix short_prod_NME_coef_se = J(10, 4, .)
qui matrix colnames short_prod_NME_coef_se = `short_prod_colnames'
qui matrix rownames short_prod_NME_coef_se = `program_names_rownames'
qui matrix short_prod_NME_p = J(10, 4, .)
qui matrix colnames short_prod_NME_p = `short_prod_colnames'
qui matrix rownames short_prod_NME_p = `program_names_rownames'

*Short Mediation ME
qui matrix short_med_ME = J(10, 7, .)
qui matrix colnames short_med_ME = program outcome estimate_all estimate_ind_outcome estimate_ind_mediator ci_lower ci_upper

*Short Mediation NME
qui matrix short_med_NME = J(10, 7, .)
qui matrix colnames short_med_NME = program outcome estimate_all estimate_ind_outcome estimate_ind_mediator ci_lower ci_upper

*Define Macros for estimation
global programs ""ehscenter" "ehshome" "ehsmixed" "ehs" `"ihdp_ppvt"' `"ihdp_sb"' "abc" "careboth" "carehome" "care""

local y_ehscenter 	ppvt36
local y_ehshome 	ppvt36
local y_ehsmixed 	ppvt36
local y_ehs 		ppvt36
local y_ihdp_ppvt 	ppvt36
local y_ihdp_sb		sb36
local y_abc 		sb48
local y_careboth 	sb48
local y_carehome 	sb48
local y_care 		sb48

local I_ehscenter 	theta36
local I_ehshome 	theta36
local I_ehsmixed 	theta36
local I_ehs 		theta36
local I_ihdp_ppvt 	theta36
local I_ihdp_sb		theta36
local I_abc 		theta42
local I_careboth 	theta42
local I_carehome 	theta42
local I_care 		theta42

local z1_ehscenter 	theta24
local z1_ehshome 	theta24
local z1_ehsmixed 	theta24
local z1_ehs 		theta24
local z1_ihdp_ppvt 	theta12
local z1_ihdp_sb	theta12
local z1_abc 		theta30
local z1_careboth 	theta30
local z1_carehome 	theta30
local z1_care 		theta30

local z2_ehscenter 	theta14
local z2_ehshome 	theta14
local z2_ehsmixed 	theta14
local z2_ehs 		theta14
local z2_abc 		theta18
local z2_careboth 	theta18
local z2_carehome 	theta18
local z2_care 		theta18

*NO instrument 3 ? this is different from Chanwool's code

local data_ehscenter	ehscenter
local data_ehshome 		ehshome
local data_ehsmixed 	ehsmixed
local data_ehs 			ehs
local data_ihdp_ppvt	ihdp
local data_ihdp_sb		ihdp
local data_abc 			abc
local data_careboth 	careboth
local data_carehome 	carehome
local data_care 		care

foreach t of global programs{
local I_R_`t'	`I_`t''_R
local z1_R_`t'	`z1_`t''_R
local z2_R_`t'	`z2_`t''_R
}

*******************
* Estimation Loop *
*******************

local row = 1
local program_num = 1

foreach t of global programs {
	cd "$data_working"
	use "`data_`t''-merge-imputations.dta", clear
	
*I. Long Production function with ME:
	ivregress 2sls `y_`t'' (`I_`t'' `I_R_`t'' = `z1_`t'' `z1_R_`t'' `z2_`t'' ``z2_`t''_R') R $covariates, vce(robust)

		matrix list r(table)
		matrix r = r(table)
		matrix long_prod_ME_coef_se[`row',1] = r[1,1]		//Theta
		matrix long_prod_ME_coef_se[`row',2] = r[2,1]		
		matrix long_prod_ME_coef_se[`row',3] = r[1,3]		//R
		matrix long_prod_ME_coef_se[`row',4] = r[2,3]
		matrix long_prod_ME_coef_se[`row',5] = r[1,2]		//Inter
		matrix long_prod_ME_coef_se[`row',6] = r[2,2]
		matrix long_prod_ME_p[`row',1] = r[4,1]				//Theta on 1
		matrix long_prod_ME_p[`row',3] = r[4,3]				//R		on 3
		matrix long_prod_ME_p[`row',5] = r[4,2]				//Inter	on 5

*II. Long Production function without ME:
	ivregress 2sls `y_`t'' `I_`t'' `I_R_`t'' R $covariates, vce(robust)

		matrix list r(table)
		matrix r = r(table)
		matrix long_prod_NME_coef_se[`row',1] = r[1,1]
		matrix long_prod_NME_coef_se[`row',2] = r[2,1]		
		matrix long_prod_NME_coef_se[`row',3] = r[1,3]
		matrix long_prod_NME_coef_se[`row',4] = r[2,3]
		matrix long_prod_NME_coef_se[`row',5] = r[1,2]
		matrix long_prod_NME_coef_se[`row',6] = r[2,2]
		matrix long_prod_NME_p[`row',1] = r[4,1]
		matrix long_prod_NME_p[`row',3] = r[4,3]
		matrix long_prod_NME_p[`row',5] = r[4,2]
		
*III. Short Production function with ME
	ivregress 2sls `y_`t'' (`I_`t'' = `z1_`t'' `z2_`t'') R $covariates, vce(robust)

		matrix list r(table)
		matrix r = r(table)
		matrix short_prod_ME_coef_se[`row',1] = r[1,1]	//Theta
		matrix short_prod_ME_coef_se[`row',2] = r[2,1]
		matrix short_prod_ME_coef_se[`row',3] = r[1,2]	//R
		matrix short_prod_ME_coef_se[`row',4] = r[2,2]
		matrix short_prod_ME_p[`row',1] = r[4,1]			//Theta	on 1
		matrix short_prod_ME_p[`row',3] = r[4,2]			//R		on 3 (there was a mistake here)

*IV. Short Production function without ME
	ivregress 2sls `y_`t'' `I_`t'' R $covariates, vce(robust)

		matrix list r(table)
		matrix r = r(table)
		matrix short_prod_NME_coef_se[`row',1] = r[1,1]
		matrix short_prod_NME_coef_se[`row',2] = r[2,1]
		matrix short_prod_NME_coef_se[`row',3] = r[1,2]
		matrix short_prod_NME_coef_se[`row',4] = r[2,2]
		matrix short_prod_NME_p[`row',1] = r[4,1]
		matrix short_prod_NME_p[`row',3] = r[4,2]
			
*V. Short Mediation with ME
	matrix short_med_ME[`row',1] = `program_num'
	matrix short_med_ME[`row',2] = 1
	qui matrix `t'_OUT_ME = J($bsamples, 3, .)
	qui matrix colnames `t'_OUT_ME = `t'_OUT_ME_all `t'_OUT_ME_ind_outcome `t'_OUT_ME_ind_mediator

*VI. Short Mediation without ME
	matrix short_med_NME[`row',1] = `program_num'
	matrix short_med_NME[`row',2] = 1
	qui matrix `t'_OUT_NME = J($bsamples, 3, .)
	qui matrix colnames `t'_OUT_NME = `t'_OUT_NME_all `t'_OUT_NME_ind_outcome `t'_OUT_NME_ind_mediator
	
	*Boootstrap CI for mediation, it repeats several of the previous commands
	local bottom=round($bsamples*0.025)
	local top=round($bsamples*0.975)

	forvalues b = 1/$bsamples {
		di "sample: `t' `b'"
		preserve
		if `b'==1 di "Original Sample"
		else bsample

	*ME
			qui ivregress 2sls `y_`t'' (`I_`t'' = `z1_`t'' `z2_`t'') R $covariates, vce(robust)		
			if `b'==1	matrix short_med_ME[`row',4] 	= _b[`I_`t'']		//Theta
			else qui 	matrix `t'_OUT_ME[`b',2] 	 	= _b[`I_`t'']		//`t'_OUT_ind_outcome [effect of investment on outcome]

	*NME
			qui ivregress 2sls `y_`t'' `I_`t'' R $covariates, vce(robust)		
			if `b'==1	matrix short_med_NME[`row',4] 	= _b[`I_`t'']	//Theta
			else qui 	matrix `t'_OUT_NME[`b',2] 		= _b[`I_`t'']	//`t'_OUT_ind_outcome [effect of investment on outcome]
	*Both
			qui reg `y_`t'' R $covariates, robust													
			if `b'==1	{
						matrix short_med_ME[`row',3] 	= _b[R]
						matrix short_med_NME[`row',3]  	= _b[R]
						}
			else qui 	{
						matrix `t'_OUT_ME[`b',1]  		= _b[R]		//`t'_OUT_all [Not used]
						matrix `t'_OUT_NME[`b',1] 		= _b[R]		//`t'_OUT_all [Not used]
						}

			qui reg `I_`t'' R $covariates, robust													
			if `b'==1	{
						matrix short_med_ME[`row',5]  	= _b[R]
						matrix short_med_NME[`row',5] 	= _b[R]
						}
			else qui 	{
						matrix `t'_OUT_ME[`b',3] 		= _b[R]		//`t'_OUT_all [Not used]
						matrix `t'_OUT_NME[`b',3] 		= _b[R]		//`t'_OUT_ind_mediator [effect of program on investment]	
						}			
			restore
	}

	foreach error in NME ME{
	di in red `"`error' `t' "'
	preserve
	svmat `t'_OUT_`error', names(col)
	sum `t'_OUT_`error'_ind_outcome
	di in red `"`r(N)' "'
	sum `t'_OUT_`error'_ind_mediator
	di in red `"`r(N)' "'	
	gen mediation_effect = `t'_OUT_`error'_ind_outcome * `t'_OUT_`error'_ind_mediator
	keep mediation_effect `t'_OUT_`error'_all `t'_OUT_`error'_ind_outcome `t'_OUT_`error'_ind_mediator
	count
	di in red `"`r(N)' "'
	keep if !missing(mediation_effect)
	count
	di in red `"`r(N)' "'
	sort mediation_effect
	mkmat mediation_effect, matrix(`t'_OUT_`error'_ci)
	matrix short_med_`error'[`row',6] = `t'_OUT_`error'_ci[`bottom',1]
	matrix short_med_`error'[`row',7] = `t'_OUT_`error'_ci[`top',1]
	restore
	}
	local row = `row' + 1
	local program_num = `program_num' + 1
}

*********
* Graph *
*********

clear
foreach error in NME ME{
svmat short_med_`error', names(col)
keep if !missing(program)
gen estimate_mediation = estimate_ind_outcome * estimate_ind_mediator
*gen estimate_indirect = estimate_all - estimate_mediation (not used for now)

gen name = _n
graph twoway (bar estimate_mediation name, horizontal) ///
	(rbar estimate_mediation estimate_all name, horizontal) ///
	(rcap ci_lower ci_upper name, horizontal), ///
	ytitle("") ///
	title("`error'") ///
	ylabel(1 "EHS(Center) - PPVT" 2 "EHS(Home) - PPVT" 3 "EHS(Mixed) - PPVT" 4 "EHS(All) - PPVT" ///
	5 "IHDP - PPVT" 6 "IHDP - SB" ///
	7 "ABC - SB" ///
	8 "CARE (Both) - SB" 9 "CARE (Home) - SB" 10 "CARE (All) - SB", angle(horizontal)) ///
	legend(order(1 "Mediation" 2 "Other" 3 "95% CI")) ///
	graphregion(fcolor(white)) bgcolor(white)

cd "$out"
graph export "mediation_cognitive_`error'.pdf", replace

*Graph adapted
gen name_col=""
replace name_col="EHS(Center) - PPVT"	if name==1
replace name_col="EHS(Home) - PPVT" 	if name==2
replace name_col="EHS(Mixed) - PPVT" 	if name==3
replace name_col="EHS(All) - PPVT" 		if name==4
replace name_col="IHDP - PPVT" 			if name==5
replace name_col="IHDP - SB" 			if name==6
replace name_col="ABC - SB" 			if name==7
replace name_col="CARE (Both) - SB" 	if name==8
replace name_col="CARE (Home) - SB"  	if name==9
replace name_col="CARE (All) - SB" 		if name==10
*keep if estimate_all>0.8
drop if name_col=="CARE (Home) - SB"
drop if name_col=="CARE (Both) - SB"
drop if name_col=="EHS(Center) - PPVT"
drop if name_col=="EHS(Home) - PPVT"
drop if name_col=="EHS(Mixed) - PPVT"

gen newname=_n
local ylabel =""
count
local N= r(N)
di "`N'"
forvalues j=1/`N'{
local ylabel `ylabel' `j'
local ylabel_aux = name_col[`j']
local ylabel `ylabel' `" `ylabel_aux' "'
}
di `"`ylabel' "'

graph twoway (bar estimate_mediation newname, horizontal barw(1) ) ///
	(rbar estimate_mediation estimate_all newname, horizontal barw(1) ) ///
	(rcap ci_lower ci_upper newname, horizontal lcolor(black) lwidth(medthick) ), ///
	title("`error'") ///
	ytitle("") ylabel(`ylabel'  , angle(horizontal)) ///
	legend(order(1 "Mediation" 2 "Other" 3 "95% CI")) ///
	graphregion(fcolor(white)) bgcolor(white)

cd "$out"
graph export "mediation_cognitive_selected_`error'.pdf", replace

drop newname name name_col program outcome estimate_mediation estimate_ind_outcome estimate_ind_mediator ci_lower ci_upper estimate_all
}

**********
* TABLES *
**********

* Table for Production Function Estimates
foreach error in NME ME{

local nrow = rowsof(long_prod_`error'_p)
local ncol = colsof(long_prod_`error'_p)
qui matrix long_prod_`error'_stars = J(`nrow', `ncol', 0) // stars matrix
qui matrix colnames long_prod_`error'_stars = `long_prod_colnames'
qui matrix rownames long_prod_`error'_stars = `program_names_rownames'

forvalues k = 1/`nrow' {
	forvalues l = 1/`ncol' {
		qui matrix long_prod_`error'_stars[`k',`l'] = (long_prod_`error'_p[`k',`l'] < 0.1) ///
			+ (long_prod_`error'_p[`k',`l'] < 0.05) ///
			+ (long_prod_`error'_p[`k',`l'] < 0.01)
	}
}

cd "$out"

frmttable using long_prod_`error', statmat(long_prod_`error'_coef_se) substat(1) sdec(3) fragment tex replace nocenter ///
	annotate(long_prod_`error'_stars) asymbol(*,**,***)

** Table for Production Function Estimates NOT Including Interactions

local nrow = rowsof(short_prod_`error'_p)
local ncol = colsof(short_prod_`error'_p)

qui matrix short_prod_`error'_stars = J(`nrow', `ncol', 0) // stars matrix

qui matrix colnames short_prod_`error'_stars = `short_prod_colnames'
qui matrix rownames short_prod_`error'_stars = `program_names_rownames'

forvalues k = 1/`nrow' {
	forvalues l = 1/`ncol' {
		qui matrix short_prod_`error'_stars[`k',`l'] = (short_prod_`error'_p[`k',`l'] < 0.1) ///
			+ (short_prod_`error'_p[`k',`l'] < 0.05) ///
			+ (short_prod_`error'_p[`k',`l'] < 0.01)
	}
}

cd "$out"
frmttable using short_prod_`error', statmat(short_prod_`error'_coef_se) substat(1) sdec(3) fragment tex replace nocenter ///
	annotate(short_prod_ME_stars) asymbol(*,**,***)
}

* DATA CHECKS *

cd "$data_working"
use "ihdp-merge-imputations.dta", clear

ivregress 2sls ppvt36 (theta36 theta36_R = theta12 theta12_R ) R $covariates, vce(robust)

reg theta36 R


