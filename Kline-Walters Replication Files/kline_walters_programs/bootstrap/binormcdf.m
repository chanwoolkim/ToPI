function [c]=binormcdf(x,y,rho);
    
    c=mvncdf([x y],zeros(1,2),[1 rho; rho 1]);