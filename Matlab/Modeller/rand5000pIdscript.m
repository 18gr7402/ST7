
%Dette script er til for at se hvordan vi har f�et 5000 random patienter ud
%M� IKKE k�res og gemmes som en ny CSV-fil

%dmnypid54000 er fra matlab -> CSV filer -> patientgruppe
data = sort(table2array(dmnypid54000));

%Her hives 5000 tilf�ldige ud

rand5000pID = randsample(data,5000);  

%Lav til csv-fil
dlmwrite('rand5000pID.csv',rand5000pID,'precision',7)
