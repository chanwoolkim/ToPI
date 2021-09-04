    function [psi_h psi_c rho]=get_probit(theta,data,T,params);

    %%%Unpack params;
        l=1;
        L=params(l); l=l+1;
        L1=params(l); l=l+1;
        LP=params(l); l=l+1;
        K=params(l); l=l+1;
        R=params(l); 
        J=length(T(:,1));
        L_X=L;

    %%%Unpack data;
        l=1;
        site_i=data(:,l); l=l+1;
        X=data(:,l:(l+L-1)); l=l+L;
        Z=data(:,l); l=l+1;
        P=data(:,l:(l+LP-1)); l=l+LP;
        W=data(:,l); l=l+1;
        D_dum=data(:,l:end);
        X1=X(:,1:L1);
        T_i=T(site_i,:);
        N=length(site_i);
    
    %%%Unpack parameters;
    
        %Unpack parameters to be estimated;
        l=1;
        psi_h_X=theta(l:(l+L-1)); l=l+L;
        psi_h_XZ=theta(l:(l+L1-1)); l=l+L1;
        psi_c_X=theta(l:(l+L-1)); l=l+L;
        alpha_rho_X=theta(l:(l+L1-1)); l=l+L1;
        psi_h_T=reshape(theta(l:(l+(K*LP)-1)),[LP K]); l=l+(K*LP);
        psi_h_TZ=reshape(theta(l:(l+(K*LP)-1)),[LP K]); l=l+(K*LP);
        psi_c_T=reshape(theta(l:(l+(K*LP)-1)),[LP K]); l=l+(K*LP);
        alpha_rho_T=reshape(theta(l:(l+(K*LP)-1)),[LP K]); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%  COMPUTE INDICES %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%Compute mean utilities;
        psi_h=(X*psi_h_X)+(repmat(Z,[1 L1]).*X1*psi_h_XZ)...
            +sum(P.*(T_i*(psi_h_T')),2)...
            +Z.*sum(P.*(T_i*(psi_h_TZ')),2);
        psi_c=(X*psi_c_X)+sum(P.*(T_i*(psi_c_T')),2);
        arctanh_rho=(X1*alpha_rho_X)+sum(P.*(T_i*(alpha_rho_T')),2);
        rho=(exp(2*arctanh_rho)-1)./(exp(2*arctanh_rho)+1);