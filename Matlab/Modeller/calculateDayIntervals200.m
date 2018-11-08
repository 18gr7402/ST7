clc
close all

%% Hent data, ekskluder patienter, label data og opdeling data p� dage pr. patient

%% Load data og �ndre labName til en categorical, s�ledes matlab kobler et navn med en nummerisk v�rdi

%load('rand200pidlab');


c = categorical(rand200pidlab.labname(1:end));
rand200pidlab.labCategory = grp2idx(c);


%% Fjern labels

patientID=[rand200pidlab.patientunitstayid];
labCategory=[rand200pidlab.labCategory];
labResult=[rand200pidlab.labresult];
offset = [rand200pidlab.labresultoffset];

data = [patientID, labCategory, labResult, offset];

%% Her fjernes alle r�kker med negative labresultoffset og output gemmes i en ny tabel
for i = 1:size(data, 1)
    ind(i) = all(data(i,:) >= 0);
end

dataUNeg = data(ind, :);

% Nu findes antal af patienter tilbage efter fjernelse af r�kker med
% negative offset
[~,idu] = unique(dataUNeg(:,1));
uniquePidUNeg = dataUNeg(idu,1);

numUniPidUNeg = length(uniquePidUNeg);

%% Find patienterne med en eller flere glucosem�ling(er) - glucose = category 79 og bedside glucose = category 69
for i = 1:size(dataUNeg, 1)
    idx(i) = all(dataUNeg(i,2) == 69 | all(dataUNeg(i,2) == 79));
end

dataUNegOnlyGlu = dataUNeg(idx, :);

% Nu findes antal patienter tilbage efter fjernelse af patienter uden
% glucose m�linger
[~,idu] = unique(dataUNegOnlyGlu(:,1));
uniquePid = dataUNegOnlyGlu(idu,1);

numUniPid = length(uniquePid);

%% Lav en tabel med alle datar�kker for hver patient - join uniquePid med dataUNeg
equalPid = dataUNeg(ismember(dataUNeg,uniquePid),:); %alle r�kke med de inkluderede patienter er fundet (patienter med glucose m�linger og ingen negative lab offset)


%% VI ER KOMMET HERTIL OG VI VED KUN AT DE OVENST�ENDE SECTIONS KAN K�RES, VI LOVER IKKE NEDENST�ENDE SECTIONS K�RER, DA VI IKKE HAR R�RT VED DEM!



%% Find unikke rows af patientid med tilh�rende unittid
[~,idu] = unique(rand200pidlab(:,1));
uniqueRows = rand200pidlab(idu,:);

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
