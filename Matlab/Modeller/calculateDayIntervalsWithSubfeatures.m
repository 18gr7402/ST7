clc
close all
clear
%clearvars -except rand200pidlab

%% Hent data, ekskluder patienter, label data og opdeling data på dage pr. patient

%% Load data 
load('FeatureLabelTabelWithOverallData500');

%% Dupliker data så vi regner videre på en ny variabel

data = FeatureLabelTabelWithOverallData(1:10000,:);

%% Her fjernes alle rækker med negative offset og output gemmes i en ny tabel
for i = 1:size(data,1)
    ind(i) = all(data.offset(i) >= 0);
end

dataUNeg = data(ind, :);

% Nu findes antal af patienter tilbage efter fjernelse af rækker med
% negative offset
numUniPidUNeg = size(unique(dataUNeg.patientunitstayid),1);

%% Find patienterne med en eller flere glucosemåling(er) - glucose = category 79 og bedside glucose = category 69
% for i = 1:size(dataUNeg.patientunitstayid)
%     idx(i) = all(dataUNeg.name(i) == 'bedside glucose' | dataUNeg.name(i) == 'glucose');
% end
% FIKS NAVNE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
dataUNegOnlyGlu = dataUNeg;

% Nu findes antal patienter tilbage efter fjernelse af patienter uden
% glucose målinger

numUniPid = size(unique(dataUNegOnlyGlu.patientunitstayid),1);

%% Lav en tabel med alle datarækker for hver patient - join uniquePid med dataUNeg
dataTrim = dataUNeg(ismember(dataUNeg.patientunitstayid,unique(dataUNegOnlyGlu.patientunitstayid)),:); %alle række med de inkluderede patienter er fundet (patienter med glucose målinger og ingen negative lab offset)

%% Find unikke rows af patient og unikke rows af patient med tilhørende data så det kan bruges til beregning
uniquePatient = unique(dataTrim.patientunitstayid);

[~,idu] = unique(dataTrim.patientunitstayid);
uniqueDataTrimPatientID = dataTrim(idu,:);

%% Løkke til opdeling af målinger for hver unikke patientid
% Preallocate
testDay = zeros(length(dataTrim.result),1);

for index=1:length(uniquePatient)
    timeIndex = uniqueDataTrimPatientID.unitadmittime24(index);  % Find admit-time for patient 'index' 
    [h,m] = hms(timeIndex);  % Omregn til timer og minutter
    tidIMin = 60*h+m;
    tidTilMidnat = 1440-tidIMin;
    
    n=find(uniquePatient(index) == dataTrim.patientunitstayid); % Find de samples der tilhøre patient 'index'
            
    % Udregning af hvor mange dage patienten har data for. Der findes offset for den sidste måling (ved max(offset(n))). Dette divideres med 60*24 og rundes op.
    numberOfTestDays = ceil((max(dataTrim.offset(n))-tidTilMidnat)/1440);
    
    % Løkke for opdeling af dag 1 indtil antallet af dag med test. De der hører til dag 0 er allerede 0.
    for day=1:numberOfTestDays
    % Der findes de samples hvor patientens offset ligger over tidTilMidnat og under tidTilMadnat+(60*24). For hver iteration ligges i*(60*24) oveni begge for på den måde at skrifte til en ny dag. Dette gemmes hver gang på som dag(i+1).
        testDay(n(find(((day-1)*1440+tidTilMidnat) <= dataTrim.offset(n) & ((day-1)*1440+tidTilMidnat+1440) > dataTrim.offset(n))))=(day-1)+1;
    end
end

% Vi slutter med at samle data.
dataTrim = [dataTrim table(testDay)];

%% Label data

glucoseMeasurements = find(dataTrim.name == 'bedside glucose' | dataTrim.name == 'glucose'| dataTrim.name == 'NCBG');
glucoseMeasurementsUnder70 = dataTrim.result(glucoseMeasurements)<=70;
locationOfglucoseMeasurementsUnder70 = glucoseMeasurements(glucoseMeasurementsUnder70);

%Preallocate
label = zeros(size(dataTrim.result,1),1);
label(locationOfglucoseMeasurementsUnder70)=1;

%Save
dataTrim = [dataTrim table(label)];

%% Opsætning af data til gennerelt overblik

%PatientID og hvilken dag der er oplevet hypo
hypoPatientDayInfo = [dataTrim.patientunitstayid(locationOfglucoseMeasurementsUnder70) dataTrim.testDay(locationOfglucoseMeasurementsUnder70)];

%Indexer labname til talrepresentationer
category = categorical(string(dataTrim.name));
dataTrim.Category = grp2idx(category);
varNames = {'Name','Category'};
categoryOverview = table(unique(category),unique(dataTrim.Category),'VariableNames',varNames);

%Preallocate
numberOfDaysIncluded = 5;


%% Opsætning af data til datasamlet
% Variabel der definerer antallet af subfeatures
numOfSubfeatures = 8;
% Preallokering 
%dataSamlet = zeros(1065, length(unique(dataTrim.Category))*numOfSubfeatures+1);

%PatientID og hvilken dag der er oplevet hypo
hypoPatientDayInfo = [dataTrim.patientunitstayid(locationOfglucoseMeasurementsUnder70) dataTrim.testDay(locationOfglucoseMeasurementsUnder70)];

%Indexer labname til talrepresentationer
category = categorical(string(dataTrim.name));
dataTrim.Category = grp2idx(category);
varNames = {'Name','Category'};
categoryOverview = table(unique(category),unique(dataTrim.Category),'VariableNames',varNames);

numberOfDaysIncluded = 5;

row = 1;

for i=1:length(uniquePatient)
    % Find info for hver person
    patientId = uniquePatient(i);
    infoLocation = find(dataTrim.patientunitstayid==patientId);
    patientInfo = dataTrim(infoLocation,:);
    
    %Find the number of days we want to include
    maxNumberOfDays = max(patientInfo.testDay);
    if maxNumberOfDays >= numberOfDaysIncluded+2
       maxNumberOfDays = numberOfDaysIncluded;
    else
        maxNumberOfDays = maxNumberOfDays-2;
    end
    
    % Regn mean for hver dag og for hver feature
    if maxNumberOfDays > 0
        
    % Save label
    hypoDays = hypoPatientDayInfo(find(hypoPatientDayInfo==patientId),2);
        
        for day=1:maxNumberOfDays
            
           %Test om der er glukosemåling dagen efter.
           if ~isempty(find(day+1 == patientInfo.testDay(ismember(infoLocation,glucoseMeasurements))))
               
           patientDayInfo = patientInfo(find(patientInfo.testDay==day),:);
                for index=1:length(unique(dataTrim.Category));
                dataSamlet(row,index)=nanmean(patientDayInfo.result(find(patientDayInfo.Category==index)));
                dataSamlet(row,index+length(unique(dataTrim.Category)))=nanmedian(patientDayInfo.result(find(patientDayInfo.Category==index)));
                dataSamlet(row,index+2*length(unique(dataTrim.Category)))=nanstd(patientDayInfo.result(find(patientDayInfo.Category==index)));
                dataSamlet(row,index+3*length(unique(dataTrim.Category)))=nanvar(patientDayInfo.result(find(patientDayInfo.Category==index)));
                    if isempty(nanmin(patientDayInfo.result(find(patientDayInfo.Category==index))))
                        dataSamlet(row,index+4*length(unique(dataTrim.Category)))=nan;
                    else 
                        dataSamlet(row,index+4*length(unique(dataTrim.Category)))=nanmin(patientDayInfo.result(find(patientDayInfo.Category==index)));
                    end
                    
                    if isempty(nanmax(patientDayInfo.result(find(patientDayInfo.Category==index))))
                        dataSamlet(row,index+5*length(unique(dataTrim.Category)))=nan;
                    else 
                        dataSamlet(row,index+5*length(unique(dataTrim.Category)))=nanmax(patientDayInfo.result(find(patientDayInfo.Category==index)));
                    end
                    
                    if isempty(range(patientDayInfo.result(find(patientDayInfo.Category==index))))
                        dataSamlet(row,index+6*length(unique(dataTrim.Category)))=nan;
                    else 
                        dataSamlet(row,index+6*length(unique(dataTrim.Category)))=range(patientDayInfo.result(find(patientDayInfo.Category==index)));
                    end
                    
                    if 1 >= length(patientDayInfo.result(find(patientDayInfo.Category==index)))
                        dataSamlet(row,index+7*length(unique(dataTrim.Category)))=nan;
                    else 
                      [p,S,mu]=polyfit(patientDayInfo.offset(find(patientDayInfo.Category==index)),patientDayInfo.result(find(patientDayInfo.Category==index)),1);
                      dataSamlet(row,index+7*length(unique(dataTrim.Category))) = p(1,1);
                    end
                end
        
            % Check om hypo i morgen
            isHypoTomorrow = ~isempty(find(hypoDays == day+1));
            % Gem label
            dataSamlet(row,1+numOfSubfeatures*length(unique(dataTrim.Category)))=isHypoTomorrow;
        
            % Tæl op til næste række
            row = row + 1;
            end
        end
    end
end

%% Tilføj sub-kategorier
stringCategory = string(unique(dataTrim.name));
for index=1:length(unique(dataTrim.Category));
    stringCategory{end+1} = char(strcat('Median',string(categoryOverview.Name(index))));
end

for index=1:length(unique(dataTrim.Category));
    stringCategory{end+1} = char(strcat('Std',string(categoryOverview.Name(index))));
end

for index=1:length(unique(dataTrim.Category));
    stringCategory{end+1} = char(strcat('Variance',string(categoryOverview.Name(index))));
end

for index=1:length(unique(dataTrim.Category));
    stringCategory{end+1} = char(strcat('Min',string(categoryOverview.Name(index))));
end

for index=1:length(unique(dataTrim.Category));
    stringCategory{end+1} = char(strcat('Max',string(categoryOverview.Name(index))));
end

for index=1:length(unique(dataTrim.Category));
    stringCategory{end+1} = char(strcat('Range',string(categoryOverview.Name(index))));
end

for index=1:length(unique(dataTrim.Category));
    stringCategory{end+1} = char(strcat('RegCoeff',string(categoryOverview.Name(index))));
end
categoryOverviewWithSubfeatures = [stringCategory,(1:length(stringCategory))'];

%% Vælg de endelige features og gør data klar til at eksportere
% 
% numberOfChosenFeatures = 50;
% 
% correlationCategoryOverview = [categoryOverviewAfterNANExclusion];
% 
% [~,idx] = sort(correlationCategoryOverview(:,3),'descend');
% correlationCategoryFinal = correlationCategoryOverview(idx,:);
% correlationCategoryFinal = correlationCategoryFinal(1:numberOfChosenFeatures,:);
% 
% %LAPPELØSNING
% correlationCategoryFinal(4,1) = 'Minbedsideglucose';
% correlationCategoryFinal(5,1) = 'Variancebedsideglucose';
% correlationCategoryFinal(8,1) = 'Rangebedsideglucose';
% correlationCategoryFinal(9,1) = 'Stdbedsideglucose';
% correlationCategoryFinal(16,1) = 'Medianbedsideglucose';
% correlationCategoryFinal(19,1) = 'Minmonos';
% correlationCategoryFinal(20,1) = 'Mediantotalbilirubin';
% correlationCategoryFinal(21,1) = 'totalbilirubin';
% correlationCategoryFinal(22,1) = 'Mintotalbilirubin';
% correlationCategoryFinal(24,1) = 'Maxtotalbilirubin';
% correlationCategoryFinal(28,1) = 'Medianmonos';
% correlationCategoryFinal(29,1) = 'monos';
% correlationCategoryFinal(31,1) = 'RegCoeffbedsideglucose';
% correlationCategoryFinal(35,1) = 'Maxmonos';
% correlationCategoryFinal(40,1) = 'bedsideglucose';
% 
% finalFeatures = str2double(correlationCategoryFinal(:,[2])');
% %finalFeatures = [659 710 558 709 557 51 203 1013 405 406 1014 856 248 96 704 253 254 722 613 293 141 749 811 901 198 654 46 157 5 806 1165 286 1166 1038 765 266 430 102 134 101 206 54 507 886 236 84 712 256 278 126];
% % 
% 
% % l = correlationCategoryFinal(:,[2])';
% % finalFeatures = str2double(l);
% 
% varNames = [cellstr(string(correlationCategoryFinal(:,1))'),'Label'];
% % % 
% % % %Sorry, dette er ikke smart. MEN det er ikke tiden værd at finde ud af
% % % %dette. Antallet af variable skal skrives manuelt.
% dataFinal = table(dataSamlet(:,finalFeatures(1,1)),dataSamlet(:,finalFeatures(1,2)),dataSamlet(:,finalFeatures(1,3)),dataSamlet(:,finalFeatures(1,4)),dataSamlet(:,finalFeatures(1,5)),dataSamlet(:,finalFeatures(1,6)),dataSamlet(:,finalFeatures(1,7)),dataSamlet(:,finalFeatures(1,8)),dataSamlet(:,finalFeatures(1,9)),dataSamlet(:,finalFeatures(1,10)),dataSamlet(:,finalFeatures(1,11)),dataSamlet(:,finalFeatures(1,12)),dataSamlet(:,finalFeatures(1,13)),dataSamlet(:,finalFeatures(1,14)),dataSamlet(:,finalFeatures(1,15)),dataSamlet(:,finalFeatures(1,16)),dataSamlet(:,finalFeatures(1,17)),dataSamlet(:,finalFeatures(1,18)),dataSamlet(:,finalFeatures(1,19)),dataSamlet(:,finalFeatures(1,20)),dataSamlet(:,finalFeatures(1,21)),dataSamlet(:,finalFeatures(1,22)),dataSamlet(:,finalFeatures(1,23)),dataSamlet(:,finalFeatures(1,24)),dataSamlet(:,finalFeatures(1,25)),dataSamlet(:,finalFeatures(1,26)),dataSamlet(:,finalFeatures(1,27)),dataSamlet(:,finalFeatures(1,28)),dataSamlet(:,finalFeatures(1,29)),dataSamlet(:,finalFeatures(1,30)),dataSamlet(:,finalFeatures(1,31)),dataSamlet(:,finalFeatures(1,32)),dataSamlet(:,finalFeatures(1,33)),dataSamlet(:,finalFeatures(1,34)),dataSamlet(:,finalFeatures(1,35)),dataSamlet(:,finalFeatures(1,36)),dataSamlet(:,finalFeatures(1,37)),dataSamlet(:,finalFeatures(1,38)),dataSamlet(:,finalFeatures(1,39)),dataSamlet(:,finalFeatures(1,40)),dataSamlet(:,finalFeatures(1,41)),dataSamlet(:,finalFeatures(1,42)),dataSamlet(:,finalFeatures(1,43)),dataSamlet(:,finalFeatures(1,44)),dataSamlet(:,finalFeatures(1,45)),dataSamlet(:,finalFeatures(1,46)),dataSamlet(:,finalFeatures(1,47)),dataSamlet(:,finalFeatures(1,48)),dataSamlet(:,finalFeatures(1,49)),dataSamlet(:,finalFeatures(1,50)),dataSamlet(:,size(dataSamlet,2)),'VariableNames',varNames);
% % 
% % 