* --------------------------------------------------------------------- *
* Graphs of treatment effects - aggregate pile (IHDP substitution effect)
* Author: Chanwool Kim
* Date Created: 22 Jan 2018
* Last Update: 23 Jan 2018
* --------------------------------------------------------------------- *

clear all

local ihdp_axis_range	-0.0015(0.0005)0.0015

* ------------ *
* Prepare matrix

foreach t of global ihdp_type {

cd "$pile_working"
use "ihdp`t'-home-agg-pile.dta", clear

	* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
	qui matrix ihdp`t'R_1 = J(7, 5, .) // for randomisation variable
	qui matrix ihdp`t'R_3 = J(9, 5, .) // for randomisation variable
	qui matrix ihdp`t'D_1 = J(7, 5, .) // for participation variable
	qui matrix ihdp`t'D_3 = J(9, 5, .) // for participation variable

	qui matrix colnames ihdp`t'R_1 = ihdp`t'R_1num ihdp`t'R_1coeff ihdp`t'R_1lower ihdp`t'R_1upper ihdp`t'R_1pval
	qui matrix colnames ihdp`t'R_3 = ihdp`t'R_3num ihdp`t'R_3coeff ihdp`t'R_3lower ihdp`t'R_3upper ihdp`t'R_3pval
	qui matrix colnames ihdp`t'D_1 = ihdp`t'D_1num ihdp`t'D_1coeff ihdp`t'D_1lower ihdp`t'D_1upper ihdp`t'D_1pval
	qui matrix colnames ihdp`t'D_3 = ihdp`t'D_3num ihdp`t'D_3coeff ihdp`t'D_3lower ihdp`t'D_3upper ihdp`t'D_3pval

	local row_1 = 1
	local row_3 = 1

	* Loop over rows to fill in values into the empty matrix.
	foreach r of global early_home_types {
		qui matrix ihdp`t'R_1[`row_1',1] = `row_1'
		qui matrix ihdp`t'D_1[`row_1',1] = `row_1'
		
		capture confirm variable norm_home_`r'1y
			if !_rc {
			* Randomisation variable
			qui xi: regress norm_home_`r'1y i.R*bw $covariates if !missing(D)
			* r(table) stores values from regression (ex. coeff, var, CI).
			qui matrix list r(table)
			qui matrix r = r(table)

			qui matrix ihdp`t'R_1[`row_1',2] = r[1,3]
			qui matrix ihdp`t'R_1[`row_1',3] = r[5,3]
			qui matrix ihdp`t'R_1[`row_1',4] = r[6,3]
			qui matrix ihdp`t'R_1[`row_1',5] = r[4,3]
			
			local row_1 = `row_1' + 1
			}
				
			else {
			local row_1 = `row_1' + 1
			}
	}

	* Loop over rows to fill in values into the empty matrix.
	foreach r of global later_home_types {
		qui matrix ihdp`t'R_3[`row_3',1] = `row_3'
		qui matrix ihdp`t'D_3[`row_3',1] = `row_3'
			
		capture confirm variable norm_home_`r'3y
			if !_rc {
			* Randomisation variable
			qui xi: regress norm_home_`r'3y i.R*bw $covariates if !missing(D)
			* r(table) stores values from regression (ex. coeff, var, CI).
			qui matrix list r(table)
			qui matrix r = r(table)

			qui matrix ihdp`t'R_3[`row_3',2] = r[1,3]
			qui matrix ihdp`t'R_3[`row_3',3] = r[5,3]
			qui matrix ihdp`t'R_3[`row_3',4] = r[6,3]
			qui matrix ihdp`t'R_3[`row_3',5] = r[4,3]

			local row_3 = `row_3' + 1
			}
				
			else {
			local row_3 = `row_3' + 1
			}
		}
		
	cd "$pile_working"

	svmat ihdp`t'R_1, names(col)
	rename ihdp`t'R_1num row_1
	keep row_1 ihdp`t'R_1coeff ihdp`t'R_1lower ihdp`t'R_1upper ihdp`t'R_1pval
	keep if row_1 != .
	save "ihdp`t'-pile-agg-1", replace

	svmat ihdp`t'R_3, names(col)
	rename ihdp`t'R_3num row_3
	keep row_3 ihdp`t'R_3coeff ihdp`t'R_3lower ihdp`t'R_3upper ihdp`t'R_3pval
	keep if row_3 != .
	save "ihdp`t'-pile-agg-3", replace
}

cd "$pile_working"

* Randomisation

use ihdp-pile-agg-1, clear

foreach t of global ihdp_type {
	merge 1:1 row_1 using ihdp`t'-pile-agg-1, nogen nolabel
}

rename row_1 row
save ihdp-agg-pile-1, replace

use ihdp-pile-agg-3, clear

foreach t of global ihdp_type {
	merge 1:1 row_3 using ihdp`t'-pile-agg-3, nogen nolabel
}

rename row_3 row
save ihdp-agg-pile-3, replace

* --------*
* Questions

cd "$pile_working"

use ihdp-agg-pile-1, clear

tostring row, gen(scale_num)

replace scale = "Total Score" if scale_num == "1"
replace scale = "Parental Warmth" if scale_num == "2"
replace scale = "Parental Verbal Skills" if scale_num == "3"
replace scale = "Parental Lack of Hostility" if scale_num == "4"
replace scale = "Learning/Literacy" if scale_num == "5"
replace scale = "Activities/Outings" if scale_num == "6"
replace scale = "Developmental Advance" if scale_num == "7"

save ihdp-agg-pile-1, replace

use ihdp-agg-pile-3, clear

tostring row, gen(scale_num)

replace scale = "Total Score" if scale_num == "1"
replace scale = "Learning Stimulation" if scale_num == "2"
replace scale = "Access to Reading" if scale_num == "3"
replace scale = "Parental Verbal Skills" if scale_num == "4"
replace scale = "Parental Warmth" if scale_num == "5"
replace scale = "Home Exterior" if scale_num == "6"
replace scale = "Home Interior" if scale_num == "7"
replace scale = "Outings/Activities" if scale_num == "8"
replace scale = "Parental Lack of Hostility" if scale_num == "9"

save ihdp-agg-pile-3, replace

* ----------------- *
* Execution - P-value

foreach age of numlist 1 3 {
	* Randomisation
	
	cd "$pile_working"
	use ihdp-agg-pile-`age', clear
	
	foreach t of global ihdp_type {
		gen inv_ihdp`t'Rcoeff = ihdp`t'R_`age'coeff * -1
		gen ihdp`t'Rinsig = .
		gen ihdp`t'R0_1 = .
		gen ihdp`t'R0_05 = .
		replace ihdp`t'Rinsig = ihdp`t'R_`age'coeff if ihdp`t'R_`age'pval > 0.1
		replace ihdp`t'R0_1 = ihdp`t'R_`age'coeff if ihdp`t'R_`age'pval <= 0.1 & ihdp`t'R_`age'pval > 0.05
		replace ihdp`t'R0_05 = ihdp`t'R_`age'coeff if ihdp`t'R_`age'pval <= 0.05
	}
	
	cd "$pile_out"

	graph dot ihdpRinsig ihdpR0_1 ihdpR0_05 ///
			  ihdphighRinsig ihdphighR0_1 ihdphighR0_05 ///
			  ihdplowRinsig ihdplowR0_1 ihdplowR0_05, ///
	marker(1,msize(large) msymbol(O) mlc(green) mfc(green*0) mlw(thin)) marker(2,msize(large) msymbol(O) mlc(green) mfc(green*0.5) mlw(thin)) marker(3,msize(large) msymbol(O) mlc(green) mfc(green) mlw(thin)) ///
	marker(4,msize(large) msymbol(T) mlc(green) mfc(green*0) mlw(thin)) marker(5,msize(large) msymbol(T) mlc(green) mfc(green*0.5) mlw(thin)) marker(6,msize(large) msymbol(T) mlc(green) mfc(green) mlw(thin)) ///
	marker(7,msize(large) msymbol(S) mlc(green) mfc(green*0) mlw(thin)) marker(8,msize(large) msymbol(S) mlc(green) mfc(green*0.5) mlw(thin)) marker(9,msize(large) msymbol(S) mlc(green) mfc(green) mlw(thin)) ///
	over(scale, label(labsize(vsmall)) sort(scale_num)) ///
	legend (order (3 "IHDP-All" 6 "IHDP-High" 9 "IHDP-Low") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
	ylabel(`ihdp_axis_range') ///
	graphregion(fcolor(white))

	graph export "ihdp_sub_agg_pile_R_`age'.pdf", replace
}
