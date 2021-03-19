*-----------------------------------------*
* Exploring HOME Construction and Impacts *
*-----------------------------------------*

*ABC:


cd "$data_working"

use "ehs-topi.dta", clear
rename home3y_original home3y_original_
egen home3y_original=std(home3y_original_)

reg norm_home_learning3y 	R	//our learning scale
reg norm_home_total3y		R	//total score for our own version

reg home3y_original 		R	//total using all items
save, replace

use "ihdp-topi.dta", clear
sum home3y_original home_jbg_learning
rename home3y_original  home3y_original_
rename home_jbg_learning home_jbg_learning_
egen home3y_original  =std(home3y_original_)
egen home_jbg_learning =std(home_jbg_learning_)

reg norm_home_learning3y 	R	//our learning scale
reg norm_home_total3y		R	//total score for our own version

reg home3y_original 		R	//total using all items

reg home_jbg_learning		R	//JBG's (and Sojourner's?) scale
save, replace

use "abc-topi.dta", clear
rename home3y6m_original  home3y_original_
rename home_jbg_learning home_jbg_learning_
egen home3y_original  =std(home3y_original_)
egen home_jbg_learning =std(home_jbg_learning_)

reg norm_home_learning3y 	R	//our learning scale
reg norm_home_total3y		R	//total score for our own version

reg home3y_original 		R	//total using all items

reg home_jbg_learning		R	//JBG's (and Sojourner's?) scale
save, replace
