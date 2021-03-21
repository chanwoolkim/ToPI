*----------------------------------*
* CREATING PARTICIPATION VARIABLES *
*----------------------------------*

*		Binary	Binary			Center_		Program_
*		Center	Program			months		months
*		Care	Participation	Care		Participation

*EHS	center	D				YES			Need Questionnaire
*IHDP	center	D				YES(proxy)	Construct from D*Months?
*ABC	P		D				Q YES?		YES?


/*
EHS:
- Ever Center Care Age 3 ok
- Months of Center Care up to Age 3 I can build
- Ever EHS Age 3 ok, but I do not have the original variables
- Months of EHS up to Age 3 I cannot build without the Questionnaire (Parent Services Interview) Mathematica 
IHDP:
- Ever Center Care ok
- Will not try to construct Months until we know it is necessary, it seems possible
*/

*-----------------------*
* I. CENTER CARE in EHS *
*-----------------------*

* HARVARD DATA, FAITHFUL TO QUESTIONNAIRE *
use "/Users/andres/Dropbox/TOPI/Original datasets/Harvard Dataverse Sensitive Original Data/parent_interview/00097_Early_Head_Start_B3P_ruf.dta", clear
gen center_PI=0
replace center_PI=1 if b3p405a1==6
replace center_PI=1 if b3p405a2==6
replace center_PI=1 if b3p405a3==6
tab center_PI //35% yes, 2110 observations

gen dob = date(cdob,"YMD")
format dob %td
gen intervew_date = date(b3p_dat,"YMD")
format intervew_date %td
gen age_days=intervew_date-dob

gen age_months=age_days/30
tab age_months
gen a1_center=(b3p405a1==6)
gen a2_center=(b3p405a2==6)
gen a3_center=(b3p405a3==6)

foreach r in 1 2 3{
replace b3p407_`r'=. if b3p407_`r'<0
gen mo`r'=age_months-b3p407_`r'
replace mo`r'=0 if mo`r'<0
replace mo`r'=age_months if mo`r'>age_months & mo`r'!=.
}

gen mo_center=0
replace mo_center=mo1 if a1_center==1
replace mo_center=mo2 if a2_center==1
replace mo_center=mo3 if a3_center==1

keep id center_PI mo_center
tempfile ehs_PI3
save `ehs_PI3'

use "/Users/andres/Dropbox/TOPI/Original datasets/Harvard Dataverse Sensitive Original Data/parent_interview/00097_Early_Head_Start_B2P_ruf.dta", clear
merge 1:1 id using `ehs_PI3'

gen center_extra=0
replace center_extra=1 if b2p405a1==6
replace center_extra=1 if b2p405a2==6
replace center_extra=1 if b2p405a3==6
tab center_extra //23% yes,  observations

replace center_PI=1 if center_PI==0 & center_extra==1

gen dob = date(cdob,"YMD")
format dob %td
gen intervew_date = date(b2p_dat,"YMD")
format intervew_date %td
gen age_days=intervew_date-dob

gen age_months=age_days/30
tab age_months
gen a1_center=(b2p405a1==6)
gen a2_center=(b2p405a2==6)
gen a3_center=(b2p405a3==6)

foreach r in 1 2 3{
replace b2p407_`r'=. if b2p407_`r'<0
gen mo`r'=age_months-b2p407_`r'
replace mo`r'=0 if mo`r'<0
replace mo`r'=age_months if mo`r'>age_months & mo`r'!=.
}

gen mo_center_extra=0
replace mo_center_extra=mo1 if a1_center==1
replace mo_center_extra=mo2 if a2_center==1
replace mo_center_extra=mo3 if a3_center==1

replace mo_center=mo_center_extra if mo_center<mo_center_extra & mo_center_extra!=.
tab mo_center_extra

keep id center_PI mo_center
tempfile ehs_PI2
save `ehs_PI2'

use "/Users/andres/Dropbox/TOPI/Original datasets/Harvard Dataverse Sensitive Original Data/parent_interview/00097_Early_Head_Start_B1P_ruf.dta", clear
merge 1:1 id using `ehs_PI2'

gen center_extra=0
replace center_extra=1 if b1p405a1==6
replace center_extra=1 if b1p405a2==6
replace center_extra=1 if b1p405a3==6
tab center_extra //20% yes, 2630 observations

replace center_PI=1 if center_PI==0 & center_extra==1

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

foreach r in 1 2 3{
replace b1p407_`r'=. if b1p407_`r'<0
gen mo`r'=age_months-b1p407_`r'
replace mo`r'=0 if mo`r'<0
replace mo`r'=age_months if mo`r'>age_months & mo`r'!=.
}

gen mo_center_extra=0
replace mo_center_extra=mo1 if a1_center==1
replace mo_center_extra=mo2 if a2_center==1
replace mo_center_extra=mo3 if a3_center==1

replace mo_center=mo_center_extra if mo_center<mo_center_extra & mo_center_extra!=.
tab mo_center_extra

sum center_PI //.44 2110 obs

keep id center_PI mo_center
tempfile ehs_PI_participation
save `ehs_PI_participation'

* ALL OTHER VARIABLES *
cd "$data_raw"
use "std-ehs.dta", clear

merge 1:1 id using `ehs_PI_participation'

rename center_used6m center_care6m
	label values center_care6m dummy
rename P2V_CB14 center_care14m
	label values center_care14m dummy
rename center_used15m center_care15m
	label values center_care15m dummy
rename P2V_CB24 center_care24m
	label values center_care24m dummy
rename center_used26m center_care26m
	label values center_care26m dummy
rename P2V_CB36 center_care30m
	label values center_care30m dummy
rename center_care3 center_care36m
	label values center_care36m dummy

* See the analysis of these and other variables in the appendix

*This creation of the variable gains 300 obs, while keeping average and treatment effects
egen center_total=rowtotal(center_PI center_care6m center_care14m center_care15m center_care24m center_care26m center_care30m center_care36m), missing
gen center=(center_total>=1) if center_total!=.
sum center //2354 .50 BIG GAIN IN OBS
reg center treat if program_type==1 //.27, DECENTE

*-----------------------*
* II. EHS PARTICIPATION *
*-----------------------*
egen ehs_total=rowtotal(ehs1 P2V_EH14 ehs2 P2V_EH24 ehs3 P2V_EH36 ehs_care3), mi
gen ehs=(ehs_total>=1) if ehs_total!=.
tab ehs //15%
reg ehs treat if program_type==1 //.58 effect, nice!

gen center_ehs=.
replace center_ehs=1 if ehs==1 & center==1
replace center_ehs=0 if ehs==0 & center!=.
replace center_ehs=0 if ehs!=. & center==0

sum center_ehs
reg center_ehs treat if program_type==1 //.56, very nice

*keep ppvt3 treat D m_age m_edu sibling m_iq race sex gestage mf

*---------------------------------*
* II. MONTHS IN EHS PARTICIPATION *
*---------------------------------*
gen ehs_months=.
replace ehs_months=0 		 if center==0
replace ehs_months=0 		 if center==1 & center_ehs==0
replace ehs_months=mo_center if center==1 & center_ehs==1 // (redundant, just for organization)

gen alt_months=.
replace alt_months=0 		 if center==0
replace alt_months=0 		 if center==1 & center_ehs==1
replace alt_months=mo_center if center==1 & center_ehs==0

sum ehs_months
sum ehs_months if ehs_months>0
sum alt_months
sum alt_months if alt_months>0

asd id center ehs center_ehs ehs_months alt_months

*--------------------------------------------------*
* III. IHDP CENTER CARE and PROGRAM PARTICIPATION  *
*--------------------------------------------------*
cd "$data_raw"
use "base-ihdp.dta", clear

rename admin_treat treat
rename ihdp	id
rename treat R

*Months in Center Care from Questionnaire F52! (there is no question about first year of life)
sum care_oth3y_i21b if R==1 //10mo
sum care_oth3y_i21b if R==0 //8mo
sum care_oth3y_i24b if R==1 //11
sum care_oth3y_i24b if R==0 //7.4

gen centerF52_second=.
replace centerF52_second=0 if v21a_f52_3y==0
replace centerF52_second=1 if v21a_f52_3y==1

gen centerF52_third=.
replace centerF52_third=0 if v24a_f52_3y==0
replace centerF52_third=1 if v24a_f52_3y==1

gen months=.
replace months=0 if centerF52_second!=.
replace months=0 if centerF52_third!=.

replace months=care_oth3y_i21b if care_oth3y_i21b!=. & care_oth3y_i24b==.
replace months=care_oth3y_i24b if care_oth3y_i21b==. & care_oth3y_i24b!=.
replace months=care_oth3y_i21b+care_oth3y_i24b if care_oth3y_i21b!=. & care_oth3y_i24b!=.

*Participation in IHDP
gen D = .
replace D = 0 if careprm_ihdp3 == 0 | caresec_ihdp3 == 0 | careter_ihdp3 == 0
replace D = 1 if careprm_ihdp3 == 1 | caresec_ihdp3 == 1 | careter_ihdp3 == 1

*Binary Center Care indicator (Ever in Center Care)
sum presch4m presch8m presch1y presch1y6m presch2y presch2y6m presch3y //they look vverry reasonable
egen ever_center_total=rowtotal(presch4m presch8m presch1y presch1y6m presch2y presch2y6m presch3y), missing
gen center1=(ever_center_total>=1) if ever_center_total!=.
sum center1 //.5 1057 obs
reg center1 R //.59 nice!

sum presch4m presch8m presch1y presch1y6m presch2y presch2y6m presch3y //they look vverry reasonable
egen ever_center_total2=rowtotal(centerF52_second centerF52_third presch4m presch8m presch1y presch1y6m presch2y presch2y6m presch3y), missing
gen center=(ever_center_total2>=1) if ever_center_total2!=.
sum center //.58 //much higher!!!
reg center R //.51 Still very nice, less strong

gen ihdp_months=.
replace ihdp_months=0 		if center==0
replace ihdp_months=0 		if center==1 & D==0
replace ihdp_months=months 	if center==1 & D==1 // (redundant, just for organization)

gen alt_months=.
replace alt_months=0 		if center==0
replace alt_months=0 		if center==1 & D==1
replace alt_months=months 	if center==1 & D==0

gen part=. //participation
replace part=1 if D==1
replace part=2 if D==0 & center==1 //attending preschool at 3 Year Old
replace part=3 if D==0 & center==0
label define part 1 "IHDP" 2 "Other" 3 "None"
label values part part 
tab part

keep id center part D ihdp_months alt_months

*--------*
* IV ABC *
*--------*
*(see daycare.do for the creation of the variables)

cd "$data_raw"
use "append-abccare.dta", clear

keep if program == "abc"

gen part=.
replace part=1 if D==1
replace part=2 if D==0 & P==1
replace part=3 if D==0 & P==0
tab part, mi

drop alt_months
gen abc_months=dc_fpg1+dc_fpg2+dc_fpg3
gen alt_months=dc_alt1+dc_alt2+dc_alt3
tabstat abc_months alt_months, by(R)

rename P center

keep id center part D abc_months alt_months


/*EXPLORING PARTICIPATION IN EHS

*Variables that show participation in EHS:
/*
P2V_EH14					PSI IN EHS CARE AT n MONTHS OLD (n=14,24,36)	1965 D=11% TE=.57
P2V_EH24					PSI IN EHS CARE AT n MONTHS OLD (n=14,24,36)	1787 D=9%  TE=.52		
P2V_EH36					PSI IN EHS CARE AT n MONTHS OLD (n=14,24,36)	543  D=10% TE=.47
ehs_hrs14m      AGEHRSE4   	PSI Hours per week in EHS care, 14m
ehs_hrs2        AGEHRSE6   	PSI Hours per week in EHS care, 2
ehs_hrs3        AGEHRSE8   	PSI Hours per week in EHS care, 3
ehs1            B1CT_EHS   	Tracking: Care provider is EHS center		371	 D=63% TE=.62 [Probb conditions on being in care]
ehs2            B2CT_EHS   	Tracking: Care provider is EHS center		415  D=51% TE=.60 [Probb conditions on being in care]	
ehs3            B3CT_EHS   	Tracking: Care provider is EHS center		500  D=28% TE=.43 [Probb conditions on being in care]
				P2V_ENG2	BY PSI26:R/FC Eng in >min EHS act.			2129 D=47% TE=.86 [Artificial]
ehs_care3 		P2B_E36		PSI IN EHS at 36 mo								858  D=16% TE=.48

NO: B5P33F01 – 33F08		   	Ever attended EHS


tab ehs_hrs14m

foreach var in P2V_EH14 ehs1 ehs2 P2V_ENG2 P2V_EH24 P2V_EH36 ehs3 ehs_care3 {
di  as text in red "`: var label `var''"
sum `var'
reg `var' t reat if program_type==1
reg `var' treat if program_type==3
label values `var' dummy
}
corr P2V_EH14 P2V_EH24 P2V_EH36 ehs1 ehs2 ehs3 ehs_care3 //corrs are decent
egen analyze_ehs_miss=group(ehs1 P2V_EH14 ehs2 P2V_EH24 ehs3 P2V_EH36    ehs_care3), label missing
tab analyze_ehs_miss
This is kind of a mess: we see both missings and contradictions
*/
*/

/*

*EXPLORING PARTICIPATION VARIABLES
* Appendix: Exploring Variables that show participation in other programs: *

/*
center_used6m   P26_CTR2   	Used child care center by 6m			1954
				P2V_CB14   	PSIs: IN CENTER CARE AT 14 MONTHS OLD	1951
center_hrs14m   AGEHRSC4   	Hours per week in center care, 14m		1897
center_hrs15m   P215_CHR   	Hours per week in center care, 15m		1831
center_used15m  P215_CR2   	Used child care center by 15m			1987
center_hrs2     AGEHRSC6   	Hours per week in center care, 2		1647
				P2V_CB24   	PSIs: IN CENTER CARE AT 24 MONTHS OLD	1699
center_used26m  P2V_CTR2   	Used child care center by 26m			1948
center_hrs26m   P2V_CHRS   	Hours per week in center care, 26m		1683
				P2V_CB36   	PSIs: IN CENTER CARE AT 36 MONTHS OLD	522
center_care3    P2B_CB36   	IN CENTER CARE @36MO W/ PI DATA			983
				HRSCB8	   	HRS/WK IN CENTER CARE @36MO W/ PI DATA
center_hrs3     AGEHRSC8   	Hours per week in center care, 3		512
*/




label define dummy 1 "1" 0 "0"

rename center_used6m center_care6m
sum center_care6m //1954 obs
tab center_care6m //77% no
reg center_care6m treat // 0.15 effect
reg center_care6m treat if program_type==1 //0.38 effect
reg center_care6m treat if program_type==3 //0.16 effect
label values center_care6m dummy

rename P2V_CB14 center_care14m
sum center_care14m //1951 obs
tab center_care14m //75% no
reg center_care14m treat //0.17 effect
reg center_care14m treat if program_type==1 //0.40 effect
reg center_care14m treat if program_type==3 //0.18 effect
label values center_care14m dummy

tab center_hrs14m
gen center_care14m_from_hours=.
replace center_care14m_from_hours=1 if center_hrs14m>0 & center_hrs14m!=.
replace center_care14m_from_hours=0 if center_hrs14m==0
sum center_care14m_from_hours //1897
tab center_care14m_from_hours //77% no
reg center_care14m_from_hours treat //0.17 coef
reg center_care14m_from_hours treat if program_type==1 //.41 coeff
reg center_care14m_from_hours treat if program_type==3 //.16 coeff
label values center_care14m_from_hours dummy

tab center_hrs15m
gen center_care15m_from_hours=.
replace center_care15m_from_hours=1 if center_hrs15m>0 & center_hrs15m!=.
replace center_care15m_from_hours=0 if center_hrs15m==0
sum center_care15m_from_hours //1831
tab center_care15m_from_hours //74% no
reg center_care15m_from_hours treat //0.14 coef
reg center_care15m_from_hours treat if program_type==1 //.36 coeff
reg center_care15m_from_hours treat if program_type==3 //.18 coeff
label values center_care15m_from_hours dummy

rename center_used15m center_care15m
sum center_care15m //1987 obs
tab center_care15m //68% no
reg center_care15m treat // 0.16 effect
reg center_care15m treat if program_type==1 //0.33 effect
reg center_care15m treat if program_type==3 //0.21 effect
label values center_care15m dummy

tab center_hrs2
gen center_care24m_from_hours=.
replace center_care24m_from_hours=1 if center_hrs2>0 & center_hrs2!=.
replace center_care24m_from_hours=0 if center_hrs2==0
sum center_care24m_from_hours //1647
tab center_care24m_from_hours //80% no
reg center_care24m_from_hours treat //0.15 coef
reg center_care24m_from_hours treat if program_type==1 //.33 coeff
reg center_care24m_from_hours treat if program_type==3 //.17 coeff
label values center_care24m_from_hours dummy

rename P2V_CB24 center_care24m
sum center_care24m //1699 obs
tab center_care24m //77% no
reg center_care24m treat //0.16 effect
reg center_care24m treat if program_type==1 //0.32 effect
reg center_care24m treat if program_type==3 //0.18 effect
label values center_care24m dummy

rename center_used26m center_care26m
sum center_care26m //1948 obs
tab center_care26m //58% no
reg center_care26m treat // 0.15 effect
reg center_care26m treat if program_type==1 //0.28 effect
reg center_care26m treat if program_type==3 //0.20 effect
label values center_care26m dummy

rename P2V_CB36 center_care30m
sum center_care30m //522 obs THIS VAR IS A FAILURE
tab center_care30m //75% WEIRD 
reg center_care30m treat //0.16 effect
reg center_care30m treat if program_type==1 //0.38 effect**
reg center_care30m treat if program_type==3 //0.05 effect
label values center_care30m dummy

rename center_care3 center_care36m
sum center_care36m //983 obs TOO LITTLE!!!
tab center_care36m //60% yes
reg center_care36m treat //0.14 effect
reg center_care36m treat if program_type==1 //0.25 effect**
reg center_care36m treat if program_type==3 //0.07 effect
label values center_care36m dummy

tab HRSCB8 
gen center_care36m_from_hours=.
replace center_care36m_from_hours=1 if HRSCB8>0 & HRSCB8!=.
replace center_care36m_from_hours=0 if HRSCB8==0
sum center_care36m_from_hours //973
tab center_care36m_from_hours //59% yes
reg center_care36m_from_hours treat //0.15 coef**
reg center_care36m_from_hours treat if program_type==1 //.25 coeff**
reg center_care36m_from_hours treat if program_type==3 //.08 coeff
label values center_care36m_from_hours dummy

tab center_hrs3 
gen center_care36m_from_hours2=.
replace center_care36m_from_hours2=1 if center_hrs3>0 & center_hrs3!=.
replace center_care36m_from_hours2=0 if center_hrs3==0
sum center_care36m_from_hours2 //512
tab center_care36m_from_hours2 //23% yes, WEIRD
reg center_care36m_from_hours2 treat //0.15 coef**
reg center_care36m_from_hours2 treat if program_type==1 //.39 coeff**
reg center_care36m_from_hours2 treat if program_type==3 //.07 coeff
label values center_care36m_from_hours2 dummy

egen analyze_center_miss=group(center_care6m center_care14m center_care15m center_care24m center_care26m center_care30m center_care36m center_care36m_from_hours center_care36m_from_hours2), label missing
tab analyze_center_miss
	*center_care36m_from_hours2 has no additional information over center_care36m_from_hours
	*center_care36m_from_hours has 7 observations w different values than center_care36m
	*It does not have any additional obs, not worth it
	*center_care30m has less info, no contribution


*Option I: variables in the dataset, adding one by one
gen center_care=.
replace center_care=center_care36m if center_care==. 				//983 changes
corr center_care center_care26m 									//0.56
tab center_care center_care26m, mi //roughly similar 0/1 and 1/0 differences, no clear bias
replace center_care=center_care26m if center_care==. 				//1030

tab center_care //42% attends at age 2/3
reg center_care treat	//.15%
reg center_care treat if program_type==1	//.27 ** DECENTE
reg center_care treat if program_type==3	//.15 **
reg center_care treat if program_type==2	//.09 **

*Option II: variables in dataset, considering Var=1 if ever in center care
egen center_total1=rowtotal(center_care6m center_care14m center_care15m center_care24m center_care26m center_care30m center_care36m), missing
gen center1=(center_total>=1) if center_total!=.
sum center1 //2042 .48
reg center1 treat if program_type==1 //.24, DECENTE

*Option III: variables in dataset, considering Var=1 if ever in center care, adding the one I created w Harvard data
egen center_total=rowtotal(center3 center_care6m center_care14m center_care15m center_care24m center_care26m center_care30m center_care36m), missing
gen center=(center_total>=1) if center_total!=.
sum center //2354 .47 BIG GAIN IN OBS
reg center treat if program_type==1 //.24, DECENTE
*/	

/* APPENDIX: EXPLORING VARIABLES THAT SHOW PARTICIPATION IN CHILD CARE: [Not used] *

/*
P2V_CC14        P2V_CC14   PSIs: IN CHILD CARE AT 14 MONTHS OLD 	1913 D=.63 TE=.12
P2V_CC24        P2V_CC24   PSIs: IN CHILD CARE AT 24 MONTHS OLD 	1569
P2V_CC36        P2V_CC36   PSIs: IN CHILD CARE AT 36 MONTHS OLD 	493		WHY??
ccare_used14m   B1P_NECC   14m ANY CHILD CARE						2341
ccare_used24m   B2P_NECC   24m ANY CHILD CARE						2162
child_care3     P2B_CC36   In child care at age 3					1323	WHY??

ccare_hrs6m     P26_HRS    By 6th mo: Avg Weekly Hrs of Child Care	
center_hrs6m    P26_CHRS   By 6th mo: Avg Weekly Hrs of Center Care
ccare_hrs15m    P215_HRS   By 15th mo: Avg Weekly Hrs of Child Care
HRSB8           HRSB8      HRS/WEEK IN CHILD CARE @36MO W/ PI DATA
ccare_hrs14m    AGEHRS4    Hours per week in child care, 14m
ccare_hrs2      AGEHRS6    Hours per week in child care, 2
ccare_hrs26m    P2V_HRS    Hours per week in child care, 26m
ccare_hrs3      AGEHRS8    Hours per week in child care, 3
*/


corr P2V_CC14 P2V_CC24 P2V_CC36 ccare_used14m ccare_used24m child_care3

foreach var in P2V_CC14 P2V_CC24 P2V_CC36 ccare_used14m ccare_used24m child_care3{
di  as text in red "`: var label `var''"
sum `var'
reg `var' treat if program_type==1
reg `var' treat if program_type==3
}
*/

