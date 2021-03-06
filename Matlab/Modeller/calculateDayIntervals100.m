clc
close all

%% Opdeling af alle m�linger p� dage

%load('rand100pidlab');


c = categorical(rand100pidlab.labname(1:end));
rand100pidlab.labCategory = grp2idx(c);


%% Fjern labels

patientID=[rand100pidlab.patientunitstayid];
labResult=[rand100pidlab.labresult];
offset = [rand100pidlab.labresultoffset];

%% Find unikke rows af patientid med tilh�rende unittid
[~,idu] = unique(rand100pidlab(:,1));
uniqueRows = rand100pidlab(idu,:);

%% Find unikke rows af patient uden labes s� det kan bruges til beregning
[u] = unique(patientID);
uniquePatient = u;

%% L�kke til opdeling af m�linger for hver unikke patientid
% Preallocate
testDay = zeros(length(labResult),1);

for index=1:length(uniquePatient)
    timeIndex = uniqueRows(index,5);  % Find admit-time for patient 'index' 
    [h,m] = hms(timeIndex.unitadmittime24);  % Omregn til timer og minutter
    tidIMin = 60*h+m;
    tidTilMidnat = 1440-tidIMin;
    
    n=find(uniquePatient(index) == patientID); % Find de samples der tilh�re patient 'index'
            
    % Udregning af hvor mange dage patienten har data for. Der findes offset for den sidste m�ling (ved max(offset(n))). Dette divideres med 60*24 og rundes op.
    numberOfTestDays = ceil((max(offset(n))-tidTilMidnat)/1440);
    
    % L�kke for opdeling af dag 1 indtil antallet af dag med test. De der h�rer til dag 0 er allerede 0.
    for i=0:numberOfTestDays-1
    % Der findes de samples hvor patientens offset ligger over tidTilMidnat og under tidTilMadnat+(60*24). For hver iteration ligges i*(60*24) oveni begge for p� den m�de at skrifte til en ny dag. Dette gemmes hver gang p� som dag(i+1).
        testDay(n(find((i*1440+tidTilMidnat) <= offset(n) & (i*1440+tidTilMidnat+1440) > offset(n))))=i+1;
    end
end

% Vi slutter med at samle data.
rand100pidlab.testDay = testDay;
