function [ trans_data ] = untitled( image, filters )
%returned the image filtered with the set of filters
% transform the input into the number_of_filters dimensional space
num_filters  = size(filters,3);
[imgx,imgy] = size(image);
trans_data = [];
    for i=1:num_filters
        filter = filters(:,:,i);
        filt_i = imfilter(image,filter,'same');
        % visualize
        %{
        figure;
        colormap(gray);
        imagesc(filter);
        figure;
        colormap(gray);
        imagesc(filt_i);
        %}
        % add to data
        filt_i = reshape(filt_i,imgx*imgy,1);
        trans_data = [trans_data, filt_i]; 
    end
end

