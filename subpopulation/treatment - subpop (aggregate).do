* ------------------------------------------- *
* Treatment effects - subpopulation (aggregate)
* Author: Chanwool Kim
* Date Created: 15 Nov 2017
* Last Update: 1 Mar 2018
* ------------------------------------------- *

clear all

* --------------------------- *
* Define macros for abstraction

local subpop_types	white black rich poor

local white_cond	"race_g == 1 & !missing(D)"
local black_cond	"race_g == 0 & !missing(D)"
local rich_cond		"poverty == 1 & !missing(D)"
local poor_cond		"poverty == 0 & !missing(D)"

/*
Poverty: 1 Over poverty line 0 Under poverty line
Race: 1 White 0 Black
*/

* ------------ *
* Prepare matrix

foreach p of global programs {

cd "$subpop_working"

	foreach t of local subpop_types {
		
	use "`p'-home-subpop-merge.dta", clear

	* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
	qui matrix `p'R`t'_1 = J(7, 3, .) // for randomisation variable
	qui matrix `p'R`t'_3 = J(9, 3, .) // for randomisation variable

	qui matrix colnames `p'R`t'_1 = `p'R`t'_1num `p'R`t'_1coeff `p'R`t'_1pval
	qui matrix colnames `p'R`t'_3 = `p'R`t'_3num `p'R`t'_3coeff `p'R`t'_3pval

	local row_1 = 1
	local row_3 = 1

		* Loop over rows to fill in values into the empty matrix.
		foreach r of global early_home_types {
			qui matrix `p'R`t'_1[`row_1',1] = `row_1'
			
			capture confirm variable norm_home_`r'1y
				if !_rc {
				
				qui count if ``t'_cond'
				local num = r(N)
				
				if `num' > 10 {
					* Run regression (by type)
					qui regress norm_home_`r'1y R $covariates if ``t'_cond'
					
					* r(table) stores values from regression (ex. coeff, var, CI).
					qui matrix list r(table)
					qui matrix r = r(table)
					
					qui matrix `p'R`t'_1[`row_1',2] = r[1,1]
					qui matrix `p'R`t'_1[`row_1',3] = r[4,1]
							
					local row_1 = `row_1' + 1
					}
					
				else {
					local row_1 = `row_1' + 1
				}
				}

				else {
				local row_1 = `row_1' + 1
				}
		}

		* Loop over rows to fill in values into the empty matrix.
		foreach r of global later_home_types {
			qui matrix `p'R`t'_3[`row_3',1] = `row_3'
			
			capture confirm variable norm_home_`r'3y
				if !_rc {
				
				qui count if ``t'_cond'
				local num = r(N)
				
				if `num' > 10 {
					* Run regression (by type)
					qui regress norm_home_`r'3y R $covariates if ``t'_cond'
				
					* r(table) stores values from regression (ex. coeff, var, CI).
					qui matrix list r(table)
					qui matrix r = r(table)
				
					qui matrix `p'R`t'_3[`row_3',2] = r[1,1]
					qui matrix `p'R`t'_3[`row_3',3] = r[4,1]
						
					local row_3 = `row_3' + 1
					}
					
				else {
					local row_3 = `row_3' + 1
				}
				}
				
				else {
				local row_3 = `row_3' + 1
				}
		}

	cd "$subpop_working"

	svmat `p'R`t'_1, names(col)
	rename `p'R`t'_1num row_1
	keep row_1 `p'R`t'_1coeff `p'R`t'_1pval
	keep if row_1 != .
	save "`p'-`t'-subpop-agg-1", replace

	svmat `p'R`t'_3, names(col)
	rename `p'R`t'_3num row_3
	keep row_3 `p'R`t'_3coeff `p'R`t'_3pval
	keep if row_3 != .
	save "`p'-`t'-subpop-agg-3", replace
	}
}

foreach t of local subpop_types {

	cd "$subpop_working"

	use ehscenter-`t'-subpop-agg-1, clear

	foreach p of global programs {
		merge 1:1 row_1 using `p'-`t'-subpop-agg-1, nogen nolabel
	}

	rename row_1 row
	save agg-`t'-subpop-1, replace

	use ehscenter-`t'-subpop-agg-3, clear

	foreach p of global programs {
		merge 1:1 row_3 using `p'-`t'-subpop-agg-3, nogen nolabel
	}

	rename row_3 row
	save agg-`t'-subpop-3, replace
}

* --------*
* Questions

foreach t of local subpop_types {

	cd "$subpop_working"

	use agg-`t'-subpop-1, clear

	tostring row, gen(scale_num)

	replace scale = "Total Score" if scale_num == "1"
	replace scale = "Parental Warmth" if scale_num == "2"
	replace scale = "Parental Verbal Skills" if scale_num == "3"
	replace scale = "Parental Lack of Hostility" if scale_num == "4"
	replace scale = "Learning/Literacy" if scale_num == "5"
	replace scale = "Activities/Outings" if scale_num == "6"
	replace scale = "Developmental Advance" if scale_num == "7"

	save agg-`t'-subpop-1, replace

	use agg-`t'-subpop-3, clear

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

	save agg-`t'-subpop-3, replace
}

* ----------------- *
* Execution - P-value

foreach age of numlist 1 3 {
	foreach t of local subpop_types {
		cd "$subpop_working"
		use agg-`t'-subpop-`age', clear
		
		foreach p of global programs {
			gen inv_`p'R`t'coeff = `p'R`t'_`age'coeff * -1
			gen `p'R`t'insig = .
			gen `p'R`t'0_1 = .
			gen `p'R`t'0_05 = .
			replace `p'R`t'insig = `p'R`t'_`age'coeff if `p'R`t'_`age'pval > 0.1
			replace `p'R`t'0_1 = `p'R`t'_`age'coeff if `p'R`t'_`age'pval <= 0.1 & `p'R`t'_`age'pval > 0.05
			replace `p'R`t'0_05 = `p'R`t'_`age'coeff if `p'R`t'_`age'pval <= 0.05
		}
		
		graph dot ehscenterR`t'insig ehscenterR`t'0_1 ehscenterR`t'0_05 ///
				  ehshomeR`t'insig ehshomeR`t'0_1 ehshomeR`t'0_05 ///
				  ehsmixedR`t'insig ehsmixedR`t'0_1 ehsmixedR`t'0_05 ///
				  ihdphighR`t'insig ihdphighR`t'0_1 ihdphighR`t'0_05 ///
				  ihdplowR`t'insig ihdplowR`t'0_1 ihdplowR`t'0_05 ///
				  abcR`t'insig abcR`t'0_1 abcR`t'0_05 ///
				  carebothR`t'insig carebothR`t'0_1 carebothR`t'0_05 ///
				  carehvR`t'insig carehvR`t'0_1 carehvR`t'0_05, ///
		marker(1,msize(large) msymbol(O) mlc(red) mfc(red*0) mlw(thin)) marker(2,msize(large) msymbol(O) mlc(red) mfc(red*0.5) mlw(thin)) marker(3,msize(large) msymbol(O) mlc(red) mfc(red) mlw(thin)) ///
		marker(4,msize(large) msymbol(T) mlc(red) mfc(red*0) mlw(thin)) marker(5,msize(large) msymbol(T) mlc(red) mfc(red*0.5) mlw(thin)) marker(6,msize(large) msymbol(T) mlc(red) mfc(red) mlw(thin)) ///
		marker(7,msize(large) msymbol(S) mlc(red) mfc(red*0) mlw(thin)) marker(8,msize(large) msymbol(S) mlc(red) mfc(red*0.5) mlw(thin)) marker(9,msize(large) msymbol(S) mlc(red) mfc(red) mlw(thin)) ///
		marker(10,msize(large) msymbol(T) mlc(green) mfc(green*0) mlw(thin)) marker(11,msize(large) msymbol(T) mlc(green) mfc(green*0.5) mlw(thin)) marker(12,msize(large) msymbol(T) mlc(green) mfc(green) mlw(thin)) ///
		marker(13,msize(large) msymbol(O) mlc(green) mfc(green*0) mlw(thin)) marker(14,msize(large) msymbol(O) mlc(green) mfc(green*0.5) mlw(thin)) marker(15,msize(large) msymbol(O) mlc(green) mfc(green) mlw(thin)) ///
		marker(16,msize(large) msymbol(O) mlc(blue) mfc(blue*0) mlw(thin)) marker(17,msize(large) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(thin)) marker(18,msize(large) msymbol(O) mlc(blue) mfc(blue) mlw(thin)) ///
		marker(19,msize(large) msymbol(O) mlc(purple) mfc(purple*0) mlw(thin)) marker(20,msize(large) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(thin)) marker(21,msize(large) msymbol(O) mlc(purple) mfc(purple) mlw(thin)) ///
		marker(22,msize(large) msymbol(T) mlc(purple) mfc(purple*0) mlw(thin)) marker(23,msize(large) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(thin)) marker(24,msize(large) msymbol(T) mlc(purple) mfc(purple) mlw(thin)) ///
		over(scale, label(labsize(vsmall)) sort(scale_num)) ///
		legend (order (3 "EHS-Center" 6 "EHS-Home" 9 "EHS-Mixed" 12 "IHDP-High" 15 "IHDP-Low" 18 "ABC" 21 "CARE-Both" 24 "CARE-Home") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
		ylabel($agg_axis_range) ///
		graphregion(fcolor(white))
		
		cd "${subpop_out}/home"
		graph export "agg_subpop_R_`t'_`age'.pdf", replace
		
		cd "${subpop_git_out}/home"
		graph export "agg_subpop_R_`t'_`age'.png", replace
	}
}
