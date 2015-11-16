function [ patch_data, patch_coord ] = patch_all_images(image_data,img_x,img_y,numcolors,patch_x,patch_y,bg_image)
% generate the image patches for all the images and stack them in a
% matrix; returns a matrix of dimensions :
% vectorized_patch_dim*num_patches_per_image*num_images
    [~, numimages] = size(image_data);
    patch_data = cell(numimages,1);
    patch_coord = cell(numimages,1);
    for i=1:1:numimages
        image_i = image_data(:,i);
        image_i = reshape(image_i,img_x,img_y,numcolors);
        [image_patch,patch_c,numskipped] = image_patches(image_i,patch_x,patch_y,bg_image);
        %{
        figure;
        stem(products);
        [~, npatches] = size(image_patch);   
        filenames = num2cell(num2str(1:npatches));
        figure;
        show_data(image_patch,filenames,patch_x,patch_y,numcolors);
        %}
        patch_data{i} = image_patch;
        patch_coord{i} = patch_c;
    end
end

