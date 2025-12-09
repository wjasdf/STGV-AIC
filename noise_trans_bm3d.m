clear
close all
addpath('./bm3d/')
addpath('./utils\')


dataset0="./input/high/";
files0 = dir(dataset0+"*.png"); 
noise_types=["gauss","uniform","salt&pepper","impulse","bernoulli","poisson","speckle"];
noise_levels=[25,0.3,0.2,0.2,0.2,25,55];

for img_i = 3
    img0 = im2double(imread(dataset0+files0(img_i).name));

    %choose noise type and level
    j=3;
    noise_type=noise_types(j);
    noise_level=noise_levels(j);
    local_flag=false;%whether to perform local histogram matching
    Nimg1=add_noise(img0,noise_type,noise_level);
    
    %Initial noise estimate via image smoothing
    [h,w,c]=size(Nimg1);
    Nimg10(:,:,1)=medfilt2(Nimg1(:,:,1));
    Nimg10(:,:,2)=medfilt2(Nimg1(:,:,2));
    Nimg10(:,:,3)=medfilt2(Nimg1(:,:,3));
    img_smooth=tsmooth(Nimg10,0.015,3);

   
    %Target noise
    sigma_target=15/255;
    rng('default')
    rng(0);
    N0=sigma_target*randn(size(Nimg1));
    rng(10);
    N_add=0.01*randn(size(Nimg1));

    %Target noise histogram statistics
    [C0,edges0] = histcounts(N0,2000,'Normalization','cdf');
    [C,ia,ic]=unique(C0);
    C0=[0,C];
    edges01=edges0(2:end);
    edges0=[edges0(1),edges01(ia)];


    maxiter=3;
    N2=zeros(size(Nimg1));
    for iter=1:maxiter
        N1=Nimg1-img_smooth;
        N1=N1+N_add;

        if ~local_flag
            for ch=1:size(Nimg1,3)
                N2(:,:,ch)=Noise_trans(N1(:,:,ch),C0,edges0);
            end
        else
            N2=Noise_trans_local(N1,C0,edges0,36,32);
        end

        
        N2=fillmissing(N2,"nearest"); 

        Nimg2=img_smooth+N2;
        noise_type0 =  'gw';
        noise_var = sigma_target^2; % Noise variance
        seed = 0;
        [noise, PSD, kernel] = getExperimentNoise(noise_type0, noise_var, seed, size(Nimg1));
        De_img2 = CBM3D(Nimg2, PSD);
        rng('default')
        if(iter==maxiter)
            break;
        end

        %Texture transformation
        T=De_img2-img_smooth;
        X=T./N2;
        T2=N1.*X;
        T2(X>1|X<-1)=T(X>1|X<-1);
        img_smooth1=img_smooth+T2;

        sigma1=std(T2,1,"all");
        noise_type0 =  'gw';
        noise_var = sigma1^2; % Noise variance
        seed = 0;
        [noise, PSD, kernel] = getExperimentNoise(noise_type0, noise_var, seed, size(Nimg1));
        img_smooth = CBM3D(img_smooth1, PSD);
        img_smooth=max(min(img_smooth,1),0);

    end

    

    %Denoise before noise transformation
    noise_type0 =  'gw';
    noise_var = sigma_target^2; % Noise variance
    seed = 0;
    [noise, PSD, kernel] = getExperimentNoise(noise_type0, noise_var, seed, size(Nimg1));
    De_img1 = CBM3D(Nimg1, PSD);
    De_img1=max(min(De_img1,1),0);
    psnr0=psnr(De_img1,img0);
    ssim0=0;
    for x=1:3
      ssim0=ssim0+ssim(De_img1(:,:,x),img0(:,:,x));
    end
    ssim0=ssim0/3;

    De_img2=double(De_img2);
    De_img2=max(min(De_img2,1),0);
    psnr1=psnr(De_img2,img0);
    ssim1=0;
    for x=1:3
      ssim1=ssim1+ssim(De_img2(:,:,x),img0(:,:,x));
    end
    ssim1=ssim1/3;

    subplot(2,2,1),imshow(Nimg1),title("Original noisy image")
    subplot(2,2,2),imshow(Nimg2),title("Transformed noisy image")
    subplot(2,2,3),imshow(De_img1),title("Denoise before noise trans ("+num2str(psnr0, '%.2f')+"/"+num2str(ssim0, '%.2f')+")");
    subplot(2,2,4),imshow(De_img2),title("Denoise after noise trans ("+num2str(psnr1, '%.2f')+"/"+num2str(ssim1, '%.2f')+")");
end