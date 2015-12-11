function blue_val()
    [image_data,~,filename, img_x, img_y, numcolors] = load_data('../pictures_data/complete3_segregated/Red/',1);
    [~,total_images] = size(image_data);
    image_data = reshape(image_data,img_x,img_y,numcolors,total_images);
    %{
    pure_blue_img = double(imread('../blue.png'));
    pure_b_comp = pure_blue_img(:,:,3)/255;
    [yb, x] = imhist(pure_b_comp);
    %figure('Name', 'Pure Blue');
    %plot(x, yb, 'Blue');
    max_pure_blue = max(yb);
    %}
    blue_val_feature = zeros(total_images,1);
    for i=1:total_images
        %imshow(image_data(:,:,:,i));
        image = image_data(:,:,:,i);
        %Split into RGB Channels
        Blue = image(:,:,3);
        
        %Get histValues for the blue channel
        %[yBlue, x] = imhist(Blue);
        
        %Plot them together in one plot
        %figure('Name', filename{i});
        %plot(x, yBlue, 'Blue');
        %max_b = max(yBlue);
        %blue_dist = max_pure_blue - max_b;
        %blue_val_feature(i,1) = blue_dist;
        %blue_val_feature(i,1) = max_b;
        blue_val_feature(i,1) = sum(Blue(:));
    end
    %{
    for i=1:total_images
        filename{i}
        blue_val_feature(i)
    end
    %}
    %blue_val_feature
    %sum(blue_val_feature)
    mean(blue_val_feature)
    %max(blue_val_feature)
    