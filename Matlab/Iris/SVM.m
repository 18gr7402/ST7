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

 klasse1 = [iris.sepal_length(iris.species==1),iris.sepal_width(iris.species==1),iris.petal_length(iris.species==1),iris.petal_width(iris.species==1)];

 klasse2 = [iris.sepal_length(iris.species==2),iris.sepal_width(iris.species==2),iris.petal_length(iris.species==2),iris.petal_width(iris.species==2)];

 klasse3 = [iris.sepal_length(iris.species==3),iris.sepal_width(iris.species==3),iris.petal_length(iris.species==3),iris.petal_width(iris.species==3)];

 % her skal forløkken starte
 
 %% forberedelse af one vs. rest metode
 w0=ones(length(klasse1),1); % her laves der en matrix bestående af 1'ere, som har samme længde som klasse 1 (altså 50), 
 %1-tallet i slutningen gør, at vi får det som en søjlevektor med én søjle,i stedet for en 50x50 matrice med 1'ere.
 k1=[w0 klasse1]'; % vi opretter en variabel med klasse 1, hvor vi lægger w0 oveni således vi starter med en arbitrær værdi
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
 margin=0; % vi starter med en margin på 0
 learningRate=0.05; % learningRate er hvor mange/hurtigt vi går frem ad gangen, når vi skal finde den optimale placering af hyperplanet
 
 init_weight=ones(size(k1,1),1); % vores initierende vægtvektor, som opdateres løbende. Denne bliver resultatet til det optimalt placerede hyperplan
 weight=init_weight; % sørger for den initierende vægt opdateres
 count=1;

 %%% Klasse 1
%  while(1)
%     g=weight'*y1; % diskriminant funktionen, dvs. afstanden til decision boundary for klasse 1
%     [Y,I]=find(g<=margin); % vi er kun interesseret i I her. Det I returnerer er de placeringer hvor diskriminant funktionen (g) er større eller lig med margin (som vi har sat til 0).
%     
% %% % gradient of perceptron criteria function
%     
%     critFunc=sum(-(weight'*y1(:,I)),2); % y(:,I) --> alle dem fra y der ligger på en fejlklassificeret palds i I %2-tallet er kun til for at gøre koden universel, fordi vi gerne ellers ville have den på en søjleform
%     y_sum=sum(y1(:,I),2);
%     weight=weight+(learningRate*y_sum);% gradient of perceptron criteria function
% 
% %% gem parametre
%     
%     ittYsum1(:,count)=y_sum;
%     ittWeight1(:,count)=weight;
%     antMisClass1(1,count)=length(I);
%     critFunc1(:,count)=critFunc;
%     
%     count=count+1;
%     
%         if (isempty(I))
%         ittYsum1(:,count)=y_sum;
%         ittWeight1(:,count)=weight;
%         antMisClass1(1,count)=length(I);
%         critFunc1(:,count)=critFunc;
%         count=count+1;
%         weight1=weight;
%         g1=g;
%         break;
%         end
%  end
 
 margin2=100; % vi starter med en margin på 0
 learningRate2=0.001; % learningRate er hvor mange/hurtigt vi går frem ad gangen, når vi skal finde den optimale placering af hyperplanet
 
 init_weight=ones(size(k1,1),1); % vores initierende vægtvektor, som opdateres løbende. Denne bliver resultatet til det optimalt placerede hyperplan
 weight=init_weight; % sørger for den initierende vægt opdateres
 count=1;

  %%% Klasse 2
 while(1)
    g=weight'*y2; % diskriminant funktionen, dvs. afstanden til decision boundary for klasse 1
    [Y,I]=find(g<=margin2); % vi er kun interesseret i I her. Det I returnerer er de placeringer hvor diskriminant funktionen (g) er større eller lig med margin (som vi har sat til 0).
    
%% % gradient of perceptron criteria function
    
    critFunc=sum(-(weight'*y2(:,I)),2); % y(:,I) --> alle dem fra y der ligger på en fejlklassificeret palds i I %2-tallet er kun til for at gøre koden universel, fordi vi gerne ellers ville have den på en søjleform
    y_sum=sum(y2(:,I),2);
    weight=weight+(learningRate2*y_sum)% gradient of perceptron criteria function

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
        weight2=weight;
        g2=g;
        break;
        end
        
        if count==1000
        break;
        end
   
 end
 
 
 %% plot
figure(1);
% subplot(331);plot(ittWeight1(:,1:count-1)');title('Parameter weights - class 1')
% subplot(332);plot(antMisClass1(:,1:count-1)');title('Number of misclassifications - class 1')
% subplot(333);plot(critFunc1(:,1:count-2)');title('Value of criterion function - class 1')

subplot(334);plot(ittWeight2(:,1:count-1)');title('Parameter weights - class 2')
subplot(335);plot(antMisClass2(:,1:count-1)');title('Number of misclassifications - class 2')
subplot(336);plot(critFunc2(:,1:count-2)');title('Value of criterion function - class 2')

 
 