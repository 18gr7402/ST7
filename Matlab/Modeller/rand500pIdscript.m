
%Dette script er til for at se hvordan vi har fået 500 random patienter ud
%Må IKKE køres og gemmes som en ny CSV-fil

%dmnypid54000 er fra matlab -> CSV filer -> patientgruppe
data = sort(table2array(dmnypid54000));

%Her hives 500 tilfældige ud

rand500pID = randsample(data,500);  

%Lav til csv-fil
dlmwrite('rand500pID.csv',rand500pID,'precision',7)
