function show_pca(image_data,img_x,img_y,numcolors)
% shows the vectorized image data in a grid of 4 rows
    [dims, numimages] = size(image_data);
    h = floor(numimages/4);
    if 4*h < numimages
        h = h+1;
    end
        %subplot(2,h);
    for i=1:numimages
        image = reshape(image_data(:,i),img_x,img_y,numcolors);
        if (numcolors==1)
            axis off;
            axis equal;
            subplot(4,h,i);    expl
            colormap(bone);
            imagesc(image);
        else 
            subplot(4,h,i);
            imshow(1*image);
        end
    end
end