clc
close all
clear

%% Load data 
load('FeatureLabelTabel80p.mat');

%% Dupliker data så vi regner videre på en ny variabel
data = FeatureLabelTabel80p;

%% Sorter data efter patientunitstayid
sortData = sortrows(data);

%% Split hele datasættet op i mindre subsets (ca. 1/20 del)
% HUSK: Tæl en op i række når man skifter til nyt subset

subset1 = sortData(1:4999864,:); 
subset2 = sortData(4999865:10000436,:);     
subset3 = sortData(10000437:15000375,:);    
subset4 = sortData(15000376:20000768,:);    
subset5 = sortData(20000769:25001669,:);    
subset6 = sortData(25001670:30003968,:);    
subset7 = sortData(30003969:35004607,:);     
subset8 = sortData(35004608:40000613,:);    
subset9 = sortData(40000614:45000033,:);  
subset10 = sortData(45000034:50000281,:); 
subset11 = sortData(50000282:55001815,:);   
subset12 = sortData(55001816:60003617,:);    
subset13 = sortData(60003618:65000112,:);   
subset14 = sortData(65000113:70001493,:);   
subset15 = sortData(70001494:75000206,:);   
subset16 = sortData(75000207:75705580,:);   


