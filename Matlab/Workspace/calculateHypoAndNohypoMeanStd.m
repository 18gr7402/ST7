clc
close all

%% Udregning af mean og standardafvigelse
% load data

% Fjern labels
patient=[nohypodiabetesallmeasurements.patientunitstayid];   %Tilpas til data (med eller uden 'no')
labresult=[nohypodiabetesallmeasurements.labresult];

% Find unikke
[u i j] = unique(patient);
uniquePatient = u;

% Preallocate med 0 matrix for hurtigere beregning
nohypoMeanStd = zeros(size(uniquePatient,1),3);       % Her kan der også lige tilpasses navn (med eller uden 'no')
nohypoMeanStd(:,1)=uniquePatient(:,1);

for i=1:size(uniquePatient,1)
    n=find(uniquePatient(i) == patient);  %Find hvilke der høre til den i-unikke patient
    
    nohypoMeanStd(i,2)= nanmean(labresult(n));  % Tag mean, og ignore NAN values
    nohypoMeanStd(i,3)= nanstd(labresult(n));  % Tag mean, og ignore NAN values
end
