function [res] = image2patch(image,patch_size,stride)
%
% image: The image that needs to be split into image blocks
% patch_size: The size of the image block, such as :(10,10)
% stride: The step size moved when splitting an image block, for example :5
if length(size(image)) == 2
    [imhigh,imwidth] = size(image);
end
if length(size(image)) == 3
    [imhigh,imwidth,imch] = size(image);
end

range_y = 1:stride:(imhigh - patch_size(1));
range_x = 1:stride:(imwidth - patch_size(2));

range_y = [range_y,imhigh - patch_size(1)+1];
range_x = [range_x,imwidth - patch_size(2)+1];

sz = length(range_y) * length(range_x);
if length(size(image)) == 2
    res = zeros(patch_size(1),patch_size(2),sz);
    index = 1;
    for y = range_y
        for x = range_x
            patch = image(y:y+patch_size(1)-1,x:x+patch_size(2)-1);
            res(:,:,index) = patch;
            index = index + 1;
        end
    end
end
if length(size(image)) == 3
    res = zeros(patch_size(1),patch_size(2),imch,sz);
    index = 1;
    for y = range_y
        for x = range_x
            patch = image(y:y+patch_size(1)-1,x:x+patch_size(2)-1,:);
            res(:,:,:,index) = patch;
            index = index + 1;
        end
    end
end