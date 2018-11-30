close all
clc
clearvars -except resulterendeFeatures resulterendeAUC idx

%% Desciption
%Scrip for forward selection of the data 

%% Load data
load('dataFinalForForwardSelection5000');

%% Data til matrix fra tabel
data = dataFinalForForwardSelection5000(1:10800,:); %Vi fjerner 2 samples så vi kan inddele i fem lige store grupper

%% Antal folds
nFold=5;

%% Fjern dem med for mange NAN
for i=1:size(data,2)-1
    dataNAN(1,i) = sum(isnan(data(:,i)));
end

thresholdForExcludingNAN = 8000;
data = [data(:,find(dataNAN <=thresholdForExcludingNAN)),data(:,size(data,2))];

%% Parametre der skal sættes
stopCriterion = 15;
numberOfForwardSelections = 1;

for i=1:numberOfForwardSelections
%% Bestem om vi vil køre med vores standard cv eller er ny random
    cv = cvpartition(data(:,size(data,2)), 'KFold',nFold,'Stratify',true);

%% perform feature selection untill all features are selected

% initialize parameters to keep track of the selected features  
    selectedFeatArr=zeros(1,size(data,2)-1);
    remainFeatArr=ones(1,size(data,2)-1);

    selectFeatMatrixTrain=[];
    selectFeatMatrixTest=[];
    remainFeatsInx=1:size(data,2)-1;
    ittNo=1;
    prevAuc=0;
    maxAuc=0.1;
    
while ittNo<=stopCriterion
    featAuc=[];
    %% finds the features that are not yet selected
    remainFeatsInx=find(remainFeatArr==1);
    %% test the feature combinations
    for featTestNo=1:length(remainFeatsInx)
        
        featInx=remainFeatsInx(featTestNo);
        
        for foldNo=1:nFold
        %% finds index on the training and test samples
        trainIndex=find(training(cv,foldNo)==1);
        testIndex=find(test(cv,foldNo)==1);
    
        %% classify the test samples based on the traning data
    
        trainSamples = data(trainIndex,[1:size(data,2)-1]);
        testSamples = data(testIndex,[1:size(data,2)-1]);

        trainLabelVec = data(trainIndex,size(data,2));
        testLabelVec = data(testIndex,size(data,2));
        %% makes a feature matrix for the traning data
        trainFeature=trainSamples(:,featInx);
        featSelecTestMatrxTrain=[selectFeatMatrixTrain trainFeature];
        %% makes a feature matrix for the test data
        testFeature=testSamples(:,featInx);
        featSelecTestMatrxTest=[selectFeatMatrixTest testFeature];
        
        %% classify the data using the new test feature matrix
        % Vi skal have beluttet os for en classifier, har bare tage
        % discriminant analyse
        Mdl = fitcsvm(featSelecTestMatrxTrain,trainLabelVec);
        [label,score] = predict(Mdl,featSelecTestMatrxTest);
        %% obtain performance metrics based on the classification
        [X,Y,T,AUC] = perfcurve(testLabelVec,score(:,1),1);
        foldAUC(:,foldNo) = AUC;
        end
        featAuc(:,featTestNo)=mean(foldAUC);
    end
    prevAuc=maxAuc;
    %% finds the best feature combination and store the results
    [maxAuc,maxIndex]=max(featAuc);
    
    selectFeatInx=remainFeatsInx(maxIndex);    
    selectedFeatArr(selectFeatInx)=1;
    remainFeatArr(selectFeatInx)=0;
    %% makes a feature matrix for the selected features for the next iteration
    selectFeatMatrixTrain=[selectFeatMatrixTrain trainSamples(:,selectFeatInx)];
    selectFeatMatrixTest=[selectFeatMatrixTest testSamples(:,selectFeatInx)];
    %% summary of which features are selected and the obtained AUCS
    selectFeatIdxItt(ittNo)=selectFeatInx;
    selectFeatAucItt(ittNo)=maxAuc;
    ittNo=ittNo+1;
end

resulterendeFeatures(idx,:) = selectFeatIdxItt;
resulterendeAUC(idx,:) = selectFeatAucItt;

idx = idx + 1;
end







