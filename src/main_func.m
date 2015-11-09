function main_func()
% runs the pgrogram
    % load the data for the green dataset
    [image_data,y_labels,filenames, img_x, img_y, numcolors] = load_data('../pictures/complete3/',0.4);
    show_data(image_data,filenames,img_x,img_y,numcolors);
    [pca_coefficients,pca_projections,variances] = pca_analysis(image_data,img_x,img_y,numcolors);
    train_data = image_data(:,1:20);
    train_labels = y_labels(1:20);
    test_data = image_data(:,21:end);
    test_labels = y_labels(21:end);
    svm_train = svmtrain(train_data.',train_labels,'showplot',true);
    svm_predict = svmclassify(svm_train,test_data.');
    test_labels
    svm_predict
    
    
end