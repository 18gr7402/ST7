%OBS: Dette kode tager 90% udgangspunkt i Alex' besvarelse fra PR 
%kursusgang 3. Har ændret til vores iris data og værdier for n og
%width der passer til det samt udvalgt en feature af de fire tilgængelige

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
axis([4 8 0 18])
legend('Sepal length')

nr=[30 60 90 120 150]; %antal samples vi bruger
width=[0.25 1 4]; % width svarer til h1, som er en udglatningsparameter, der anvendes til at beregne hn i funktionen Parzen.m

figure(2)
n=1;
featVal = (4:0.1:10); %laver vindue fra x=4 til x=10 der rykkes 0,1 af gangen
for winWidthNo=1:length(width)
    for sampAntNo=1:length(nr)
        selectDat = traIris1(1:nr(sampAntNo));        
        for featValNo =1:length(featVal) % Definere antal vindue vi beregner udfra. Der er ialt 101 vinduer.
            % Da parzen funktionen laver et normalfordelt vindue (Gaussisk) bliver vinduet ikke kvadratisk men klokkeformet.
            pdfVal(featValNo) =  parzen(featVal(featValNo),selectDat,nr(sampAntNo),width(winWidthNo)); %Sandsynlighedsværdien pn(x) for hvert af de 101 vinduer
        end        
%         w = pdfVal';
        subplot(3,5,n)
        plot(featVal,pdfVal)
        axis tight
        title(['h1 = ',num2str(width(winWidthNo)),' n = ',num2str(nr(sampAntNo))])
        n=n+1;
    end
end
xlabel('Feature value')
ylabel('p(x)')

%Ser på figur hvad der passer bedst ved at sammenligne fig 1 (histogram) 
%med de enkelte grafer på fig 2. Kan også prøve med andre vinduestørrelser.
%Gøres bare ved at ændre width

%Forslag til næste skridt i dette kode:
    %Bruge det til klassificering (alle n kan ikke bruges til at lave modellen opdel i træningsdata og testdata)
    %Få alle fire features med

