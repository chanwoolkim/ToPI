*-------------------*
* Descriptive Stats *
*-------------------*

cd "$data_working"




use "ihdp-topi.dta", clear
tab poverty // 401 527 (poverty=1-->nonpoor)
tab m_ed     // 394 270 321
		gen hs=.
		replace hs=1 if m_ed==1|m_ed==2
		replace hs=2 if m_ed==3

gen H=.
replace H = 4212/6000 if D==1
replace H=0 if D==0
*http://www.welfareacademy.org/pubs/early_education/pdfs/Besharov_ECE%20assessments_IHDP.pdf assumes 9 hours/day				

		
save, replace

use "abc-topi.dta", clear
tab poverty // 102 12 (poverty=1-->nonpoor)
tab m_ed     // 77 35 4
		gen hs=.
		replace hs=1 if m_ed==1|m_ed==2
		replace hs=2 if m_ed==3

gen H=.
replace H = 6000/6000 if D==1  // 50 weeks/year, 40 hours per week
replace H=0 if D==0

gen twin=0
	
save, replace

cd "$data_working"
use "abc-topi.dta", clear
gen ww=1
save,replace

*Counts in ABC		
count if hs==1 & bw>2000 & black==1
local hs1_abc=r(N)
count if hs==0 & bw>2000 & black==1
local hs0_abc=r(N)
local hs1_rate_abc= `hs1_abc'/(`hs1_abc' + `hs0_abc')
local hs0_rate_abc= `hs0_abc'/(`hs1_abc' + `hs0_abc')
di "Proportion of Families with HS completed in ABC: `hs1_rate_abc'"

foreach data in ihdp ehscenter{
use "`data'-topi.dta", clear
if "`data'"=="ihdp" drop if missing(pag)
if "`data'"=="ihdp" drop if twin==1
if "`data'"=="ihdp" drop if pag==0  //drops the second twin
count if hs==1 & bw>2000 & black==1
local hs1_`data'=r(N)
count if hs==0 & bw>2000 & black==1
local hs0_`data'=r(N)
local hs1_rate_`data'= `hs1_`data''/(`hs1_`data'' + `hs0_`data'')
local hs0_rate_`data'= `hs0_`data''/(`hs1_`data'' + `hs0_`data'')
di "Proportion of Families with HS completed in `data': `hs1_rate_`data''"

gen ww=.
replace ww= `hs1_rate_abc'/`hs1_rate_`data'' if hs==1
replace ww= `hs0_rate_abc'/`hs0_rate_`data'' if hs==0

save, replace
}




				

