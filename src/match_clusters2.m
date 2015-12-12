% load the cluster images
[cluster_images,y_labels,filename, imgx, imgy, numcolors] = load_grey_data2('../new_pictures_data/kmeans_LMF_8/',1);
% load the original images
[image_data,y_labels,image_filename, imgx, imgy, numcolors] = load_data('../new_pictures_data/data4/',1);

numimages = numel(filename);

% specified manually
seed_cluster_no  = 1;  % cluster no corresponding to the cluster of epithelial cells
seed_cluster_image_name = '1_green.tif'; % reference image name for cluster matching

% create cluster images
cluster_image_data = reshape(cluster_images,imgx,imgy,numimages);

% create the filter images
F=getLMfilters();
filters = [];
filters = cat(3,filters,F(:,:,38));
filters = cat(3,filters,F(:,:,39));
filters = cat(3,filters,F(:,:,41));
filters = cat(3,filters,F(:,:,42));
filters = cat(3,filters,F(:,:,44));
filters = cat(3,filters,F(:,:,45));
filters = cat(3,filters,F(:,:,47));
filters = cat(3,filters,F(:,:,48));
filt_images = [];
for i=1:numimages
    image_g = image_data(:,i);
    image_g = reshape(image_g,imgx,imgy,numcolors);
    image_g = rgb2gray(image_g);
    filt_images = cat(4,filt_images,getLMfilterResponse(image_g,filters));
end


% identify the index of the reference image
seed_cluster_img_idx = 0; 
for i=1:numimages
    if strcmp(filename{i},seed_cluster_image_name)==1
        seed_cluster_img_idx = i;
        break;
    end
end

% create the binary cluster mask for the refernece image
seed_cluster_img = cluster_images(:,:,seed_cluster_img_idx);
seed_filt_img = filt_images(:,:,:,seed_cluster_img_idx);
seed_cluster_mask = zeros(imgx,imgy);
seed_cluster_mask(seed_cluster_img==seed_cluster_no)=1;
for i=1:numimages
    if i~=seed_cluster_img_idx
       matched_cluster_mask = identifyCluster(seed_cluster_mask,cluster_images(:,:,i),...
       seed_filt_img,filt_images(:,:,:,i));
       imwrite(strcat(basepath_filter_clusters,'/selected_cluster/',filename{i}),matched_cluster_mask);
    else
       imwrite(strcat(basepath_filter_clusters,'/selected_cluster/',filename{i}),seed_cluster_mask);
    end
end