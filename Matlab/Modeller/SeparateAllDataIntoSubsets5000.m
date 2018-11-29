clc
close all
clear

%% Load data 
load('FeatureLabelTabelWithOverallData5000');

%% Dupliker data så vi regner videre på en ny variabel
data = FeatureLabelTabelWithOverallData;

%% Sorter data efter patientunitstayid
sortData = sortrows(data);

%% Split hele datasættet op i mindre subsets (ca. 1/20 del)
% HUSK: Tæl en op i række når man skifter til nyt subset

subset1 = sortData(1:452636,:);         % Slutter med pId 347562
subset2 = sortData(452637:905154,:);    % Starter med pId 349313 og slutter med pId 530711
subset3 = sortData(905155:1358992,:);   % Starter med pId 531068 og slutter med pId 728179
subset4 = sortData(1358993:2257507,:);  % Starter med pId 728469 og slutter med pId 1030252
subset5 = sortData(2257508:3158262,:);  % Starter med pId 1033063 og slutter med pId 1310301
subset6 = sortData(3158263:4060726,:);  % Starter med pId 1313727 og slutter med pId 1638479
subset7 = sortData(4060727:4963835,:);  % Starter med pId 1638579 og slutter med pId 1813718
subset8 = sortData(4963836:5865757,:);  % Starter med pId 1814272 og slutter med pId 2401329
subset9 = sortData(5865758:6765839,:);  % Starter med pId 2403618 og slutter med pId 2751335
subset10 = sortData(6765840:7666262,:); % Starter med pId 2752818 og slutter med pId 3009540
subset11 = sortData(7666263:8568603,:); % Starter med pId 3010000 og slutter med pId 3179215
subset12 = sortData(8568604:9066021,:); % Starter med pId 3179323 og slutter med pId 3353121



