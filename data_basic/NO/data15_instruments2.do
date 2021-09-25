**************
*** I. EHS ***
**************
global master_path			"/Users/andres/Dropbox/TOPI"
global data_raw "${master_path}/Original datasets"

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

*keep id caregiver_n`y' caregiver`y' weekly_cc_pay`y'
tempfile instruments`y'
save `instruments`y''
}
merge 1:1 id using `instruments2'
drop _merge
merge 1:1 id using `instruments1'
drop _merge

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

gen weekly_cc_pay=weekly_cc_pay3
replace weekly_cc_pay=weekly_cc_pay2 if weekly_cc_pay==.
replace weekly_cc_pay=weekly_cc_pay1 if weekly_cc_pay==.

*just to try:
tab b3p405a1
gen center3=0 if b3p33_03!=.
replace center3=1 if b3p405a1==6
replace center3=1 if b3p405a2==6
replace center3=1 if b3p405a3==6
tab center3
reg center3 caregiver3 //No effect

gen center2=0 if b2p33_03!=.
replace center2=1 if b2p405a1==6
replace center2=1 if b2p405a2==6
replace center2=1 if b2p405a3==6
tab center2
reg center2 caregiver2 //No effect

gen center_ever=.
replace center_ever=0 if b3p33_03==0|b2p33_03==0|b1p33_03==0 //if I have aunts all years this goes to missing!!!
replace center_ever=1 if b3p405a1==6
replace center_ever=1 if b3p405a2==6
replace center_ever=1 if b3p405a3==6
replace center_ever=1 if b2p405a1==6
replace center_ever=1 if b2p405a2==6
replace center_ever=1 if b2p405a3==6
replace center_ever=1 if b1p405a1==6
replace center_ever=1 if b1p405a2==6
replace center_ever=1 if b1p405a3==6

reg center_ever caregiver_ever 	//MORE CAREGIVER MORE CENTER??? WTF. Big!: N=2300, b=0.08
asd

gen non_center=center_ever==0 & center_ever!=.
reg non_center caregiver_ever	//big impact: 2600 obs, -14%

**Examining this in detail

foreach y in 3 2 1{
gen mom_exclusive`y'=.
replace mom_exclusive`y'=1 if b`y'p400==0 & b`y'p400a==0
replace mom_exclusive`y'=0 if b`y'p400==1 | b`y'p400a==1
gen cc_center`y'=.
replace cc_center`y'=0 if mom_exclusive`y'==1
replace cc_center`y'=0 if b`y'p405a1>0 & b`y'p405a1!=.
replace cc_center`y'=1 if b`y'p405a1==6|b`y'p405a2==6|b`y'p405a3==6
gen family`y'=.
replace family`y'=0 if mom_exclusive`y'==1
replace family`y'=0 if b`y'p405a1>0 & b`y'p405a1!=.
replace family`y'=1 if inlist(b`y'p405a1,1,2,3,4)+inlist(b`y'p405a2,1,2,3,4)+inlist(b`y'p405a3,1,2,3,4)

gen non_cc_center`y'	=1-cc_center`y'
reg non_cc_center`y'	caregiver`y'	//not significant
egen group`y'=group(mom_exclusive`y' cc_center`y' family`y' non_cc_center`y'), label
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

reg family`y' 		caregiver`y'		//significant, positive	(13%)
reg cc_center`y' 		caregiver`y' 	//non-significant (0%)
reg mom_exclusive`y' 	caregiver`y'	//significant, negative (-8%)


/*
			Age3	Age2	Age1
Aunt		-8%*	-2%		-4%
Grandma		+2%		+4%		+2%
Sibling		-9%		-5%*	-5%**
*/

}
gen couple3=b3p32
reg family3 has_aunt3		couple3	//10%**
reg family3 has_grandma3	couple3	//11%**
reg family3 has_sibling3 	couple3	//-4%
reg cc_center3 has_aunt3	couple3	//-9%**
reg cc_center3 has_grandma3	couple3	//+1%
reg cc_center3 has_sibling3	couple3	//-4%

gen couple2=b2p32
reg family2 has_aunt2		couple2	//10%**
reg family2 has_grandma2	couple2	//9%**
reg family2 has_sibling2 	couple2	//-7%**
reg cc_center2 has_aunt2	couple2	//-2%
reg cc_center2 has_grandma2	couple2	//+2%
reg cc_center2 has_sibling2	couple2	//0%

gen couple1=b1p32
reg family1 has_aunt1		couple1	//.14**
reg family1 has_grandma1	couple1	//.19**
reg family1 has_sibling1 	couple1	//-0.11**
reg cc_center1 has_aunt1	couple1	//-0.4
reg cc_center1 has_grandma1	couple1	//0.2
reg cc_center1 has_sibling1	couple1	//-0.3

*Try with Ever_caregiver:
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

gen ever_caregiver=ever_grandma==1|ever_aunt==1 if ever_grandma!=.|ever_aunt!=.

reg family3 ever_aunt 			couple3 //11%**
reg family3 ever_grandma 		couple3 //11%**
reg family3 ever_caregiver 		couple3 //12%**
reg cc_center3 ever_aunt		couple3 //-0.05*
reg cc_center3 ever_grandma		couple3 //0
reg cc_center3 ever_caregiver 	couple3 //0**

*Try with Ever_center:
gen ever_family=family3
replace ever_family=1 if family2==1
replace ever_family=0 if family2==0 & ever_family==.
replace ever_family=1 if family1==1
replace ever_family=0 if family1==0 & ever_family==.

gen ever_family=family3
replace ever_family=1 if family2==1
replace ever_family=0 if family2==0 & ever_family==.
replace ever_family=1 if family1==1
replace ever_family=0 if family1==0 & ever_family==.

gen ever_center=cc_center3
replace ever_center=1 if cc_center2==1
replace ever_center=0 if cc_center2==0 & ever_center==.
replace ever_center=1 if cc_center1==1
replace ever_center=0 if cc_center1==0 & ever_center==.

reg ever_family ever_aunt 		couple3 //.17**
reg ever_family ever_grandma 	couple3 //.22**
reg ever_family ever_caregiver 	couple3 //.21**
reg ever_center ever_aunt		couple3 //-3%
reg ever_center ever_grandma	couple3 //+3%
reg ever_center ever_caregiver 	couple3 //0000


***** Try with Center is MAIN care arrangement rather than ever went to center? *****
**Make Family and center mutually exclusive??
**I think this would make our model worse: it is defining our treatment as getting a certain amount of center
asd





asd

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

