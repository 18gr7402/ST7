
%Dette script er til for at se hvordan vi har f�et 100 random patienter ud
%M� ikke k�res og gemme en ny CSV-fil

%dmwithglucose er fra matlab -> CSV filer -> patientgruppe
data = sort(table2array(dmwithglucose));

%Her hives 100 tilf�ldige ud

rand100pID = randsample(data,100);  

%csvwrite('rand100pID.csv',rand100pID) %Virker ikke
dlmwrite('rand100pID.csv',rand100pID,'precision',7)

%Nedenfor er scrip til at udtr�kke 200 patienter ud af alle dm

%dm er fra matlab -> CSV filer -> patientgruppe

data200 = sort(table2array(dm));

%Her hives 200 tilf�ldige ud

rand200pID = randsample(data200,200); 

%Lav til csv-fil
dlmwrite('rand200pID.csv',rand200pID,'precision',7)
