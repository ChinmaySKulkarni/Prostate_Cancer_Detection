% This function takes in the entire image data and for each image 
% returns the number of cancerous and non-cancerous patches in the 
% image (as predicted by the gmm classifier) v/s the originally labelled
% data

warning('on','all');
% {
% With normal images
[patch_cancer,~,filenames_cancer, patchx, patchy, numcolors] = load_data('../cancerous_patch3_50x50_labelled/cancer/',1);
[patch_no_cancer,~,filenames_no_cancer, patchx, patchy, numcolors] = load_data('../cancerous_patch3_50x50_labelled/no_cancer/',1);
[patch_green_data,~,all_green_patch_names, patchx, patchy, numcolors] = load_data('../cancerous_patch3_50x50_labelled/unlabelled_green/',1);
patch_no_cancer = [patch_no_cancer,patch_green_data];
totalGreen = numel(filenames_no_cancer)+numel(all_green_patch_names);
no_cancer_fnames = cell(1,totalGreen);
for i=1:numel(filenames_no_cancer)
     no_cancer_fnames{i} = filenames_no_cancer{i};
end
    
for i=numel(filenames_no_cancer)+1:totalGreen
    no_cancer_fnames{i} = all_green_patch_names{i-numel(filenames_no_cancer)}; 
end
filenames_no_cancer = no_cancer_fnames;
%}
%{
% With gaussian subsampled images
[patch_cancer,~,filenames_cancer, patchx, patchy, numcolors] = load_data('../level2_gaussian_subsampled_patch3_13x13_labelled/cancer/',1);
[patch_no_cancer,~,filenames_no_cancer, patchx, patchy, numcolors] = load_data('../level2_gaussian_subsampled_patch3_13x13_labelled/no_cancer/',1);
%}



[train_data, y_train,test_data, y_test,data_stats, train_filenames, test_filenames, unique_image_names] = create_image_patch_train_test_split(patch_cancer,filenames_cancer,...
    patch_no_cancer,filenames_no_cancer,patchx,patchy,numcolors);
[~,numtrain] = size(train_data);
prior_cancer = sum(y_train)/numel(y_train);
prior_no_cancer = 1 - prior_cancer;
complete_patch_data = [train_data,test_data];

% temporary
%prior_cancer = 1;
%prior_no_cancer = 1;

% Do domensionality reduction of the data
% {
% PCA - gives the best result
%[pca_coefficients,~,vars,expl,mu] = pca_analysis(complete_patch_data);
%pca_top_components = pca_coefficients(:,1:100)';
%reduced_patch_data = pca_top_components*complete_patch_data;
%}
 
%NMF - gives very bad result, not at all worthwhile
nmf_options = statset('MaxIter',10000,'TolFun',1e-5);
[nmf_components, nmf_weights,residue] = nnmf(complete_patch_data,70,'options',nmf_options);
reduced_patch_data = nmf_weights;    
residue

% {
% Gaussian subsampled images - does not work as data dimensionality not
% enough for GMM
% reduced_patch_data = complete_patch_data;
%}

% perform the prediction
X_train = reduced_patch_data(:,1:numtrain);
X_test = reduced_patch_data(:,numtrain+1:end);
[GMMModel_cancer, GMMModel_noncancer] = gmm_model(X_train, y_train);
y_predicted = prior_cancer*GMMModel_cancer.pdf(X_test') > prior_no_cancer*GMMModel_noncancer.pdf(X_test');
[accuracy,precision,recall] = classifier_performance(y_test, y_predicted)
f_score = harmmean([precision;recall])

all_patch_data = [train_data,test_data];
all_patch_names = [train_filenames,test_filenames];
[~,parent_filenames] = get_parent_filenames(all_patch_names);
[~,all_data] = size(all_patch_data);


% write out the per image predictions
for i=1:numel(unique_image_names)
    basepath = strcat('../image_split_prediction/',unique_image_names{i});
    mkdir(basepath);
    mkdir(strcat(basepath,'/cancer'));
    mkdir(strcat(basepath,'/no_cancer'));
end


% calculate the per image classification rate for the classifier
predicted_stats = zeros(numel(unique_image_names),1);
all_predicted = prior_cancer*GMMModel_cancer.pdf(reduced_patch_data') > prior_no_cancer*GMMModel_noncancer.pdf(reduced_patch_data');
for i=1:all_data
    patch_file_name = parent_filenames{i};
    findval = ismember(unique_image_names,patch_file_name);
    img_idx = find(findval==1);
    basepath = strcat('../image_split_prediction/',unique_image_names{img_idx},'/');
    predicted_stats(img_idx) = predicted_stats(img_idx)+all_predicted(i);
    if all_predicted(i)==1
        writepath  = strcat(basepath,'/cancer/',all_patch_names{i});
    else
        writepath =  strcat(basepath,'/no_cancer/',all_patch_names{i});
    end
    patch_image = all_patch_data(:,i);
    patch_image = reshape(patch_image,patchx,patchy,numcolors);
    imwrite(patch_image,writepath);
end


% print the prediction stats for labelled data
unique_image_names
data_stats
predicted_stats

% calculate the average number of cancerous and non-cancerous patches in green
% and red images
all_data = [data_stats(:,2),predicted_stats];
gix = find(all_data(:,1)==0);
rix = find(all_data(:,1)>0);
gthresh = sum(all_data(gix,2))/numel(gix);
rthresh = sum(all_data(rix,2))/numel(rix);


% {
% With normal patch data
[patch_green_data,~,all_green_patch_names, patchx, patchy, numcolors] = load_data('../new_pictures_data/complete_data_patches/',1);
[~,num_green_patches] = size(patch_green_data);
%}
%{
% With gaussian subsampled images
[patch_green_data,~,all_green_patch_names, patchx, patchy, numcolors] = load_data('../level2_gaussian_subsampled_patch3_13x13_labelled/unlabelled_green/',1);
[~,num_green_patches] = size(patch_green_data);
%}



% Do dimensionality reduction
% {
% PCA - gives the best result
% reduced_green_patch_data = pca_top_components*(patch_green_data-repmat(mu',1, num_green_patches));
%}

% NMF - very bad results, no point in doing
[~,reduced_green_patch_data,residue_green] = nnmf(patch_green_data,60,'options',nmf_options);
residue_green

% {
% Gaussian sumsampled images - does not work, not enough dimensionality for
% gmm
% reduced_green_patch_data = patch_green_data;
%}

[unique_green_image_names,parent_green_filenames] = get_parent_filenames(all_green_patch_names);
% write out the per image predictions
for i=1:numel(unique_green_image_names)
    basepath = strcat('../new_pictures_data/complete_data_per_image_patch/',unique_green_image_names{i});
    mkdir(strcat(basepath,'/cancer'));
    mkdir(strcat(basepath,'/no_cancer'));
end

% calculate the predictions
green_predicted_stats = zeros(numel(unique_green_image_names),1);
all_green_predicted = prior_cancer*GMMModel_cancer.pdf(reduced_green_patch_data') > prior_no_cancer*GMMModel_noncancer.pdf(reduced_green_patch_data');
%probs =[GMMModel_cancer.pdf(reduced_green_patch_data'),GMMModel_noncancer.pdf(reduced_green_patch_data')];
%probs(1,1)


% calculate the per image classification rate for the classifier
for i=1:num_green_patches
    patch_file_name = parent_green_filenames{i};
    findval = ismember(unique_green_image_names,patch_file_name);
    img_idx = find(findval==1);
    basepath = strcat('../new_pictures_data/complete_data_per_image_patch/',unique_green_image_names{img_idx},'/');
    green_predicted_stats(img_idx) = green_predicted_stats(img_idx)+all_green_predicted(i);
    if all_green_predicted(i)==1
        writepath  = strcat(basepath,'/cancer/',all_green_patch_names{i});
    else
        writepath =  strcat(basepath,'/no_cancer/',all_green_patch_names{i});
    end
    patch_image = patch_green_data(:,i);
    patch_image = reshape(patch_image,patchx,patchy,numcolors);
    imwrite(patch_image,writepath);
end

sum(all_green_predicted)
% calculate the prediction accuracy
image_classes = zeros(numel(unique_green_image_names),1);
unique_green_image_names
for i=1:numel(unique_green_image_names)
     filename = unique_green_image_names{i};
     [s, e] = regexp(filename,'red');
     suffix = filename(s:e);
     if strcmp(suffix,'red')==1
         image_classes(i)=1;
     end
end
green_predicted_stats
thresh = (gthresh+rthresh)/2;
image_preds = zeros(numel(unique_green_image_names),1);
image_preds(find(green_predicted_stats>thresh))=1;
image_preds









