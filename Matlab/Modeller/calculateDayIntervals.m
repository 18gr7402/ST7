clc
close all


%% Opdeling af glukosemålinger på dage
% load data

%% Fjern labesl

patient=[hypodiabetesglukoseunitAdmitlabOffset.patientunitstayid];   %Tilpas til data (med eller uden 'no')
labresult=[hypodiabetesglukoseunitAdmitlabOffset.labresult];
offset = [hypodiabetesglukoseunitAdmitlabOffset.labresultoffset];
%unitAdmitTime = [hypodiabetesglukoseunitAdmitlabOffset.unitadmittime24];

[~,idu] = unique(hypodiabetesglukoseunitAdmitlabOffset(:,1));
uniqueRows = hypodiabetesglukoseunitAdmitlabOffset(idu,:);

%% Fjern patienter der kun har målinger for 1 døgn


%% Find unikke
[u] = unique(patient);
uniquePatient = u;

for index=1:length(uniquePatient)
    timeIndex = uniqueRows(index,4);
    [h,m] = hms(timeIndex.unitadmittime24);
    tidIMin = 60*h+m;
    tidTilMidnat = 1440-tidIMin;
    
    n=find(uniquePatient(index) == patient);
    labTest(index).PatientID = uniquePatient(index);
    labTest(index).( ['Day',num2str(1)]).('var') = labresult(n(find(offset(n)<tidTilMidnat)));

    numberOfTestDays = ceil((max(offset(n))-tidTilMidnat)/1440);
    
    for i=0:numberOfTestDays-1
        labTest(index).( ['Day',num2str(i+2)]).('var') = labresult(n(find((i*1440+tidTilMidnat) <= offset(n) & (i*1440+tidTilMidnat+1440) > offset(n))));
    end
    
    index = index + 1;
end
