function morphological_masking(I,writepath)
% do some morphological experiments on the image
    figure;
    s = strel('disk',3);
    I_dil = imdilate(I,s);
    imshow(I_dil);
    figure;
    gauss_filt = fspecial('gaussian',8,10);
    I_smooth = imfilter(I_dil,gauss_filt);
    I_smooth = histeq(I_smooth);
    imshow(I_smooth);
    t = graythresh(I_smooth);
    I_mask = I_smooth;
    onepixels = find(I_mask>=t);
    zeropixels = find(I_mask<t);
    I_mask(onepixels) = 1;
    I_mask(zeropixels) = 0;
    figure;
    imshow(I_mask);
    I_clipped = I.*I_mask;
    imwrite(I_clipped,writepath);
end