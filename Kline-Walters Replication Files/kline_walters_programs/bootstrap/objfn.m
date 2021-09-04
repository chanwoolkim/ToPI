function [Q G]=objfn(theta,data,T,sims,params);

        %Get likelihood and gradient at initial point;
        [Q G logL dlogL]=get_Q(theta,data,T,sims,params);
        
        %Determine if initial gradient evaluates to NaN. If so, supply
        %numerical gradient;
        %{
        nangrad=(sum(isnan(G))>0);
        if nangrad==1;
            options_nangrad=struct('Display','off','Algorithm','active-set','GradObj','off','LargeScale','off','TolFun',1e10);
            [theta_hat Q_hat exitflag output G_hat]=fminunc(@(x)get_Q(x,data,T,sims,params),theta,options_nangrad);
            Q=Q_hat;
            G=G_hat;
            disp('Warning: Analytic gradient evaluated to NaN')
        end;
        %}