* --------------------- *
* By-site analysis (IHDP)
* Author: Chanwool Kim
* Date Created: 4 Feb 2018
* Last Update: 4 Feb 2018
* --------------------- *

clear all

* --------------------------- *
* Define macros for abstraction

* IHDP
local cogs		ppvt sb

* ------- *
* Execution

foreach t of global ihdp_type {
	foreach c of local cogs {
	cd "$data_home"
	use "ihdp`t'-home-agg-merge.dta", clear
	
	levelsof state, local(states)
	
		gen `c'_result = .
		
		foreach s of local states {
			qui regress `c'36 R $covariates if !missing(D) & state == "`s'"
			qui matrix list r(table)
			qui matrix r = r(table)
			local `c'_`s'_result = r[1,1]
			
			replace `c'_result = ``c'_`s'_result' if state == "`s'"
		}
	
	qui matrix ihdp`t'_`c'R_3 = J(9, 5, .) // for randomisation variable
	qui matrix colnames ihdp`t'_`c'R_3 = ihdp`t'_`c'R_3num ihdp`t'_`c'R_3coeff ihdp`t'_`c'R_3lower ihdp`t'_`c'R_3upper ihdp`t'_`c'R_3pval
	
	local row_`c'3 = 1
	
	* Loop over rows to fill in values into the empty matrix.
	foreach r of global later_home_types {
		qui matrix ihdp`t'_`c'R_3[`row_`c'3',1] = `row_`c'3'
				
		capture confirm variable norm_home_`r'36
			if !_rc {
			* Randomisation variable
			qui xi: regress norm_home_`r'36 i.R*`c'_result if !missing(D)
			* r(table) stores values from regression (ex. coeff, var, CI).
			qui matrix list r(table)
			qui matrix r = r(table)

			qui matrix ihdp`t'_`c'R_3[`row_`c'3',2] = r[1,3]
			qui matrix ihdp`t'_`c'R_3[`row_`c'3',3] = r[5,3]
			qui matrix ihdp`t'_`c'R_3[`row_`c'3',4] = r[6,3]
			qui matrix ihdp`t'_`c'R_3[`row_`c'3',5] = r[4,3]

			local row_`c'3 = `row_`c'3' + 1
			}
					
			else {
			local row_`c'3 = `row_`c'3' + 1				
			}
		}
	
	cd "$by_site_working"
	svmat ihdp`t'_`c'R_3, names(col)
	rename ihdp`t'_`c'R_3num row_3
	keep row_3 ihdp`t'_`c'R_3coeff ihdp`t'_`c'R_3lower ihdp`t'_`c'R_3upper ihdp`t'_`c'R_3pval
	keep if row_3 != .
	save "ihdp`t'-`c'-pile-agg-sub-3", replace
	
	}
}

* --------*
* Questions

cd "$by_site_working"

* Randomisation

foreach c of local cogs {

	use ihdp-`c'-pile-agg-sub-3, clear

	foreach t of global ihdp_type {
		merge 1:1 row_3 using ihdp`t'-`c'-pile-agg-sub-3, nogen nolabel
	}

	rename row_3 row
	
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

	save ihdp-`c'-agg-pile-sub-3, replace
}

* ----------------- *
* Execution - P-value

foreach c of local cogs {
	cd "$by_site_working"
	use ihdp-`c'-agg-pile-sub-3, clear
	
	foreach t of global ihdp_type {
		gen inv_ihdp`t'_`c'Rcoeff = ihdp`t'_`c'R_3coeff * -1
		gen ihdp`t'_`c'Rinsig = .
		gen ihdp`t'_`c'R0_1 = .
		gen ihdp`t'_`c'R0_05 = .
		replace ihdp`t'_`c'Rinsig = ihdp`t'_`c'R_3coeff if ihdp`t'_`c'R_3pval > 0.1
		replace ihdp`t'_`c'R0_1 = ihdp`t'_`c'R_3coeff if ihdp`t'_`c'R_3pval <= 0.1 & ihdp`t'_`c'R_3pval > 0.05
		replace ihdp`t'_`c'R0_05 = ihdp`t'_`c'R_3coeff if ihdp`t'_`c'R_3pval <= 0.05
	}
	
	cd "$by_site_out"

	graph dot ihdp_`c'Rinsig ihdp_`c'R0_1 ihdp_`c'R0_05 ///
			  ihdphigh_`c'Rinsig ihdphigh_`c'R0_1 ihdphigh_`c'R0_05 ///
			  ihdplow_`c'Rinsig ihdplow_`c'R0_1 ihdplow_`c'R0_05, ///
		  marker(1,msize(large) msymbol(D) mlc(green) mfc(green*0) mlw(thin)) marker(2,msize(large) msymbol(D) mlc(green) mfc(green*0.5) mlw(thin)) marker(3,msize(large) msymbol(D) mlc(green) mfc(green) mlw(thin)) ///
		  marker(4,msize(large) msymbol(T) mlc(green) mfc(green*0) mlw(thin)) marker(5,msize(large) msymbol(T) mlc(green) mfc(green*0.5) mlw(thin)) marker(6,msize(large) msymbol(T) mlc(green) mfc(green) mlw(thin)) ///
		  marker(7,msize(large) msymbol(O) mlc(green) mfc(green*0) mlw(thin)) marker(8,msize(large) msymbol(O) mlc(green) mfc(green*0.5) mlw(thin)) marker(9,msize(large) msymbol(O) mlc(green) mfc(green) mlw(thin)) ///
		  over(scale, label(labsize(vsmall)) sort(scale_num)) ///
		  legend (order (3 "IHDP-All" 6 "IHDP-High" 9 "IHDP-Low") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
		  ylabel($by_site_axis_range) ///
		  graphregion(fcolor(white))

	graph export "ihdp_by_site_agg_pile_R_3.pdf", replace
}
