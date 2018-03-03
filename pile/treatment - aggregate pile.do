* ------------------------------------------ *
* Graphs of treatment effects - aggregate pile
* Author: Chanwool Kim
* Date Created: 13 Sep 2017
* Last Update: 3 Mar 2018
* ------------------------------------------ *

clear all

* ------------ *
* Prepare matrix

foreach p of global programs {

cd "$pile_working"
use "`p'-home-agg-pile.dta", clear

* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
qui matrix `p'R_1 = J(7, 5, .) // for randomisation variable
qui matrix `p'R_3 = J(8, 5, .) // for randomisation variable
qui matrix `p'D_1 = J(7, 5, .) // for participation variable
qui matrix `p'D_3 = J(8, 5, .) // for participation variable

qui matrix colnames `p'R_1 = `p'R_1num `p'R_1coeff `p'R_1lower `p'R_1upper `p'R_1pval
qui matrix colnames `p'R_3 = `p'R_3num `p'R_3coeff `p'R_3lower `p'R_3upper `p'R_3pval
qui matrix colnames `p'D_1 = `p'D_1num `p'D_1coeff `p'D_1lower `p'D_1upper `p'D_1pval
qui matrix colnames `p'D_3 = `p'D_3num `p'D_3coeff `p'D_3lower `p'D_3upper `p'D_3pval

local row_1 = 1
local row_3 = 1

	* Loop over rows to fill in values into the empty matrix.
	foreach r of global early_home_types {
		qui matrix `p'R_1[`row_1',1] = `row_1'
		qui matrix `p'D_1[`row_1',1] = `row_1'
		
		capture confirm variable norm_home_`r'1y
			if !_rc {
			* Randomisation variable
			qui regress norm_home_`r'1y R $covariates if !missing(D)
			* r(table) stores values from regression (ex. coeff, var, CI).
			qui matrix list r(table)
			qui matrix r = r(table)

			qui matrix `p'R_1[`row_1',2] = r[1,1]
			qui matrix `p'R_1[`row_1',3] = r[5,1]
			qui matrix `p'R_1[`row_1',4] = r[6,1]
			qui matrix `p'R_1[`row_1',5] = r[4,1]
			
			* Participation variable (program specific)
			* We only want to do IV regression only if there is significant variability (> 1%)
			count if !missing(norm_home_`r'1y) & !missing(D)
			local nobs = r(N)
			count if R != D & !missing(norm_home_`r'1y) & !missing(D)
			local ndiff = r(N)
			local nprop = `ndiff'/`nobs'
			
			if `nprop' < 0.01 | `ndiff' < 2 {
			di "Not much variability"
			qui regress norm_home_`r'1y R $covariates if !missing(D)
			}
			
			else {
			qui ivregress 2sls norm_home_`r'1y (D = R) $covariates if !missing(D)
			}
			* r(table) stores values from regression (ex. coeff, var, CI).
			qui matrix list r(table)
			qui matrix r = r(table)
		
			qui matrix `p'D_1[`row_1',2] = r[1,1]
			qui matrix `p'D_1[`row_1',3] = r[5,1]
			qui matrix `p'D_1[`row_1',4] = r[6,1]
			qui matrix `p'D_1[`row_1',5] = r[4,1]
			
			local row_1 = `row_1' + 1
			}
			
			else {
			local row_1 = `row_1' + 1
			}
	}

	* Loop over rows to fill in values into the empty matrix.
	foreach r of global later_home_types {
		qui matrix `p'R_3[`row_3',1] = `row_3'
		qui matrix `p'D_3[`row_3',1] = `row_3'
		
		capture confirm variable norm_home_`r'3y
			if !_rc {
			* Randomisation variable
			qui regress norm_home_`r'3y R $covariates if !missing(D)
			* r(table) stores values from regression (ex. coeff, var, CI).
			qui matrix list r(table)
			qui matrix r = r(table)

			qui matrix `p'R_3[`row_3',2] = r[1,1]
			qui matrix `p'R_3[`row_3',3] = r[5,1]
			qui matrix `p'R_3[`row_3',4] = r[6,1]
			qui matrix `p'R_3[`row_3',5] = r[4,1]
			
			* Participation variable (program specific)
			* We only want to do IV regression only if there is significant variability (> 1%)
			count if !missing(norm_home_`r'3y) & !missing(D)
			local nobs = r(N)
			count if R != D & !missing(norm_home_`r'3y) & !missing(D)
			local ndiff = r(N)
			local nprop = `ndiff'/`nobs'
			
			if `nprop' < 0.01 | `ndiff' < 2 {
			di "Not much variability"
			qui regress norm_home_`r'3y R $covariates if !missing(D)
			}
			
			else {
			qui ivregress 2sls norm_home_`r'3y (D = R) $covariates if !missing(D)
			}
			* r(table) stores values from regression (ex. coeff, var, CI).
			qui matrix list r(table)
			qui matrix r = r(table)
		
			qui matrix `p'D_3[`row_3',2] = r[1,1]
			qui matrix `p'D_3[`row_3',3] = r[5,1]
			qui matrix `p'D_3[`row_3',4] = r[6,1]
			qui matrix `p'D_3[`row_3',5] = r[4,1]
						
			local row_3 = `row_3' + 1
			}
			
			else {
			local row_3 = `row_3' + 1
			}
	}
		
cd "$pile_working"

svmat `p'R_1, names(col)
rename `p'R_1num row_1
keep row_1 `p'R_1coeff `p'R_1lower `p'R_1upper `p'R_1pval
keep if row_1 != .
save "`p'-pile-agg-1", replace

svmat `p'R_3, names(col)
rename `p'R_3num row_3
keep row_3 `p'R_3coeff `p'R_3lower `p'R_3upper `p'R_3pval
keep if row_3 != .
save "`p'-pile-agg-3", replace

svmat `p'D_1, names(col)
rename `p'D_1num row_1
keep row_1 `p'D_1coeff `p'D_1lower `p'D_1upper `p'D_1pval
keep if row_1 != .
save "`p'-pile-agg-D-1", replace

svmat `p'D_3, names(col)
rename `p'D_3num row_3
keep row_3 `p'D_3coeff `p'D_3lower `p'D_3upper `p'D_3pval
keep if row_3 != .
save "`p'-pile-agg-D-3", replace
}

cd "$pile_working"

* Randomisation

use ehscenter-pile-agg-1, clear

foreach p of global programs {
	merge 1:1 row_1 using `p'-pile-agg-1, nogen nolabel
}

rename row_1 row
save agg-pile-1, replace

use ehscenter-pile-agg-3, clear

foreach p of global programs {
	merge 1:1 row_3 using `p'-pile-agg-3, nogen nolabel
}

rename row_3 row
save agg-pile-3, replace

* Participation

use ehscenter-pile-agg-D-1, clear

foreach p of global programs {
	merge 1:1 row_1 using `p'-pile-agg-D-1, nogen nolabel
}

rename row_1 row
save agg-pile-D-1, replace

use ehscenter-pile-agg-D-3, clear

foreach p of global programs {
	merge 1:1 row_3 using `p'-pile-agg-D-3, nogen nolabel
}

rename row_3 row
save agg-pile-D-3, replace

* --------*
* Questions

cd "$pile_working"

use agg-pile-1, clear

tostring row, gen(scale_num)

replace scale = "Total Score" if scale_num == "1"
replace scale = "Development Materials" if scale_num == "2"
replace scale = "Family Culture" if scale_num == "3"
replace scale = "Lack of Hostility" if scale_num == "4"
replace scale = "Learning Stimulation" if scale_num == "5"
replace scale = "Opportunities for Variety" if scale_num == "6"
replace scale = "Warmth" if scale_num == "7"

save agg-pile-1, replace

use agg-pile-3, clear

tostring row, gen(scale_num)

replace scale = "Total Score" if scale_num == "1"
replace scale = "Development Materials" if scale_num == "2"
replace scale = "Family Culture" if scale_num == "3"
replace scale = "Housing" if scale_num == "4"
replace scale = "Lack of Hostility" if scale_num == "5"
replace scale = "Learning Stimulation" if scale_num == "6"
replace scale = "Opportunities for Variety" if scale_num == "7"
replace scale = "Warmth" if scale_num == "8"

save agg-pile-3, replace

use agg-pile-D-1, clear

tostring row, gen(scale_num)

replace scale = "Total Score" if scale_num == "1"
replace scale = "Development Materials" if scale_num == "2"
replace scale = "Family Culture" if scale_num == "3"
replace scale = "Lack of Hostility" if scale_num == "4"
replace scale = "Learning Stimulation" if scale_num == "5"
replace scale = "Opportunities for Variety" if scale_num == "6"
replace scale = "Warmth" if scale_num == "7"

save agg-pile-D-1, replace

use agg-pile-D-3, clear

tostring row, gen(scale_num)

replace scale = "Total Score" if scale_num == "1"
replace scale = "Development Materials" if scale_num == "2"
replace scale = "Family Culture" if scale_num == "3"
replace scale = "Housing" if scale_num == "4"
replace scale = "Lack of Hostility" if scale_num == "5"
replace scale = "Learning Stimulation" if scale_num == "6"
replace scale = "Opportunities for Variety" if scale_num == "7"
replace scale = "Warmth" if scale_num == "8"

save agg-pile-D-3, replace

* ----------------- *
* Execution - P-value

foreach age of numlist 1 3 {
	* Randomisation
	
	cd "$pile_working"
	use agg-pile-`age', clear
	
	foreach p of global programs {
		gen inv_`p'Rcoeff = `p'R_`age'coeff * -1
		gen `p'Rinsig = .
		gen `p'R0_1 = .
		gen `p'R0_05 = .
		replace `p'Rinsig = `p'R_`age'coeff if `p'R_`age'pval > 0.1
		replace `p'R0_1 = `p'R_`age'coeff if `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05
		replace `p'R0_05 = `p'R_`age'coeff if `p'R_`age'pval <= 0.05
	}

	graph dot ehscenterRinsig ehscenterR0_1 ehscenterR0_05 ///
			  ehshomeRinsig ehshomeR0_1 ehshomeR0_05 ///
			  ehsmixedRinsig ehsmixedR0_1 ehsmixedR0_05 ///
			  ihdpRinsig ihdpR0_1 ihdpR0_05 ///
			  abcRinsig abcR0_1 abcR0_05, ///
	marker(1,msize(large) msymbol(D) mlc(red) mfc(red*0) mlw(thin)) marker(2,msize(large) msymbol(D) mlc(red) mfc(red*0.5) mlw(thin)) marker(3,msize(large) msymbol(D) mlc(red) mfc(red) mlw(thin)) ///
	marker(4,msize(large) msymbol(T) mlc(red) mfc(red*0) mlw(thin)) marker(5,msize(large) msymbol(T) mlc(red) mfc(red*0.5) mlw(thin)) marker(6,msize(large) msymbol(T) mlc(red) mfc(red) mlw(thin)) ///
	marker(7,msize(large) msymbol(S) mlc(red) mfc(red*0) mlw(thin)) marker(8,msize(large) msymbol(S) mlc(red) mfc(red*0.5) mlw(thin)) marker(9,msize(large) msymbol(S) mlc(red) mfc(red) mlw(thin)) ///
	marker(10,msize(large) msymbol(O) mlc(green) mfc(green*0) mlw(thin)) marker(11,msize(large) msymbol(O) mlc(green) mfc(green*0.5) mlw(thin)) marker(12,msize(large) msymbol(O) mlc(green) mfc(green) mlw(thin)) ///
	marker(13,msize(large) msymbol(O) mlc(blue) mfc(blue*0) mlw(thin)) marker(14,msize(large) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(thin)) marker(15,msize(large) msymbol(O) mlc(blue) mfc(blue) mlw(thin)) ///
	over(scale, label(labsize(vsmall)) sort(scale_num)) ///
	legend (order (3 "EHS-Center" 6 "EHS-Home" 9 "EHS-Mixed" 12 "IHDP" 15 "ABC") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
	ylabel($agg_axis_range) ///
	graphregion(fcolor(white))
	
	cd "$pile_out"
	graph export "agg_pile_R_`age'.pdf", replace
	
	cd "$pile_git_out"
	graph export "agg_pile_R_`age'.png", replace
	
	* Participation
	
	cd "$pile_working"
	use agg-pile-D-`age', clear
	
	foreach p of global programs {
		gen inv_`p'Dcoeff = `p'D_`age'coeff * -1
		gen `p'Dinsig = .
		gen `p'D0_1 = .
		gen `p'D0_05 = .
		replace `p'Dinsig = `p'D_`age'coeff if `p'D_`age'pval > 0.1
		replace `p'D0_1 = `p'D_`age'coeff if `p'D_`age'pval <= 0.1 & `p'D_`age'pval > 0.05
		replace `p'D0_05 = `p'D_`age'coeff if `p'D_`age'pval <= 0.05
	}
	
	graph dot ehscenterDinsig ehscenterD0_1 ehscenterD0_05 ///
			  ehshomeDinsig ehshomeD0_1 ehshomeD0_05 ///
			  ehsmixedDinsig ehsmixedD0_1 ehsmixedD0_05 ///
			  ihdpDinsig ihdpD0_1 ihdpD0_05 ///
			  abcDinsig abcD0_1 abcD0_05, ///
	marker(1,msize(large) msymbol(D) mlc(red) mfc(red*0) mlw(thin)) marker(2,msize(large) msymbol(D) mlc(red) mfc(red*0.5) mlw(thin)) marker(3,msize(large) msymbol(D) mlc(red) mfc(red) mlw(thin)) ///
	marker(4,msize(large) msymbol(T) mlc(red) mfc(red*0) mlw(thin)) marker(5,msize(large) msymbol(T) mlc(red) mfc(red*0.5) mlw(thin)) marker(6,msize(large) msymbol(T) mlc(red) mfc(red) mlw(thin)) ///
	marker(7,msize(large) msymbol(S) mlc(red) mfc(red*0) mlw(thin)) marker(8,msize(large) msymbol(S) mlc(red) mfc(red*0.5) mlw(thin)) marker(9,msize(large) msymbol(S) mlc(red) mfc(red) mlw(thin)) ///
	marker(10,msize(large) msymbol(O) mlc(green) mfc(green*0) mlw(thin)) marker(11,msize(large) msymbol(O) mlc(green) mfc(green*0.5) mlw(thin)) marker(12,msize(large) msymbol(O) mlc(green) mfc(green) mlw(thin)) ///
	marker(13,msize(large) msymbol(O) mlc(blue) mfc(blue*0) mlw(thin)) marker(14,msize(large) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(thin)) marker(15,msize(large) msymbol(O) mlc(blue) mfc(blue) mlw(thin)) ///
	over(scale, label(labsize(vsmall)) sort(scale_num)) ///
	legend (order (3 "EHS-Center" 6 "EHS-Home" 9 "EHS-Mixed" 12 "IHDP" 15 "ABC") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
	ylabel($agg_axis_range) ///
	graphregion(fcolor(white))

	cd "$pile_out"
	graph export "agg_pile_D_`age'.pdf", replace
	
	cd "$pile_git_out"
	graph export "agg_pile_D_`age'.png", replace
}
