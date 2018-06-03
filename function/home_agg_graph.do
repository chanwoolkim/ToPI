graph dot ehsRinsig ehsR0_1 ehsR0_05 ///
		  ihdpRinsig ihdpR0_1 ihdpR0_05 ///
		  abcRinsig abcR0_1 abcR0_05 ///
		  careRinsig careR0_1 careR0_05, ///
marker(1,msize(large) msymbol(O) mlc(red) mfc(red*0) mlw(thick)) marker(2,msize(large) msymbol(O) mlc(red) mfc(red*0.5) mlw(thick)) marker(3,msize(large) msymbol(O) mlc(red) mfc(red) mlw(thick)) ///
marker(4,msize(large) msymbol(O) mlc(green) mfc(green*0) mlw(thick)) marker(5,msize(large) msymbol(O) mlc(green) mfc(green*0.5) mlw(thick)) marker(6,msize(large) msymbol(O) mlc(green) mfc(green) mlw(thick)) ///
marker(7,msize(large) msymbol(O) mlc(blue) mfc(blue*0) mlw(thick)) marker(8,msize(large) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(thick)) marker(9,msize(large) msymbol(O) mlc(blue) mfc(blue) mlw(thick)) ///
marker(10,msize(large) msymbol(O) mlc(purple) mfc(purple*0) mlw(thick)) marker(11,msize(large) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(thick)) marker(12,msize(large) msymbol(O) mlc(purple) mfc(purple) mlw(thick)) ///
over(scale, label(labsize(large)) sort(scale_row)) ///
legend (order (3 "EHS" 6 "IHDP" 9 "ABC" 12 "CARE") size(medsmall)) yline(0) ylabel(#4, labsize(medsmall)) ///
ylabel($agg_axis_range) ///
graphregion(fcolor(white)) bgcolor(white)
