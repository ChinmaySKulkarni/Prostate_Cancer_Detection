[lumen_images,y_labels,filenames, imgx, imgy,~] = load_grey_data('../new_pictures_data/data4_lumen/',1);
[epithileal_images,y_labels,filenames, imgx, imgy,~] = load_grey_data('../new_pictures_data/epithelial_data4/',1);
features = lumen_features(lumen_images,filenames,epithileal_images,imgx,imgy);
tree = fitctree(features',y_labels,'CrossVal','on','KFold',5);
predictions = kfoldPredict(tree);
