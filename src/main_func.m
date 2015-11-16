function main_func()
% runs the pgrogram
    close all;
    % load the data for the 3 dataset and write the patches
    %[image_data,y_labels,filenames, img_x, img_y, numcolors] = load_data('../pictures_data/complete3/',0.4);
    
    % do a basic pca analysis on the data
    %basic_pca_analysis(image_data,img_x,img_y,numcolors);
    
    % create the patch images
    % create_image_patches(image_data,img_x,img_y,numcolors,filenames,'../pictures_data/background.tiff',25,25,'../clipped_patch_data3_25x25');
    
    % do different dimensionality reduction transforms on the patch data
    %patch_pca_analysis('../clipped_patch_data3_50x50/');
    %patch_nmf_analysis('../clipped_patch_data3_50x50/');
    %patch_ica_analysis('../clipped_patch_data3_50x50/');
    %patch_gmm_fit_analysis('../clipped_patch_data3_50x50/',4,1000,true);
    
    
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

function basic_pca_analysis(image_data,img_x,img_y,numcolors)
% performs a basic pca analysis on the data
    [pca_coefficients,~,vars,expl] = pca_analysis(image_data);
    figure;
    show_pca(pca_coefficients, img_x, img_y, numcolors);
end

function create_image_patches(image_data,img_x,img_y,numcolors,filenames,bg_image_path,patchx,patchy,patch_dir)
% creates and writes image patches from the image data in 'image_data'. The
% patch dimensions are specified in 'patchx' and 'patchy'. The
% 'bg_image_path' points to the background image patch of size 'patch_x'
% and 'patchy' which is used to filter out background patches. 'patch_dir'
% refers to the directory where the created patches will be stored.
    bg_image = imread(bg_image_path);
    bg_image = bg_image(1:25,1:25,:);
    [patch_data, patch_coord] =  patch_all_images(image_data,img_x,img_y,numcolors,patchx,patchy,bg_image);
    mkdir(patch_dir);
    write_patches(patch_data,patch_coord,filenames,patchx,patchy,numcolors,patch_dir);
end

function patch_gmm_fit_analysis(patch_data_dir,numk, num_pca, green_keep)
% performs gaussian mixuture model clustering for patch image data located
% in 'patch_data_dir'. 'numk' specifies the number of components of the
% model, 'num_pca' specifies number of principal components to use and
% 'green_keep' specifies whether the green channel needs to be kept.

    % load the patched data;
    [patch_data, y_labels, filenames, img_x, img_y, numcolors] = ...
        load_data(patch_data_dir,1);
    [patch_dim,numpatches] = size(patch_data);
    old_patch_data = patch_data;
    
    % keep the green channel in the patch data
    if green_keep==false
        new_patch_data = [];
        for i=1:numpatches
            patch_image = reshape(patch_data(:,i),50,50,3);
            patch_image = patch_image(:,:,1:2);
            patch_image = reshape(patch_image,50*50*2,1);
            new_patch_data = [new_patch_data, patch_image];
        end
        patch_data = new_patch_data;
    end
    
    
    % reduce the dimension of the patches to 50 by applying pca
    [patch_pca_coefficients,~,vars,expl] = pca_analysis(patch_data);
    % the amount of variance explained by the top 50 components
    s = sum(expl(1:num_pca))
    top_pca = patch_pca_coefficients(:,1:num_pca);
    projected_data = top_pca'*patch_data;
    
    % Fig a gaussian mixture model of 5 components for each patch image
    numcomps = numk;
    projected_data = projected_data';
    options = statset('MaxIter',num_pca);
    model = fitgmdist(projected_data,numcomps,'CovType','full','SharedCov',false,'Options',options,'Replicates',4,'Regularize',0.01);
    means = model.mu;
    sigma = model.Sigma;
    weights = model.PComponents

    % calculate the posterior probabilities for each of the components and 
    % classify the data points accordingly.
    probs = zeros(numpatches,numcomps);
    preds = cell(numpatches,1);
    for i=1:numpatches
        for j=1:numcomps
            mu = means(j,:);
            covar = sigma(:,:,j);
            x = projected_data(i,:);
            conditional = mvnpdf(x,mu,covar);
            pr= weights(j)*conditional;
            probs(i,j) = pr;
        end
        % do MLE prediction
        [~,class] = max(probs(i,:));
        preds{i} = strcat('class',int2str(class));
    end
    
    % normalize the probabilities
    sum_probs = sum(probs');
    probs = bsxfun(@rdivide,probs',sum_probs);
    probs = probs';
    
    % write the files in the class directories;
    for i=1:numcomps
        folder =  strcat('../class',int2str(i));
        mkdir(folder);
    end
    for i=1:numpatches
        pred = preds{i};
        filepath = strcat('../',pred,'/',filenames{i});
        patch_im = old_patch_data(:,i);
        patch_im = reshape(old_patch_data(:,i),img_x,img_y,numcolors);
        imwrite(patch_im,filepath);
    end
    
    % reconstruct the mean images
    means = means';
    reconstr_mean_images = top_pca*means;
    
    % display the average cluster image for the blue and red channels
    % separately
    for i=1:numcomps
        mean_image = reconstr_mean_images(:,i);
        if green_keep==true
            mean_image = reshape(mean_image,img_x,img_y,3);
        else 
            mean_image = reshape(mean_image,img_x,img_y,2);
        end
        figure;
        subplot(4,1,1)
        mean_red = mean_image(:,:,1);
        imshow(mean_red);
        subplot(4,1,2);
        mean_blue = mean_image(:,:,2);
        imshow(mean_blue);
        if green_keep==true
            mean_green = mean_image(:,:,3);
            subplot(4,1,3);
            imshow(mean_green);
            subplot(4,1,4);
            imshow(mean_image);
        end
    end
end

function patch_pca_analysis(patch_data_dir)
% performs pca analysis on the patch images present in 'patch_data_dir'.
% the show_pca method might need to be adjusted to scale and show the image
% properly.


    % load the patched data;
    [patch_data, y_labels, filenames, img_x, img_y, numcolors] = ...
        load_data(patch_data_dir,1);
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

function patch_nmf_analysis(patch_data_dir,gray_data)
% performs nmf analysis on the patch images present in 'patch_data_dir'.
% the show_pca method might need to be adjusted to scale and show the image
% properly. 'gray_data' specifies if the analysis needs to be done on
% grayscale data insted of color data

    % load the patched data;
    [patch_data, y_labels, filenames, img_x, img_y, numcolors] = ...
        load_data(patch_data_dir,1);
    [patch_dim,numpatches] = size(patch_data); 
    
    % convert the patch data to grayscale (in case you want to run on
    % greyscale data )
   
    if grey_data==true
        patch_grey_data = [];
        for i=1:numpatches
            patch_image = patch_data(:,i);
            patch_image = reshape(patch_image,50,50,3);
            patch_greyscale = rgb2gray(patch_image);
            patch_greyscale = reshape(patch_greyscale,50*50,1);
            patch_grey_data = [patch_grey_data, patch_greyscale];
        end
        patch_data = patch_grey_data;
    end
   
    % try out nmf for 4 components - 
    % stroma 
    % lumen
    % epithilial nuclei
    % background
    [nmf_components, nmf_weights] = nnmf(patch_data,4);
    figure;
    show_pca(nmf_components,50,50,3);
    
end

function patch_ica_analysis(patch_data_dir)
% performs ica analysis on the patch images present in 'patch_data_dir'.
% the show_pca method might need to be adjusted to scale and show the image
% properly.

    % load the patched data;
    [patch_data, y_labels, filenames, img_x, img_y, numcolors] = ...
        load_data(patch_data_dir,1);
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