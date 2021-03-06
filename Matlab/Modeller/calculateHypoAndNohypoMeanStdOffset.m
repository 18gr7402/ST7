clc
close all

%% Udregning af mean og standardafvigelse
% load data

% Fjern labels
patient=[nohypodiabetesAllMeasurementspluslabresultoffset.patientunitstayid];   %Tilpas til data (med eller uden 'no')
labresult=[nohypodiabetesAllMeasurementspluslabresultoffset.labresult];
offset = [nohypodiabetesAllMeasurementspluslabresultoffset.labresultoffset];

% Find unikke
[u i j] = unique(patient);
uniquePatient = u;

% Preallocate med 0 matrix for hurtigere beregning
hypoMeanStd = zeros(size(uniquePatient,1),3);       % Her kan der ogs� lige tilpasses navn (med eller uden 'no')
hypoMeanStd(:,1)=uniquePatient(:,1);

intervalMin = 600;
index = 1;

for i=1:size(uniquePatient,1)
    n=find(uniquePatient(i) == patient);  %Find hvilke der h�re til den i-unikke patient
    
    labUnder70 = find(labresult(n)<70);
    
    for j=1:length(labUnder70)
    offsetLabUnder70 = offset(labUnder70(j,1));
    
    offsetLowValue = offsetLabUnder70 - intervalMin;
    resultInInterval = find(offsetLowValue <= offset(n) & offsetLabUnder70 > offset(n)); 
    
    hypoMeanStd(index,2)= nanmean(labresult(resultInInterval));  % Tag mean, og ignore NAN values
    hypoMeanStd(index,3)= nanstd(labresult(resultInInterval));  % Tag mean, og ignore NAN values
    
    index = index+1;
    end
end

realValues = ~isnan(hypoMeanStd);
antalLabResults = length(find(realValues(:,2)~=0));

nohypoMeanStdUdenNAN = hypoMeanStd(find(realValues(:,2)~=0),2:3);

