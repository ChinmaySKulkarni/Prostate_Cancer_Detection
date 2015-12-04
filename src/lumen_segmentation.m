close all
clear all
clc

input_dir = './../pictures_data/complete4/';
output_dir = './../pictures_data/complete4_lumen/';

if (exist(output_dir) ~= 7)
	mkdir(output_dir)
end

load('./../pixel_data.mat');
idx = randperm(size(epithelial_pixels, 1));
epithelial_pixels = epithelial_pixels(idx(1:600), :);
idx = randperm(size(lumen_pixels, 1));
lumen_pixels = lumen_pixels(idx(1:600), :);
idx = randperm(size(stroma_pixels, 1));
stroma_pixels = stroma_pixels(idx(1:600), :);
training_pixels = [lumen_pixels' epithelial_pixels' stroma_pixels'];
class_labels = [1*ones(size(lumen_pixels,1),1);2*ones(size(epithelial_pixels,1),1); 3*ones(size(stroma_pixels,1),1)];



image_files = dir(fullfile(input_dir,'*.tif*'));
for i = 1:length(image_files)
	filepath = strcat(input_dir,image_files(i).name);
	[class_probabilities, binary_lumen_image] = colorBasedSegmentation(training_pixels, class_labels, filepath);
	imwrite(binary_lumen_image, strcat(output_dir, image_files(i).name));
end

