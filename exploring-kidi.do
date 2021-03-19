
*---------------------------*
* Exploring Impacts on KIDI *
*---------------------------*
*Covariates and both twins is the only way to attain significance in IHDP


cd "$data_working"
use ehscenter-topi, clear
*KIDI Variables: norm_kidi_total2y norm_kidi_total1y

reg norm_kidi_total2y R if m_ed==1 //.04
reg norm_kidi_total2y R if m_ed==2 //.1
reg norm_kidi_total2y R if m_ed==3 //0

reg norm_kidi_total2y R 					// 	Impact: 0.12. P=0.004.
reg norm_kidi_total2y R $covariates 		// 	Impact: 0.11. P=0.004.
ivreg2 norm_kidi_total2y (D=R) 				//	Impact: 0.11. P=0.021.
ivreg2 norm_kidi_total2y (D=R) $covariates 	//	Impact: 0.10. P=0.025.

reg m_work2 R

reg norm_home_total3y norm_kidi_total2y R hours_worked
reg norm_home_total3y norm_kidi_total2y R m_work1
reg norm_home_total3y norm_kidi_total2y R m_work2

use ihdp-topi, clear
reg kidi_accuracy24 R if m_ed==1 //.0.06
reg kidi_accuracy24 R if m_ed==2 //.0.09
reg kidi_accuracy24 R if m_ed==3 //.14

*KIDI Variables: kidi_attempted24 kidi_accuracy24 kidi_total24 kidi_right24

* NOT DROPPING ANY TWINS *
reg kidi_accuracy24 R						//	Impact: 0.04. 	P=0.45.
reg kidi_accuracy24 R $covariates			//	Impact: 0.11. 	P=0.02.	**
ivreg2 kidi_accuracy24 (D=R)				//	Impact: 0.057.	P=0.47.
ivreg2 kidi_accuracy24 (D=R) $covariates	//	Impact: 0.14.	P=.023	**

reg kidi_total24 R							//	Impact: 0.03. 	P=0.62.
reg kidi_total24 R $covariates				//	Impact: 0.10. 	P=0.039	**
ivreg2 kidi_total24 (D=R)					//	Impact: 0.03.	P=0.64.
ivreg2 kidi_total24 (D=R) $covariates		//	Impact: 0.12.	P=0.038 **

* KEEPING ONLY MAIN TWINS
drop if pag==0  //drops the second twin
reg kidi_accuracy24 R						//	Impact: 0.05. 	P=0.39.
reg kidi_accuracy24 R $covariates			//	Impact: 0.09. 	P=0.06.	*
ivreg2 kidi_accuracy24 (D=R)				//	Impact: 0.07.	P=0.39.
ivreg2 kidi_accuracy24 (D=R) $covariates	//	Impact: 0.12.	P=0.06.	*

reg kidi_total24 R							//	Impact: 0.038. 	P=0.57.
reg kidi_total24 R $covariates				//	Impact: 0.086. 	P=0.1
ivreg2 kidi_total24 (D=R)					//	Impact: 0.048.	P=0.57.
ivreg2 kidi_total24 (D=R) $covariates		//	Impact: 0.1.	P=0.1

* DROPPING ALL TWINS (This is usually done in data13_descriptive_stats)*
drop if missing(pag)
tab twin pag, mi
drop if twin==1

reg kidi_accuracy24 R						//	Impact: 0.07. 	P=0.3.
reg kidi_accuracy24 R $covariates			//	Impact: 0.082. 	P=0.14.
ivreg2 kidi_accuracy24 (D=R)				//	Impact: 0.096.	P=0.29.
ivreg2 kidi_accuracy24 (D=R) $covariates	//	Impact: 0.10.	P=0.15.

reg kidi_total24 R							//	Impact: 0.04. 	P=0.5.
reg kidi_total24 R $covariates				//	Impact: 0.06. 	P=0.23
ivreg2 kidi_total24 (D=R)					//	Impact: 0.06.	P=0.48.
ivreg2 kidi_total24 (D=R) $covariates		//	Impact: 0.08.	P=0.26.

reg norm_home_total3y kidi_total24 R m_work3y
reg m_work3y R


kidi_total24

drop if twin==1
