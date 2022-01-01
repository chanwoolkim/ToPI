***********************************************
*** Expermenting with Instruments, Dec 2021 ***
***********************************************
*center any_ehs1 any_ehs2 center_ehs1 center_ehs2 ehs_months alt_months ///
*D_1 D_6 D_12 D_18 P P_1 P_6 P_12 P_18 alt1 alt2

cd $data_working

*****************************************
*** Data Experiments with Full Sample ***
*****************************************
matrix A=J(50,10,.)
matrix colnames A = "HomeEHS" "Chop B" "Chop Ed" "Months" "b_N" "p" "b_P" p CD MinCD
matrix rownames A = "R_Pr" "R_Pr" "R_Pr" "R_Pr" ///
					"R_Pr" "R_Pr" "R_Pr" "R_Pr" ///	
					"R_Pr_R0Pr" "R_Pr_R0Pr" "R_Pr_R0Pr" "R_Pr_R0Pr" ///	
					"R_Pr_R1Pr" "R_Pr_R1Pr" "R_Pr_R1Pr" "R_Pr_R1Pr" ///	
					"R_Pr_RHome" "R_Pr_RHome" "R_Pr_RHome" "R_Pr_RHome" ///	
					"R_Pr_Rblack" "R_Pr_Rm_iq" "R_Pr_Rsex" "R_Pr_Rm_age" "R_Pr_Rm_edu"      ///
					"R_Pr" "R_Pr" "R_Pr" "R_Pr" ///
					"R_Pr_RHome" "R_Pr_RHome" "R_Pr_RHome" "R_Pr_RHome"  ///
					"R_Pr" "R_Pr" "R_Pr" "R_Pr" ///
					"R_Pr_RHome" "R_Pr_RHome" "R_Pr_RHome" "R_Pr_RHome"  
					
*** Clean Data ***

use ehs-full-topi, clear

gen N_1=(D_1==0 & P_1==0) if D_1!=. & P_1!=.
reg N_1 cc_price_relative	//3.15
reg N_1 caregiver_ever 		//
reg N_1 cc_payments_site 	//3.4
gen N_6=(D_6==0 & P_6==0) if D_6!=. & P_6!=.
reg N_6 cc_price_relative	//5.2
reg N_6 caregiver_ever 		//
reg N_6 cc_payments_site 	//4.9
gen N_12=(D_12==0 & P_12==0) if D_12!=. & P_12!=.
reg N_12 cc_price_relative	//6
reg N_12 caregiver_ever 	//
reg N_12 cc_payments_site 	//6
gen N_18=(D_18==0 & P_18==0) if D_18!=. & P_18!=.
reg N_18 cc_price_relative	//7
reg N_18 caregiver_ever 	//
reg N_18 cc_payments_site 	//7

sum any_ehs1	//.15
sum any_ehs2	//.47

sum P_1			//.23
sum D_1			//.12
sum N_1			//.63

sum P_6			//.17
sum D_6			//.11
sum N_6			//.7

sum P_12		//.12
sum D_12		//.11
sum N_12		//.76

rename D oldD //this is minimal engagement
*reg D R //t=102
*reg alt R // -22 because it was based on the engagement variable
*How is alt created? YES THIS IS IT
drop alt
gen alt=.
replace alt=0 if center!=.
replace alt=1 if center==1 & oldD==0 //

gen P2=.
replace P2=0 if center!=.
replace P2=1 if center==1 & D_1==0 // D==0 is equivalent to doing center_ehs==0
reg P2 R 	//-1.78
reg P_1 R 	//-1.38

*** Initial Exploratory Regressions ***


reg alt 	cc_price_relative 	//good
reg alt 	caregiver_ever 		//nothing
reg alt 	cc_payments_site 	//good		-2.68
reg alt1 	cc_price_relative 	//nothing
reg alt1 	caregiver_ever 		//nothing
reg alt1 	cc_payments_site 	//nothing
reg alt2 	cc_price_relative 	//-2
reg alt2 	caregiver_ever 		//nothing
reg alt2 	cc_payments_site 	//nothing
reg P2 		cc_price_relative 	//nothing
reg P2 		caregiver_ever 		//nothing
reg P2 		cc_payments_site 	//nothing
reg P_1 	cc_price_relative 	//nothing
reg P_1 	caregiver_ever 		//nothing
reg P_1 	cc_payments_site 	//nothing
reg P_6 	cc_price_relative 	//-2.21
reg P_6 	caregiver_ever 		//nothing
reg P_6 	cc_payments_site 	//nothing
reg P_12 	cc_price_relative 	// -4.17
reg P_12 	caregiver_ever 		//
reg P_12 	cc_payments_site 	// -2.78
reg P_18 	cc_price_relative 	// -4.79
reg P_18 	caregiver_ever 		//nothing
reg P_18 	cc_payments_site 	// -3.93

tabstat center any_ehs1 any_ehs2 center_ehs1 center_ehs2 ehs_months alt_months if oldD==1

tabstat center any_ehs1 any_ehs2 center_ehs1 center_ehs2 ehs_months alt_months if oldD==0 	//3% ehs children in control group
																							//they seem to be all in centers
tabstat center any_ehs1 any_ehs2 center_ehs1 center_ehs2 ehs_months alt_months if alt==1
tabstat center any_ehs1 any_ehs2 center_ehs1 center_ehs2 ehs_months alt_months if P_1==1
tabstat center any_ehs1 any_ehs2 center_ehs1 center_ehs2 ehs_months alt_months if P_12==1
tabstat center any_ehs1 any_ehs2 center_ehs1 center_ehs2 ehs_months alt_months if P_18==1

reg oldD R	//t=102
reg D_1 R	//t=14
reg D_6 R	//t=14
reg D_12 R	//t=14
reg D_18 R	//t=14

*Estimation I
local r=1
foreach n in 1 6 12 18{
ivreg2 ppvt3 (N_`n' P_`n' = cc_price_relative R)	i.program_type
matrix A[`r',1]=1
matrix A[`r',2]=0
matrix A[`r',3]=0
matrix A[`r',4]=`n'
matrix A[`r',5]=_b[N_]
matrix A[`r',6]=2*ttail(e(N),abs(_b[N_]/_se[N_]))
matrix A[`r',7]=_b[P_]
matrix A[`r',8]=2*ttail(e(N),abs(_b[P_]/_se[P_]))
matrix A[`r',9]=e(cdf) 
matrix A[`r',10]=3.63
local r=`r'+1
}
matrix list A, format( %9.2g)

*Not controlling for program type
ivreg2 ppvt3 (N_6 P_6   = cc_price_relative R)	//CD=12
ivreg2 ppvt3 (N_12 P_12 = cc_price_relative R)	//CD=16
ivreg2 ppvt3 (N_18 P_18 = cc_price_relative R)	//CD=16

*PAYMENTS SITE SEEM BAD
ivreg2 ppvt3 (N_6 P_6   = cc_payments_site R)	//CD=12 b=.26 g=-2
ivreg2 ppvt3 (N_12 P_12 = cc_payments_site R)	//CD=16 b=.16 g=-2
ivreg2 ppvt3 (N_18 P_18 = cc_payments_site R)	//CD=16 b=.14 g=-3

ivreg2 ppvt3 (N_6 P_6   = cc_payments_site R)	i.program_type //CD: BAD
ivreg2 ppvt3 (N_12 P_12 = cc_payments_site R)	i.program_type //CD: 6.6 b=-0.1 g=-2.5
ivreg2 ppvt3 (N_18 P_18 = cc_payments_site R)	i.program_type //CD: 8.6 b=-0.5 g=-2.5
*END PAYMENTS SITE


*** Trying Non-Visits Sites only ***
local r=5
foreach n in 1 6 12 18{
ivreg2 ppvt3 (N_`n' P_`n'    = cc_price_relative R)	i.program_type if program_type!=2
matrix A[`r',1]=0
matrix A[`r',2]=0
matrix A[`r',3]=0
matrix A[`r',4]=`n'
matrix A[`r',5]=_b[N_]
matrix A[`r',6]=2*ttail(e(N),abs(_b[N_]/_se[N_]))
matrix A[`r',7]=_b[P_]
matrix A[`r',8]=2*ttail(e(N),abs(_b[P_]/_se[P_]))
matrix A[`r',9]=e(cdf) 
matrix A[`r',10]=3.63
local r=`r'+1
}
matrix list A, format( %9.2g)



ivreg2 ppvt3 (N_6 P_6    = cc_price_relative R)	i.program_type if program_type!=2 //CD=2 (with all program types was CD=7)
ivreg2 ppvt3 (N_12 P_12 = cc_price_relative R)	i.program_type if program_type!=2 //CD=3								CD=10
ivreg2 ppvt3 (N_18 P_18 = cc_price_relative R)	i.program_type if program_type!=2 //CD=5								CD=12


ivreg2 ppvt3 (D_18 N_18 = cc_price_relative R)	i.program_type										//CD=12/7
ivreg2 ppvt3 (N_18 P_18  = cc_price_relative R)	i.program_type if program_type==1|program_type==3 	//CD=5/7  b_N=-.5 b_P=.17

ivreg2 ppvt3 (P_18 N_18 = cc_price_relative R)										//CD=16 b=-1.2 g=-0.12 N=1366
ivreg2 ppvt3 (P_18 N_18 = cc_price_relative R)	if program_type==1|program_type==3 	//CD=3.7 b=-1 g=-2 N=790 CRAP!

ivreg2 ppvt3 (P_6 N_6   = cc_price_relative R)	i.program_type										//CD=7   b=-.74 g=-.21
ivreg2 ppvt3 (P_6 N_6   = cc_price_relative R)	i.program_type if program_type==1|program_type==3 	//CD=2.3 b=.24  g=-.57 CD TOO LOW
ivreg2 ppvt3 (P_12 N_12 = cc_price_relative R)	i.program_type										//CD=10	 b=-.74 g=-.25
ivreg2 ppvt3 (P_12 N_12 = cc_price_relative R)	i.program_type if program_type==1|program_type==3 	//CD=3					CD TOO LOW
ivreg2 ppvt3 (P_18 N_18 = cc_price_relative R)	i.program_type										//CD=12 b=-.81 g=-.27
ivreg2 ppvt3 (P_18 N_18 = cc_price_relative R)	i.program_type if program_type==1|program_type==3 	//CD=5.3 b=.17 g=-.5 N=790

ivreg2 ppvt3 (D_18 = R) //.33
ivreg2 ppvt3 (D_18 = R) if program_type==1|program_type==3 //.32
ivreg2 ppvt3 (D_18 = R) if program_type==1 //.29
ivreg2 ppvt3 (D_18 = R) if program_type==3 //.62
ivreg2 ppvt3 (D_18 = R) if program_type==2
tab D_18 if program_type==2 & ppvt3!=.

ivreg2 ppvt3 (P_18 = cc_price_relative)  									//-1.1 CD is 26
ivreg2 ppvt3 (P_18 = cc_price_relative) if program_type==1|program_type==3 	// 1.6 CD is 8
ivreg2 ppvt3 (P_18 = cc_price_relative) if program_type==1 					//-4.5 CD is 8
ivreg2 ppvt3 (P_18 = cc_price_relative) if program_type==3 					// 1.1 CD is 6
ivreg2 ppvt3 (P_18 = cc_price_relative) if program_type==2 					//-1.7 CD is 17

*** Interactions Between Instruments ***
gen R0inter=(1-R)*cc_price_relative
gen R1inter=R*cc_price_relative

local r=9
foreach n in 1 6 12 18{
ivreg2 ppvt3 (N_`n' P_`n'   = cc_price_relative R R0inter)	i.program_type
matrix A[`r',1]=1
matrix A[`r',2]=0
matrix A[`r',3]=0
matrix A[`r',4]=`n'
matrix A[`r',5]=_b[N_]
matrix A[`r',6]=2*ttail(e(N),abs(_b[N_]/_se[N_]))
matrix A[`r',7]=_b[P_]
matrix A[`r',8]=2*ttail(e(N),abs(_b[P_]/_se[P_]))
matrix A[`r',9]=e(cdf) 
matrix A[`r',10]=5.45
local r=`r'+1
}
matrix list A, format( %9.2g)

local r=13
foreach n in 1 6 12 18{
ivreg2 ppvt3 (N_`n' P_`n'   = cc_price_relative R R1inter)	i.program_type
matrix A[`r',1]=1
matrix A[`r',2]=0
matrix A[`r',3]=0
matrix A[`r',4]=`n'
matrix A[`r',5]=_b[N_]
matrix A[`r',6]=2*ttail(e(N),abs(_b[N_]/_se[N_]))
matrix A[`r',7]=_b[P_]
matrix A[`r',8]=2*ttail(e(N),abs(_b[P_]/_se[P_]))
matrix A[`r',9]=e(cdf) 
matrix A[`r',10]=5.45
local r=`r'+1
}
matrix list A, format( %9.2g)

ivreg2 ppvt3 (N_6 P_6   = cc_price_relative R R0inter)	i.program_type //6/13. Original: CD=7/7
ivreg2 ppvt3 (N_12 P_12 = cc_price_relative R R0inter)	i.program_type //8/13. Original: CD=10/7
ivreg2 ppvt3 (N_18 P_18 = cc_price_relative R R0inter)	i.program_type //9/13. Original: CD=12/7

ivreg2 ppvt3 (N_6 P_6   = cc_price_relative R R1inter)	i.program_type //6/13. Original: CD=7/7
ivreg2 ppvt3 (N_12 P_12 = cc_price_relative R R1inter)	i.program_type //8/13. Original: CD=10/7
ivreg2 ppvt3 (N_18 P_18 = cc_price_relative R R1inter)	i.program_type //9/13. Original: CD=12/7

ivreg2 ppvt3 (N_6 P_6  =  R R0inter)	i.program_type //8/7. Original: CD=7/7  b_N=-.28 b_P=-.45
ivreg2 ppvt3 (N_12 P_12 = R R0inter)	i.program_type //8/7. Original: CD=10/7 similar
ivreg2 ppvt3 (N_18 P_18 = R R0inter)	i.program_type //8/7. Original: CD=12/7 similar

ivreg2 ppvt3 (N_6 P_6  =  R R1inter)	i.program_type //0/7. Original: CD=7/7
ivreg2 ppvt3 (N_12 P_12 = R R1inter)	i.program_type //2/7. Original: CD=10/7
ivreg2 ppvt3 (N_18 P_18 = R R1inter)	i.program_type //3/7. Original: CD=12/7


*** Interactions Between Instruments and Program Type ***
gen R_inter_type2=R*(program_type==2)

local r=17
foreach n in 1 6 12 18{
ivreg2 ppvt3 (N_`n'  P_`n'  = cc_price_relative R R_inter_type2)	i.program_type
matrix A[`r',1]=1
matrix A[`r',2]=0
matrix A[`r',3]=0
matrix A[`r',4]=`n'
matrix A[`r',5]=_b[N_]
matrix A[`r',6]=2*ttail(e(N),abs(_b[N_]/_se[N_]))
matrix A[`r',7]=_b[P_]
matrix A[`r',8]=2*ttail(e(N),abs(_b[P_]/_se[P_]))
matrix A[`r',9]=e(cdf) 
matrix A[`r',10]=5.45
local r=`r'+1
}
matrix list A, format( %9.2g)



ivreg2 ppvt3 (N_6  P_6  = cc_price_relative R R_inter_type2)	i.program_type // 7/13. Original: CD=7/7	b_N=-.19 b_P=-.62
ivreg2 ppvt3 (N_12 P_12 = cc_price_relative R R_inter_type2)	i.program_type // 9/13. Original: CD=10/7	b_N=-.22 b_P=-.67
ivreg2 ppvt3 (N_18 P_18 = cc_price_relative R R_inter_type2)	i.program_type // 9/13. Original: CD=12/7	b_N=-.25 b_P=-.77

tab D_1 if program_type==2 & ppvt3!=. //1
tab P_1 if program_type==2 & ppvt3!=. //150
tab any_ehs1 if program_type==2 & ppvt3!=. //1
tab any_ehs2 if program_type==2 & ppvt3!=. //265
tab center_ehs2 if program_type==2 & ppvt3!=. //107
tab center if program_type==2 & ppvt3!=. //225
reg center R if program_type==2 & ppvt3!=. //Non-significant, they are going to other types of centers

ivreg2 ppvt3 ( P_18 N_18 = cc_price_relative R R_inter_type2) i.program_type, first

*** Interactions Between Instruments and Covariates ***
local r=21
foreach var in black m_iq sex m_age m_edu{
gen R_inter_`var'=R*`var'
ivreg2 ppvt3 (N_18  P_18  = cc_price_relative R R_inter_`var')	i.program_type
matrix A[`r',1]=1
matrix A[`r',2]=0
matrix A[`r',3]=0
matrix A[`r',4]=18
matrix A[`r',5]=_b[N_]
matrix A[`r',6]=2*ttail(e(N),abs(_b[N_]/_se[N_]))
matrix A[`r',7]=_b[P_]
matrix A[`r',8]=2*ttail(e(N),abs(_b[P_]/_se[P_]))
matrix A[`r',9]=e(cdf) 
matrix A[`r',10]=5.45
local r=`r'+1
}
matrix list A, format( %9.2g)









reg D_18 black R i.program_type //t=2.4
reg D_18 m_iq R i.program_type 	//t=3.4
reg D_18 sex R i.program_type 	//t=0
reg D_18 m_age R i.program_type //t=2.5
reg D_18 m_edu R i.program_type //t=5

reg P_1  black R i.program_type //t=4.6
reg P_18 black R i.program_type //t=3.6
reg P_1  m_iq R i.program_type 	//t=
reg P_18 m_iq R i.program_type 	//t=
reg P_1  sex R i.program_type 	//t=0
reg P_18 sex R i.program_type 	//t=0
reg P_1  m_age R i.program_type //t=
reg P_18 m_age R i.program_type //t=
reg P_1  m_edu R i.program_type //t=3
reg P_18 m_edu R i.program_type //t=2

foreach var in black m_iq sex m_age m_edu{
gen price_inter_`var'=cc_price_relative*`var'
}
reg P_12 R_inter_black 	black 	R i.program_type //
reg P_12 R_inter_m_iq 	m_iq 	R i.program_type //
reg P_12 R_inter_sex 	sex 	R i.program_type //
reg P_12 R_inter_m_age 	m_age 	R i.program_type //barely significant
reg P_12 R_inter_m_edu	m_edu 	R i.program_type //

reg P_12 price_inter_black 	black 	cc_price_relative	R i.program_type //
reg P_12 price_inter_m_iq 	m_iq 	cc_price_relative	R i.program_type //significant
reg P_12 price_inter_sex 	sex 	cc_price_relative	R i.program_type //
reg P_12 price_inter_m_age 	m_age 	cc_price_relative	R i.program_type //
reg P_12 price_inter_m_edu	m_edu 	cc_price_relative	R i.program_type //

ivreg2 ppvt3 (N_18 P_18 = cc_price_relative R R_inter_black)	i.program_type // 9/13. Original: CD=12/7
ivreg2 ppvt3 (N_18 P_18 = cc_price_relative R R_inter_m_iq)		i.program_type // 9/13. Original: CD=12/7
ivreg2 ppvt3 (N_18 P_18 = cc_price_relative R R_inter_sex)		i.program_type // 8/13. Original: CD=12/7
ivreg2 ppvt3 (N_18 P_18 = cc_price_relative R R_inter_m_age)	i.program_type // 8/13. Original: CD=12/7
ivreg2 ppvt3 (N_18 P_18 = cc_price_relative R R_inter_m_edu)	i.program_type // 9/13. Original: CD=12/7


****************
*** CHOPPIN' ***
****************

gen m_edu_lessHS = (m_edu == 1)
gen m_edu_HS     = (m_edu == 2)
gen m_edu_moreHS = (m_edu == 3)
gen R_inter_m_edu_lessHS=R*m_edu_lessHS
rename m_edu_moreHS medumoreHS 
rename m_edu_lessHS medulessHS 

global chop "black==1 & (m_edu_HS==1|medulessHS==1)"

tab cc_price_relative if ppvt3!=. & $chop
gen price_h=cc_price_relative>0.07
reg P_18 price_h R if ppvt3!=. & $chop
reg P_12 price_h R if ppvt3!=. & $chop
reg P_6  price_h R if ppvt3!=. & $chop

*** Basic Instruments ***
reg P_1		cc_price_relative if $chop	//nothing
reg P_6		cc_price_relative if $chop 	//t=-1.7
reg P_12	cc_price_relative if $chop 	//t=-2	
reg P_18	cc_price_relative if $chop	//nothing

reg P_1		cc_payments_site if $chop	//nothing
reg P_6		cc_payments_site if $chop 	//nothing
reg P_12	cc_payments_site if $chop 	//nothing
reg P_18	cc_payments_site if $chop	//nothing

reg N_1		caregiver_ever if $chop		//nothing
reg N_6		caregiver_ever if $chop 	//nothing
reg N_12	caregiver_ever if $chop 	//nothing
reg N_18	caregiver_ever if $chop		//nothing

reg P_1		R cc_price_relative if $chop	//nothing
reg P_6		R cc_price_relative if $chop 	//t=-1.7
reg P_12	R cc_price_relative if $chop 	//t=-2	
reg P_18	R cc_price_relative if $chop	//nothing

reg P_1		R cc_payments_site if $chop	//nothing
reg P_6		R cc_payments_site if $chop //nothing
reg P_12	R cc_payments_site if $chop //nothing
reg P_18	R cc_payments_site if $chop	//nothing

reg N_1		R caregiver_ever if $chop	//nothing
reg N_6		R caregiver_ever if $chop 	//nothing
reg N_12	R caregiver_ever if $chop 	//nothing
reg N_18	R caregiver_ever if $chop	//nothing

*** Initial Choppin' Estimates **
local r=26
foreach n in 1 6 12 18{
ivreg2 ppvt3 (N_`n'  P_`n'  = cc_price_relative R)	i.program_type if $chop
matrix A[`r',1]=1
matrix A[`r',2]=1
matrix A[`r',3]=1
matrix A[`r',4]=`n'
matrix A[`r',5]=_b[N_]
matrix A[`r',6]=2*ttail(e(N),abs(_b[N_]/_se[N_]))
matrix A[`r',7]=_b[P_]
matrix A[`r',8]=2*ttail(e(N),abs(_b[P_]/_se[P_]))
matrix A[`r',9]=e(cdf) 
matrix A[`r',10]=3.6
local r=`r'+1
}
matrix list A, format( %9.2g)

ivreg2 ppvt3 (N_1 P_1   = cc_price_relative R)	i.program_type if $chop //CD=0						N=354
ivreg2 ppvt3 (N_6 P_6   = cc_price_relative R)	i.program_type if $chop //CD=1.6 original CD=7/7	N=354
ivreg2 ppvt3 (N_12 P_12 = cc_price_relative R)	i.program_type if $chop //CD=2.9 original CD=10/7	N=354
ivreg2 ppvt3 (N_18 P_18 = cc_price_relative R)	i.program_type if $chop //CD=0 	 original CD=12/7	N=354

* No program type
ivreg2 ppvt3 (D_6 P_6   = cc_price_relative R) if $chop	//CD=2.3/7
ivreg2 ppvt3 (D_12 P_12 = cc_price_relative R) if $chop	//CD=3.8/7
ivreg2 ppvt3 (D_18 P_18 = cc_price_relative R) if $chop	//CD=0.8/7

*** Interactions ***
reg P_1		R R0inter cc_price_relative if $chop	//nothing
reg P_6		R R0inter cc_price_relative if $chop 	//nothing
reg P_12	R R0inter cc_price_relative if $chop 	//nothing
reg P_18	R R0inter cc_price_relative if $chop	//nothing

ivreg2 ppvt3 (N_1 P_1   = cc_price_relative R R0inter)	i.program_type if $chop //CD=0   og chop CD=0
ivreg2 ppvt3 (N_6 P_6   = cc_price_relative R R0inter)	i.program_type if $chop //CD=1.6 og chop CD=1.6 original CD=7/7
ivreg2 ppvt3 (N_12 P_12 = cc_price_relative R R0inter)	i.program_type if $chop //CD=2.4 og chop CD=2.9 original CD=10/7
ivreg2 ppvt3 (N_18 P_18 = cc_price_relative R R0inter)	i.program_type if $chop //CD=0.5 og chop CD=0   original CD=12/7

*** Interactions with Program Type ***
local r=30
foreach n in 1 6 12 18{
ivreg2 ppvt3 (N_`n'  P_`n'  = cc_price_relative R R_inter_type2)	i.program_type if $chop
matrix A[`r',1]=1
matrix A[`r',2]=1
matrix A[`r',3]=1
matrix A[`r',4]=`n'
matrix A[`r',5]=_b[N_]
matrix A[`r',6]=2*ttail(e(N),abs(_b[N_]/_se[N_]))
matrix A[`r',7]=_b[P_]
matrix A[`r',8]=2*ttail(e(N),abs(_b[P_]/_se[P_]))
matrix A[`r',9]=e(cdf) 
matrix A[`r',10]=5.5
local r=`r'+1
}
matrix list A, format( %9.2g)

ivreg2 ppvt3 (N_1  P_1  = cc_price_relative R R_inter_type2) i.program_type if $chop, first //CD=1.4/13 og chop CD=0   b_P=-.47 b_N=-1.4
ivreg2 ppvt3 (N_6  P_6  = cc_price_relative R R_inter_type2) i.program_type if $chop, first //CD=4.0/13 og chop CD=1.6 b_P=-.34 b_N=-1.2 *
ivreg2 ppvt3 (N_12 P_12 = cc_price_relative R R_inter_type2) i.program_type if $chop, first //CD=4.9/13 og chop CD=2.9 b_P=-.29 b_N=-1.3 *
ivreg2 ppvt3 (N_18 P_18 = cc_price_relative R R_inter_type2) i.program_type if $chop, first //CD=3.3/13 og chop CD=0   b_P=-.4  b_N=-1.2

*** ONLY CENTER AND MIXED ***
ivreg2 ppvt3 ( P_18 N_18 = cc_price_relative R ) i.program_type if $chop & program_type!=2, first 	//CD=0.06 BAD
ivreg2 ppvt3 ( P_12 N_12 = cc_price_relative R ) i.program_type if $chop & program_type!=2, first 	//CD=0.9
ivreg2 ppvt3 ( P_6 N_6 = cc_price_relative R ) i.program_type if $chop & program_type!=2, first 	//CD=0.2  BAD
ivreg2 ppvt3 ( P_1 N_1 = cc_price_relative R ) i.program_type if $chop & program_type!=2, first 	//CD=0.11 BAD


**********************
*** Less Chopping? ***
**********************

*** Trying to Justify it ***

gen low_edu=(m_edu_HS==1|medulessHS==1) if (m_edu_HS!=. & medulessHS!=.)
gen D_black=D_12*black
gen D_edu=D_12*low_edu
gen R_inter_low_edu=R*low_edu

local r=34
foreach n in 1 6 12 18{
ivreg2 ppvt3 (N_`n'  P_`n'  = cc_price_relative R)	i.program_type if black==1
matrix A[`r',1]=1
matrix A[`r',2]=1
matrix A[`r',3]=0
matrix A[`r',4]=`n'
matrix A[`r',5]=_b[N_]
matrix A[`r',6]=2*ttail(e(N),abs(_b[N_]/_se[N_]))
matrix A[`r',7]=_b[P_]
matrix A[`r',8]=2*ttail(e(N),abs(_b[P_]/_se[P_]))
matrix A[`r',9]=e(cdf) 
matrix A[`r',10]=3.6
local r=`r'+1
}
matrix list A, format( %9.2g)
																	//CD's:	Chopped 	Original	N	Black CD
ivreg2 ppvt3 (N_1 P_1   = cc_price_relative R)	i.program_type if black==1 	//CD=0					354		0
ivreg2 ppvt3 (N_6 P_6   = cc_price_relative R)	i.program_type if black==1 	//CD=1.6	CD=7/7		354		0.9
ivreg2 ppvt3 (N_12 P_12 = cc_price_relative R)	i.program_type if black==1 	//CD=2.9 	CD=10/7		354		2.3
ivreg2 ppvt3 (N_18 P_18 = cc_price_relative R)	i.program_type if black==1 	//CD=0 	 	CD=12/7		354		0.6

local r=38
foreach n in 1 6 12 18{
ivreg2 ppvt3 (N_`n'  P_`n'  = cc_price_relative R R_inter_type2)	i.program_type if black==1
matrix A[`r',1]=1
matrix A[`r',2]=1
matrix A[`r',3]=0
matrix A[`r',4]=`n'
matrix A[`r',5]=_b[N_]
matrix A[`r',6]=2*ttail(e(N),abs(_b[N_]/_se[N_]))
matrix A[`r',7]=_b[P_]
matrix A[`r',8]=2*ttail(e(N),abs(_b[P_]/_se[P_]))
matrix A[`r',9]=e(cdf) 
matrix A[`r',10]=5.5
local r=`r'+1
}
matrix list A, format( %9.2g)

																					//CD's:	Chopped 	Original	N	Black CD
ivreg2 ppvt3 (N_1 P_1   = cc_price_relative R R_inter_type2)	i.program_type if black==1 	//CD=0					354		1.7
ivreg2 ppvt3 (N_6 P_6   = cc_price_relative R R_inter_type2)	i.program_type if black==1 	//CD=1.6	CD=7/7		354		4.5
ivreg2 ppvt3 (N_12 P_12 = cc_price_relative R R_inter_type2)	i.program_type if black==1 	//CD=2.9 	CD=10/7		354		5.2
ivreg2 ppvt3 (N_18 P_18 = cc_price_relative R R_inter_type2)	i.program_type if black==1 	//CD=0 	 	CD=12/7		354		4.5

ivreg2 ppvt3 (D_12 = R  ) //.31
ivreg2 ppvt3 (D_12 = R) if black==1 //.65
ivreg2 ppvt3 (D_12 = R) if (m_edu_HS==1|medulessHS==1) //.34
ivreg2 ppvt3 (D_12 = R) if (m_edu_HS==1|medulessHS==1) & black==1 //.69

ivreg2 ppvt3 (D_12 D_black = R R_inter_black ) black	i.program_type //t=1.29. Not sure how to justify chopping.
ivreg2 ppvt3 (D_12 D_edu = R R_inter_low_edu ) low_edu 	i.program_type //NO. Not sure how to justify chopping.

ivreg2 ppvt3 (D_12 = R) if black==1 //.65
ivreg2 ppvt3 (D_12 = R) if (m_edu_HS==1|medulessHS==1) //.34
ivreg2 ppvt3 (D_12 = R) if (m_edu_HS==1|medulessHS==1) & black==1 //.69

************
*** HULL ***
************
rename P_* C_*

*1 Not Chopping
*foreach n in 1 6 12 18{
tab cc_price_relative
gen price_h1=cc_price_relative>0.07
tabstat C_12, by(price_h1) //6% difference, not bad

	sum N_12 if R==1 & price_h1==1
	scalar p_nn_EHS_12h = r(mean)
	sum P_12 if R==1 & price_h1==1
	scalar p_cc_EHS_12h = r(mean)
	sum D_12 if R==0 & price_h1==1
	scalar p_hh_EHS_12h = r(mean)
	sum N_12 if R==0 & price_h1==1
	scalar p_nh_EHS_12h = r(mean)-p_nn_EHS_12
	sum P_12 if R==0 & price_h1==1
	scalar p_ch_EHS_12h = r(mean)-p_cc_EHS_12
	scalar w_h_n=p_nh_EHS_12h/(p_nh_EHS_12h+p_ch_EHS_12h)
	scalar w_h_c=p_ch_EHS_12h/(p_nh_EHS_12h+p_ch_EHS_12h)
	
	sum N_12 if R==1 & price_h1==0
	scalar p_nn_EHS_12l = r(mean)
	sum P_12 if R==1 & price_h1==0
	scalar p_cc_EHS_12l = r(mean)
	sum D_12 if R==0 & price_h1==0
	scalar p_hh_EHS_12l = r(mean)
	sum N_12 if R==0 & price_h1==0
	scalar p_nh_EHS_12l = r(mean)-p_nn_EHS_12
	sum C_12 if R==0 & price_h1==0
	scalar p_ch_EHS_12l = r(mean)-p_cc_EHS_12
	scalar w_l_n=p_nh_EHS_12l/(p_nh_EHS_12l+p_ch_EHS_12l)
	scalar w_l_c=p_ch_EHS_12l/(p_nh_EHS_12l+p_ch_EHS_12l)
	
		noi di as text "ABC Sub-Types Using Threshold   " 12
		noi di as text "Estimated Pr[n always-taker]   =" p_nn_EHS_12h p_nn_EHS_12l
		noi di as text "Estimated Pr[h always-taker]   =" p_hh_EHS_12h p_hh_EHS_12l
		noi di as text "Estimated Pr[c always-taker]   =" p_cc_EHS_12h p_cc_EHS_12l
		noi di as text "Estimated Pr[n-to-h complier]  =" p_nh_EHS_12h p_nh_EHS_12l
		noi di as text "Estimated Pr[c-to-h complier]  =" p_ch_EHS_12h p_ch_EHS_12l

ivreg2 ppvt3 (D_12=R) i.program_type if price_h1==1
scalar late_h = _b[D_12] //.27
ivreg2 ppvt3 (D_12=R) i.program_type if price_h1==0
scalar late_l = _b[D_12] //.42

scalar LATE_C=(late_h*w_l_n-late_l*w_h_n)/(w_l_n*w_h_c+w_l_c*w_h_n)
di LATE_C //-.61
scalar LATE_N=(late_h-w_h_c*LATE_C)/w_h_n
di LATE_N //.30
ivreg2 ppvt3 (D_12=R) i.program_type //.35


ivreg2 ppvt3 (N_12 C_12 = cc_price_relative R) i.program_type
scalar iv_b_n=_b[N_12]
scalar iv_b_c=_b[C_12]

ivreg2 ppvt3 (D_12= R) i.program_type
di "Months: `n'" 
di " LATE:" _b[D_12]
di "subLATE IV N: " iv_b_n
di "subLATE IV C: " iv_b_c
di "subLATE Hull N: " LATE_N 
di "subLATE Hull C: " LATE_C
asda
	
	
*2 Chopping Educ and Black
tab cc_price_relative if $chop
gen price_h2=cc_price_relative>0.062
tabstat P_12, by(price_h2) //8% difference, not bad

	sum N_12 if R==1 & $chop
	scalar p_nn_EHS_12 = r(mean)
	sum P_12 if R==1 & $chop
	scalar p_cc_EHS_12 = r(mean)
	sum D_12 if R==0 & $chop
	scalar p_hh_EHS_12 = r(mean)
	sum N_12 if R==0 & $chop
	scalar p_nh_EHS_12 = r(mean)-p_nn_EHS_12
	sum P_12 if R==0 & $chop
	scalar p_ch_EHS_12 = r(mean)-p_cc_EHS_12
	    
		noi di as text "ABC Sub-Types Using Threshold   " 12
		noi di as text "Estimated Pr[n always-taker]   =" p_nn_EHS_12
		noi di as text "Estimated Pr[h always-taker]   =" p_hh_EHS_12
		noi di as text "Estimated Pr[c always-taker]   =" p_cc_EHS_12
		noi di as text "Estimated Pr[n-to-h complier]  =" p_nh_EHS_12
		noi di as text "Estimated Pr[c-to-h complier]  =" p_ch_EHS_12

		
		
		
		
tab cc_price_relative if (black==0 |m_edu_moreHS==1)

gen price_h2=cc_price_relative>0.062
tabstat P_12, by(price_h2) //8% difference, not bad

	sum N_12 if R==1 & (black==0 |m_edu_moreHS==1)
	scalar p_nn_EHS_12 = r(mean)
	sum P_12 if R==1 & (black==0 |m_edu_moreHS==1)
	scalar p_cc_EHS_12 = r(mean)
	sum D_12 if R==0 & (black==0 |m_edu_moreHS==1)
	scalar p_hh_EHS_12 = r(mean)
	sum N_12 if R==0 & (black==0 |m_edu_moreHS==1)
	scalar p_nh_EHS_12 = r(mean)-p_nn_EHS_12
	sum P_12 if R==0 & (black==0 |m_edu_moreHS==1)
	scalar p_ch_EHS_12 = r(mean)-p_cc_EHS_12
	    
		noi di as text "ABC Sub-Types Using Threshold   " 12
		noi di as text "Estimated Pr[n always-taker]   =" p_nn_EHS_12
		noi di as text "Estimated Pr[h always-taker]   =" p_hh_EHS_12
		noi di as text "Estimated Pr[c always-taker]   =" p_cc_EHS_12
		noi di as text "Estimated Pr[n-to-h complier]  =" p_nh_EHS_12
		noi di as text "Estimated Pr[c-to-h complier]  =" p_ch_EHS_12

		
		
		
		
		



sum cc_price_relative
tab price_h
ivreg2 ppvt3 (D_6 =  R) if $chop & price_h==1 //CD=10, N=110 .89
ivreg2 ppvt3 (D_6 =  R) if $chop & price_h==0 //CD=38, N=247 .59
sum P_6 if price_h==1 //.15
sum P_6 if price_h==0 //.19

ivreg2 ppvt3 (D_12 = R) if $chop & price_h==1	//CD=10 .89
ivreg2 ppvt3 (D_12 = R) if $chop & price_h==0	//CD=35 .64

ivreg2 ppvt3 (D_18 P_18 = cc_price_relative R) if $chop	//CD=0.8/7

*** CHoPPED
tab cc_price_relative if ppvt3!=. & $chop
gen price_1=cc_price_relative<0.048
gen price_2=cc_price_relative<0.062 & cc_price_relative>0.048
gen price_3=cc_price_relative<0.077 & cc_price_relative>0.062
gen price_4=cc_price_relative<0.1 & cc_price_relative>0.077
sum price_1-price_4 if ppvt3!=. & $chop
gen price_strata=.
replace price_strata=1 if price_1==1
replace price_strata=2 if price_2==1
replace price_strata=3 if price_3==1
replace price_strata=4 if price_4==1
tabstat P_6, by(price_strata)  //Very Mild
tabstat P_12, by(price_strata) //18%-9%
tabstat P_18, by(price_strata) //12%-4%

tabstat P_6  if ppvt3!=. & $chop, by(price_h)  	//4% difference
tabstat P_12 if ppvt3!=. & $chop, by(price_h) 	//6%
tabstat P_18 if ppvt3!=. & $chop, by(price_h) 	//2%







