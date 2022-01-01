* ---- * Author: Chanwool Kim 	* ---- *
* ---- * Updated by AH in 2018 	* ---- *
* ---- * Updated by AH in 2020 	* ---- *

clear all
set more off
global master_path			"/Users/ckim/Dropbox/Research/TOPI"
global code_path 			"${master_path}/do-ToPI"
global data_raw		        "${master_path}/Original datasets"
global data_working			"${master_path}/working"
global out					"${master_path}/../../Apps/Overleaf/ToPI/Results"
global git_out				"${code_path}/output_backup"

global covariates			m_age m_edu sibling m_iq black sex gestage mf
global programs				ehs ehscenter ehshome ehsmixed ihdp abc care careboth carehome
global program_name			""EHS" "EHS-Center" "EHS-Home" "EHS-Mixed" "IHDP" "ABC" "CARE" "CARE-Both" "CARE-Home""
global programs_merge		ehs ihdp abc care
global measure				outcome home labor parent

global ehs_type				""center" "home" "mixed" """
global ihdp_type			""high" "low" """
global abc_type				""""
global care_type			""both" "home" """

global outcome_types		ppvt sb
global outcome_types2		ppvt sb noncog
global noncog_types			bayley /*cbcl*/
global bayley_types			attention emotion engagement
global cbcl_types			aggressive attention anxious external internal rule somatic social thought withdrawn
global home_types			total learning develop variety hostility warmth
global parent_types			kidi pari pase
global kidi_types			total accuracy attempted right
global pari_types			dpnd scls noaggr isltd supsex maritl nohome rage verb egal comrde auth hostl demo
global pase_types			auth cnfv cntr do dtch indp obey pos prog sdv socv talk educ
global homevideo_types		total video /*AH modified this*/

global outcome_axis_range	-15(5)15
global outcome_axis_range2	-1(0.2)1
global agg_axis_range		-0.5(0.25)0.5
global item_axis_range		-0.5(0.25)0.5
global parent_axis_range	-1.5(0.5)1.5

set seed 2018

*[UNMUTE THIS IF YOU DONT HAVE THE PROGRAM]
*cd $code_path
*ssc install estout, replace
*ssc install ivreg2, replace
*ssc install ranktest, replace
*net install github, from("https://haghish.github.io/github/")
*github install haghish/rcall, stable

* -------------- * Data Preparation * -------------- *
cd "${code_path}/data_basic" 	//Creates controls. starts with std-ehs, base-ihdp, append-abccare. Renames.
	include "data1_control" 		//Imputes covariates. CARE: treat=random!=0. AH added Homo Poverty.
cd "${code_path}/data_basic"
	include "data2_participation"
cd "${code_path}/data_basic"
	include "data3_outcome"
cd "${code_path}/data_basic"
	include "data4_labor"
cd "${code_path}/data_basic"
	include "data5_home_item"	/*AH modified this to include later ages*/	
cd "${code_path}/data_basic"
	include "data6_home_aggregate"
cd "${code_path}/data_basic"
	include "data7_parental_info"
cd "${code_path}/data_basic"
	include "data8_noncognitive" /*AH modified this*/
cd "${code_path}/data_basic"
	include "data9_video" /*AH modified this*/
cd "${code_path}/data_basic"
	include "data10_merge"
cd "${code_path}/data_basic"
	include "data11_rename_standardize" //uses the -merge data
cd "${code_path}/data_basic"
	include "data12_rename_items" //data creation. From mo to yr.
	
*cd "${code_path}/data_basic"
*	include "data13_descriptive_stats" //Creates HS and Educ Weights CHANGE
cd "${code_path}/data_basic"
	include "data14_OtherPreschools"
cd "${code_path}/data_basic"
	include "data15_instruments3"
cd "${code_path}/data_basic"
	include "data16_keep" //Creates HS and Educ Weights CHANGE
*cd "${code_path}/data_basic"
*	include "data16_exploring_participation" //Creates HS and Educ Weights CHANGE

*cd "${code_path}/data_basic"
*	include "exploring_home" //Creates HS and Educ Weights CHANGE


*AH May 18 2021 working on this:	
cd "${code_path}/analysis"			
	include "pile_cog_prog_method"

cd "${code_path}/analysis"
	include "forChanwool"
	
cd "${code_path}/analysis"
*	include "IV_Chopped"
