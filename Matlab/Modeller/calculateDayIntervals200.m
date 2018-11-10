clc
close all

%% Hent data, ekskluder patienter, label data og opdeling data på dage pr. patient

%% Load data 
%load('rand200pidlab');

%% Dupliker data så vi regner videre på en ny variabel

data = rand200pidlab;

%% Her fjernes alle rækker med negative labresultoffset og output gemmes i en ny tabel
for i = 1:size(data, 1)
    ind(i) = all(data.labresultoffset(i) >= 0);
end

dataUNeg = data(ind, :);

% Nu findes antal af patienter tilbage efter fjernelse af rækker med
% negative offset
numUniPidUNeg = size(unique(dataUNeg.patientunitstayid),1);

%% Find patienterne med en eller flere glucosemåling(er) - glucose = category 79 og bedside glucose = category 69
for i = 1:size(dataUNeg.patientunitstayid)
    idx(i) = all(dataUNeg.labname(i) == 'bedside glucose' | all(dataUNeg.labname(i) == 'glucose'));
end

dataUNegOnlyGlu = dataUNeg(idx, :);

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
testDay = zeros(length(dataTrim.labresult),1);

for index=1:length(uniquePatient)
    timeIndex = uniqueDataTrimPatientID.unitadmittime24(index);  % Find admit-time for patient 'index' 
    [h,m] = hms(timeIndex);  % Omregn til timer og minutter
    tidIMin = 60*h+m;
    tidTilMidnat = 1440-tidIMin;
    
    n=find(uniquePatient(index) == dataTrim.patientunitstayid); % Find de samples der tilhøre patient 'index'
            
    % Udregning af hvor mange dage patienten har data for. Der findes offset for den sidste måling (ved max(offset(n))). Dette divideres med 60*24 og rundes op.
    numberOfTestDays = ceil((max(dataTrim.labresultoffset(n))-tidTilMidnat)/1440);
    
    % Løkke for opdeling af dag 1 indtil antallet af dag med test. De der hører til dag 0 er allerede 0.
    for day=1:numberOfTestDays
    % Der findes de samples hvor patientens offset ligger over tidTilMidnat og under tidTilMadnat+(60*24). For hver iteration ligges i*(60*24) oveni begge for på den måde at skrifte til en ny dag. Dette gemmes hver gang på som dag(i+1).
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

%% Opsætning af data til dataoversigt

%PatientID og hvilken dag der er oplevet hypo
hypoPatientDayInfo = [dataTrim.patientunitstayid(locationOfglucoseMeasurementsUnder70) dataTrim.testDay(locationOfglucoseMeasurementsUnder70)];

%Indexer labname til talrepresentationer
category = categorical(string(dataTrim.labname));
dataTrim.labCategory = grp2idx(category);
varNames = {'LabName','LabCategory'};
categoryOverview = table(unique(category),unique(dataTrim.labCategory),'VariableNames',varNames);

%Preallocate
numberOfDaysIncluded = 5;
dataOversigt = zeros(length(uniquePatient),(1+length(unique(dataTrim.labCategory))*numberOfDaysIncluded));

for i=1:length(uniquePatient)
    % Find info for hver person
    patientId = uniquePatient(i);
    infoLocation = find(dataTrim.patientunitstayid==patientId);
    patientInfo = dataTrim(infoLocation,:);
    
    %Gemt patientId
    dataOversigt(i,1) = patientId;
    
    % Save label
    labelDataLocation = find(hypoPatientDayInfo==patientId);
    hypoDays = hypoPatientDayInfo(labelDataLocation,2);
    
    for day=1:numberOfDaysIncluded
        % Check om hypo i morgen
        isHypoTomorrow = ~isempty(find(hypoDays == day+1));
        % Gem label
        dataOversigt(i,1+((1+length(unique(dataTrim.labCategory)))*day))=isHypoTomorrow;
        for index=1:length(unique(dataTrim.labCategory));
            categoryDataLocation = find(patientInfo.labCategory==index);
            dataOversigt(i,index+1+((day-1)*(length(unique(dataTrim.labCategory))+1)))=mean(dataTrim.labresult(categoryDataLocation));
        end
    end
end

%% Samling af data til korrelation og klassifikation

for day=1:numberOfDaysIncluded
dataSamlet(1+(day-1)*size(dataOversigt,1):(day)*size(dataOversigt,1),:) = dataOversigt(1:size(dataOversigt,1), 2+(day-1)*(length(unique(dataTrim.labCategory))+1):length(unique(dataTrim.labCategory))+2+(day-1)*(length(unique(dataTrim.labCategory))+1));
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

%% Korrelationsanalyse
dataSamlet(isnan(dataSamlet))=0;

for i=1:length(unique(dataTrim.labCategory))
correlation(1,i) = corr2(dataSamlet(:,i),dataSamlet(:,length(unique(dataTrim.labCategory))+1));
end

figure
bar(categoryOverview.LabName,abs(correlation))
title('Overview of correlation between feature and class label');
xlabel('Feature');
ylabel('Correlation coefficient');

