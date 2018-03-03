* --------------------------------------- *
* Graphs of treatment effects - parent pile
* Author: Chanwool Kim
* Date Created: 26 Jan 2018
* Last Update: 1 Mar 2018
* --------------------------------------- *

clear all

* ------------ *
* Prepare matrix

foreach p of global programs {

cd "$pile_working"
use "`p'-parent-pile.dta", clear

* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
qui matrix `p'R_1 = J(18, 5, .) // for randomisation variable
qui matrix `p'R_2 = J(18, 5, .) // for randomisation variable

qui matrix colnames `p'R_1 = `p'R_1num `p'R_1coeff `p'R_1lower `p'R_1upper `p'R_1pval
qui matrix colnames `p'R_2 = `p'R_2num `p'R_2coeff `p'R_2lower `p'R_2upper `p'R_2pval

local row_1 = 1
local row_2 = 1

	* Loop over rows to fill in values into the empty matrix.
	foreach r of global parent_types {
		qui matrix `p'R_1[`row_1',1] = `row_1'
		
		capture confirm variable norm_parent_`r'1y
			if !_rc {
			* Randomisation variable
			qui regress norm_parent_`r'1y R $covariates if !missing(D)
			* r(table) stores values from regression (ex. coeff, var, CI).
			qui matrix list r(table)
			qui matrix r = r(table)

			qui matrix `p'R_1[`row_1',2] = r[1,1]
			qui matrix `p'R_1[`row_1',3] = r[5,1]
			qui matrix `p'R_1[`row_1',4] = r[6,1]
			qui matrix `p'R_1[`row_1',5] = r[4,1]
			
			local row_1 = `row_1' + 1
			}
			
			else {
			local row_1 = `row_1' + 1
			}
	}

	* Loop over rows to fill in values into the empty matrix.
	foreach r of global parent_types {
		qui matrix `p'R_2[`row_2',1] = `row_2'
		
		capture confirm variable norm_parent_`r'2y
			if !_rc {
			* Randomisation variable
			qui regress norm_parent_`r'2y R $covariates if !missing(D)
			* r(table) stores values from regression (ex. coeff, var, CI).
			qui matrix list r(table)
			qui matrix r = r(table)

			qui matrix `p'R_2[`row_2',2] = r[1,1]
			qui matrix `p'R_2[`row_2',3] = r[5,1]
			qui matrix `p'R_2[`row_2',4] = r[6,1]
			qui matrix `p'R_2[`row_2',5] = r[4,1]
			
			local row_2 = `row_2' + 1
			}
			
			else {
			local row_2 = `row_2' + 1
			}
	}
		
cd "$pile_working"

svmat `p'R_1, names(col)
rename `p'R_1num row_1
keep row_1 `p'R_1coeff `p'R_1lower `p'R_1upper `p'R_1pval
keep if row_1 != .
save "`p'-pile-parent-1", replace

svmat `p'R_2, names(col)
rename `p'R_2num row_2
keep row_2 `p'R_2coeff `p'R_2lower `p'R_2upper `p'R_2pval
keep if row_2 != .
save "`p'-pile-parent-2", replace
}

cd "$pile_working"

* Randomisation

use ehscenter-pile-parent-1, clear

foreach p of global programs {
	merge 1:1 row_1 using `p'-pile-parent-1, nogen nolabel
}

rename row_1 row
save parent-pile-1, replace

use ehscenter-pile-parent-2, clear

foreach p of global programs {
	merge 1:1 row_2 using `p'-pile-parent-2, nogen nolabel
}

rename row_2 row
save parent-pile-2, replace

* --------*
* Questions

cd "$pile_working"

use parent-pile-1, clear

tostring row, gen(scale_num)

replace scale = "KIDI Total Score" if scale_num == "1"
replace scale = "KIDI Accuracy" if scale_num == "2"
replace scale = "KIDI Attempted" if scale_num == "3"
replace scale = "KIDI Right" if scale_num == "4"
replace scale = "PARI Fostering Dependency" if scale_num == "5"
replace scale = "PARI Seclusiveness of Mother" if scale_num == "6"
replace scale = "PARI Suppression of Aggression" if scale_num == "7"
replace scale = "PARI Exclude Outside Influences" if scale_num == "8"
replace scale = "PARI Suppression of Sexuality" if scale_num == "9"
replace scale = "PARI Marital Conflict" if scale_num == "10"
replace scale = "PARI Rejects Homemaking Role" if scale_num == "11"
replace scale = "PARI Irritability" if scale_num == "12"
replace scale = "PARI Encouraging Verbalization" if scale_num == "13"
replace scale = "PARI Egalitarianism" if scale_num == "14"
replace scale = "PARI Comradeship and Sharing" if scale_num == "15"
replace scale = "PARI Factor: Authority" if scale_num == "16"
replace scale = "PARI Factor: Hostility" if scale_num == "17"
replace scale = "PARI Factor: Democratic" if scale_num == "18"

save parent-pile-1, replace

use parent-pile-2, clear

tostring row, gen(scale_num)

replace scale = "KIDI Total Score" if scale_num == "1"
replace scale = "KIDI Accuracy" if scale_num == "2"
replace scale = "KIDI Attempted" if scale_num == "3"
replace scale = "KIDI Right" if scale_num == "4"
replace scale = "PARI Fostering Dependency" if scale_num == "5"
replace scale = "PARI Seclusiveness of Mother" if scale_num == "6"
replace scale = "PARI Suppression of Aggression" if scale_num == "7"
replace scale = "PARI Exclude Outside Influences" if scale_num == "8"
replace scale = "PARI Suppression of Sexuality" if scale_num == "9"
replace scale = "PARI Marital Conflict" if scale_num == "10"
replace scale = "PARI Rejects Homemaking Role" if scale_num == "11"
replace scale = "PARI Irritability" if scale_num == "12"
replace scale = "PARI Encouraging Verbalization" if scale_num == "13"
replace scale = "PARI Egalitarianism" if scale_num == "14"
replace scale = "PARI Comradeship and Sharing" if scale_num == "15"
replace scale = "PARI Factor: Authority" if scale_num == "16"
replace scale = "PARI Factor: Hostility" if scale_num == "17"
replace scale = "PARI Factor: Democratic" if scale_num == "18"

save parent-pile-2, replace

* ----------------- *
* Execution - P-value

foreach age of numlist 1 2 {
	* Randomisation
	
	cd "$pile_working"
	use parent-pile-`age', clear
	
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
	ylabel($parent_axis_range) ///
	graphregion(fcolor(white))
	
	cd "$pile_out"
	graph export "parent_pile_R_`age'.pdf", replace
	
	cd "$pile_git_out"
	graph export "parent_pile_R_`age'.png", replace
}
