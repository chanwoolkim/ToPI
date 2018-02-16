* ---- *
* Master
* Author: Chanwool Kim
* Date Created: 2 Nov 2017
* Last Update: 15 Feb 2018
* ---- *

clear all
set more off
ssc install outreg, replace
adoupdate outreg
ssc install hotdeck, replace
adoupdate hotdeck

global klmshare 			: env klmshare

global master_path			"/Users/ckim/Dropbox (Work)"

global main_path			"${master_path}/TOPI/treatment_effect"
global raw_path				"${master_path}/Data/std"
global code 				"/Users/ckim/Desktop/ToPI"

global data_ehs				"$raw_path"
global data_ehs_h			"${master_path}/Data/Harvard Dataverse Sensitive Original Data/parent_interview"
global data_ihdp 			"$raw_path"
global data_abc				"$raw_path"

global data_home			"${main_path}/data/home"
global data_labor			"${main_path}/data/labor"
global data_parent			"${main_path}/data/parental"

global data_out				"${main_path}/out/data_basic"
global analysis_out			"${main_path}/out/analysis_basic"
global pile_out				"${main_path}/out/pile"
global homo_out				"${main_path}/out/homogenisation"
global subpop_out			"${main_path}/out/subpopulation"
global homo_subpop_out		"${main_path}/out/homo_subpop"
global by_site_out			"${main_path}/out/by_site"
global mediation_out		"${main_path}/out/mediation"

global pile_working			"${main_path}/working/pile"
global homo_working			"${main_path}/working/homogenisation"
global subpop_working		"${main_path}/working/subpopulation"
global homo_subpop_working	"${main_path}/working/homo_subpop"
global by_site_working		"${main_path}/working/by_site"
global mediation_working	"${main_path}/working/mediation"

global covariates			m_age m_edu sibling m_iq race sex gestage mf
global programs				ehscenter ehshome ehsmixed ihdplow ihdphigh abc carehv careboth
global program_name			""EHS-Center" "EHS-Home" "EHS-Mixed" "IHDP-Low" "IHDP-High" "ABC" "CARE-Home" "CARE-Both""
global programs_merge		ehs ihdp abc care
global programs_all			ehscenter ehshome ehsmixed ehs ihdphigh ihdplow ihdp abc careboth carehv care
global program_name_all		""EHS-Center" "EHS-Home" "EHS-Mixed" "EHS-All" "IHDP-High" "IHDP-Low" "IHDP-All" "ABC" "CARE-Both" "CARE-Home" "CARE-All"
global measure				home labor parent

global ehs_type				""center" "home" "mixed" """
global ihdp_type			""high" "low" """
global abc_type				""""
global care_type			""both" "hv" """

global early_home_types		total warmth verbal hostility learning activity develop
global later_home_types		total learning reading verbal warmth exterior interior activity hostility
global parent_types			kidi pari pase
global kidi_types			total accuracy attempted right
global pari_types			dpnd scls noaggr isltd supsex maritl nohome rage verb egal comrde auth hostl demo
global pase_types			auth cnfv cntr do dtch indp obey pos prog sdv socv talk educ

global agg_axis_range		-1.5(0.5)1.5
global item_axis_range		-1(0.25)1
global sub_axis_range		-0.002(0.0005)0.002
global parent_axis_range	-1.5(0.5)1.5
global by_site_axis_range	-0.1(0.025)0.1

* -------------- *
* Data Preperation

cd "${code}/data_basic"
	include "data - control"
cd "${code}/data_basic"
	include "data - participation"
cd "${code}/data_basic"
	include "data - labor"
cd "${code}/data_basic"
	include "data - home item"
cd "${code}/data_basic"
	include "data - home aggregate"
cd "${code}/data_basic"
	include "data - parental info"
cd "${code}/data_basic"
	include "data - merge"

* -------- *
* Diagnostic

/*
cd "${code}/data_basic"
	include "patch - abccheck" //Check ABC scales
*/
cd "${code}/data_basic"
	include "data - description"

* ----------- *
* Main Analysis

cd "${code}/analysis_basic"
	include "treatment - longitudinal"
cd "${code}/analysis_basic"
	include "treatment - table"
	
* -- *
* Pile

cd "${code}/pile"
	include "data - aggregate pile"
cd "${code}/pile"
	include "data - item pile"
cd "${code}/pile"
	include "data - parent pile"
cd "${code}/pile"
	include "treatment - aggregate pile"
cd "${code}/pile"
	include "treatment - aggregate pile (substitution)"
cd "${code}/pile"
	include "treatment - item pile"
cd "${code}/pile"
	include "treatment - parent pile"
cd "${code}/pile"
	include "treatment - parent item pile"
cd "${code}/pile"
	include "treatment - pile (comparison)"
	
* ------------ *
* Homogenisation

cd "${code}/homogenisation"
	include "data - homo"
cd "${code}/homogenisation"
	include "data - homo (merge)"
cd "${code}/homogenisation"
	include "data - homo (table)"
cd "${code}/homogenisation"
	include "treatment - homogenisation (table)"
cd "${code}/homogenisation"
	include "treatment - homogenisation (aggregate)"
cd "${code}/homogenisation"
	include "treatment - homogenisation (item)"
cd "${code}/homogenisation"
	include "treatment - homogenisation (comparison)"
cd "${code}/homogenisation"
	include "comparison - aggregate"
	
* ----------- *
* Subpopulation

cd "${code}/subpopulation"
	include "data - subpop"
cd "${code}/subpopulation"
	include "data - subpop (merge)"
cd "${code}/subpopulation"
	include "data - subpop (table)"
cd "${code}/subpopulation"
	include "treatment - subpop (aggregate)"
cd "${code}/subpopulation"
	include "treatment - subpop (item)"

* ---------------------------- *
* Homogenisation + Subpopulation

cd "${code}/homo_subpop"
	include "data - homo_subpop (table)"
cd "${code}/homo_subpop"
	include "treatment - homo_subpop (aggregate)"
cd "${code}/homo_subpop"
	include "treatment - homo_subpop (item)"

* ------- *
* Mediation

cd "${code}/mediation"
	include "treatment - mediation (cognitive home)"
	
* ------------ *
* By-Site (IHDP)

cd "${code}/by_site"
	include "treatment - by site (ihdp)"
