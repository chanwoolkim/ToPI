* ------------------------------------------ *
* Preliminary data preparation - participation
* Author: Chanwool Kim
* ------------------------------------------ *

clear all

*Objective: create a good binary participation variable and good months of participation variables

** Age 3 Parental Interview **
*  Questionnaire Page 19

cd "${data_raw}/Harvard Dataverse Sensitive Original Data/parent_interview"
use "00097_Early_Head_Start_B3P_ruf.dta", clear //2110 obs

* Months of age at the time of the interview
gen dob=date(cdob,"YMD") //in trimesters
format dob %td
gen intervew_date=date(b3p_dat,"YMD")
format intervew_date %td
gen age_days=intervew_date-dob
gen age_months=age_days/30
tab age_months // almost all children are 36-39 months

*Dummies for current arrangements being centers. People with no parent interview will be missings.
gen a1_center=(b3p405a1==6)	// arrangement 1
gen a2_center=(b3p405a2==6) // arrangement 2
gen a3_center=(b3p405a3==6) // arrangement 3

*b3p407 is the variable for months, although its name is 407 rather than 408 (range coincides)
*Months using each arrangement
foreach r in 1 2 3 {
	replace b3p407_`r'=. if b3p407_`r'<0
	gen mo`r'=age_months-b3p407_`r' // how many months has the child been using the arrangement
	replace mo`r'=0 if mo`r'<0
	replace mo`r'=age_months if mo`r'>age_months & mo`r'!=.
}

*Months center ages 0-3, prioritizing the one with more hours
gen mo_center1=mo1 if a1_center==1
gen mo_center2=mo2 if a2_center==1
gen mo_center3=mo3 if a3_center==1

gen mo_center_3y=mo_center1
replace mo_center_3y=mo_center2 if mo_center_3y==.
replace mo_center_3y=mo_center3 if mo_center_3y==.
replace mo_center_3y=0 if mo_center_3y==.

gen center_PI=mo_center_3y>0

sum mo_center_3y //defined for all 2110
rename mo_center_3y mo_center_total
keep id center_PI mo_center_total
tempfile ehs_PI3
save `ehs_PI3'

*Adding variables:
* If the age of start for age 3 is older than age of interview at age 2, we need to add age 2
* If it is not, the age 2 exposure should be included at age 3

** Parental interview, age 2 **
use "00097_Early_Head_Start_B2P_ruf.dta", clear //2164 obs
merge 1:1 id using `ehs_PI3'

* Adding information to our previous variables
replace center_PI=1 if b2p405a1==6|b2p405a2==6|b2p405a3==6
tab center_PI // 40% yes, 2174 obs

* Months of age at time of the interview
gen dob = date(cdob,"YMD")
format dob %td
gen intervew_date = date(b2p_dat,"YMD")
format intervew_date %td
gen age_days=intervew_date-dob
gen age_months=age_days/30
tab age_months

* Which arrangements are centers
gen a1_center=(b2p405a1==6)
gen a2_center=(b2p405a2==6)
gen a3_center=(b2p405a3==6)

*How old was child when started using that arrangement
foreach r in 1 2 3 {
	replace b2p407_`r'=. if b2p407_`r'<0
	gen mo`r'=age_months-b2p407_`r'
	replace mo`r'=0 if mo`r'<0
	replace mo`r'=age_months if mo`r'>age_months & mo`r'!=.
}

gen mo_center_2y=0 if _merge!=2
replace mo_center_2y=mo1 if a1_center==1
replace mo_center_2y=mo2 if a2_center==1 & mo_center_2y==.
replace mo_center_2y=mo3 if a3_center==1 & mo_center_2y==.

*Filling up number of months of exposure between ages 2 and 3: up to 12
gen mo_center_23=12 if mo_center_total>12 & mo_center_total!=.
replace mo_center_23=mo_center_total if mo_center_total<12

gen mo_center_pieces=mo_center_23+mo_center_2y
compare mo_center_total mo_center_pieces
replace mo_center_total=max(mo_center_pieces,mo_center_total) 
replace mo_center_total=mo_center_2y if mo_center_2y!=. & mo_center_total==. // For master-only ppl

keep id center_PI mo_center_total mo_center_23 mo_center_2y
tempfile ehs_PI2
save `ehs_PI2'

** Parental interview, age 1 **
use "00097_Early_Head_Start_B1P_ruf.dta", clear
merge 1:1 id using `ehs_PI2', nogen nolabel

replace center_PI=1 if b1p405a1==6|b1p405a2==6|b1p405a3==6
tab center_PI // 46% yes

gen dob = date(cdob,"YMD")
format dob %td
gen intervew_date = date(b1p_dat,"YMD")
format intervew_date %td
gen age_days=intervew_date-dob
gen age_months=age_days/30
tab age_months

gen a1_center=(b1p405a1==6)
gen a2_center=(b1p405a2==6)
gen a3_center=(b1p405a3==6)

foreach r in 1 2 3 {
	replace b1p407_`r'=. if b1p407_`r'<0
	gen mo`r'=age_months-b1p407_`r'
	replace mo`r'=0 if mo`r'<0
	replace mo`r'=age_months if mo`r'>age_months & mo`r'!=.
}

gen mo_center_1y=0
replace mo_center_1y=mo1 if a1_center==1
replace mo_center_1y=mo2 if a2_center==1
replace mo_center_1y=mo3 if a3_center==1

*Just to construct center12:
gen mo_center_12=12 if mo_center_2y>12 & mo_center_2y!=.
replace mo_center_12=mo_center_2y if mo_center_2y<12

gen mo_center_13=24 if mo_center_total>24 & mo_center_total!=.
replace mo_center_13=mo_center_total if mo_center_total<24

gen mo_center_pieces=mo_center_13+mo_center_1y
compare mo_center_total mo_center_pieces
replace mo_center_total=max(mo_center_pieces,mo_center_total)

replace mo_center_total=mo_center_1y if mo_center_1y!=. & mo_center_total==. // For master-only ppl

keep id center_PI mo_center_total mo_center_1y mo_center_12 mo_center_23
sum id center_PI mo_center_total mo_center_1y mo_center_12 mo_center_23

tempfile ehs_PI_participation
save `ehs_PI_participation'

*** Participation in EHS Visits from the Parent Services Interviews ***

use "${data_raw}/Harvard Dataverse Sensitive Original Data/parent_services_exit/00097_Early_Head_Start_P0_ruf.dta", clear
*From the Codebook, page 96, we know that the frequency of EHS home visits is P0F47_1 
*That variable is in the Harvard data: 00097_Early_Head_Start_P0_ruf, variable p0f47_1
gen visits0=p0f47_1
replace visits0=0 if p0f47_1==-2
replace visits0=. if p0f47_1==-5|p0f47_1==-1
replace visits0=. if p0f47_1==99
tab visits0 //2429 observations
replace visits0=1 if visits0>1 & visits0!=.
keep id visits0
tempfile visits0
save `visits0'

use "${data_raw}/Harvard Dataverse Sensitive Original Data/parent_services_exit/00097_Early_Head_Start_P1_ruf.dta", clear
gen visits1=p1f47_1
replace visits1=0 if p1f47_1==-2
replace visits1=. if p1f47_1==-5|p1f47_1==-1|p1f47_1==-4
replace visits1=. if p1f47_1==99
tab visits1 //2248 observations
replace visits1=1 if visits1>1 & visits1!=.
keep id visits1
merge 1:1 id using `visits0', nogenerate
tempfile visits1 
save `visits1'

use "${data_raw}/Harvard Dataverse Sensitive Original Data/parent_services_exit/00097_Early_Head_Start_P2_ruf.dta", clear
gen visits2=p2f47_1
replace visits2=0 if p2f47_1==-2
replace visits2=. if p2f47_1==-5|p2f47_1==-1
replace visits2=. if p2f47_1==99
tab visits2 //2080 observations
replace visits2=1 if visits2>1 & visits2!=.
keep id visits2
merge 1:1 id using `visits1', nogenerate

egen ehs_visits=rowtotal(visits0 visits1 visits2)
replace ehs_visits=1 if ehs_visits>1 & ehs_visits!=.
sum ehs_visits visits0 visits1 visits2 //2726 obs. Nice.
keep id ehs_visits visits0 visits1 visits2
tempfile visits
save `visits'

use "${data_raw}/ICPSR_03804/DS0001/03804-0001-Data.dta", clear
rename IDNUM id
rename PROGTYPE program_type
rename PROGRAM R

merge 1:1 id using "${data_raw}/Harvard Dataverse Sensitive Original Data/baseline/00097_Early_Head_Start_ehs_sites.dta", nogen nolabel
tab sitenum R, row

merge 1:1 id using `visits'
rename _merge merge_visits

*Open ICPSR Data
rename P26_CTR2 			center_used6m  	//By 6th month: Used Any Center Care
rename P215_CR2 			center_used15m 	//By 15th month: Used Any Center Care
rename P2V_CTR2 			center_used26m 	//By PSI 26: Used Child Care Center
rename P2V_CB14 			center_care14m 	//PSIs: IN CENTER CARE AT 14 MONTHS OLD
rename P2V_CB24 			center_care24m 	//PSIs: IN CENTER CARE AT 24 MONTHS OLD
rename P2V_CB36 			center_care36m 	//PSIs: IN CENTER CARE AT 36 MONTHS OLD
rename P2B_CB36				center_care3 	//IN CENTER CARE @36MO W/ PI DATA
replace center_care3=0 if center_care3==-6 	//(missing care section)

rename P2V_EH14				ehs14m		//PSIs: IN EHS CARE AT 14 MONTHS OLD
rename P2V_EH24				ehs24m		//PSIs: IN EHS CARE AT 24 MONTHS OLD
rename P2V_EH36				ehs36m		//PSIs: IN EHS CARE AT 36 MONTHS OLD
rename B1CT_EHS 			ehs_care1	//Tracking: Care provider is EHS center 14
rename B2CT_EHS 			ehs_care2	//Tracking: Care provider is EHS center 24
rename B3CT_EHS 			ehs_care3	//Tracking: Care provider is EHS center 36
rename P2B_E36				ehs3		//In EHS care at age3
replace ehs3=0 if ehs3==-6 				//(missing care section)
*Don't think this adds information AGEHRSE4: PSIs: HRS/WK IN EHS CARE AT 14 MO

foreach var in center_used6m center_used15m center_used26m ///
			   center_care14m center_care24m center_care36m center_care3 ///
			   ehs14m ehs24m ehs36m ehs_care1 ehs_care2 ehs_care3 ehs3{
replace `var'=.  if `var'<0
}

egen any_center=rowtotal(center_used6m center_used15m center_used26m center_care14m center_care24m center_care36m center_care3), missing
replace any_center=1 if any_center>1 & any_center!=.
sum any_center //2042

egen ehs_c=rowtotal(ehs14m ehs24m ehs36m ehs_care1 ehs_care2 ehs_care3 ehs3), missing
replace ehs_c=1 if ehs_c>1 & ehs_c!=.
sum ehs_c //2195

/*
egen ehs_01=rowtotal(ehs14m ehs_care1 ), missing
replace ehs_01=1 if ehs_01>1 & ehs_01!=.
egen ehs_12=rowtotal(ehs24m ehs_care2 ), missing
replace ehs_12=1 if ehs_01>1 & ehs_01!=.
egen ehs_23=rowtotal(ehs36m ehs_care3 ehs3 ), missing
replace ehs_23=1 if ehs_23>1 & ehs_23!=.

reg ehs_01 R
reg ehs_12 R
reg ehs_23 R
*/

keep id R program_type any_center ehs_c center_used6m center_used15m center_used26m center_care14m center_care24m center_care36m center_care3 ehs_visits 
/*ehs_01 ehs_12 ehs_23*/

merge 1:1 id using `ehs_PI_participation'

** Constructing the Binary Variables **
** Notice that this uses more information than just the count variables, so they don't have to coincide **

*Binary Center Variable
gen C=center_PI
replace C=0 if C==. & any_center==0
replace C=1 if any_center==1
label var C "Ever Participated in Any Center"
sum C //.52

*Binary EHS Center Variable
gen D=ehs_c
label var D "Ever Participated in EHS Center"
sum D //.15

*Binary Vists
gen V=ehs_visits
sum V //.47
label var V "Ever Received an EHS Visit"

*Binary Any EHS Variable
gen E=.
replace E=0 if D!=.|V!=.
replace E=1 if D==1|V==1
sum E //.5
label var E "Ever Participated in Any EHS (C/V) Activity"

*Binary Non-EHS Centers Variable (Defines non-EHS as)
gen P=C
replace P=. if D==. //we lose 200 obs
replace P=0 if D==1
label var P "Participated in Non-EHS Centers"
sum P //.38

*Constructing variables in months
gen mo_ehs=mo_center_total if D!=.
replace mo_ehs=0 if D==0

gen D_1=mo_ehs>1 		if mo_ehs!=. & C!=.
gen P_1=C==1 & D_1==0	if mo_ehs!=. & C!=.

gen D_6=mo_ehs>6 		if mo_ehs!=. & C!=.
gen P_6=C==1 & D_6==0	if mo_ehs!=. & C!=.

gen D_12=mo_ehs>12 		if mo_ehs!=. & C!=.
gen P_12=C==1 & D_12==0	if mo_ehs!=. & C!=.

gen D_18=mo_ehs>18 		if mo_ehs!=. & C!=.
gen P_18=C==1 & D_18==0	if mo_ehs!=. & C!=.

cd "$data_working"
save "ehs-participation.dta", replace

merge 1:1 id using ehs-control, keepusing(black m_edu) nogenerate

sum E    if R==1								 //.88
sum E    if R==1 & program_type==1 						 //.79
sum E    if R==1 & program_type==1 & black==1 & m_edu<=2 //.68
sum D    if R==1 & program_type==1 & black==1 & m_edu<=2 //.56
sum D_12 if R==1 & program_type==1 & black==1 & m_edu<=2 //.52

matrix M=J(6,9,.)
matrix rownames M=E D D_1 D_6 D_12 D_18
matrix colnames M=Dt Dc(p_hh) Pt(p_cc) Pc P_nn p_ch p_nh om_c om_n
local r=1

local p_E		P			
local p_D		P	
local p_D_1		P_1
local p_D_6		P_6	
local p_D_12	P_12	
local p_D_18	P_18	

foreach m in E D D_1 D_6 D_12 D_18{
	sum `m' if R==1 & program_type==1
	matrix M[`r',1]=r(mean)
	
	sum `m' if R==0 &  program_type==1
	local p_hh=r(mean)
	matrix M[`r',2]=`p_hh'
		
	sum `p_`m'' if R==1 & program_type==1
	local p_cc=r(mean)
	matrix M[`r',3]=`p_cc'
	
	sum `p_`m'' if R==0 & program_type==1
	matrix M[`r',4]=r(mean)
	
	gen N=`m'==0 & `p_`m''==0 if `m'!=. & `p_`m''!=.
	sum N if R==1 & program_type==1
	local p_nn=r(mean)
	matrix M[`r',5]=`p_nn'
	
	sum `p_`m'' if R==0 & program_type==1
	local p_ch=r(mean)-`p_cc'
	matrix M[`r',6]=`p_ch'
	
	sum N if R==0 & program_type==1
	local p_nh=r(mean)-`p_nn'
	matrix M[`r',7]=`p_nh'

	matrix M[`r',8]=`p_ch'/(`p_ch'+`p_nh')
	
	matrix M[`r',9]=`p_nh'/(`p_ch'+`p_nh')

	drop N
	
	local r=`r'+1
}
matrix list M , format(%12.2f)

* --------- *
* Abecedarian

cd "$data_raw"
use "append-abccare.dta", clear

// See daycare.do for the creation of the variables

drop if id==74 	// died at 3 months
drop if id==85 	// withdrawn at 3 months, does not have SB
drop if id==108 // moved at 6 months, does not have SB
* 900 no-show
* 912 no-show
* 922 no-show
* 78 crossover
* 82 crossover [need]
* 119 crossover [need]

keep if program == "abc"
drop P D // no (1,1)
gen abc_months=dc_fpg1+dc_fpg2+dc_fpg3
gen alt_months=dc_alt1+dc_alt2+dc_alt3

foreach m in 1 6 12 18{
	gen P_`m'=.
	replace P_`m'=0 if alt_months<`m'
	replace P_`m'=1 if alt_months>=`m' & alt_months!=.

	gen D_`m'=.
	replace D_`m'=0 if abc_months<`m'
	replace D_`m'=1 if abc_months>=`m' & abc_months!=.
}

gen P=.
replace P=1 if alt_months>=1 & alt_months!=.
replace P=0 if alt_months<1
*replace P=0 if alt_months==0 // 11 changes!

gen D=.
replace D=1 if abc_months>=1 & abc_months!=.
replace D=0 if abc_months<1

/*
	   gen part=.
	   replace part=1 if D==1
	   replace part=2 if D==0 & P==1
	   replace part=3 if D==0 & P==0
	   tab part, mi
*/

* drop alt_months
tabstat abc_months alt_months, by(R)
* rename P center
* rename D center_abc

tab dc_alt1 if R==0 // 80% had none
tab dc_alt2 if R==0 // 70% had none
tab dc_alt3 if R==0 // 44% had none

gen mo_center=abc_months+alt_months

/*
	   * Treated and control groups
	   cumul mo_center if R==1, gen(v__t) equal
	   cumul mo_center if R==0, gen(v__c) equal
	   line v__t v__c mo_center, sort ylabel(0(0.1)1) legend(order(1 "Treatment" 2 "Control"))

	   * Months of ABC and non-ABC centers
       cumul alt_months if abc_months==0, gen(v_alt) equal
	   cumul abc_months if alt_months==0, gen(v_abc) equal
	   line v_alt v_abc mo_center, sort ylabel(0(0.1)1) legend(order(1 "Alternative" 2 "ABC"))

	   cumul abc_months if R==1, gen(v__t) equal
	   cumul abc_months if R==0, gen(v__c) equal
	   line v__t v__c abc_months, sort ylabel(0(0.1)1) legend(order(1 "Treatment" 2 "Control"))
*/

keep id center abc_months alt_months R D D_1 D_6 D_12 D_18 P P_1 P_6 P_12 P_18 
cd "$data_working"
save "abc-participation.dta", replace
