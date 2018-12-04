clc
close all
clear
%clearvars -except rand200pidlab

%% Hent data, ekskluder patienter, label data og opdeling data p� dage pr. patient

%% Load data VIGTIGT! �ndre til det rette subset
load('subset80p1');

%% Dupliker data s� vi regner videre p� en ny variabel

data = subset1;

%% Her fjernes alle r�kker med negative offset og output gemmes i en ny tabel
for i = 1:size(data,1)
    ind(i) = all(data.offset(i) >= 0);
end

dataTrim = data(ind, :);

%% Find unikke rows af patient og unikke rows af patient med tilh�rende data s� det kan bruges til beregning
uniquePatient = unique(dataTrim.patientunitstayid);

[~,idu] = unique(dataTrim.patientunitstayid);
uniqueDataTrimPatientID = dataTrim(idu,:);

%% L�kke til opdeling af m�linger for hver unikke patientid
% Preallocate
testDay = zeros(length(dataTrim.result),1);

for index=1:length(uniquePatient)
    timeIndex = uniqueDataTrimPatientID.unitadmittime24(index);  % Find admit-time for patient 'index' 
    [h,m] = hms(timeIndex);  % Omregn til timer og minutter
    tidIMin = 60*h+m;
    tidTilMidnat = 1440-tidIMin;
    
    n=find(uniquePatient(index) == dataTrim.patientunitstayid); % Find de samples der tilh�re patient 'index'
            
    % Udregning af hvor mange dage patienten har data for. Der findes offset for den sidste m�ling (ved max(offset(n))). Dette divideres med 60*24 og rundes op.
    numberOfTestDays = ceil((max(dataTrim.offset(n))-tidTilMidnat)/1440);
    
    % L�kke for opdeling af dag 1 indtil antallet af dag med test. De der h�rer til dag 0 er allerede 0.
    for day=1:numberOfTestDays
    % Der findes de samples hvor patientens offset ligger over tidTilMidnat og under tidTilMadnat+(60*24). For hver iteration ligges i*(60*24) oveni begge for p� den m�de at skrifte til en ny dag. Dette gemmes hver gang p� som dag(i+1).
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

%% Ops�tning af data til generelt overblik
% 
% %PatientID og hvilken dag der er oplevet hypo
% hypoPatientDayInfo = [dataTrim.patientunitstayid(locationOfglucoseMeasurementsUnder70) dataTrim.testDay(locationOfglucoseMeasurementsUnder70)];
% 
% %Indexer labname til talrepresentationer
% category = categorical(string(dataTrim.name));
% dataTrim.Category = grp2idx(category);
% varNames = {'Name','Category'};
% categoryOverview = table(unique(category),unique(dataTrim.Category),'VariableNames',varNames);
% 
% %Preallocate
% numberOfDaysIncluded = 5;

%% Ops�tning af data til datasamlet
% Variabel der definerer antallet af subfeatures
numOfSubfeatures = 7;
% Preallokering 
% dataSamlet = zeros(1065,15);

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
            
           %Test om der er glukosem�ling dagen efter.
           if ~isempty(find(day+1 == patientInfo.testDay(ismember(infoLocation,glucoseMeasurements))))
               
           patientDayInfo = patientInfo(find(patientInfo.testDay==day),:);
                % OBS TJEK category nummer, da dette �ndrer sig
                dataSamlet(row,1)=nanmean(patientDayInfo.result(find(patientDayInfo.Category==1))); %-monos
                dataSamlet(row,2)=nanmean(patientDayInfo.result(find(patientDayInfo.Category==3))); %NCRR
                dataSamlet(row,3)=nanmean(patientDayInfo.result(find(patientDayInfo.Category==6))); %RespiratoryRateOverall
                dataSamlet(row,4)=nanmedian(patientDayInfo.result(find(patientDayInfo.Category==1))); %-monos
                dataSamlet(row,5)=nanmedian(patientDayInfo.result(find(patientDayInfo.Category==9))); %RespiratoryRateOverall
                dataSamlet(row,6)=nanstd(patientDayInfo.result(find(patientDayInfo.Category==8))); %phosphate
                dataSamlet(row,7)=nanvar(patientDayInfo.result(find(patientDayInfo.Category==2))); %NCBG
                
                    if isempty(nanmin(patientDayInfo.result(find(patientDayInfo.Category==1)))) %-monos
                        dataSamlet(row,8)=nan;
                    else 
                        dataSamlet(row,8)=nanmin(patientDayInfo.result(find(patientDayInfo.Category==1)));
                    end
                    
                    if isempty(nanmin(patientDayInfo.result(find(patientDayInfo.Category==7)))) % glucose 
                        dataSamlet(row,9)=nan;
                    else 
                        dataSamlet(row,9)=nanmin(patientDayInfo.result(find(patientDayInfo.Category==7)));
                    end
                    
                    if isempty(nanmin(patientDayInfo.result(find(patientDayInfo.Category==6)))) %bedside glucose overall
                        dataSamlet(row,10)=nan;
                    else 
                        dataSamlet(row,10)=nanmin(patientDayInfo.result(find(patientDayInfo.Category==6)));
                    end
                    
                    if isempty(nanmax(patientDayInfo.result(find(patientDayInfo.Category==4)))) %albumin
                        dataSamlet(row,11)=nan;
                    else 
                        dataSamlet(row,11)=nanmax(patientDayInfo.result(find(patientDayInfo.Category==4)));
                    end
                                        
                    if isempty(nanmax(patientDayInfo.result(find(patientDayInfo.Category==8)))) %phosphate
                        dataSamlet(row,12)=nan;
                    else 
                        dataSamlet(row,12)=nanmax(patientDayInfo.result(find(patientDayInfo.Category==8)));
                    end
                    
                    if isempty(nanmax(patientDayInfo.result(find(patientDayInfo.Category==10)))) %total bilirubin
                        dataSamlet(row,13)=nan;
                    else 
                        dataSamlet(row,13)=nanmax(patientDayInfo.result(find(patientDayInfo.Category==10)));
                    end
                    
                    if isempty(range(patientDayInfo.result(find(patientDayInfo.Category==5)))) %bedside glucose
                        dataSamlet(row,14)=nan;
                    else 
                        dataSamlet(row,14)=range(patientDayInfo.result(find(patientDayInfo.Category==5)));
                    end
        
            % Check om hypo i morgen
            isHypoTomorrow = ~isempty(find(hypoDays == day+1));
            % Gem label
            dataSamlet(row,15)=isHypoTomorrow;
        
            % T�l op til n�ste r�kke
            row = row + 1;
            end
        end
    end
end

%% Tilf�j sub-kategorier
stringCategory = string(unique(dataTrim.name));
stringCategory{end+1} = char(strcat('Median',string(categoryOverview.Name(1)))); %-monos
stringCategory{end+1} = char(strcat('Median',string(categoryOverview.Name(9)))); %RR Overall
stringCategory{end+1} = char(strcat('Std',string(categoryOverview.Name(8)))); %phosphate
stringCategory{end+1} = char(strcat('Variance',string(categoryOverview.Name(2)))); %NCBG
stringCategory{end+1} = char(strcat('Min',string(categoryOverview.Name(1)))); %-monos
stringCategory{end+1} = char(strcat('Min',string(categoryOverview.Name(7)))); %glucose
stringCategory{end+1} = char(strcat('Min',string(categoryOverview.Name(6)))); %bedside glucose overall
stringCategory{end+1} = char(strcat('Max',string(categoryOverview.Name(4)))); %albumin
stringCategory{end+1} = char(strcat('Max',string(categoryOverview.Name(8)))); %phosphate
stringCategory{end+1} = char(strcat('Max',string(categoryOverview.Name(10)))); %total bilirubin
stringCategory{end+1} = char(strcat('Range',string(categoryOverview.Name(5)))); %bedside glucose

categoryOverviewWithSubfeatures = [stringCategory,(1:length(stringCategory))'];

