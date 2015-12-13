function [ identified_cluster ] = identifyEpithelialCluster(input_cluster_image, numclusters )
% Identifies the cluster number corresponding to the epithelial cells and
% returns the binarized mask image for that cluster. This is done by doing
% a hough transform on each of the cluster images and checking which image
% has the highest number of ellipses
    [imgx,imgy] = size(input_cluster_image);
    params.minMajorAxis = 20;
    params.minMinorAxis = 15;
    params.uniformWeights = true;
    params.randomize = 0;
    params.rotationSpan = 89;
    identified_cluster = [];
    size_variance = [];
    average_size = [];
    for i=1:numclusters
        close all;
        cluster_mask_image = getClusterMaskImage(input_cluster_image,i);
        %imshow(cluster_mask_image);
        % calculate the edge image and some stats about average circularity
        %{
        cluster_mask_edge = zeros(imgx,imgy);
        cluster_mask_edge = logical(cluster_mask_edge);
        %}
        cc = bwconncomp(cluster_mask_image);
        stats = regionprops(cc,'Area','Eccentricity','Perimeter','PixelIdxList');
        numcomps = numel(stats);
        params.numBest = numcomps;
        size_stats = zeros(numcomps,1);
        circ_stats = zeros(numcomps,1);
        ecc_stats = zeros(numcomps,1);
        for j=1:numcomps
            size_stats(j) = stats(j).Area;
            circ_stats(j) = (stats(j).Perimeter)^2/(4*stats(j).Area*pi);
            ecc_stats(j) = stats(j).Eccentricity;
            % get the lumen boundary and calculate the average radius of a 
            % lumen object
            %{
            boundary_image = zeros(imgx,imgy);
            boundary_image(stats(j).PixelIdxList) = 1;
            perim_image = bwperim(boundary_image);
            cluster_mask_edge = cluster_mask_edge | perim_image;
            %}
        end
        %figure;
        %imshow(cluster_mask_edge);
        %figure;
        v1 = std(size_stats);
        v2 = mean(size_stats);
        size_variance = [size_variance, v1];
        average_size = [average_size, v2];
        % pick the cluster with the smallest average size 
        % calcuate the number of ellipses from the cluster edge image
        %ellipses = ellipseDetection(cluster_mask_edge,params);
        %{
        numellipses = size(ellipses,1);
        if numellipses > max_num_ellipses 
            max_num_ellipses = numellipses;
            identified_cluster = cluster_mask_image;
        end
        %}
    end
    [~,c1] = min(size_variance);
    c1_image = getClusterMaskImage(input_cluster_image,c1);
    [~,c2] = min(average_size);
    c2_image = getClusterMaskImage(input_cluster_image,c2);
    if c1~=c2
        c1_image(c2_image==1)=0.5;
    end
    identified_cluster = c1_image;
end

function cluster_mask_image = getClusterMaskImage(input_cluster_image,cluster_no)
    [imgx,imgy] = size(input_cluster_image);
    cluster_mask_image = zeros(imgx,imgy);
    cluster_mask_image(input_cluster_image==cluster_no)=1;
    % smoothen the image a bit
    s = strel('disk',1);
    cluster_mask_image = imopen(cluster_mask_image,s);
end
