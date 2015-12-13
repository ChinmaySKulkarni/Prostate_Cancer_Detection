% This script reads the contrast enahanced images from the folder passed in
%  to load data and creates the corresponding cluster and filter response
%  images in the basepath_filter_clusters and basepath_clusters_matfiles
%  folder

[image_data,y_labels,filename, imgx, imgy, numcolors] = load_data('../new_pictures_data/modified_data4/',1);


numclusters = 8;
basepath_filter_clusters = strcat('../new_pictures_data/kmeans_LMF_',int2str(numclusters),'/');
mkdir(basepath_filter_clusters);
basepath_clusters_matfiles = strcat('../new_pictures_data/kmeans_LMF_',int2str(numclusters),'/cluster_matfiles/');
mkdir(basepath_clusters_matfiles);

numimages = size(image_data,2);
numiters = 500;
cmap = colormap(jet);
n = size(cmap,1);
cmap = cmap(1:floor(n/(numclusters-1)):n,:);

% calculate the filters
F=getLMfilters();
filters_to_keep = [38,39,41,42,44,45,47,48];
filters = F(:,:,filters_to_keep);

% store the filtered images for cluster matching later
filt_images = [];
cluster_images  = [];

for i=1:numimages
    image = image_data(:,i);
    image = reshape(image,imgx,imgy,numcolors);
    image_g = rgb2gray(image);    
    % will convert each pixel into 8-dimensional. 
    filt_i = getLMfilterResponse(image_g,filters);
    % write the filter image to matfile
    save(strcat(basepath_clusters_matfiles,filename{i},'_filt.mat'),'filt_image');
    idx = kmeans(filt_i,numclusters,'MaxIter',numiters);
    cluster_image = reshape(idx,imgx,imgy);
    % write the cluster image to matfile
    save(strcat(basepath_clusters_matfiles,filename{i},'_cluster.mat'),'cluster_image');
    % write the cluster image for visual inspection
    imwrite(cluster_image,cmap,strcat(basepath_filter_clusters,filename{i}));
end

