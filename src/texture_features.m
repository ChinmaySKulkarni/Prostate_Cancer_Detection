%Retrieves texture features. Returns the F matrix from SFTA computation 
%F -> [Number of Images X 24]
function F = texture_features()
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
    dims = 24;
    F = zeros(total_images,dims);
    for i=1:total_images
       f = sfta(reshape(grayscale_image_data(i,:,:),img_x,img_y),dims/6);
       F(i,:) = f;
    end
   
    %{
    %Create the training and test splits. First 30 % is test data and
    %remaining is training data.
    grayscale_image_data = reshape(grayscale_image_data,total_images,img_x * img_y);
    [~,train_labels,~,test_labels] = split_test_train(grayscale_image_data,y_labels);
    
    [test_size,~] = size(test_labels);
    train_F = zeros(total_images - test_size,dims);
    for i=test_size + 1:total_images
        train_F(i - test_size,:) = squeeze(F(i,:));
    end
    nb = NaiveBayes.fit(train_F,train_labels);
    
    test_F = zeros(test_size,dims);
    for i=1:test_size
        test_F(i,:) = squeeze(F(i,:));
    end
    
    predicted_labels = zeros(test_size,1);
    for i=1:test_size
       predicted_labels(i) = predict(nb,test_F(i,:)); 
    end    
    
    [accuracy,precision,recall] = classifier_performance(test_labels,predicted_labels);
    accuracy
    precision
    recall
    %}
   
end
    
    