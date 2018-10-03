%OBS: Dette kode tager 90% udgangspunkt i Alex' besvarelse fra PR 
%kursusgang 3. Har �ndret til vores iris data og v�rdier for n og
%width der passer til det samt udvalgt en feature af de fire tilg�ngelilge

clc
clear all
close all

load('irisData.mat');

iris1 = [iris.sepal_length]; %v�lger en feature, sepal l�ngde 
%(n�ste skridt udover klassifier er nok at f� alle fire med
traIris1 = iris1'; 


%Histogram over data fordelt p� en feature. Data er ikke opdelt i
%klasser.
figure(1)
hist(iris1,20)
title('Histogram over feature 1 data fordelt p� de tre klasser')
xlabel('Sepal length [cm]')
ylabel('Count')
legend('Sepal length')

nr=[30 60 90 120 150]; %antal samples vi bruger
width=[0.25 1 4]; %bredden p� vinduet

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

%Ser p� figur hvad der passer bedst ved at sammenligne fig 1 (histogram) 
%med de enkelte grafer p� fig 2. Kan ogs� pr�ve med andre vinduest�rrelser.
%G�res bare ved at �ndre width


%I nedenst�ende bruges funktionen ksdensity til at estimere p(x) 
%with a box and triangle 

[pdfFunc,xc1] = ksdensity(traIris1,featVal,'Kernel','triangle'); % triangle, box
figure
plot(featVal,pdfFunc);hold on  

%Ovenst�ende er bare gjort fordi vi skulle g�re det til kursusgang 3.
%Ved ikke om vi skal g�re det i projekt. M�ske vi ogs� kan kigge p�
%at bruge en gaussisk enhedsvarians som vindue.

%Tinas forslag til n�ste skridt i dette kode:
    %Evt gaussisk enhedsvarians
    %Pr�ve med andre vindue width
    %Bruge det til klassificering (alle n kan ikke bruges til at lave modellen s�)
    %F� alle fire features med
%Derudover er der ogs� hele delen med at f� "vores egen kode" til at virke
%jf. det der ligger i git 'irisParzenWindow'. 