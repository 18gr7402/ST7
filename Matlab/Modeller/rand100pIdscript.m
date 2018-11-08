
%Dette script er til for at se hvordan vi har fået 100 random patienter ud
%Må ikke køres og gemme en ny CSV-fil

%dmwithglucose er fra matlab -> CSV filer -> patientgruppe
data = sort(table2array(dmwithglucose));

%Her hives 100 tilfældige ud

rand100pID = randsample(data,100);  

%csvwrite('rand100pID.csv',rand100pID) %Virker ikke
dlmwrite('rand100pID.csv',rand100pID,'precision',7)