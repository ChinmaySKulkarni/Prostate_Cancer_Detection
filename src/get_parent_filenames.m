function [unique_image_names, parent_filenames] = get_parent_filenames(image_filenames)
% get the corresponding parent file names and the list of unique image
% files from a list of patch file names
    parent_filenames = cell(1,numel(image_filenames));
    for i=1:numel(image_filenames)
        fname = image_filenames{i};
        split_idx = find(fname=='_');
        split_idx = split_idx(2)-1;
        parent_filenames{i} = image_filenames{i}(1:split_idx);
    end
    unique_image_names = unique(parent_filenames);
    [~,idx] = sort(unique_image_names);
    unique_image_names = unique_image_names(idx);
end
