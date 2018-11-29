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
subset4 = sortData(1358993:2257507,:);  % Starter med pId 728469 og slutter med pId 1030252
subset5 = sortData(2257508:3158262,:);  % Starter med pId 1033063 og slutter med pId 1310301
subset6 = sortData(3158263:4060726,:);   % Starter med pId 1313727 og slutter med pId 1638479
subset7 = sortData(4060727:4963835,:);   % Starter med pId 1638579 og slutter med pId 1813718
%subset8 = sortData(,:);   % Starter med pId 1814272 og slutter med pId