clc
close all
clearvars -except rand200pidlab

%% Hent data, ekskluder patienter, label data og opdeling data p� dage pr. patient

%% Load data 
%load('rand200pidlab');

%% Dupliker data s� vi regner videre p� en ny variabel

data = rand200pidlab;

%% Her fjernes alle r�kker med negative labresultoffset og output gemmes i en ny tabel
for i = 1:size(data,1)
    ind(i) = all(data.labresultoffset(i) >= 0);
end

dataUNeg = data(ind, :);

% Nu findes antal af patienter tilbage efter fjernelse af r�kker med
% negative offset
numUniPidUNeg = size(unique(dataUNeg.patientunitstayid),1);

%% Find patienterne med en eller flere glucosem�ling(er) - glucose = category 79 og bedside glucose = category 69
for i = 1:size(dataUNeg.patientunitstayid)
    idx(i) = all(dataUNeg.labname(i) == 'bedside glucose' | all(dataUNeg.labname(i) == 'glucose'));
end

dataUNegOnlyGlu = dataUNeg(idx, :);

% Nu findes antal patienter tilbage efter fjernelse af patienter uden
% glucose m�linger

numUniPid = size(unique(dataUNegOnlyGlu.patientunitstayid),1);

%% Lav en tabel med alle datar�kker for hver patient - join uniquePid med dataUNeg
dataTrim = dataUNeg(ismember(dataUNeg.patientunitstayid,unique(dataUNegOnlyGlu.patientunitstayid)),:); %alle r�kke med de inkluderede patienter er fundet (patienter med glucose m�linger og ingen negative lab offset)

%% Find unikke rows af patient og unikke rows af patient med tilh�rende data s� det kan bruges til beregning
uniquePatient = unique(dataTrim.patientunitstayid);

[~,idu] = unique(dataTrim.patientunitstayid);
uniqueDataTrimPatientID = dataTrim(idu,:);

%% L�kke til opdeling af m�linger for hver unikke patientid
% Preallocate
testDay = zeros(length(dataTrim.labresult),1);

for index=1:length(uniquePatient)
    timeIndex = uniqueDataTrimPatientID.unitadmittime24(index);  % Find admit-time for patient 'index' 
    [h,m] = hms(timeIndex);  % Omregn til timer og minutter
    tidIMin = 60*h+m;
    tidTilMidnat = 1440-tidIMin;
    
    n=find(uniquePatient(index) == dataTrim.patientunitstayid); % Find de samples der tilh�re patient 'index'
            
    % Udregning af hvor mange dage patienten har data for. Der findes offset for den sidste m�ling (ved max(offset(n))). Dette divideres med 60*24 og rundes op.
    numberOfTestDays = ceil((max(dataTrim.labresultoffset(n))-tidTilMidnat)/1440);
    
    % L�kke for opdeling af dag 1 indtil antallet af dag med test. De der h�rer til dag 0 er allerede 0.
    for day=1:numberOfTestDays
    % Der findes de samples hvor patientens offset ligger over tidTilMidnat og under tidTilMadnat+(60*24). For hver iteration ligges i*(60*24) oveni begge for p� den m�de at skrifte til en ny dag. Dette gemmes hver gang p� som dag(i+1).
        testDay(n(find(((day-1)*1440+tidTilMidnat) <= dataTrim.labresultoffset(n) & ((day-1)*1440+tidTilMidnat+1440) > dataTrim.labresultoffset(n))))=(day-1)+1;
    end
end

% Vi slutter med at samle data.
dataTrim = [dataTrim table(testDay)];

%% Label data

glucoseMeasurements = find(dataTrim.labname == 'bedside glucose' | dataTrim.labname == 'glucose');
glucoseMeasurementsUnder70 = dataTrim.labresult(glucoseMeasurements)<=70;
locationOfglucoseMeasurementsUnder70 = glucoseMeasurements(glucoseMeasurementsUnder70);

%Preallocate
label = zeros(size(dataTrim.labresult,1),1);
label(locationOfglucoseMeasurementsUnder70)=1;

%Save
dataTrim = [dataTrim table(label)];

%% Ops�tning af data til gennerelt overblik

%PatientID og hvilken dag der er oplevet hypo
hypoPatientDayInfo = [dataTrim.patientunitstayid(locationOfglucoseMeasurementsUnder70) dataTrim.testDay(locationOfglucoseMeasurementsUnder70)];

%Indexer labname til talrepresentationer
category = categorical(string(dataTrim.labname));
dataTrim.labCategory = grp2idx(category);
varNames = {'LabName','LabCategory'};
categoryOverview = table(unique(category),unique(dataTrim.labCategory),'VariableNames',varNames);

%Preallocate
numberOfDaysIncluded = 5;

%% Ops�tning af data til dataoversigt
% dataOversigt = zeros(length(uniquePatient),(1+length(unique(dataTrim.labCategory))*numberOfDaysIncluded));
% 
% for i=1:length(uniquePatient)
%     % Find info for hver person
%     patientId = uniquePatient(i);
%     infoLocation = find(dataTrim.patientunitstayid==patientId);
%     patientInfo = dataTrim(infoLocation,:);
%     %Find the number of days we want to include
%     maxNumberOfDays = max(patientInfo.testDay);
%     if maxNumberOfDays >= numberOfDaysIncluded+2
%        maxNumberOfDays = numberOfDaysIncluded;
%     else
%         maxNumberOfDays = maxNumberOfDays-2;
%     end
%     
%     %Gemt patientId
%     dataOversigt(i,1) = patientId;
%     
%     % Save label
%     hypoDays = hypoPatientDayInfo(find(hypoPatientDayInfo==patientId),2);
%     
%     for day=1:maxNumberOfDays
%         patientDayInfo = patientInfo(find(patientInfo.testDay==day),:);
%         for index=1:length(unique(dataTrim.labCategory));
%             dataOversigt(i,index+1+((day-1)*(length(unique(dataTrim.labCategory))+1)))=mean(patientDayInfo.labresult(find(patientDayInfo.labCategory==index)));
%         end
%         
%         % Check om hypo i morgen
%         isHypoTomorrow = ~isempty(find(hypoDays == day+1));
%         % Gem label
%         dataOversigt(i,1+((1+length(unique(dataTrim.labCategory)))*day))=isHypoTomorrow;
%     end
% end

%% Ops�tning af data til datasamlet

%PatientID og hvilken dag der er oplevet hypo
hypoPatientDayInfo = [dataTrim.patientunitstayid(locationOfglucoseMeasurementsUnder70) dataTrim.testDay(locationOfglucoseMeasurementsUnder70)];

%Indexer labname til talrepresentationer
category = categorical(string(dataTrim.labname));
dataTrim.labCategory = grp2idx(category);
varNames = {'LabName','LabCategory'};
categoryOverview = table(unique(category),unique(dataTrim.labCategory),'VariableNames',varNames);

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
        patientDayInfo = patientInfo(find(patientInfo.testDay==day),:);
        for index=1:length(unique(dataTrim.labCategory));
            dataSamlet(row,index)=mean(patientDayInfo.labresult(find(patientDayInfo.labCategory==index)));
        end
        
        % Check om hypo i morgen
        isHypoTomorrow = ~isempty(find(hypoDays == day+1));
        % Gem label
        dataSamlet(row,1+length(unique(dataTrim.labCategory)))=isHypoTomorrow;
        
        % T�l op til n�ste r�kke
        row = row + 1;
    end
    end
end

%% Antal af NAN plot

for c=1:length(unique(dataTrim.labCategory))
    dataNAN(1,c) = sum(isnan(dataSamlet(:,c)));
end

figure
bar(categoryOverview.LabName,dataNAN)
title('Number of missing measurements');
xlabel('Feature');
ylabel('Number of NAN values');

dataNANprocent = 100*(dataNAN./length(dataSamlet));

figure
bar(categoryOverview.LabName,dataNANprocent)
title('Procent of missing measurements');
xlabel('Feature');
ylabel('Procent of NAN values');

thresholdForExcludingNAN = 100;

dataSamletAfterNANExclusion = [dataSamlet(:,find(dataNAN <=thresholdForExcludingNAN)),dataSamlet(:,length(unique(dataTrim.labCategory))+1)];
categoryOverviewAfterNANExclusion = categoryOverview(find(dataNAN <=thresholdForExcludingNAN),:);

%% Korrelationsanalyse

dataSamletNANToZero = dataSamletAfterNANExclusion;
dataSamletNANToZero(isnan(dataSamletNANToZero))=0; 

for i=1:length(unique(categoryOverviewAfterNANExclusion.LabCategory))
    correlation(i,1) = abs(corr2(dataSamletNANToZero(:,i),dataSamletNANToZero(:,size(dataSamletNANToZero,2))));
end

figure
bar(categoryOverviewAfterNANExclusion.LabName,correlation)
title('Overview of correlation between feature and class label');
xlabel('Feature');
ylabel('Correlation coefficient');

% %% V�lg de endelige features og g�r data klar til at eksportere
% 
% numberOfChosenFeatures = 10;
% 
% correlationCategoryOverview = [categoryOverviewAfterNANExclusion, table(correlation)];
% 
% [~,idx] = sort(correlationCategoryOverview.correlation,'descend');
% correlationCategoryFinal = correlationCategoryOverview(idx,:);
% correlationCategoryFinal = correlationCategoryFinal(1:numberOfChosenFeatures,:);
% 
% %varName = {cellstr(string(correlationCategoryFinal.LabName(1)))};
% varName = {'hej'};
% T = table('VariableNames',varName);
% T = table(dataSamlet(:,correlationCategoryFinal.LabCategory(1)));
% for i=1:numberOfChosenFeatures-1
%    varName = {cellstr(string(correlationCategoryFinal.LabName(i+1)))};
%    T = [T table(dataSamlet(:,correlationCategoryFinal.LabCategory(i+1)),'VariableNames',varName)];
% end
% 
% hej = table(dataSamlet(:,correlationCategoryFinal.LabCategory));
% %varNames = {cellstr(string(correlationCategoryFinal.LabName(i+1)))};
% %,'VariableNames',varNames
% dataFinal = [table(dataSamlet(:,correlationCategoryFinal.LabCategory)),table(dataSamletNANToZero)];

