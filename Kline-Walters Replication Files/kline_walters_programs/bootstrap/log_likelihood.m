function [logL dlogL]=log_likelihood(theta,data,T,sims,params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%  SETUP %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%Unpack params;
        l=1;
        L=params(l); l=l+1;
        L1=params(l); l=l+1;
        K=params(l); l=l+1;
        R=params(l); 
        J=length(T(:,1));
        L_X=L;

    %%%Unpack data;
        l=1;
        site_i=data(:,l); l=l+1;
        X=data(:,l:(l+L-1)); l=l+L;
        Z=data(:,l); l=l+1;
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
        psi_h_T=theta(l:(l+K-1)); l=l+K;
        psi_h_TZ=theta(l:(l+K-1)); l=l+K;
        psi_c_T=theta(l:(l+K-1)); l=l+K;
        alpha_rho_T=theta(l:(l+K-1));
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%  COMPUTE LIKELIHOOD %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%Compute mean utilities;
        psi_h=(X*psi_h_X)+(repmat(Z,[1 L1]).*X1*psi_h_XZ)+(T_i*psi_h_T)+(repmat(Z,[1 K]).*T_i*psi_h_TZ);
        psi_c=(X*psi_c_X)+(T_i*psi_c_T);
        arctanh_rho=(X1*alpha_rho_X)+(T_i*alpha_rho_T);
        rho=(exp(2*arctanh_rho)-1)./(exp(2*arctanh_rho)+1);
        
    %%%preliminaries;
        psi_c_wide=repmat(psi_c,[1 R]);
        psi_h_wide=repmat(psi_h,[1 R]);

    %%%Choice-specific likelihoods;
    
        %%%%N%%%%%%%%%%;
        
            %Likelihood;
            rho_1h=1;
            rho_1c=rho;
            rho_2c=sqrt(1-(rho.^2));
            arg1=-psi_h./rho_1h;
            k1=normcdf(arg1);
            k1_wide=repmat(k1,[1 R]);
            eta1=norminv(sims.*k1_wide);
            arg2=-(psi_c_wide+(repmat(rho_1c,[1 R]).*eta1))./repmat(rho_2c,[1 R]);
            k2=normcdf(arg2);
            L=k1_wide.*k2;
            L_n=mean(L,2);

            %Gradients;
            
                %g1;
                darg1=-1./rho_1h;
                dk1=normpdf(arg1)./darg1;
                deta1=(1./normpdf(eta1)).*sims.*repmat(dk1,[1 R]);
                darg2=-(repmat(rho_1c./rho_2c,[1 R])).*deta1;
                dk2=normpdf(arg2).*darg2;
                dlogL=repmat(dk1./k1,[1 R])+(dk2./k2);
                g_1_n=mean(dlogL.*L,2)./L_n;
                
                %g2;
                darg2=-1./rho_2c;
                dk2=normpdf(arg2).*repmat(darg2,[1 R]);
                dlogL=dk2./k2;
                g_2_n=mean(dlogL.*L,2)./L_n;
                
                %g3;
                drho=(1+rho).*(1-rho);
                drho_1h=0*drho;
                drho_1c=1*drho;
                drho_2c=0.5*(1./sqrt(1-(rho.^2))).*(-2*rho.*drho);
                darg1=(psi_h./(rho_1h.^2)).*drho_1h;
                dk1=normpdf(arg1).*darg1;
                deta1=(1./normpdf(eta1)).*sims.*repmat(dk1,[1 R]);
                darg2=-((repmat(rho_2c,[1 R]).*(repmat(rho_1c,[1 R]).*deta1+eta1.*repmat(drho_1c,[1 R]))...
                        -(psi_c_wide+repmat(rho_1c,[1 R]).*eta1).*repmat(drho_2c,[1 R]))./repmat(rho_2c.^2,[1 R]));
                dk2=normpdf(arg2).*darg2;
                dlogL=repmat(dk1./k1,[1 R])+(dk2./k2);
                g_3_n=mean(dlogL.*L,2)./L_n;
                
        
        %%%%H%%%%%%%%%%;
            
            %Likelihood;
            rho_1n=1;
            rho_1c=1-rho;
            rho_2c=sqrt(1-(rho.^2));
            arg1=psi_h./rho_1n;
            k1=normcdf(arg1);
            k1_wide=repmat(k1,[1 R]);
            eta1=norminv(sims.*k1_wide);
            arg2=-(psi_c_wide-psi_h_wide+repmat(rho_1c,[1 R]).*eta1)./repmat(rho_2c,[1 R]);
            k2=normcdf(arg2);
            L=k1_wide.*k2;
            L_h=mean(L,2);
            
            %Gradients;
            
                %g1;
                darg1=1./rho_1n;
                dk1=normpdf(arg1).*darg1;
                deta1=(1./normpdf(eta1)).*sims.*repmat(dk1,[1 R]);
                darg2=repmat((1./rho_2c),[1 R])-repmat((rho_1c./rho_2c),[1 R]).*deta1;
                dk2=normpdf(arg2).*darg2;
                dlogL=repmat((dk1./k1),[1 R])+(dk2./k2);
                g_1_h=mean(dlogL.*L,2)./L_h;
                
                %g2;
                darg2=-1./rho_2c;
                dk2=normpdf(arg2).*repmat(darg2,[1 R]);
                dlogL=(dk2./k2);
                g_2_h=mean(dlogL.*L,2)./L_h;
                
                %g3;
                drho=(1+rho).*(1-rho);
                drho_1n=0*drho;
                drho_1c=-1*drho;
                drho_2c=0.5*(1./sqrt(1-(rho.^2))).*(-2*rho.*drho);
                darg1=-(psi_h./(rho_1n.^2)).*drho_1n;
                dk1=normpdf(arg1).*darg1;
                deta1=(1./normpdf(eta1)).*repmat(dk1,[1 R]).*sims;
                darg2=-((repmat(rho_2c,[1 R]).*(repmat(drho_1c,[1 R]).*eta1+deta1.*repmat(rho_1c,[1 R]))...
                        -repmat(drho_2c,[1 R]).*(psi_c_wide-psi_h_wide+repmat(rho_1c,[1 R]).*eta1))./repmat(rho_2c.^2,[1 R]));
                dk2=normpdf(arg2).*darg2;
                dlogL=repmat((dk1./k1),[1 R])+(dk2./k2);
                g_3_h=mean(dlogL.*L,2)./L_h;
                

            
        
        %%%%C%%%%%%%%%%%%;
        
            %Likelihood;
            rho_1n=1;
            rho_1h=1-rho;
            rho_2h=sqrt(1-(rho.^2));
            arg1=psi_c./rho_1n;
            k1=normcdf(arg1);
            k1_wide=repmat(k1,[1 R]);
            eta1=norminv(sims.*k1_wide);
            arg2=-(psi_h_wide-psi_c_wide+repmat(rho_1h,[1 R]).*eta1)./repmat(rho_2h,[1 R]);
            k2=normcdf(arg2);
            L=k1_wide.*k2;
            L_c=mean(L,2);
            
            %Gradients;
            
                %g1;
                darg2=-1./rho_2h;
                dk2=normpdf(arg2).*repmat(darg2,[1 R]);
                dlogL=(dk2./k2);
                g_1_c=mean(dlogL.*L,2)./L_c;
                
                %g2;
                darg1=1./rho_1n;
                dk1=normpdf(arg1).*darg1;
                deta1=(1./normpdf(eta1)).*sims.*repmat(dk1,[1 R]);
                darg2=repmat((1./rho_2h),[1 R])-repmat((rho_1h./rho_2h),[1 R]).*deta1;
                dk2=normpdf(arg2).*darg2;
                dlogL=repmat((dk1./k1),[1 R])+(dk2./k2);
                g_2_c=mean(dlogL.*L,2)./L_c;
                
                %g3;
                drho=(1+rho).*(1-rho);
                drho_1n=0*drho;
                drho_1h=-1*drho;
                drho_2h=0.5*(1./sqrt(1-(rho.^2))).*(-2*rho.*drho);
                darg1=-(psi_c./(rho_1n.^2)).*drho_1n;
                dk1=normpdf(arg1).*darg1;
                deta1=(1./normpdf(eta1)).*sims.*repmat(dk1,[1 R]);
                darg2=-((repmat(rho_2h,[1 R]).*(repmat(rho_1h,[1 R]).*deta1+eta1.*repmat(drho_1h,[1 R]))...
                        -repmat(drho_2h,[1 R]).*(psi_h_wide-psi_c_wide+repmat(rho_1h,[1 R]).*eta1))./(repmat(rho_2h.^2,[1 R])));
                dk2=normpdf(arg2).*darg2;
                dlogL=repmat((dk1./k1),[1 R])+(dk2./k2);
                g_3_c=mean(dlogL.*L,2)./L_c;

        
   %%%Final log likelihood;
   
        %Compute likelihood;
        logL=log(sum(D_dum.*[L_h L_c L_n],2));
        Q=-sum(logL);
      
   %%%Final gradient;
        
        %Replace gradients with zero when they are not chosen to avoid NaNs
        %in gradient;
        g_1_h(D_dum(:,1)~=1)=0;
        g_1_c(D_dum(:,2)~=1)=0;
        g_1_n(D_dum(:,3)~=1)=0;
        g_2_h(D_dum(:,1)~=1)=0;
        g_2_c(D_dum(:,2)~=1)=0;
        g_2_n(D_dum(:,3)~=1)=0;
        g_3_h(D_dum(:,1)~=1)=0;
        g_3_c(D_dum(:,2)~=1)=0;
        g_3_n(D_dum(:,3)~=1)=0;
   
        %Index gradients;
        g_1=g_1_h+g_1_c+g_1_n;
        g_2=g_2_h+g_2_c+g_2_n;
        g_3=g_3_h+g_3_c+g_3_n;
        
        %Storage for final gradient;
        G=[];

        %psi_h_X;
        G_temp=-sum(repmat(g_1,[1 L_X]).*X,1)';
        G=[G; G_temp];
  
        %psi_h_XZ;
        G_temp=-sum(repmat(g_1.*Z,[1 L1]).*X1,1)';
        G=[G; G_temp];
        
        %psi_c_X;
        G_temp=-sum(repmat(g_2,[1 L_X]).*X,1)';
        G=[G; G_temp];
        
        %alpha_rho_X;
        G_temp=-sum(repmat(g_3,[1 L1]).*X1,1)';
        G=[G; G_temp];
        
        %psi_h_T;
        G_temp=-sum(repmat(g_1,[1 K]).*T_i)';
        G=[G; G_temp];
        
        %psi_h_TZ;
        G_temp=-sum(repmat(g_1.*Z,[1 K]).*T_i)';
        G=[G; G_temp];
        
        %psi_c_T;
        G_temp=-sum(repmat(g_2,[1 K]).*T_i)';
        G=[G; G_temp];
        
        %alpha_rho_T;
        G_temp=-sum(repmat(g_3,[1 K]).*T_i,1)';
        G=[G; G_temp];
        
        
        
        
        