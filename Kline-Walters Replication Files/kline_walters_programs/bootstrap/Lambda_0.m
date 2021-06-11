function [v]=Lambda_0(a0,a1,b0,b1,chi);

    
    num1=normarg(b1,a0,chi)-normarg(a0,a0,chi);
    if (isinf(a0)==1);
        num1=0;
    end;
    
    num2=normarg(b1,a1,chi)-normarg(b0,a1,chi);
    if (isinf(a1))==1;
        num2=0;
    end;

    num3=normarg(a1,b1,chi)-normarg(a0,b0,chi);
    if (isinf(b0)==1);
        num3=0;
    end;
    
    num4=normarg(a1,b1,chi)-normarg(a0,b1,chi);
    if (isinf(b1)==1);
        num4=0;
    end;
    
    num=normpdf(a0)*num1-normpdf(a1)*num2+chi*normpdf(b0)*num3-chi*normpdf(b1)*num4;
   
    denom=binormcdf(a1,b1,chi)-binormcdf(a1,b0,chi)-binormcdf(a0,b1,chi)+2*binormcdf(a0,b0,chi);

    v=num/denom;
  