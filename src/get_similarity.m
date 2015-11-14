function avg_similarity = get_similarity(test_ex,low_dim_patches)
    [~,num_patches] = size(low_dim_patches);
    avg_similarity = 0;
    for j=1:num_patches
        similarity = dot(test_ex,low_dim_patches(:,j));
        avg_similarity = avg_similarity + similarity;
    end
    avg_similarity = avg_similarity/num_patches;
end