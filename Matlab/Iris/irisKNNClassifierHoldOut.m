clc
clear
close all

%% Forberedelse af data

load ('irisWorkSpace.mat')
c = categorical(iris.species(1:end));
iris.species = grp2idx(c);
classLabels = unique(iris.species);
classes = length(classLabels);

%% Separate to training and test data

%load('splitIndex');
cv = cvpartition(size(iris,1),'HoldOut',0.2);
splitIndex = cv.test;
dataTest  = iris(splitIndex,:);
dataTrain = iris(~splitIndex,:);

dataTrainNoLable = [dataTrain.sepal_length,dataTrain.sepal_width,dataTrain.petal_length,dataTrain.petal_width];
dataTestNoLable = [dataTest.sepal_length,dataTest.sepal_width,dataTest.petal_length,dataTest.petal_width];

%% KNN manuel

% Regn k
k=round(sqrt(length(dataTrainNoLable)));

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

for i=1:length(dataTestNoLable)
    for idx=1:length(dataTrainNoLable)
distance(idx,i) = sum((abs(dataTrainNoLable(idx,:)-dataTestNoLable(i,:)).^2)).^0.5;
% distance(idx,i) =
% sum((abs(dataTrainNoLable(idx,:)-dataTestNoLable(i,:)).^k)).^(1/k); %
% Hvis man gerne vil brug Minkowski i stedet for Euclidean.
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
fejlrateManuel = 100*numberWrongClassification/length(dataTestNoLable) %Fejlrate.

%% KNN Matlab

% Brug fitcknn til at lave model
modelMatlab = fitcknn(dataTrainNoLable,dataTrain.species,'NumNeighbors',k);
% cvmodel = crossval(Mdl)  % A cross validation on the trainingdata.

%% Benyt KNN til klassifikation
classifiedValue = predict(modelMatlab,dataTestNoLable);

%% Fejlrate
differenceVec = dataTest.species - classifiedValue;
indeces = find(differenceVec ~= 0); 
numberWrongClassification = length(indeces); % Antallet af forkerte klassificeringer (forskel på test og træning ikke er 0).
fejlrateMatlab = 100*numberWrongClassification/length(dataTestNoLable) % Fejlrate. 

