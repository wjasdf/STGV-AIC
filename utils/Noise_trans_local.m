function N2 = Noise_trans_local(N1,C0,edges0,blocksize,step)
%Transform noise distribution via histogram matching
%Input
% N1: origianl noise; C0: target noise
% blocksize: size of the image block, step: The step size moved when splitting an image block
%Output
% N2: Transformed noise
interval=0.001;
left=min(N1(:));
right=max(N1(:))+interval;
edges =left:interval:right;
blocks_N1=image2patch(N1,[blocksize,blocksize],step);
[H1, W1, C1, N_blocks] = size(blocks_N1);

blocks1 = reshape(permute(blocks_N1, [1, 2, 4, 3]), [H1*W1, N_blocks, C1]);
Y=1:N_blocks;
Y1=repmat(Y,H1*W1,1)-1;
his_cdf_all=zeros(N_blocks,size(edges,2)-1,size(N1,3));
for ch=1:size(N1,3)
    [his_cdf_all1,~,~] = histcounts2(Y1,blocks1(:,:,ch),0:1:N_blocks,edges);
    his_cdf_all(:,:,ch)=his_cdf_all1;
end
his_cdf_all=his_cdf_all./(H1*W1);
his_cdf_all=cumsum(his_cdf_all,2);
A=zeros(size(his_cdf_all,1),1,size(N1,3));
his_cdf_all=[A his_cdf_all];

X=double(edges);
Yq=repmat(Y,H1*W1,1);
blocks1_cdf=zeros(size(blocks1));
for ch=1:size(N1,3)
    V=his_cdf_all(:,:,ch);
    Xq=blocks1(:,:,ch);
    blocks1_cdf(:,:,ch) = interp2(X,Y,V,Xq,Yq);
end

blocks1_trans= interp1(C0,edges0,blocks1_cdf);

blocks2 = reshape(blocks1_trans, [H1, W1, N_blocks, C1]);
blocks_N2 = permute(blocks2, [1, 2, 4, 3]);

Size0=size(N1);
N2=patch2image(blocks_N2,[Size0(1),Size0(2)],step);

end

