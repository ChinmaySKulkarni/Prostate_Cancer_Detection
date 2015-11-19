function [ image_data, y_labels, filenames, imgx, imgy, numcolors ] = load_grey_data( input_dir, resize_scale )
%LOAD_DATA loads the images from a given folder , vectorizes
% and returns them. image_data is a dims x num_images matrix
   image_files = dir(fullfile(input_dir,'*.tif*'));
   image_data = [];
   max_imgx=0;
   max_imgy=0;
   y_labels = [];
   filenames = {};
   k = 1;
   for i=1:length(image_files)
       filename = image_files(i).name;
       if strcmp(filename,'.')~=1 && strcmp(filename,'..')~=1
           filenames{k} = filename;
           k=k+1;
           [s, e] = regexp(filename,'red');
           suffix = filename(s:e);
           if strcmp(suffix,'red')==1
               y_labels = [y_labels; 1];
           else
               y_labels = [y_labels; 0];
           end
           filepath = strcat(input_dir,image_files(i).name);
           image = imread(filepath);
           [img_x, img_y, numcolors] = size(image);
           max_imgx = max(max_imgx,img_x);
           max_imgy = max(max_imgy,img_y);
       end
   end
   % pad the images to make them all the same size
   for i=1:length(image_files)
       if strcmp(image_files(i).name,'.')~=1 && strcmp(image_files(i).name,'..')~=1
           filepath = strcat(input_dir,image_files(i).name);
           image = imread(filepath);
           [img_x,img_y,numcolors] = size(image);
           padded_image = [];
           x_diff = max_imgx-img_x;
           y_diff = max_imgy-img_y;
           % what padval to chose (must be the same color as boundary
           % region, or different for each color component). Right now
           % values hardcoded from that found in the sample background
           % image
           padvals = [127];
           for j=1:1
               color_image = image(:,:,j);
               padding_x = floor(x_diff/2);
               padding_y = floor(y_diff/2);
               if mod(x_diff,2)==0
                   color_image = padarray(color_image,[padding_x,0],padvals(j),'both');
               else 
                   color_image = padarray(color_image,[padding_x+1,0],padvals(j),'pre');
                   color_image = padarray(color_image,[padding_x,0],padvals(j),'post');
               end
               if mod(y_diff,2)==0
                   color_image = padarray(color_image,[0,padding_y],padvals(j),'both');
               else 
                   color_image = padarray(color_image,[0,padding_y],padvals(j),'pre');
                   color_image = padarray(color_image,[0,padding_y+1],padvals(j),'post');
               end
               padded_image = cat(3,padded_image,color_image);
           end
           scaled_image = imresize(padded_image,resize_scale);
           [imgx, imgy, numcolors] = size(scaled_image);
           scaled_image = im2double(scaled_image);
           padded_image = reshape(scaled_image,imgx*imgy*numcolors,1);
           image_data = cat(2,image_data,padded_image);
       end
   end
            
end

