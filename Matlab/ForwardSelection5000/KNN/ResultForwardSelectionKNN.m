clear
close all
clc
load resulterendeAUCKNN1;
load resulterendeFeaturesKNN1;

A=resulterendeFeatures(:,1);
u=unique(A);
[n,b]=histc(A,u);
[n,is]=sort(n,'descend');
m=A(arrayfun(@(x) find(b==x,1,'first'),is));
Feature1=[n m];

B=resulterendeFeatures(find(A==43),2);
u=unique(B);
[n,b]=histc(B,u);
[n,is]=sort(n,'descend');
m=B(arrayfun(@(x) find(b==x,1,'first'),is));
Feature2=[n m];

B1=resulterendeFeatures(:,2);

C=resulterendeFeatures(find(A==43 & B1==12),3);
u=unique(C);
[n,b]=histc(C,u);
[n,is]=sort(n,'descend');
m=C(arrayfun(@(x) find(b==x,1,'first'),is));
Feature3=[n m];

C1=resulterendeFeatures(:,3);

D=resulterendeFeatures(find(A==43 & B1==12 & C1==37),4);
u=unique(D);
[n,b]=histc(D,u);
[n,is]=sort(n,'descend');
m=D(arrayfun(@(x) find(b==x,1,'first'),is));
Feature4=[n m];
