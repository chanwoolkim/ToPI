graph dot ehsRinsig ehsR0_1 ehsR0_05 ///
		  ihdpRinsig ihdpR0_1 ihdpR0_05 ///
		  abcRinsig abcR0_1 abcR0_05 ///
		  careRinsig careR0_1 careR0_05, ///
marker(1,msize(large) msymbol(O) mlc(red) mfc(red*0) mlw(thin)) marker(2,msize(large) msymbol(O) mlc(red) mfc(red*0.5) mlw(thin)) marker(3,msize(large) msymbol(O) mlc(red) mfc(red) mlw(thin)) ///
marker(4,msize(large) msymbol(O) mlc(green) mfc(green*0) mlw(thin)) marker(5,msize(large) msymbol(O) mlc(green) mfc(green*0.5) mlw(thin)) marker(6,msize(large) msymbol(O) mlc(green) mfc(green) mlw(thin)) ///
marker(7,msize(large) msymbol(O) mlc(blue) mfc(blue*0) mlw(thin)) marker(8,msize(large) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(thin)) marker(9,msize(large) msymbol(O) mlc(blue) mfc(blue) mlw(thin)) ///
marker(10,msize(large) msymbol(O) mlc(purple) mfc(purple*0) mlw(thin)) marker(11,msize(large) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(thin)) marker(12,msize(large) msymbol(O) mlc(purple) mfc(purple) mlw(thin)) ///
over(scale, label(labsize(vsmall)) sort(scale_row)) ///
legend (order (3 "EHS" 6 "IHDP" 9 "ABC" 12 "CARE") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
ylabel($outcome_axis_range) ///
graphregion(fcolor(white))
