clc
clear all
close all

load('irisData.mat');

iris1 = [iris.sepal_length];
traIris1 = iris1';

% Vi ved vi skal lave Parzen windows, hvorfor vi indsætter følgende kode,
% som er en funktion Alex har lavet til MM3 i PR.

%Histogram over data fordelt på de fire features. Data er ikke opdelt i
%klasser.
figure(1)
hist(iris1,20)
title('Histogram over feature 1 data fordelt på de tre klasser')
xlabel('Sepal length [cm]')
ylabel('Count')
legend('Sepal length')

% Ud fra histogrammet ses det, at datasættet ligger mellem værdierne cirka 4 og
% 8, hvorfor vi nu ved, at vores Parzen Window skal dække over disse
% værdier. For at være sikre på at dække 4-8 vælger vi at vinduet skal
% dække lidt længere ud, hvorfor vi vælger fra 2-12.

featVal = (2:0.1:12);  % Området vores Parzen window skal bevæge sig indenfor
featValNo = (1:length(featVal));
data = traIris1(1:end); %Vælger antal samples, og her vælger vi alle fra feature 1
nr = 150;   % Vælger antal samples man vil bruge til at lave sin model ud fra
width = 0.5;    % Bredde på Parzen Window, manuelt bestemt
pdfVal(featValNo) = parzen(featVal,data,nr,width)
