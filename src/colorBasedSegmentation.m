function [class_probabilities, binary_lumen_image] = colorBasedSegmentation(training_pixels, class_labels, image)


	neighborhood_parameter = 10;
	if ischar(image)
		image = imread(image);
		image = image(:,:,1:3);
    end
    image = uint8(255*image);
	num_classes = length(unique(class_labels));
	classes = sort(unique(class_labels));
	[m, n, ch] = size(image)
	img_vector = reshape(image, m*n, ch);
	idx = rangesearch(training_pixels', img_vector, neighborhood_parameter);

	class_probabilities = zeros(m*n, num_classes);
	for cl = 1:num_classes
		curr_class = classes(cl);
		for i = 1:length(idx)
			if (length(idx{i}) == 0)
				continue;
            end
            class_probabilities(i, cl) = sum(class_labels(idx{i}) == curr_class)/length(idx{i});
		end
	end

	class_probabilities = reshape(class_probabilities, m, n, num_classes);
	lumen_image = class_probabilities(:,:,2);
	s = strel('ball', 4, 0.3, 0);
	lumen_closed = imclose(lumen_image, s);
	binary_lumen_image = lumen_closed;
	binary_lumen_image (lumen_closed <= 0.2) = 1;
	binary_lumen_image (lumen_closed >0.2) = 0;
    s = strel('disk', 4, 0);
    binary_lumen_image = imdilate(binary_lumen_image, s);


end
