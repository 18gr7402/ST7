clc
close all
clear

%% Load data 
load('FeatureLabelTabelWithOverallData5000');

%% Dupliker data s� vi regner videre p� en ny variabel
data = FeatureLabelTabelWithOverallData;

%% Sorter data efter patientunitstayid
sortData = sortrows(data);

%% Split hele datas�ttet op i mindre subsets (ca. 1/20 del)
% HUSK: T�l en op i r�kke n�r man skifter til nyt subset

subset1 = sortData(1:452636,:);         % Slutter med pId 347562
subset2 = sortData(452637:905154,:);    % Starter med pId 349313 og slutter med pId 530711
subset3 = sortData(905155:1358992,:);   % Starter med pId 531068 og slutter med pId 728179