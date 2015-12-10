[lumen_images,y_labels,filenames, imgx, imgy,~] = load_grey_data('../pictures_data/complete3_lumen/',1);
[epithileal_images,y_labels,filenames, imgx, imgy,~] = load_grey_data('../epithelial_complete3/',1);
features = lumen_features(lumen_images,epithileal_images,imgx,imgy);
tree = fitctree(features',y_labels,'CrossVal','on','KFold',3);
predictions = kfoldPredict(tree);
