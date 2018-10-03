%OBS: Dette kode tager 90% udgangspunkt i Alex' besvarelse fra PR 
%kursusgang 3. Har ændret til vores iris data og værdier for n og
%width der passer til det samt udvalgt en feature af de fire tilgængelilge

clc
clear all
close all

load('irisData.mat');

iris1 = [iris.sepal_length]; %vælger en feature, sepal længde 
%(næste skridt udover klassifier er nok at få alle fire med
traIris1 = iris1'; 


%Histogram over data fordelt på en feature. Data er ikke opdelt i
%klasser.
figure(1)
hist(iris1,20)
title('Histogram over feature 1 data fordelt på de tre klasser')
xlabel('Sepal length [cm]')
ylabel('Count')
legend('Sepal length')

nr=[30 60 90 120 150]; %antal samples vi bruger
width=[0.25 1 4]; %bredden på vinduet

figure(2)

n=1;
featVal = (2:0.1:12); %laver vindue fra x=2 til x=12 der rykkes 0,1 af gangen
for winWidthNo=1:length(width)
    for sampAntNo=1:length(nr)
        selectDat = traIris1(1:nr(sampAntNo));        
        for featValNo =1:length(featVal)
            pdfVal(featValNo) =  parzen(featVal(featValNo),selectDat,nr(sampAntNo),width(winWidthNo));
        end        
%         w = pdfVal';
        subplot(3,5,n)
        plot(featVal,pdfVal)
        axis tight
        title(['h = ',num2str(width(winWidthNo)),' n = ',num2str(nr(sampAntNo))])
        n=n+1;
    end
end
xlabel('Feature value')
ylabel('p(x)')

%Ser på figur hvad der passer bedst ved at sammenligne fig 1 (histogram) 
%med de enkelte grafer på fig 2. Kan også prøve med andre vinduestørrelser.
%Gøres bare ved at ændre width


%I nedenstående bruges funktionen ksdensity til at estimere p(x) 
%with a box and triangle 

[pdfFunc,xc1] = ksdensity(traIris1,featVal,'Kernel','triangle'); % triangle, box
figure
plot(featVal,pdfFunc);hold on  

%Ovenstående er bare gjort fordi vi skulle gøre det til kursusgang 3.
%Ved ikke om vi skal gøre det i projekt. Måske vi også kan kigge på
%at bruge en gaussisk enhedsvarians som vindue.

%Tinas forslag til næste skridt i dette kode:
    %Evt gaussisk enhedsvarians
    %Prøve med andre vindue width
    %Bruge det til klassificering (alle n kan ikke bruges til at lave modellen så)
    %Få alle fire features med
%Derudover er der også hele delen med at få "vores egen kode" til at virke
%jf. det der ligger i git 'irisParzenWindow'. 