% match the seed cluster in all the other images. Must be run after
% epithelialAditya has been run.

% load the cluster images and the filtered images from matfiles

basepath_clusters_matfiles = strcat('../new_pictures_data/kmeans_LMF_',int2str(numclusters),'/cluster_matfiles/');
basepath_filter_clusters = strcat('../new_pictures_data/kmeans_LMF_',int2str(numclusters),'/cluster_masks/');
mkdir(basepath_filter_clusters);
load(strcat(basepath_clusters_matfiles,'cluster_images.mat'));
load(strcat(basepath_clusters_matfiles,'filt_images.mat'))
load(strcat(basepath_clusters_matfiles,'filename.mat'));

seed_cluster_no  = 1;  % cluster no corresponding to the cluster of epithelial cells
seed_cluster_image_name = '1_green.tif'; % reference image name for cluster matching


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
