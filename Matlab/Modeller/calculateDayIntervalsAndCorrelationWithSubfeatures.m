clc
close all
clear
%clearvars -except rand200pidlab

%% Hent data, ekskluder patienter, label data og opdeling data p� dage pr. patient

%% Load data 
load('FeatureLabelTabelWithOverallData500');

%% Dupliker data s� vi regner videre p� en ny variabel

data = FeatureLabelTabelWithOverallData;

%% Her fjernes alle r�kker med negative labresultoffset og output gemmes i en ny tabel
for i = 1:size(data,1)
    ind(i) = all(data.offset(i) >= 0);
end

dataUNeg = data(ind, :);

% Nu findes antal af patienter tilbage efter fjernelse af r�kker med
% negative offset
numUniPidUNeg = size(unique(dataUNeg.patientunitstayid),1);

%% Find patienterne med en eller flere glucosem�ling(er) - glucose = category 79 og bedside glucose = category 69
% for i = 1:size(dataUNeg.patientunitstayid)
%     idx(i) = all(dataUNeg.name(i) == 'bedside glucose' | dataUNeg.name(i) == 'glucose');
% end
% FIKS NAVNE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
dataUNegOnlyGlu = dataUNeg;

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

%% Ops�tning af data til gennerelt overblik

%PatientID og hvilken dag der er oplevet hypo
hypoPatientDayInfo = [dataTrim.patientunitstayid(locationOfglucoseMeasurementsUnder70) dataTrim.testDay(locationOfglucoseMeasurementsUnder70)];

%Indexer labname til talrepresentationer
category = categorical(string(dataTrim.name));
dataTrim.Category = grp2idx(category);
varNames = {'Name','Category'};
categoryOverview = table(unique(category),unique(dataTrim.Category),'VariableNames',varNames);

%Preallocate
numberOfDaysIncluded = 5;

%% Ops�tning af data til dataoversigt
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

%% Ops�tning af data til datasamlet
% Variabel der definerer antallet af subfeatures
numOfSubfeatures = 8;
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
    
    % Regn mean for hver dag og for hver feature
    if maxNumberOfDays > 0
        
    % Save label
    hypoDays = hypoPatientDayInfo(find(hypoPatientDayInfo==patientId),2);
        
        for day=1:maxNumberOfDays
            
           %Test om der er glukosem�ling dagen efter.
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
        
            % T�l op til n�ste r�kke
            row = row + 1;
            end
        end
    end
end

%% Tilf�j sub-kategorier
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


%% Antal af NAN plot


for i=1:size(dataSamlet,2)-1
    dataNAN(1,i) = sum(isnan(dataSamlet(:,i)));
end

figure
bar(dataNAN)
title('Number of missing measurements');
xlabel('Feature');
ylabel('Number of NAN values');

dataNANprocent = 100*(dataNAN./length(dataSamlet));

figure
bar(dataNANprocent)
title('Procent of missing measurements');
xlabel('Feature');
ylabel('Procent of NAN values');

thresholdForExcludingNAN = 800;

dataSamletAfterNANExclusion = [dataSamlet(:,find(dataNAN <=thresholdForExcludingNAN)),dataSamlet(:,size(dataSamlet,2))];
categoryOverviewAfterNANExclusion = categoryOverviewWithSubfeatures(find(dataNAN <=thresholdForExcludingNAN),:);

%% Korrelationsanalyse

for i=1:length(unique(categoryOverviewAfterNANExclusion(:,2)))
    % Inddeling af data
    ind = ~isnan(dataSamletAfterNANExclusion(:,i));
    %dataForAnalysis(1+((i-1)*(length(dataSamletAfterNANExclusion))):length(dataSamletAfterNANExclusion)+((i-1)*(length(dataSamletAfterNANExclusion))),1) = dataSamletAfterNANExclusion(:,i);
    %dataForAnalysis(1+((i-1)*(length(dataSamletAfterNANExclusion))):length(dataSamletAfterNANExclusion)+((i-1)*(length(dataSamletAfterNANExclusion))),2) = categoryOverviewAfterNANExclusion.Name(i);
    
    dataSamletAfterNANExclusionNoNAN = dataSamletAfterNANExclusion(ind,i);
    labelAfterNANExclusionNoNAN = dataSamletAfterNANExclusion(ind,size(dataSamletAfterNANExclusion,2));
    
    dataTemp1 = dataSamletAfterNANExclusionNoNAN(logical(labelAfterNANExclusionNoNAN));
    dataTemp1Position1 = find(logical(labelAfterNANExclusionNoNAN));
    dataTemp1OutlierPosition1 = find(isoutlier(dataTemp1,'mean'));
    
    dataTemp0 = dataSamletAfterNANExclusionNoNAN(logical(~labelAfterNANExclusionNoNAN));
    dataTemp1Position0 = find(logical(labelAfterNANExclusionNoNAN));
    dataTemp1OutlierPosition0 = find(isoutlier(dataTemp1,'mean'));
    
    index = ones(size(dataSamletAfterNANExclusionNoNAN,1),1);
    index(dataTemp1Position1(dataTemp1OutlierPosition1)) = 0;
    index(dataTemp1Position0(dataTemp1OutlierPosition0)) = 0;
    
    dataSamletAfterNANExclusionNoNANNoOutlier = dataSamletAfterNANExclusionNoNAN(logical(index));
    labelAfterNANExclusionNoNANNoOutlier = labelAfterNANExclusionNoNAN(logical(index));
    
    % Analyser
    %Test for normal distribution: h = kstest(x) returns a test decision for the null hypothesis that the data in vector x comes from a standard normal distribution, against the alternative that it does not come from such a distribution, using the one-sample Kolmogorov-Smirnov test. The result h is 1 if the test rejects the null hypothesis at the 5% significance level, or 0 otherwise.
    isGaussianDistribution(i,1) = jbtest(dataTemp1);
    isGaussianDistribution(i,2) = jbtest(dataTemp0);
    isGaussianDistributionNoOutliers(i,1) = jbtest(dataTemp1(~isoutlier(dataTemp1,'mean'),1));
    isGaussianDistributionNoOutliers(i,2) = jbtest(dataTemp0(~isoutlier(dataTemp0,'mean'),1));
%      figure
%      normplot(dataTemp1(~isoutlier(dataTemp1,'mean'),1));
%      figure
%      hist(dataTemp1(~isoutlier(dataTemp1,'mean'),1),10);
%      figure
%      normplot(dataTemp0(~isoutlier(dataTemp0,'mean'),1));
%      figure
%      hist(dataTemp0(~isoutlier(dataTemp0,'mean'),1),40);
     
    %Test for outliers s� det kan sammenholdes med total antal: TF = isoutlier(A) returns a logical array whose elements are true when an outlier is detected in the corresponding element of A. By default, an outlier is a value that is more than three scaled median absolute deviations (MAD) away from the median. If A is a matrix or table, then isoutlier operates on each column separately. If A is a multidimensional array, then isoutlier operates along the first dimension whose size does not equal 1.
    isOutlier(i,1) = sum(isoutlier(dataTemp1,'mean'));
    isOutlier(i,2) = length(dataTemp1);
    isOutlier(i,3) = sum(isoutlier(dataTemp0,'mean'));
    isOutlier(i,4) = length(dataTemp0);
    
    %The Levene, Brown-Forsythe, and O�Brien tests are less sensitive to departures from normality than Bartlett�s test, so they are useful alternatives if you suspect the samples come from nonnormal distributions.
    %[p] = vartestn(dataSamletAfterNANExclusion(ind,i),dataSamletAfterNANExclusion(ind,size(dataSamletAfterNANExclusion,2)),'TestType','LeveneAbsolute','Display','off');
    %[h,p] = vartest2(dataTemp1,dataTemp0);
    %isEqualVariance(i,1) = h;
    %isEqualVariance(i,2) = p;
    
    [h,p] = vartest2(dataTemp1(~isoutlier(dataTemp1,'mean'),1),dataTemp0(~isoutlier(dataTemp0,'mean'),1));
    isEqualVariance(i,1) = h;
    isEqualVariance(i,2) = p;
    
%     figure
%     subplot(1,2,1)
%     boxplot(dataTemp1(~isoutlier(dataTemp1,'mean'),1))
%     subplot(1,2,2)
%     boxplot(dataTemp0(~isoutlier(dataTemp0,'mean'),1))
    
    %Test for correlation
    %Correlation(i,1) = abs(corr2(dataSamletAfterNANExclusionNoNAN,labelAfterNANExclusionNoNAN));
    CorrelationNoOutliers(i,1) = abs(corr2(dataSamletAfterNANExclusionNoNANNoOutlier,labelAfterNANExclusionNoNANNoOutlier));
end
% Test for equal variance: vartestn(x) returns a summary table of statistics and a box plot for a Bartlett test of the null hypothesis that the columns of data vector x come from normal distributions with the same variance. The alternative hypothesis is that not all columns of data have the same variance.
% A low -value, p = 0, indicates that vartestn rejects the null hypothesis that the variances are equal across all five columns, in favor of the alternative hypothesis that at least one column has a different variance.
% vartestn(dataForAnalysis(:,1),dataForAnalysis(:,2),'TestType','LeveneAbsolute');

%% Plot figurer
% figure
% bar(categoryOverviewAfterNANExclusion.Name,isEqualVariance)
% title('P-values of the Leneve absolute test for equal variance between hypo og nohypo group');
% xlabel('Feature');
% ylabel('Correlation coefficient');

% figure
% bar(categoryOverviewAfterNANExclusion.Name,Correlation)
% title('Overview of correlation between feature and class label');
% xlabel('Feature');
% ylabel('Correlation coefficient');

figure
bar(CorrelationNoOutliers)
title('Overview of correlation between feature and class label. No outliers');
xlabel('Feature');
ylabel('Correlation coefficient');

%% V�lg de endelige features og g�r data klar til at eksportere

numberOfChosenFeatures = 50;

correlationCategoryOverview = [categoryOverviewAfterNANExclusion];

[~,idx] = sort(correlationCategoryOverview(:,3),'descend');
correlationCategoryFinal = correlationCategoryOverview(idx,:);
correlationCategoryFinal = correlationCategoryFinal(1:numberOfChosenFeatures,:);

%LAPPEL�SNING
correlationCategoryFinal(4,1) = 'Minbedsideglucose';
correlationCategoryFinal(5,1) = 'Variancebedsideglucose';
correlationCategoryFinal(8,1) = 'Rangebedsideglucose';
correlationCategoryFinal(9,1) = 'Stdbedsideglucose';
correlationCategoryFinal(16,1) = 'Medianbedsideglucose';
correlationCategoryFinal(19,1) = 'Minmonos';
correlationCategoryFinal(20,1) = 'Mediantotalbilirubin';
correlationCategoryFinal(21,1) = 'totalbilirubin';
correlationCategoryFinal(22,1) = 'Mintotalbilirubin';
correlationCategoryFinal(24,1) = 'Maxtotalbilirubin';
correlationCategoryFinal(28,1) = 'Medianmonos';
correlationCategoryFinal(29,1) = 'monos';
correlationCategoryFinal(31,1) = 'RegCoeffbedsideglucose';
correlationCategoryFinal(35,1) = 'Maxmonos';
correlationCategoryFinal(40,1) = 'bedsideglucose';

finalFeatures = str2double(correlationCategoryFinal(:,[2])');
%finalFeatures = [659 710 558 709 557 51 203 1013 405 406 1014 856 248 96 704 253 254 722 613 293 141 749 811 901 198 654 46 157 5 806 1165 286 1166 1038 765 266 430 102 134 101 206 54 507 886 236 84 712 256 278 126];
% 

% l = correlationCategoryFinal(:,[2])';
% finalFeatures = str2double(l);

varNames = [cellstr(string(correlationCategoryFinal(:,1))'),'Label'];
% % 
% % %Sorry, dette er ikke smart. MEN det er ikke tiden v�rd at finde ud af
% % %dette. Antallet af variable skal skrives manuelt.
dataFinal = table(dataSamlet(:,finalFeatures(1,1)),dataSamlet(:,finalFeatures(1,2)),dataSamlet(:,finalFeatures(1,3)),dataSamlet(:,finalFeatures(1,4)),dataSamlet(:,finalFeatures(1,5)),dataSamlet(:,finalFeatures(1,6)),dataSamlet(:,finalFeatures(1,7)),dataSamlet(:,finalFeatures(1,8)),dataSamlet(:,finalFeatures(1,9)),dataSamlet(:,finalFeatures(1,10)),dataSamlet(:,finalFeatures(1,11)),dataSamlet(:,finalFeatures(1,12)),dataSamlet(:,finalFeatures(1,13)),dataSamlet(:,finalFeatures(1,14)),dataSamlet(:,finalFeatures(1,15)),dataSamlet(:,finalFeatures(1,16)),dataSamlet(:,finalFeatures(1,17)),dataSamlet(:,finalFeatures(1,18)),dataSamlet(:,finalFeatures(1,19)),dataSamlet(:,finalFeatures(1,20)),dataSamlet(:,finalFeatures(1,21)),dataSamlet(:,finalFeatures(1,22)),dataSamlet(:,finalFeatures(1,23)),dataSamlet(:,finalFeatures(1,24)),dataSamlet(:,finalFeatures(1,25)),dataSamlet(:,finalFeatures(1,26)),dataSamlet(:,finalFeatures(1,27)),dataSamlet(:,finalFeatures(1,28)),dataSamlet(:,finalFeatures(1,29)),dataSamlet(:,finalFeatures(1,30)),dataSamlet(:,finalFeatures(1,31)),dataSamlet(:,finalFeatures(1,32)),dataSamlet(:,finalFeatures(1,33)),dataSamlet(:,finalFeatures(1,34)),dataSamlet(:,finalFeatures(1,35)),dataSamlet(:,finalFeatures(1,36)),dataSamlet(:,finalFeatures(1,37)),dataSamlet(:,finalFeatures(1,38)),dataSamlet(:,finalFeatures(1,39)),dataSamlet(:,finalFeatures(1,40)),dataSamlet(:,finalFeatures(1,41)),dataSamlet(:,finalFeatures(1,42)),dataSamlet(:,finalFeatures(1,43)),dataSamlet(:,finalFeatures(1,44)),dataSamlet(:,finalFeatures(1,45)),dataSamlet(:,finalFeatures(1,46)),dataSamlet(:,finalFeatures(1,47)),dataSamlet(:,finalFeatures(1,48)),dataSamlet(:,finalFeatures(1,49)),dataSamlet(:,finalFeatures(1,50)),dataSamlet(:,size(dataSamlet,2)),'VariableNames',varNames);
% 
% 
