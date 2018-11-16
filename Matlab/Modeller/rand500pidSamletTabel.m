%load rand500pidlab
%load rand500pidVPTemp;
%load rand500pidNCTempC;
%load rand500pidNCHR;
%load rand500pidVPHR;
%load rand500pidNCRR;
%load rand500pidNCTempF;
%load rand500pidRCRRpatient;
%load rand500pidRCRRtotal;
%load rand500pidVPRR;
%load rand500pidNCPS;
%load rand500pidNCBG; 
%load rand500pidIDInsulin;
%load rand500pidIOInsulin;
%% LabLabel - laves kun for at alle tabellerne hedder det samme
LabLabel = rand500pidlab;

LabLabel.Properties.VariableNames = {'patienunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};
LabLabel.name = string(LabLabel.name);

%% VPTemp - indsæt label i tabellen

VPTemp = (1:height(rand500pidVPTemp))';
VPTemp = repmat(string('VPTemp'),height(rand500pidVPTemp),1);

VPTempLabel = addvars(rand500pidVPTemp,VPTemp,'Before',('temperature'));
VPTempLabel.Properties.VariableNames = {'patienunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% NCTempC - indsæt label i tabellen

NCTempCLabel = (1:height(rand500pidNCTempC))';
NCTempCLabel = repmat(string('NCTempC'),height(rand500pidNCTempC),1);

NCTempCLabel = addvars(rand500pidNCTempC,NCTempCLabel,'Before',('nursingchartvalue'));
NCTempCLabel.Properties.VariableNames = {'patienunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% NCHR - indsæt label i tabellen

NCHR = (1:height(rand500pidNCHR))';
NCHR = repmat(string('NCHR'),height(rand500pidNCHR),1);

NCHRLabel = addvars(rand500pidNCHR,NCHR,'Before',('nursingchartvalue'));
NCHRLabel.Properties.VariableNames = {'patienunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% VPHR - indsæt label i tabellen
VPHR = (1:height(rand500pidVPHR))';
VPHR = repmat(string('VPHR'),height(rand500pidVPHR),1);

VPHRLabel = addvars(rand500pidVPHR,VPHR,'Before',('heartrate'));
VPHRLabel.Properties.VariableNames = {'patienunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% NCRR - indsæt label i tabellen
NCRR = (1:height(rand500pidNCRR))';
NCRR = repmat(string('NCRR'),height(rand500pidNCRR),1);

NCRRLabel = addvars(rand500pidNCRR,NCRR,'Before',('nursingchartcelltypevalname'));
NCRRLabel = removevars(NCRRLabel,{'nursingchartcelltypevalname'});
NCRRLabel.Properties.VariableNames = {'patienunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% NCTempF - indsæt label i tabellen

NCTempF = (1:height(rand500pidNCTempF))';
NCTempF = repmat(string('NCTempF'),height(rand500pidNCTempF),1);

NCTempFLabel = addvars(rand500pidNCTempF,NCTempF,'Before',('nursingchartvalue'));
NCTempFLabel.Properties.VariableNames = {'patienunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% RCRRpatient - indsæt label i tabellen

RCRRpatient = (1:height(rand500pidRCRRpatient))';
RCRRpatient = repmat(string('RCRRpatient'),height(rand500pidRCRRpatient),1);

RCRRpatientLabel = addvars(rand500pidRCRRpatient,RCRRpatient,'Before',('respchartvaluelabel'));
RCRRpatientLabel = removevars(RCRRpatientLabel,{'respchartvaluelabel'});
RCRRpatientLabel.Properties.VariableNames = {'patienunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% RCRRtotal - indsæt label i tabellen

RCRRtotal = (1:height(rand500pidRCRRtotal))';
RCRRtotal = repmat(string('RCRRtotal'),height(rand500pidRCRRtotal),1);

RCRRtotalLabel = addvars(rand500pidRCRRtotal,RCRRtotal,'Before',('respchartvaluelabel'));
RCRRtotalLabel = removevars(RCRRtotalLabel,{'respchartvaluelabel'});
RCRRtotalLabel.Properties.VariableNames = {'patienunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% VPRR - indsæt label i tabellen

VPRR = (1:height(rand500pidVPRR))';
VPRR = repmat(string('VPRR'),height(rand500pidVPRR),1);

VPRRLabel = addvars(rand500pidVPRR,VPRR,'Before',('respiration'));
VPRRLabel.Properties.VariableNames = {'patienunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% NCPS - indsæt label i tabellen

NCPS = (1:height(rand500pidNCPS))';
NCPS = repmat(string('NCPS'),height(rand500pidNCPS),1);

NCPSLabel = addvars(rand500pidNCPS,NCPS,'Before',('nursingchartvalue'));
NCPSLabel.Properties.VariableNames = {'patienunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% NCBG

NCBG = (1:height(rand500pidNCBG))';
NCBG = repmat(string('NCBG'),height(rand500pidNCBG),1);

NCBGLabel = addvars(rand500pidNCBG,NCBG,'Before',('nursingchartvalue'));
NCBGLabel.Properties.VariableNames = {'patienunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% IDInsulin

IDInsulin = (1:height(rand500pidIDInsulin))';
IDInsulin = repmat(string('IDInsulin'),height(rand500pidIDInsulin),1);

IDInsulinLabel = addvars(rand500pidIDInsulin,IDInsulin,'Before',('drugrate'));
IDInsulinLabel.Properties.VariableNames = {'patienunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% IOInsulin

IOInsulin = (1:height(rand500pidIOInsulin))';
IOInsulin = repmat(string('IOInsulin'),height(rand500pidIOInsulin),1);

IOInsulinLabel = addvars(rand500pidIOInsulin,IOInsulin,'Before',('cellvaluenumeric'));
IOInsulinLabel.Properties.VariableNames = {'patienunitstayid' 'name' 'result' 'offset' 'unitadmittime24'};

%% Tabellerne er samlet


FeatureLabelTabel = vertcat(LabLabel,VPTempLabel,NCTempCLabel,NCTempFLabel,NCRRLabel,RCRRpatientLabel,RCRRtotalLabel,VPRRLabel,NCHRLabel,VPHRLabel,NCBGLabel,NCPSLabel,IDInsulinLabel,IOInsulinLabel);
           
                 
