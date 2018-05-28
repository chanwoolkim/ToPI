* ---- *
* Master
* Author: Chanwool Kim
* ---- *

clear all
set more off
ssc install outreg, replace
adoupdate outreg

global klmshare 			: env klmshare

global code_path 			"C:/Users/chanw/Desktop/ToPI"
global master_path			"C:/Users/chanw/Dropbox (Work)"

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
	include "data - control"
cd "${code_path}/data_basic"
	include "data - participation"
cd "${code_path}/data_basic"
	include "data - outcome"
cd "${code_path}/data_basic"
	include "data - labor"
cd "${code_path}/data_basic"
	include "data - home item"
cd "${code_path}/data_basic"
	include "data - home aggregate"
cd "${code_path}/data_basic"
	include "data - parental info"
cd "${code_path}/data_basic"
	include "data - merge"

* -------- *
* Diagnostic

cd "${code_path}/data_basic"
	include "data - description"

* ----------- *
* Main Analysis

cd "${code_path}/analysis_basic"
	include "treatment - longitudinal"
cd "${code_path}/analysis_basic"
	include "treatment - table"

* -- *
* Pile

cd "${code_path}/pile"
	include "data - aggregate pile"
cd "${code_path}/pile"
	include "data - item pile"
cd "${code_path}/pile"
	include "data - parent pile"
cd "${code_path}/pile"
	include "treatment - outcome pile"
cd "${code_path}/pile"
	include "treatment - aggregate pile"
*cd "${code_path}/pile"
*	include "treatment - aggregate pile (substitution)"
cd "${code_path}/pile"
	include "treatment - item pile"
cd "${code_path}/pile"
	include "treatment - parent item pile"
cd "${code_path}/pile"
	include "treatment - pile (comparison)"
	
* ------------ *
* Homogenisation

cd "${code_path}/homogenisation"
	include "data - homo"
cd "${code_path}/homogenisation"
	include "data - homo (merge)"
cd "${code_path}/homogenisation"
	include "data - homo (table)"
*cd "${code_path}/homogenisation"
*	include "treatment - homogenisation (table)"
cd "${code_path}/homogenisation"
	include "treatment - homogenisation (aggregate)"
cd "${code_path}/homogenisation"
	include "treatment - homogenisation (item)"
*cd "${code_path}/homogenisation"
*	include "treatment - homogenisation (comparison)"
cd "${code_path}/homogenisation"
	include "comparison - aggregate"
	
* ----------- *
* Subpopulation

cd "${code_path}/subpopulation"
	include "data - subpop"
cd "${code_path}/subpopulation"
	include "data - subpop (merge)"
cd "${code_path}/subpopulation"
	include "data - subpop (table)"
cd "${code_path}/subpopulation"
	include "treatment - subpop (aggregate)"
cd "${code_path}/subpopulation"
	include "treatment - subpop (item)"

* ---------------------------- *
* Homogenisation + Subpopulation

cd "${code_path}/homo_subpop"
	include "data - homo_subpop (table)"
cd "${code_path}/homo_subpop"
	include "treatment - homo_subpop (aggregate)"
cd "${code_path}/homo_subpop"
	include "treatment - homo_subpop (item)"

* ------- *
* Mediation

cd "${code_path}/mediation"
	include "treatment - mediation (cognitive home)"
	
* ------------ *
* By-Site (IHDP)

cd "${code_path}/by_site"
	include "treatment - by site (ihdp)"
