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

%% KNN manuel

% Regn k
k=round(sqrt(length(dataTrain.species)));

for i=1:4      % Vi kører den lige i et for loop et par gange for at sikre når vi fjer multiplum at vi ikke får et lige nr.
if mod(k,2) == 0  % k må ikke være et lige nr.
    k = k-1;
end
if mod(k,classes) == 0     % k må ikke være et multiplum af antallet af klasser.
    k = k-1;
end
end

%% Regn euclidean distance weight function

% Ligning findes på PRDS lek 2 slide 41.
% To for-løkker da distancen fra hver test sample skal regnes til alle
% trænings sample.

dataTrainNoLable = [dataTrain.sepal_length,dataTrain.sepal_width,dataTrain.petal_length,dataTrain.petal_width];
dataTestNoLable = [dataTest.sepal_length,dataTest.sepal_width,dataTest.petal_length,dataTest.petal_width];

for i=1:length(dataTestNoLable)
    for idx=1:length(dataTrainNoLable)
distance(idx,i) = sum((abs(dataTrainNoLable(idx,:)-dataTestNoLable(i,:)).^2)).^0.5;
    end
end

%% Sortering af distancer, udvælgelse af de lavest og omsæt til klasselable
% Det sorteres så laveste distance står øvers. 'I' bruges til at indikere
% hvilken sample denne værdi hører til.
[sortDist,I]=sort(distance);

% Disse I bliver omsat til hvilken gruppe de hører til ud fra træningsdata.
for sampNo=1:length(dataTestNoLable)
    sortClassLab(:,sampNo)=dataTrain.species(I(:,sampNo));
end

knnLabs=sortClassLab(1:k,:);  % Vi skal kun bruge de k-antal laveste, så de udvælges.

%% Klassificering
classManuel = mode(knnLabs);  % Returnere most occuring value, altså vores klassificering.

%% Udregning af fejlrate
differenceVec = dataTest.species - classManuel';
indeces = find(differenceVec ~= 0);
numberWrongClassification = length(indeces);
fejlrateManuel(fold,1) = 100*numberWrongClassification/length(dataTestNoLable) %Fejlrate.

% Vi gemmer klassificeringerne til confusion matrix
testClassesManuelLoop(fold,1).vec = classManuel';

%% KNN Matlab

% Brug fitcknn til at lave model
modelMatlab = fitcknn(dataTrainNoLable,dataTrain.species,'NumNeighbors',k);
% cvmodel = crossval(Mdl)  % A cross validation on the trainingdata.

%% Benyt KNN til klassifikation
classMatlab = predict(modelMatlab,dataTestNoLable);

%% Fejlrate
differenceVec = dataTest.species - classMatlab;
indeces = find(differenceVec ~= 0); 
numberWrongClassification = length(indeces); % Antallet af forkerte klassificeringer (forskel på test og træning ikke er 0).
fejlrateMatlab(fold,1) = 100*numberWrongClassification/length(dataTestNoLable) % Fejlrate.

% Vi gemmer klassificeringerne til confusion matrix
testClassesMatlabLoop(fold,1).vec = classMatlab;

end % Slut på five fold validation loop

%% Confusion matrix

% Først smides alle de forventede klassificeringer, de egentlige
% klassificeringer manuelt og de egentlige klassificeringer ved matlab
% sammen til en variable efter hinanden.
testClasses = [dataTest.species; dataTest.species; dataTest.species; dataTest.species; dataTest.species];
testClassesManuel = [testClassesManuelLoop(1,1).vec; testClassesManuelLoop(2,1).vec; testClassesManuelLoop(3,1).vec; testClassesManuelLoop(4,1).vec; testClassesManuelLoop(5,1).vec];
testClassesMatlab = [testClassesMatlabLoop(1,1).vec; testClassesMatlabLoop(2,1).vec; testClassesMatlabLoop(3,1).vec; testClassesMatlabLoop(4,1).vec; testClassesMatlabLoop(5,1).vec];

% Nu laves de så categorial så vi kan bruge dem i plotconfusion
categoricalDataTest = categorical(testClasses);
categoricalClassManuel = categorical(testClassesManuel);
categoricalClassMatlab = categorical(testClassesMatlab);

figure;
plotconfusion(categoricalClassManuel,categoricalDataTest); % FLIPPET!!!!
title('Manuel confusion matrix','Fontsize',16,'Fontweight','bold');
ylabel('True value','Fontsize',12,'Fontweight','bold')
xlabel('Predicted value','Fontsize',12,'Fontweight','bold')
xticks([1 2 3])
xticklabels({'Setosa','Versicolor','Virginica'})
yticks([1 2 3])
yticklabels({'Setosa','Versicolor','Virginica'})

figure;
plotconfusion(categoricalClassMatlab,categoricalDataTest); % FLIPPET!!!!
title('Matlab confusion matrix','Fontsize',16,'Fontweight','bold');
ylabel('True value','Fontsize',12,'Fontweight','bold')
xlabel('Predicted value','Fontsize',12,'Fontweight','bold')
xticks([1 2 3])
xticklabels({'Setosa','Versicolor','Virginica'})
yticks([1 2 3])
yticklabels({'Setosa','Versicolor','Virginica'})

%% Udskriv de værdier vi er interesseret i
fejlrateManuel
fejlrateMatlab
gennemsnitFejlrateManuel = mean(fejlrateManuel)
gennemsnitFejlrateMatlab = mean(fejlrateMatlab)