* ----------------- *
* BIG SUMMARY PLOT  *
* Author: Andrés    *	
* ----------------- *

*Outcomes should all be standardized!

* Options: Randomization or Participation?
* Options: Homogenized or not?
* Options: Pile down or all programs in same line?
* Given that it is for us, I think for now it would be most useful to have all in a single graph

*1. Big Plot
*Down: outcomes/Programs *Side: methods Simple-->Homo-->compliance-->dosage
*2. New outcomes plot
*Down: outcomes/programs * Side: conf intervals
*3. Old outcomes plot
*Down: outcomes *Side: programs

*Different .do files-->generate matrices
*Same .do file-->turn matrix into a graph

* Use coefplot?
*global method 	iv
*				ols
*clear all

*Covariates: m_age m_edu sibling m_iq race sex gestage mf
*homogenization: bw poor/m_edu black

* Requires manual inputs:
clear all

local prog1 ehs
local prog2 ihdp
local prog3 ihdp
local prog4 abc
local prog5 care

local out1 ppvt
local out2 sb
local out3 ppvt
local out4 sb
local out5 sb

local ehs_ppvt		ppvt3y
local ihdp_sb		sb3y	
local ihdp_ppvt		ppvt3y
local abc_sb 		sb3y
local care_sb		sb3y	

local prog6 ehs
local prog7 ihdp

local out6 kidi
local out7 kidi

local ehs_kidi		norm_kidi_total2y
local ihdp_kidi		kidi_accuracy24

local prog8 ehs
local prog9 ihdp
local prog10 abc
local prog11 care

local out8 home
local out9 home
local out10 home
local out11 home

local ehs_home		norm_home_total3y
local ihdp_home		norm_home_total3y
local abc_home		norm_home_total3y
local care_home		norm_home_total3y

local prog12 ehs
local prog13 ihdp
local prog14 abc

local out12 video
local out13 video
local out14 video

local ehs_video		video_factor3y
local ihdp_video	video_factor3y
local abc_video		video_factor3y

local prog15 ehs
local prog16 ihdp
local prog17 abc
local prog18 care

local out15 noncog
local out16 noncog
local out17 noncog
local out18 noncog

local ehs_noncog 	norm_bayley_engagement3y
local ihdp_noncog	norm_bayley_engagement2y
local abc_noncog	norm_bayley_engagement3y
local care_noncog	norm_bayley_engagement3y

local rows=18

* ------------ *
* Prepare matrix
*global outcomes ppvt sb noncog
cd "$data_working"

local row = 1
	* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.

forv d=1/3{	
	matrix D`d' = J(`rows', 5, .)
		matrix colnames D`d' = numD`d' coeffD`d' lowerD`d' upperD`d' pvalD`d'
}	

	* Loop over rows/outcomes to fill in values into the empty matrix.
	forv p =1/`rows' {
		use "`prog`p''-topi.dta", clear

forv d=1/3{			
	* IV
	di `"IV: `prog`p'' ``prog`p''_`out`p''' Education:`d' "'
		* We only want to do IV regression only if there is significant variability (> 1%)
				qui count if !missing(``prog`p''_`out`p''') & !missing(D) & m_ed==`d'
			    local nobs = r(N)
				qui count if R != D & !missing(``prog`p''_`out`p''') & !missing(D) & m_ed==`d'
				local ndiff = r(N)
				local nprop = `ndiff'/`nobs'
				di " program: ``prog`p''  nprop: `nprop' "
				if `nprop' < 0.01 | `ndiff' < 2 {
					di "Not much variability"
					regress ``prog`p''_`out`p''' R $covariates if !missing(D) & m_ed==`d'
					}
				else {
					ivregress 2sls ``prog`p''_`out`p''' (D = R) $covariates if !missing(D) & m_ed==`d'
					}
				* r(table) stores values from regression (ex. coeff, var, CI).
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

		matrix DDD=D1,D2,D3
		svmat DDD, names(col)
		keep numD1 coeffD1 lowerD1 upperD1 pvalD1 coeffD2 lowerD2 upperD2 pvalD2 coeffD3 lowerD3 upperD3 pvalD3
		keep if numD1 != .

* ----------------- *
* Execution - P-value

	foreach D in D1 D2 D3{
	gen `D'_insig = .
	gen `D'_01 = .
	gen `D'_005 = .
	replace `D'_insig =	coeff`D' 	if pval`D' > 0.1
	replace `D'_01 = 	coeff`D' 	if pval`D' <= 0.1 & pval`D' > 0.05
	replace `D'_005 = 	coeff`D' 	if pval`D' <= 0.05
}

label define Outcomes	///
1 "EHS PPVT Age 3"		///
2 "IHDP SB Age 3"		///
3 "IHDP PPVT Age 3"		///
4 "ABC SB Age 3"		///
5 "CARE SB Age 3"		///
6 "EHS KIDI Age 2"		///
7 "IHDP KIDI Age 2"		///
8 "EHS HOME Age 3"		///
9 "IHDP HOME Age 3"		///
10 "ABC HOME Age 3"		///
11 "CARE HOME Age 3"	///
12 "EHS Video Age 3"	///
13 "IHDP Video Age 3"	///
14 "ABC Video Age 3"	///
15 "EHS Noncog Age 3"	///
16 "IHDP Noncog Age 3"	///
17 "ABC Noncog Age 3"	///
18 "CARE Noncog Age 3"
label values numD1 Outcomes

*One variable per each horizontal category and for significance levels
*One row (obs) per vertical category
graph dot 	D1_insig D1_01 D1_005 	///
			D2_insig D2_01 D2_005  	///
			D3_insig D3_01 D3_005,  ///
	marker(1,msize(large) msymbol(D) mlc(navy) mfc(navy*0) mlw(thick)) ///
	marker(2,msize(large) msymbol(D) mlc(navy) mfc(navy*0.45) mlw(thick)) ///
	marker(3,msize(large) msymbol(D) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(4,msize(large) msymbol(O) mlc(navy) mfc(navy*0) mlw(thick)) ///
	marker(5,msize(large) msymbol(O) mlc(navy) mfc(navy*0.45) mlw(thick)) ///
	marker(6,msize(large) msymbol(O) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(7,msize(large) msymbol(T) mlc(navy) mfc(navy*0) mlw(thick)) ///
	marker(8,msize(large) msymbol(T) mlc(navy) mfc(navy*0.45) mlw(thick)) ///
	marker(9,msize(large) msymbol(T) mlc(navy) mfc(navy) mlw(thick)) ///
	over(numD1, gap(0.5) label(labsize(small)) sort(scale_row) ) ///
	legend (order (1 "Less than HS" 4 "HS" 7 "More than HS") size(medsmall) cols(3) ) yline(0) ///
	ysize(1) xsize(2)   ///
	graphregion(fcolor(white)) bgcolor(white) aspect(1.5)	
	
cd "$out"
	graph export "all_outcomes_by_educ.pdf", replace
cd "$git_out"
	graph export "all_outcomes_by_educ.pdf", replace

matrix rownames DDD = ehs_ppvt ihdp_sb ihdp_ppvt abc_sb ///
care_sb ehs_kidi ihdp_kidi ehs_home ///
ihdp_home abc_home care_home ehs_video ///
ihdp_video abc_video ehs_noncog ihdp_noncog ///
abc_noncog care_noncog
	
matrix list DDD

* asd for EHS:
