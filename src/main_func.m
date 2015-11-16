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
    
    % do different dimensionality reduction transforms on the patch data
    patch_pca_analysis();
    patch_nmf_analysis();
    patch_ica_analysis();
end

function patch_pca_analysis()
    % load the patched data;
    [patch_data, y_labels, filenames, img_x, img_y, numcolors] = ...
        load_data('../clipped_patch_data3_50x50/',1);
    % do the pca on the entire patch data;
    [patch_dim,numpatches] = size(patch_data);
    [patch_pca_coefficients, patch_pca_projections,vars,expl] = pca_analysis(patch_data);
    % the amount of variance explained by the top 20 components
    s = sum(expl(1:20))
    % show the top 20 components
    top_pca = patch_pca_coefficients(:,1:20);
    figure;
    show_pca(top_pca,50,50,3);
end

function patch_nmf_analysis()

    % load the patched data;
    [patch_data, y_labels, filenames, img_x, img_y, numcolors] = ...
        load_data('../clipped_patch_data3_50x50/',1);
    [patch_dim,numpatches] = size(patch_data); 
    
    % convert the patch data to grayscale (in case you want to run on
    % greyscale data )
    %{
    patch_grey_data = [];
    for i=1:numpatches
        patch_image = patch_data(:,i);
        patch_image = reshape(patch_image,50,50,3);
        patch_greyscale = rgb2gray(patch_image);
        patch_greyscale = reshape(patch_greyscale,50*50,1);
        patch_grey_data = [patch_grey_data, patch_greyscale];
    end
    %}
   
    % try out nmf for 4 components - 
    % stroma 
    % lumen
    % epithilial nuclei
    % background
    [nmf_components, nmf_weights] = nnmf(patch_data,4);
    figure;
    show_pca(nmf_components,50,50,3);
    
end

function patch_ica_analysis()
    
    % load the patched data;
    [patch_data, y_labels, filenames, img_x, img_y, numcolors] = ...
        load_data('../clipped_patch_data3_50x50/',1);
    [patch_dim,numpatches] = size(patch_data); 
    
    % do the pca on the entire patch data;
    [patch_pca_coefficients, patch_pca_projections,vars,expl] = pca_analysis(patch_data);
    top_pca_coeff = patch_pca_coefficients(:,1:20);
    top_pca_coeff = top_pca_coeff';
    projected_data = top_pca_coeff*patch_data;
  
    % compute the ICA analysis features
    W = fastica(projected_data.');
    ica_components = W*top_pca_coeff;
    figure;
    show_pca(ica_components',50,50,3);
   
end