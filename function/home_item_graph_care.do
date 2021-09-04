
graph dot carebothRinsig carebothR0_1 carebothR0_05 ///
		  carehomeRinsig carehomeR0_1 carehomeR0_05, ///
marker(1,msize(small) msymbol(O) mlc(navy) mfc(navy*0) mlw(vthin)) marker(2,msize(small) msymbol(O) mlc(navy) mfc(navy*0.5) mlw(vthin)) marker(3,msize(small) msymbol(O) mlc(navy) mfc(navy) mlw(vthin)) ///
marker(4,msize(small) msymbol(T) mlc(navy) mfc(navy*0) mlw(vthin)) marker(5,msize(small) msymbol(T) mlc(navy) mfc(navy*0.5) mlw(vthin)) marker(6,msize(small) msymbol(T) mlc(navy) mfc(navy) mlw(vthin)) ///
over(question, label(labsize(tiny)) sort(scale_row)) ///
legend (order (3 "CARE-Both" 6 "CARE-Home") size(vsmall)) yline(0) ylabel(#7, labsize(vsmall)) ///
ylabel($item_axis_range) ///
ysize(5) xsize(8.5) graphregion(fcolor(white)) bgcolor(white)
