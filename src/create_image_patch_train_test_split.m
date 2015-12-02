function[train_data,train_labels,test_data,test_labels,data_stats, ...
    train_data_filenames,test_data_filenames,unique_image_names] =  create_image_patch_train_test_split(patch_cancer,...
    filenames_cancer,patch_no_cancer,filenames_no_cancer,patchx,patchy,numcolors)
% This function reads in the labelled cancer/no-cancer patch data
% from a directory that contains this data for a set of images
% and creates a train-test split such that patches from an image
% are either all in training or in testing. Also calculates and reports
% the per-image fraction of cancerous patches

% group the patches by images first.
image_filenames = [filenames_cancer, filenames_no_cancer];
[unique_image_names,parent_filenames] = get_parent_filenames(image_filenames);

% create a 70-30 train test split on the parent images (assuming the number
% of patches per image is approximately the same, this should lead to a
% 70-30 split of the patches as well.
numimages = numel(unique_image_names);
unique_image_names = unique_image_names(randperm(numimages));
split_idx = floor(0.7*numimages);
train_image_names = unique_image_names(1:split_idx);

y_labels_cancer = ones(1,numel(filenames_cancer));
y_labels_no_cancer = zeros(1,numel(filenames_no_cancer));
y_labels = [y_labels_cancer, y_labels_no_cancer];
patch_data = [patch_cancer,patch_no_cancer];

train_data = [];
train_labels = [];
test_data = [];
test_labels = [];
train_data_filenames = {};
test_data_filenames = {};
image_stats = zeros(numimages,2);

% add each patch to the train or test set depending upon whether the 
% corresponding parent image is a train image or test image.
for i=1:numel(image_filenames)
    findval = ismember(train_image_names,parent_filenames{i});
    is_train = sum(findval);
    findval = ismember(unique_image_names,parent_filenames{i});
    img_idx = find(findval==1);
    % increment the patch count of the image
    image_stats(img_idx,1) = image_stats(img_idx,1)+1;
    image_stats(img_idx,2) = image_stats(img_idx,2)+y_labels(i);
    if is_train>=1
        train_data = [train_data,patch_data(:,i)];
        train_labels = [train_labels,y_labels(i)];
        train_data_filenames = [train_data_filenames, image_filenames{i}];
    else
        test_data = [test_data,patch_data(:,i)];
        test_labels = [test_labels,y_labels(i)];
        test_data_filenames = [test_data_filenames, image_filenames{i}];
    end
end

% randomly permute the data
train_perm = randperm(numel(train_labels));
test_perm = randperm(numel(test_labels));
train_data = train_data(:,train_perm);
train_labels = train_labels(train_perm);
test_data = test_data(:,test_perm);
test_labels = test_labels(test_perm);
num_cancerous = sum(image_stats(:,2))
toatal_patches = sum(image_stats(:,1))
data_stats = image_stats;

end