*if `age' == 5 {
	graph dot ihdpRinsig ihdpR0_1 ihdpR0_05, ///
		marker(1,msize(small) msymbol(O) mlc(green) mfc(green*0) mlw(vthin)) marker(2,msize(small) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) marker(3,msize(small) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
		over(question, label(labsize(tiny)) sort(scale_row)) ///
		legend (order (3 "IHDP") size(vsmall)) yline(0) ylabel(#4, labsize(vsmall)) ///
		ylabel($item_axis_range) ///
		ysize(11) xsize(8.5) graphregion(fcolor(white)) bgcolor(white)
/*}

if `age' == 8 {
	graph dot ihdpRinsig ihdpR0_1 ihdpR0_05 ///
		careRinsig careR0_1 careR0_05 ///
		carebothRinsig carebothR0_1 carebothR0_05 ///
		carehomeRinsig carehomeR0_1 carehomeR0_05, ///
		marker(1,msize(small) msymbol(O) mlc(green) mfc(green*0) mlw(vthin)) marker(2,msize(small) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) marker(3,msize(small) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
		marker(4,msize(small) msymbol(O) mlc(purple) mfc(purple*0) mlw(vthin)) marker(5,msize(small) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) marker(6,msize(small) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
		marker(7,msize(small) msymbol(D) mlc(purple) mfc(purple*0) mlw(vthin)) marker(8,msize(small) msymbol(D) mlc(purple) mfc(purple*0.5) mlw(vthin)) marker(9,msize(small) msymbol(D) mlc(purple) mfc(purple) mlw(vthin)) ///
		marker(10,msize(small) msymbol(T) mlc(purple) mfc(purple*0) mlw(vthin)) marker(11,msize(small) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) marker(12,msize(small) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
		over(question, label(labsize(tiny)) sort(scale_row)) ///
		legend (order (3 "IHDP" 6 "CARE" 9 "CARE-Both" 12 "CARE-Home") size(vsmall)) yline(0) ylabel(#4, labsize(vsmall)) ///
		ylabel($item_axis_range) ///
		ysize(11) xsize(8.5) graphregion(fcolor(white))
}
*/
