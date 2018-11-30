clear
close all
clc

load('Subset1Workspace');
D = dataSamlet;
load('Subset2Workspace');
D = [D;dataSamlet];
load('Subset3Workspace');
D = [D;dataSamlet];
load('Subset4Workspace');
D = [D;dataSamlet];
load('Subset5Workspace');
D = [D;dataSamlet];
load('Subset6Workspace');
D = [D;dataSamlet];
load('Subset7Workspace');
D = [D;dataSamlet];
load('Subset8Workspace');
D = [D;dataSamlet];
load('Subset9Workspace');
D = [D;dataSamlet];
load('Subset10Workspace');
D = [D;dataSamlet];
load('Subset11Workspace');
D = [D;dataSamlet];

dataFinalForForwardSelection5000 = [D(:,63), D(:,70), D(:,55), D(:,69), D(:,3), D(:,54)...
    , D(:,18), D(:,99), D(:,39), D(:,40), D(:,100), D(:,83), D(:,23), D(:,8), D(:,68)...
    , D(:,24), D(:,25), D(:,72), D(:,61), D(:,30), D(:,15), D(:,75), D(:,78), D(:,90)...
    , D(:,17), D(:,62), D(:,2), D(:,16), D(:,1), D(:,77), D(:,114), D(:,29), D(:,115)...
    , D(:,103), D(:,76), D(:,27), D(:,43), D(:,10), D(:,14), D(:,9), D(:,19), D(:,4)...
    , D(:,48), D(:,88), D(:,22), D(:,7), D(:,71), D(:,26), D(:,28), D(:,13), D(:,121)];



