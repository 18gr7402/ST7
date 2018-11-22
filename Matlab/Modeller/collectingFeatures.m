clear
close all
clc

%% Load data

load('FeatureLabelTabel500')

%% Glukose
%Find dataposition
labBedsideGlucose = find(FeatureLabelTabel.name == 'bedside glucose');
NCBG = find(FeatureLabelTabel.name == 'NCBG');
%Samling af data
glucoseOverall= vertcat(FeatureLabelTabel(labBedsideGlucose,:),FeatureLabelTabel(NCBG,:));
%�ndre navn
glucoseOverall.name = repmat(string('glucoseOverall'),height(glucoseOverall),1);

%% Respiratory rate

RCRRpatient = find(FeatureLabelTabel.name == 'RCRRpatient');
RCRRtotal = find(FeatureLabelTabel.name == 'RCRRtotal');
VPRR = find(FeatureLabelTabel.name == 'VPRR');
NCRR = find(FeatureLabelTabel.name == 'NCRR');

respiratoryRateOverall = vertcat(FeatureLabelTabel(RCRRpatient,:),FeatureLabelTabel(RCRRtotal,:),FeatureLabelTabel(VPRR,:),FeatureLabelTabel(NCRR,:));

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

FeatureLabelTabelWithOverallData = vertcat(FeatureLabelTabel,glucoseOverall,respiratoryRateOverall,heartRateOverall,temperatureOverall);
