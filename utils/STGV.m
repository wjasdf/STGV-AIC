function [I,R,N] = STGV( im, para, S_map, T_map)

alpha=para.alpha;
beta=para.beta;
delta=para.delta;
maxiter=para.maxiter;
debug=para.debug;
vareps=para.vareps;


eps=0.001;

if debug == true
    fprintf('-- Stop iteration until eplison < %02f or Iter > %d\n', vareps, maxiter);
end


%Calculate the weight of I  
Gi1=(S_map(:,:,1)+S_map(:,:,2)+S_map(:,:,3))/3;
Ix = diff(Gi1,1,2); Ix = padarray(Ix, [0 1], 'post');
Iy = diff(Gi1,1,1); Iy = padarray(Iy, [1 0], 'post');

ux = max(abs(Ix),eps).^(-1);
uy = max(abs(Iy),eps).^(-1);
ux(:,end) = 0;%令最后一列为0
uy(end,:) = 0;

%Calculate the weight of R
%R channel
Rx1 = diff(T_map(:,:,1),1,2); Rx1 = padarray(Rx1, [0 1], 'post');
Ry1 = diff(T_map(:,:,1),1,1); Ry1 = padarray(Ry1, [1 0], 'post');

vx1 = max(abs(Rx1),eps).^(-1);
vy1 = max(abs(Ry1),eps).^(-1);

vx1(:,end) = 0;
vy1(end,:) = 0;  

%G channel
Rx2 = diff(T_map(:,:,2),1,2); Rx2 = padarray(Rx2, [0 1], 'post');
Ry2 = diff(T_map(:,:,2),1,1); Ry2 = padarray(Ry2, [1 0], 'post');
vx2 = max(abs(Rx2),eps).^(-1);
vy2 = max(abs(Ry2),eps).^(-1);

vx2(:,end) = 0;
vy2(end,:) = 0; 

%B channel
Rx3 = diff(T_map(:,:,3),1,2); Rx3 = padarray(Rx3, [0 1], 'post');
Ry3 = diff(T_map(:,:,3),1,1); Ry3 = padarray(Ry3, [1 0], 'post');
vx3 = max(abs(Rx3),eps).^(-1);
vy3 = max(abs(Ry3),eps).^(-1);

vx3(:,end) = 0;
vy3(end,:) = 0; 


im=im+0.001;
im_sum=im(:,:,1)+im(:,:,2)+im(:,:,3);

%Initialization
I=im_sum/3;%I0
R=double(ones(size(im)));
N=double(zeros(size(im)));
for iter = 1:maxiter
    preI=I;
    preR=R;
    
    R_sum=R(:,:,1)+R(:,:,2)+R(:,:,3);
    N_sum=N(:,:,1)+N(:,:,2)+N(:,:,3);
    I0=(im_sum-N_sum)./(R_sum);
    I0(R_sum==0)=preI(R_sum==0);
   
    %% Calculate I和R    
    I = Solve_Eq(I0, ux, uy, alpha);  % Eq.(12)
    eplisonI = norm(I-preI, 'fro')/norm(preI, 'fro');   % iterative error of I
    R0=(im-N)./I;
    I1=cat(3,I,I,I);
    R0(I1==0)=preR(I1==0);
   
    R1 = Solve_Eq(R0(:,:,1), vx1, vy1, beta); 
    R2 = Solve_Eq(R0(:,:,2), vx2, vy2, beta);
    R3 = Solve_Eq(R0(:,:,3), vx3, vy3, beta); 
    R=cat(3,R1,R2,R3);
    eplisonR = norm(R-preR, 'fro')/norm(preR, 'fro');   % iterative error of R
    N=(im-R.*I)/(1+delta);
    %% iteration until convergence
    if debug == true
        fprintf('Iter %d: eplisonI = %f; eplisonR = %f\n', iter, eplisonI, eplisonR);
    end
    if(eplisonI<vareps||eplisonR<vareps)
        break;
    end
    if iter>1
    if(eplisonI-pre_eplisonI>0.1||eplisonR-pre_eplisonR>0.1)
        I=preI;
        R=preR;
        break;
    end
    end
    pre_eplisonI=eplisonI;
    pre_eplisonR=eplisonR;
end
I(I<0)=0;
R(R<0)=0;
I=abs(I);
R=abs(R);
end


