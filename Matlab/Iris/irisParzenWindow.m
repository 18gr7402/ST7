clc
clear
close all

%% Beskrivelse

% Kode til Parzen Window Classifikation 
% Køres på iris data, der først loades.

load ('irisWorkSpace.mat')

% Species lavet til et nummerisk indeks
c = categorical(iris.species(1:end));
iris.species = grp2idx(c);

%% Histrogram for hver enkelt feature

classLabels = unique(iris.species);
classes = length(classLabels);
classIndex = [0,0,0];
for classes=1:length(classes)+1
    classIdx=find(iris.species>classes);
    classIndex(classes)=classIdx(1);
end
figure(1)
subplot(2,2,1)
h1_SL = histogram(iris.sepal_length(1:classIndex(1)-1));
hold on
h2_SL = histogram(iris.sepal_length(classIndex(1):classIndex(2)-1));
hold on 
h3_SL = histogram(iris.sepal_length(classIndex(2):end));
hold on
title('Feature 1: Sepal Length');
legend([h1_SL, h2_SL, h3_SL],{'Setosa','Versicolor','Virginica'});


subplot(2,2,2)
h1_SW = histogram(iris.sepal_width(1:classIndex(1)-1));
hold on
h2_SW = histogram(iris.sepal_width(classIndex(1):classIndex(2)-1));
hold on 
h3_SW = histogram(iris.sepal_width(classIndex(2):end));
hold on
title('Feature 2: Sepal Width');
legend([h1_SW, h2_SW, h3_SW],{'Setosa','Versicolor','Virginica'});

subplot(2,2,3)
h1_PL = histogram(iris.petal_length(1:classIndex(1)-1));
hold on
h2_PL = histogram(iris.petal_length(classIndex(1):classIndex(2)-1));
hold on 
h3_PL = histogram(iris.petal_length(classIndex(2):end));
hold on
title('Feature 3: Petal Length');
legend([h1_PL, h2_PL, h3_PL],{'Setosa','Versicolor','Virginica'});

subplot(2,2,4)
h1_PW = histogram(iris.petal_width(1:classIndex(1)-1));
hold on
h2_PW = histogram(iris.petal_width(classIndex(1):classIndex(2)-1));
hold on 
h3_PW = histogram(iris.petal_width(classIndex(2):end));
hold on
title('Feature 4: Petal Width');
legend([h1_PW, h2_PW, h3_PW],{'Setosa','Versicolor','Virginica'});

%% Histrogram for hver klasse

class1 = [iris.sepal_length(iris.species == 1) iris.sepal_width(iris.species == 1) iris.petal_length(iris.species == 1) iris.petal_width(iris.species == 1)];
class2 = [iris.sepal_length(iris.species == 2) iris.sepal_width(iris.species == 2) iris.petal_length(iris.species == 2) iris.petal_width(iris.species == 2)];
class3 = [iris.sepal_length(iris.species == 3) iris.sepal_width(iris.species == 3) iris.petal_length(iris.species == 3) iris.petal_width(iris.species == 3)];

allDataNoLabel = [class1; class2; class3];

figure(2)
subplot(3,1,1)
h_c1_spec1 = histogram(iris.sepal_length(iris.species == 1),10);
hold on
h_c1_spec2 = histogram(iris.sepal_width(iris.species == 1),10);
hold on 
h_c1_spec3 = histogram(iris.petal_length(iris.species == 1),10);
hold on
h_c1_spec4 = histogram(iris.petal_width(iris.species == 1),10);
legend([h_c1_spec1, h_c1_spec2, h_c1_spec3, h_c1_spec4],{'Sepal Length','Sepal Width','Petal Length','Petal Width'});
title('Class 1: Setosa');

subplot(3,1,2)
h_c2_spec1 = histogram(iris.sepal_length(iris.species == 2),10);
hold on
h_c2_spec2 = histogram(iris.sepal_width(iris.species == 2),10);
hold on 
h_c2_spec3 = histogram(iris.petal_length(iris.species == 2),10);
hold on
h_c2_spec4 = histogram(iris.petal_width(iris.species == 2),10);
legend([h_c2_spec1, h_c2_spec2, h_c2_spec3, h_c2_spec4],{'Sepal Length','Sepal Width','Petal Length','Petal Width'});
title('Class 2: Versicolor');

subplot(3,1,3)
h_c3_spec1 = histogram(iris.sepal_length(iris.species == 3),10);
hold on
h_c3_spec2 = histogram(iris.sepal_width(iris.species == 3),10);
hold on 
h_c3_spec3 = histogram(iris.petal_length(iris.species == 3),10);
hold on
h_c3_spec4 = histogram(iris.petal_width(iris.species == 3),10);
legend([h_c3_spec1, h_c3_spec2, h_c3_spec3, h_c3_spec4],{'Sepal Length','Sepal Width','Petal Length','Petal Width'});
title('Class 3: Verginica');


%% Definér størrelsen på samles (no) og vinduesbredden (width)

no = length(class1);  %Denne defineres til at være længden på én klasse, da det bruges som træningsdata
width = 1/sqrt(no);

%% Udvælg testdata (som her kun er 1 række fra oprindelig data)
testdata = allDataNoLabel(56,:);

%Jeg udregner p(x) for hver klasse, som er vores likelihood for hver klasse i forhold til mit testdata. 
%Når række 56 vælges, bliver prob2 højest, hvilket jeg forventer.
%Når række 1 vælges, bliver prob1 højest, hvilket jeg forventer.

    for j = 1:length(class1)
       prob1=(sum(normal((testdata-class1(j,:))/width)))/no; 
    end   

     for j = 1:length(class2)
       prob2=(sum(normal((testdata-class2(j,:))/width)))/no; 
     end 
    
     for j = 1:length(class3)
       prob3=(sum(normal((testdata-class3(j,:))/width)))/no; 
     end
     
     %Vi kan vælge blot at gå med likelihoods til at klassificere ud fra,
     %men vi kan også vælge at klassificere ud fra posterior probability,
     %som udregnes herunder. (Men det har ingen betydning for
     %klassifikaitonen, blot at det normaliseres, så sandsynligheden
     %summerer op til 1)
     
     %Vi kan udregne posterior probability ved at tage likelihood*prior og
     %dividere det med evidens.
     %Prior er ens, så den går ud
     %evidens er ud fra bayes formel blot likelihoods for hver enkelt
     %klasse summeret sammen.
     %Derfor kan man udregne posterior prob. for hver klasse for den værdi
     %vi vælger at klassificere
     
     postprob_C1 = prob1/(prob1+prob2+prob3);
     postprob_C2 = prob2/(prob1+prob2+prob3);
     postprob_C3 = prob3/(prob1+prob2+prob3);
     
     %Ud fra det kan vi tydeligt se, at det stemmer overens med det vi
     %forventer.
     
     
%% OBS: Jeg tror ikke det er rigtigt, at tage testdata ind, 
% da funktionen fra %kurset i stedet definerer featurevalues, som rykker sig med et inkrement
%på 0.1. Derfor sættes det også ind. Her benyttes funktionen fra kurset. 
%HOV: Det var faktisk rigtig nok det jeg havde gjort. Det vi når frem til
%ved at tage testdata - klassedata vil være nogenlunde den samme likelihood
%som hvis man lavede en sandsynlighedsdistribution for hver eneste feature
%og klasse. Så vil man gå ind og aflæse ud fra værdierne og finde frem til
%det samme. 

n=50;  %Da det er størrelsen på klassen
width = 1; % Det er tilfældigt valgt (I kursusgangen blev der brugt 0,25, 1 og 4.
featVal = (-1:0.1:8); %laver vindue fra x=0 til x=8 der rykkes 0,1 af gangen. Det er valgt ud fra histogramplottene for de enkelte klasser.

%Alt klassedata transponeres for at kunne indgå i funktionen
traclass1 = class1';
traclass2 = class2';
traclass3 = class3';

for winWidthNo=1:length(width)
    for sampAntNo=1:length(n)
        selectDat1 = traclass1(1:n(sampAntNo)); %Vi vil gerne udregne p(x) for hver klasse
        selectDat2 = traclass2(1:n(sampAntNo));
        selectDat3 = traclass3(1:n(sampAntNo));
        for featValNo =1:length(featVal) % Definere antal vinduer, vi beregner udfra.
            % Da parzen funktionen laver et normalfordelt vindue (Gaussisk) bliver vinduet ikke kvadratisk men klokkeformet.
            pdfVal1(featValNo) =  parzen(featVal(featValNo),selectDat1,n(sampAntNo),width(winWidthNo)); %Sandsynlighedsværdien pn(x) for hvert vindue for klasse 1
            pdfVal2(featValNo) =  parzen(featVal(featValNo),selectDat2,n(sampAntNo),width(winWidthNo)); %Sandsynlighedsværdien pn(x) for hvert vindue for klasse 2
            pdfVal3(featValNo) =  parzen(featVal(featValNo),selectDat3,n(sampAntNo),width(winWidthNo)); %Sandsynlighedsværdien pn(x) for hvert vindue for klasse 3
        end        
    end
end

figure(3)
subplot(3,1,1)
plot(pdfVal1)
title('p(x) for klasse 1: Setosa')
xlabel('Feature value')
ylabel('p(x)')

subplot(3,1,2)
plot(pdfVal2)
title('p(x) for klasse 2: Versicolor ')
xlabel('Feature value')
ylabel('p(x)')

subplot(3,1,3)
plot(pdfVal3)
title('Feature value: Virginica')
xlabel('Feature value')
ylabel('p(x)')

%Man kan af figuren se, at fordelingen nogenlunde følger histrogrammet for
%de tre klasser.

%OBS! Dette er klasse likelihoots, men vi har ikke taget højde for de fire
%features. Det vil gå hen og blive 4 dimensionelt. 


