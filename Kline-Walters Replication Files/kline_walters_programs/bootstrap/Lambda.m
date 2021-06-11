function [v]=Lambda(a,b,xi);
    arg1=(b-xi*a)/sqrt(1-(xi^2));
    arg2=(a-xi*b)/sqrt(1-(xi^2));
    num=(normpdf(a)*normcdf(arg1))+(xi*normpdf(b)*normcdf(arg2));
    denom=mvncdf([a b],zeros(1,2),[1 xi; xi 1]);
    v=-num/denom;