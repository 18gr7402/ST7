clc
close all

%% Model på glukose mean uden tidsaspekt

%% Load data

load('hypoMeanStdOffset600');
load('nohypoDiabetesAllMeasurementsMeanStd');

%% Lav labels

hypoMeanStdUdenNAN(:,3) = ones(1:end);
nohypoMeanStd(:,4) = zeros(1:end);

%hypoMeanStdUdenNAN = hypoMeanStdUdenNAN(find(hypoMeanStdUdenNAN(:,2)~=0),:);

%% Hvis vi vil inddele i et tænings og test sæt
% cv = cvpartition(size(hypoMeanStd,1),'HoldOut',0.2);
% splitIndex = cv.test;
% % Separate to training and test data
% testHypoMeanStd  = hypoMeanStd(splitIndex,:);
% trainHypoMeanStd = hypoMeanStd(~splitIndex,:); 
% 
% cv = cvpartition(size(nohypoMeanStd,1),'HoldOut',0.2);
% splitIndex = cv.test;
% % Separate to training and test data
% testnoHypoMeanStd  = nohypoMeanStd(splitIndex,:);
% trainnoHypoMeanStd = nohypoMeanStd(~splitIndex,:); 
% 
% % Samle i tænings- og testsæt
% trainData = [trainnoHypoMeanStd;trainHypoMeanStd];
% testData = [testnoHypoMeanStd;testHypoMeanStd];

%% Sammesæt matrix
allData = [nohypoMeanStd(:,2:3);hypoMeanStdUdenNAN(:,1:2)]; % Vælg data '2':mean '3':std '2:3': Begge
trainLabelVec = [nohypoMeanStd(:,4);hypoMeanStdUdenNAN(:,3)];

%% Opdelig af data til k-fold validation

nFold = 10;
n=size(allData,1);
c = cvpartition(n,'KFold',nFold);
% Preallocation
samLabelVec=zeros(n,1);
samScoreVec=zeros(n,2);

%% cross validation loop
for foldNo=1:nFold
    %% finds index on the training and test samples
    trainIndex=find(training(c,foldNo)==1);
    testIndex=find(test(c,foldNo)==1);
    %% classify the test samples based on the traning data
    Mdl = fitcdiscr(allData(trainIndex,:),trainLabelVec(trainIndex,:));
    [mFoldLabel,mFoldScore] = predict(Mdl,allData(testIndex,:));
    %% saves results for each m-fold
    samLabelVec(testIndex,:)=mFoldLabel;
    samScoreVec(testIndex,:)=mFoldScore;
end

%% m-fold error rate
mFoldErrorVec=sum((samLabelVec-trainLabelVec)~=0)/size(trainLabelVec,1)

%% ROC curve
[X,Y,T,AUC] = perfcurve(trainLabelVec,samScoreVec(:,2),1);
figure;
plot(X,Y)
xlabel('False positive rate')
ylabel('True positive rate')
title('ROC for m-fold validation')