%load rand80plab;
%load rand80pncbg;
%load rand80pncrr;
%load rand80prcrr; 

%OBS! mangler VPRR værdierne

%% LabLabel - laves kun for at alle tabellerne hedder det samme
LabLabel = rand80plab;

LabLabel.Properties.VariableNames = {'patientunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};
LabLabel.name = string(LabLabel.name);

%% NCRR - indsæt label i tabellen
NCRR = (1:height(rand80pncrr))';
NCRR = repmat(string('NCRR'),height(rand80pncrr),1);

NCRRLabel = addvars(rand80pncrr,NCRR,'Before',('nursingchartcelltypevalname'));
NCRRLabel = removevars(NCRRLabel,{'nursingchartcelltypevalname'});
NCRRLabel.Properties.VariableNames = {'patientunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% VPRR - indsæt label i tabellen
% 
% %rand80pVPRR.observationoffset=str2double(rand80pVPRR.observationoffset);
% VPRR = (1:height(rand80pVPRR))';
% VPRR = repmat(string('VPRR'),height(rand80pVPRR),1);
% 
% VPRRLabel = addvars(rand80pVPRR,VPRR,'Before',('respiration'));
% %VPRRLabel.observationoffset = str2double(VPRRLabel.observationoffset);
% VPRRLabel.Properties.VariableNames = {'patientunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};
% % VPRRLabel.offset = str2double(VPRRLabel.offset);
% % VPRRLabel.patientunitstayid = str2double(VPRRLabel.patientunitstayid);
% % VPRRLabel.result = str2double(VPRRLabel.result);
%% NCBG

NCBG = (1:height(rand80pncbg))';
NCBG = repmat(string('NCBG'),height(rand80pncbg),1);

NCBGLabel = addvars(rand80pncbg,NCBG,'Before',('nursingchartvalue'));
NCBGLabel = removevars(NCBGLabel,{'nursingchartcelltypevalname'});
NCBGLabel.Properties.VariableNames = {'patientunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% RCRRpatient
RCRRpatient = (1:height(rand80prcrr))';
RCRRpatient = repmat(string('RCRRpatient'),height(rand80prcrr),1);

RCRRpatientLabel = addvars(rand80prcrr,RCRRpatient,'Before',('respchartvaluelabel'));
RCRRpatientLabel = removevars(RCRRpatientLabel,{'respchartvaluelabel'});
RCRRpatientLabel.Properties.VariableNames = {'patientunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% Tabellerne er samlet

FeatureLabelTabel80p = vertcat(LabLabel,NCBGLabel,NCRRLabel,RCRRpatientLabel);
 
