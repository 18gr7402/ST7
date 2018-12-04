clc
close all
clear
%clearvars -except rand200pidlab

%% Hent data, ekskluder patienter, label data og opdeling data på dage pr. patient

%% Load data 
load('FeatureLabelTabel80p');

%% Dupliker data så vi regner videre på en ny variabel

data = FeatureLabelTabel80p(1:10000,:);

%% Her fjernes alle rækker med negative offset og output gemmes i en ny tabel
for i = 1:size(data,1)
    ind(i) = all(data.offset(i) >= 0);
end

dataTrim = data(ind, :);

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
numOfSubfeatures = 7;
% Preallokering 
dataSamlet = zeros(1065, length(unique(dataTrim.Category))*numOfSubfeatures+1);

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
    
    % Regn subfeatures for hver dag
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