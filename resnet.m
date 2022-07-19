clear all;
close all;
clc;
image_folder =  "D:\dataset\segment3";  % give the path of the folder where your images are present
imds = imageDatastore(image_folder, 'LabelSource', 'foldernames', 'IncludeSubfolders',true);
tbl=countEachLabel(imds);

% Load pretrained network
net = resnet50();

[trainingSet, testSet] = splitEachLabel(imds, 0.3, 'randomize');

% Create augmentedImageDatastore from training and test sets to resize
% images in imds to the size required by the network.
imageSize = net.Layers(1).InputSize;
augmentedTrainingSet = augmentedImageDatastore(imageSize, trainingSet, 'ColorPreprocessing','gray2rgb');
augmentedTestSet = augmentedImageDatastore(imageSize, testSet, 'ColorPreprocessing','gray2rgb');


% Get the network weights for the second convolutional layer
w1 = net.Layers(2).Weights;

% Scale and resize the weights for visualization
w1 = mat2gray(w1);
w1 = imresize(w1,5); 
featureLayer = 'fc1000';
trainingFeatures = activations(net, augmentedTrainingSet, featureLayer,'MiniBatchSize', 32, 'OutputAs', 'columns');

% Get training labels from the trainingSet
trainingLabels = trainingSet.Labels;

% Train multiclass SVM classifier using a fast linear solver, and set
% 'ObservationsIn' to 'columns' to match the arrangement used for training
% features.
classifier = fitcecoc(trainingFeatures, trainingLabels,'Learners', 'Linear', 'Coding', 'onevsall', 'ObservationsIn', 'columns');

% Extract test features using the CNN
testFeatures = activations(net, augmentedTestSet, featureLayer,'MiniBatchSize', 32, 'OutputAs', 'columns');

% Pass CNN image features to trained classifier
predictedLabels = predict(classifier, testFeatures, 'ObservationsIn', 'columns');

% Get the known labels
testLabels = testSet.Labels;

% Tabulate the results using a confusion matrix.
confMat = confusionmat(testLabels, predictedLabels);
cmt = confMat';
plotconfusion(testLabels, predictedLabels)

diagonal = diag(cmt);
sum_of_rows = sum(cmt, 2);

precision = diagonal ./ sum_of_rows;
overall_precision = mean(precision);

sum_of_columns = sum(cmt, 1);

recall = diagonal ./ sum_of_columns';
overall_recall = mean(recall);

f1_score = 2*((overall_precision*overall_recall)/(overall_precision+overall_recall));

% Convert confusion matrix into percentage form
confMat = bsxfun(@rdivide,confMat,sum(confMat,2));

% Display the mean accuracy
mean(diag(confMat))

testImage = readimage(testSet,1);
testLabel = testSet.Labels(1);


% Create augmentedImageDatastore to automatically resize the image when
% image features are extracted using activations.
ds = augmentedImageDatastore(imageSize, testImage, 'ColorPreprocessing', 'gray2rgb');

% Extract image features using the CNN
imageFeatures = activations(net, ds , featureLayer, 'OutputAs', 'columns');



% Make a prediction using the classifier
predictedLabel = predict(classifier, imageFeatures, 'ObservationsIn', 'columns');