foreach p of global programs {
	gen inv_`p'Rcoeff = `p'R_`age'coeff * -1
	gen `p'Rinsig = .
	gen `p'R0_1 = .
	gen `p'R0_05 = .
	replace `p'Rinsig = `p'R_`age'coeff if `p'R_`age'pval > 0.1
	replace `p'R0_1 = `p'R_`age'coeff if `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05
	replace `p'R0_05 = `p'R_`age'coeff if `p'R_`age'pval <= 0.05
}
