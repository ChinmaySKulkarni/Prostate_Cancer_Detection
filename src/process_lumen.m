function [fraction_epithelial_in_boundary, fraction_epithelial_in_image] = process_lumen(lumenImage, epithelial_image)

	se = strel('disk',30);
	afterOpening = imdilate(lumenImage,se);
	lumen_boundary = afterOpening - lumenImage;
    figure;imshow(lumenImage);
	figure;imshow(lumen_boundary);
	epithelial_in_lumen_boundary = epithelial_image(logical(lumen_boundary));

	CC = bwconncomp(epithelial_in_lumen_boundary);
	numEpithelial_in_boundary = numel(CC.PixelIdxList);
	fraction_epithelial_in_boundary = numEpithelial_in_boundary/sum(sum(lumen_boundary));


	CC = bwconncomp(epithelial_image);
	numEpithelialInImage = numel(CC.PixelIdxList);
	fraction_epithelial_in_image = numEpithelialInImage/numel(epithelial_image);

end