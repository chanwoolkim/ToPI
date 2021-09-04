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
local prog8 care

local out6 kidi
local out7 kidi
local out8 kidi

local ehs_kidi		norm_kidi_total2y
local ihdp_kidi		kidi_accuracy24
local care_kidi		kidi_accuracy30

local prog9 ehs
local prog10 ihdp
local prog11 abc
local prog12 care

local out9 home
local out10 home
local out11 home
local out12 home

local ehs_home		norm_home_total3y
local ihdp_home		norm_home_total3y
local abc_home		norm_home_total3y
local care_home		norm_home_total3y

local prog13 ehs
local prog14 ihdp
local prog15 abc

local out13 video
local out14 video
local out15 video

local ehs_video		video_factor3y
local ihdp_video	video_factor3y
local abc_video		video_factor3y

local prog16 ehs
local prog17 ihdp
local prog18 abc
local prog19 care

local out16 noncog
local out17 noncog
local out18 noncog
local out19 noncog

local ehs_noncog 	norm_bayley_engagement3y
local ihdp_noncog	norm_bayley_engagement2y
local abc_noncog	norm_bayley_engagement3y
local care_noncog	norm_bayley_engagement3y

local rows=19

* ------------ *
local covariates_comma
foreach var in $covariates {
local covariates_comma `covariates_comma',`var'  
di `"`covariates_comma'"'
}

* ------------ *
* Prepare matrix
*global outcomes ppvt sb noncog
cd "$data_working"

local row = 1
	* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
	matrix R = J(`rows', 5, .)
		matrix colnames R = numR coeffR lowerR upperR pvalR
	matrix D = J(`rows', 5, .)
		matrix colnames D = numD coeffD lowerD upperD pvalD
	matrix S = J(`rows', 5, .)
		matrix colnames S = numS coeffS lowerS upperS pvalS	
	matrix H = J(`rows', 5, .)
		matrix colnames H = numH coeffH lowerH upperH pvalH	

	* Loop over rows/outcomes to fill in values into the empty matrix.
	forv p =1/`rows' {
		use "`prog`p''-topi.dta", clear
		di "`prog`p''"
		if "`prog`p''"=="ehs" di "yes"
*http://www.welfareacademy.org/pubs/early_education/pdfs/Besharov_ECE%20assessments_IHDP.pdf assumes 9 hours/day				
*https://eclkc.ohs.acf.hhs.gov/programs/article/early-head-start-program-options

	* ITT
	di `"ITT: `prog`p'' ``prog`p''_`out`p''' "'
		regress ``prog`p''_`out`p''' R $covariates if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)
				qui matrix R[`row',1] = `row'
				qui matrix R[`row',2] = r[1,1]
				qui matrix R[`row',3] = r[5,1]
				qui matrix R[`row',4] = r[6,1] 
				qui matrix R[`row',5] = r[4,1]

	* IV
	di `"IV: `prog`p'' ``prog`p''_`out`p''' "'
		* We only want to do IV regression only if there is significant variability (> 1%)
				count if !missing(R,``prog`p''_`out`p''',D`covariates_comma')
			    local nobs = r(N)
				count if R != D & !missing(R,``prog`p''_`out`p''',D`covariates_comma')				
				local ndiff = r(N)
				local nprop = `ndiff'/`nobs'
				di " program: `prog`p''  nprop: `nprop' "
				if `nprop' < 0.01 | `ndiff' < 2 {
					di "Not much variability"
					regress ``prog`p''_`out`p''' R $covariates if !missing(D)
					}
				else {
					ivregress 2sls ``prog`p''_`out`p''' (D = R) $covariates if !missing(D)
					}
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)
				qui matrix D[`row',2] = r[1,1]
				qui matrix D[`row',3] = r[5,1]
				qui matrix D[`row',4] = r[6,1]
				qui matrix D[`row',5] = r[4,1]

	* IV + SUBPOP
	di `"Subpop: `prog`p'' ``prog`p''_`out`p''' "'
		* We only want to do IV regression only if there is significant variability (> 1%)
				qui count if !missing(R,``prog`p''_`out`p''',D`covariates_comma') & black==1 & poverty==0 & bw>2000
			    local nobs = r(N)
				qui count if R != D & !missing(R,``prog`p''_`out`p''',D`covariates_comma') & black==1 & poverty==0 & bw>2000
				local ndiff = r(N)
				local nprop = `ndiff'/`nobs'
				di " program: ``prog`p''  nprop: `nprop' "
				if `nprop' < 0.01 | `ndiff' < 2 {
					di "Not much variability"
					regress ``prog`p''_`out`p''' R $covariates if !missing(D) & black==1 & poverty==0 & bw>2000
					}
				else {
					ivregress 2sls ``prog`p''_`out`p''' (D = R) $covariates if !missing(H) & black==1 & poverty==0 & bw>2000
					}
				qui matrix r = r(table)
				qui matrix S[`row',2] = r[1,1]
				qui matrix S[`row',3] = r[5,1]
				qui matrix S[`row',4] = r[6,1]
				qui matrix S[`row',5] = r[4,1]
				
	* IV + SUBPOP + INTENSITY
	di `"Subpop + Intensity: `prog`p'' ``prog`p''_`out`p''' "'
		* We only want to do IV regression only if there is significant variability (> 1%)
				
				count if !missing(R,``prog`p''_`out`p''',D`covariates_comma') & black==1 & poverty==0 & bw>2000
			    local nobs = r(N)
				count if R != D & !missing(R,``prog`p''_`out`p''',D`covariates_comma') & black==1 & poverty==0 & bw>2000 //CHANGE TO R!=DUMMY (H) LATER
				local ndiff = r(N)
				local nprop = `ndiff'/`nobs'
				di " program: ``prog`p''  nprop: `nprop' "
				if `nprop' < 0.01 | `ndiff' < 4 {
					di "Not much variability"
					*regress ``prog`p''_`out`p''' R $covariates if !missing(H) & black==1 & poverty==0 & bw>2000
					}
				else {
					ivregress 2sls ``prog`p''_`out`p''' (H = R) $covariates if !missing(H) & black==1 & poverty==0 & bw>2000
					}
				qui matrix r = r(table)
				qui matrix H[`row',2] = r[1,1]*4000
				qui matrix H[`row',3] = r[5,1]
				qui matrix H[`row',4] = r[6,1]
				qui matrix H[`row',5] = r[4,1]
				
* BW:
*				ihdp 	bw>2000 (678/1090 in ihdp)
*				abc		bw>2000 (4/126 in abc)
*				ehs		bw>2000 (73/2694 in ehs)
*				care	bw>2000 (2/66 in care)

				local row = `row' + 1
		}

		matrix RDSH=R,D,S,H
		svmat RDSH, names(col)
		keep numR coeffR lowerR upperR pvalR coeffD lowerD upperD pvalD coeffS lowerS upperS pvalS coeffH lowerH upperH pvalH
		keep if numR != .

* ----------------- *
* Execution - P-value

	foreach m in R D S H{
	gen `m'insig = .
	gen `m'0_1 = .
	gen `m'0_05 = .
	replace `m'insig =	coeff`m' 	if pval`m' > 0.1
	replace `m'0_1 = 	coeff`m' 	if pval`m' <= 0.1 & pval`m' > 0.05
	replace `m'0_05 = 	coeff`m' 	if pval`m' <= 0.05
}

label define Outcomes	///
1 "EHS PPVT Age 3"		///
2 "IHDP SB Age 3"		///
3 "IHDP PPVT Age 3"		///
4 "ABC SB Age 3"		///
5 "CARE SB Age 3"		///
6 "EHS KIDI Age 2"		///
7 "IHDP KIDI Age 2"		///
8 "CARE KIDI Age 3"		///
9 "EHS HOME Age 3"		///
10 "IHDP HOME Age 3"	///
11 "ABC HOME Age 3"		///
12 "CARE HOME Age 3"	///
13 "EHS Video Age 3"	///
14 "IHDP Video Age 3"	///
15 "ABC Video Age 3"	///
16 "EHS Noncog Age 3"	///
17 "IHDP Noncog Age 3"	///
18 "ABC Noncog Age 3"	///
19 "CARE Noncog Age 3"
label values numR Outcomes

*One variable per each horizontal category and for significance levels
*One row (obs) per vertical category
graph dot 	Rinsig R0_1 R0_05 	///
			Dinsig D0_1 D0_05  	///
			Sinsig S0_1 S0_05  ///
			Hinsig H0_1 H0_05,  ///
	marker(1,msize(large) msymbol(D) mlc(navy) mfc(navy*0) mlw(thick)) ///
	marker(2,msize(large) msymbol(D) mlc(navy) mfc(navy*0.45) mlw(thick)) ///
	marker(3,msize(large) msymbol(D) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(4,msize(large) msymbol(O) mlc(navy) mfc(navy*0) mlw(thick)) ///
	marker(5,msize(large) msymbol(O) mlc(navy) mfc(navy*0.45) mlw(thick)) ///
	marker(6,msize(large) msymbol(O) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(7,msize(large) msymbol(T) mlc(navy) mfc(navy*0) mlw(thick)) ///
	marker(8,msize(large) msymbol(T) mlc(navy) mfc(navy*0.45) mlw(thick)) ///
	marker(9,msize(large) msymbol(T) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(10,msize(large) msymbol(S) mlc(navy) mfc(navy*0) mlw(thick)) ///
	marker(11,msize(large) msymbol(S) mlc(navy) mfc(navy*0.45) mlw(thick)) ///
	marker(12,msize(large) msymbol(S) mlc(navy) mfc(navy) mlw(thick)) ///	
	over(numR, gap(0.5) label(labsize(small)) sort(scale_row) ) ///
	legend (order (1 "ITT" 4 "IV" 7 "Subpop" 10 "Intensity (Offer of 4000 hours)") size(medsmall) cols(3) ) yline(0) /*ylabel(, labsize(tiny))*/ ///
	/*ylabel(-0.2)*/ ysize(1) xsize(2)   ///
	graphregion(fcolor(white)) bgcolor(white) aspect(1)	
cd "$out"
	graph export "all_outcomes.pdf", replace
cd "$git_out"
	graph export "all_outcomes.pdf", replace

	asd
	
matrix rownames RDS = ehs_ppvt ihdp_sb ihdp_ppvt abc_sb ///
care_sb ehs_kidi ihdp_kidi ehs_home ///
ihdp_home abc_home care_home ehs_video ///
ihdp_video abc_video ehs_noncog ihdp_noncog ///
abc_noncog care_noncog
	
matrix list RDS

* asd for EHS:
