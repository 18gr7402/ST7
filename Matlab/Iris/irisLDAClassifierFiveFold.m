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

% Dette er blot nogle structs der skal bruges til confusion matrix.
testClassesLoop = struct;
testClassesManuelLoop = struct;
testClassesMatlabLoop = struct;

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

%% Step 1: Mean af features for hver klasse

meanSL1 = mean(dataTrain.sepal_length(dataTrain.species == 1));
meanSW1 = mean(dataTrain.sepal_width(dataTrain.species == 1));
meanPL1 = mean(dataTrain.petal_length(dataTrain.species == 1));
meanPW1 = mean(dataTrain.petal_width(dataTrain.species == 1));

meanvectorCl1 = [meanSL1; meanSW1; meanPL1; meanPW1];

meanSL2 = mean(dataTrain.sepal_length(dataTrain.species == 2));
meanSW2 = mean(dataTrain.sepal_width(dataTrain.species == 2));
meanPL2 = mean(dataTrain.petal_length(dataTrain.species == 2));
meanPW2 = mean(dataTrain.petal_width(dataTrain.species == 2));

meanvectorCl2 = [meanSL2; meanSW2; meanPL2; meanPW2];

meanSL3 = mean(dataTrain.sepal_length(dataTrain.species == 3));
meanSW3 = mean(dataTrain.sepal_width(dataTrain.species == 3));
meanPL3 = mean(dataTrain.petal_length(dataTrain.species == 3));
meanPW3 = mean(dataTrain.petal_width(dataTrain.species == 3));

meanvectorCl3 = [meanSL3; meanSW3; meanPL3; meanPW3];  %Her kunne vi have gjort det samme som for cov

%% Step 2: Compute scatter matrice

%Først udregnes within scatter matricen: 
%a = class1(1,:)-meanvectorCl1 b =%a' og S1 = a*b 

class1 = [dataTrain.sepal_length(dataTrain.species == 1) dataTrain.sepal_width(dataTrain.species == 1) dataTrain.petal_length(dataTrain.species == 1) dataTrain.petal_width(dataTrain.species == 1)];

S1 = cov(class1);

class2 = [dataTrain.sepal_length(dataTrain.species == 2) dataTrain.sepal_width(dataTrain.species == 2) dataTrain.petal_length(dataTrain.species == 2) dataTrain.petal_width(dataTrain.species == 2)];

S2 = cov(class2);

class3 = [dataTrain.sepal_length(dataTrain.species == 3) dataTrain.sepal_width(dataTrain.species == 3) dataTrain.petal_length(dataTrain.species == 3) dataTrain.petal_width(dataTrain.species == 3)];

S3 = cov(class3);

Sw = S1+S2+S3;

%Dernæst udregnes between class scatter matricen
mean1 = ([meanvectorCl1(1,:)+ meanvectorCl2(1,:)+ meanvectorCl3(1,:)]/3);
mean2 = ([meanvectorCl1(2,:)+ meanvectorCl2(2,:)+ meanvectorCl3(2,:)]/3);
mean3 = ([meanvectorCl1(3,:)+ meanvectorCl2(3,:) + meanvectorCl3(3,:)]/3);
mean4 = ([meanvectorCl1(4,:)+ meanvectorCl2(4,:) + meanvectorCl3(4,:)]/3);

meanOverall = [mean1 mean2 mean3 mean4]';

s1 = length(class1)*(meanvectorCl1-meanOverall)*(meanvectorCl1-meanOverall)';
s2 = length(class2)*(meanvectorCl2-meanOverall)*(meanvectorCl2-meanOverall)';
s3 = length(class3)*(meanvectorCl3-meanOverall)*(meanvectorCl3-meanOverall)';

Sb = s1+s2+s3;

%% Step 3: Solving the generalized eigenvalue problem for the matrix 
invSw = inv(Sw);

invSwSb = invSw*Sb;

[V,D] = eig(invSwSb);  
% Giver os V ud der er en matrix hvis kolonner svarer til eigenvektorer.
% Giver os D ud der er en diagonal matrix med eigenværdier.

%solve(abs(invSwSb-x*I)=0;x);

%Her er alle eigenvektorerne
W1 = V(:,1);
W2 = V(:,2);
W3 = V(:,3);
W4 = V(:,4);

%% Step 4: Selecting linear discriminants for the new feature subspace

%Ud fra D kan vi se at eigenværdierne for W3 og W4 er nul.
%Dette stemmer overens med teorien der siger at antallet af eigenvektorer
%der er forskellig fra 0 er C-1 og dermed antallet af klasser -1
%Her sammensættes eigenvektorer med egenværdi forskellig fra 0 til en
%matrix W:

W = [W1 W2];

%% Step 5: Transforming the samples onto the new subspace

X = [class1 ; class2; class3];

Y = X*W;

%Vi inddeler y-værdierne for hver klasse, da vi gerne vil have dem plottet
%i hver sin farve på det efterfølgende scatterplot

Y1 = class1*W;
Y2 = class2*W;
Y3 = class3*W;

%% Scatter figure

% figure
% S1 = scatter(Y1(:,1),Y1(:,2),'red');
% hold on
% S2 = scatter(Y2(:,1),Y2(:,2),'blue');
% hold on
% S3 = scatter(Y3(:,1),Y3(:,2),'green');
% title('Iris projection onto the first 2 linear discriminants');
% legend([S1, S2, S3],{'Setosa','Versicolor','Virginica'});
% xlabel('LDA1')
% ylabel('LDA2')

%Vi kan se at LDA1 er bedre til at adskille de tre klasser end LDA2,
%hvilket stemmer overens med de to eigenvektorer vi fik, hvor W1 havde
%størt eigenværdi og derfor også burde give den bedste adskillelse

%% Lav det til en classifier

dataTestNoLable = [dataTest.sepal_length,dataTest.sepal_width,dataTest.petal_length,dataTest.petal_width];

% Preallocation 
classifiedValue = zeros(1,length(dataTestNoLable));
% For-loop for alle samples i testdata.
testIndex = 1;
for testIndex = 1: length(dataTestNoLable)

nySample = dataTestNoLable(testIndex,:);  %Er ens med første række i irisdata

meanC1 = meanvectorCl1'; %Skal være en rækkevektor 
f1 = meanC1*(Sw^-1)*nySample' - 0.5*meanC1*(Sw^-1)*(meanC1');

meanC2 = meanvectorCl2';
f2 = meanC2*(Sw^-1)*nySample' - 0.5*meanC2*(Sw^-1)*(meanC2');

meanC3 = meanvectorCl3';
f3 = meanC3*(Sw^-1)*nySample' - 0.5*meanC3*(Sw^-1)*(meanC3');

%% Choose the highest value

fMatrix = [f1,f2,f3];
maxfMatrix = max(fMatrix);

if maxfMatrix == f1
   classifiedValue(1,testIndex) = 1; 
end    
if maxfMatrix == f2
   classifiedValue(1,testIndex) = 2; 
end  
if maxfMatrix == f3
   classifiedValue(1,testIndex) = 3; 
end  
end % Nu er alle test samples kørt igennem

%% Udregning af fejlraten

differenceVec = dataTest.species - classifiedValue';
indeces = find(differenceVec ~= 0); 
numberWrongClassification = length(indeces); %antallet af forkerte klassificeringer (forskel på test og træning ikke er 0)
fejlrateManuel(fold,1) = 100*numberWrongClassification/length(dataTestNoLable); %Fejlrate 

% Vi gemmer klassificeringerne til confusion matrix
testClassesManuelLoop(fold,1).vec = classifiedValue';

%% Udregning med matlabs classify

groupTR = dataTrain.species;

[class,err] = classify(dataTestNoLable,X, groupTR);
errMatlab(fold,1) = err;

differenceVec = dataTest.species - class;
indeces = find(differenceVec ~= 0);
numberWrongClassification = length(indeces); %antallet af forkerte klassificeringer (forskel på test og træning ikke er 0)
fejlrateMatlab(fold,1) = 100*numberWrongClassification/length(dataTestNoLable); %Fejlrate 

% Vi gemmer klassificeringerne til confusion matrix
testClassesMatlabLoop(fold,1).vec = class;

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
errMatlab
gennemsnitFejlrateManuel = mean(fejlrateManuel)
gennemsnitFejlrateMatlab = mean(fejlrateMatlab)