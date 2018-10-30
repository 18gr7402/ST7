clc
close all

%% Opdeling af glukosemålinger på dage
% load data

%% Fjern labels

patientID=[nohypodiabetesglukoseunitAdmitlabOffset.patientunitstayid];
labResult=[nohypodiabetesglukoseunitAdmitlabOffset.labresult];
offset = [nohypodiabetesglukoseunitAdmitlabOffset.labresultoffset];

%% Find unikke rows af patientid med tilhørende tid
[~,idu] = unique(nohypodiabetesglukoseunitAdmitlabOffset(:,1));
uniqueRows = nohypodiabetesglukoseunitAdmitlabOffset(idu,:);

%% Find unikke rows af patient uden labes så det kan bruges til beregning
[u] = unique(patientID);
uniquePatient = u;

%% Løkke til opdeling af målinger for hver unikke patientid
% Preallocate
testDay = zeros(length(labResult),1);

for index=1:length(uniquePatient)
    timeIndex = uniqueRows(index,4);  % Find admit-time for patient 'index' 
    [h,m] = hms(timeIndex.unitadmittime24);  % Omregn til timer og minutter
    tidIMin = 60*h+m;
    tidTilMidnat = 1440-tidIMin;
    
    n=find(uniquePatient(index) == patientID); % Find de samples der tilhøre patient 'index'
            
    % Udregning af hvor mange dage patienten har data for. Der findes offset for den sidste måling (ved max(offset(n))). Dette divideres med 60*24 og rundes op.
    numberOfTestDays = ceil((max(offset(n))-tidTilMidnat)/1440);
    
    % Løkke for opdeling af dag 1 indtil antallet af dag med test. De der hører til dag 0 er allerede 0.
    for i=0:numberOfTestDays-1
    % Der findes de samples hvor patientens offset ligger over tidTilMidnat og under tidTilMadnat+(60*24). For hver iteration ligges i*(60*24) oveni begge for på den måde at skrifte til en ny dag. Dette gemmes hver gang på som dag(i+1).
        testDay(n(find((i*1440+tidTilMidnat) <= offset(n) & (i*1440+tidTilMidnat+1440) > offset(n))))=i+1;
    end
end

% Vi slutter med at samle data.
allGlucoseDataNoHypo = table(patientID,labResult,testDay);
