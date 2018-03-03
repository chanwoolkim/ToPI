* -------------------------------------------- *
* Graphs of treatment effects - parent item pile
* Author: Chanwool Kim
* Date Created: 3 Feb 2018
* Last Update: 3 Mar 2018
* -------------------------------------------- *

clear all

* ------------ *
* Prepare matrix

* IHDP - KIDI
local 1_row = 26
local 2_row = 21

foreach t of global ihdp_type {
	foreach age of numlist 1 2 {

	cd "$pile_working"
	use "ihdp`t'-parent-pile.dta", clear

	* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
	qui matrix ihdp`t'R_`age' = J(``age'_row', 5, .) // for randomisation variable

	qui matrix colnames ihdp`t'R_`age' = ihdp`t'R_`age'num ihdp`t'R_`age'coeff ihdp`t'R_`age'lower ihdp`t'R_`age'upper ihdp`t'R_`age'pval

	local row_`age' = 1

	* Loop over rows to fill in values into the empty matrix.

		forvalues r = 1/``age'_row' {
			qui matrix ihdp`t'R_`age'[`row_`age'',1] = `row_`age''
			
			capture confirm variable kidi`age'y_`r'
				if !_rc {
				* Randomisation variable
				qui regress kidi`age'y_`r' R $covariates if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix ihdp`t'R_`age'[`row_`age'',2] = r[1,1]
				qui matrix ihdp`t'R_`age'[`row_`age'',3] = r[5,1]
				qui matrix ihdp`t'R_`age'[`row_`age'',4] = r[6,1]
				qui matrix ihdp`t'R_`age'[`row_`age'',5] = r[4,1]
					
				local row_`age' = `row_`age'' + 1
				}
				
				else {
				local row_`age' = `row_`age'' + 1
				}
		}

		svmat ihdp`t'R_`age', names(col)
		rename ihdp`t'R_`age'num row_`age'
		keep row_`age' ihdp`t'R_`age'coeff ihdp`t'R_`age'lower ihdp`t'R_`age'upper ihdp`t'R_`age'pval
		keep if row_`age' != .
		save "ihdp`t'-pile-kidi-`age'", replace
	}
}

cd "$pile_working"

* Randomisation

use ihdp-pile-kidi-1, clear

foreach t of global ihdp_type {
	merge 1:1 row_1 using ihdp`t'-pile-kidi-1, nogen nolabel
}

rename row_1 row
save ihdp-kidi-pile-1, replace

use ihdp-pile-kidi-2, clear

foreach t of global ihdp_type {
	merge 1:1 row_2 using ihdp`t'-pile-kidi-2, nogen nolabel
}

rename row_2 row
save ihdp-kidi-pile-2, replace

* IHDP - Sameroff
local 1_row = 20
local 3_row = 20

foreach t of global ihdp_type {
	foreach age of numlist 1 3 {

	cd "$pile_working"
	use "ihdp`t'-parent-pile.dta", clear

	* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
	qui matrix ihdp`t'R_`age' = J(``age'_row', 5, .) // for randomisation variable

	qui matrix colnames ihdp`t'R_`age' = ihdp`t'R_`age'num ihdp`t'R_`age'coeff ihdp`t'R_`age'lower ihdp`t'R_`age'upper ihdp`t'R_`age'pval

	local row_`age' = 1

	* Loop over rows to fill in values into the empty matrix.

		forvalues r = 1/``age'_row' {
			qui matrix ihdp`t'R_`age'[`row_`age'',1] = `row_`age''
			
			capture confirm variable norm_sameroff`age'y_`r'
				if !_rc {
				* Randomisation variable
				qui regress norm_sameroff`age'y_`r' R $covariates if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)

				qui matrix ihdp`t'R_`age'[`row_`age'',2] = r[1,1]
				qui matrix ihdp`t'R_`age'[`row_`age'',3] = r[5,1]
				qui matrix ihdp`t'R_`age'[`row_`age'',4] = r[6,1]
				qui matrix ihdp`t'R_`age'[`row_`age'',5] = r[4,1]
					
				local row_`age' = `row_`age'' + 1
				}
				
				else {
				local row_`age' = `row_`age'' + 1
				}
		}

		svmat ihdp`t'R_`age', names(col)
		rename ihdp`t'R_`age'num row_`age'
		keep row_`age' ihdp`t'R_`age'coeff ihdp`t'R_`age'lower ihdp`t'R_`age'upper ihdp`t'R_`age'pval
		keep if row_`age' != .
		save "ihdp`t'-pile-sameroff-`age'", replace
	}
}

cd "$pile_working"

* Randomisation

use ihdp-pile-sameroff-1, clear

foreach t of global ihdp_type {
	merge 1:1 row_1 using ihdp`t'-pile-sameroff-1, nogen nolabel
}

rename row_1 row
save ihdp-sameroff-pile-1, replace

use ihdp-pile-sameroff-3, clear

foreach t of global ihdp_type {
	merge 1:1 row_3 using ihdp`t'-pile-sameroff-3, nogen nolabel
}

rename row_3 row
save ihdp-sameroff-pile-3, replace

* ABC/CARE - PARI
local 1_row = 55
local 2_row = 55

foreach p in abc {
	foreach age of numlist 1 2 {

	cd "$pile_working"
	use "`p'-parent-pile.dta", clear

	* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
	qui matrix `p'R_`age' = J(``age'_row', 5, .) // for randomisation variable

	qui matrix colnames `p'R_`age' = `p'R_`age'num `p'R_`age'coeff `p'R_`age'lower `p'R_`age'upper `p'R_`age'pval

	local row_`age' = 1

	* Loop over rows to fill in values into the empty matrix.

		forvalues r = 1/``age'_row' {
			qui matrix `p'R_`age'[`row_`age'',1] = `row_`age''
				
			capture confirm variable norm_pari`age'y_`r'
				if !_rc {
				* Randomisation variable
				qui regress norm_pari`age'y_`r' R $covariates if !missing(D)
				* r(table) stores values from regression (ex. coeff, var, CI).
				qui matrix list r(table)
				qui matrix r = r(table)
				
				qui matrix `p'R_`age'[`row_`age'',2] = r[1,1]
				qui matrix `p'R_`age'[`row_`age'',3] = r[5,1]
				qui matrix `p'R_`age'[`row_`age'',4] = r[6,1]
				qui matrix `p'R_`age'[`row_`age'',5] = r[4,1]					
				
				local row_`age' = `row_`age'' + 1
				}
					
				else {
				local row_`age' = `row_`age'' + 1
				}
		}

		svmat `p'R_`age', names(col)
		rename `p'R_`age'num row_`age'
		keep row_`age' `p'R_`age'coeff `p'R_`age'lower `p'R_`age'upper `p'R_`age'pval
		keep if row_`age' != .
		save "`p'-pile-pari-`age'", replace
	}
}

cd "$pile_working"

* Randomisation

use abc-pile-pari-1, clear

rename row_1 row
save abc-pari-pile-1, replace

use abc-pile-pari-2, clear

rename row_2 row
save abc-pari-pile-2, replace

* --------*
* Questions

cd "$pile_working"

use ihdp-kidi-pile-1, clear

tostring row, gen(scale_num)

replace scale = "KIDI: babies with colic can cry for 20, 30 minutes, no matter what is done" if scale_num == "1"
replace scale = "KIDI: if baby is fed evaporated milk, baby needs extra vitamins/iron" if scale_num == "2"
replace scale = "KIDI: all infants need the same amount of sleep" if scale_num == "3"
replace scale = "KIDI: taking careof baby can leave parent tired, frustrated, overwhelmed" if scale_num == "4"
replace scale = "KIDI: one year old knows right from wrong" if scale_num == "5"
replace scale = "KIDI: infants stop paying atttention to surroundings if too much going on" if scale_num == "6"
replace scale = "KIDI: some normal babies do not enjoy being cuddled" if scale_num == "7"
replace scale = "KIDI: comforting/holding crying baby is spoiling the baby" if scale_num == "8"
replace scale = "KIDI: frequent cause of accidents is chidl pulling somevthing on self" if scale_num == "9"
replace scale = "KIDI: good way to teach child not to hit is to hit back" if scale_num == "10"
replace scale = "KIDI: 6mo baby responds differently to people depending on person's mood" if scale_num == "11"
replace scale = "KIDI: Infants are usually walking by 12mo" if scale_num == "12"
replace scale = "KIDI: most infants are ready to be toilet trained by 1yo" if scale_num == "13"
replace scale = "KIDI: an infant will begin to respond to his her name at 10mo" if scale_num == "14"
replace scale = "KIDI: 5mo know what 'no' means" if scale_num == "15"
replace scale = "KIDI: 1yo children will cooperate and share when they play together" if scale_num == "16"
replace scale = "KIDI: baby is 7mo before he/she can reach for and grab vthings" if scale_num == "17"
replace scale = "KIDI: babies usually say first word at 6mo." if scale_num == "18"
replace scale = "KIDI: 1yo playing with breakable things: keep him or her in a playpen" if scale_num == "19"
replace scale = "KIDI: 1yo playing with breakable things: slap the baby's hand" if scale_num == "20"
replace scale = "KIDI: 1yo playing with breakable things: tell the child No! and expect him to obey" if scale_num == "21"
replace scale = "KIDI: 1yo playing with breakable things: put things out of reach until child is older" if scale_num == "22"
replace scale = "KIDI: most appropriate game for 1yo: stringing small beads" if scale_num == "23"
replace scale = "KIDI: most appropriate game for 1yo: cutting out shapes with scissors" if scale_num == "24"
replace scale = "KIDI: most appropriate game for 1yo: rolling a ball back and forth with an adult" if scale_num == "25"
replace scale = "KIDI: most appropriate game for 1yo: sorting things by shape and color" if scale_num == "26"

save ihdp-kidi-pile-1, replace

use ihdp-kidi-pile-2, clear

tostring row, gen(scale_num)

replace scale = "KIDI: way infant is brought up will have little effect on intelligence" if scale_num == "1"
replace scale = "KIDI: baby can leave the parent feeling tired, frustrated, overwhelmed" if scale_num == "2"
replace scale = "KIDI: younger sibling may start wetting bed/sucking thumb when new baby arrives" if scale_num == "3"
replace scale = "KIDI: two year old's sense of time is different from an adults" if scale_num == "4"
replace scale = "KIDI: The baby's personality is set by 6mo" if scale_num == "5"
replace scale = "KIDI: Child  uses rules of speech even if saying vthings incorrectly" if scale_num == "6"
replace scale = "KIDI: Child learns all language through copying what they hear people say" if scale_num == "7"
replace scale = "KIDI: frequent cause of accidents for 1yo is pulling vthings down onto themselves" if scale_num == "8"
replace scale = "KIDI: good way to teach child not to hit is to hit back" if scale_num == "9"
replace scale = "KIDI: Most 2yo can tell fiction on TV from truth" if scale_num == "10"
replace scale = "KIDI: Infants are usually walking by 12mo" if scale_num == "11"
replace scale = "KIDI: 2yo can reason logically, much as an adult would" if scale_num == "12"
replace scale = "KIDI: 1yo knows right from wrong" if scale_num == "13"
replace scale = "KIDI: most infants are ready to be toilet trained by 1yo" if scale_num == "14"
replace scale = "KIDI: 1yo children will cooperate and share when they play together" if scale_num == "15"
replace scale = "KIDI: infants of 12mo can remember toys they have watched being hidden" if scale_num == "16"
replace scale = "KIDI: babies usually say first word at 6mo." if scale_num == "17"
replace scale = "KIDI: best way to avoid future trantrums by 2yo?: give the child a different toy" if scale_num == "18"
replace scale = "KIDI: best way to avoid future trantrums by 2yo?: ignore the temper tantrum" if scale_num == "19"
replace scale = "KIDI: best way to avoid future trantrums by 2yo?: spank the child's bottom" if scale_num == "20"
replace scale = "KIDI: best way to avoid future trantrums by 2yo?: let the child have his own way" if scale_num == "21"

save ihdp-kidi-pile-2, replace

foreach age of numlist 1 3 {
	use ihdp-sameroff-pile-`age', clear
	
	tostring row, gen(scale_num)
	
	replace scale = "Sameroff: Children have to be treated differently as they grow older" if scale_num == "1"
	replace scale = "Sameroff: Parents must keep to their standards and rules no matter what their child is like" if scale_num == "2"
	replace scale = "Sameroff: It is not easy to define a good home because a good home is made up of many different things" if scale_num == "3"
	replace scale = "Sameroff: Fathers cannot raise their children as well as mothers" if scale_num == "4"
	replace scale = "Sameroff: The mischief that 2-year-olds get into is part of a passing stage they'll grow out of" if scale_num == "5"
	replace scale = "Sameroff: A child who isn't toilet trained by 3 years of age must have something wrong with him " if scale_num == "6"
	replace scale = "Sameroff: Parents need to be sensitive to the needs of their children" if scale_num == "7"
	replace scale = "Sameroff: Girls tend to be easier babies to take care of than are boys" if scale_num == "8"
	replace scale = "Sameroff: Difficult babies will grow out of it" if scale_num == "9"
	replace scale = "Sameroff: There's not much anyone can do to help emotionally disturbed children" if scale_num == "10"
	replace scale = "Sameroff: Children's problems seldom have a single cause" if scale_num == "11"
	replace scale = "Sameroff: Father's role is to provide discipline mother's role is to give love and attention to the children" if scale_num == "12"
	replace scale = "Sameroff: Parents can be turned off by a fussy child so that they are unable to be as nice as they would like" if scale_num == "13"
	replace scale = "Sameroff: A child's success at school depends on how much his mother taught him at home" if scale_num == "14"
	replace scale = "Sameroff: There is no one right way to raise children" if scale_num == "15"
	replace scale = "Sameroff: Boy babies are less affectionate than girl babies" if scale_num == "16"
	replace scale = "Sameroff: Firstborn children are usually treated differently than are later-born children" if scale_num == "17"
	replace scale = "Sameroff: An easy baby will grow up to be a good child" if scale_num == "18"
	replace scale = "Sameroff: Parents change in response to their children" if scale_num == "19"
	replace scale = "Sameroff: Babies have to be taught to behave themselves or they will be bad later on" if scale_num == "20"

	save ihdp-sameroff-pile-`age', replace
}

foreach age of numlist 1 2 {
	use abc-pari-pile-`age', clear

	tostring row, gen(scale_num)

	replace scale = "PARI: A good mother should shelter her child from life's little difficulties" if scale_num == "1"
	replace scale = "PARI: Children should be taught about sex as soon as possible" if scale_num == "2"
	replace scale = "PARI: People who vthink they can get along in marriage without arguments just don't know the facts" if scale_num == "3"
	replace scale = "PARI: Parents should not have to earn the respect of their children by the way they act" if scale_num == "4"
	replace scale = "PARI: The women who want lots of parties seldom make good mothers" if scale_num == "5"
	replace scale = "PARI: Most mothers are content to be with children all the time" if scale_num == "6"
	replace scale = "PARI: A child has a right to his own point of view and ought to be allowed to express it" if scale_num == "7"
	replace scale = "PARI: If a parent is wrong he should admit it to his child" if scale_num == "8"
	replace scale = "PARI: A child should be taught to avoid fighting no matter what happens" if scale_num == "9"
	replace scale = "PARI: Most mothers can spend all day with the children and remain calm and even-tempered" if scale_num == "10"
	replace scale = "PARI: Parents who are interested in hearing about their children's parties, dates, and fun help them grow up right" if scale_num == "11"
	replace scale = "PARI: A child should learn that he has to be disappointed sometimes" if scale_num == "12"
	replace scale = "PARI: It is very important that young boys and girls not be allowed to see each other completely undressed" if scale_num == "13"
	replace scale = "PARI: If a couple really loves each other there are very few arguments in their married life" if scale_num == "14"
	replace scale = "PARI: Parents should adjust to the children some rather than always expecting the children to adjust to the parents" if scale_num == "15"
	replace scale = "PARI: A good mother should develop interests outside the home" if scale_num == "16"
	replace scale = "PARI: One of the worst vthings about taking care of a home is a woman feels that she can't get out" if scale_num == "17"
	replace scale = "PARI: Children should not be allowed to disagree with their parents, even if they feel their own ideas are better" if scale_num == "18"
	replace scale = "PARI: It's best for the child if he never gets started wondering whether his mother's views are right" if scale_num == "19"
	replace scale = "PARI: A child should be taught to fight his own battles" if scale_num == "20"
	replace scale = "PARI: Children will get on any woman's nerves if she has to be with them all day" if scale_num == "21"
	replace scale = "PARI: Children would be happier and better behaved if parents would show less interest in their affairs" if scale_num == "22"
	replace scale = "PARI: A child should be protected from jobs which might be too tiring or hard for him" if scale_num == "23"
	replace scale = "PARI: Sex play is a normal vthing in children" if scale_num == "24"
	replace scale = "PARI: Sometimes it's necessary for a wife to tell off her husband in order to get her rights" if scale_num == "25"
	replace scale = "PARI: Children should learn to compromise and adjust to the demands of their parents" if scale_num == "26"
	replace scale = "PARI: Too many women forget that a mother's place is in the home" if scale_num == "27"
	replace scale = "PARI: Most young mothers don't mind spending most of their time at home" if scale_num == "28"
	replace scale = "PARI: A child's ideas should be seriously considered in making family decisions" if scale_num == "29"
	replace scale = "PARI: A child should be encouraged to look for answers to his questions from other people even if the answers contradict his parents" if scale_num == "30"
	replace scale = "PARI: Children should not be encouraged to bos or wrestle because it often leads to trouble or injury" if scale_num == "31"
	replace scale = "PARI: Raising children is an easy job" if scale_num == "32"
	replace scale = "PARI: If parents would have fun with their children, the children would be more apt to take their advice" if scale_num == "33"
	replace scale = "PARI: Children have to face difficult situations on their own" if scale_num == "34"
	replace scale = "PARI: Sex is one of the greatest problems to be contended with in children" if scale_num == "35"
	replace scale = "PARI: Almost any problem can be settled by quietly talking it over" if scale_num == "36"
	replace scale = "PARI: There is no reason parents should have their own way all the time, any more than the children should have their own way all the time" if scale_num == "37"
	replace scale = "PARI: A mother can keep a nice home and still have plenty of time left over to visit with neighbors and friends" if scale_num == "38"
	replace scale = "PARI: One of the bad vthings about raising children is that you aren't free enough of the time to do just as you like" if scale_num == "39"
	replace scale = "PARI: Children should be discouraged from telling their parents about it when they feel family rules are unreasonable" if scale_num == "40"
	replace scale = "PARI: The child should not question the vthinking of his parents" if scale_num == "41"
	replace scale = "PARI: It's quite natural for children to hit one another" if scale_num == "42"
	replace scale = "PARI: Mothers very often feel that they can't stand their children a moment longer" if scale_num == "43"
	replace scale = "PARI: Laughing at children's jokes and telling children jokes usually fail to make vthings go more smoothly" if scale_num == "44"
	replace scale = "PARI: Children should be kept away from all hard jobs which might be discouraging" if scale_num == "45"
	replace scale = "PARI: Children are normally curious about sex" if scale_num == "46"
	replace scale = "PARI: It's natural to have quarrels when two people who both have minds of their own get married" if scale_num == "47"
	replace scale = "PARI: It is rarely possible to treat a child as an equal" if scale_num == "48"
	replace scale = "PARI: A good mother will find enough social life wivthin the family" if scale_num == "49"
	replace scale = "PARI: Most young mothers are pretty content with home life" if scale_num == "50"
	replace scale = "PARI: When a child is in trouble he ought to know he won't be punished for talking about it with his parents" if scale_num == "51"
	replace scale = "PARI: A good mother can tolerate criticism of herself, even when the children are around" if scale_num == "52"
	replace scale = "PARI: Most parents prefer a quiet child to a scrappy one" if scale_num == "53"
	replace scale = "PARI: A mother should keep control of her temper even when children are demanding" if scale_num == "54"
	replace scale = "PARI: When you do vthings together, children feel close to you and can talk easier" if scale_num == "55"

	save abc-pari-pile-`age', replace
}

* ----------------- *
* Execution - P-value

foreach age of numlist 1 2 {
	* IHDP KIDI	
	cd "$pile_working"
	use ihdp-kidi-pile-`age', clear
	
	foreach t of global ihdp_type {
		gen inv_ihdp`t'Rcoeff = ihdp`t'R_`age'coeff * -1
		gen ihdp`t'Rinsig = .
		gen ihdp`t'R0_1 = .
		gen ihdp`t'R0_05 = .
		replace ihdp`t'Rinsig = ihdp`t'R_`age'coeff if ihdp`t'R_`age'pval > 0.1
		replace ihdp`t'R0_1 = ihdp`t'R_`age'coeff if ihdp`t'R_`age'pval <= 0.1 & ihdp`t'R_`age'pval > 0.05
		replace ihdp`t'R0_05 = ihdp`t'R_`age'coeff if ihdp`t'R_`age'pval <= 0.05
	}
	
	graph dot ihdpRinsig ihdpR0_1 ihdpR0_05 ///
			  ihdphighRinsig ihdphighR0_1 ihdphighR0_05 ///
			  ihdplowRinsig ihdplowR0_1 ihdplowR0_05, ///
	marker(1,msize(medium) msymbol(D) mlc(green) mfc(green*0) mlw(vthin)) marker(2,msize(medium) msymbol(D) mlc(green) mfc(green*0.5) mlw(vthin)) marker(3,msize(medium) msymbol(D) mlc(green) mfc(green) mlw(vthin)) ///
	marker(4,msize(medium) msymbol(T) mlc(green) mfc(green*0) mlw(vthin)) marker(5,msize(medium) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) marker(6,msize(medium) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
	marker(7,msize(medium) msymbol(O) mlc(green) mfc(green*0) mlw(vthin)) marker(8,msize(medium) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) marker(9,msize(medium) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
	over(scale, label(labsize(vsmall)) sort(scale_num)) ///
	legend (order (3 "IHDP-All" 6 "IHDP-High" 9 "IHDP-Low") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
	ylabel($item_axis_range) ///
	graphregion(fcolor(white))

	cd "$pile_out"
	graph export "ihdp_kidi_pile_R_`age'.pdf", replace
	
	cd "$pile_git_out"
	graph export "ihdp_kidi_pile_R_`age'.png", replace

	* ABC/CARE PARI
	cd "$pile_working"
	use abc-pari-pile-`age', clear
	
	foreach p in abc {
		gen inv_`p'Rcoeff = `p'R_`age'coeff * -1
		gen `p'Rinsig = .
		gen `p'R0_1 = .
		gen `p'R0_05 = .
		replace `p'Rinsig = `p'R_`age'coeff if `p'R_`age'pval > 0.1
		replace `p'R0_1 = `p'R_`age'coeff if `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05
		replace `p'R0_05 = `p'R_`age'coeff if `p'R_`age'pval <= 0.05
	}

	graph dot abcRinsig abcR0_1 abcR0_05, ///
	marker(1,msize(small) msymbol(D) mlc(blue) mfc(blue*0) mlw(vthin)) marker(2,msize(small) msymbol(D) mlc(blue) mfc(blue*0.5) mlw(vthin)) marker(3,msize(small) msymbol(D) mlc(blue) mfc(blue) mlw(vthin)) ///
	over(scale, label(labsize(tiny)) sort(scale_num)) ///
	legend (order (3 "ABC") size(vsmall)) yline(0) ylabel(#6, labsize(tiny)) ///
	ylabel($item_axis_range) ///
	graphregion(fcolor(white))
	
	cd "$pile_out"
	graph export "abccare_pari_pile_R_`age'.pdf", replace
	
	cd "$pile_git_out"
	graph export "abccare_pari_pile_R_`age'.png", replace
}

foreach age of numlist 1 3 {
	* IHDP Sameroff	
	cd "$pile_working"
	use ihdp-sameroff-pile-`age', clear
	
	foreach t of global ihdp_type {
		gen inv_ihdp`t'Rcoeff = ihdp`t'R_`age'coeff * -1
		gen ihdp`t'Rinsig = .
		gen ihdp`t'R0_1 = .
		gen ihdp`t'R0_05 = .
		replace ihdp`t'Rinsig = ihdp`t'R_`age'coeff if ihdp`t'R_`age'pval > 0.1
		replace ihdp`t'R0_1 = ihdp`t'R_`age'coeff if ihdp`t'R_`age'pval <= 0.1 & ihdp`t'R_`age'pval > 0.05
		replace ihdp`t'R0_05 = ihdp`t'R_`age'coeff if ihdp`t'R_`age'pval <= 0.05
	}

	graph dot ihdpRinsig ihdpR0_1 ihdpR0_05 ///
			  ihdphighRinsig ihdphighR0_1 ihdphighR0_05 ///
			  ihdplowRinsig ihdplowR0_1 ihdplowR0_05, ///
	marker(1,msize(medium) msymbol(D) mlc(green) mfc(green*0) mlw(vthin)) marker(2,msize(medium) msymbol(D) mlc(green) mfc(green*0.5) mlw(vthin)) marker(3,msize(medium) msymbol(D) mlc(green) mfc(green) mlw(vthin)) ///
	marker(4,msize(medium) msymbol(T) mlc(green) mfc(green*0) mlw(vthin)) marker(5,msize(medium) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) marker(6,msize(medium) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
	marker(7,msize(medium) msymbol(O) mlc(green) mfc(green*0) mlw(vthin)) marker(8,msize(medium) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) marker(9,msize(medium) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
	over(scale, label(labsize(tiny)) sort(scale_num)) ///
	legend (order (3 "IHDP-All" 6 "IHDP-High" 9 "IHDP-Low") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
	ylabel($item_axis_range) ///
	graphregion(fcolor(white))
	
	cd "$pile_out"
	graph export "ihdp_sameroff_pile_R_`age'.pdf", replace
	
	cd "$pile_git_out"
	graph export "ihdp_sameroff_pile_R_`age'.png", replace
}
