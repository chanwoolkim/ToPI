graph dot ehsRinsig ehsR0_1 ehsR0_05 ///
		  ihdpRinsig ihdpR0_1 ihdpR0_05 ///
		  abcRinsig abcR0_1 abcR0_05 ///
		  careRinsig careR0_1 careR0_05, ///
marker(1,msize(small) msymbol(D) mlc(navy) mfc(navy*0) mlw(vthin)) marker(2,msize(small) msymbol(D) mlc(navy) mfc(navy*0.5) mlw(vthin)) marker(3,msize(small) msymbol(D) mlc(navy) mfc(navy) mlw(vthin)) ///
marker(4,msize(small) msymbol(O) mlc(navy) mfc(navy*0) mlw(vthin)) marker(5,msize(small) msymbol(O) mlc(navy) mfc(navy*0.5) mlw(vthin)) marker(6,msize(small) msymbol(O) mlc(navy) mfc(navy) mlw(vthin)) ///
marker(7,msize(small) msymbol(T) mlc(navy) mfc(navy*0) mlw(vthin)) marker(8,msize(small) msymbol(T) mlc(navy) mfc(navy*0.5) mlw(vthin)) marker(9,msize(small) msymbol(T) mlc(navy) mfc(navy) mlw(vthin)) ///
marker(10,msize(small) msymbol(S) mlc(navy) mfc(navy*0) mlw(vthin)) marker(11,msize(small) msymbol(S) mlc(navy) mfc(navy*0.5) mlw(vthin)) marker(12,msize(small) msymbol(S) mlc(navy) mfc(navy) mlw(vthin)) ///
over(question, label(labsize(tiny)) sort(scale_row)) ///
legend (order (3 "EHS" 6 "IHDP" 9 "ABC" 12 "CARE") size(vsmall)) yline(0) ylabel(#4, labsize(vsmall)) ///
ylabel($item_axis_range) ///
ysize(11) xsize(8.5) graphregion(fcolor(white)) bgcolor(white)
