%% Script til at vælge en classier til forward selection

%Man skal loade workspacet correlationWithSubfeatures
%% Vælg de endelige features og gør data klar til at eksportere

numberOfChosenFeatures = 10;
 
correlationCategoryOverview = [categoryOverviewAfterNANExclusion];
 
[~,idx] = sort(correlationCategoryOverview(:,3),'descend');
correlationCategoryFinal = correlationCategoryOverview(idx,:);
correlationCategoryFinal = correlationCategoryFinal(1:numberOfChosenFeatures,:);

%LAPPELØSNING
correlationCategoryFinal(4,1) = 'Minbedsideglucose';
correlationCategoryFinal(5,1) = 'Variancebedsideglucose';
correlationCategoryFinal(8,1) = 'Rangebedsideglucose';
correlationCategoryFinal(9,1) = 'Stdbedsideglucose';

finalFeatures = correlationCategoryFinal(:,2);
finalFeatures = char(finalFeatures);
 
varNames = [cellstr(string(correlationCategoryFinal(:,1))'),'Label'];
 
% % %Sorry, dette er ikke smart. MEN det er ikke tiden værd at finde ud af
% % %dette. Antallet af variable skal skrives manuelt.

dataFinal = table(dataSamlet(:,finalFeatures(1)),dataSamlet(:,finalFeatures(2)),dataSamlet(:,finalFeatures(3)),dataSamlet(:,finalFeatures(4)),dataSamlet(:,finalFeatures(5)),dataSamlet(:,finalFeatures(6)),dataSamlet(:,finalFeatures(7)),dataSamlet(:,finalFeatures(8)),dataSamlet(:,finalFeatures(9)),dataSamlet(:,finalFeatures(10)),dataSamlet(:,size(dataSamlet,2)),'VariableNames',varNames);

%% Split into training and test
% Skal lige tilpasses så vi tager samme procentdel fra hver gruppe.

data = table2array(dataFinal);

% Opdeling af data i 0 og 1
dataTemp1 = data(logical(data(:,11)),:); 
dataTemp0 = data(logical(~data(:,11)),:);

% Det sikres, at vi har samples med label 1 i vores partitions
nFold = 5;
cv = cvpartition(dataFinal.Label, 'KFold',nFold,'Stratify',true)


%% cross validation loop (Fra MM6 i PRDS: mm6exerciseSolution)

for foldNo=1:nFold
    %% finds index on the training and test samples
    trainIndex=find(training(cv,foldNo)==1);
    testIndex=find(test(cv,foldNo)==1);
    %% classify the test samples based on the traning data
    Mdl = fitcknn(dataFinal(trainIndex,[1:10]),dataFinal.Label(trainIndex,:));
    [mFoldLabel,mFoldScore] = predict(Mdl,dataFinal(testIndex,[1:10]));
    %% saves results for each m-fold
    samLabelVec(testIndex,:)=mFoldLabel;
    samScoreVec(testIndex,:)=mFoldScore;
end
%% m-fold error rate
mFoldErrorVec=sum((samLabelVec-dataFinal.Label)~=0)/size(dataFinal.Label,1);

%Vi ser for det første at mFoldLabel indeholder ene af nuller.
%Vi ser for det andet at mFoldSore indeholder to kolonner med ene af
%NAN-værdier
