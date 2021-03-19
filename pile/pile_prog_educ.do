* ------------------------------------------------- *
* TE on Cognitive Skills by Education of the Mother *
* Author: Andrés    								*	
* ------------------------------------------------- *

* Requires manual inputs:
clear all

local prog1 ehscenter
local prog2 ihdp
local prog3 ihdp
local prog4 abc

local out1 ppvt
local out2 sb
local out3 ppvt
local out4 sb

local ehs_ppvt		ppvt3y
local ihdp_sb		sb3y	
local ihdp_ppvt		ppvt3y
local abc_sb 		sb3y

local rows=4

*  Prepare matrix *

cd "$data_working"

	* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.

forv d=1/2{	
	matrix D`d' = J(`rows', 5, .)
		matrix colnames D`d' = numD`d' coeffD`d' lowerD`d' upperD`d' pvalD`d'
}	

local row = 1

	forv p =1/`rows' {
		use "`prog`p''-topi.dta", clear

		forv d=1/2{			
			di `"ITT: `prog`p'' ``prog`p''_`out`p''' Education:`d' "'
			regress ``prog`p''_`out`p''' R if hs==`d'
			qui matrix list r(table)
			qui matrix r = r(table)
			qui matrix D`d'[`row',1] = `row'
			qui matrix D`d'[`row',2] = r[1,1]
			qui matrix D`d'[`row',3] = r[5,1]
			qui matrix D`d'[`row',4] = r[6,1]
			qui matrix D`d'[`row',5] = r[4,1]
			}
				
				local row = `row' + 1
		}

		matrix DD=D1,D2
		svmat DD, names(col)
		keep numD1 coeffD1 lowerD1 upperD1 pvalD1 coeffD2 lowerD2 upperD2 pvalD2
		keep if numD1 != .

* ----------------- *
* Execution - P-value

	foreach D in D1 D2{
	gen `D'_insig = .
	gen `D'_01 = .
	gen `D'_005 = .
	replace `D'_insig =	coeff`D' 	if pval`D' > 0.1
	replace `D'_01 = 	coeff`D' 	if pval`D' <= 0.1 & pval`D' > 0.05
	replace `D'_005 = 	coeff`D' 	if pval`D' <= 0.05
}

label define Outcomes		///
1 "EHS CENTER PPVT Age 3"	///
2 "IHDP SB Age 3"			///
3 "IHDP PPVT Age 3"			///
4 "ABC SB Age 3"		
label values numD1 Outcomes

*One variable per each horizontal category and for significance levels
*One row (obs) per vertical category
graph dot 	D1_insig D1_01 D1_005 	///
			D2_insig D2_01 D2_005,  ///
	marker(1,msize(large) msymbol(D) mlc(navy) mfc(navy*0) mlw(thick)) ///
	marker(2,msize(large) msymbol(D) mlc(navy) mfc(navy*0.45) mlw(thick)) ///
	marker(3,msize(large) msymbol(D) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(4,msize(large) msymbol(O) mlc(navy) mfc(navy*0) mlw(thick)) ///
	marker(5,msize(large) msymbol(O) mlc(navy) mfc(navy*0.45) mlw(thick)) ///
	marker(6,msize(large) msymbol(O) mlc(navy) mfc(navy) mlw(thick)) ///
	over(numD1, gap(0.5) label(labsize(small)) sort(scale_row) ) ///
	legend (order (1 "HS or Less" 4 "More than HS") size(medsmall) cols(3) ) yline(0) ///
	ysize(1) xsize(2)   ///
	graphregion(fcolor(white)) bgcolor(white) aspect(1.5)	
	
cd "$out"
	graph export "itt_educ.pdf", replace
cd "$git_out"
	graph export "itt_educ.pdf", replace
