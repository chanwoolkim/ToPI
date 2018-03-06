* -------------- *
* Data description
* Author: Chanwool Kim
* Date Created: 22 Mar 2017
* Last Update: 4 Mar 2017
* -------------- *

set more off

* --------------------------- *
* Define macros for abstraction

local covariates_table	sex bw gestage black hispanic m_edu m_age m_iq mf
local num : list sizeof local(covariates_table)

* ------- *
* Execution

foreach p of global programs {
cd "$data_home"

	if "`p'" == "ehs" | "`p'" == "ehscenter" | "`p'" == "ehshome" | "`p'" == "ehsmixed" {
		use "ehs-home-control.dta", clear
	}
	
	if "`p'" == "ihdp" {
		use "ihdp-home-control.dta", clear
	}
	
	if "`p'" == "abc" | "`p'" == "care" | "`p'" == "careboth" | "`p'" == "carehome" {
		use "abc-home-control.dta", clear
	}
	
	gen blank = 1

	forval i=1/`num' {
		local var : word `i' of `covariates_table'
		global vlab`i' : variable label `var'
	}

	matrix baseline = [.,.,.,.,.,.]
	matrix colnames baseline = "Mean1" "SD1" "Mean2" "SD2" "MeanDifference" "Pval"

foreach var of varlist `covariates_table' {
	summ `var' if treat == 0
	local meancont = r(mean)
	local   sdcont = r(sd)
	
	summ `var' if treat == 1 
	local meantr = r(mean)
	local   sdtr = r(sd)

	local diff = `meantr' - `meancont'
	
	ttest `var', by(treat)
	local pval = r(p)
	
	matrix `var' = [`meancont',`sdcont',`meantr',`sdtr',`diff',`pval']
	matrix colnames `var' = "Mean1" "SD1" "Mean2" "SD2" "MeanDifference" "Pval"
	
	mat_rapp baseline : baseline `var'
}

matrix baseline = baseline[2...,1...]
matrix rownames baseline = 1 2 3 4 5 6 7 8 9

* ------------ *
* Table creation

clear							
svmat baseline, names(col)
gen ind = _n
gen group = .
replace group = 1 if ind <= 5
replace group = 2 if ind > 6 & ind <= 8
replace group = 3 if ind > 8 & ind <= 9

local label1 Child
local label2 Mother
local label3 Household

global vlab1 "Male"
global vlab2 "Birthweight (grams)"
global vlab3 "Gestational age (weeks)"
global vlab4 "Black"
global vlab5 "Hispanic"
global vlab6 "Mother's education"
global vlab7 "Mother's age at birth"
global vlab8 "Mother's IQ"
global vlab9 "Father/Boyfriend at home"

cd "$data_out"
cap file close texfile
file open texfile using "`p'_datadesc.tex", write replace
file write texfile "\begin{tabular}{lcccccc}" _newline
file write texfile "\toprule" _newline
file write texfile "& \multicolumn{2}{c}{Control} & \multicolumn{2}{c}{Treatment} & \multicolumn{2}{c}{Treatment - Control} \\" _newline
file write texfile "\midrule" _newline
forval g = 1/3{
	file write texfile "\textbf{`label`g''} & & & & & & \\" _newline
	preserve
	keep if group == `g'
	local obs = _N
	forval i = 1/`obs'{
		local varnum = ind[`i']
		local varname "${vlab`varnum'}"
		local row \quad\quad `varname'
		foreach var of varlist Mean1 SD1 Mean2 SD2 MeanDifference Pval{
			local writer = `var'[`i']
			local writer = trim("`: display %10.3f `writer''")
			local row `row' & `writer'
				}
		file write texfile "`row' \\" _newline
		}
	restore
	}
file write texfile "\bottomrule" _newline
file write texfile "\end{tabular}" _newline
file close texfile

cd "$data_git_out"
cap file close texfile
file open texfile using "`p'_datadesc.tex", write replace
file write texfile "\begin{tabular}{lcccccc}" _newline
file write texfile "\toprule" _newline
file write texfile "& \multicolumn{2}{c}{Control} & \multicolumn{2}{c}{Treatment} & \multicolumn{2}{c}{Treatment - Control} \\" _newline
file write texfile "\midrule" _newline
forval g = 1/3{
	file write texfile "\textbf{`label`g''} & & & & & & \\" _newline
	preserve
	keep if group == `g'
	local obs = _N
	forval i = 1/`obs'{
		local varnum = ind[`i']
		local varname "${vlab`varnum'}"
		local row \quad\quad `varname'
		foreach var of varlist Mean1 SD1 Mean2 SD2 MeanDifference Pval{
			local writer = `var'[`i']
			local writer = trim("`: display %10.3f `writer''")
			local row `row' & `writer'
				}
		file write texfile "`row' \\" _newline
		}
	restore
	}
file write texfile "\bottomrule" _newline
file write texfile "\end{tabular}" _newline
file close texfile

}
