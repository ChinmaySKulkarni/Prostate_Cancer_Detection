function findCicles()
    [image_data,y_labels,image_filename, imgx, imgy, numcolors] = load_data('../new_pictures_data/modified_data4/',1);
    numimages = size(image_data,2);
    for i=1:numimages
        image = reshape(image_data(:,i),imgx,imgy,numcolors);
        [centers,radii,~]  = imfindcircles(image,[2 5],'ObjectPolarity','dark','Sensitivity',0.92, 'EdgeThreshold',0.1);
        image_filename{i}
        write_epithelial_images(centers,radii,imgx,imgy,image_filename{i});
        %figure
        %imshow(image);
        %viscircles(centers,radii,'EdgeColor','g');
    end

function write_epithelial_images(centers,radii,imgx,imgy,name)
    new_image = zeros(imgx, imgy);
    [num_circles, ~] = size(centers);
    for i=1:num_circles
        new_image(round(centers(i,2)), round(centers(i,1))) = 1;
    end
    radius = round(mean(radii(:)));
    circ_mask = double(getnhood(strel('ball',radius,radius,0)));
    %imshow(circ_mask, 'InitialMagnification', 500)
    new_image = imfilter(new_image,circ_mask,'conv');
    imwrite(new_image,strcat('../new_pictures_data/circle_epithelial_data4/', name));
    
    