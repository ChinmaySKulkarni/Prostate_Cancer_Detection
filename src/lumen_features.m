function [lumen_features] = lumen_features(lumen_images,filenames,epithileal_images,imgx,imgy)
% Creates the following basic features from the segmented lumen images :
    
    pruned_image_path = '../new_pictures_data/pruned_data4/';
    mkdir(pruned_image_path);

    [~, numimages]=size(lumen_images);
    % image gloabl features
    num_lumen_objects = [];
    fraction_lumen_area = [];
    % size based features are average right now, will change
    % to distribution later
    avg_eccentricity = [];
    var_eccentricity = [];
    avg_lumen_size = [];
    var_lumen_size = [];
    avg_circularity = [];
    var_circularity = [];
    avg_lumen_radius = [];
    var_lumen_radius = [];
    % epithilial cell based features
    fraction_ep_bound = [];
    fraction_ep_image = [];
    
    % construct the mask image
    mask_image = ones(imgx,imgy);
    mindim = min([imgx,imgy]);
    params = floor([imgy/2, imgx/2, mindim/2]);
    shapeInserter = vision.ShapeInserter('Shape','Circles','Fill',true);
    mask_image = step(shapeInserter,mask_image,params);
    mask_image = im2double(mask_image);
    mask_image = im2bw(mask_image,0.5);
    mask_image = 1-mask_image;
    mask_image = logical(mask_image);
    
    for i=1:numimages
        image = lumen_images(:,i);
        image = reshape(image,imgx,imgy);
        %figure;
        %imshow(image)
       
        % remove the largest connected components that correspond to the 
        % image corners
        % image = image.*mask_image;
        cc = bwconncomp(image);
        lumen_area = cellfun(@numel,cc.PixelIdxList);
        [lumen_area, sort_idx] = sort(lumen_area);
        area_thresh = (imgx*imgy/4)-(pi*imgx*imgx/16);
        num_remove = 0;
        for k=numel(lumen_area):-1:1
            if lumen_area(k) > 0.9*area_thresh 
                num_remove = num_remove+1;
            end
        end
        keep_idx = sort_idx(1:end-num_remove);
        image = ismember(labelmatrix(cc),keep_idx);
        
        % recalculate the connected components
        %figure; 
        pruned_write_path = strcat(pruned_image_path,filenames{i});
        imwrite(image,pruned_write_path);
        cc = bwconncomp(image);
        stats = regionprops(cc,'Area','Centroid','Eccentricity','Perimeter','PixelIdxList','Extrema','Image');
        numlumen = numel(stats);
        l_size_stats = zeros(numlumen,1);
        l_circ_stats = zeros(numlumen,1);
        l_ecc_stats = zeros(numlumen,1);
        l_radius_stats = zeros(numlumen,1);
        % for each lumen in the image , calculate the above features;
        for j=1:numlumen
            l_size_stats(j) = stats(j).Area;
            l_circ_stats(j) = (stats(j).Perimeter)^2/(4*stats(j).Area*pi);
            l_ecc_stats(j) = stats(j).Eccentricity;
            % get the lumen boundary and calculate the average radius of a 
            % lumen object
            boundary_image = zeros(imgx,imgy);
            boundary_image(stats(j).PixelIdxList) = 1;
            perim_image = bwperim(boundary_image);
            boundary_pix_idx = find(perim_image==1);
            [boundary_pix_y, boundary_pix_x] = ind2sub(size(perim_image),boundary_pix_idx);
            boundary_pix = [boundary_pix_x, boundary_pix_y];
            boundary_pix = boundary_pix-repmat(stats(j).Centroid, size(boundary_pix,1),1);
            radii = boundary_pix(:,1).^2 + boundary_pix(:,2).^2;
            avg_radius = mean(radii(:));
            l_radius_stats(j) = avg_radius;
        end

        % image global features
        num_lumen_objects = [num_lumen_objects,numlumen];
        fraction_lumen_area = [fraction_lumen_area, sum(l_size_stats(:))/(imgx*imgy)];
        
        % lumen size features
        avg_lumen_size = [avg_lumen_size mean(l_size_stats(:))];
        var_lumen_size = [var_lumen_size, var(l_size_stats(:))];
        avg_eccentricity = [avg_eccentricity, mean(l_ecc_stats(:))];
        var_eccentricity = [var_eccentricity, var(l_ecc_stats(:))];
        avg_circularity = [avg_circularity , mean(l_circ_stats(:))];
        var_circularity = [var_circularity , var(l_circ_stats(:))];
        avg_lumen_radius = [avg_lumen_radius, mean(l_radius_stats(:))];
        var_lumen_radius = [var_lumen_radius, var(l_radius_stats(:))];
        
        %epithileal features
        ep_image = epithileal_images(:,i);
        ep_image = reshape(ep_image,imgx,imgy);
        [f1, f2] = process_lumen(image,ep_image);
        fraction_ep_bound = [fraction_ep_bound,f1];
        fraction_ep_image = [fraction_ep_image,f2];
        
    end
    
    lumen_features = [  num_lumen_objects;...
                        fraction_lumen_area;...
                        avg_lumen_size;...
                        var_lumen_size;...
                        avg_eccentricity;...
                        var_eccentricity;...
                        avg_circularity;...
                        var_circularity;...
                        avg_lumen_radius;...
                        var_lumen_radius;...
                        fraction_ep_bound;...
                        fraction_ep_image
                     ];
end

    
