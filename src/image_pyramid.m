% creates subsampled image patches using gaussian image pyramid subsampling
% technique and then applies the GMM classifier to them

% load the entire patch data
[image_data,y_labels,filenames, img_x, img_y, numcolors] = load_data('../cancerous_patch3_50x50_labelled/cancer/',1);
% create reduced gaussian pyramid of the patch data (two levels reduced)
[image_data, sub_img_x, sub_img_y] = gaussian_pyramid(image_data,img_x, img_y, numcolors, 1);
% write out the patches 

basedirname = '../level1_gaussian_subsampled_patch3_13x13_labelled/cancer/';
mkdir(basedirname);
[~,numimages] = size(image_data);
for i=1:numimages
    filename = strcat(basedirname,filenames{i});
    image = reshape(image_data(:,i),sub_img_x,sub_img_y,numcolors);
    imwrite(image,filename);
end



