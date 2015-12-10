[image_data,y_labels,filename, imgx, imgy, numcolors] = load_data('../new_pictures_data/modified_data4/',1);

numclusters = 3;
basepath_filter_clusters = strcat('../new_pictures_data/kmeans_LMF_',int2str(numclusters),'/');
mkdir(basepath_filter_clusters);

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

goodness_vals = [];

for i=1:numimages
    image = image_data(:,i);
    image = reshape(image,imgx,imgy,numcolors);
    % write the filtered clusters;
    image_g = rgb2gray(image);
    
    % will convert each pixel into 8-dimensional. write 8-dim clusters
    filt_i = getLMfilterResponse(image_g,filters);
    idx = kmeans(filt_i,numclusters,'MaxIter',numiters);
    [s,~] = silhouette(filt_i,idx,'cityblock');
    goodness_vals = [goodness_vals,mean(s)];
    cluster_image = reshape(idx,imgx,imgy);
    imwrite(cluster_image,cmap,strcat(basepath_filter_clusters,filename{i}));
    
    % write the raw clusters
    %{
    image = reshape(image,imgx*imgy,numcolors);
    idx = kmeans(image,numclusters);
    cluster_image = reshape(idx,imgx,imgy);
    imwrite(cluster_image,cmap,strcat(basepath_raw_clusters,filename{i}));
    %}
end
numclusters
goodness = mean(goodness_vals)

% spectral clustering based approach, didn't work because computationally
% infeasible.
% compute the affinity matrix (getting too big for an image,
% impractical)!!
%{
numpoints = size(trans_data,1);
affinity = zeros(numpoints,numpoints);
sigma = 1;
for i=1:numpoints
    for j=1:numpoints
        v1 = trans_data(i,:);
        v2 = trans_data(j,:);
        v = v1-v2;
        v_mod = v*v';
        affinity(i,j) = exp(-v_mod);
    end
end

% calculate the cluster centers;
[C,~,~] = SpectralClustering(affinity,8,3);
C;
%}


