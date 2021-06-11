function [Q G]=objfn(theta,data,T,sims,params);

        %Get likelihood and gradient at initial point;
        [Q G logL dlogL]=get_Q(theta,data,T,sims,params);