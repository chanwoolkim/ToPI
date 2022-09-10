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

local prog1 ehscenter
local prog2 ehs_mixed_center
local prog3 ihdp
local prog4 ihdp
local prog5 abc

local out1 ppvt
local out2 ppvt
local out3 sb
local out4 ppvt
local out5 sb

local ehscenter_ppvt		ppvt3y
local ehs_mixed_center_ppvt	ppvt3y
local ihdp_sb				sb3y	
local ihdp_ppvt				ppvt3y
local abc_sb 				sb3y

local rows=5

* ------------ *
* Prepare matrix
*global outcomes ppvt sb noncog
cd "$data_working"

*Methods:
* itt
* itt + chop
* itt + chop + reweight
* iv + chop + reweight
* iv + chop + reweight + intensity

local row = 1
	* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
	matrix ITT = J(`rows', 5, .)
		matrix colnames ITT = numITT coeffITT lowerITT upperITT pvalITT
	matrix CHOP = J(`rows', 5, .)
		matrix colnames CHOP = numCHOP coeffCHOP lowerCHOP upperCHOP pvalCHOP
	matrix REW = J(`rows', 5, .)
		matrix colnames REW = numREW coeffREW lowerREW upperREW pvalREW	
	matrix IV = J(`rows', 5, .)
		matrix colnames IV = numIV coeffIV lowerIV upperIV pvalIV	
	matrix IV2 = J(`rows', 5, .)
		matrix colnames IV2 = numIV2 coeffIV2 lowerIV2 upperIV2 pvalIV2	
	matrix INT = J(`rows', 5, .)
		matrix colnames INT = numINT coeffINT lowerINT upperINT pvalINT	
	matrix INT2 = J(`rows', 5, .)
		matrix colnames INT2 = numINT2 coeffINT2 lowerINT2 upperINT2 pvalINT2	

	* Loop over rows/outcomes to fill in values into the empty matrix.
	forv p =1/`rows' {
		use "`prog`p''-topi.dta", clear
		di "`prog`p''"
		
		cap drop ww
		gen ww = 1
		
		if "`prog`p''" == "abc" {
			gen twin = 0
		}
		
	* ITT
	di `"ITT: `prog`p'' ``prog`p''_`out`p''' "'
	regress ``prog`p''_`out`p''' R
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)
				qui matrix ITT[`row',1] = `row'
				qui matrix ITT[`row',2] = r[1,1]
				qui matrix ITT[`row',3] = r[5,1]
				qui matrix ITT[`row',4] = r[6,1] 
				qui matrix ITT[`row',5] = r[4,1]
				
	* CHOP
	di `"CHOP: `prog`p'' ``prog`p''_`out`p''' "'
	regress ``prog`p''_`out`p''' R if bw>2000 & black==1 & twin==0
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)
				qui matrix CHOP[`row',1] = `row'
				qui matrix CHOP[`row',2] = r[1,1]
				qui matrix CHOP[`row',3] = r[5,1]
				qui matrix CHOP[`row',4] = r[6,1] 
				qui matrix CHOP[`row',5] = r[4,1]			

	* Reweighting
	di `"REW: `prog`p'' ``prog`p''_`out`p''' "'
	regress ``prog`p''_`out`p''' R if bw>2000 & black==1 & twin==0 [weight=ww]
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)
				qui matrix REW[`row',1] = `row'
				qui matrix REW[`row',2] = r[1,1]
				qui matrix REW[`row',3] = r[5,1]
				qui matrix REW[`row',4] = r[6,1] 
				qui matrix REW[`row',5] = r[4,1]			
/*
	* IV
	di `"IV: `prog`p'' ``prog`p''_`out`p''' "'
			ivregress 2sls ``prog`p''_`out`p''' (D = R) if bw>2000 & black==1 & twin==0  [weight=ww]
				qui matrix r = r(table)
				qui matrix IV[`row',1] = `row'
				qui matrix IV[`row',2] = r[1,1]
				qui matrix IV[`row',3] = r[5,1]
				qui matrix IV[`row',4] = r[6,1]
				qui matrix IV[`row',5] = r[4,1]
*/
	* NEW IV
	di `"IV: `prog`p'' ``prog`p''_`out`p''' "'
			ivregress 2sls ``prog`p''_`out`p''' (D = R) if bw>2000 & black==1 & twin==0  [weight=ww]
				qui matrix r = r(table)
				qui matrix IV2[`row',1] = `row'
				qui matrix IV2[`row',2] = r[1,1]
				qui matrix IV2[`row',3] = r[5,1]
				qui matrix IV2[`row',4] = r[6,1]
				qui matrix IV2[`row',5] = r[4,1]
/*
	* INTENSITY
	di `"INTENSITY: `prog`p'' ``prog`p''_`out`p''' "'
			ivregress 2sls ``prog`p''_`out`p''' (H = R) if bw>2000 & black==1 & twin==0  [weight=ww]
				qui matrix r = r(table)
				qui matrix INT[`row',1] = `row'
				qui matrix INT[`row',2] = r[1,1]
				qui matrix INT[`row',3] = r[5,1]
				qui matrix INT[`row',4] = r[6,1]
				qui matrix INT[`row',5] = r[4,1]
*/
	* NEW INTENSITY
	di `"INTENSITY: `prog`p'' ``prog`p''_`out`p''' "'
			ivregress 2sls ``prog`p''_`out`p''' (`prog`p''_months = R) if bw>2000 & black==1 & twin==0  [weight=ww]
				qui matrix r = r(table)
				qui matrix INT2[`row',1] = `row'
				qui matrix INT2[`row',2] = r[1,1]*29
				qui matrix INT2[`row',3] = r[5,1]
				qui matrix INT2[`row',4] = r[6,1]
				qui matrix INT2[`row',5] = r[4,1]

				
		local row = `row' + 1
		}

*----------------------------------*
* Simple CI Graphs with One Method *
*----------------------------------*
/*
local num=1
foreach M in ITT CHOP REW IV INT{
preserve
	svmat `M', names(col)
	keep num`M' coeff`M' lower`M' upper`M' pval`M'
	keep if num`M' != .
		
	* Prepare Graph *
	label define Outcomes	///
	1 "EHS CENTER PPVT Age 3"		///
	2 "IHDP SB Age 3"		///
	3 "IHDP PPVT Age 3"		///
	4 "ABC SB Age 3"		
	label values num`M' Outcomes

	twoway (scatter num`M' coeff`M',ylabel(,val angle(360)) ) (rcap lower`M' upper`M' num`M', horizontal) ///
	,graphregion(fcolor(white)) legend(off) ytitle("")
	
	cd "$out"
	graph export "pile_cog`num'_`M'.pdf", replace
	cd "$git_out"
	graph export "pile_cog`num'_`M'.pdf", replace
restore
local num=`num'+1
}
*/
*--------------------------------*
* General Graph with All Methods *
*--------------------------------*		
		
matrix ALL=ITT,CHOP,REW,IV2,INT2 //ALL=ITT,CHOP,REW,IV,IV2,INT,INT2
svmat ALL, names(col)
keep numITT coeffITT pvalITT coeffCHOP pvalCHOP coeffREW pvalREW /*coeffIV pvalIV*/ coeffIV2 pvalIV2 /*coeffINT pvalINT*/ coeffINT2 pvalINT2		 		 
keep if numITT != .

* ----------------- *
* Execution - P-value

	foreach m in ITT CHOP REW /*IV*/ IV2 /*INT*/ INT2{
	gen `m'insig = .
	gen `m'0_1 = .
	gen `m'0_05 = .
	replace `m'insig =	coeff`m' 	if pval`m' > 0.1
	replace `m'0_1 = 	coeff`m' 	if pval`m' <= 0.1 & pval`m' > 0.05
	replace `m'0_05 = 	coeff`m' 	if pval`m' <= 0.05
}

label define Outcomes	///
1 "EHS CENTER PPVT Age 3"		///
2 "EHS CENTER + MIXED PPVT Age 3"		///
3 "IHDP SB Age 3"		///
4 "IHDP PPVT Age 3"		///
5 "ABC SB Age 3"
label values numITT Outcomes

*One variable per each horizontal category and for significance levels
*One row (obs) per vertical category
graph dot 	ITTinsig ITT0_1 ITT0_05 	///
			CHOPinsig CHOP0_1 CHOP0_05  	///
			REWinsig REW0_1 REW0_05  ///
			IV2insig IV20_1 IV20_05 ///
			INT2insig INT20_1 INT20_05 ///
   ,marker(1,msize(large) msymbol(D) mlc(navy) mfc(navy*0) mlw(thick)) ///
	marker(2,msize(large) msymbol(D) mlc(navy) mfc(navy*0.45) mlw(thick)) ///
	marker(3,msize(large) msymbol(D) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(4,msize(large) msymbol(O) mlc(navy) mfc(navy*0) mlw(thick)) ///
	marker(5,msize(large) msymbol(O) mlc(navy) mfc(navy*0.45) mlw(thick)) ///
	marker(6,msize(large) msymbol(O) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(7,msize(large) msymbol(T) mlc(navy) mfc(navy*0) mlw(thick)) ///
	marker(8,msize(large) msymbol(T) mlc(navy) mfc(navy*0.45) mlw(thick)) ///
	marker(9,msize(large) msymbol(T) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(10,msize(large) msymbol(S) mlc(green) mfc(green*0) mlw(thick)) ///
	marker(11,msize(large) msymbol(S) mlc(green) mfc(green*0.45) mlw(thick)) ///
	marker(12,msize(large) msymbol(S) mlc(green) mfc(green) mlw(thick)) ///
	marker(13,msize(large) msymbol(S) mlc(red) mfc(red*0) mlw(thick)) ///
	marker(14,msize(large) msymbol(S) mlc(red) mfc(red*0.45) mlw(thick)) ///
	marker(15,msize(large) msymbol(S) mlc(red) mfc(red) mlw(thick)) ///
	over(numITT, gap(0.5) label(labsize(small)) sort(scale_row) ) ///
	legend (order (1 "ITT" 4 "CHOP" 7 "REW" 10 "IV" 13 "Hours" ) size(medsmall) cols(5) ) yline(0)  ///
	ysize(1) xsize(2)   ///
	graphregion(fcolor(white)) bgcolor(white) aspect(1)	
cd "$out"
	graph export "pile_cog_all_methods.pdf", replace
cd "$git_out"
	graph export "pile_cog_all_methods.png", replace
/*
graph dot 	ITTinsig ITT0_1 ITT0_05 	///
			CHOPinsig CHOP0_1 CHOP0_05  	///
			REWinsig REW0_1 REW0_05  ///
			IVinsig IV0_1 IV0_05 ///
			IV2insig IV20_1 IV20_05 ///
			INTinsig INT0_1 INT0_05 ///
			INT2insig INT20_1 INT20_05 ///
   ,marker(1,msize(large) msymbol(D) mlc(navy) mfc(navy*0) mlw(thick)) ///
	marker(2,msize(large) msymbol(D) mlc(navy) mfc(navy*0.45) mlw(thick)) ///
	marker(3,msize(large) msymbol(D) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(4,msize(large) msymbol(O) mlc(navy) mfc(navy*0) mlw(thick)) ///
	marker(5,msize(large) msymbol(O) mlc(navy) mfc(navy*0.45) mlw(thick)) ///
	marker(6,msize(large) msymbol(O) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(7,msize(large) msymbol(T) mlc(navy) mfc(navy*0) mlw(thick)) ///
	marker(8,msize(large) msymbol(T) mlc(navy) mfc(navy*0.45) mlw(thick)) ///
	marker(9,msize(large) msymbol(T) mlc(navy) mfc(navy) mlw(thick)) ///
	marker(10,msize(large) msymbol(S) mlc(green) mfc(green*0) mlw(thick)) ///
	marker(11,msize(large) msymbol(S) mlc(green) mfc(green*0.45) mlw(thick)) ///
	marker(12,msize(large) msymbol(S) mlc(green) mfc(green) mlw(thick)) ///
	marker(13,msize(large) msymbol(S) mlc(red) mfc(red*0) mlw(thick)) ///
	marker(14,msize(large) msymbol(S) mlc(red) mfc(red*0.45) mlw(thick)) ///
	marker(15,msize(large) msymbol(S) mlc(red) mfc(red) mlw(thick)) ///
	marker(16,msize(large) msymbol(D) mlc(green) mfc(green*0) mlw(thick)) ///
	marker(17,msize(large) msymbol(D) mlc(green) mfc(green*0.45) mlw(thick)) ///
	marker(18,msize(large) msymbol(D) mlc(green) mfc(green) mlw(thick)) ///
	marker(19,msize(large) msymbol(D) mlc(red) mfc(red*0) mlw(thick)) ///
	marker(20,msize(large) msymbol(D) mlc(red) mfc(red*0.45) mlw(thick)) ///
	marker(21,msize(large) msymbol(D) mlc(red) mfc(red) mlw(thick)) ///
	over(numITT, gap(0.5) label(labsize(small)) sort(scale_row) ) ///
	legend (order (1 "ITT" 4 "CHOP" 7 "REW" 10 "IV" 13 "NEW IV" 16 "Hours" 19 "New Hours") size(medsmall) cols(5) ) yline(0)  ///
	ysize(1) xsize(2)   ///
	graphregion(fcolor(white)) bgcolor(white) aspect(1)	
cd "$out"
	graph export "pile_cog_all_methods.pdf", replace
cd "$git_out"
	graph export "pile_cog_all_methods.pdf", replace
	
