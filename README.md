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

## Possibly try the following:

1. **PCA, ICA, NMF:** Apply PCA, ICA, NMF on *patches* of data. Remove most prominent eigen vector (presumably common to both classes).
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

7. **Model Patches:** Fit Gaussians for the cancer and non-cancer *patches* of data. Apply PCA/kPCA and then assign images to the class with the MLE.

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
	3. Maintiain "cancer" and "no cancer" patches.
	4. Divide test data into patches and get kNN for each patch.
	5. If any patch (> threshold) is classified as "cancer", label image as "cancer".

10. **GMMs/ Spectral Clustering:** 1 GMM per class (according to patches). Assign class that gives MLE.

11. **Deep Learning**

