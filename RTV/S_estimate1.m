function S=S_estimate1(im,alpha1,sigma,G)
if (~exist('sigma','var'))
    sigma=3;
end
if(size(im,3)==1)
    [wx,wy]=computeTextureWeights(G(:,:,1),sigma);
    S(:,:,1)=solveLinearEquation(im(:,:,1),wx,wy,alpha1);
else
    [wx,wy]=computeTextureWeights(G(:,:,1),sigma);
    S(:,:,1)=solveLinearEquation(im(:,:,1),wx,wy,alpha1);
    
    [wx,wy]=computeTextureWeights(G(:,:,2),sigma);
    S(:,:,2)=solveLinearEquation(im(:,:,2),wx,wy,alpha1);

    [wx,wy]=computeTextureWeights(G(:,:,3),sigma);
    S(:,:,3)=solveLinearEquation(im(:,:,3),wx,wy,alpha1);
end

end

function[retx,rety]=computeTextureWeights(fin,sigma)
    vareps_s=0.02;
    vareps=0.001;
    fx=diff(fin,1,2);
    fx=padarray(fx,[0,1],'post');
    fy=diff(fin,1,1);
    fy=padarray(fy,[1,0],'post');

    wtox=max(abs(fx),vareps_s).^(-1);
    wtoy=max(abs(fy),vareps_s).^(-1);

    fbin=conv2_sep(fin,sigma);
    gfx=diff(fbin,1,2);
    gfx=padarray(gfx,[0,1],'post');
    gfy=diff(fbin,1,1);
    gfy=padarray(gfy,[1,0],'post');
    wtbx=max(abs(gfx),vareps).^(-1);
    wtby=max(abs(gfy),vareps).^(-1);
    retx=wtbx.*wtox;
    rety=wtby.*wtoy;
   
    retx(:,end)=0;
    rety(end,:)=0;
end

function ret=conv2_sep(im,sigma)
    ksize=bitor(round(5*sigma),1);
    g=fspecial('gaussian',[1,ksize],sigma);
    ret=conv2(im,g,'same');
    ret=conv2(ret,g','same');
end

function OUT=solveLinearEquation(IN,wx,wy,lambda)
    [r,c]=size(IN);
    k=r*c;
    dx=-lambda*wx(:);
    dy=-lambda*wy(:);
    B(:,1)=dx;
    B(:,2)=dy;
    d=[-r,-1];
    A=spdiags(B,d,k,k);
    e=dx;
    w=padarray(dx,r,'pre');w=w(1:end-r);
    s=dy;
    n=padarray(dy,1,'pre');n=n(1:end-1);
    D=1-(e+w+s+n);
    A=A+A'+spdiags(D,0,k,k);
    L=ichol(A,struct('michol','on'));
    [tout,~]=pcg(A,IN(:),0.1,max(min(lambda*100,40),10),L,L');
    OUT=reshape(tout,r,c);
end
