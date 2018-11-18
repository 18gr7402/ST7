clc
close all
clear
%clearvars -except rand200pidlab

%% Hent data, ekskluder patienter, label data og opdeling data på dage pr. patient

%% Load data 
load('FeatureLabelTabel500');

%% Dupliker data så vi regner videre på en ny variabel

data = FeatureLabelTabel;

%% Her fjernes alle rækker med negative labresultoffset og output gemmes i en ny tabel
for i = 1:size(data,1)
    ind(i) = all(data.offset(i) >= 0);
end

dataUNeg = data(ind, :);

% Nu findes antal af patienter tilbage efter fjernelse af rækker med
% negative offset
numUniPidUNeg = size(unique(dataUNeg.patientunitstayid),1);

%% Find patienterne med en eller flere glucosemåling(er) - glucose = category 79 og bedside glucose = category 69
for i = 1:size(dataUNeg.patientunitstayid)
    idx(i) = all(dataUNeg.name(i) == 'bedside glucose' | all(dataUNeg.name(i) == 'glucose'));
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

glucoseMeasurements = find(dataTrim.name == 'bedside glucose' | dataTrim.name == 'glucose');
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

%% Opsætning af data til dataoversigt
% dataOversigt = zeros(length(uniquePatient),(1+length(unique(dataTrim.Category))*numberOfDaysIncluded));
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
%         for index=1:length(unique(dataTrim.Category));
%             dataOversigt(i,index+1+((day-1)*(length(unique(dataTrim.Category))+1)))=mean(patientDayInfo.result(find(patientDayInfo.Category==index)));
%         end
%         
%         % Check om hypo i morgen
%         isHypoTomorrow = ~isempty(find(hypoDays == day+1));
%         % Gem label
%         dataOversigt(i,1+((1+length(unique(dataTrim.Category)))*day))=isHypoTomorrow;
%     end
% end

%% Opsætning af data til datasamlet

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
                end
        
            % Check om hypo i morgen
            isHypoTomorrow = ~isempty(find(hypoDays == day+1));
            % Gem label
            dataSamlet(row,1+length(unique(dataTrim.Category)))=isHypoTomorrow;
        
            % Tæl op til næste række
            row = row + 1;
            end
        end
    end
end

%% Antal af NAN plot

for c=1:length(unique(dataTrim.Category))
    dataNAN(1,c) = sum(isnan(dataSamlet(:,c)));
end

figure
bar(categoryOverview.Name,dataNAN)
title('Number of missing measurements');
xlabel('Feature');
ylabel('Number of NAN values');

dataNANprocent = 100*(dataNAN./length(dataSamlet));

figure
bar(categoryOverview.Name,dataNANprocent)
title('Procent of missing measurements');
xlabel('Feature');
ylabel('Procent of NAN values');

thresholdForExcludingNAN = 500;

dataSamletAfterNANExclusion = [dataSamlet(:,find(dataNAN <=thresholdForExcludingNAN)),dataSamlet(:,length(unique(dataTrim.Category))+1)];
categoryOverviewAfterNANExclusion = categoryOverview(find(dataNAN <=thresholdForExcludingNAN),:);

%% Korrelationsanalyse


for i=1:length(unique(categoryOverviewAfterNANExclusion.Category))
    ind = ~isnan(dataSamletAfterNANExclusion(:,i));
    dataForAnalysis(1+((i-1)*(length(dataSamletAfterNANExclusion))):length(dataSamletAfterNANExclusion)+((i-1)*(length(dataSamletAfterNANExclusion))),1) = dataSamletAfterNANExclusion(:,i);
    dataForAnalysis(1+((i-1)*(length(dataSamletAfterNANExclusion))):length(dataSamletAfterNANExclusion)+((i-1)*(length(dataSamletAfterNANExclusion))),2) = categoryOverviewAfterNANExclusion.Name(i);
    %Test for correlation
    correlation(i,1) = abs(corr2(dataSamletAfterNANExclusion(ind,i),dataSamletAfterNANExclusion(ind,size(dataSamletAfterNANExclusion,2))));
    %Test for normal distribution: h = kstest(x) returns a test decision for the null hypothesis that the data in vector x comes from a standard normal distribution, against the alternative that it does not come from such a distribution, using the one-sample Kolmogorov-Smirnov test. The result h is 1 if the test rejects the null hypothesis at the 5% significance level, or 0 otherwise.
    isGaussianDistribution(i,1) = kstest((dataSamletAfterNANExclusion(ind,i)));
    %Test for outliers så det kan sammenholdes med total antal: 
    isOutlier(i,1) = sum(isoutlier((dataSamletAfterNANExclusion(ind,i))));
    isOutlier(i,2) = length(dataSamletAfterNANExclusion(ind,i));
end
% Test for equal variance: vartestn(x) returns a summary table of statistics and a box plot for a Bartlett test of the null hypothesis that the columns of data vector x come from normal distributions with the same variance. The alternative hypothesis is that not all columns of data have the same variance.
%A low -value, p = 0, indicates that vartestn rejects the null hypothesis that the variances are equal across all five columns, in favor of the alternative hypothesis that at least one column has a different variance.
    vartestn(dataForAnalysis(:,1),dataForAnalysis(:,2))

figure
bar(categoryOverviewAfterNANExclusion.Name,correlation)
title('Overview of correlation between feature and class label');
xlabel('Feature');
ylabel('Correlation coefficient');

%% Vælg de endelige features og gør data klar til at eksportere

%  numberOfChosenFeatures = 10;
% % 
%  correlationCategoryOverview = [categoryOverviewAfterNANExclusion, table(correlation)];
%  
%  [~,idx] = sort(correlationCategoryOverview.correlation,'descend');
%  correlationCategoryFinal = correlationCategoryOverview(idx,:);
%  correlationCategoryFinal = correlationCategoryFinal(1:numberOfChosenFeatures,:);
% % 
% varNames = cellstr(string(correlationCategoryFinal.LabName));
% % varName = {'hej'};
% % T = table('VariableNames',varName);
% % T = table(dataSamlet(:,correlationCategoryFinal.LabCategory(1)));
% % for i=1:numberOfChosenFeatures-1
% %    varName = {cellstr(string(correlationCategoryFinal.LabName(i+1)))};
% %    T = [T table(dataSamlet(:,correlationCategoryFinal.LabCategory(i+1)),'VariableNames',varName)];
% % end
% % 
% % % hej = table(dataSamlet(:,correlationCategoryFinal.LabCategory));
% % % %varNames = {cellstr(string(correlationCategoryFinal.LabName(i+1)))};
% % % %,'VariableNames',varNames
% % % dataFinal = [table(dataSamlet(:,correlationCategoryFinal.LabCategory)),table(dataSamletNANToZero)];
% 
% T = array2table(dataSamlet(:,correlationCategoryFinal.LabCategory),'VariableNames',varNames);