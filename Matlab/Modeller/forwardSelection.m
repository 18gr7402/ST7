clear
close all
clc

%% Desciption
%Scrip for farward selection of the data chosen from
%calculateDayIntervalsAndCorrelation

%% Load data

load('dataFinalForForwardSelectionTestThreashold300');

% %% Make category overview OBS. skal højest sandsynligt ikke bruges
% 
% categorynames = dataFinal.Properties.VariableNames(1:length(dataFinal.Properties.VariableNames)-1)';
% categoryOverview = table(categorical(categorynames),grp2idx(categorical(categorynames)));

%% Split into training and test
% Skal lige tilpasses så vi tager samme procentdel fra hver gruppe.

data = table2array(dataFinal);
data(isnan(data))=0;

cv = cvpartition(size(data,1),'HoldOut',0.2);
splitIndex = cv.test;
testSamples  = data(splitIndex,1:10);
testLabelVec = data(splitIndex,11);
trainSamples = data(~splitIndex,1:10);
trainLabelVec = data(~splitIndex,11);


%% initialize parameters to keep track of the selected features
selectedFeatArr=zeros(1,size(trainSamples,2));
remainFeatArr=ones(1,size(trainSamples,2));

selectFeatMatrixTrain=[];
selectFeatMatrixTest=[];
remainFeatsInx=1:size(testSamples,2);
ittNo=1;
prevAuc=0;
maxAuc=0.1;

% while ittNo>=1&&prevAuc<maxAuc
%% perform feature selection untill all features are selected
while ittNo<=length(selectedFeatArr) 
    featAuc=[];
    %% finds the features that are not yet selected
    remainFeatsInx=find(remainFeatArr==1)
    %% test the feature combinations
    for featTestNo=1:length(remainFeatsInx)
        featInx=remainFeatsInx(featTestNo)
        %% makes a feature matrix for the traning data
        trainFeature=trainSamples(:,featInx);
        featSelecTestMatrxTrain=[selectFeatMatrixTrain trainFeature];
        %% makes a feature matrix for the test data
        testFeature=testSamples(:,featInx);
        featSelecTestMatrxTest=[selectFeatMatrixTest testFeature];
        
        %% classify the data using the new test feature matrix
        % Vi skal have beluttet os for en classifier, har bare tage
        % discriminant analyse
        Mdl = fitcdiscr(featSelecTestMatrxTrain,trainLabelVec);
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

%% plot results of the feature selection
figure;
plot(selectFeatAucItt,'ro-');hold on
xlabel('Number of features')
ylabel('AUC')

