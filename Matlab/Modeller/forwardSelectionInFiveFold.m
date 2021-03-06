clear
close all
clc

%% Desciption
%Scrip for farward selection of the data chosen from
%calculateDayIntervalsAndCorrelation

%% Load data

load('dataFinalForForwardSelection5000');

% %% Make category overview OBS. skal h�jest sandsynligt ikke bruges
% 
% categorynames = dataFinal.Properties.VariableNames(1:length(dataFinal.Properties.VariableNames)-1)';
% categoryOverview = table(categorical(categorynames),grp2idx(categorical(categorynames)));

%% Split into training and test
% Skal lige tilpasses s� vi tager samme procentdel fra hver gruppe.

data = dataFinalForForwardSelection5000;

% cv = cvpartition(size(data,1),'HoldOut',0.2);
% splitIndex = cv.test;
% testSamples  = data(splitIndex,1:10);
% testLabelVec = data(splitIndex,11);
% trainSamples = data(~splitIndex,1:10);
% trainLabelVec = data(~splitIndex,11);

% Opdeling af data i 0 og 1
nFold=5;

%load('ourStandardCVPartition');
cv = cvpartition(data(:,51),'KFold',nFold,'Stratify',true);

% while ittNo>=1&&prevAuc<maxAuc
%% perform feature selection untill all features are selected

%%

for i=1:size(data,2)-1
    dataNAN(1,i) = sum(isnan(data(:,i)));
end

thresholdForExcludingNAN = 7000;

data = [data(:,find(dataNAN <=thresholdForExcludingNAN)),data(:,size(data,2))];

for foldNo=1:nFold
    %% finds index on the training and test samples
    trainIndex=find(training(cv,foldNo)==1);
    testIndex=find(test(cv,foldNo)==1);
    
    %% classify the test samples based on the traning data
    
    trainSamples = data(trainIndex,[1:size(data,2)-1]);
    testSamples = data(testIndex,[1:size(data,2)-1]);

    trainLabelVec = data(trainIndex,size(data,2));
    testLabelVec = data(testIndex,size(data,2));
% initialize parameters to keep track of the selected features  
    selectedFeatArr=zeros(1,size(data,2)-1);
    remainFeatArr=ones(1,size(data,2)-1);

    selectFeatMatrixTrain=[];
    selectFeatMatrixTest=[];
    remainFeatsInx=1:size(data,2)-1;
    ittNo=1;
    prevAuc=0;
    maxAuc=0.1;
    
while ittNo<=length(selectedFeatArr) 
    featAuc=[];
    %% finds the features that are not yet selected
    remainFeatsInx=find(remainFeatArr==1);
    %% test the feature combinations
    for featTestNo=1:length(remainFeatsInx)
        featInx=remainFeatsInx(featTestNo);
        %% makes a feature matrix for the traning data
        trainFeature=trainSamples(:,featInx);
        featSelecTestMatrxTrain=[selectFeatMatrixTrain trainFeature];
        %% makes a feature matrix for the test data
        testFeature=testSamples(:,featInx);
        featSelecTestMatrxTest=[selectFeatMatrixTest testFeature];
        
        %% classify the data using the new test feature matrix
        % Vi skal have beluttet os for en classifier, har bare tage
        % discriminant analyse
        Mdl = fitctree(featSelecTestMatrxTrain,trainLabelVec);
        [label,score] = predict(Mdl,featSelecTestMatrxTest);
        %% obtain performance metrics based on the classification
        [X,Y,T,AUC] = perfcurve(testLabelVec,score(:,1),1);
        featAuc(:,featTestNo)=AUC;


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

selectedFeatFold(foldNo,:)=selectFeatIdxItt;
selectedFeatAUCFold(foldNo,:)=selectFeatAucItt;

% plot results of the feature selection

figure;
plot(selectFeatAucItt,'ro-');hold on
xlabel('Number of features')
ylabel('AUC')


end




