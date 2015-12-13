[image_data,y_labels,image_filename, imgx, imgy, numcolors] = load_data('../new_pictures_data/modified_data4/',1);
numimages = size(image_data,2);
for i=1:numimages
    image = reshape(image_data(:,i),imgx,imgy,numcolors);
    [centers,radii,~]  = imfindcircles(image,[2 5],'ObjectPolarity','dark','Sensitivity',0.92, 'EdgeThreshold',0.1);
    figure
    imshow(image);
    image_filename{i}
    viscircles(centers,radii,'EdgeColor','g');
    if(i==10)
        return
    end
end
