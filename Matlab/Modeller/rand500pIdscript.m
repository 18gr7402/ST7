
%Dette script er til for at se hvordan vi har f�et 500 random patienter ud
%M� IKKE k�res og gemmes som en ny CSV-fil

%dmnypid54000 er fra matlab -> CSV filer -> patientgruppe
data = sort(table2array(dmnypid54000));

%Her hives 500 tilf�ldige ud

rand500pID = randsample(data,500);  

%Lav til csv-fil
dlmwrite('rand500pID.csv',rand500pID,'precision',7)
