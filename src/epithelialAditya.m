[image_data,y_labels,filename, imgx, imgy, numcolors] = load_data('../new_pictures_data/modified_data4/',1);

numclusters = 5;
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
filters = [];
filters = cat(3,filters,F(:,:,38));
filters = cat(3,filters,F(:,:,39));
filters = cat(3,filters,F(:,:,41));
filters = cat(3,filters,F(:,:,42));
filters = cat(3,filters,F(:,:,44));
filters = cat(3,filters,F(:,:,45));
filters = cat(3,filters,F(:,:,47));
filters = cat(3,filters,F(:,:,48));

% store the filtered images for cluster matching later
filt_images = [];
cluster_images  = [];

numimages = 5;

for i=1:numimages
    image = image_data(:,i);
    image = reshape(image,imgx,imgy,numcolors);
    % write the filtered clusters;
    image_g = rgb2gray(image);    
    % will convert each pixel into 8-dimensional. write 8-dim clusters
    filt_i = getLMfilterResponse(image_g,filters);
    filt_images = cat(4,filt_images,filt_i);
    idx = kmeans(filt_i,numclusters,'MaxIter',numiters);
    cluster_image = reshape(idx,imgx,imgy);
    cluster_images = cat(3,cluster_images,cluster_image);
    % write the cluster image for visual inspection
    imwrite(cluster_image,cmap,strcat(basepath_filter_clusters,filename{i}));
end
% save the cluster images and the filter images as matfiles
save(strcat(basepath_clusters_matfiles,'/cluster_images.mat'),'cluster_images');
save(strcat(basepath_clusters_matfiles,'/filt_images.mat'),'filt_images');
save(strcat(basepath_clusters_matfiles,'/filename.mat'),'filename');

