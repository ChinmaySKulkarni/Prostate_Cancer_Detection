# Prostate_Cancer_Detection
CS 598 - Machine Learning for Signal Processing Project


## Some General Preliminary Observations:

### Green Images:

1. Thicker walls in the white vacuoles
2. Purple dots are generally in the walls of the white vacuoles
3. Purple dots are of larger size
4. White vacuoles are larger
5. Proportion of the image that is white (vacuole) is larger
6. Less mixed pink tissue

### Red Images:
1. Thinner walls in the white vacuoles
2. Purple dots are present outside the walls of the white vacuoles and throughout the pink parts
3. Purple dots are smaller in size
4. White vacuoles are smaller in size
5. Lower proportion of the image is accounted for by the white vacuole
6. More pink tissue
7. Epithelial nuclei (which stain blue) invade stroma (which stains light red), and lumen regions (which do not stain) remain white.
8. As the level of malignancy increases, the above characteristic is more prominent.

### Observations Mentioned in Related Work:
Normal prostate tissue consists of gland units surrounded by fibromuscular tissue, called stroma, which holds the gland units
together. Each gland unit is composed of rows of epithelial cells located around a duct, named the lumen. When cancer occurs, epithelial cells replicate in an uncontrolled way, disrupting the
regular arrangement of gland units.

1. The glands in the cancerous region become small, regular, and more tightly packed as cancer progresses from benign to highly malignant.
2. Size and roundness of the glands is an important factor in distinguishing cancerous vs. benign images.
3. As the Gleason grade increases, the glands start to fuse, become regular, tightly packed, and smaller in size. However, despite these changes, all gland regions share
   certain characteristics that can be used to identify the Gleason grade of a tissue region.
4. Use stain colors to get the different types of glands: White is lumen, pink is cytoplasm, purple dots are nuclei.
5. Benign images have large and irregular lumen regions, higher grade cancers have small, narrow lumens.
6. Use a color histogram to identify lumen glands (should be white and be surrounded by pink and purple).
7. Gleason grade 4 distributions show areas that are smaller and more uniform compared with benign epithelium, which has a wide range of large gland and lumen areas. 
   Thus, smaller and more uniform glands are more indicative of grade.

## Possibly try the following:

1. **PCA, ICA, NMF:** Apply PCA, ICA, NMF on **patches** of data. Remove most prominent eigen vector (presumably common to both classes).
NMF will probably provide best results See [Analyzing Non-Negative Matrix Factorization for Image Classification](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.19.717&rep=rep1&type=pdf).
See if any of the above observations are getting highlighted. Try PCA + ICA. ICA might be promising since it doesn't rely on a Gaussian assumption.
NMF is also promising since it is a better way to explain structured data as addition of separate features.
Use **Fischer Disriminant Analysis** instead of normal/blindly applying PCA.

2. **Kernel PCA:** Since our data is complex and too curvy (no prominent linear features) and thus not simply Gaussian, it is likely there won't be linear mappings to common features.
To get common "curvy" features (like the white vacuoles/purple dots, etc.) we need to try a non-linear transform like kernel PCA. Worth giving a shot.

3. **Edge Detection for pre-processing:** Edge detection can be used to reduce the feature space by filtering out information that might be
less relevant + intensifying structural differences like texture, variation in illumination, etc. See [Edge Detection](https://en.wikipedia.org/wiki/Edge_detection)

4. **Cross-Correlation:** Compare average Cross-correlation of data with template of green class and data to the average cross-correlation of data with template of red class.

5. **Template Matching:** Manually extract many templates for red and green data and simply do template detection on example images. Predict the label according to the
greater value of the result after applying the matched filter using both types of templates.
We can use template matching to extract the white vacuoles and their wall. From preliminary observations, one possible characteristic involves the thickness of the wall so maybe
a simple linear classifier might be able to recognize this feature after the white vacuoles + wall are extracted separately.

6. **Incorporate risk:** Incorporate risk of false negatives in the loss function (See lecture 9) for the classifier we use. Might be useful.

7. **Model Patches:** Fit Gaussians for the cancer and non-cancer **patches** of data. Apply PCA/kPCA and then assign images to the class with the MLE.

8. **Swimming Pool Detection:** Very relevant to our problem. Must try. See lecture 10. Overall methodology:
	1. Break the image into patches.
	2. Manually tag patches as "cancer", "not cancer".
	3. (Optional) Drop dimensions using PCA/kPCA.
	4. Try simple things like normalized cross-correlation (Point 4 above).
	5. Evaluate results of simple linear classifiers/Naive Bayes, etc.
	6. Try more complicated non-linear classifiers with different kernels.
	7. Try Neural Nets.
	8. Boosting + Go back to step 5

9. **kNN/Parzen Estimation:** Maybe too simple but worth a shot:
	1. Divide the training data into patches.
	2. PCA or else kNN will die.
	3. Maintain "cancer" and "no cancer" patches.
	4. Divide test data into patches and get kNN for each patch.
	5. If any patch has a probability > threshold, it is classified as "cancer", label image as "cancer".

10. **GMMs/ Spectral Clustering:** 1 GMM per class (according to patches). Assign class that gives MLE.

11. **Deep Learning**


## Related Work:

###[Automatic Classification of Prostate Cancer Gleason Scores from Multiparametric Magnetic Resonance Images](http://www.pnas.org/content/early/2015/10/28/1505935112.full.pdf)
1. Apply image segmentation to delineate cancerous and non-cancerous parts of images.
2. Extracted texture-related features using Haralick features(?)
3. Oversampled non-cancerous examples to prevent skewness (used SMOTE for this).
4. **Feature Selection and Classification:**
	1. **t-test SVM** - Selected features that were significantly different for both classes (using t tests at 95 % C.I.) and then trained an SVM.
	2. **AdaBoost** - (Did Poorly)
	3. **Recursive Feature Selection SVM (RFE-SVM)** - See [SVM-RFE](http://www.mathworks.com/matlabcentral/fileexchange/50701-feature-selection-with-svm-rfe)  (Did the best) Here the feature selection is integrated with the classifier's training and an intersection of
	features is modeled. It allows feature interactions and thus is able to explicitly model the correlation between features thus leading to robust classifier performance.
	Feature selection involved backward elimination where in each iteration, the feature that had the least impact on improving the performance of the classifier was
	removed. The algorithm continued until the desired number of features *r* was reached. An RFE-SVM is essentially a method for ranking the relative importance of a set of features such
	that the top-few features, i.e., those that remain through the longest number of iterations are chosen for training the SVM.
	4. **Evaluation:** 10-fold cross-validation, measures included accuracy, sensitivity and specificity.

###[Gland Segmentation and Computerized Gleason Grading of Prostate Histology by Integrating Low-, High-level and Domain Specific Information](http://engineering.case.edu/centers/ccipd/sites/ccipd.case.edu/files/publications/Automated-Gland-Segmentation-and-Gleason-Grading-of-Prostate-Histology-by-Integrating-Low-,-High-level-and-Domain-Specific-Information.pdf)
1. Used Graph Embedding and then SVM.
2. Used 3 classes: 1) No cancer 2) Gleason Score 3 3) Gleason Score 4
3. Developed automatic segmentation for various parts of the image (Lumen, Epithelial Cytoplasm and Epithelial Nuclei).
4. Gland Detection -> Gland Segmentation -> Morphological Feature Extraction -> Manifold Learning -> Classification -> Evaluation.
5. **Gland Detection:** Used pixel-wise classification. Specific arrangement of the strucutre:**Lumen is surrounded by cytoplasm which is surrounded by a ring of nuclei.**
   They use a Bayesian classifier that learns based on pixels from the before-mentioned 3 types of glands (multi-class classification). They use 600 manually denoted pixels from
   each class for training. Thus they get a **pixel-wise likelihood** of belonging to either lumen, cytoplasm or nuclei. Incorporated gland size to actual lumen structures.
6. **Gland Segmentation:** Done after the gland lumen are found using above step.
7. **Feature Extraction:** Use manually chosen morphological features for a set of pixels lying on a contiguous region of an image::
	1. Area overlap ratio
	2. Distance ratio
	3. Standard Deviation
	4. Variance
	5. Perimeter Ratio
	6. Compactness
	7. Smoothness
	8. Area
8. **Manifold Learning:** Did dimensionality reduction using graph embedding (has been used by others for this task before as well).
9. **Classification:** Used an SVM with a Gaussian kernel to classify images to one of 3 classes mentioned in point 2.

###[Multifeature Prostate Cancer Diagnosis and Gleason Grading of Histological Images](http://claymore.rfmh.org/~atabesh/papers/tabesh_tmi07_final.pdf)
1. Use color, texture and morphological features.
2. Provide a good section of related work and useful summaries of other approaches.
3. Compare the results of a Gaussian class-conditional Bayesian classifier, k-NN and SVM. Got an accuracy of approximately 97%.
4. **Pre-processing:**
	1. Removed background (Transparent white regions at the corners of the image **TODO**) - Done by thresholding pixels for the value of the background (pure white in our case).
	2. Removed color variations due to staining.
5. **Feature Extraction:**
	1. **Color Channel Histograms** - There is a noticeble change in image color as tissue transforms from benign to cancerous. Observed color histogram of benign vs. less malignant vs.
	more malignant images. The histogram shifts towards blue as the level of malignancy increases. **Removing white pixels (lumen) improved classification performance**.
	2. **Texture Features** - The change in the texture as the tissue progresses towards malignancy:
	The texture becomes finer as the epithelial nuclei spread across the tissue. The connection between the texture characteristics of
	the tissue and the level of tumor malignancy has been confirmed in several studies. Used **fractal dimension features, fractal code features, wavelet transform features, etc.**
6. **Classification:** Evaluated Bayesian, kNN and SVM classifiers.


## Experiments
List the various methods tried and the results from each of the methods
1. Train Gaussian Mixture Model on cancerous and non-cancerous patches. For a
   new unlabelled patch, use the mixture models of the positive and negative
   classes to predict whether an incoming patch is cancerous/non-cancerous.
   Since each patch is 50x50x3 , different types of dimensionality reduction
   approaches were tried:
   - Used PCA, the first 1000 principal components explained about 99% variance
     in the raw patch data. But since we do not have that many patches while
     training the classifier, we had to restrict ourselves to far fewer
     principal components, With just PCA dimensionality reduction, we got the
     following results:
     With 75 principal components explaining % variance
     With a 70-30 train test split with 177/722 cancerous patches in the
     training, and using the GMM classifier we got the following performance on
     the labelled test patches:
     Accuracy : 72-76%
     Precision : ~0.0.3-0.5
     Recall : ~0.3
     F-score : 0.3-0.4
     Per Image Prediction
     Total      Labelled 
     Patches    Cancerous
     63         4
     64         41
     56         0
     56         6
     61         18
     60         15
     60         17
     59         20
     58         10
     60         6
     63         32
     62         8
     
    predicted_stats    
         
    20
    17
    17
    17
    17
    19
    21
    13
     8
     9
    11
    11

    But with prediction on on-cancerous unlabelled data, there are far more
    false positives per image.

    With 100 principal components :
    Accuracy : 78%
    Precision : 0.54
    Recall : 0.41
    Fscore : 0.49

    Per Image Prediction

    predicted_stats =

    18
    19
    13
    17
    25
    16
    21
    13
     9
     9
    11
    13    

    But between successive runs there is a lot more variation.

   - Used NMF dimensionality reduction on the data, using the first 100 analysis 
     features and with the same prediction as above but very disappointing results

[TODOs in this approach]

   - Use textre features extracted from [Reference paper here] in addition to
     the features obtained after dimensionality reduction. This did not yield
     significant improvement in results. 
     
   - Use Gaussian Pyramid subsampled patches for the GMM classifier. Subsampled
     at levels 1 and 2. However, with the reduction in pixels,No longer possible to use 
     GMM classifer.
          
Try out the following maybe [TODO]:
- Gray level co-occurence matrix for detection of texture to detect epithilial
  cells
- Wavelet analysis for image segmentation ??
- Extract epithileal cells texture using repeated opening closing
- Follow an approach similar to the one in the above paper where we extract the number
  of lumen objects, number of epithilial cells etc and extract features based on that
  (basically segment the image based on object distribution) and then create features
  out of that and then apply the classifier.


## TODO

**NOTE: Get accuracy after applying each of the below steps (after adding each feature) incrementally. This will help us to identify which features are actually helping and which are actually
messing up the accuracy.**

1. Add Haralick Features (try with different number of features).
2. Histrogram shift towards blue for cancerous images. (Use KL-Divergence between image histogram and blue channel histrogram to determine this).
3. Background removal using successive closing operations.
4. Better segmentation for Epithelial Cells: Use K-means/DBScan for epithelial cell detection and try for different k values/(minPts and epsilon values).
 1. Do parameter tuning to get best number of k and minPts/epsilon by comparing silhouette values (see kmeans man page for matlab) or basically by using that k for which
    you get the highest value of intra-cluster similarity vs. inter-cluster similarity.
 2. To figure out which cluster belongs to epithelial cells, simple dot product/other similarity measure can be used with a set of manually chosen images that are epithelial cells.
5. Try better segmentation for Lumen.
6. Try representing the images in higher dimensional space (kernel SVM), and apply PCA in that higher dimensional space(?). Alternatively, we can try applying kernel PCA
at the original dimensionality of the image data.
7. Try other classifiers apart from CART.

