function texture_features()
    [image_data,y_labels,filenames, img_x, img_y, numcolors] = load_data('../clipped_matfile_patch_data3_50x50/',1);
    image_data = image_data.';
    [training_size,~] = size(image_data);
    image_data = reshape(image_data,training_size,img_x,img_y,numcolors);
    grayscale_image_data = zeros(training_size,img_x,img_y);
    for i=1:training_size
         grayscale_image_data(i,:,:) = rgb2gray(reshape(image_data(i,:,:,:),img_x,img_y,numcolors));
    end
    %size(grayscale_image_data)
    
    F = zeros(training_size,24);
    for i=1:training_size
       f = sfta(reshape(grayscale_image_data(i,:,:),img_x,img_y),4);
       F(i,:) = f;
    end
    size(F)
end
    
    