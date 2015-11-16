function write_patches( patch_data, patch_coords, filenames, patch_x, patch_y, numcolors, base_path )
%Writes all the patches for all the image files
    [numimages,~] = size(patch_data);
    for i=1:1:numimages
        [~,patch_file_base,~] = fileparts(filenames{i});
        image_patches = patch_data{i};
        patch_coord = patch_coords{i};
        [~,npatches] = size(image_patches);
        for j=1:1:npatches
            image_patch = image_patches(:,j);
            image_patch = reshape(image_patch,patch_x,patch_y,numcolors);
            patch_index_str = strcat(int2str(patch_coord(j,1)),'_',int2str(patch_coord(j,2)));
            patch_filename = strcat(base_path,'/',patch_file_base,'_',patch_index_str,'.tiff');
            imwrite(image_patch,patch_filename);
        end
    end
end

