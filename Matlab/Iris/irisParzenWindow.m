clc
clear all
close all

load('irisData.mat');

iris1 = [iris.sepal_length];
traIris1 = iris1';

% Vi ved vi skal lave Parzen windows, hvorfor vi inds�tter f�lgende kode,
% som er en funktion Alex har lavet til MM3 i PR.

%Histogram over data fordelt p� de fire features. Data er ikke opdelt i
%klasser.
figure(1)
hist(iris1,20)
title('Histogram over feature 1 data fordelt p� de tre klasser')
xlabel('Sepal length [cm]')
ylabel('Count')
legend('Sepal length')

% Ud fra histogrammet ses det, at datas�ttet ligger mellem v�rdierne cirka 4 og
% 8, hvorfor vi nu ved, at vores Parzen Window skal d�kke over disse
% v�rdier. For at v�re sikre p� at d�kke 4-8 v�lger vi at vinduet skal
% d�kke lidt l�ngere ud, hvorfor vi v�lger fra 2-12.

featVal = (2:0.1:12);  % Omr�det vores Parzen window skal bev�ge sig indenfor
featValNo = (1:length(featVal));
data = traIris1(1:end); %V�lger antal samples, og her v�lger vi alle fra feature 1
nr = 150;   % V�lger antal samples man vil bruge til at lave sin model ud fra
width = 0.5;    % Bredde p� Parzen Window, manuelt bestemt
pdfVal(featValNo) = parzen(featVal,data,nr,width)
