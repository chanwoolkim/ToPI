**************
*** I. EHS ***
**************
foreach y in 1 2 3{
use "$data_raw/Harvard Dataverse Sensitive Original Data/parent_interview/00097_Early_Head_Start_B`y'P_ruf.dta", clear
*Presence of a Caregiver Age 3
gen caregiver`y'=.
replace caregiver`y'=0 if b`y'p33_03==0
replace caregiver`y'=0 if b`y'p33_04==0
replace caregiver`y'=0 if b`y'p31==0
replace caregiver`y'=0 if b`y'p31==0
replace caregiver`y'=1 if b`y'p33_03==3 //one or more aunts/uncles at home
replace caregiver`y'=1 if b`y'p33_04==4 //one or more grandparents

gen caregiver_n`y'=.
replace caregiver_n`y'=0 						if b`y'p33_03==0
replace caregiver_n`y'=0 						if b`y'p33_04==0
replace caregiver`y'=0 							if b`y'p31==0
replace caregiver`y'=0							if b`y'p31==0
replace caregiver_n`y'=b`y'p33a03 				if b`y'p33_03==3 //N aunts/uncles at home
replace caregiver_n`y'=b`y'p33a04 				if b`y'p33_04==4 //N grandparents
replace caregiver_n`y'=b`y'p33a04+b`y'p33a03	if b`y'p33_04==4 & b`y'p33_03==3

*weekly childcare price
gen weekly_cc_pay`y'=.
replace weekly_cc_pay`y'=b`y'p424*40 		if b`y'p424p==1
replace weekly_cc_pay`y'=b`y'p424*5 		if b`y'p424p==2
replace weekly_cc_pay`y'=b`y'p424 			if b`y'p424p==3
replace weekly_cc_pay`y'=b`y'p424/2 		if b`y'p424p==4
replace weekly_cc_pay`y'=b`y'p424/4.2 		if b`y'p424p==5
replace weekly_cc_pay`y'=b`y'p424/(4.2*11) 	if b`y'p424p==6
replace weekly_cc_pay`y'=. 					if weekly_cc_pay`y'>4000 //1 case
replace weekly_cc_pay`y'=. 					if weekly_cc_pay`y'<0


** These are not instruments, constructed to understand **
gen mom_exclusive`y'=.
replace mom_exclusive`y'=1 if b`y'p400==0 & b`y'p400a==0
replace mom_exclusive`y'=0 if b`y'p400==1 | b`y'p400a==1

gen family`y'=.
replace family`y'=0 if mom_exclusive`y'==1
replace family`y'=0 if b`y'p405a1>0 & b`y'p405a1!=.
replace family`y'=1 if inlist(b`y'p405a1,1,2,3,4)+inlist(b`y'p405a2,1,2,3,4)+inlist(b`y'p405a3,1,2,3,4)

*assumption: if someone does not answer (-5), they are not in center, but they are still counted as 0
gen center`y'=0 if b`y'p400!=.
replace center`y'=1 if b`y'p405a1==6
replace center`y'=1 if b`y'p405a2==6
replace center`y'=1 if b`y'p405a3==6

gen non_center`y'	=1-center`y'
reg non_center`y'	caregiver`y'	//not significant
egen group`y'=group(mom_exclusive`y' center`y' family`y' non_center`y'), label
tab group`y'

gen has_aunt`y'=b`y'p33_03/3
replace has_aunt`y'=0  if b`y'p31==00
replace has_aunt`y'=.  if b`y'p33_03==-5

gen has_grandma`y'=b`y'p33_04/4
replace has_grandma`y'=0  if b`y'p31==00
replace has_grandma`y'=.  if b`y'p33_04==-5

gen has_sibling`y'=b`y'p33_05/5					
replace has_sibling`y'=0	if b`y'p31==00
replace has_sibling`y'=.  	if b`y'p33_05==-5

gen couple`y'=b`y'p32

** Saving **
tempfile instruments`y'
save `instruments`y''
}

merge 1:1 id using `instruments2'
drop _merge
merge 1:1 id using `instruments1'
drop _merge

** Creating summary Variables **

** Caregiver

replace caregiver3=caregiver2 if caregiver3==.
replace caregiver3=caregiver1 if caregiver3==.
sum caregiver3 //2500 obs

gen caregiver_ever=caregiver3
replace caregiver_ever=1 if caregiver2 ==1
replace caregiver_ever=1 if caregiver1 ==1
replace caregiver_ever=0 if caregiver2 ==0 & caregiver_ever==.
replace caregiver_ever=0 if caregiver1 ==0 & caregiver_ever==.
sum caregiver_ever

gen caregiver_n=.
replace caregiver_n=caregiver_n3
replace caregiver_n=caregiver_n2 if caregiver_n==.
replace caregiver_n=caregiver_n1 if caregiver_n==.

** Weekly Payments

gen weekly_cc_pay=weekly_cc_pay3
replace weekly_cc_pay=weekly_cc_pay2 if weekly_cc_pay==.
replace weekly_cc_pay=weekly_cc_pay1 if weekly_cc_pay==.

** Center

gen ever_center=center3
replace ever_center=1 if center2==1
replace ever_center=0 if center2==0 & ever_center==.
replace ever_center=1 if center1==1
replace ever_center=0 if center1==0 & ever_center==.

** Aunt, Grandma

gen ever_aunt=has_aunt3
replace ever_aunt=1 if has_aunt2==1
replace ever_aunt=0 if has_aunt2==0 & ever_aunt==.
replace ever_aunt=1 if has_aunt1==1
replace ever_aunt=0 if has_aunt1==0 & ever_aunt==.

gen ever_grandma=has_grandma3
replace ever_grandma=1 if has_grandma2==1
replace ever_grandma=0 if has_grandma2==0 & ever_aunt==.
replace ever_grandma=1 if has_grandma1==1
replace ever_grandma=0 if has_grandma1==0 & ever_aunt==.

** Ever in family care:

gen ever_family=family3
replace ever_family=1 if family2==1
replace ever_family=0 if family2==0 & ever_family==.
replace ever_family=1 if family1==1
replace ever_family=0 if family1==0 & ever_family==.

** Regressions **

reg ever_family ever_aunt 		couple3 //.17** similar result for individual years
reg ever_family ever_grandma 	couple3 //.22** similar result for individual years
reg ever_family caregiver_ever 	couple3 //.21**
reg ever_center ever_aunt		couple3 //-3%	results for individual years have some variance
reg ever_center ever_grandma	couple3 //+3%	results for individual years are a bit smaller
reg ever_center caregiver_ever 	couple3 // 0%

** ALTERNATIVE SPECIFICATION: MAIN **

gen main_center=0 if b3p400!=.
replace main_center=1 if b3p405a1==6

gen main_informal=0 if b3p400a!=.
replace main_informal=1 if inlist(b3p405a1,3,4,5,7)


gen main_parents=0 if b3p400a!=.
replace main_parents=1 if b3p400==0 & b3p400a==0
replace main_parents=1 if inlist(b3p405a1,1,2)

reg main_center		caregiver_ever couple3 //Non-significant!!!
reg main_parents	caregiver_ever couple3 //-7%	
reg main_informal	caregiver_ever couple3 //+8%

*Very interesting: access to informal care from relatives at home does not seem
*to substitute for center care, it substitutes for parental care

keep id caregiver_n caregiver_ever weekly_cc_pay ever_center main_center

cd "$data_working"
save ehs-instruments, replace


**************
** II. IHDP **
**************
cd "$data_raw"
use "base-ihdp.dta", clear
gen caregiver_three=.
foreach var of varlist v86a1_f52_3y-v86a15_f52_3y v45a1_f34_2y-v45a15_f34_2y v46a1_f18_1y-v46a15_f18_1y{
replace caregiver_three=0 if `var'!=. & caregiver_three==.
replace caregiver_three=1 if inlist(`var',5,6,7,8,9,10,11,13,14)
}
tab caregiver_three

gen weekly_cc_pay=care_payamt3y //mean 25, reasonable
rename ihdp id
keep id weekly_cc_pay caregiver_three
cd "$data_working"
save ihdp-instruments, replace

