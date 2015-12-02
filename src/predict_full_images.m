% This function takes in the entire image data and for each image 
% returns the number of cancerous and non-cancerous patches in the 
% image (as predicted by the gmm classifier) v/s the originally labelled
% data

[patch_cancer,~,filenames_cancer, patchx, patchy, numcolors] = load_data('../cancerous_patch3_50x50_labelled/cancer/',1);
[patch_no_cancer,~,filenames_no_cancer, patchx, patchy, numcolors] = load_data('../cancerous_patch3_50x50_labelled/no_cancer/',1);
[train_data, y_train,test_data, y_test,data_stats, train_filenames, test_filenames, unique_image_names] = create_image_patch_train_test_split(patch_cancer,filenames_cancer,...
    patch_no_cancer,filenames_no_cancer,patchx,patchy,numcolors);
[~,numtrain] = size(train_data);
prior_cancer = sum(y_train)/numel(y_train);
prior_no_cancer = 1 - prior_cancer;
complete_patch_data = [train_data,test_data];
[pca_coefficients,~,vars,expl] = pca_analysis(complete_patch_data);
reduced_patch_data = pca_coefficients(:, 1:100)'*complete_patch_data;
X_train = reduced_patch_data(:,1:numtrain);
X_test = reduced_patch_data(:,numtrain+1:end);
[GMMModel_cancer, GMMModel_noncancer] = gmm_model(X_train, y_train);
y_predicted = prior_cancer*GMMModel_cancer.pdf(X_test') > prior_no_cancer*GMMModel_noncancer.pdf(X_test');
[accuracy,precision,recall] = classifier_performance(y_test, y_predicted)
f_score = harmmean([precision;recall])

all_patch_names = [train_filenames,test_filenames];
[~,parent_filenames] = get_parent_filenames(all_patch_names);
all_patch_data = [patch_cancer,patch_no_cancer];
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

unique_image_names
data_stats
predicted_stats








