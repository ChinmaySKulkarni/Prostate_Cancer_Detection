function [ output_image_data, img_outx, img_outy ] = gaussian_pyramid( image_data, img_x, img_y, numcolors, level )
% creates a gaussian subsampled representation of the image in the gaussian
% pyramid subsampled l levels from the original image
    output_image_data = [];
    [~,numimages] = size(image_data);
    for i=1:numimages
        image = image_data(:,i);
        image = reshape(image,img_x,img_y,numcolors);
        for j=1:level
            image = impyramid(image,'reduce');
        end
        [img_outx, img_outy, ~] = size(image);
        image = reshape(image,img_outx*img_outy*numcolors,1);
        output_image_data = cat(2,output_image_data,image);
    end
end

