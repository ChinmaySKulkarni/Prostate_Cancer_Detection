
[patch_cancer,~,~, patchx, patchy, numcolors] = load_data('../cancerous_patch3_50x50_labelled/cancer/',1);
[patch_no_cancer,~,~, patchx, patchy, numcolors] = load_data('../cancerous_patch3_50x50_labelled/no_cancer/',1);
patch_data = [patch_cancer patch_no_cancer];
patch_labels = [ones(size(patch_cancer,2),1);zeros(size(patch_no_cancer,2),1)];
[pca_coefficients,~,vars,expl] = pca_analysis(patch_data);
reduced_patch_data = pca_coefficients(:, 1:100)'*patch_data;
[X_train, y_train, X_test, y_test] = split_test_train(reduced_patch_data, patch_labels);
[GMMModel_cancer, GMMModel_noncancer] = gmm_model(X_train, y_train);
y_predicted = GMMModel_cancer.pdf(X_test') > GMMModel_noncancer.pdf(X_test');
[accuracy,precision,recall] = classifier_performance(y_test, y_predicted)
f_score = harmmean([precision;recall])