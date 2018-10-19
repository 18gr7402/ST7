clc
close all
clear

%% Test af flere modeller på data.

%% Load data

load('hypoMeanStdOffset600');
load('nohypoDiabetesAllMeasurementsMeanStd');

%% Lav labels

hypoMeanStdUdenNAN(:,3) = ones(1:end);
nohypoMeanStd(:,4) = zeros(1:end);
hypoMeanStdUdenNAN = hypoMeanStdUdenNAN(find(hypoMeanStdUdenNAN(:,2)~=0),:);

%% Sammesæt matrix
allData = [nohypoMeanStd(:,2:3);hypoMeanStdUdenNAN(:,1:2)]; % Vælg data '2' og '1':mean '3' og '2':std '2:3' og '1:2': Begge
trainLabelVec = [nohypoMeanStd(:,4);hypoMeanStdUdenNAN(:,3)];

%% Scatter
gscatter(allData(:,1),allData(:,2),trainLabelVec,'rgb','osd');
xlabel('Mean');
ylabel('Standard deviation');

%% Histrogram

classIndex = [0,0];
classIdx=find(trainLabelVec==0);
classIndex(1,1)=length(classIdx);
classIndex(1,2)=length(allData);

figure;
subplot(2,1,1)
h1_SL = histogram(allData(1:classIndex(1),1));
hold on
h2_SL = histogram(allData(classIndex(1)+1:classIndex(2),1));
hold on 
title('Feature 1: Mean');
legend([h1_SL, h2_SL],{'No Hypo','Hypo'});

subplot(2,1,2)
h1_SL = histogram(allData(1:classIndex(1),2));
hold on
h2_SL = histogram(allData(classIndex(1)+1:classIndex(2),2));
hold on 
title('Feature 2: Standard deviation');
legend([h1_SL, h2_SL],{'No Hypo','Hypo'});

%% Opdelig af data til k-fold validation

nFold = 2;
n=size(allData,1);
c = cvpartition(n,'KFold',nFold);

% Preallocation
field1 = 'classifier1';
field2 = 'classifier2';
field3 = 'classifier3';
field4 = 'classifier4';
field5 = 'classifier5';

samLabelVec = struct(field1,zeros(n,1),field2,zeros(n,1),field3,zeros(n,1),field4,zeros(n,1),field5,zeros(n,1));
samScoreVec = struct(field1,zeros(n,2),field2,zeros(n,2),field3,zeros(n,2),field4,zeros(n,2),field5,zeros(n,2));

%% Classification names
classifier_name = {'Naive Bayes','Discriminant Analysis','Classification Tree','Nearest Neighbor','Support Vector Machine'};

%% Cross validation loop
for foldNo=1:nFold
    % finds index on the training and test samples
    trainIndex=find(training(c,foldNo)==1);
    testIndex=find(test(c,foldNo)==1);
    % classify the test samples based on the traning data
    X = allData(trainIndex,:);
    y = trainLabelVec(trainIndex,:);
    %[class,err] = classify(dataTestNoLable,X, groupTR);
% Train a naive Bayes model.
classifier{1} = fitcnb(X,y);
%Train a discriminant analysis classifier.
classifier{2} = fitcdiscr(X,y);
%Train a classification decision tree.
classifier{3} = fitctree(X,y);
%Train a k-nearest neighbor classifier.
classifier{4} = fitcknn(X,y);
%Train a support vector machine
classifier{5} = fitcsvm(X,y);

   [mFoldLabel,mFoldScore] = predict(classifier{1},allData(testIndex,:));
   % saves results for each m-fold
   samLabelVec.classifier1(testIndex,:)=mFoldLabel;
   samScoreVec.classifier1(testIndex,:)=mFoldScore;
   
   [mFoldLabel,mFoldScore] = predict(classifier{2},allData(testIndex,:));
   % saves results for each m-fold
   samLabelVec.classifier2(testIndex,:)=mFoldLabel;
   samScoreVec.classifier2(testIndex,:)=mFoldScore;
   
   [mFoldLabel,mFoldScore] = predict(classifier{3},allData(testIndex,:));
   % saves results for each m-fold
   samLabelVec.classifier3(testIndex,:)=mFoldLabel;
   samScoreVec.classifier3(testIndex,:)=mFoldScore;
   
   [mFoldLabel,mFoldScore] = predict(classifier{4},allData(testIndex,:));
   % saves results for each m-fold
   samLabelVec.classifier4(testIndex,:)=mFoldLabel;
   samScoreVec.classifier4(testIndex,:)=mFoldScore;
   
   [mFoldLabel,mFoldScore] = predict(classifier{5},allData(testIndex,:));
   % saves results for each m-fold
   samLabelVec.classifier5(testIndex,:)=mFoldLabel;
   samScoreVec.classifier5(testIndex,:)=mFoldScore;

end

%% K-fold error rate
kFoldErrorVecClassifier1=sum((samLabelVec.classifier1-trainLabelVec)~=0)/size(trainLabelVec,1);
kFoldErrorVecClassifier2=sum((samLabelVec.classifier2-trainLabelVec)~=0)/size(trainLabelVec,1);
kFoldErrorVecClassifier3=sum((samLabelVec.classifier3-trainLabelVec)~=0)/size(trainLabelVec,1);
kFoldErrorVecClassifier4=sum((samLabelVec.classifier4-trainLabelVec)~=0)/size(trainLabelVec,1);
kFoldErrorVecClassifier5=sum((samLabelVec.classifier4-trainLabelVec)~=0)/size(trainLabelVec,1);

%% ROC curve
figure;
[X,Y,T,AUC] = perfcurve(trainLabelVec,samScoreVec.classifier1(:,2),1);
subplot(3,2,1)
plot(X,Y)
title([classifier_name{1},', AUC = ',num2str(AUC)])
xlabel('False positive rate')
ylabel('True positive rate')
AUCClassifier1 = AUC;

[X,Y,T,AUC] = perfcurve(trainLabelVec,samScoreVec.classifier2(:,2),1);
subplot(3,2,2)
plot(X,Y)
title([classifier_name{2},', AUC = ',num2str(AUC)])
xlabel('False positive rate')
ylabel('True positive rate')
AUCClassifier2 = AUC;

[X,Y,T,AUC] = perfcurve(trainLabelVec,samScoreVec.classifier3(:,2),1);
subplot(3,2,3)
plot(X,Y)
title([classifier_name{3},', AUC = ',num2str(AUC)])
xlabel('False positive rate')
ylabel('True positive rate')
AUCClassifier3 = AUC;

[X,Y,T,AUC] = perfcurve(trainLabelVec,samScoreVec.classifier4(:,2),1);
subplot(3,2,4)
plot(X,Y)
title([classifier_name{4},', AUC = ',num2str(AUC)])
xlabel('False positive rate')
ylabel('True positive rate')
AUCClassifier4 = AUC;

[X,Y,T,AUC] = perfcurve(trainLabelVec,samScoreVec.classifier5(:,2),1);
subplot(3,2,5)
plot(X,Y)
title([classifier_name{5},', AUC = ',num2str(AUC)])
xlabel('False positive rate')
ylabel('True positive rate')
AUCClassifier5 = AUC;
