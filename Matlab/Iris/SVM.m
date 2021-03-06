clc
clear
close all

%% Forberedelse af data
load ('irisWorkspace.mat');
c = categorical(iris.species(1:end));
iris.species = grp2idx(c);
classLabels = unique(iris.species);
classes = length(classLabels);

%% Separate to training and test data

%load('splitIndex');
cv = cvpartition(size(iris,1),'HoldOut',0.2);
splitIndex = cv.test;
dataTest  = iris(splitIndex,:);
dataTrain = iris(~splitIndex,:);

dataTrainNoLable = [dataTrain.sepal_length,dataTrain.sepal_width,dataTrain.petal_length,dataTrain.petal_width];
dataTestNoLable = [dataTest.sepal_length,dataTest.sepal_width,dataTest.petal_length,dataTest.petal_width];

 %% inddeling af klasserne

 originalklasse1 = [iris.sepal_length(iris.species==1),iris.sepal_width(iris.species==1),iris.petal_length(iris.species==1),iris.petal_width(iris.species==1)];
 klasse1=originalklasse1(1:30,:);
 tranklasse1=originalklasse1(31:50,:);
 
 originalklasse2 = [iris.sepal_length(iris.species==2),iris.sepal_width(iris.species==2),iris.petal_length(iris.species==2),iris.petal_width(iris.species==2)];
 klasse2=originalklasse2(1:30,:);
 tranklasse2=originalklasse2(31:50,:);
 
 originalklasse3 = [iris.sepal_length(iris.species==3),iris.sepal_width(iris.species==3),iris.petal_length(iris.species==3),iris.petal_width(iris.species==3)];
 klasse3=originalklasse3(1:30,:);
 tranklasse3=originalklasse3(31:50,:);
 % her skal forl�kken starte
 
 %% forberedelse af one vs. rest metode
 w0=ones(length(klasse1),1); % her laves der en matrix best�ende af 1'ere, som har samme l�ngde som klasse 1 (alts� 50), 
 %1-tallet i slutningen g�r, at vi f�r det som en s�jlevektor med �n s�jle,i stedet for en 50x50 matrice med 1'ere.
 k1=[w0 klasse1]'; % vi opretter en variabel med klasse 1, hvor vi l�gger w0 oveni s�ledes vi starter med en arbitr�r v�rdi
 k2=[w0 klasse2]';
 k3=[w0 klasse3]';
 
 k12=[w0 klasse1 ; w0 klasse2]'; 
 k13=[w0 klasse1 ; w0 klasse3]';
 k23=[w0 klasse2 ; w0 klasse3]';
 
 %% normalisering af "resten" fra one vs. rest metoden
 
 k12_norm=-k12;
 k13_norm=-k13;
 k23_norm=-k23;
 
 y1=[k1 k23_norm];
 y2=[k2 k13_norm];
 y3=[k3 k12_norm];
 
 %% perceptron
 margin=0; % vi starter med en margin p� 0
 learningRate=0.05; % learningRate er hvor mange/hurtigt vi g�r frem ad gangen, n�r vi skal finde den optimale placering af hyperplanet
 
 init_weight=ones(size(k1,1),1); % vores initierende v�gtvektor, som opdateres l�bende. Denne bliver resultatet til det optimalt placerede hyperplan
 weight=init_weight; % s�rger for den initierende v�gt opdateres
 count=1;

 %%% Klasse 1
 while(1)
    g=weight'*y1; % diskriminant funktionen, dvs. afstanden til decision boundary for klasse 1
    [Y,I]=find(g<=margin); % vi er kun interesseret i I her. Det I returnerer er de placeringer hvor diskriminant funktionen (g) er st�rre eller lig med margin (som vi har sat til 0).
    
%% % gradient of perceptron criteria function
    
    critFunc=sum(-(weight'*y1(:,I)),2); % y(:,I) --> alle dem fra y der ligger p� en fejlklassificeret palds i I %2-tallet er kun til for at g�re koden universel, fordi vi gerne ellers ville have den p� en s�jleform
    y_sum=sum(y1(:,I),2);
    weight=weight+(learningRate*y_sum);% gradient of perceptron criteria function

%% gem parametre
    
    ittYsum1(:,count)=y_sum;
    ittWeight1(:,count)=weight;
    antMisClass1(1,count)=length(I);
    critFunc1(:,count)=critFunc;
    
    count=count+1;
    
        if (isempty(I))
        ittYsum1(:,count)=y_sum;
        ittWeight1(:,count)=weight;
        antMisClass1(1,count)=length(I);
        critFunc1(:,count)=critFunc;
        count=count+1;
        weight1=weight;
        g1=g;
        break;
        end
 end
 
   %% plot klasse 1
figure(1);
subplot(331);plot(ittWeight1(:,1:count-1)');title('Parameter weights - class 1')
subplot(332);plot(antMisClass1(:,1:count-1)');title('Number of misclassifications - class 1')
subplot(333);plot(critFunc1(:,1:count-2)');title('Value of criterion function - class 1')

%% Klasse 2
 
 margin2=100; % vi starter med en margin p� 0
 learningRate2=0.001; % learningRate er hvor mange/hurtigt vi g�r frem ad gangen, n�r vi skal finde den optimale placering af hyperplanet
 
 init_weight=ones(size(k2,1),1); % vores initierende v�gtvektor, som opdateres l�bende. Denne bliver resultatet til det optimalt placerede hyperplan
 weight=init_weight; % s�rger for den initierende v�gt opdateres
 count=1;


 while(1)
    g=weight'*y2; % diskriminant funktionen, dvs. afstanden til decision boundary for klasse 1
    [Y,I]=find(g<=margin2); % vi er kun interesseret i I her. Det I returnerer er de placeringer hvor diskriminant funktionen (g) er st�rre eller lig med margin (som vi har sat til 0).
    
%% % gradient of perceptron criteria function
    
    critFunc=sum(-(weight'*y2(:,I)),2); % y(:,I) --> alle dem fra y der ligger p� en fejlklassificeret palds i I %2-tallet er kun til for at g�re koden universel, fordi vi gerne ellers ville have den p� en s�jleform
    y_sum=sum(y2(:,I),2);
    weight=weight+(learningRate2*y_sum);% gradient of perceptron criteria function

%% gem parametre
    
    ittYsum2(:,count)=y_sum;
    ittWeight2(:,count)=weight;
    antMisClass2(1,count)=length(I);
    critFunc2(:,count)=critFunc;
    
    count=count+1;
    
        if (isempty(I))
        ittYsum2(:,count)=y_sum;
        ittWeight2(:,count)=weight;
        antMisClass2(1,count)=length(I);
        critFunc2(:,count)=critFunc;
        count=count+1;
        weight2=weight
        g2=g;
        break;
        end
        
        if count==1000
        break;
        end
   
 end
 
%% plot klasse 2
figure(1)
subplot(334);plot(ittWeight2(:,1:count-1)');title('Parameter weights - class 2')
subplot(335);plot(antMisClass2(:,1:count-1)');title('Number of misclassifications - class 2')
subplot(336);plot(critFunc2(:,1:count-2)');title('Value of criterion function - class 2')

%% Klasse 3
 
 margin3=100; % vi starter med en margin p� 0
 learningRate3=0.01; % learningRate er hvor mange/hurtigt vi g�r frem ad gangen, n�r vi skal finde den optimale placering af hyperplanet
 
 init_weight=ones(size(k3,1),1); % vores initierende v�gtvektor, som opdateres l�bende. Denne bliver resultatet til det optimalt placerede hyperplan
 weight=init_weight; % s�rger for den initierende v�gt opdateres
 count=1;


 while(1)
    g=weight'*y3; % diskriminant funktionen, dvs. afstanden til decision boundary for klasse 1
    [Y,I]=find(g<=margin3); % vi er kun interesseret i I her. Det I returnerer er de placeringer hvor diskriminant funktionen (g) er st�rre eller lig med margin (som vi har sat til 0).
    
%% % gradient of perceptron criteria function
    
    critFunc=sum(-(weight'*y3(:,I)),2); % y(:,I) --> alle dem fra y der ligger p� en fejlklassificeret palds i I %2-tallet er kun til for at g�re koden universel, fordi vi gerne ellers ville have den p� en s�jleform
    y_sum=sum(y3(:,I),2);
    weight=weight+(learningRate3*y_sum);% gradient of perceptron criteria function

%% gem parametre
    
    ittYsum3(:,count)=y_sum;
    ittWeight3(:,count)=weight;
    antMisClass3(1,count)=length(I);
    critFunc3(:,count)=critFunc;
    
    count=count+1;
    
        if (isempty(I))
        ittYsum3(:,count)=y_sum;
        ittWeight3(:,count)=weight;
        antMisClass3(1,count)=length(I);
        critFunc3(:,count)=critFunc;
        count=count+1;
        weight3=weight
        g3=g;
        break;
        end
        
        if count==1000
        break;
        end
   
 end
 
%% plot klasse 3
figure(1)
subplot(337);plot(ittWeight3(:,1:count-1)');title('Parameter weights - class 3')
subplot(338);plot(antMisClass3(:,1:count-1)');title('Number of misclassifications - class 3')
subplot(339);plot(critFunc3(:,1:count-2)');title('Value of criterion function - class 3')


 %% tr�n modellen / classify the unknown samples 
 
    gg1=weight1*[ones(20,1) tranklasse1]';% klasser skal ikke negeres => se om samples er over eller under 0
    [Y,I]=find(gg1<0); % finder I (placeringerne) hvor gg (diskriminant funktionen) er mindre end nul, hvilket returnerer placeringerne for fejlklassificeringerne
   % I1=I;
%     classes=ones(1,20);
%     classes(I)=2;
%     weight
%     classes
 
    gg2=weight*[ones(20,1) tranklasse2]';% klasser skal ikke negeres => se om samples er over eller under 0
    [Y,I]=find(gg2<0); % finder I (placeringerne) hvor gg (diskriminant funktionen) er mindre end nul, hvilket returnerer placeringerne for fejlklassificeringerne
  %  I2=I;
%     classes=ones(1,20);
%     classes(I)=2;
%     weight
%     classes

    gg3=weight*[ones(20,1) tranklasse3]';% klasser skal ikke negeres => se om samples er over eller under 0
    [Y,I]=find(gg3<0); % finder I (placeringerne) hvor gg (diskriminant funktionen) er mindre end nul, hvilket returnerer placeringerne for fejlklassificeringerne
    %I3=I;
%     classes=ones(1,20);
%     classes(I)=2;
%     weight
%     classes
 