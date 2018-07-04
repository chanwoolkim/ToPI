* ---- *
* Master
* Author: Chanwool Kim
* ---- *

clear all
set more off
ssc install outreg, replace
adoupdate outreg

global klmshare 			: env klmshare

global code_path 			"/Users/ckim/Desktop/ToPI"
global master_path			"/Users/ckim/Dropbox (Work)"

global main_path			"${master_path}/TOPI/treatment_effect"

global data_raw				"${master_path}/Data/std"
global data_ehs_harvard		"${master_path}/Data/Harvard Dataverse Sensitive Original Data/parent_interview"
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

global outcome_types		ppvt sb
global noncog_types			bayley /*cbcl*/
global bayley_types			attention emotion engagement
global cbcl_types			aggressive attention anxious external internal rule somatic social thought withdrawn
global home_types			total learning develop variety hostility warmth
global parent_types			kidi pari pase
global kidi_types			total accuracy attempted right
global pari_types			dpnd scls noaggr isltd supsex maritl nohome rage verb egal comrde auth hostl demo
global pase_types			auth cnfv cntr do dtch indp obey pos prog sdv socv talk educ

global outcome_axis_range	-15(5)15
global agg_axis_range		-0.5(0.25)0.5
global item_axis_range		-0.5(0.25)0.5
global sub_axis_range		-0.002(0.0005)0.002
global parent_axis_range	-1.5(0.5)1.5
global by_site_axis_range	-0.1(0.025)0.1

set seed 2018

* -------------- *
* Data Preperation

cd "${code_path}/data_basic"
	include "data_control"
cd "${code_path}/data_basic"
	include "data_participation"
cd "${code_path}/data_basic"
	include "data_outcome"
cd "${code_path}/data_basic"
	include "data_labor"
cd "${code_path}/data_basic"
	include "data_home_item"
cd "${code_path}/data_basic"
	include "data_home_aggregate"
cd "${code_path}/data_basic"
	include "data_parental_info"
cd "${code_path}/data_basic"
	include "data_noncognitive"
cd "${code_path}/data_basic"
	include "data_merge"

* -------- *
* Diagnostic

cd "${code_path}/data_basic"
	include "data_description"

* ----------- *
* Main Analysis

cd "${code_path}/analysis_basic"
	include "treatment_longitudinal"
cd "${code_path}/analysis_basic"
	include "treatment_table"

* -- *
* Pile

cd "${code_path}/pile"
	include "data_home_aggregate_pile"
cd "${code_path}/pile"
	include "data_home_item_pile"
cd "${code_path}/pile"
	include "data_parent_pile"
cd "${code_path}/pile"
	include "data_noncognitive_pile"
cd "${code_path}/pile"
	include "treatment_outcome_pile"
cd "${code_path}/pile"
	include "treatment_home_aggregate_pile"
cd "${code_path}/pile"
	include "treatment_home_aggregate_substitution_pile"
cd "${code_path}/pile"
	include "treatment_home_item_pile"
cd "${code_path}/pile"
	include "treatment_parent_item_pile"
cd "${code_path}/pile"
	include "treatment_noncognitive_aggregate_pile"
cd "${code_path}/pile"
	include "treatment_noncognitive_item_pile"
cd "${code_path}/pile"
	include "treatment_home_comparison_pile"

* ------------ *
* Homogenisation

cd "${code_path}/homogenisation"
	include "data_homo"
cd "${code_path}/homogenisation"
	include "data_merge_homo"
cd "${code_path}/homogenisation"
	include "data_table_homo"
cd "${code_path}/homogenisation"
	include "treatment_table_homo"
cd "${code_path}/homogenisation"
	include "treatment_home_aggregate_homo"
cd "${code_path}/homogenisation"
	include "treatment_home_item_homo"
cd "${code_path}/homogenisation"
	include "treatment_home_comparison_homo"
cd "${code_path}/homogenisation"
	include "home_comparison_aggregate"

* ----------- *
* Subpopulation

cd "${code_path}/subpopulation"
	include "data_subpop"
cd "${code_path}/subpopulation"
	include "data_table_subpop"
cd "${code_path}/subpopulation"
	include "treatment_home_aggregate_subpop"
cd "${code_path}/subpopulation"
	include "treatment_home_item_subpop"
cd "${code_path}/subpopulation"
	include "treatment_home_aggregate_vulnerable_subpop"
cd "${code_path}/subpopulation"
	include "treatment_outcome_vulnerable_subpop"

* ---------------------------- *
* Homogenisation + Subpopulation

cd "${code_path}/homo_subpop"
	include "data_table_homo_subpop"
cd "${code_path}/homo_subpop"
	include "treatment_home_aggregate_homo_subpop"
cd "${code_path}/homo_subpop"
	include "treatment_home_item_homo_subpop"

* ------- *
* Mediation

cd "${code_path}/mediation"
	include "treatment_home_outcome_mediation"
cd "${code_path}/mediation"
	include "treatment_home_outcome_interaction"
	
* ------------ *
* By-Site (IHDP)

cd "${code_path}/by_site"
	include "treatment_ihdp_by_site"
