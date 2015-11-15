function main_func()
% runs the pgrogram

    % load the data for the green dataset and write the patches
    [image_data,y_labels,filenames, img_x, img_y, numcolors] = load_data('../pictures_data/complete3/',0.4);
    show_data(image_data,filenames,img_x,img_y,numcolors);
    [patch_data, patch_coord] =  patch_all_images(image_data,img_x,img_y,numcolors,50,50);
    write_patches(patch_data,patch_coord,filenames,50,50,numcolors,'../patch_data3_50x50');
   
    
    % load the data for the green dataset and write the patches
    [image_data,y_labels,filenames, img_x, img_y, numcolors] = load_data('../pictures_data/complete4/',0.4);
    show_data(image_data,filenames,img_x,img_y,numcolors);
    [patch_data, patch_coord] =  patch_all_images(image_data,img_x,img_y,numcolors,50,50);
    write_patches(patch_data,patch_coord,filenames,50,50,numcolors,'../patch_data4_50x50');
    
    % basic PCA analysis
    %[patch_dim,num_patch_per_image,numimages] = size(patch_data);
    %patch_data = reshape(patch_data,patch_dim,num_patch_per_image*numimages);
    %[patch_pca_coefficients, patch_pca_projections,vars] = pca_analysis(patch_data);
    %[pca_coefficients,pca_projections,variances] = pca_analysis(image_data);
    %figure;
    %show_pca(pca_coefficients,img_x,img_y,numcolors);
    

    %{ 
    basic classifier
    train_data = image_data(:,1:20);
    train_labels = y_labels(1:20);
    test_data = image_data(:,21:end);
    test_labels = y_labels(21:end);
    svm_train = svmtrain(train_data.',train_labels,'showplot',true);
    svm_predict = svmclassify(svm_train,test_data.');
    test_labels
    svm_predict
    %}
    
    
end