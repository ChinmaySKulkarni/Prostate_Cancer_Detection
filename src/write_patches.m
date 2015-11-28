function write_patches( patch_data, patch_coords, filenames, patch_x, patch_y, numcolors, base_path,write_images )
% Writes all the patches for all the image files. patch_data contains the
% stacked vectorized patch data for each image. i.e. the patch data for
% each image is vectorized and the data for various images are stacked on
% top of each other. If write images is 'true' the patch image files are
% written to the destination folder specified by 'base_path', otherwise a
% the data is written in matlab '.mat' form in the base folder., patch_x,
% patch_y control the patch size and filenames and patch_coords identify
% the patch's coordinates in the original image and the filename of the
% original image.

    % save the patch data in the matrix
    [numimages,~] = size(patch_data);
    patch_save_names = cell(1,numimages);
    for i=1:1:numimages
        [~,patch_file_base,~] = fileparts(filenames{i});
        image_patches = patch_data{i};
        patch_coord = patch_coords{i};
        [~,npatches] = size(image_patches);
        patch_save_names{i} = cell(1,npatches);
        for j=1:1:npatches
            image_patch = image_patches(:,j);
            image_patch = reshape(image_patch,patch_x,patch_y,numcolors);
            patch_index_str = strcat(int2str(patch_coord(j,1)),'_',int2str(patch_coord(j,2)));
            patch_filename = strcat(base_path,'/',patch_file_base,'_',patch_index_str,'.tiff');
            if write_images==false
                patch_save_names{i}{j} = [patch_coord(j,1),patch_coord(j,2)];
            else
                imwrite(image_patch,patch_filename);
            end
        end
    end
    if write_images == false
        patch_data_struct = cell(1,2);
        patch_data_struct{1} = patch_data;
        patch_data_struct{2} = patch_save_names;
        patch_data_file = strcat(base_path,'/','patch_data.mat');
        save(patch_data_file,'patch_data_struct');        
    end
end

