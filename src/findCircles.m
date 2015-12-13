[image_data,y_labels,image_filename, imgx, imgy, numcolors] = load_data('../new_pictures_data/data4/',1);
numimages = size(image_data,2);
for i=1:numimages
    image = reshape(image_data(:,i),imgx,imgy,numcolors);
    image = rgb2gray(image);
    [centers,radii,~]  = imfindcircles(image,[3 7],'ObjectPolarity','d');
    clear all;
    imshow(image);
    viscircles(centers,radii,'EdgeColor','g');
end
