function [f]=normarg(x,y,rho);

    f=normcdf((x-(rho*y))/sqrt(1-(rho^2)));