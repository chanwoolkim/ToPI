
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Chris Walters %%%%%%%%%%%%%%%%%%%
%%%%%%%% 1/28/2016  %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% This program estimates the %%%%%%
%%%%%%%%% MN Probit finite type FE model %
%%%%%%%%% in bootstrap samples %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% SET UP MATLAB %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%Set randomization seed and number of trials;
        core = str2num(getenv('i'));
        rng(core);
        B_min=1;
        B_max=10;
    
    %%%Choose parameters;
    
        %fminunc options;
        options_fmin=struct('Display','iter','Algorithm','active-set','MaxFunEvals',10000,'MaxIter',500,'GradObj','on','LargeScale','off','TolFun',1e-6);
        
        %Simulation draws;
        R=300;
        
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
    site_dum_full=dummyvar(site_i);
    W=W*(N/sum(W));
    if use_weights~=1;
        W=ones(N,1);
    end;
    
    %%%%Data and parameters to pass to optimizer;   
        data_full=[site_i X Z P W D_dum];
        params=[L L1 LP K R];
   
    
    %%%%Full sample starting values;
        load('sims_final');
        sims_full=sims_final(:,1:R);
        load('start_vals');
        theta_common=start_vals;
        load('T_final');
        T_full=T_final;
        load('start_vals_group');
        theta_group=start_vals_group;
        site_full=site_i;
        
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% ESTIMATE PARAMETERS %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

for b=B_min:B_max;
    
    %%%%%%%%%%%%%% DRAW BOOTSTRAP TRIALS;
    W_bs_site=-log(rand(J,1));
    W_bs=W_bs_site(site_i);
    W_final=W.*W_bs;
    data=[site_i X Z P W_final D_dum];
    sims=sims_full;
    site_dum=site_dum_full;
    
                 
       %%%%Initial values;
        theta_0=[theta_common; theta_group];
        T_current=T_full;
        theta_current=theta_0;
        T_0=T_full;
    
    %%%%%%%%%%% MAXIMIZE OBJECTIVE %%%%%%%%%%%%%%%%%%%%%%%%%
    
                tic
                conv=eps+1;
                logL=-9999999999999;
                while conv>eps;

                    %%%%Maximize likelihood over parameters given type assignments;
                        complete=0;
                        theta_init=theta_current;
                        while complete<1;
                           try;
                                [theta_new Q_hat]=fminunc(@(x)objfn(x,data,T_current,sims,params),theta_init,options_fmin);
                            catch;
                               disp('Warning: Maximization failed. Trying a new point')
                               complete=complete-1;
                               theta_init=[theta_common; randn(4*K*LP,1)];
                            end;
                            complete=complete+1;
                        end;

                    %%%%Get new type assignments to maximize likelihood;

                        %Compute type-specific likelihoods;
                        logL_type=zeros(N,K);
                        for k=1:K;
                            [Qtemp Gtemp logL_temp]=get_Q(theta_new,data,[zeros(N,k-1) ones(N,1) zeros(N,K-k)],sims,params);
                            logL_type(:,k)=logL_temp;
                        end;

                        %Assign max likelihood by site;
                        site_logL=zeros(J,K);
                        for j=1:J;
                            site_logL(j,:)=sum(logL_type(site_dum(:,j)==1,:));
                        end;
                        [maxval maxtype]=max(site_logL,[],2);
                        T_new=zeros(J,K);
                        for k=1:K;
                            T_new(:,k)=(maxtype==k);
                        end;
                        
                    %%%%%Assign new params and check convergence;    
                        conv=-Q_hat-logL
                        logL=-Q_hat
                        mean(T_new)
                        sum(sum(T_new~=T_current))
                        if conv>eps;
                           theta_current=theta_new;
                           T_current=T_new;
                        end;
                end;
        
    %%%%%%%%%%%%%%% STORE RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%
        
                        %%%Display estimates;  

                        common_ests=[theta_common theta_current(1:(2*(L+L1)))]
                        group_ests=[theta_group theta_current((2*(L+L1)+1):end)]
                        group_shares=mean(T_current)

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
                            output=[hsis_childid W_bs ...
                                    psi_h_0 psi_h_1 psi_h psi_c rho ...
                                    lambda_h_h lambda_h_c lambda_c_h lambda_c_c lambda_n_h lambda_n_c ...
                                    v_h v_c delta_v_h delta_v_c...
                                    dlambda_h_h dlambda_h_c dlambda_c_h dlambda_c_c dlambda_n_h dlambda_n_c ...
                                    w_nc v_h_nc v_c_nc ...
                                    w_cc v_h_cc v_c_cc ...
                                    w_nnt v_h_nnt v_c_nnt ...
                                    w_cnt v_h_cnt v_c_cnt ...
                                    w_at v_h_at v_c_at ...
                                    T_i];
                            savename=[];
                            dlmwrite(['output_core' num2str(core) '_trial' num2str(b) '.csv'], output, 'delimiter', ',', 'precision', 9);  
                   

end;
     
        
        
    