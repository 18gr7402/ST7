
%Dette script er til for at se hvordan vi har f�et 100 random patienter ud
%M� ikke k�res og gemme en ny CSV-fil

%dmwithglucose er fra matlab -> CSV filer -> patientgruppe
data = sort(table2array(dmwithglucose));

%Her hives 100 tilf�ldige ud

rand100pID = randsample(data,100);  

%csvwrite('rand100pID.csv',rand100pID) %Virker ikke
dlmwrite('rand100pID.csv',rand100pID,'precision',7)