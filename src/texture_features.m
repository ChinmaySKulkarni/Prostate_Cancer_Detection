function texture_features()
    [image_data,y_labels,filenames, img_x, img_y, numcolors] = load_data('../clipped_matfile_patch_data3_50x50/',1);
    image_data = image_data.';
    [total_images,~] = size(image_data);
    image_data = reshape(image_data,total_images,img_x,img_y,numcolors);
    %Convert the RGB images to grayscale.
    grayscale_image_data = zeros(total_images,img_x,img_y);
    for i=1:total_images
         grayscale_image_data(i,:,:) = rgb2gray(reshape(image_data(i,:,:,:),img_x,img_y,numcolors));
    end
    %size(grayscale_image_data)
    
    %Extract the texture features based on SFTA.
    F = zeros(total_images,24);
    for i=1:total_images
       f = sfta(reshape(grayscale_image_data(i,:,:),img_x,img_y),4);
       F(i,:) = f;
    end
   
    %Create the training and test splits. First 30 % is test data and
    %remaining is training data.
    test_size = floor(0.3 * total_images);  
    [~,dims] = size(F);
    given_labels = zeros(total_images - test_size,1);
    train_F = zeros(total_images - test_size,dims);
    for i=test_size + 1:total_images
        given_labels(i - test_size) = squeeze(y_labels(i));
        train_F(i - test_size,:) = squeeze(F(i,:));
    end
    nb = NaiveBayes.fit(train_F,given_labels);
    
    actual_labels = zeros(test_size,1);    
    test_set = zeros(test_size,img_x,img_y);
    test_F = zeros(test_size,dims);
    for i=1:test_size
        test_set(i,:,:) = reshape(grayscale_image_data(i,:,:),img_x,img_y);
        test_F(i,:) = squeeze(F(i,:));
        actual_labels(i) = squeeze(y_labels(i));
    end
    
    predicted_labels = zeros(test_size,1);
    for i=1:test_size
       predicted_labels(i) = predict(nb,test_F(i,:)); 
    end    
    
    [accuracy,precision,recall] = classifier_performance(actual_labels,predicted_labels);
    accuracy
    precision
    recall

   
end
    
    