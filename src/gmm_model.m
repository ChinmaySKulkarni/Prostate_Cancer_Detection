function [GMMModel_cancer, GMMModel_noncancer] = gmm_model(X, labels)

% Fit a 100-dimensional GMM
k = 4;


% CLASS IMBALANCE DOES NOT MATTER FOR GMM CLASSIFICATION
% Handle class imbalance to ignore some data
%{
if sum(labels==1)> sum(labels==0)
	X0 = X(labels==0);
	k = randperm(size(X,2));
	X0 = X0(:,k(1:sum(labels==1)));
	X1 = X(labels==1);
else
	X1 = X(labels==1);
	k = randperm(size(X,2));
	X1 = X1(:,k(1:sum(labels==0)));
	X0 = X(labels==0);
end
%}

size(X(:,labels == 1)')
GMMModel_cancer = gmdistribution.fit(X(:,labels == 1)',k, 'CovarianceType','diagonal','RegularizationValue',0.01);%fitgmdist(X(:,labels == 1)',k);
GMMModel_noncancer = gmdistribution.fit(X(:,labels == 0)',k, 'CovarianceType','diagonal','RegularizationValue',0.01);%fitgmdist(X(:,labels==0)', k);

end
