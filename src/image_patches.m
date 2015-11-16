function [ patch_image,patch_coord, numskipped] = image_patches( input_image, patch_x, patch_y, bg_image )
%IMAGE_PATCHES Summary of this function goes here
%   Detailed explanation goes here
    [imgy, imgx , numcolors ] = size(input_image);
    patch_image = [];
    patch_coord = [];
    numskipped = 0;
    bg_image = im2double(bg_image);
    bg_image_avg = zeros(1,numcolors);
    for i=1:numcolors
        color_image = bg_image(:,:,i);
        bg_image_avg(i) = mean(color_image(:));
    end
    bg_image = reshape(bg_image, patch_x*patch_y*numcolors,1);
    for i=1:patch_x:imgy
        for j=1:patch_y:imgx
            patch_endi = min(i+patch_x-1,imgy);
            patch_endj = min(j+patch_y-1,imgx);
            patchy_len = patch_endi - i +1;
            patchx_len = patch_endj - j +1;
            patch = input_image(i:patch_endi,j:patch_endj,:);
            if patchx_len < patch_x
                z = ones(patchy_len,patch_x-patchx_len,numcolors);
                for k=1:numcolors
                    z(:,:,k) = bg_image_avg(k)*z(:,:,k);
                end
                patch = [patch, z];
            end
            if patchy_len < patch_y
                z = ones(patch_y-patchy_len,patch_x,numcolors);
                for k=1:numcolors
                    z(:,:,k) = bg_image_avg(k)*z(:,:,k);
                end
                patch = [patch; z];
            end
            [x, y, z] = size(patch);
            patch = reshape(patch,x*y*z,1);
            mod1 = sqrt(patch'*patch);
            mod2 = sqrt(bg_image'*bg_image);
            dot_product = (patch'*bg_image)/(mod1*mod2);
            if abs(dot_product-1)<0.001
                numskipped = numskipped+1;
            else 
               patch_image = [patch_image, patch];
               patch_coord = [patch_coord; [i,j]];
            end
        end
    end
end

