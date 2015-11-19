function [X_train, y_train, X_test, y_test] = split_test_train(X, y)

	ind_cancerous = find(y == 1);
	ind_cancerous = ind_cancerous(randperm(length(ind_cancerous)));

	size_train = floor(0.7*length(ind_cancerous));

	X_train = X(:,ind_cancerous(1:size_train));
	y_train = y(ind_cancerous(1:size_train));
	X_test = X(:,ind_cancerous(size_train+1:end));
	y_test = y(ind_cancerous(size_train+1:end));


	ind_noncancerous = find(y == 0);
	ind_noncancerous = ind_noncancerous(randperm(length(ind_noncancerous)));

	size_train = floor(0.7*length(ind_noncancerous));

	X_train = [X_train X(:,ind_noncancerous(1:size_train))];
	y_train = [y_train;y(ind_noncancerous(1:size_train))];
	X_test = [X_test X(:,ind_noncancerous(size_train+1:end))];
	y_test = [y_test;y(ind_noncancerous(size_train+1:end))];

end