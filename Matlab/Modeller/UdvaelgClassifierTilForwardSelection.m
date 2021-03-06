%% Script til at v�lge en classier til forward selection

%Man skal loade workspacet correlationWithSubfeatures
%% V�lg de endelige features og g�r data klar til at eksportere

numberOfChosenFeatures = 10;
 
correlationCategoryOverview = [categoryOverviewAfterNANExclusion];
 
[~,idx] = sort(correlationCategoryOverview(:,3),'descend');
correlationCategoryFinal = correlationCategoryOverview(idx,:);
correlationCategoryFinal = correlationCategoryFinal(1:numberOfChosenFeatures,:);

%LAPPEL�SNING
correlationCategoryFinal(4,1) = 'Minbedsideglucose';
correlationCategoryFinal(5,1) = 'Variancebedsideglucose';
correlationCategoryFinal(8,1) = 'Rangebedsideglucose';
correlationCategoryFinal(9,1) = 'Stdbedsideglucose';

finalFeatures = [659 710 558 709 557 51 203 1013 405 406];
 
varNames = [cellstr(string(correlationCategoryFinal(:,1))'),'Label'];
 
% % %Sorry, dette er ikke smart. MEN det er ikke tiden v�rd at finde ud af
% % %dette. Antallet af variable skal skrives manuelt.

dataFinal = table(dataSamlet(:,finalFeatures(1,1)),dataSamlet(:,finalFeatures(1,2)),dataSamlet(:,finalFeatures(1,3)),dataSamlet(:,finalFeatures(1,4)),dataSamlet(:,finalFeatures(1,5)),dataSamlet(:,finalFeatures(1,6)),dataSamlet(:,finalFeatures(1,7)),dataSamlet(:,finalFeatures(1,8)),dataSamlet(:,finalFeatures(1,9)),dataSamlet(:,finalFeatures(1,10)),dataSamlet(:,size(dataSamlet,2)),'VariableNames',varNames);

%% Split into training and test
% Skal lige tilpasses s� vi tager samme procentdel fra hver gruppe.

data = table2array(dataFinal);

% Det sikres, at vi har samples med label 1 i vores partitions
nFold = 5;
cv = cvpartition(dataFinal.Label, 'KFold',nFold,'Stratify',true)

% Preallocation
field1 = 'classifier1';
field2 = 'classifier2';
field3 = 'classifier3';
field4 = 'classifier4';
field5 = 'classifier5';
field6 = 'classifier6';
n= size(dataFinal,1);
samLabelVec = struct(field1,zeros(n,1),field2,zeros(n,1),field3,zeros(n,1),field4,zeros(n,1),field5,zeros(n,1),field6,zeros(n,1));
samScoreVec = struct(field1,zeros(n,2),field2,zeros(n,2),field3,zeros(n,2),field4,zeros(n,2),field5,zeros(n,2),field6,zeros(n,2));


%% cross validation loop (Fra MM6 i PRDS: mm6exerciseSolution)

for foldNo=1:nFold
    %% finds index on the training and test samples
    trainIndex=find(training(cv,foldNo)==1);
    testIndex=find(test(cv,foldNo)==1);
    %% classify the test samples based on the traning data
    
    X = dataFinal(trainIndex,[1:10]);
    y = dataFinal.Label(trainIndex,:);
    
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
mdTreebag = ClassificationTree.template('NVarToSample','all','surrogate','on');
classifier{6} = fitensemble(X,y,'Bag',150,mdTreebag,'type','classification');


   [mFoldLabel,mFoldScore] = predict(classifier{1},dataFinal(testIndex,[1:10]));
   % saves results for each m-fold
   samLabelVec.classifier1(testIndex,:)=mFoldLabel;
   samScoreVec.classifier1(testIndex,:)=mFoldScore;
   
   [mFoldLabel,mFoldScore] = predict(classifier{2},dataFinal(testIndex,[1:10]));
   % saves results for each m-fold
   samLabelVec.classifier2(testIndex,:)=mFoldLabel;
   samScoreVec.classifier2(testIndex,:)=mFoldScore;
   
   [mFoldLabel,mFoldScore] = predict(classifier{3},dataFinal(testIndex,[1:10]));
   % saves results for each m-fold
   samLabelVec.classifier3(testIndex,:)=mFoldLabel;
   samScoreVec.classifier3(testIndex,:)=mFoldScore;
   
   [mFoldLabel,mFoldScore] = predict(classifier{4},dataFinal(testIndex,[1:10]));
   % saves results for each m-fold
   samLabelVec.classifier4(testIndex,:)=mFoldLabel;
   samScoreVec.classifier4(testIndex,:)=mFoldScore;
   
      [mFoldLabel,mFoldScore] = predict(classifier{5},dataFinal(testIndex,[1:10]));
   % saves results for each m-fold
   samLabelVec.classifier5(testIndex,:)=mFoldLabel;
   samScoreVec.classifier5(testIndex,:)=mFoldScore;
   
      [mFoldLabel,mFoldScore] = predict(classifier{6},dataFinal(testIndex,[1:10]));
   % saves results for each m-fold
   samLabelVec.classifier6(testIndex,:)=mFoldLabel;
   samScoreVec.classifier6(testIndex,:)=mFoldScore;
end
%% m-fold error rate
mFoldErrorVec(1,1)=sum((samLabelVec.classifier1-dataFinal.Label)~=0)/size(dataFinal.Label,1);
mFoldErrorVec(2,1)=sum((samLabelVec.classifier2-dataFinal.Label)~=0)/size(dataFinal.Label,1);
mFoldErrorVec(3,1)=sum((samLabelVec.classifier3-dataFinal.Label)~=0)/size(dataFinal.Label,1);
mFoldErrorVec(4,1)=sum((samLabelVec.classifier4-dataFinal.Label)~=0)/size(dataFinal.Label,1);
mFoldErrorVec(5,1)=sum((samLabelVec.classifier5-dataFinal.Label)~=0)/size(dataFinal.Label,1);
mFoldErrorVec(6,1)=sum((samLabelVec.classifier6-dataFinal.Label)~=0)/size(dataFinal.Label,1);

PR(1,:) = Evaluate(samLabelVec.classifier1,dataFinal.Label);
PR(2,:) = Evaluate(samLabelVec.classifier2,dataFinal.Label);
PR(3,:) = Evaluate(samLabelVec.classifier3,dataFinal.Label);
PR(4,:) = Evaluate(samLabelVec.classifier4,dataFinal.Label);
PR(5,:) = Evaluate(samLabelVec.classifier5,dataFinal.Label);
PR(6,:) = Evaluate(samLabelVec.classifier6,dataFinal.Label);

%% ROC curve
[X1,Y1,T1,AUC1] = perfcurve(dataFinal.Label,samScoreVec.classifier1(:,2),1);
[X2,Y2,T2,AUC2] = perfcurve(dataFinal.Label,samScoreVec.classifier2(:,2),1);
[X3,Y3,T3,AUC3] = perfcurve(dataFinal.Label,samScoreVec.classifier3(:,2),1);
[X4,Y4,T4,AUC4] = perfcurve(dataFinal.Label,samScoreVec.classifier4(:,2),1);
[X5,Y5,T5,AUC5] = perfcurve(dataFinal.Label,samScoreVec.classifier5(:,2),1);
[X6,Y6,T6,AUC6] = perfcurve(dataFinal.Label,samScoreVec.classifier6(:,2),1);

figure;
plot(X1,Y1)
xlabel('False positive rate')
ylabel('True positive rate')
title('ROC for m-fold validation')

figure;
plot(X2,Y2)
xlabel('False positive rate')
ylabel('True positive rate')
title('ROC for m-fold validation')

figure;
plot(X3,Y3)
xlabel('False positive rate')
ylabel('True positive rate')
title('ROC for m-fold validation')

figure;
plot(X4,Y4)
xlabel('False positive rate')
ylabel('True positive rate')
title('ROC for m-fold validation')

figure;
plot(X5,Y5)
xlabel('False positive rate')
ylabel('True positive rate')
title('ROC for m-fold validation')

figure;
plot(X6,Y6)
xlabel('False positive rate')
ylabel('True positive rate')
title('ROC for m-fold validation')
