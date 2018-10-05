clc
clear
close all

%% Forberedelse af data
load ('irisWorkspace.mat');
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

 %% inddeling af klasserne

 klasse1 = [iris.sepal_length(iris.species==1),iris.sepal_width(iris.species==1),iris.petal_length(iris.species==1),iris.petal_width(iris.species==1)];

 klasse2 = [iris.sepal_length(iris.species==2),iris.sepal_width(iris.species==2),iris.petal_length(iris.species==2),iris.petal_width(iris.species==2)];

 klasse3 = [iris.sepal_length(iris.species==3),iris.sepal_width(iris.species==3),iris.petal_length(iris.species==3),iris.petal_width(iris.species==3)];

 % her skal forløkken starte
 
 w0=ones(length(klasse1),1);
 k1=[w0 klasse1]';
 k2=[w0 klasse2]';
 
 
