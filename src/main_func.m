function main_func()
% runs the pgrogram

    % load the data for the 3 dataset and write the patches
    %{
    [image_data,y_labels,filenames, img_x, img_y, numcolors] = load_data('../pictures_data/complete3/',0.4);
    show_data(image_data,filenames,img_x,img_y,numcolors);
    bg_image = imread('../pictures_data/background.tiff');
    [patch_data, patch_coord] =  patch_all_images(image_data,img_x,img_y,numcolors,50,50,bg_image);
    write_patches(patch_data,patch_coord,filenames,50,50,numcolors,'../clipped_patch_data3_50x50');
    %}
    
    % load the data for the 4 dataset and write the patches
    %{
    [image_data,y_labels,filenames, img_x, img_y, numcolors] = load_data('../pictures_data/complete4/',0.4);
    show_data(image_data,filenames,img_x,img_y,numcolors);
    bg_image = imread('../pictures_data/background.tiff');
    [patch_data, patch_coord] =  patch_all_images(image_data,img_x,img_y,numcolors,50,50,bg_image);
    write_patches(patch_data,patch_coord,filenames,50,50,numcolors,'../clipped_patch_data4_50x50');
    %}
    
    % basic PCA analysis
    %
    
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
    
    patch_analysis();
end

function image_analysis()

end

function patch_analysis()
    % load the patched data;
    [patch_data, y_labels, filenames, img_x, img_y, numcolors] = ...
        load_data('../clipped_patch_data3_50x50/',1);
    % do the pca on the entire patch data;
    [patch_dim,numpatches] = size(patch_data);
    [patch_pca_coefficients, patch_pca_projections,vars,expl] = pca_analysis(patch_data);
    vars
    figure;
    stem(vars);
    figure;
    stem(expl);
    %figure;
    %show_pca(pca_coefficients,img_x,img_y,numcolors);
end