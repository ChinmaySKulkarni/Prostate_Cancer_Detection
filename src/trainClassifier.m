function [trainedClassifier, validationAccuracy] = trainClassifier(datasetTable)
% Convert input to table
datasetTable = table(datasetTable');
datasetTable.Properties.VariableNames = {'row'};
% Split matrices in the input table into vectors
datasetTable.row_1 = datasetTable.row(:,1);
datasetTable.row_2 = datasetTable.row(:,2);
datasetTable.row_3 = datasetTable.row(:,3);
datasetTable.row_4 = datasetTable.row(:,4);
datasetTable.row_5 = datasetTable.row(:,5);
datasetTable.row_6 = datasetTable.row(:,6);
datasetTable.row_7 = datasetTable.row(:,7);
datasetTable.row_8 = datasetTable.row(:,8);
datasetTable.row_9 = datasetTable.row(:,9);
datasetTable.row_10 = datasetTable.row(:,10);
datasetTable.row_11 = datasetTable.row(:,11);
datasetTable.row_12 = datasetTable.row(:,12);
datasetTable.row_13 = datasetTable.row(:,13);
datasetTable.row = [];
% Extract predictors and response
predictorNames = {'row_1', 'row_2', 'row_3', 'row_4', 'row_5', 'row_6', 'row_7', 'row_8', 'row_9', 'row_10', 'row_11', 'row_12'};
predictors = datasetTable(:,predictorNames);
predictors = table2array(varfun(@double, predictors));
response = datasetTable.row_13;
% Train a classifier
trainedClassifier = fitcsvm(predictors, response, 'KernelFunction', 'gaussian', 'PolynomialOrder', [], 'KernelScale', 3.500000e+00, 'BoxConstraint', 1, 'Standardize', 1, 'PredictorNames', {'row_1' 'row_2' 'row_3' 'row_4' 'row_5' 'row_6' 'row_7' 'row_8' 'row_9' 'row_10' 'row_11' 'row_12'}, 'ResponseName', 'row_13', 'ClassNames', [0 1]);

% Perform cross-validation
partitionedModel = crossval(trainedClassifier, 'KFold', 5);

% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');

%% Uncomment this section to compute validation predictions and scores:
% % Compute validation predictions and scores
% [validationPredictions, validationScores] = kfoldPredict(partitionedModel);