function  image = patch2image(coldata,imsize,stride)
%patch2image
% coldata: Data obtained using image2cols
% imsize: The width and height of the original image, such as (500, 500)
% stride: The step size during image segmentation, such as 32
patch_size = size(coldata);
patch_size = patch_size(1:2);
range_y = 1:stride:(imsize(1) - patch_size(1));
range_x = 1:stride:(imsize(2) - patch_size(2));
if range_y(end) ~= imsize(1) - patch_size(1)+1
    range_y = [range_y,imsize(1) - patch_size(1)+1];
end
if range_x(end) ~= imsize(2) - patch_size(2)+1
    range_x = [range_x,imsize(2) - patch_size(2)+1];
end
if length(size(coldata)) == 3
    %## 初始化灰度图像;
    res = zeros(imsize);
    w = zeros(imsize);
    index = 1;
    for y = range_y
        for x = range_x
            res(y:(y+patch_size(1)-1),x:(x+patch_size(2)-1)) = ...
                res(y:(y+patch_size(1)-1),x:(x+patch_size(2)-1)) +...
                coldata(:,:,index);
            w(y:(y+patch_size(1)-1),x:(x+patch_size(2)-1)) = ...
                w(y:(y+patch_size(1)-1),x:(x+patch_size(2)-1)) + 1;
            index = index + 1;
        end
    end
end
if length(size(coldata)) == 4
    %## 初始化RGB图像
    res = zeros([imsize,3]);
    w = zeros([imsize,3]);
    index = 1;
    for y = range_y
        for x = range_x
            res(y:(y+patch_size(1)-1),x:(x+patch_size(2)-1),:) = ...
                res(y:(y+patch_size(1)-1),x:(x+patch_size(2)-1),:) +...
                coldata(:,:,:,index);
            w(y:(y+patch_size(1)-1),x:(x+patch_size(2)-1),:) = w(y:(y+patch_size(1)-1),x:(x+patch_size(2)-1),:) + 1;
            index = index + 1;
        end
    end
end
image = res ./ w;
end