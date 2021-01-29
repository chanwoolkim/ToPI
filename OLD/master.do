* ---- * Master Author: Chanwool Kim * ---- *
* ---- * Updated by AH in 2018 * ---- *
* ---- * Updated by AH in 2020 * ---- *
*1:29pm starting


clear all
set more off
*global klmshare 			: env klmshare
global code_path 			"/Users/andres/Dropbox/TOPI/do"
global master_path			"/Users/andres/Dropbox/TOPI"
global main_path			"${master_path}/treatment_effect"
global data_raw		        "${master_path}/Original datasets"
*We need: std-ehs.dta, base-ihdp.dta, append-abccare.dta, merge-ihdp.dta

global data_ehs_harvard		"${main_path}/data/Harvard Dataverse Sensitive Original Data/parent_interview"
global data_working			"${main_path}/working"
global data_analysis		"${main_path}/working/analysis"
global data_out				"${main_path}/out/data_basic"
global analysis_out			"${main_path}/out/analysis_basic"
global pile_out				"${main_path}/out/pile"
global homo_out				"${main_path}/out/homogenisation"
global subpop_out			"${main_path}/out/subpopulation"
global homo_subpop_out		"${main_path}/out/homo_subpop"
global by_site_out			"${main_path}/out/by_site"
global mediation_out		"${main_path}/out/mediation"
global data_git_out			"${code_path}/out/data_basic"
global analysis_git_out		"${code_path}/out/analysis_basic"
global pile_git_out			"${code_path}/out/pile"
global homo_git_out			"${code_path}/out/homogenisation"
global subpop_git_out		"${code_path}/out/subpopulation"
global homo_subpop_git_out	"${code_path}/out/homo_subpop"
global by_site_git_out		"${code_path}/out/by_site"
global mediation_git_out	"${code_path}/out/mediation"

global covariates			m_age m_edu sibling m_iq race sex gestage mf
global programs				ehs ehscenter ehshome ehsmixed ihdp abc care careboth carehome
global program_name			""EHS" "EHS-Center" "EHS-Home" "EHS-Mixed" "IHDP" "ABC" "CARE" "CARE-Both" "CARE-Home""
global programs_merge		ehs ihdp abc care
global measure				outcome home labor parent

global ehs_type				""center" "home" "mixed" """
global ihdp_type			""high" "low" """
global abc_type				""""
global care_type			""both" "home" """

global outcome_types		ppvt sb /*AH modified this*/
global outcome_types2		ppvt sb noncog /*AH modified this*/
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
global sub_axis_range		-0.002(0.0005)0.002
global parent_axis_range	-1.5(0.5)1.5
global by_site_axis_range	-0.1(0.025)0.1

set seed 2018

* -------------- * Data Preparation * -------------- *
cd "${code_path}/data_basic" 	//Creates controls. starts with std-ehs, base-ihdp, append-abccare. Renames.
	include "data_control" 		//Imputes covariates. CARE: treat=random!=0. AH added Homo Poverty.
								//added poverty variables
cd "${code_path}/data_basic"
	include "data_participation"
cd "${code_path}/data_basic"
	include "data_outcome"
cd "${code_path}/data_basic"
	include "data_labor"
cd "${code_path}/data_basic"
	include "data_home_item"	/*AH modified this to include later ages*/
cd "${code_path}/data_basic"
	include "data_home_aggregate"
cd "${code_path}/data_basic"
	include "data_parental_info"
cd "${code_path}/data_basic"
	include "data_noncognitive" /*AH modified this*/
cd "${code_path}/data_basic"
	include "data_video" /*AH modified this*/
cd "${code_path}/data_basic"
	include "data_merge"

* -------- * Pile Data * -------- *
cd "${code_path}/pile"
	include "data_homevideo_aggregate_pile" //uses the -merge data
	// renames vars for pile chart: from mo to yr. Modified to topi.dta.
	*cd "${code_path}/pile"
*	include "data_home_aggregate_pile" //AH added noncog and video factor. From mo to yr.
										//Also included some of the renaming of data_merge_homo
cd "${code_path}/pile"
	//OG: include "data_home_item_pile" //data creation. From mo to yr.
	/*ALT:*/ include "data_home_item_pile" //data creation. From mo to yr.
	//OG: cd "${code_path}/pile"
	//OG:  include "data_parent_pile" //data creation. From mo to yr. Integrated into the agg file above.
	//OG:  cd "${code_path}/pile"
	//OG:  include "data_noncognitive_pile" //data creation

	* -------- * Diagnostic * -------- *
*cd "${code_path}/data_basic"
*	include "data_description"

* ----------- * Main Analysis * ----------- *
/*cd "${code_path}/analysis_basic"
	include "treatment_longitudinal"
cd "${code_path}/analysis_basic"
	include "treatment_table"
cd "${code_path}/analysis_basic"
	include "treatment_list" */

* -------- * Pile * -------- *
cd "${code_path}/pile"				//uses the -topi data
	include "pile_prog_var_method" /*AH: original was treatment_outcome_pile */

asd not using what follows:

cd "${code_path}/pile"
	include "treatment_outcome_pile2" /*AH: original was treatment_outcome_pile */
cd "${code_path}/pile"
	include "treatment_homevideo_aggregate_pile" /*AH created this*/
cd "${code_path}/pile"
	include "treatment_home_aggregate_pile"
cd "${code_path}/pile"
	include "treatment_home_aggregate_substitution_pile"
*cd "${code_path}/pile"
*	include "treatment_home_item_pile2" /* AH: original was treatment_home_item_pile2 */
*cd "${code_path}/pile"
*	include "treatment_parent_item_pile"
cd "${code_path}/pile"
	include "treatment_noncognitive_aggregate_pile"
*cd "${code_path}/pile"
*	include "treatment_noncognitive_item_pile"
cd "${code_path}/pile"
	include "treatment_home_comparison_pile"

* ------------ * Homogenisation * ------------ *
cd "${code_path}/homogenisation" 	//AH: added to data creation
	include "data_homo"				// use data_raw Creates race and poverty variables. Should be in data creation.
cd "${code_path}/homogenisation" 
	include "data_merge_homo"		//Renames HOME variables. Should be in data creation.
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
