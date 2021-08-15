* ---- * Author: Chanwool Kim 	* ---- *
* ---- * Updated by AH in 2018 	* ---- *
* ---- * Updated by AH in 2020 	* ---- *

clear all
set more off
global master_path			"/Users/andres/Dropbox/TOPI"
global code_path 			"${master_path}/do-ToPI"
global data_raw		        "${master_path}/Original datasets"
global data_working			"${master_path}/working"
global out					"${master_path}/../Apps/Overleaf/ToPI/Results"
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
cd "${code_path}/pile"			
	include "pile_cog_prog_method"
	
asd	
	
	
	cd "${code_path}/pile"			
	include "pile_homevariants_prog_method"
	
* -------- * Charts * -------- *
cd "${code_path}/pile"			
	include "pile_prog_CI_chop"
cd "${code_path}/pile"
	include "pile_prog_chop_educ"
cd "${code_path}/pile"
	include "pile_prog_chop_poor"
cd "${code_path}/pile"
	include "pile_prog_educ"
cd "${code_path}/pile"
	include "pile_prog_poor"

asd



cd "${code_path}/pile"				//uses the -topi data
	include "pile_prog_var_method" /*AH: original was treatment_outcome_pile */		
cd "${code_path}/pile"
	include "pile_prog_var_educ"
cd "${code_path}/pile"
	include "treatment_outcome_pile2" /*AH: original was treatment_outcome_pile */
cd "${code_path}/pile"
	include "treatment_homevideo_aggregate_pile" /*AH created this*/
cd "${code_path}/pile"
	include "treatment_home_aggregate_pile"	

*AH JAN cd "${code_path}/pile"
*AH JAN 	include "treatment_home_aggregate_substitution_pile" 
	
	*cd "${code_path}/pile"
*	include "treatment_home_item_pile2" /* AH: original was treatment_home_item_pile2 */
*cd "${code_path}/pile"
*	include "treatment_parent_item_pile"
*AH JAN cd "${code_path}/pile"
*AH JAN 	include "treatment_noncognitive_aggregate_pile"
*cd "${code_path}/pile"
*	include "treatment_noncognitive_item_pile"
*AH JAN cd "${code_path}/pile"
*AH JAN 	include "treatment_home_comparison_pile"

* ------------ * Homogenisation * ------------ *
*cd "${code_path}/homogenisation" 	//AH: added to data creation
*	include "data_homo"				// use data_raw Creates race and poverty variables. Should be in data creation.
*cd "${code_path}/homogenisation" 
*	include "data_merge_homo"		//Renames HOME variables. Should be in data creation.
*cd "${code_path}/homogenisation" 
*	include "data_table_homo"		//count by cells
*cd "${code_path}/homogenisation"
*	include "treatment_table_homo"	//creates weights
*cd "${code_path}/homogenisation"
*	include "treatment_home_aggregate_homo" 
*cd "${code_path}/homogenisation"
*	include "treatment_home_item_homo"
*cd "${code_path}/homogenisation"
*	include "treatment_home_comparison_homo"
*cd "${code_path}/homogenisation"
*	include "home_comparison_aggregate"

* ----------- * Subpopulation * ----------- *
/*
cd "${code_path}/subpopulation"
	include "data_subpop"	//this simply creates a commonnly coded race variable. Include it in data preparation codes!
cd "${code_path}/subpopulation"
	include "data_table_subpop" //this prepares a table of # of blacks, whites, poor, nonpoor
cd "${code_path}/subpopulation"
	include "treatment_home_aggregate_subpop" //chats w effects on HOME subscales by poverty/race
cd "${code_path}/subpopulation"
	include "treatment_homevideo_aggregate_subpop" //charts w scales on HOME + Video by poverty/race
cd "${code_path}/subpopulation"
	include "treatment_home_item_subpop"
cd "${code_path}/subpopulation"
	include "treatment_home_aggregate_vulnerable_subpop"
cd "${code_path}/subpopulation"
	include "treatment_outcome_vulnerable_subpop"
*/

/* Homogenisation + Subpopulation
cd "${code_path}/homo_subpop"
	include "data_table_homo_subpop"
cd "${code_path}/homo_subpop"
	include "treatment_home_aggregate_homo_subpop"
cd "${code_path}/homo_subpop"
	include "treatment_home_item_homo_subpop" */

* ------- * Mediation * ------- *
cd "${code_path}/mediation"
	include "imputations" /* AH: Factors and Averages */
cd "${code_path}/mediation"
	include "treatment_home_outcome_mediation3" // Uses Month notation
*cd "${code_path}/mediation"
*	include "treatment_home_outcome_interaction" AH: This is for the subscales
	
* ------------ * By-Site (IHDP) * ------------ *
*cd "${code_path}/by_site"
*	include "treatment_ihdp_by_site"
