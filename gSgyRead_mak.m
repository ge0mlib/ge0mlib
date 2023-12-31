function [SgyHead,Head,Data]=gSgyRead_mak(fName,Endian,DataSampleFormat)
%Read Sgy variables [SgyHead,Head,Data] from file.
%function [SgyHead,Head,Data]=gSgyRead(fName,Endian,DataSampleFormat), where
%fName - the target file name;
%Endian - forced Endian; 'b'- big-endian; 'l'- Little-endian; ''- Endian auto detection (used DataSampleFormat bytes);
%DataSampleFormat - forced Sample Format (1, 2, 3, 4, 5 or 8); empty matrix, if no forced (used DataSampleFormat from file);
%SgyHead - Header structure, included Textual File Header, Binary File Header, Extended Textual File Header;
%Head - Header structure, included Trace Headers;
%Data - matrix with Traces Data.
%"Un-defined" numbers (for traces with variable length) set to nan.
%Example: [SgyHead,Head,Data]=gSgyRead('c:\temp\1.sgy','',[]);

Descript.DataSampleFormat.Code=(1:8)';
Descript.DataSampleFormat.Text={'1=4-byte IBM floating-point','2=4-byte, two''s complement integer','3=2-byte, two''s complement integer','4=4-byte fixed-point with gain (obsolete)','5=4-byte IEEE floating-point','6=Not currently used','7=Not currently used','8=1-byte, two''s complement integer'};
Descript.DataSampleFormat.C={'uint32','int32','int16','uint32','float32','','','int8'};
Descript.DataSampleFormat.nb=[4,4,2,4,4,nan,nan,1];
Descript.TraceSorting.Code=(-1:9)';
Descript.TraceSorting.Text={'-1=Other (should be explained in user Extended Textual File Header stanza','0=Unknown','1=As recorded (no sorting)','2=CDP ensemble','3=Single fold continuous profile','4=Horizontally stacked','5=Common source point','6=Common receiver point','7=Common offset point','8=Common mid-point','9=Common conversion point'};
Descript.SweepType.Code=(1:4)';
Descript.SweepType.Text={'1=linear','2=parabolic','3=exponential','4=other'};
Descript.TaperType.Code=(1:3)';
Descript.TaperType.Text={'1=linear','2=cos^2','3=other'};
Descript.AmplitudeRecoveryMethod.Code=(1:3)';
Descript.AmplitudeRecoveryMethod.Text={'1=none','2=spherical divergence','3=AGC','4=other'};
Descript.MeasurementSystem.Code=(1:2)';
Descript.MeasurementSystem.Text={'1=Meters','2=Feet'};
Descript.ImpulseSignalPolarity.Code=(1:2)';
Descript.ImpulseSignalPolarity.Text={'1=Increase pressure gives negative number','2=Increase pressure gives positive number'};
Descript.VibratoryPolarityCode.Code=(1:8)';
Descript.VibratoryPolarityCode.Text={'1=337.5 to 22.5','2=22.5 to 67.5','3=67.5 to 112.5','4=112.5 to 157.5','5=157.5 to 202.5','6=202.5 to 247.5','7=247.5 to 292.5','8=292.5 to 337.5'};
Descript.TraceIdenitifactionCode.Code=(-1:22)';
Descript.TraceIdenitifactionCode.Text={'-1=Other','0=Unknown','1=Seismic data','2=Dead','3=Dummy','4=Time break','5=Uphole','6=Sweep','7=Timing','8=Waterbreak','9=Near-field gun signature','10=Far-field gun signature','11=Seismic pressure sensor','12=Multicomponent seismic sensor - Vertical component','13=Multicomponent seismic sensor - Cross-line component','14=Multicomponent seismic sensor - In-line component','15=Rotated multicomponent seismic sensor - Vertical component','16=Rotated multicomponent seismic sensor - Transverse component','17=Rotated multicomponent seismic sensor - Radial component','18=Vibrator reaction mass','19=Vibrator baseplate','20=Vibrator estimated ground force','21=Vibrator reference','22=Time-velocity pairs'};
Descript.CoordinateUnits.Code=(1:4)';
Descript.CoordinateUnits.Text={'1=Length (meters or feet)','2=Seconds of arc','3=Decimal degrees','4=Degrees, minutes, seconds (DMS)'};
Descript.GainType.Code=(1:3)';
Descript.GainType.Text={'1=fixed','2=binary','3=floating point'};
Descript.SweepType.Code=(1:4)';
Descript.SweepType.Text={'1=linear','2=parabolic','3=exponential','4=other'};
Descript.TaperType.Code=(1:3)';
Descript.TaperType.Text={'1=linear','2=cos^2','3=other'};
Descript.SweepType.Code=(1:4)';
Descript.SweepType.Text={'1=Local','2=GMT (Greenwich Mean Time)c','3=Other, should be explained in a user defined stanza in the Extended Textual File Header','4=UTC (Coordinated Universal Time)'};
Descript.TraceValueMeasurementUnit.Code=(-1:9)';
Descript.TraceValueMeasurementUnit.Text={'-1=Other (should be described in Data Sample Measurement Units Stanza)','0=Unknown','1=Pascal(Pa)','2=Volts(v)','3=Millivolts(mV)','4=Amperes(A)','5=Meters(m)','6=Meters per second(m/s)','7=Meters per second squared(m/s^2)','8=Newton(N)','9=Watt(W)'};
Descript.TransductionUnit.Code=(-1:9)';
Descript.TransductionUnit.Text={'-1=Other (should be described in Data Sample Measurement Units Stanza)','0=Unknown','1=Pascal(Pa)','2=Volts(v)','3=Millivolts(mV)','4=Amperes(A)','5=Meters(m)','6=Meters per second(m/s)','7=Meters per second squared(m/s^2)','8=Newton(N)','9=Watt(W)'};
Descript.TaperType.Code=(-1:9)';
Descript.TaperType.Text={'-1=Other (should be described in Source Type/Orientation stanza)','0=Unknown','1=Vibratory - Vertical orientation','2=Vibratory - Cross-line orientation','3=Vibratory - In-line orientation','4=Impulsive - Vertical orientation','5=Impulsive - Cross-line orientation','6=Impulsive - In-line orientation','7=Distributed Impulsive - Vertical orientation','8=Distributed Impulsive - Cross-line orientation','9=Distributed Impulsive - In-line orientation'};
Descript.TaperType.Code=(-1:6)';
Descript.TaperType.Text={'-1=Other (should be described in Source Measurement Unit stanza)','0=Unknown','1=Joule(J)','2=Kilowatt(kW)','3=Pascal(Pa)','4=Bar(Bar)/4=Bar-meter(Bar-m)','5=Newton(N)','6=Kilograms(kg)'};

%==Begin Endian detection
if isempty(Endian), 
    [fId, mes]=fopen(fName,'r','b');if ~isempty(mes), error(['gSgyRead: ' mes]);end;
    fseek(fId,3224,'bof');tmp=fread(fId,1,'uint16');%read DataSampleFormat
    if tmp<9, Endian='b';
    elseif (bitand(tmp,255)==0)&&(tmp<2304), Endian='l';
    elseif error('gSgyRead: error in DataSampleFormat (bytes 3225-3226) value');
    end;
    fclose(fId);
end;
%==End Endian detection
%==Begin File reading
[fId, mes]=fopen(fName,'r',Endian);if ~isempty(mes), error(['gSgyRead: ' mes]);end;
SgyHead.Descript=Descript;
SgyHead.fName=fName;
SgyHead.Endian=Endian;
SgyHead.FDataSampleFormat=DataSampleFormat;
finfo=dir(SgyHead.fName);fSize=finfo.bytes;
%===Begin Read Textual File Header
SgyHead.TextualFileHeader=char(fread(fId,3200,'uint8'));
%===End Read Textual File Header
%===Begin Read Binary File Header
SgyHead.Job=fread(fId,1,'int32'); %Job identification number.
SgyHead.Line=fread(fId,1,'int32'); %=1 // Line number.  For 3-D poststack data, this will typically contain the in-line number.
SgyHead.Reel=fread(fId,1,'int32'); %=1 // Reel number.
 SgyHead.DataTracePerEnsemble=fread(fId,1,'int16'); %!!!changed The cannels number // Number of data traces per ensemble.  Mandatory for prestack data.
SgyHead.AuxiliaryTracePerEnsemble=fread(fId,1,'int16'); %Number of auxiliary traces per ensemble.  Mandatory for prestack data.
SgyHead.dt=fread(fId,1,'int16'); %1000000/ADC_Freq // Sample interval in microseconds (�s).  Mandatory for all data types.
SgyHead.dtOrig=fread(fId,1,'int16'); %1000000/ADC_Freq // Sample interval in microseconds  (�s) of original field recording.
SgyHead.ns=fread(fId,1,'int16'); % Number of samples per channel // Number of samples per data trace.  Mandatory for all types of data. Note: The sample interval and number of samples in the Binary File Header should be for the primary set of seismic data traces in the file.
SgyHead.nsOrig=fread(fId,1,'int16'); %Number of samples per channel // Number of samples per data trace for original field recording.
 SgyHead.DataSampleFormat=fread(fId,1,'int16'); if SgyHead.DataSampleFormat==2,SgyHead.DataSampleFormat=8;end; %!!! 2-(signed byte), 3-(short, 2 byte) // Data sample format code.  Mandatory for all data. 1=4-byte IBM floating-point; 2=4-byte, two's complement integer; 3=2-byte, two's complement integer; 4=4-byte fixed-point with gain (obsolete); 5=4-byte IEEE floating-point; 6=Not currently used; 7=Not currently used; 8=1-byte, two's complement integer.
SgyHead.EnsembleFold=fread(fId,1,'int16'); %=1 // Ensemble fold - The expected number of data traces per trace ensemble (e.g. the CMP fold). Highly recommended for all types of data.
SgyHead.TraceSorting=fread(fId,1,'int16'); %Trace sorting code (i.e. type of ensemble) : -1=Other (should be explained in user Extended Textual File Header stanza; 0=Unknown; 1=As recorded (no sorting); 2=CDP ensemble; 3=Single fold continuous profile; 4=Horizontally stacked; 5=Common source point; 6=Common receiver point; 7=Common offset point; 8=Common mid-point; 9=Common conversion point. Highly recommended for all types of data.
SgyHead.VerticalSumCode=fread(fId,1,'int16'); %Vertical sum code: 1 = no sum, 2 = two sum, �, N = M-1 sum  (M = 2 to 32,767).
SgyHead.SweepFrequencyStart=fread(fId,1,'int16'); %Sweep frequency at start (Hz).
SgyHead.SweepFrequencyEnd=fread(fId,1,'int16'); %Sweep frequency at end (Hz).
SgyHead.SweepLength=fread(fId,1,'int16'); %Sweep length (ms).
SgyHead.SweepType=fread(fId,1,'int16'); %Sweep type code: 1=linear; 2=parabolic; 3=exponential; 4=other.
SgyHead.SweepChannel=fread(fId,1,'int16'); %Trace number of sweep channel.
SgyHead.SweepTaperlengthStart=fread(fId,1,'int16'); %Sweep trace taper length in milliseconds at start if tapered (the taper starts at zero time and is effective for this length).
SgyHead.SweepTaperLengthEnd=fread(fId,1,'int16'); %Sweep trace taper length in milliseconds at end (the ending taper starts at sweep length minus the taper length at end).
SgyHead.TaperType=fread(fId,1,'int16'); %Taper type: 1=linear; 2=cos^2; 3=other.
SgyHead.CorrelatedDataTraces=fread(fId,1,'int16'); %Correlated data traces: 1=no; 2=yes.
SgyHead.BinaryGain=fread(fId,1,'int16'); %Binary gain recovered: 1=yes; 2=no.
SgyHead.AmplitudeRecoveryMethod=fread(fId,1,'int16'); %Amplitude recovery method: 1=none; 2=spherical divergence; 3=AGC; 4=other.
SgyHead.MeasurementSystem=fread(fId,1,'int16'); %=1 // Measurement system: Highly recommended for all types of data.  If Location Data stanzas are included in the file, this entry must agree with the Location Data stanza.  If there is a disagreement, the last Location Data stanza is the controlling authority. 1=Meters; 2=Feet.
SgyHead.ImpulseSignalPolarity=fread(fId,1,'int16'); %Impulse signal polarity: 1=Increase in pressure or upward geophone case movement gives negative number on tape. 2=Increase in pressure or upward geophone case movement gives positive number on tape.
SgyHead.VibratoryPolarityCode=fread(fId,1,'int16'); %Vibratory polarity code: Seismic signal lags pilot signal by: 1=337.5 to 22.5; 2=22.5 to 67.5; 3=67.5 to 112.5; 4=112.5 to 157.5; 5=157.5 to 202.5; 6=202.5 to 247.5; 7=247.5 to 292.5;8=292.5 to 337.5.
 SgyHead.nChannelType=fread(fId,128,'int16'); %!!!added 1-SBP, 2-SSS left side (port side),3-SSS right side (starboard)
 SgyHead.nSoftwareVersion=fread(fId,1,'int16'); %!!!added
 SgyHead.nNavLatency=fread(fId,1,'int32'); %!!!added
 SgyHead.nGLS_Sign=fread(fId,1,'int32'); %!!!added = 44534c47h ��� 1146309703 for files were MAK-created
 SgyHead.nMax_Digital_Val=fread(fId,1,'int16'); %!!!added ADT-maximum code
 SgyHead.nMax_Voltage_mkv=fread(fId,1,'int16'); %!!!added ADT-maximum value in mkv
 SgyHead.Unassigned1=zeros(1,120); %!!!not used // fread(fId,120,'int16'); %Unassigned1
 SgyHead.SegyFormatRevisionNumber=0; %!!!not used // fread(fId,1,'int16'); %SEG Y Format Revision Number. This is a 16-bit unsigned value with a Q-point between the first and second bytes. Thus for SEG Y Revision 1.0, as defined in this document, this will be recorded as 0100. This field is mandatory for all versions of SEG Y, although a value of zero indicates "traditional" SEG Y conforming to the 1975 standard.
 SgyHead.FixedLengthTraceFlag=1; %!!!not used // fread(fId,1,'int16'); %Fixed length trace flag. A value of one indicates that all traces in this SEG Y file are guaranteed to have the same sample interval and number of samples, as specified in Textual File Header bytes 3217-3218 and 3221-3222. A value of zero indicates that the length of the traces in the file may vary and the number of samples in bytes 115-116 of the Trace Header must be examined to determine the actual length of each trace. This field is mandatory for all versions of SEG Y, although a value of zero indicates "traditional" SEG Y conforming to the 1975 standard.
 SgyHead.NumberOfExtTextualHeaders=0; %!!!not used // fread(fId,1,'int16'); %Number of 3200-byte, Extended Textual File Header records following the Binary Header. A value of zero indicates there are no Extended Textual File Header records (i.e. this file has no Extended Textual File Header(s)).  A value of -1 indicates that there are a variable number of Extended Textual File Header records and the end of the Extended Textual File Header is denoted by an ((SEG: EndText)) stanza in the final record.
% A positive value indicates that there are exactly that many Extended Textual File Header records.  Note that, although the exact number of Extended Textual File Header records may be a useful piece of information, it will not always be known at the time the Binary Header is written and it is not mandatory that a positive value be recorded here.  This field is mandatory for all versions of SEG Y, although a value of zero indicates �traditional� SEG Y conforming to the 1975 standard.
 SgyHead.nUnassigned2=fread(fId,70,'uint8'); %!!!changed // Unassigned2
 SgyHead.Unassigned2=zeros(1,47); %!!!not used // fread(fId,47,'int16'); %Unassigned2
if ~isempty(DataSampleFormat), SgyHead.FDataSampleFormat=DataSampleFormat; else SgyHead.FDataSampleFormat=SgyHead.DataSampleFormat; end;
%===End Read Binary File Header
%===Begin Read Extended Textual File Header
SgyHead.ExtTextualHeaders=[];
%not used // if SgyHead.NumberOfExtTextualHeaders==0, %a value of zero indicates there are no Extended Textual File Header records
%not used //     SgyHead.ExtTextualHeaders=[];
%not used // elseif SgyHead.NumberOfExtTextualHeaders>0, %A positive value indicates that there are exactly that many Extended Textual File Header records.
%not used //     SgyHead.ExtTextualHeaders=char(fread(fId,3200.*SgyHead.NumberOfExtTextualHeaders,'uint8'));
%not used // elseif SgyHead.NumberOfExtTextualHeaders==-1, %a value of -1 indicates that there are a variable number of Extended Textual File Header records and the end of the Extended Textual File Header is denoted by an ((SEG: EndText)) stanza in the final record.
%not used //     nn=1;stz='';
%not used //     while nn,
%not used //         stz(:,nn)=fread(fId,3200,'*char');k=strfind(stz(:,nn),'((SEG: EndText))');if isempty(k), nn=nn+1; else nn=0; end; %!!!Warning NOT TESTED
%not used //     end;
%not used //     SgyHead.ExtTextualHeaders=stz;
%not used // else
%not used //     error(['Error gSgyRead: Not valid SgyHead.NumberOfExtTextualHeaders=' num2str(SgyHead.NumberOfExtTextualHeaders)]);
%not used // end;
%===End Read Extended Textual File Header
%===Begin Number of Traces and Trace Length estimation
SeekTraceStart=ftell(fId);
nForm=SgyHead.Descript.DataSampleFormat.nb(SgyHead.Descript.DataSampleFormat.Code==SgyHead.FDataSampleFormat);
%not used // FL=SgyHead.FixedLengthTraceFlag;
%not used // if FL==1,
%not used //     NTrace=(fSize-SeekTraceStart)./(240+SgyHead.ns.*nForm);
%not used //     LTrace=SgyHead.ns;
%not used // elseif FL==0,
    NTrace=0;LTrace=0;
    while ftell(fId)<fSize,
        fseek(fId,114,'cof');nSam=fread(fId,1,'int16');
        NTrace=NTrace+1;if LTrace<nSam,LTrace=nSam;end;
        fseek(fId,124+nSam.*nForm,'cof');
    end;
%not used // else
%not used //     error(['Error gSgyRead: Not valid FixedLengthTraceFlag=' num2str(FixedLengthTraceFlag)]);
%not used // end;
fseek(fId,SeekTraceStart,'bof');
%===End Number of Traces and Trace Length estimation
%===Begin Trase Header Allocate
Head=struct('MessageNum',nan(1,NTrace),'TraceSequenceLine',nan(1,NTrace),'TraceSequenceFile',nan(1,NTrace),'FieldRecord',nan(1,NTrace),'TraceNumber',nan(1,NTrace),'EnergySourcePoint',nan(1,NTrace),...
    'cdp',nan(1,NTrace),'cdpTrace',nan(1,NTrace),'TraceIdenitifactionCode',nan(1,NTrace),'NSummedTraces',nan(1,NTrace),'NStackedTraces',nan(1,NTrace),'DataUse',nan(1,NTrace),'offset',nan(1,NTrace),...
    'ReceiverGroupElevation',nan(1,NTrace),'SourceSurfaceElevation',nan(1,NTrace),'SourceDepth',nan(1,NTrace),'ReceiverDatumElevation',nan(1,NTrace),'SourceDatumElevation',nan(1,NTrace),...
    'SourceWaterDepth',nan(1,NTrace),'GroupWaterDepth',nan(1,NTrace),'ElevationScalar',nan(1,NTrace),'SourceGroupScalar',nan(1,NTrace),'SourceX',nan(1,NTrace),'SourceY',nan(1,NTrace),...
    'GroupX',nan(1,NTrace),'GroupY',nan(1,NTrace),'CoordinateUnits',nan(1,NTrace),'WeatheringVelocity',nan(1,NTrace),'SubWeatheringVelocity',nan(1,NTrace),'SourceUpholeTime',nan(1,NTrace),...
    'GroupUpholeTime',nan(1,NTrace),'SourceStaticCorrection',nan(1,NTrace),'GroupStaticCorrection',nan(1,NTrace),'TotalStaticApplied',nan(1,NTrace),'LagTimeA',nan(1,NTrace),...
    'LagTimeB',nan(1,NTrace),'DelayRecordingTime',nan(1,NTrace),'MuteTimeStart',nan(1,NTrace),'MuteTimeEnd',nan(1,NTrace),'ns',nan(1,NTrace),'dt',nan(1,NTrace),'GainType',nan(1,NTrace),...
    'InstrumentGainConstant',nan(1,NTrace),'InstrumentInitialGain',nan(1,NTrace),'Correlated',nan(1,NTrace),'SweepFrequenceStart',nan(1,NTrace),'SweepFrequenceEnd',nan(1,NTrace),...
    'SweepLength',nan(1,NTrace),'SweepType',nan(1,NTrace),'SweepTraceTaperLengthStart',nan(1,NTrace),'SweepTraceTaperLengthEnd',nan(1,NTrace),'TaperType',nan(1,NTrace),'AliasFilterFrequency',nan(1,NTrace),...
    'AliasFilterSlope',nan(1,NTrace),'NotchFilterFrequency',nan(1,NTrace),'NotchFilterSlope',nan(1,NTrace),'LowCutFrequency',nan(1,NTrace),'HighCutFrequency',nan(1,NTrace),'LowCutSlope',nan(1,NTrace),...
    'HighCutSlope',nan(1,NTrace),'YearDataRecorded',nan(1,NTrace),'DayOfYear',nan(1,NTrace),'HourOfDay',nan(1,NTrace),'MinuteOfHour',nan(1,NTrace),'SecondOfMinute',nan(1,NTrace),...
    'TimeBaseCode',nan(1,NTrace),'TraceWeightningFactor',nan(1,NTrace),...
    'nChannelCode',nan(1,NTrace),'nShipCourse',nan(1,NTrace),'nShipSpeed',nan(1,NTrace),'nSignal_Period_ms',nan(1,NTrace),'nChannel_Ping_Divider',nan(1,NTrace),'nTowfishPitch',nan(1,NTrace),'nTowfishRoll',nan(1,NTrace),'nTowfishHeading',nan(1,NTrace),'nSpeedLog',nan(1,NTrace),'nlMagX',nan(1,NTrace),'nlMagY',nan(1,NTrace),'nlMagZ',nan(1,NTrace),...
    'nlConductivityFreq',nan(1,NTrace),'nlTemperatureFreq',nan(1,NTrace),'nlPressureFreq',nan(1,NTrace),'nlPressureTemp',nan(1,NTrace),'nlCableout',nan(1,NTrace),'nlSoundVelocity',nan(1,NTrace),'nlPressure_dBars',nan(1,NTrace),'nlTemperature',nan(1,NTrace),'nlLayback',nan(1,NTrace),'nEventNumber',nan(1,NTrace),'nTowfishSpeed',nan(1,NTrace),'nSpare',nan(1,NTrace),...
    'GeophoneGroupNumberRoll',zeros(1,NTrace),'GeophoneGroupNumberFirstTraceOrigField',zeros(1,NTrace),... %not used //
    'GeophoneGroupNumberLastTraceOrigField',zeros(1,NTrace),'GapSize',zeros(1,NTrace),'OverTravel',zeros(1,NTrace),'cdpX',zeros(1,NTrace),'cdpY',zeros(1,NTrace),'Inline3D',zeros(1,NTrace),... %not used //
    'Crossline3D',zeros(1,NTrace),'ShotPoint',zeros(1,NTrace),'ShotPointScalar',zeros(1,NTrace),'TraceValueMeasurementUnit',zeros(1,NTrace),'TransductionConstantMantissa',zeros(1,NTrace),... %not used //
    'TransductionConstantPower',zeros(1,NTrace),'TransductionUnit',zeros(1,NTrace),'TraceIdentifier',zeros(1,NTrace),'ScalarTraceHeader',zeros(1,NTrace),'SourceType',zeros(1,NTrace),... %not used //
    'SourceEnergyDirectionMantissa',zeros(1,NTrace),'SourceEnergyDirectionExponent',zeros(1,NTrace),'SourceMeasurementMantissa',zeros(1,NTrace),'SourceMeasurementExponent',zeros(1,NTrace),... %not used //
    'SourceMeasurementUnit',zeros(1,NTrace),'UnassignedInt1',zeros(1,NTrace),'UnassignedInt2',zeros(1,NTrace)); %not used //
%===End Trase Header Allocate
%===Begin Trase Data Allocate
Data=nan(LTrace,NTrace);
%===End Trase Data Allocate
cForm=SgyHead.Descript.DataSampleFormat.C{SgyHead.Descript.DataSampleFormat.Code==SgyHead.FDataSampleFormat};
errIbmFl=1;errObsFl=1;
for n=1:NTrace,
    %===Begin Trase Header Read
    Head.MessageNum(n)=n;
    Head.TraceSequenceLine(n)=fread(fId,1,'int32'); %Trace sequence number within line � Numbers continue to increase if the same line continues across multiple SEG Y files. Highly recommended for all types of data.
    Head.TraceSequenceFile(n)=fread(fId,1,'int32'); %Trace sequence number within SEG Y file � Each file starts with trace sequence one.
    Head.FieldRecord(n)=fread(fId,1,'int32'); %Original field record number. Highly recommended for all types of data.
    Head.TraceNumber(n)=fread(fId,1,'int32'); %=1 // Trace number within the original field record. Highly recommended for all types of data.
    Head.EnergySourcePoint(n)=fread(fId,1,'int32'); %Energy source point number � Used when more than one record occurs at the same effective surface location.  It is recommended that the new entry defined in Trace Header bytes 197-202 be used for shotpoint number.
    Head.cdp(n)=fread(fId,1,'int32'); %Ensemble number (i.e. CDP, CMP, CRP, etc)
    Head.cdpTrace(n)=fread(fId,1,'int32'); %Trace number within the ensemble � Each ensemble starts with trace number one.
    Head.TraceIdenitifactionCode(n)=fread(fId,1,'int16'); %=1 //Trace identification code: -1=Other; 0=Unknown; 1=Seismic data; 2=Dead; 3=Dummy; 4=Time break; 5=Uphole; 6=Sweep; 7=Timing; 8=Waterbreak; 9=Near-field gun signature; 10=Far-field gun signature; 11=Seismic pressure sensor; 12=Multicomponent seismic sensor - Vertical component; 13=Multicomponent seismic sensor - Cross-line component; 14=Multicomponent seismic sensor - In-line component; 15=Rotated multicomponent seismic sensor - Vertical component; 16=Rotated multicomponent seismic sensor - Transverse component; 17=Rotated multicomponent seismic sensor - Radial component; 18=Vibrator reaction mass; 19=Vibrator baseplate; 20=Vibrator estimated ground force; 21=Vibrator reference; 22=Time-velocity pairs; 23 � N=optional use,  (maximum N = 32,767). Highly recommended for all types of data.
    Head.NSummedTraces(n)=fread(fId,1,'int16'); %Number of vertically summed traces yielding this trace.  (1 is one trace, 2 is two summed traces, etc.)
    Head.NStackedTraces(n)=fread(fId,1,'int16'); %Number of horizontally stacked traces yielding this trace.  (1 is one trace, 2 is two stacked traces, etc.)
    Head.DataUse(n)=fread(fId,1,'int16'); %Data use: 1=Production; 2=Test.
    Head.offset(n)=fread(fId,1,'int32'); %Distance from center of the source point to the center of the receiver group (negative if opposite to direction in which line is shot).
    %////The scalar in Trace Header bytes 69-70 applies to these values. The units are feet or meters as specified in Binary File Header bytes 3255-3256). The Vertical Datum should be defined through a Location Data stanza (see section D-1).
    Head.ReceiverGroupElevation(n)=fread(fId,1,'int32'); %////Receiver group elevation (all elevations above the Vertical datum are positive and below are negative).
     Head.SourceSurfaceElevation(n)=fread(fId,1,'int32'); %!!!changed =-Fish_altitude*ElevationScalar ////Surface elevation at source.
     Head.SourceDepth(n)=fread(fId,1,'int32'); %!!!changed =-Fish_depth*ElevationScalar ////Source depth below surface (a positive number).
    Head.ReceiverDatumElevation(n)=fread(fId,1,'int32'); %////Datum elevation at receiver group.
    Head.SourceDatumElevation(n)=fread(fId,1,'int32'); %////Datum elevation at source.
     Head.SourceWaterDepth(n)=fread(fId,1,'int32'); %!!!changed =-Sea_depth*ElevationScalar ////Water depth at source.
    Head.GroupWaterDepth(n)=fread(fId,1,'int32'); %////Water depth at group.
    Head.ElevationScalar(n)=fread(fId,1,'int16'); %Scalar to be applied to all elevations and depths specified in Trace Header bytes 41-68 to give the real value.  Scalar = 1, +10, +100, +1000, or +10,000.  If positive, scalar is used as a multiplier; if negative, scalar is used as a divisor.
    Head.SourceGroupScalar(n)=fread(fId,1,'int16'); %100-planar, 10000-geographical // Scalar to be applied to all coordinates specified in Trace Header bytes 73-88 and to bytes Trace Header 181-188 to give the real value.  Scalar = 1, +10, +100, +1000, or +10,000.  If positive, scalar is used as a multiplier; if negative, scalar is used as divisor.
    %//The coordinate reference system should be identified through an extended header Location Data stanza (see section D-1). If the coordinate units are in seconds of arc, decimal degrees or DMS, the X values represent longitude and the Y values latitude. A positive value designates east of Greenwich Meridian or north of the equator and a negative value designates south or west.
     Head.SourceX(n)=fread(fId,1,'int32'); %!!!changed Vessel's coordinates // Source coordinate - X.
     Head.SourceY(n)=fread(fId,1,'int32'); %!!!changed Vessel's coordinates // Source coordinate - Y.
     Head.GroupX(n)=fread(fId,1,'int32'); %!!!changed Towbody coordinates // Group coordinate - X.
     Head.GroupY(n)=fread(fId,1,'int32'); %!!!changed Towbody coordinates // Group coordinate - Y.
     Head.CoordinateUnits(n)=fread(fId,1,'int16'); %!!!changed 1-planar, 2-geographical // Coordinate units: 1=Length (meters or feet); 2=Seconds of arc; 3=Decimal degrees; 4=Degrees, minutes, seconds (DMS). Note: To encode +-DDDMMSS bytes 89-90 equal= +-DDD*10^4 + MM*10^2 + SS with bytes 71-72 set to 1; To encode +-DDDMMSS.ss bytes 89-90 equal= +-DDD*10^6 + MM*10^4 + SS*10^2 with bytes 71-72 set to -100.
    Head.WeatheringVelocity(n)=fread(fId,1,'int16'); %Weathering velocity. (ft/s or m/s as specified in Binary File Header bytes 3255-3256).
    Head.SubWeatheringVelocity(n)=fread(fId,1,'int16'); %Subweathering velocity. (ft/s or m/s as specified in Binary File Header bytes 3255-3256)
    %////Time in milliseconds as scaled by the scaled by the scalar specified in Trace Header bytes 215-216.
    Head.SourceUpholeTime(n)=fread(fId,1,'int16'); %////Uphole time at source in milliseconds.
    Head.GroupUpholeTime(n)=fread(fId,1,'int16'); %////Uphole time at group in milliseconds.
    Head.SourceStaticCorrection(n)=fread(fId,1,'int16'); %////Source static correction in milliseconds.
    Head.GroupStaticCorrection(n)=fread(fId,1,'int16'); %////Group static correction in milliseconds.
    Head.TotalStaticApplied(n)=fread(fId,1,'int16'); %////Total static applied in milliseconds. (Zero if no static has been applied).
    Head.LagTimeA(n)=fread(fId,1,'int16'); %////Lag time A � Time in milliseconds between end of 240-byte trace identification header and time break.  The value is positive if time break occurs after the end of header; negative if time break occurs before the end of header.  Time break is defined as the initiation pulse that may be recorded on an auxiliary trace or as otherwise specified by the recording system.
    Head.LagTimeB(n)=fread(fId,1,'int16'); %////Lag Time B � Time in milliseconds between time break and the initiation time of the energy source.  May be positive or negative.
    Head.DelayRecordingTime(n)=fread(fId,1,'int16'); %////Delay recording time � Time in milliseconds between initiation time of energy source and the time when recording of data samples begins.  In SEG Y rev 0 this entry was intended for deep-water work if data recording does not start at zero time.  The entry can be negative to accommodate negative start times (i.e. data recorded before time zero, presumably as a result of static application to the data trace).  If a non-zero value (negative or positive) is recorded in this entry, a comment to that effect should appear in the Textual File Header.
    Head.MuteTimeStart(n)=fread(fId,1,'int16'); %////Mute time � Start time in milliseconds.
    Head.MuteTimeEnd(n)=fread(fId,1,'int16'); %////Mute time � End time in milliseconds.
    Head.ns(n)=fread(fId,1,'int16'); %Number of samples in this trace. Highly recommended for all types of data.
    Head.dt(n)=fread(fId,1,'int16'); %Sample interval in microseconds (�s) for this trace. The number of bytes in a trace record must be consistent with the number of samples written in the trace header.  This is important for all recording media; but it is particularly crucial for the correct processing of SEG Y data in disk files (see Appendix C). If the fixed length trace flag in bytes 3503-3504 of the Binary File Header is set, the sample interval and number of samples in every trace in the SEG Y file must be the same as the values recorded in the Binary File Header.  If the fixed length trace flag is not set, the sample interval and number of samples may vary from trace to trace. Highly recommended for all types of data.
    Head.GainType(n)=fread(fId,1,'int16'); %=1 // Gain type of field instruments: 1=fixed; 2=binary; 3=floating point; 4 � N=optional use.
    Head.InstrumentGainConstant(n)=fread(fId,1,'int16'); %=1 // Instrument gain constant (dB).
    Head.InstrumentInitialGain(n)=fread(fId,1,'int16'); %Instrument early or initial gain (dB).
    Head.Correlated(n)=fread(fId,1,'int16'); %Correlated: 1=no; 2=yes.
     Head.SweepFrequenceStart(n)=fread(fId,1,'uint16').*1e4; %!!!changed Sweep frequency at start kHz*10 //Sweep frequency at start (Hz).
     Head.SweepFrequenceEnd(n)=fread(fId,1,'uint16').*1e4; %!!!changed Sweep frequency at end kHz*10 // Sweep frequency at end (Hz).
     Head.SweepLength(n)=fread(fId,1,'int16')./1e2; %!!!changed length at ms*100 // Sweep length in milliseconds.
    Head.SweepType(n)=fread(fId,1,'int16'); %Sweep type: 1=linear; 2=parabolic; 3=exponential; 4=other.
    Head.SweepTraceTaperLengthStart(n)=fread(fId,1,'int16'); %Sweep trace taper length at start in milliseconds.
    Head.SweepTraceTaperLengthEnd(n)=fread(fId,1,'int16'); %Sweep trace taper length at end in milliseconds.
    Head.TaperType(n)=fread(fId,1,'int16'); %Taper type: 1=linear; 2=cos^2; 3=other.
    Head.AliasFilterFrequency(n)=fread(fId,1,'int16'); %Alias filter frequency (Hz), if used.
    Head.AliasFilterSlope(n)=fread(fId,1,'int16'); %Alias filter slope (dB/octave).
    Head.NotchFilterFrequency(n)=fread(fId,1,'int16'); %Notch filter frequency (Hz), if used.
    Head.NotchFilterSlope(n)=fread(fId,1,'int16'); %Notch filter slope (dB/octave).
    Head.LowCutFrequency(n)=fread(fId,1,'int16'); %Low-cut frequency (Hz), if used.
    Head.HighCutFrequency(n)=fread(fId,1,'int16'); %High-cut frequency (Hz), if used.
    Head.LowCutSlope(n)=fread(fId,1,'int16'); %Low-cut slope (dB/octave).
    Head.HighCutSlope(n)=fread(fId,1,'int16'); %High-cut slope (dB/octave).
    Head.YearDataRecorded(n)=fread(fId,1,'int16'); %Year data recorded � The 1975 standard is unclear as to whether this should be recorded as a 2-digit or a 4-digit year and both have been used.  For SEG Y revisions beyond rev 0, the year should be recorded as the complete 4-digit Gregorian calendar year (i.e. the year 2001 should be recorded as 2001 (7D1)).
    Head.DayOfYear(n)=fread(fId,1,'int16'); %Day of year (Julian day for GMT and UTC time basis).
    Head.HourOfDay(n)=fread(fId,1,'int16'); %Hour of day (24 hour clock).
    Head.MinuteOfHour(n)=fread(fId,1,'int16'); %Minute of hour.
    Head.SecondOfMinute(n)=fread(fId,1,'int16'); %Second of minute.
     Head.TimeBaseCode(n)=fread(fId,1,'int16'); Head.SecondOfMinute(n)=Head.SecondOfMinute(n)+Head.TimeBaseCode(n)./1000;Head.TimeBaseCode(n)=2; %!!!changed Millisecond // Time basis code: 1=Local; 2=GMT (Greenwich Mean Time); 3=Other, should be explained in a user defined stanza in the Extended Textual File Header; 4=UTC (Coordinated Universal Time).
    Head.TraceWeightningFactor(n)=fread(fId,1,'int16'); %Trace weighting factor � Defined as 2^-N volts for the least significant bit.  (N = 0, 1, ..., 32767)
    Head.nChannelCode(n)=fread(fId,1,'int16'); %!!!changed Type of channel -- 1=subbottom, 2=port, 3=stbd
    Head.nShipCourse(n)=fread(fId,1,'uint16'); %!!!changed ���� ����� � �������� * 100
    Head.nShipSpeed(n)=fread(fId,1,'uint16'); %!!!changed �������� ����� � �/� * 100
    Head.nSignal_Period_ms(n)=fread(fId,1,'uint16'); %!!!changed 
    Head.nChannel_Ping_Divider(n)=fread(fId,1,'uint16'); %!!!changed 
    Head.nTowfishPitch(n)=fread(fId,1,'int16'); %!!!changed Stored times 100
    Head.nTowfishRoll(n)=fread(fId,1,'int16'); %!!!changed Stored times 100
    Head.nTowfishHeading(n)=fread(fId,1,'uint16'); %!!!changed Stored times 100 fix:15.03.2002
    Head.nSpeedLog(n)=fread(fId,1,'int16'); %!!!changed Stored times 100
    Head.nlMagX(n)=fread(fId,1,'int32'); %!!!changed ��1*100
    Head.nlMagY(n)=fread(fId,1,'int32'); %!!!changed ��2*100
    Head.nlMagZ(n)=fread(fId,1,'int32'); %!!!changed ��
    Head.nlConductivityFreq(n)=fread(fId,1,'int32'); %!!!changed CTD Conductivity Frequency stored times 10000
    Head.nlTemperatureFreq(n)=fread(fId,1,'int32'); %!!!changed CTD Temperature Frequency stored times 10000
    Head.nlPressureFreq(n)=fread(fId,1,'int32'); %!!!changed CTD Pressure Frequency stored times 10
    Head.nlPressureTemp(n)=fread(fId,1,'int32'); %!!!changed CTD Pressure Temperature stored times 100
    Head.nlCableout(n)=fread(fId,1,'uint16'); %!!!changed ����� ������-������ � ��������� �� 50��  chg 24.04.2005 // 09.02.2007 fix: � ��������� �� 25 ��
    Head.nlSoundVelocity(n)=fread(fId,1,'int32'); %!!!changed �������� ����� � �/� * 100
    Head.nlPressure_dBars(n)=fread(fId,1,'int32'); %!!!changed �������� � ������ * 1000
    Head.nlTemperature(n)=fread(fId,1,'int32'); %!!!changed ����������� � �������� ������� * 100
    Head.nlLayback(n)=fread(fId,1,'int32'); %!!!changed ���������� �� ����������� �� ������� �� ���� � ��
    Head.nEventNumber(n)=fread(fId,1,'uint16'); %!!!changed Event number
    Head.nTowfishSpeed(n)=fread(fId,1,'uint16'); %!!!changed TowfishSpeed * 100 (m/s)
    Head.nSpare(n)=fread(fId,1,'int16'); %!!!changed Spare
    %not used // Head.GeophoneGroupNumberRoll(n)=fread(fId,1,'int16'); %Geophone group number of roll switch position one.
    %not used // Head.GeophoneGroupNumberFirstTraceOrigField(n)=fread(fId,1,'int16'); %Geophone group number of trace number one within original field record.
    %not used // Head.GeophoneGroupNumberLastTraceOrigField(n)=fread(fId,1,'int16'); %Geophone group number of last trace within original field record.
    %not used // Head.GapSize(n)=fread(fId,1,'int16'); %Gap size (total number of groups dropped).
    %not used // Head.OverTravel(n)=fread(fId,1,'int16'); %Over travel associated with taper at beginning or end of line: 1=down (or behind); 2=up (or ahead).
    %not used // Head.cdpX(n)=fread(fId,1,'int32'); %X coordinate of ensemble (CDP) position of this trace (scalar in Trace Header bytes 71-72 applies). The coordinate reference system should be identified through an extended header Location Data stanza (see section D-1).
    %not used // Head.cdpY(n)=fread(fId,1,'int32'); %Y coordinate of ensemble (CDP) position of this trace (scalar in bytes Trace Header 71-72 applies). The coordinate reference system should be identified through an extended header Location Data stanza (see section D-1).
    %not used // Head.Inline3D(n)=fread(fId,1,'int32'); %For 3-D poststack data, this field should be used for the in-line number. If one in-line per SEG Y file is being recorded, this value should be the same for all traces in the file and the same value will be recorded in bytes 3205-3208 of the Binary File Header.
    %not used // Head.Crossline3D(n)=fread(fId,1,'int32'); %For 3-D poststack data, this field should be used for the cross-line number. This will typically be the same value as the ensemble (CDP) number in Trace Header bytes 21-24, but this does not have to be the case.
    %not used // Head.ShotPoint(n)=fread(fId,1,'int32'); %Shotpoint number � This is probably only applicable to 2-D poststack data. Note that it is assumed that the shotpoint number refers to the source location nearest to the ensemble (CDP) location for a particular trace.  If this is not the case, there should be a comment in the Textual File Header explaining what the shotpoint number actually refers to.
    %not used // Head.ShotPointScalar(n)=fread(fId,1,'int16'); %Scalar to be applied to the shotpoint number in Trace Header bytes 197-200 to give the real value.  If positive, scalar is used as a multiplier; if negative as a divisor; if zero the shotpoint number is not scaled (i.e. it is an integer.  A typical value will be -10, allowing shotpoint numbers with one decimal digit to the right of the decimal point).
    %not used // Head.TraceValueMeasurementUnit(n)=fread(fId,1,'int16'); %Trace value measurement unit: -1=Other (should be described in Data Sample Measurement Units Stanza); 0=Unknown; 1=Pascal(Pa); 2=Volts(v); 3=Millivolts(mV); 4=Amperes(A); 5=Meters(m); 6=Meters per second(m/s); 7=Meters per second squared(m/s^2); 8=Newton(N); 9=Watt(W).
    %not used // Head.TransductionConstantMantissa(n)=fread(fId,1,'int32'); %//Transduction Constant � The multiplicative constant used to convert the Data Trace samples to the Transduction Units (specified in Trace Header bytes 211-212).  The constant is encoded as a four-byte, two's complement integer (bytes 205-208) which is the mantissa and a two-byte, two's complement integer (bytes 209-210) which is the power of ten exponent (i.e. Bytes 205-208 * 10**Bytes 209-210).
    %not used // Head.TransductionConstantPower(n)=fread(fId,1,'int16'); %//
    %not used // Head.TransductionUnit(n)=fread(fId,1,'int16'); %Transduction Units � The unit of measurement of the Data Trace samples after they have been multiplied by the Transduction Constant specified in Trace Header bytes 205-210. -1=Other (should be described in Data Sample Measurement Unit stanza, page 36); 0=Unknown; 1=Pascal(Pa); 2=Volts(v); 3=Millivolts(mV); 4=Amperes(A); 5=Meters(m); 6=Meters per second(m/s); 7=Meters per second squared(m/s^2); 8=Newton(N); 9=Watt(W).
    %not used // Head.TraceIdentifier(n)=fread(fId,1,'int16'); %Device/Trace Identifier � The unit number or id number of the device associated with the Data Trace (i.e. 4368 for vibrator serial number 4368 or 20316 for gun 16 on string 3 on vessel 2).  This field allows traces to be associated across trace ensembles independently of the trace number (Trace Header bytes 25-28).
    %not used // Head.ScalarTraceHeader(n)=fread(fId,1,'int16'); %Scalar to be applied to times specified in Trace Header bytes 95-114 to give the true time value in milliseconds.  Scalar = 1, +10, +100, +1000, or +10,000. If positive, scalar is used as a multiplier; if negative, scalar is used as divisor. A value of zero is assumed to be a scalar value of 1.
    %not used // Head.SourceType(n)=fread(fId,1,'int16'); %Source Type/Orientation � Defines the type and the orientation of the energy source.  The terms vertical, cross-line and in-line refer to the three axes of an orthogonal coordinate system.  The absolute azimuthal orientation of the coordinate system axes can be defined in the Bin Grid Definition Stanza (page 27). -1 to -n = Other (should be described in Source Type/Orientation stanza, page 38). 0=Unknown; 1=Vibratory - Vertical orientation; 2=Vibratory - Cross-line orientation; 3=Vibratory - In-line orientation; 4=Impulsive - Vertical orientation; 5=Impulsive - Cross-line orientation; 6=Impulsive - In-line orientation; 7=Distributed Impulsive - Vertical orientation; 8=Distributed Impulsive - Cross-line orientation; 9=Distributed Impulsive - In-line orientation.
    %not used // Head.SourceEnergyDirectionMantissa(n)=fread(fId,1,'int32'); %////Source Energy Direction with respect to the source orientation  � The positive orientation direction is defined in Bytes 217-218 of the Trace Header. The energy direction is encoded in tenths of degrees (i.e. 347.8 is encoded as 3478).
    %not used // Head.SourceEnergyDirectionExponent(n)=fread(fId,1,'int16'); %////
    %not used // Head.SourceMeasurementMantissa(n)=fread(fId,1,'int32'); %//Source Measurement � Describes the source effort used to generate the trace. The measurement can be simple, qualitative measurements such as the total weight of explosive used or the peak air gun pressure or the number of vibrators times the sweep duration.  Although these simple measurements are acceptable, it is preferable to use true measurement units of energy or work. The constant is encoded as a four-byte, two's complement integer (bytes 225-228) which is the mantissa and a two-byte, two's complement integer (bytes 209-230) which is the power of ten exponent (i.e. Bytes 225-228 * 10**Bytes 229-230).
    %not used // Head.SourceMeasurementExponent(n)=fread(fId,1,'int16'); %//
    %not used // Head.SourceMeasurementUnit(n)=fread(fId,1,'int16'); %Source Measurement Unit � The unit used for the Source Measurement, Trace header bytes 225-230. -1 = Other (should be described in Source Measurement Unit stanza, page 39); 0=Unknown; 1=Joule(J); 2=Kilowatt(kW); 3=Pascal(Pa); 4=Bar(Bar); 4=Bar-meter(Bar-m); 5=Newton(N); 6=Kilograms(kg).
    %not used // Head.UnassignedInt1(n)=fread(fId,1,'int32'); %Unassigned � For optional information.
    %not used // Head.UnassignedInt2(n)=fread(fId,1,'int32'); %Unassigned � For optional information.
    %===End Trase Header Read
    %===Begin Trase Data Read
    LTrace=Head.ns(n);
    %not used // if ~FL, LTrace=Head.ns(n); end;
    a=fread(fId,LTrace,cForm); 
    switch SgyHead.FDataSampleFormat, %format apply
        case 1, %1=4-byte IBM floating-point
            a1=uint32(a); a=(1-2.*double(bitget(a1,32))).*pow2(double(bitand(a1,uint32(16777215)))./16777216,4.*(double(bitshift(bitand(a1,uint32(2130706432)),-24))-64));
            if errIbmFl, errIbmFl=~any(bitand(a1,1));end;
        case 4, %4=4-byte fixed-point with gain (obsolete)
            a1=uint32(a); a=(1-2.*double(bitget(a1,16))).*pow2(double(bitand(a1,uint32(32767))),double(bitshift(bitand(a1,uint32(16711680)),-16)));
            if errObsFl, errObsFl=~any(bitand(a1,4278190080));end;
    end;
    Data(1:LTrace,n)=a;
    %===End Trase Data Read
    %if ~mod(n,5000), disp(['Trace: ',num2str(n)]);end;
end;
if ftell(fId)~=fSize, error(['Error gSgyRead: last pointer=' num2str(ftell(fId)) ', but File Size=' num2str(ftell(fSize)) '.']);end;
fclose(fId);
if ~errIbmFl, disp('Warning gSgyRead: There is bitN7 set in IBM formated number. Possible, format not correct .');end;
if ~errObsFl, disp('Warning gSgyRead: There are bits from byteN1 set in Obsolete formated number. Possible, format not correct .');end;
%==End File reading

%mail@ge0mlib.com 05/02/2021