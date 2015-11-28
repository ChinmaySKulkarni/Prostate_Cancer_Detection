function[pca_coefficients, pca_projections, variances, explained] =  pca_analysis( image_data)
%PCA_ANALYSIS This function does pca analysis on the image data and returns
%the pca projections, the coefficients , and the variances.
    [pca_coefficients,pca_projections,variances,~,explained,~] = pca(image_data.');
    
    % plot the variances
end

