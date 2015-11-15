function[pca_coefficients, pca_projections, variances] =  pca_analysis( image_data)
%PCA_ANALYSIS This function does pca analysis on the image data and tries
% to project it do dimensions
    [pca_coefficients,pca_projections,variances,~,~,~] = pca(image_data.');
    
    % plot the variances
end

