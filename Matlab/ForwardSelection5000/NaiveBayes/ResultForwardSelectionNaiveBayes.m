clear
close all
clc

load ('resulterendeAUCBayes98');
AUC1=resulterendeAUC;
load ('resulterendeAUCBayes102');
AUC2=resulterendeAUC;


load ('resulterendeFeaturesBayes98');
Features1=resulterendeFeatures;
load ('resulterendeFeaturesBayes102');
Features2=resulterendeFeatures;

resulterendeAUC=[AUC1;AUC2];
resulterendeFeatures=[Features1;Features2];

A=resulterendeFeatures(:,1);
u=unique(A);
[n,b]=histc(A,u);
[n,is]=sort(n,'descend');
m=A(arrayfun(@(x) find(b==x,1,'first'),is));
Feature1=[n m];

B=resulterendeFeatures(find(A==21),2);
u=unique(B);
[n,b]=histc(B,u);
[n,is]=sort(n,'descend');
m=B(arrayfun(@(x) find(b==x,1,'first'),is));
Feature2=[n m];

B1=resulterendeFeatures(:,2);

C=resulterendeFeatures(find(A==21 & B1==22),3);
u=unique(C);
[n,b]=histc(C,u);
[n,is]=sort(n,'descend');
m=C(arrayfun(@(x) find(b==x,1,'first'),is));
Feature3=[n m];

C1=resulterendeFeatures(:,3);

D=resulterendeFeatures(find(A==21 & B1==22 & C1==20),4);
u=unique(D);
[n,b]=histc(D,u);
[n,is]=sort(n,'descend');
m=D(arrayfun(@(x) find(b==x,1,'first'),is));
Feature4=[n m];

D1= resulterendeFeatures(:,4);

E=resulterendeFeatures(find(A==21 & B1==22 & C1==20 & D1==24),5);
u=unique(E);
[n,b]=histc(E,u);
[n,is]=sort(n,'descend');
m=E(arrayfun(@(x) find(b==x,1,'first'),is));
Feature5=[n m];

E1=resulterendeFeatures(:,5);

F=resulterendeFeatures(find(A==21 & B1==22 & C1==20 & D1==24 & E1==37),6);
u=unique(F);
[n,b]=histc(F,u);
[n,is]=sort(n,'descend');
m=F(arrayfun(@(x) find(b==x,1,'first'),is));
Feature6=[n m];
