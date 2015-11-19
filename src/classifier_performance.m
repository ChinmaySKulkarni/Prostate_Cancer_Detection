function [accuracy,precision,recall] = classifier_performance(test_labels,predict_labels)
    tp = 0; 
    fp = 0;
    fn = 0;
    tn = 0;
    for i =1:numel(predict_labels)
        if predict_labels(i)==1
            if predict_labels(i)==test_labels(i)
                tp = tp+1;
            else 
                fp = fp+1;
            end
        else
            if predict_labels(i)==test_labels(i)
                tn = tn+1;
            else
                fn = fn+1;
            end
        end
    end
    precision = tp/(tp+fp);
    recall = tp/(tp+fn);
    accuracy = (tp+tn)/(fp+fn+tp+tn);
end