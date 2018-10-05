clc
clear
close all

%% Beskrivelse

% Kode til LDA classifikation med five fold validation, scatter plot,
% confusion matrix og sammenligning med matlabs indbyggerede classify.
% Køres på iris data der først loades.

load ('irisWorkSpace.mat')

%iris = inputdata;  % Kan bruges hvis load data ikke hedder iris

% Species laved til et nummerisk indeks
c = categorical(iris.species(1:end));
iris.species = grp2idx(c);

%% Histrogram

classLabels = unique(iris.species);
classes = length(classLabels);
classIndex = [0,0,0];
for classes=1:length(classes)+1
    classIdx=find(iris.species>classes);
    classIndex(classes)=classIdx(1);
end

subplot(2,2,1)
h1_SL = histogram(iris.sepal_length(1:classIndex(1)-1));
hold on
h2_SL = histogram(iris.sepal_length(classIndex(1):classIndex(2)-1));
hold on 
h3_SL = histogram(iris.sepal_length(classIndex(2):end));
hold on
title('Feature 1: Sepal Length');
legend([h1_SL, h2_SL, h3_SL],{'Setosa','Versicolor','Virginica'});

subplot(2,2,2)
h1_SW = histogram(iris.sepal_width(1:classIndex(1)-1));
hold on
h2_SW = histogram(iris.sepal_width(classIndex(1):classIndex(2)-1));
hold on 
h3_SW = histogram(iris.sepal_width(classIndex(2):end));
hold on
title('Feature 2: Sepal Width');
legend([h1_SW, h2_SW, h3_SW],{'Setosa','Versicolor','Virginica'});

subplot(2,2,3)
h1_PL = histogram(iris.petal_length(1:classIndex(1)-1));
hold on
h2_PL = histogram(iris.petal_length(classIndex(1):classIndex(2)-1));
hold on 
h3_PL = histogram(iris.petal_length(classIndex(2):end));
hold on
title('Feature 3: Petal Length');
legend([h1_PL, h2_PL, h3_PL],{'Setosa','Versicolor','Virginica'});

subplot(2,2,4)
h1_PW = histogram(iris.petal_width(1:classIndex(1)-1));
hold on
h2_PW = histogram(iris.petal_width(classIndex(1):classIndex(2)-1));
hold on 
h3_PW = histogram(iris.petal_width(classIndex(2):end));
hold on
title('Feature 4: Petal Width');
legend([h1_PW, h2_PW, h3_PW],{'Setosa','Versicolor','Virginica'});

%% Five fold validation

fiveFoldGroups=struct;
idx1 = 1;
for idx = 1:10:141
fiveFoldGroups(idx1).vec=[iris(idx,:);iris(idx+1,:);iris(idx+2,:);iris(idx+3,:);iris(idx+4,:);iris(idx+5,:);...
    iris(idx+6,:);iris(idx+7,:);iris(idx+8,:);iris(idx+9,:)];
idx1 = idx1 + 1;
end

for fold = 1:5   %Number of folds
% Fold bruges til at beskrive hvilke der går til test eks. 1 6 og 11 osv. Nu finder vi hvilke går til træning ved at fjerne de tal fra talrækken.     
numberOfGroups = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15];
trainGroup = numberOfGroups(numberOfGroups~=fold & numberOfGroups~=fold+5 & numberOfGroups~=fold+10);

%Positionerne i talrækken bruges til at oprette en matrix med træningsdata.
dataTrain = [fiveFoldGroups(trainGroup(1,1)).vec; fiveFoldGroups(trainGroup(1,2)).vec; fiveFoldGroups(trainGroup(1,3)).vec;...
    fiveFoldGroups(trainGroup(1,4)).vec; fiveFoldGroups(trainGroup(1,5)).vec; fiveFoldGroups(trainGroup(1,6)).vec; ...
    fiveFoldGroups(trainGroup(1,7)).vec; fiveFoldGroups(trainGroup(1,8)).vec; fiveFoldGroups(trainGroup(1,9)).vec; ...
    fiveFoldGroups(trainGroup(1,10)).vec; fiveFoldGroups(trainGroup(1,11)).vec; fiveFoldGroups(trainGroup(1,12)).vec;];
%Fold benyttes til at oprette en matrix med testdata.
dataTest = [fiveFoldGroups(fold).vec; fiveFoldGroups(fold+5).vec; fiveFoldGroups(fold+10).vec];
end 

dataTrainNoLable = [dataTrain.sepal_length,dataTrain.sepal_width,dataTrain.petal_length,dataTrain.petal_width];
dataTestNoLable = [dataTest.sepal_length,dataTest.sepal_width,dataTest.petal_length,dataTest.petal_width];

no = length(dataTestNoLable);
width = 1/sqrt(no);

for i=1:length(dataTestNoLable)
    for j = 1:length(dataTrainNoLable)
       prob(i)=(sum(normal((dataTestNoLable(i,:)-dataTrainNoLable(j,:))/width)))/no; 
    end   
end


%% Nu laves datasæt med alle features for hver klasse
class1 = [iris.sepal_length(iris.species == 1) iris.sepal_width(iris.species == 1) iris.petal_length(iris.species == 1) iris.petal_width(iris.species == 1)];
class2 = [iris.sepal_length(iris.species == 2) iris.sepal_width(iris.species == 2) iris.petal_length(iris.species == 2) iris.petal_width(iris.species == 2)];
class3 = [iris.sepal_length(iris.species == 3) iris.sepal_width(iris.species == 3) iris.petal_length(iris.species == 3) iris.petal_width(iris.species == 3)];

allDataNoLabel = [class1; class2; class3];

testdata = allDataNoLabel(56,:);

    for j = 1:length(class1)
       prob1=(sum(normal((testdata-class1(j,:))/width)))/no; 
    end   

     for j = 1:length(class2)
       prob2=(sum(normal((testdata-class2(j,:))/width)))/no; 
     end 
    
     for j = 1:length(class3)
       prob3=(sum(normal((testdata-class3(j,:))/width)))/no; 
     end 
     

