* ------------------------ *
* Data table - subpopulation
* Author: Chanwool Kim
* ------------------------ *

clear all

* --------------------------- *
* Define macros for abstraction

local choice	""White" "Black" "Over Poverty" "Under Poverty" "Total""
local nrow : list sizeof local(choice)
local ncol : list sizeof global(programs)

* ---------------------- *
* Execution - Nonmissing D

matrix count_D = J(`nrow', `ncol', .)
matrix rownames count_D = `choice'
matrix colnames count_D = $program_name
local col = 1

foreach p of global programs {
	cd "$data_analysis"
	use "`p'-subpop-merge.dta", clear
	di "`p'"

	* Count total number of observations
	count if !missing(D)
	local total = r(N)

	count if race_g == 1 & !missing(D)
	matrix count_D[1,`col'] = r(N)
	count if race_g == 0 & !missing(D)
	matrix count_D[2,`col'] = r(N)
	count if poverty == 1 & !missing(D)
	matrix count_D[3,`col'] = r(N)
	count if poverty == 0 & !missing(D)
	matrix count_D[4,`col'] = r(N)

	matrix count_D[5,`col'] = `total'

	local col = `col' + 1
}

matrix list count_D
cd "$subpop_out"
frmttable using count_D, statmat(count_D) sdec(0) fragment tex replace nocenter

cd "$subpop_git_out"
frmttable using count_D, statmat(count_D) sdec(0) fragment tex replace nocenter
