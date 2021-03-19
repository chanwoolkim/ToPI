* ----------------- *
* BIG SUMMARY PLOT  *
* Author: Andrés    *	
* ----------------- *

* Requires manual inputs:
clear all

local prog1 ehscenter
local prog2 ihdp
local prog3 abc

local out1 home
local out2 home
local out3 home

local ehscenter_home	norm_home_total3y
local ihdp_home			norm_home_total3y
local abc_home			norm_home_total3y

local prog4 ehscenter
local prog5 ihdp
local prog6 abc

local out4 video
local out5 video
local out6 video

local ehscenter_video	video_factor3y
local ihdp_video		video_factor3y
local abc_video			video_factor3y

local rows=6

* ------------ *
* Prepare matrix
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
	matrix INT = J(`rows', 5, .)
		matrix colnames INT = numINT coeffINT lowerINT upperINT pvalINT	

	* Loop over rows/outcomes to fill in values into the empty matrix.
	forv p =1/`rows' {
		use "`prog`p''-topi.dta", clear
		di "`prog`p''"

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

	* IV
	di `"IV: `prog`p'' ``prog`p''_`out`p''' "'
	if "`prog`p''"=="abc" & "`out`p''"=="video"  regress ``prog`p''_`out`p''' R if bw>2000 & black==1 & twin==0  [weight=ww]
	cap else ivregress 2sls ``prog`p''_`out`p''' (D = R) if bw>2000 & black==1 & twin==0  [weight=ww]
				qui matrix r = r(table)
				qui matrix IV[`row',1] = `row'
				qui matrix IV[`row',2] = r[1,1]
				qui matrix IV[`row',3] = r[5,1]
				qui matrix IV[`row',4] = r[6,1]
				qui matrix IV[`row',5] = r[4,1]
	
	* INTENSITY
	di `"INTENSITY: `prog`p'' ``prog`p''_`out`p''' "'
	if `"`prog`p''"'=="abc" & `"`out`p''"'=="video" regress  ``prog`p''_`out`p''' R if bw>2000 & black==1 & twin==0  [weight=ww]
	else ivregress 2sls ``prog`p''_`out`p''' (H = R) if bw>2000 & black==1 & twin==0  [weight=ww]
				qui matrix r = r(table)
				qui matrix INT[`row',1] = `row'
				qui matrix INT[`row',2] = r[1,1]
				qui matrix INT[`row',3] = r[5,1]
				qui matrix INT[`row',4] = r[6,1]
				qui matrix INT[`row',5] = r[4,1]

				
		local row = `row' + 1
		}

*----------------------------------*
* Simple CI Graphs with One Method *
*----------------------------------*
local num=1
foreach M in ITT CHOP REW IV INT{
preserve
	svmat `M', names(col)
	keep num`M' coeff`M' lower`M' upper`M' pval`M'
	keep if num`M' != .
		
	* Prepare Graph *
	label define Outcomes	///
	1 "EHS HOME Age 3"		///
	2 "IHDP HOME Age 3"		///
	3 "ABC HOME Age 3"		///
	4 "EHS Video Age 3"		///
	5 "IHDP Video Age 3"	///
	6 "ABC Video Age 3"
	label values num`M' Outcomes

	twoway (scatter num`M' coeff`M',ylabel(,val angle(360)) ) (rcap lower`M' upper`M' num`M', horizontal) ///
	,graphregion(fcolor(white)) legend(off) ytitle("")
	
	cd "$out"
	graph export "pile_home`num'_`M'.pdf", replace
	cd "$git_out"
	graph export "pile_home`num'_`M'.pdf", replace
restore
local num=`num'+1
}

*--------------------------------*
* General Graph with All Methods *
*--------------------------------*		
		
matrix ALL=ITT,CHOP,REW,IV,INT
svmat ALL, names(col)
keep numITT coeffITT pvalITT coeffCHOP pvalCHOP coeffREW pvalREW coeffIV pvalIV coeffINT pvalINT		 
keep if numITT != .

* ----------------- *
* Execution - P-value

	foreach m in ITT CHOP REW IV INT{
	gen `m'insig = .
	gen `m'0_1 = .
	gen `m'0_05 = .
	replace `m'insig =	coeff`m' 	if pval`m' > 0.1
	replace `m'0_1 = 	coeff`m' 	if pval`m' <= 0.1 & pval`m' > 0.05
	replace `m'0_05 = 	coeff`m' 	if pval`m' <= 0.05
}

label define Outcomes	///
1 "EHS HOME Age 3"		///
2 "IHDP HOME Age 3"		///
3 "ABC HOME Age 3"		///
4 "EHS Video Age 3"		///
5 "IHDP Video Age 3"	///
6 "ABC Video Age 3"
label values numITT Outcomes

*One variable per each horizontal category and for significance levels
*One row (obs) per vertical category
graph dot 	ITTinsig ITT0_1 ITT0_05 	///
			CHOPinsig CHOP0_1 CHOP0_05  	///
			REWinsig REW0_1 REW0_05  ///
			IVinsig IV0_1 IV0_05 ///
			INTinsig INT0_1 INT0_05 ///
   ,marker(1,msize(large) msymbol(D) mlc(navy) mfc(navy*0) mlw(thick)) ///
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
	marker(13,msize(large) msymbol(D) mlc(red) mfc(red*0) mlw(thick)) ///
	marker(14,msize(large) msymbol(D) mlc(red) mfc(red*0.45) mlw(thick)) ///
	marker(15,msize(large) msymbol(D) mlc(red) mfc(red) mlw(thick)) ///
	over(numITT, gap(0.5) label(labsize(small)) sort(scale_row) ) ///
	legend (order (1 "ITT" 4 "CHOP" 7 "REW" 10 "IV" 13 "Hours") size(medsmall) cols(5) ) yline(0)  ///
	ysize(1) xsize(2)   ///
	graphregion(fcolor(white)) bgcolor(white) aspect(1)	
cd "$out"
	graph export "pile_home_all_methods.pdf", replace
cd "$git_out"
	graph export "pile_home_all_methods.pdf", replace
