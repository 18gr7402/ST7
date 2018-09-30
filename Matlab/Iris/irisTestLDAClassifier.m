clc
clear
close all

load ('irisWorkSpace.mat')

c = categorical(iris.species(1:end));
iris.species = grp2idx(c);

classLabels = unique(iris.species);
classes = length(classLabels);

% Cross varidation (train: 70%, test: 20%)
cv = cvpartition(size(iris,1),'HoldOut',0.2);
splitIndex = cv.test;
% Separate to training and test data
orginalData = iris;
dataTest  = iris(splitIndex,:);
iris = iris(~splitIndex,:);    %iris er nu vores dataTrain, skal evt. laves om hele vejen igennem.

classIndex = [0,0,0];
for classes=1:length(classes)+1
    classIdx=find(iris.species>classes);
    classIndex(classes)=classIdx(1);
end

%% Histrogram
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

%% Step 1: Mean af features for hver klasse

meanSL1 = mean(iris.sepal_length(iris.species == 1));
meanSW1 = mean(iris.sepal_width(iris.species == 1));
meanPL1 = mean(iris.petal_length(iris.species == 1));
meanPW1 = mean(iris.petal_width(iris.species == 1));

meanvectorCl1 = [meanSL1; meanSW1; meanPL1; meanPW1];

meanSL2 = mean(iris.sepal_length(iris.species == 2));
meanSW2 = mean(iris.sepal_width(iris.species == 2));
meanPL2 = mean(iris.petal_length(iris.species == 2));
meanPW2 = mean(iris.petal_width(iris.species == 2));

meanvectorCl2 = [meanSL2; meanSW2; meanPL2; meanPW2];

meanSL3 = mean(iris.sepal_length(iris.species == 3));
meanSW3 = mean(iris.sepal_width(iris.species == 3));
meanPL3 = mean(iris.petal_length(iris.species == 3));
meanPW3 = mean(iris.petal_width(iris.species == 3));

meanvectorCl3 = [meanSL3; meanSW3; meanPL3; meanPW3];  %Her kunne vi have gjort det samme som for cov

%% Step 2: Compute scatter matrice

%Først udregnes within scatter matricen: 
%a = class1(1,:)-meanvectorCl1 b =%a' og S1 = a*b 

class1 = [iris.sepal_length(iris.species == 1) iris.sepal_width(iris.species == 1) iris.petal_length(iris.species == 1) iris.petal_width(iris.species == 1)];

S1 = cov(class1);

class2 = [iris.sepal_length(iris.species == 2) iris.sepal_width(iris.species == 2) iris.petal_length(iris.species == 2) iris.petal_width(iris.species == 2)];

S2 = cov(class2);

class3 = [iris.sepal_length(iris.species == 3) iris.sepal_width(iris.species == 3) iris.petal_length(iris.species == 3) iris.petal_width(iris.species == 3)];

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
invSw = inv(Sw)

invSwSb = invSw*Sb

[V,D] = eig(invSwSb)  
% Giver os V ud der er en matrix hvis kolonner svarer til eigenvektorer.
% Giver os D ud der er en diagonal matrix med eigenværdier.

%solve(abs(invSwSb-x*I)=0;x);

%Her er alle eigenvektorerne
W1 = V(:,1)
W2 = V(:,2)
W3 = V(:,3)
W4 = V(:,4)

%% Step 4: Selecting linear discriminants for the new feature subspace

%Ud fra D kan vi se at eigenværdierne for W3 og W4 er nul.
%Dette stemmer overens med teorien der siger at antallet af eigenvektorer
%der er forskellig fra 0 er C-1 og dermed antallet af klasser -1
%Her sammensættes eigenvektorer med egenværdi forskellig fra 0 til en
%matrix W:

W = [W1 W2]

%% Step 5: Transforming the samples onto the new subspace

X = [class1 ; class2; class3];

Y = X*W

%Vi inddeler y-værdierne for hver klasse, da vi gerne vil have dem plottet
%i hver sin farve på det efterfølgende scatterplot

Y1 = class1*W
Y2 = class2*W
Y3 = class3*W

figure
S1 = scatter(Y1(:,1),Y1(:,2),'red');
hold on
S2 = scatter(Y2(:,1),Y2(:,2),'blue');
hold on
S3 = scatter(Y3(:,1),Y3(:,2),'green');
title('Iris projection onto the first 2 linear discriminants');
legend([S1, S2, S3],{'Setosa','Versicolor','Virginica'});
xlabel('LDA1')
ylabel('LDA2')

%Vi kan se at LDA1 er bedre til at adskille de tre klasser end LDA2,
%hvilket stemmer overens med de to eigenvektorer vi fik, hvor W1 havde
%størt eigenværdi og derfor også burde give den bedste adskillelse

%% Lav det til en classifier

orginalTestData = dataTest;

dataTest = [dataTest.sepal_length,dataTest.sepal_width,dataTest.petal_length,dataTest.petal_width];

testIndex = 1;
classifiedValue = zeros(1,length(dataTest));
for testIndex = 1: length(dataTest)

nySample = dataTest(testIndex,:);  %Er ens med første række i irisdata

meanC1 = meanvectorCl1'; %Skal være en rækkevektor 

f_d1 = meanC1*(Sw^-1)*nySample';
f_d2 = 0.5*meanC1*(Sw^-1)*(meanC1');

f1 = f_d1 - f_d2;

meanC2 = meanvectorCl2';

f2_d1 = meanC2*(Sw^-1)*nySample';
f2_d2 = 0.5*meanC2*(Sw^-1)*(meanC2');

f2 = f2_d1 - f2_d2;

meanC3 = meanvectorCl3';

f3_d1 = meanC3*(Sw^-1)*nySample';
f3_d2 = 0.5*meanC3*(Sw^-1)*(meanC3');

f3 = f3_d1 - f3_d2;

%f1 = meanvectorCl1*(nannax)*(Sw^-1) - 0.5*meanvectorCl1*(Sw^-1)*(meanvectorCl1');

%% Choose the highest value

A = [f1,f2,f3];
M = max(A);

if M == f1
   classifiedValue(1,testIndex) = 1; 
end    
if M == f2
   classifiedValue(1,testIndex) = 2; 
end  
if M == f3
   classifiedValue(1,testIndex) = 3; 
end  
end

%% Udregning af fejlraten

differenceVec = orginalTestData.species - classifiedValue';
indeces = find(differenceVec ~= 0); 
N = length(indeces); %antallet af forkerte klassificeringer (forskel på test og træning ikke er 0)
fejlrateManuel = 100*N/length(dataTest) %Fejlrate 

%% Udregning med matlabs classify

groupTR = iris.species;

newclass = classify(dataTest,X, groupTR);

differenceVec = orginalTestData.species - newclass;
indeces = find(differenceVec ~= 0);
N = length(indeces); %antallet af forkerte klassificeringer (forskel på test og træning ikke er 0)
fejlrateMatlab = 100*N/length(dataTest) %Fejlrate 