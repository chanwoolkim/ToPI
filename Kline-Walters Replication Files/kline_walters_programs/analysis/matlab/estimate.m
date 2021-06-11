
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Chris Walters %%%%%%%%%%%%%%%%%%%
%%%%%%%% 1/28/2016  %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% This program estimates the %%%%%%
%%%%%%%%% MN Probit finite type FE model %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% SET UP MATLAB %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%Clear;
    clear all;
    
    %%%Choose parameters;
    
        %fminunc options;
        options_fmin=struct('Display','iter','Algorithm','active-set','MaxFunEvals',10000,'MaxIter',500,'GradObj','on','LargeScale','off','TolFun',1e-6);
        
        %Simulation draws;
        R=300;
        new_sims=0;
        
        %Optimization tolerance;
        eps=1e-4;
        
        %Number of covariates in X1;
        L1=8;
        
        %Number of groups;
        K=6;
       
        %Whether to interact first element in X1 with type;
        interact_P=0;
        
        %Whether to use weights;
        use_weights=1;
        
        %Choices for starting values;
        rand_start_params=0;
        rand_start_groups=0;
            split=0*(1-rand_start_groups);
            split_biggest=1*split;
                random_split=1*split_biggest;
        rand_start_group_params=0;
            
        %Whether to use hessian for SEs;
        hessian_se=0;
        cluster_se=0;

 %%%%%Switches;
    maximize=1;
    export=1;
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% LOAD  DATA %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

    %%%Bring in raw data;
    rawdata=dlmread('sitedata.csv');

    %%%Extract variables;
    l=1;
    hsis_childid=rawdata(:,l); l=l+1;
    micro_site_i=rawdata(:,l); l=l+1;
    site_i=rawdata(:,l); l=l+1;
    Y=rawdata(:,l); l=l+1;
    D_h=rawdata(:,l); l=l+1;
    D_c=rawdata(:,l); l=l+1;
    D_n=rawdata(:,l); l=l+1;
    Z=rawdata(:,l); l=l+1;
    W=rawdata(:,l); l=l+1;
    X1=rawdata(:,l:(l+L1-1)); l=l+L1;
    X0=rawdata(:,l:end);
    
    %%%Format and label;
    N=length(Y);
    J=length(unique(site_i));
    X=[X1 X0];
    P=ones(N,1);
    if interact_P==1;
        P=[P X1(:,1)];
        X1(:,1)=[];
        X=[X1 X0];
    end;
    L1=length(X1(1,:));
    L=L1+length(X0(1,:));
    LP=length(P(1,:));
    D_dum=[D_h D_c D_n];
    site_dum=dummyvar(site_i);
    W=W*(N/sum(W));
    if use_weights~=1;
        W=ones(N,1);
    end;
    
    %%%%Data and parameters to pass to optimizer;   
        data=[site_i X Z P W D_dum];
        params=[L L1 LP K R];
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% ESTIMATE PARAMETERS %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

if maximize==1;
    


    %%%%%%%%%%%% SIMULATION DRAWS FOR GHK %%%%%%%%%%%%%%%%%%%%%%%
    
                sims=rand(N,R);
                if new_sims==0;
                    try;
                        load('sims_final');
                        sims=sims_final;
                        R=length(sims(1,:));
                        params=[L L1 LP K R];
                    catch;
                        disp('Could not load sim draws -- starting randomly')
                    end;
                end;
    
    
    %%%%%%%%%%%%% INITIAL VALUES %%%%%%%%%%%%

            %%%%Initial common parameter vector;

                start_vals=randn(2*L+2*L1,1);
                if rand_start_params==0;
                    %Try to load from existing estimates;
                    try;
                        load('start_vals');
                    %If failed, start randomly;
                    catch;
                        disp('Could not load starting vals for common params -- starting randomly')
                    end;
                end;
                theta_common=start_vals;

            %%%%Initial type assignments;
                %Random groups;
                U_T=randn(J,K);
                [maxval Tval]=max(U_T,[],2);
                T_0=zeros(J,K);
                for k=1:K;
                    T_0(:,k)=(Tval==k);
                end;
                theta_group=randn(4*K*LP,1);
                
                %Try to load from existing estimates (will only work if previous
                %estimates use same # of groups);
                if (rand_start_groups==0) & (split==0);
                    try;
                        load('T_final');
                        T_0=T_final.*ones(J,K);
                        load('start_vals_group');
                        theta_group=ones(4*K*LP,1).*start_vals_group;

                    %If failed, assign randomly;
                    catch;
                        disp('Could not load starting vals for group assignments -- starting randomly')
                    end;
                end;
                %Try to split existing estimates (will only work if previous
                 %estimates use one less group);
                if (rand_start_groups==0) & (split==1);
                    try;
                        %Load previous group assignments and group params;
                        load('T_final');
                        load('start_vals_group');
                        T_i_final=T_final(site_i,:);
                        theta_group_old=zeros(4*LP,K-1);
                        q=1;
                        for t=1:4;
                            for k=1:(K-1);
                                theta_group_old(t,k)=start_vals_group(q);
                                q=q+1;
                            end;
                        end;
                        
                        %Determine which group has worst logL;
                        params_old=[L L1 LP (K-1) R];
                        [Qtemp Gtemp logL_i_temp dlogL_i_temp]=get_Q([theta_common' start_vals_group']',data,T_final,sims,params_old);
                        [min_val min_index]=min((sum((T_i_final.*repmat(logL_i_temp,[1 (K-1)])),1))');
                        if split_biggest==1;
                            [min_val min_index]=max(sum(T_i_final,1)');
                        end;
                        
                        %Split group with worst logL at median of site avg logL in
                        %this group;
                        type_init=zeros(J,1);
                        for k=1:(K-1);
                            type_init=type_init+(k*T_final(:,k));
                        end;
                        logL_site_temp=inv(site_dum'*site_dum)*site_dum'*logL_i_temp;
                        if random_split==1;
                            logL_site_temp=randn(length(logL_site_temp(:,1)),length(logL_site_temp(1,:)));
                        end;
                        med_logL=median(logL_site_temp(type_init==min_index));
                        T_split=repmat(type_init==min_index,[1 2]).*[(logL_site_temp<med_logL) (logL_site_temp>=med_logL)];
                        
                        
                        %Assign new groups;
                        T_0=[T_final(:,1:(min_index-1)) T_split T_final(:,(min_index+1):end)];
                        
                        %Assign new params;
                        theta_group_0=[theta_group_old(:,1:(min_index-1)) randn(4*LP,2) theta_group_old(:,(min_index+1):end)]';
                        theta_group=theta_group_0(:);
                        
                   catch;
                       disp('Could not split groups -- starting randomly')  
                    end;
                end;
                if rand_start_group_params==1;
                    theta_group=randn(4*K,1);
                end;
                %If any group has no sites assigned, try a new random point;
                min_assign=min(sum(T_0,1));
                reassign=(min_assign==0);
                while reassign==1;
                    U_T=randn(J,K);
                    [maxval Tval]=max(U_T,[],2);
                    T_0=zeros(J,K);
                    for k=1:K;
                        T_0(:,k)=(Tval==k);
                    end;
                    min_assign=min(sum(T_0,1));
                    reassign=(min_assign==0);
                end;
                
                %Final starting values;
                theta_0=[theta_common; theta_group];
                theta_current=theta_0;
                T_current=T_0;

         
    %%%%%%%%%%% MAXIMIZE OBJECTIVE %%%%%%%%%%%%%%%%%%%%%%%%%
    
                tic
                conv=eps+1;
                logL=-9999999999999;
                while conv>eps;

                    %%%%Maximize likelihood over parameters given type assignments;
                        complete=0;
                        while complete<1;
                           try;
                                [theta_current Q_hat]=fminunc(@(x)objfn(x,data,T_current,sims,params),theta_current,options_fmin);
                            catch;
                               disp('Warning: Maximization failed. Trying a new point')
                               complete=complete-1;
                               theta_current=[theta_common; randn(4*K*LP,1)];
                               if rand_start_params==1;
                                   theta_current=randn(2*L+2*L1+4*K*LP,1);
                               end;
                            end;
                            complete=complete+1;
                        end;


                    %%%%Compute change in likelihood to determine if converged;
                        conv=abs(-Q_hat-logL)
                        logL=-Q_hat
                        mean(T_current)

                    %%%%Get new type assignments to maximize likelihood;

                        %Compute type-specific likelihoods;
                        logL_type=zeros(N,K);
                        for k=1:K;
                            [Qtemp Gtemp logL_temp]=get_Q(theta_current,data,[zeros(N,k-1) ones(N,1) zeros(N,K-k)],sims,params);
                            logL_type(:,k)=logL_temp;
                        end;

                        %Assign max likelihood by site;
                        site_logL=site_dum'*logL_type;
                        [maxval maxtype]=max(site_logL,[],2);
                        T_current=zeros(J,K);
                        for k=1:K;
                            T_current(:,k)=(maxtype==k);
                        end;

                end;
        
    %%%%%%%%%%%%%%% DISPLAY RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%
        
            %%%Get SEs;
            
                %Outer prod of gradient;
                [Q_hat G_hat logL_i dlogL_i]=get_Q(theta_current,data,T_current,sims,params);
                cov=inv(dlogL_i'*dlogL_i);
                SE=real(sqrt(diag(cov)));
                
                %Inverse hessian;
                SE2=[];
                if hessian_se==1;
                    options_fmin_hess=struct('Display','iter','Algorithm','active-set','MaxFunEvals',10000,'MaxIter',500,'GradObj','on','LargeScale','off','TolFun',1e10);
                    [t q exit out g H]=fminunc(@(x)objfn(x,data,T_current,sims,params),theta_current,options_fmin_hess);
                    cov2=inv(H);
                    SE2=real(sqrt(diag(cov)));
                end;
                
                %Cluster robust;
                if cluster_se==1;
                    clust=zeros(length(SE),length(SE));
                    micro_J=length(unique(micro_site_i));
                    for j=1:J;
                        dlogL_temp=dlogL_i(site_i==j,:);
                        dlogL_j=sum(dlogL_temp,1)';
                        clust=clust+dlogL_j*(dlogL_j');
                    end;
                    cov=inv(H)*clust*inv(H);
                    SE=real(sqrt(diag(cov)));
                end;

            %%%Display estimates;  
                
                common_ests=[theta_common theta_current(1:(2*(L+L1))) SE(1:(2*(L+L1)))]
                group_ests=[theta_group theta_current((2*(L+L1)+1):end) SE((2*(L+L1)+1):end)]
                group_shares=mean(T_current)

            %%%Display diagnostics;

                %Log likelihood;
                logL=logL

                %AIC;
                nparams=length(theta_current)+J;
                AIC=2*nparams-2*logL

                %BIC;
                BIC=nparams*log(N)-2*logL
                
            %%%Run time;
                toc
                
    %%%%%%%%%%%%%%%%%%% SAVE RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%
    
            start_vals=theta_current(1:(2*L+2*L1));
            save('start_vals','start_vals');
            start_vals_group=theta_current(((2*L+2*L1)+1):end);
            save('start_vals_group','start_vals_group');
            sims_final=sims;
            save('sims_final','sims_final');
            T_final=T_current;
            T_i_final=T_final(site_i,:);
            save('T_final','T_final','T_i_final');
            results={theta_current,T_current,data,params,sims};
            save('results','results');
                
                
    %%%%%%%%%%%%%%%%%%% TEST FOR HETEROGENEITY %%%%%%%%%%%%%%%%%%%%%%%%%% 
        theta=theta_current;
    
        %%%%%%Covariates;
            
            %Constant;
            ntheta=length(theta_current);
            C=[eye(L1) zeros(L1,ntheta-L1)];
            teststat=(C*theta)'*inv(C*cov*C')*(C*theta)
            pval=1-chi2cdf(teststat,L1)
            
            %Offer interaction;
            C=[zeros(L1,L) eye(L1) zeros(L1,ntheta-(L+L1))];
            teststat=(C*theta)'*inv(C*cov*C')*(C*theta)
            pval=1-chi2cdf(teststat,L1)
            
            %Other centerutility;
            C=[zeros(L1,L+L1) eye(L1) zeros(L1,ntheta-(L+2*L1))];
            teststat=(C*theta)'*inv(C*cov*C')*(C*theta)
            pval=1-chi2cdf(teststat,L1)
            
            %Correlation;
            C=[zeros(L1,2*L+L1) eye(L1) zeros(L1,ntheta-(2*L+2*L1))];
            teststat=(C*theta)'*inv(C*cov*C')*(C*theta)
            pval=1-chi2cdf(teststat,L1)
            
        %%%%%Sites;
            if K>1;
                sitew=mean(T_current,1)';
                sitew(6)=0;
                sitew=sitew/sum(sitew);
                sitemat=zeros(K-1,K);
                for k=1:(K-1);
                    sitemat(k,k:(k+1))=[1 -1];
                end;

                %Show coefs;
                ngroup=length(theta_group);
                group_cov=cov((2*(L+L1)+1):end,(2*(L+L1)+1):end);
                for t=1:4;
                    try;
                    v=[zeros(6*(t-1),1); sitew; zeros(ngroup-(6*(t-1)+6),1)];
                    real([v'*theta_group sqrt(v'*group_cov*v)])
                    catch;
                        
                    end;
                end;

                %Constant;
                C=[zeros(K-1,2*(L+L1)) sitemat zeros(K-1,ntheta-(2*(L+L1)+K))];
                teststat=(C*theta)'*inv(C*cov*C')*(C*theta)
                pval=1-chi2cdf(teststat,L1)

                %Offer coef;
                C=[zeros(K-1,2*(L+L1)+K) sitemat zeros(K-1,ntheta-(2*(L+L1)+2*K))];
                teststat=(C*theta)'*inv(C*cov*C')*(C*theta)
                pval=1-chi2cdf(teststat,L1)

                %C utility;
                C=[zeros(K-1,2*(L+L1)+2*K) sitemat zeros(K-1,ntheta-(2*(L+L1)+3*K))];
                teststat=(C*theta)'*inv(C*cov*C')*(C*theta)
                pval=1-chi2cdf(teststat,L1)

                %Correlation;
                C=[zeros(K-1,2*(L+L1)+3*K) sitemat zeros(K-1,ntheta-(2*(L+L1)+4*K))];
                teststat=(C*theta)'*inv(C*cov*C')*(C*theta)
                pval=1-chi2cdf(teststat,L1)
            end;
            
end;  
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% EXPORT RESULTS %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

if export==1;

    %%%Load results;
    load('results');
    l=1;
    theta_current=cell2mat(results(l)); l=l+1;
    T_current=cell2mat(results(l)); l=l+1;
    data=cell2mat(results(l)); l=l+1;
    params=cell2mat(results(l)); l=l+1;
    sims=cell2mat(results(l));

    %%%Get group membership;
    T_i=T_current(site_i,:);

    %%%Get choice indices;
    [psi_h psi_c rho]=get_probit(theta_current,data,T_current,params);
    data_0=[site_i X zeros(N,1) P W D_dum];
    [psi_h_0 temp1 temp2]=get_probit(theta_current,data_0,T_current,params);
    data_1=[site_i X ones(N,1) P W D_dum];
    [psi_h_1 temp1 temp2]=get_probit(theta_current,data_1,T_current,params);

    %%%Get control functions and imputed means for compliance groups;
    lambda_h_h=zeros(N,1);
    lambda_h_c=zeros(N,1);
    lambda_c_h=zeros(N,1);
    lambda_c_c=zeros(N,1);
    lambda_n_h=zeros(N,1);
    lambda_n_c=zeros(N,1);
    lambda_h_h_1=zeros(N,1);
    lambda_h_c_1=zeros(N,1);
    lambda_c_h_1=zeros(N,1);
    lambda_c_c_1=zeros(N,1);
    lambda_n_h_1=zeros(N,1);
    lambda_n_c_1=zeros(N,1);
    lambda_h_h_0=zeros(N,1);
    lambda_h_c_0=zeros(N,1);
    lambda_c_h_0=zeros(N,1);
    lambda_c_c_0=zeros(N,1);
    lambda_n_h_0=zeros(N,1);
    lambda_n_c_0=zeros(N,1);
    w_nc=zeros(N,1);
    w_cc=zeros(N,1);
    w_cnt=zeros(N,1);
    w_nnt=zeros(N,1);
    w_at=zeros(N,1);
    v_h_nc=zeros(N,1);
    v_h_cc=zeros(N,1);
    v_h_nnt=zeros(N,1);
    v_h_cnt=zeros(N,1);
    v_h_at=zeros(N,1);
    v_c_nc=zeros(N,1);
    v_c_cc=zeros(N,1);
    v_c_nnt=zeros(N,1);
    v_c_cnt=zeros(N,1);
    v_c_at=zeros(N,1);
    
    for i=1:N;
        
        %Control functions;
        lambda_h_h(i)=-Lambda(psi_h(i),(psi_h(i)-psi_c(i))/sqrt(2*(1-rho(i))),sqrt((1-rho(i))/2));
        lambda_h_c(i)=lambda_h_h(i)+sqrt(2*(1-rho(i)))*Lambda((psi_h(i)-psi_c(i))/sqrt(2*(1-rho(i))),psi_h(i),sqrt((1-rho(i))/2));
        lambda_c_c(i)=-Lambda(psi_c(i),(psi_c(i)-psi_h(i))/sqrt(2*(1-rho(i))),sqrt((1-rho(i))/2));
        lambda_c_h(i)=lambda_c_c(i)+sqrt(2*(1-rho(i)))*Lambda((psi_c(i)-psi_h(i))/sqrt(2*(1-rho(i))),psi_c(i),sqrt((1-rho(i))/2));
        lambda_n_h(i)=Lambda(-psi_h(i),-psi_c(i),rho(i));
        lambda_n_c(i)=Lambda(-psi_c(i),-psi_h(i),rho(i));
        
        %Hypothetical ontrol functions with Z switched on/off;
        lambda_h_h_1(i)=-Lambda(psi_h_1(i),(psi_h_1(i)-psi_c(i))/sqrt(2*(1-rho(i))),sqrt((1-rho(i))/2));
        lambda_h_c_1(i)=lambda_h_h_1(i)+sqrt(2*(1-rho(i)))*Lambda((psi_h_1(i)-psi_c(i))/sqrt(2*(1-rho(i))),psi_h_1(i),sqrt((1-rho(i))/2));
        lambda_c_c_1(i)=-Lambda(psi_c(i),(psi_c(i)-psi_h_1(i))/sqrt(2*(1-rho(i))),sqrt((1-rho(i))/2));
        lambda_c_h_1(i)=lambda_c_c_1(i)+sqrt(2*(1-rho(i)))*Lambda((psi_c(i)-psi_h_1(i))/sqrt(2*(1-rho(i))),psi_c(i),sqrt((1-rho(i))/2));
        lambda_n_h_1(i)=Lambda(-psi_h_1(i),-psi_c(i),rho(i));
        lambda_n_c_1(i)=Lambda(-psi_c(i),-psi_h_1(i),rho(i));
        lambda_h_h_0(i)=-Lambda(psi_h_0(i),(psi_h_0(i)-psi_c(i))/sqrt(2*(1-rho(i))),sqrt((1-rho(i))/2));
        lambda_h_c_0(i)=lambda_h_h_0(i)+sqrt(2*(1-rho(i)))*Lambda((psi_h_0(i)-psi_c(i))/sqrt(2*(1-rho(i))),psi_h_0(i),sqrt((1-rho(i))/2));
        lambda_c_c_0(i)=-Lambda(psi_c(i),(psi_c(i)-psi_h_0(i))/sqrt(2*(1-rho(i))),sqrt((1-rho(i))/2));
        lambda_c_h_0(i)=lambda_c_c_0(i)+sqrt(2*(1-rho(i)))*Lambda((psi_c(i)-psi_h_0(i))/sqrt(2*(1-rho(i))),psi_c(i),sqrt((1-rho(i))/2));
        lambda_n_h_0(i)=Lambda(-psi_h_0(i),-psi_c(i),rho(i));
        lambda_n_c_0(i)=Lambda(-psi_c(i),-psi_h_0(i),rho(i));
        
        %Compliance groups;
        
            %NC's;
            w_nc(i)=binormcdf(-psi_h_0(i),-psi_c(i),rho(i)) - binormcdf(-psi_h_1(i),psi_c(i),rho(i));
            v_h_nc(i)=Lambda_0(-psi_h_1(i),-psi_h_0(i),-Inf,-psi_c(i),rho(i));
            v_c_nc(i)=Lambda_0(-Inf,-psi_c(i),-psi_h_1(i),-psi_h_0(i),rho(i));
            
            %CC's;
            a1=(psi_c(i) - psi_h_1(i))/sqrt(2*(1-rho(i)));
            a2=(psi_c(i) - psi_h_0(i))/sqrt(2*(1-rho(i)));
            b1=psi_c(i);
            tau=sqrt((1-rho(i))/2);
            w_cc(i)=binormcdf(a2,b1,tau) - binormcdf(a1,b1,tau);
            temp1=Lambda_0(a1,a2,-Inf,b1,tau);
            temp2=Lambda_0(-Inf,b1,a1,a2,tau);
            v_h_cc(i)=-temp2+sqrt(2*(1-rho(i)))*temp1;
            v_c_cc(i)=-temp2;
            
            
            %NNT's;
            w_nnt(i)=binormcdf(-psi_h_1(i),-psi_c(i),rho(i));
            v_h_nnt(i)=Lambda_0(-Inf,-psi_h_1(i),-Inf,-psi_c(i),rho(i));
            v_c_nnt(i)=Lambda_0(-Inf,-psi_c(i),-Inf,-psi_h_1(i),rho(i));
            
            %CNT's;
            a1=(psi_c(i) - psi_h_1(i))/sqrt(2*(1-rho(i)));
            a2=psi_c(i);
            tau=sqrt((1-rho(i))/2);
            w_cnt(i)=binormcdf(a1,a2,tau);
            temp1=Lambda_0(-Inf,a1,-Inf,a2,tau);
            temp2=Lambda_0(-Inf,a2,-Inf,a1,tau);
            v_h_cnt(i)=-temp2+sqrt(2*(1-rho(i)))*temp1;
            v_c_cnt(i)=-temp2;
            
            %AT's;
            a1=(psi_h_0(i) - psi_c(i))/sqrt(2*(1-rho(i)));
            a2=psi_h_0(i);
            tau=sqrt((1-rho(i))/2);
            w_at(i)=binormcdf(a1,a2,tau);
            temp1=Lambda_0(-Inf,a2,-Inf,a1,tau);
            temp2=Lambda_0(-Inf,a1,-Inf,a2,tau);
            v_h_at(i)=-temp1;
            v_c_at(i)=-temp1+sqrt(2*(1-rho(i)))*temp2;
        
    end;
    
    v_h=(D_h.*lambda_h_h)+(D_c.*lambda_c_h)+(D_n.*lambda_n_h);
    v_c=(D_h.*lambda_h_c)+(D_c.*lambda_c_c)+(D_n.*lambda_n_c);
    delta_v_h=(D_h.*(lambda_h_h_1-lambda_h_h_0))+(D_c.*(lambda_c_h_1-lambda_c_h_0))+(D_n.*(lambda_n_h_1-lambda_n_h_0));
    delta_v_c=(D_h.*(lambda_h_c_1-lambda_h_c_0))+(D_c.*(lambda_c_c_1-lambda_c_c_0))+(D_n.*(lambda_n_c_1-lambda_n_c_0));
    dlambda_h_h=(lambda_h_h_1-lambda_h_h_0);
    dlambda_h_c=(lambda_h_c_1-lambda_h_c_0);
    dlambda_c_h=(lambda_c_h_1-lambda_c_h_0);
    dlambda_c_c=(lambda_c_c_1-lambda_c_c_0);
    dlambda_n_h=(lambda_n_h_1-lambda_n_h_0);
    dlambda_n_c=(lambda_n_c_1-lambda_n_c_0);
    
    %%%Save output;
    output=[hsis_childid ...
            psi_h_0 psi_h_1 psi_h psi_c rho ...
            lambda_h_h lambda_h_c lambda_c_h lambda_c_c lambda_n_h lambda_n_c ...
            v_h v_c delta_v_h delta_v_c ...
            dlambda_h_h dlambda_h_c dlambda_c_h dlambda_c_c dlambda_n_h dlambda_n_c ...
            w_nc v_h_nc v_c_nc ...
            w_cc v_h_cc v_c_cc ...
            w_nnt v_h_nnt v_c_nnt ...
            w_cnt v_h_cnt v_c_cnt ...
            w_at v_h_at v_c_at ...
            T_i];
    dlmwrite('output.csv', output, 'delimiter', ',', 'precision', 9);  
    
    
end;
     
        
        
    