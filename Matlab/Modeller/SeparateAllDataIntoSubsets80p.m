clc
close all
clear

%% Load data 
load('FeatureLabelTabel80p.mat');

%% Dupliker data s� vi regner videre p� en ny variabel
data = FeatureLabelTabel80p;

%% Sorter data efter patientunitstayid
sortData = sortrows(data);

%% Split hele datas�ttet op i mindre subsets (ca. 1/20 del)
% HUSK: T�l en op i r�kke n�r man skifter til nyt subset

subset1 = sortData(1:5000000,:); 
subset2 = sortData(:,:);     
subset3 = sortData(:,:);    
subset4 = sortData(:,:);    
subset5 = sortData(:,:);    
subset6 = sortData(:,:);    
subset7 = sortData(:,:);     
subset8 = sortData(:,:);    
subset9 = sortData(:,:);  
subset10 = sortData(:,:); 
subset11 = sortData(:,:);   
subset12 = sortData(:,:);    
subset13 = sortData(:,:);   
subset14 = sortData(:,:);   
subset15 = sortData(:,:);   
subset16 = sortData(:,:);   


