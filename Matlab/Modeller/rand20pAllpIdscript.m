%Dette script er til for at se hvordan vi har f�et 20% random patienter ud
%Der er i SQL kaldet forinden taget h�jde for at de 500 og 5000 random
%patient id'er ikke indg�r. 

%M� IKKE k�res og gemmes som en ny CSV-fil

%pidnot500and5000 er fra matlab -> CSV filer -> HelePatientgruppen(20%og80%)
data = sort(table2array(pidnot500and5000));

%Her hives 20% = 10.834 tilf�ldige patient id'er ud

rand20pTest= randsample(data,10834);  

%Lav til csv-fil
dlmwrite('20pTest.csv',rand20pTest,'precision',7)