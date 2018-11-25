clear
close all
clc

%% Load data

load('FeatureLabelTabel500')

%% Bedside glukose
%Find dataposition
labBedsideGlucose = find(FeatureLabelTabel.name == 'bedside glucose');
NCBG = find(FeatureLabelTabel.name == 'NCBG');
%Samling af data
bedsideGlucoseOverall= vertcat(FeatureLabelTabel(labBedsideGlucose,:),FeatureLabelTabel(NCBG,:));
%Ændre navn
bedsideGlucoseOverall.name = repmat(string('bedsideGlucoseOverall'),height(bedsideGlucoseOverall),1);

%% Respiratory rate

RCRRpatient = find(FeatureLabelTabel.name == 'RCRRpatient');
VPRR = find(FeatureLabelTabel.name == 'VPRR');
NCRR = find(FeatureLabelTabel.name == 'NCRR');
labRespiratoryRate = find(FeatureLabelTabel.name == 'Respiratory Rate');

respiratoryRateOverall = vertcat(FeatureLabelTabel(RCRRpatient,:),FeatureLabelTabel(labRespiratoryRate,:),FeatureLabelTabel(VPRR,:),FeatureLabelTabel(NCRR,:));

respiratoryRateOverall.name = repmat(string('respiratoryRateOverall'),height(respiratoryRateOverall),1);

%% Heart rate

VPHR = find(FeatureLabelTabel.name == 'VPHR');
NCHR = find(FeatureLabelTabel.name == 'NCHR');

heartRateOverall = vertcat(FeatureLabelTabel(VPHR,:),FeatureLabelTabel(NCHR,:));

heartRateOverall.name = repmat(string('heartRateOverall'),height(heartRateOverall),1);

%% Temperature

NCTempC = find(FeatureLabelTabel.name == 'NCTempC');
VPTemp = find(FeatureLabelTabel.name == 'VPTemp');
Temperature = find(FeatureLabelTabel.name == 'Temperature');

temperatureOverall = vertcat(FeatureLabelTabel(NCTempC,:),FeatureLabelTabel(VPTemp,:),FeatureLabelTabel(Temperature,:));

temperatureOverall.name = repmat(string('temperatureOverall'),height(temperatureOverall),1);

%% Samling af ny data og FeatureLabelTabel

FeatureLabelTabelWithOverallData = vertcat(FeatureLabelTabel,bedsideGlucoseOverall,respiratoryRateOverall,heartRateOverall,temperatureOverall);
