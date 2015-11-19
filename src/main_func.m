function main_func()
% runs the pgrogram
    close all;
    % load the data for the 3 dataset and write the patches
    % [image_data,y_labels,filenames, img_x, img_y, numcolors] = load_data('../pictures_data/complete3/',0.4);
    
    % do a basic pca analysis on the data
    %basic_pca_analysis(image_data,img_x,img_y,numcolors);
    
    % create the patch images, pass false as the last parametet in order to
    % create the matfile for the patches in the directory specified by
    % second last argument.
    % create_image_patches(image_data,img_x,img_y,numcolors,filenames,'../pictures_data/background.tiff',50,50,'../clipped_matfile_patch_data3_50x50',false);
    
    % do different dimensionality reduction transforms on the patch data
    %patch_pca_analysis('../clipped_patch_data3_50x50/');
    %patch_nmf_analysis('../clipped_patch_data3_50x50/');
    %ica_projection = patch_ica_analysis('../clipped2_patch_data3_50x50/',100,true);
    
    % gmm clustering on patch and single images.
    %patch_gmm_fit_analysis('../clipped_patch_data3_50x50/',4,1000,true);
    %single_image_gmm(image_data,img_x,img_y,numcolors,filenames,4);
    
    % do prediction of cancerous/non_cancerous patches after projecting the
    % labelled patch data in ICA space
    % [accuracy,precision,recall] = ica_classifier_analysis();
    % accuracy
    % precision
    % recall
    
    
end

function single_image_gmm(images, imgx, imgy, numcolors, filenames, numcomps)
    [~, numimages] = size(images);
    segment_colors = colormap('jet');
    [maxcolors, ~] = size(segment_colors);
    div = floor(maxcolors/(numcomps-1));
    segment_colors = segment_colors(1:div:maxcolors,:);
    mkdir('../image_segmentation/');
    for n=1:numimages
        img = images(:,n);
        img = reshape(img,imgx*imgy,numcolors);
        options = statset('MaxIter',500);
        model = fitgmdist(img,4,'CovType','full','SharedCov',false,'Options',options,'Replicates',2,'Regularize',0.01);
        means = model.mu;
        sigma = model.Sigma;
        weights = model.PComponents
        % cacluate the segmentation of the image using map estimation
        probs = zeros(imgx,imgy,4);
        pred = zeros(imgx,imgy,3);
        img = reshape(img,imgx,imgy,3);
        for i=1:imgx
            for j=1:imgy
                for k=1:4
                    mu = means(k,:);
                    covar = sigma(:,:,k);
                    pixel = img(i,j,:);
                    pixel = pixel(:)';
                    conditional = mvnpdf(pixel,mu,covar);
                    pr = weights(k)*conditional;
                    probs(i,j,k) = pr;
                end
                [~,maxidx] = max(probs(i,j,:));
                pred(i,j,:) = segment_colors(maxidx,:);   
            end
        end
        % write the segmented image
        writepath = strcat('../image_segmentation/',filenames{n});
        imwrite(pred,writepath);
    end
end

function [accuracy,precision,recall] =  ica_classifier_analysis()

    % load the data from the labelled red patches
    [patch_cancer,~,~, patchx, patchy, numcolors] = load_data('../cancerous_patch3_50x50_labelled/cancer/',1);
    [patch_no_cancer,~,~, patchx, patchy, numcolors] = load_data('../cancerous_patch3_50x50_labelled/no_cancer/',1);
    [patch_predict_images,~,filenames, patchx, patchy, numcolors] = load_data('../cancerous_patch3_50x50_labelled/unlabelled_green/',1);
    [~, num_cancer] = size(patch_cancer);
    [~, num_no_cancer] = size(patch_no_cancer);
    total_data = [patch_cancer,patch_no_cancer,patch_predict_images];
 
    % get the ica projection of the patches
    ica_data = patch_ica_analysis(total_data,100,false);
    patch_cancer = ica_data(:,1:num_cancer);
    patch_no_cancer = ica_data(:,num_cancer+1:num_cancer+num_no_cancer);
    patch_predict = ica_data(:,num_cancer+num_no_cancer+1:end);
    
    % create the training and test splits and the data labels for 
    % training.
    cancer_thresh = floor(0.70*num_cancer);
    no_cancer_thresh = floor(0.70*num_no_cancer);
    train_data = [patch_cancer(:,1:cancer_thresh),patch_no_cancer(:,1:no_cancer_thresh)];
    train_labels = [ones(1,cancer_thresh),zeros(1,no_cancer_thresh)];
    [~,numtrain] = size(train_data);
    train_perm = randperm(numtrain);
    train_data = train_data(:,train_perm);
    train_labels = train_labels(:,train_perm);
    test_data = [patch_cancer(:,cancer_thresh+1:end),patch_no_cancer(:,no_cancer_thresh+1:end)];
    [~,numtest] = size(test_data);
    test_labels = [ones(1,num_cancer-cancer_thresh),zeros(1,num_no_cancer-no_cancer_thresh)];
    test_perm = randperm(numtest);
    test_data = test_data(:,test_perm);
    test_labels  = test_labels(:,test_perm);
    [accuracy,precision,recall,classifier] = basic_svm_classifier(train_data,train_labels,test_data,test_labels);
    
    %use the classifier to divide the patches in the green data into
    %cancerous / non-cancerous and then evaluate them using human
    %comparison
    mkdir('../class1');
    mkdir('../class0');
    [~,numpredict] = size(patch_predict);
    svm_predict = svmclassify(classifier,patch_predict.');
    for i=1:numpredict
        filepath = strcat('../class',int2str(svm_predict(i)),'/',filenames{i});
        predict_image = patch_predict_images(:,i);
        predict_image = reshape(predict_image,patchx,patchy,numcolors);
        imwrite(predict_image,filepath);
    end
    
end

function [accuracy,precision,recall] = classifier_performance(test_labels,predict_labels)
    tp = 0; 
    fp = 0;
    fn = 0;
    tn = 0;
    for i =1:numel(predict_labels)
        if predict_labels(i)==1
            if predict_labels(i)==test_labels(i)
                tp = tp+1;
            else 
                fp = fp+1;
            end
        else
            if predict_labels(i)==test_labels(i)
                tn = tn+1;
            else
                fn = fn+1;
            end
        end
    end
    precision = tp/(tp+fp);
    recall = tp/(tp+fn);
    accuracy = (tp+tn)/(fp+fn+tp+tn);
end

function [accuracy,precision,recall,svm_train] = basic_svm_classifier(train_data,train_labels,test_data,test_labels)
% takes in the training and testing data and labels in (dimxxnumexamples)
% format and outputs the test labels
    %learn a soft-margin svm
    svm_train = svmtrain(train_data.',train_labels,'showplot',true,'kernel_function','linear','boxconstraint',0.1);
    svm_predict = svmclassify(svm_train,test_data.');
    svm_predict = svm_predict';
    [accuracy,precision,recall] = classifier_performance(test_labels,svm_predict);
end

function basic_pca_analysis(image_data,img_x,img_y,numcolors)
% performs a basic pca analysis on the data
    [pca_coefficients,~,vars,expl] = pca_analysis(image_data);
    figure;
    show_pca(pca_coefficients, img_x, img_y, numcolors);
end

function create_image_patches(image_data,img_x,img_y,numcolors,filenames,bg_image_path,patchx,patchy,patch_dir,write_images)
% creates and writes image patches from the image data in 'image_data'. The
% patch dimensions are specified in 'patchx' and 'patchy'. The
% 'bg_image_path' points to the background image patch of size 'patch_x'
% and 'patchy' which is used to filter out background patches. 'patch_dir'
% refers to the directory where the created patches will be stored.
% write_images' is true then patch images will be created othwerwise a mat
% file will be created.
    bg_image = imread(bg_image_path);
    bg_image = bg_image(1:patchx,1:patchy,:);
    [patch_data, patch_coord] =  patch_all_images(image_data,img_x,img_y,numcolors,patchx,patchy,bg_image);
    mkdir(patch_dir);
    write_patches(patch_data,patch_coord,filenames,patchx,patchy,numcolors,patch_dir,write_images);
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
            patch_image = reshape(patch_data(:,i),img_x,img_y,3);
            patch_image = patch_image(:,:,1:2);
            patch_image = reshape(patch_image,img_y*img_x*2,1);
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
    options = statset('MaxIter',1000);
    model = fitgmdist(projected_data,numcomps,'CovType','full','SharedCov',false,'Options',options,'Replicates',4,'Regularize',0.01);
    means = model.mu;
    sigma = model.Sigma;
    weights = model.PComponents
    bic = model.BIC

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

function [ica_projection] = patch_ica_analysis(patch_data_dir,num_top_pca,data_dir)
% performs ica analysis on the patch images present in 'patch_data_dir'.
% the show_pca method might need to be adjusted to scale and show the image
% properly.

    % load the patched data;
    if data_dir==true
        [patch_data, y_labels, filenames, img_x, img_y, numcolors] = ...
        load_data(patch_data_dir,1);
    else 
        patch_data=patch_data_dir;
    end
    [patch_dim,numpatches] = size(patch_data); 
    
    % do the pca on the entire patch data;
    [patch_pca_coefficients, patch_pca_projections,vars,expl] = pca_analysis(patch_data);
    top_pca_coeff = patch_pca_coefficients(:,1:num_top_pca);
    top_pca_coeff = top_pca_coeff';
    projected_data = top_pca_coeff*patch_data;
  
    % compute the ICA analysis features
    W = fastica(projected_data.');
    ica_components = W*top_pca_coeff;
    figure;
    show_pca(ica_components',50,50,3);
    ica_projection = ica_components*patch_data;
end