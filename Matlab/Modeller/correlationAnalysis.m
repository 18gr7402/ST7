clear 
clc
close all

%% Load data

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

thresholdForExcludingNAN = 300;

dataSamletAfterNANExclusion = [dataSamlet(:,find(dataNAN <=thresholdForExcludingNAN)),dataSamlet(:,length(unique(dataTrim.Category))+1)];
categoryOverviewAfterNANExclusion = categoryOverview(find(dataNAN <=thresholdForExcludingNAN),:);

%% Korrelationsanalyse

for i=1:length(unique(categoryOverviewAfterNANExclusion.Category))
    %% Inddeling af data
    ind = ~isnan(dataSamletAfterNANExclusion(:,i));
    dataForAnalysis(1+((i-1)*(length(dataSamletAfterNANExclusion))):length(dataSamletAfterNANExclusion)+((i-1)*(length(dataSamletAfterNANExclusion))),1) = dataSamletAfterNANExclusion(:,i);
    dataForAnalysis(1+((i-1)*(length(dataSamletAfterNANExclusion))):length(dataSamletAfterNANExclusion)+((i-1)*(length(dataSamletAfterNANExclusion))),2) = categoryOverviewAfterNANExclusion.Name(i);
    
    dataSamletAfterNANExclusionNoNAN = dataSamletAfterNANExclusion(ind,i);
    dataTemp1 = dataSamletAfterNANExclusionNoNAN(logical(dataSamletAfterNANExclusion(ind,size(dataSamletAfterNANExclusion,2))));
    dataTemp0 = dataSamletAfterNANExclusionNoNAN(logical(~dataSamletAfterNANExclusion(ind,size(dataSamletAfterNANExclusion,2))));
    
    %% Analyser
    %The Levene, Brown-Forsythe, and O’Brien tests are less sensitive to departures from normality than Bartlett’s test, so they are useful alternatives if you suspect the samples come from nonnormal distributions.
    [p] = vartestn(dataSamletAfterNANExclusion(ind,i),dataSamletAfterNANExclusion(ind,size(dataSamletAfterNANExclusion,2)),'TestType','LeveneAbsolute','Display','off');
    pValues(i,1) = p;
    
    %Test for correlation
    correlation(i,1) = abs(corr2(dataSamletAfterNANExclusionNoNAN,dataSamletAfterNANExclusion(ind,size(dataSamletAfterNANExclusion,2))));
        
    %Test for normal distribution: h = kstest(x) returns a test decision for the null hypothesis that the data in vector x comes from a standard normal distribution, against the alternative that it does not come from such a distribution, using the one-sample Kolmogorov-Smirnov test. The result h is 1 if the test rejects the null hypothesis at the 5% significance level, or 0 otherwise.
    isGaussianDistribution(i,1) = jbtest(dataTemp1,0.001);
    isGaussianDistribution(i,2) = jbtest(dataTemp0,0.001);
    isGaussianDistributionNoOutliers(i,1) = jbtest(dataTemp1(~isoutlier(dataTemp1,'mean'),1),0.001);
    isGaussianDistributionNoOutliers(i,2) = jbtest(dataTemp0(~isoutlier(dataTemp0,'mean'),1),0.001);
%     figure
%     normplot(dataTemp1);
%     figure
%     normplot(dataTemp0);
    %Test for outliers så det kan sammenholdes med total antal: TF = isoutlier(A) returns a logical array whose elements are true when an outlier is detected in the corresponding element of A. By default, an outlier is a value that is more than three scaled median absolute deviations (MAD) away from the median. If A is a matrix or table, then isoutlier operates on each column separately. If A is a multidimensional array, then isoutlier operates along the first dimension whose size does not equal 1.
    isOutlier(i,1) = sum(isoutlier(dataTemp1,'mean'));
    isOutlier(i,2) = length(dataTemp1);
    isOutlier(i,3) = sum(isoutlier(dataTemp0,'mean'));
    isOutlier(i,4) = length(dataTemp0);
end
% Test for equal variance: vartestn(x) returns a summary table of statistics and a box plot for a Bartlett test of the null hypothesis that the columns of data vector x come from normal distributions with the same variance. The alternative hypothesis is that not all columns of data have the same variance.
% A low -value, p = 0, indicates that vartestn rejects the null hypothesis that the variances are equal across all five columns, in favor of the alternative hypothesis that at least one column has a different variance.
% vartestn(dataForAnalysis(:,1),dataForAnalysis(:,2),'TestType','LeveneAbsolute');

%% Plot figurer
figure
bar(categoryOverviewAfterNANExclusion.Name,pValues)
title('P-values of the Leneve absolute test for equal variance between hypo og nohypo group');
xlabel('Feature');
ylabel('Correlation coefficient');

figure
bar(categoryOverviewAfterNANExclusion.Name,correlation)
title('Overview of correlation between feature and class label');
xlabel('Feature');
ylabel('Correlation coefficient');

%% Vælg de endelige features og gør data klar til at eksportere

numberOfChosenFeatures = 10;
% 
 correlationCategoryOverview = [categoryOverviewAfterNANExclusion, table(correlation)];
 
 [~,idx] = sort(correlationCategoryOverview.correlation,'descend');
 correlationCategoryFinal = correlationCategoryOverview(idx,:);
 correlationCategoryFinal = correlationCategoryFinal(1:numberOfChosenFeatures,:);
% 
varNames = cellstr(string(correlationCategoryFinal.LabName));
% varName = {'hej'};
% T = table('VariableNames',varName);
% T = table(dataSamlet(:,correlationCategoryFinal.LabCategory(1)));
% for i=1:numberOfChosenFeatures-1
%    varName = {cellstr(string(correlationCategoryFinal.LabName(i+1)))};
%    T = [T table(dataSamlet(:,correlationCategoryFinal.LabCategory(i+1)),'VariableNames',varName)];
% end
% 
% % hej = table(dataSamlet(:,correlationCategoryFinal.LabCategory));
% % %varNames = {cellstr(string(correlationCategoryFinal.LabName(i+1)))};
% % %,'VariableNames',varNames
% % dataFinal = [table(dataSamlet(:,correlationCategoryFinal.LabCategory)),table(dataSamletNANToZero)];

T = array2table(dataSamlet(:,correlationCategoryFinal.LabCategory),'VariableNames',varNames);