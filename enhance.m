clear
close all
addpath('bm3d');
addpath('NoiseEstimation')
addpath('utils')
addpath('RTV')

para.alpha = 0.1;%α
para.beta = 0.01;%β
para.delta = 1000;%δ
para.maxiter = 20;%K
para.vareps = 1e-2;%ɛ
para.debug = true;

v=0.55;
l=0.6;
h=1.8;

dataset0="./input/high/";
dataset1="./input/low/";

files0 = dir(dataset0+"*.png");   
files1 = dir(dataset1+"*.png"); 

for j = 1
    img0 = im2double(imread(dataset0+files0(j).name));%normal-light
    img1 = im2double(imread(dataset1+files1(j).name));%low-light

    %Initial enhancement
    hsvI=rgb2hsv(img1);
    gamma=log10(0.3)/log10(mean2(hsvI(:,:,3))); 
    if(gamma>1) 
        gamma=1; 
    end
    hsvI(:,:,3)=hsvI(:,:,3).^gamma; 
    E0=hsv2rgb(hsvI);  
    S0=tsmooth(E0,0.015,3);
 
    S00=S0;
    
    nSig=NoiseEstimation(E0,5);
    if(nSig>0.06)
        para.delta=0.5;
    else
        para.delta=1000;
    end
    
    %Target noise histogram statistics
    var1=0.002;
    N_target=var1^0.5*randn(size(img1));
    [C0,edges0] = histcounts(N_target,2000,'Normalization','cdf');
    [C,ia,ic]=unique(C0);
    C0=[0,C];
    C0(1,end)=1; %Make sure the range is within [0,1]
    edges01=edges0(2:end);
    edges0=[edges0(1),edges01(ia)];
 
    noise_type =  'gw';
    noise_var = var1;
    seed = 0;
    [~, PSD1, ~] = getExperimentNoise(noise_type, noise_var, seed, size(img1));
  
    noise_var = 0.001;
    seed = 0;
    [~, PSD2, ~] = getExperimentNoise(noise_type, noise_var, seed, size(img1));
    rng('default') 
    if(nSig>0.1)
        N_add=0.0002^0.5*randn(size(img1)); 
    else
        % N_add=0.00001^0.5*randn(size(img1)); %for LOL
        N_add =0.0001^0.5*randn(size(img1)); %for SDSD
    end

    maxiter1=3; 
    N2=zeros(size(img1));
    for iter=1:maxiter1
        hsvI=rgb2hsv(S0);
        hsvI(:,:,3)=hsvI(:,:,3).^(1/gamma);
        S_low=hsv2rgb(hsvI);
        if(iter==1)
            S_low0=S_low;
        end
        N1=img1-S_low;
        N1=N1+N_add;%Noise is added for robustness, optionally not
        
        %Noise transformation
        for ch=1:size(img1,3)
           N2(:,:,ch)=Noise_trans(N1(:,:,ch),C0,edges0);
        end

        Nimg2=S0+N2;
        Nimg2(Nimg2<0)=0;
        Nimg2(Nimg2>1)=1;
        
        if(iter==maxiter1) 
            var_es=NoiseEstimation(Nimg2,5).^2;
            noise_type =  'gw';
            noise_var = var_es; % Noise variance000
            seed = 0;
            [noise, PSD, kernel] = getExperimentNoise(noise_type, noise_var, seed, size(img1));
            T_map = CBM3D(Nimg2, PSD);
            T_map(T_map<0)=0;
            T_map(T_map>1)=1;
            break;
        end
  
        if(iter==1)
            [T_map,blocks] = CBM3D1(Nimg2, PSD1,'np','opp',true,0);
        else
            T_map = CBM3D1(Nimg2, PSD1,'np','opp',false,blocks);
        end
        T_map(T_map<0)=0;
        T_map(T_map>1)=1;

        %Texture transformation
        T2=T_map-S0;
        X=T2./N2;
        T1=N1.*X;
        T1(X>1|X<-1)=T2(X>1|X<-1);
        S0=S0+T1;
        S0(S0<0)=0;
        S0(S0>1)=1;
        S0 = CBM3D1(S0, PSD2,'np','opp',false,blocks);
    end
 
    %STGV
    S_map=S00;
    [I,R,N_target]=STGV(img1,para,S_map,(T_map-S_map));
    I_en=I.^(1/2.2);
    E1=R.*I_en;  
    
    %AIC
    T31=AIC(img1(:,:,1),v,l,h);
    T32=AIC(img1(:,:,2),v,l,h);
    T33=AIC(img1(:,:,3),v,l,h);
    E2=cat(3,T31,T32,T33);
    hsvI=rgb2hsv(img1);
    hsvI(:,:,3)=AIC(hsvI(:,:,3),v,l,h);
    E3=hsv2rgb(hsvI);     
    E2=E2.*(1-S_low0)+E3.*S_low0;

    %Integration
    S1=S_estimate(E1,0.03,3);
    S2=S_estimate1(E2,0.015,3,T_map);
    F=S2+E1-S1;%default

    %Higher contrast result
    S21=S_estimate1(E2,0.015,3,F);
    F1=S21+E1-S1;

    psnr(F,img0)
    ssim(F,img0)

    figure; imshow([E1,E2]); title('STGV & AIC');
    figure; imshow([img1,F]); title('input & output');

    % Save results
    % imwrite(E1,".\output\E1\"+files1(j).name)
    % imwrite(E2,".\output\E2\"+files1(j).name)
    % imwrite(T_map,".\output\T_map\"+files1(j).name)
    % imwrite(F,".\output\F\"+files1(j).name)
   
end


