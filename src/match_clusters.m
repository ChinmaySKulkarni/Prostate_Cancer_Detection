% match the seed cluster in all the other images. Must be run after
% epithelialAditya has been run.

% load the cluster images and the filtered images from matfiles

seed_cluster_no  = 1;  % cluster no corresponding to the cluster of epithelial cells
seed_cluster_image_name = '1_green.tif'; % reference image name for cluster matching
basepath_clusters_matfiles = '../new_pictures_data/kmeans_LMF_8/cluster_matfiles/';
basepath_segment_files = '../new_pictures_data/kmeans_LMF_8/cluster_masks/';
mkdir(basepath_segment_files);

% process each cluster file and filter image file in the directory
cluster_filenames = dir(fullfile(basepath_clusters_matfiles,'*_cluster.mat'));
filter_filenames = dir(fullfile(basepath_clusters_matfiles,'*_filt.mat'));
numfiles = length(cluster_filenames);

% load the seed cluster image name
load(strcat(basepath_clusters_matfiles,seed_cluster_image_name,'_cluster.mat'));
seed_cluster_img = cluster_image;
load(strcat(basepath_clusters_matfiles,seed_cluster_image_name,'_filt.mat'));
seed_filt_img = filt_image;
seed_cluster_mask = zeros(size(seed_cluster_img));
seed_cluster_mask(seed_cluster_img==seed_cluster_no)=1;

% process each image and calculate its matching cluster and cluster segmented
% image
for i=1:numfiles
  cluster_filename = cluster_filenames(i).name;
  filt_filename = filter_filenames(i).name;
  if strcmp(cluster_filename,'.')==1 || strcmp(filt_filename,'.')==1 ||...
     strcmp(cluster_filename,'..')==1 || strcmp(filt_filename,'..')==1 
    continue;
  end
  s = regexp(cluster_filename,'_cluster.mat');
  image_file_name = cluster_filename(1:s-1);
  load(strcat(basepath_clusters_matfiles,cluster_filename));
  load(strcat(basepath_clusters_matfiles,filt_filename));
  if strcmp(seed_cluster_image_name,image_file_name)~=1
     %matched_cluster_mask = identifyCluster(seed_cluster_mask,cluster_image,...
     %seed_filt_img,filt_image,8);
     matched_cluster_mask = identifyEpithelialCluster(cluster_image,8);
     figure;
     imshow(matched_cluster_mask);
     imwrite(matched_cluster_mask,strcat(basepath_segment_files,image_file_name));
  else
     imwrite(seed_cluster_mask,strcat(basepath_segment_files,seed_cluster_image_name));
  end
end

% create the binary cluster mask for the refernece image
