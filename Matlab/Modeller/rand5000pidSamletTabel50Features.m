%load rand5000pidspecifiklabvaerdi;
%load rand5000pidNCRR;
%load rand5000pidVPRR;
%load rand5000pidNCBG; 
%load rand5000pidRCRRpatient;
%% LabLabel - laves kun for at alle tabellerne hedder det samme
LabLabel = rand5000pidspecifiklabvaerdi;

LabLabel.Properties.VariableNames = {'patientunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};
LabLabel.name = string(LabLabel.name);

%% NCRR - inds�t label i tabellen
NCRR = (1:height(rand5000pidNCRR))';
NCRR = repmat(string('NCRR'),height(rand5000pidNCRR),1);

NCRRLabel = addvars(rand5000pidNCRR,NCRR,'Before',('nursingchartcelltypevalname'));
NCRRLabel = removevars(NCRRLabel,{'nursingchartcelltypevalname'});
NCRRLabel.Properties.VariableNames = {'patientunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% VPRR - inds�t label i tabellen

%rand5000pidVPRR.observationoffset=str2double(rand5000pidVPRR.observationoffset);
VPRR = (1:height(rand5000pidVPRR))';
VPRR = repmat(string('VPRR'),height(rand5000pidVPRR),1);

VPRRLabel = addvars(rand5000pidVPRR,VPRR,'Before',('respiration'));
%VPRRLabel.observationoffset = str2double(VPRRLabel.observationoffset);
VPRRLabel.Properties.VariableNames = {'patientunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};
% VPRRLabel.offset = str2double(VPRRLabel.offset);
% VPRRLabel.patientunitstayid = str2double(VPRRLabel.patientunitstayid);
% VPRRLabel.result = str2double(VPRRLabel.result);
%% NCBG

NCBG = (1:height(rand5000pidNCBG))';
NCBG = repmat(string('NCBG'),height(rand5000pidNCBG),1);

NCBGLabel = addvars(rand5000pidNCBG,NCBG,'Before',('nursingchartvalue'));
NCBGLabel = removevars(NCBGLabel,{'nursingchartcelltypevalname'});
NCBGLabel.Properties.VariableNames = {'patientunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% RCRRpatient
RCRRpatient = (1:height(rand5000pidRCRRpatient))';
RCRRpatient = repmat(string('RCRRpatient'),height(rand5000pidRCRRpatient),1);

RCRRpatientLabel = addvars(rand5000pidRCRRpatient,RCRRpatient,'Before',('respchartvaluelabel'));
RCRRpatientLabel = removevars(RCRRpatientLabel,{'respchartvaluelabel'});
RCRRpatientLabel.Properties.VariableNames = {'patientunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% Tabellerne er samlet

FeatureLabelTabel = vertcat(LabLabel,NCBGLabel,NCRRLabel,VPRRLabel,RCRRpatientLabel);
 
