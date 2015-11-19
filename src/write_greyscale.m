function write_greyscale( image_data, img_x,img_y,numcolors, filenames, greyscale_folder )
%Takes in image data as a dimsxnumimages matrix, reshapes it and writes it
% as greyscale image in the specified folder
    mkdir(greyscale_folder);
    [dims, numimages] = size(image_data);
    for i=1:numimages
        image = reshape(image_data(:,i),img_x,img_y,numcolors);
        image = rgb2gray(image);
        write_path = strcat(greyscale_folder,'/',filenames{i});
        imwrite(image,write_path);
    end

end

