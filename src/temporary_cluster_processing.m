% Run this file, point it to the aggregated cluster file and the aggregated
% filenames file to split the big cluster file into small individual files.

basepath_clusters_matfiles = '../new_pictures_data/kmeans_LMF_8/cluster_matfiles/';
load(strcat(basepath_clusters_matfiles,'cluster_images.mat'));
load(strcat(basepath_clusters_matfiles,'filename.mat'));

[image_data,y_labels,image_filename, imgx, imgy, numcolors] = load_data('../new_pictures_data/modified_data4/',1);

numimages = size(image_data,2);

F=getLMfilters();
filters_to_keep = [38,39,41,42,44,45,47,48];
filters = F(:,:,filters_to_keep);

for i=1:numimages
    image = image_data(:,i);
    image = reshape(image,imgx,imgy,numcolors);
    image_g = rgb2gray(image);
    filt_image =  getLMfilterResponse(image_g,filters);
    cluster_image = cluster_images(:,:,i);
    save(strcat(basepath_clusters_matfiles,filename{i},'_filt.mat'),'filt_image');
    save(strcat(basepath_clusters_matfiles,filename{i},'_cluster.mat'),'cluster_image');
end