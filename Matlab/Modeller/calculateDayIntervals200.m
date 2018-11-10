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
% string(rand200pidlab.labname)
data = [patientID,labCategory, labResult, offset];

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
[~,idu] = unique(equalPid(:,1));
uniqueRows = equalPid(idu,:);

%% Find unikke rows af patient uden labes s� det kan bruges til beregning
[u] = unique(equalPid(:,1));
uniquePatient = u;

%% L�kke til opdeling af m�linger for hver unikke patientid
% Preallocate
testDay = zeros(length(equalPid(:,3)),1);

for index=1:length(uniquePatient)
    timeIndex = rand200pidlab.unitadmittime24(index);  % Find admit-time for patient 'index' 
    [h,m] = hms(timeIndex);  % Omregn til timer og minutter
    tidIMin = 60*h+m;
    tidTilMidnat = 1440-tidIMin;
    
    n=find(uniquePatient(index) == equalPid(:,1)); % Find de samples der tilh�re patient 'index'
            
    % Udregning af hvor mange dage patienten har data for. Der findes offset for den sidste m�ling (ved max(offset(n))). Dette divideres med 60*24 og rundes op.
    numberOfTestDays = ceil((max(equalPid(n,4))-tidTilMidnat)/1440);
    
    % L�kke for opdeling af dag 1 indtil antallet af dag med test. De der h�rer til dag 0 er allerede 0.
    for i=0:numberOfTestDays-1
    % Der findes de samples hvor patientens offset ligger over tidTilMidnat og under tidTilMadnat+(60*24). For hver iteration ligges i*(60*24) oveni begge for p� den m�de at skrifte til en ny dag. Dette gemmes hver gang p� som dag(i+1).
        testDay(n(find((i*1440+tidTilMidnat) <= equalPid(n,4) & (i*1440+tidTilMidnat+1440) > equalPid(n,4))))=i+1;
    end
end

% Vi slutter med at samle data.
equalPid = [equalPid testDay];

%% Label data

glucoseMeasurements = find(equalPid(:,2) == 69 | equalPid(:,2) == 79);
glucoseMeasurementsUnder70 = equalPid(glucoseMeasurements,3)<=70;
locationOfglucoseMeasurementsUnder70 = glucoseMeasurements(glucoseMeasurementsUnder70);

%Preallocate
label = zeros(length(equalPid),1);
label(locationOfglucoseMeasurementsUnder70)=1;

%Save
equalPid = [equalPid label];

%% Ops�tning af data

%PatientID og hvilken dag der er oplevet hypo
hypoPatientDayInfo = [equalPid(locationOfglucoseMeasurementsUnder70,1) equalPid(locationOfglucoseMeasurementsUnder70,5)];

%Preallocate
numberOfDaysIncluded = 5;
dataOversigt = zeros(length(uniquePatient),(1+length(unique(equalPid(:,2)))*numberOfDaysIncluded));

for i=1:length(uniquePatient)
    % Find info for hver person
    patientId = uniquePatient(i);
    infoLocation = find(equalPid(:,1)==patientId);
    patientInfo = equalPid(infoLocation,:);
    
    %Gemt patientId
    dataOversigt(i,1) = patientId;
    
    % Save label
    labelDataLocation = find(hypoPatientDayInfo==patientId);
    hypoDays = hypoPatientDayInfo(labelDataLocation,2);
    
    for day=1:numberOfDaysIncluded
        % Check om hypo i morgen
        isHypoTomorrow = ~isempty(find(hypoDays == day+1));
        % Gem label
        dataOversigt(i,1+((1+length(unique(equalPid(:,2))))*day))=isHypoTomorrow;
        for index=1:length(unique(equalPid(:,2)));
            categoryDataLocation = find(patientInfo(:,2)==index);
            dataOversigt(i,index+1+((day-1)*(length(unique(equalPid(:,2)))+1)))=mean(equalPid(categoryDataLocation,3));
        end
    end
end

%% Samling af data til korrelation og klassifikation

for day=1:numberOfDaysIncluded
dataSamlet(1+(day-1)*size(dataOversigt,1):(day)*size(dataOversigt,1),:) = dataOversigt(1:size(dataOversigt,1), 2+(day-1)*(length(unique(equalPid(:,2)))+1):length(unique(equalPid(:,2)))+2+(day-1)*(length(unique(equalPid(:,2)))+1));
end

%% Antal af NAN plot

for category=1:length(unique(equalPid(:,2)))
    dataNAN(1,category) = sum(isnan(dataSamlet(:,category)));
end

height(unique(categoryOverview(:,2)))

figure
bar(dataNAN)

%% Korrelationsanalyse
dataSamlet(isnan(dataSamlet))=0;

for i=1:length(unique(equalPid(:,2)))
correlation(1,i) = corr2(dataSamlet(:,i),dataSamlet(:,126));
end

figure
bar(abs(correlation))

