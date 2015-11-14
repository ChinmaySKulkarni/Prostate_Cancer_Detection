function classifier()
    %[image_data_3,y_labels_3,filenames_3, img_x_3, img_y_3, numcolors] = load_data('../pictures_data/complete3/',0.4);
    %show_data(image_data_3,filenames_3,img_x_3,img_y_3,numcolors);
    %size(image_data_3)
    %ex = image_data_3(:,1);
    %ex = reshape(ex,166116,3,1);
    
    %Lower dimentional patches after applying PCA/NMF:
    %D X P (dims X number of patches)
    low_dim_patches_red;
    low_dim_patches_green;
    test_data_patches;
    [~,num_test_patches] = size(test_data_patches);
    predicted_labels = zeros(num_test_patches,1);
    %Get the average similarity of each test image patch with red and green
    %patches.
    for i=1:num_test_patches
        test_ex = test_data_patches(:,i);
        avg_simil_red = get_similarity(test_ex,low_dim_patches_red);
        avg_simil_green = get_similarity(test_ex,low_dim_patches_green);
        if(avg_simil_red > avg_simil_green)
            predicted_labels(i) = 1;
        else
            predicted_labels(i) = 0;
        end
    end
end