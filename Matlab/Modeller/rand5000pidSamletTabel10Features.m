%load rand5000pidlab
%load rand5000pidNCRR;
%load rand5000pidVPRR;
%load rand5000pidNCBG; 
%% LabLabel - laves kun for at alle tabellerne hedder det samme
LabLabel = rand5000pidlab;

LabLabel.Properties.VariableNames = {'patientunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};
LabLabel.name = string(LabLabel.name);

%% NCRR - indsæt label i tabellen
NCRR = (1:height(rand5000pidNCRR))';
NCRR = repmat(string('NCRR'),height(rand5000pidNCRR),1);

NCRRLabel = addvars(rand5000pidNCRR,NCRR,'Before',('nursingchartcelltypevalname'));
NCRRLabel = removevars(NCRRLabel,{'nursingchartcelltypevalname'});
NCRRLabel.Properties.VariableNames = {'patientunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% VPRR - indsæt label i tabellen

VPRR = (1:height(rand5000pidVPRR))';
VPRR = repmat(string('VPRR'),height(rand500pidVPRR),1);

VPRRLabel = addvars(rand5000pidVPRR,VPRR,'Before',('respiration'));
VPRRLabel.Properties.VariableNames = {'patientunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% NCBG

NCBG = (1:height(rand5000pidNCBG))';
NCBG = repmat(string('NCBG'),height(rand500pidNCBG),1);

NCBGLabel = addvars(rand5000pidNCBG,NCBG,'Before',('nursingchartvalue'));
NCBGLabel.Properties.VariableNames = {'patientunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% Tabellerne er samlet

FeatureLabelTabel = vertcat(LabLabel,NCRRLabel,VPRRLabel,NCBGLabel);
 
