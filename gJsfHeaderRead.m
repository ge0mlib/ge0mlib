function JsfHead=gJsfHeaderRead(fName,flStat)
%Read JsfHead structure (16-Byte Message Header) from *.jsf file (0004824_REV_1.20 used).
%function JsfHead=gJsfHeaderRead(fName,flStat), where
%JsfHead - JsfHead structure;
%fName - the target file name;
%flStat - flag for statistics display (1 or 0).
%JsfHead include the next addition fields: JsfHead.Descript, JsfHead.fName, JsfHead.RSeek, JsfHead.ROnFlag.
%Example: JsfHead=gJsfHeaderRead('c:\temp\1.jsf',1);

Descript.MessageType.Code=[40,80,82,86,181,182,426,428,1009,1011,1065,2000,2002,2020,2040,2043,2060,2071,2080,2090,2091,2100,2101,2111,3000,3001,3002,3003,3004,3005,3041,3060,3061,3062,9001,9002,9003]';
Descript.MessageType.Text={'0040=System Status Message (private)','0080=Sonar Data Message','0082=Side Scan Data Message','0086=4400-SAS Processed Data',...
    '0181=Navigation Offset','0182=System Information Message / Configuration','0426=File Timestamp Message','0428=File Padding Message',...
    '1009=Array Information (private)','1011=Bathymetric Array Calibration (private)','1065=Sonar Performance Counter (private)',...
    '2000=Equip Serial Ports Raw Data','2002=NMEA String','2020=Pitch Roll Data','2040=Miscellaneous Analog Sensors (private)','2043=AnalogIO Data (not public)','2060=Pressure Sensor Data','2071=Reflection Coefficient','2080=Doppler Velocity Log Data (DVL)','2090=Situation Message','2091=Situation Comprehensive Message (version 2)',...
    '2100=Cable Counter Data Message','2101=Kilometer of Pipe Data','2111=Container Timestamp Message',...
    '3000=BathymetricDataMessageType','3001=AttitudeMessageType','3002=PressureMessageType','3003=AltitudeMessageType','3004=PositionMessageType','3005=StatusMessageType',... %used for interferometer ET-6205
    '3041=BathymetricParameterPublicMessage','3060=Internal Bathymetric (private)','3061=Internal Bathymetric (private)','3062=Internal Bathymetric (private)',...
    '9001=Discover-2 General Prefix Message','9002=Discover-2 Situation Data','9003=Discover-2 Acoustic Prefix Message'}'; %used for Discover-2 system
Descript.Subsystem.Code=[0,20,21,22,40,41,42,70,71,72,100,101,102,120]';
Descript.Subsystem.Text={'0=Sub-bottom','20=Single frequency sidescan data or Lower Frequency Dual Side Scan (75 or 120kHz typical)','21=Higher Frequency Dual Side Scan (410kHz typical)','22=Very High frequency data of a tri-frequency side scan',...
    '40=Bathymetric low frequency data of a dual side scan','41=Bathymetric high frequency data of a dual side scan','42=Bathymetric very high frequency of a tri-frequency','70=Bathymetric motion tolerant, low frequency dual side scan',...
    '71=Bathymetric motion tolerant high frequency dual side scan','72=Bathymetric motion tolerant very high frequency tri-frequency','100=Raw Serial/UDP/TCP data','101=Parsed Serial/UDP/TCP data','102=Miscellaneous Analog Sensors (Mess2040)',...
    '120=Gap Filler data'}';
Descript.ChannelMulti.Code=[0,1]';
Descript.ChannelMulti.Text={'0=Port','1=Starboard'}';
Descript.SystemTypeNumber.Code=[1,2,4,5,6,7,11,14,16,17,18,19,20,21,23,24,25,27,30,31,32,33,34,35,36,37,38,39,51,128];
Descript.SystemTypeNumber.Text={'1=2xxx  Series,  Combined  Sub-Bottom  /  Side  Scan  with SIB Electronics','2=2xxx  Series,  Combined  Sub-Bottom  /  Side  Scan  with FSIC Electronics','4=4300-MPX (Multi-Ping)','5=3200-XS,Sub-Bottom Profiler wit h AIC Electronics',...
    '6=4400-SAS, 12-Channel Side Scan','7=3200-XS, Sub Bottom Profiler with SIB Electronics','11=4200 Limited Multipulse Dual Frequency Side Scan','14=3100-P, Sub Bottom Profiler','16=2xxx Series, Dual Side Scan with SIB Electronics','17=4200 Multipulse Dual Frequency Side Scan',...
    '18=4700 Dynamic Focus','19=4200 Dual Frequency Side Scan','20=4200 Dual Frequency non Simultaneous Side Scan','21=2200-MP Combined Sub-Bottom / Dual Frequency Multipulse','23=4600 Multipulse Bathymetric System','24=4200 Single Frequency Dynamically Focused Side Scan',...
    '25=4125 Dual Frequency Side Scan','27=4600 Monopulse Bathymetric System','30=4200 MPX Coupled in MP mode','31=2205 Sub-Bottom with SAIB / COMSON Electronics','32=2205 Dual Side Scan with SAIB / COMSON Electronics',...
    '33=2205 Side Scan with SAIB / COMSON Electronics','34=2205 Sub-Bottom and Side Scan with SAIB / COMSON Electronics','35=2205 Sub-Bottom and Side Scan SAIB / COMSON Electronics',...
    '36=2205 Dual Frequency Side Scan, Sub-Bottom with Bathy low and SAIB/COMSON Electronics','37=2205 Dual Frequency Side Scan, Sub-Bottom with  Bathy high and SAIB/COMSON Electronics',...
    '38=2205 Dual Frequency Side Scan with Bathy low and SAIB/COMSON Electronics','39=2205 Dual Frequency Side Scan with Bathy high and SAIB/COMSON Electronics','51=4205 Tri Frequency Side Scan','128=4100, 272 /560A Side Scan'};

[fId, mes]=fopen(fName,'r');if ~isempty(mes), error(['gJsfReadHeader: ' mes]);end;
%===Begin Calc Num of Records
nRec=0;finfo=dir(fName);fSize=finfo.bytes;
while fSize>ftell(fId),
    nRec=nRec+1;
    face=fread(fId,1,'uint16');if face~=5633, error('Error gFJsfReadHeader: Marker for the Start of JstHeader~=0x1601');end;
    fseek(fId,10,'cof');
    SizeFollowingMessage=fread(fId,1,'uint32'); %Size of following Message in Bytes
    fseek(fId,SizeFollowingMessage,'cof'); %goto block end
end;
%===End Calc Num of Records
%===Begin JsfHeader Record Allocate
JsfHead=struct('Descript',Descript,'fName',fName,'HMarkerForStart',nan(1,nRec),'HVersionOfProtocol',nan(1,nRec),'HSessionIdentifier',nan(1,nRec),'HMessageType',nan(1,nRec),'HCommandType',nan(1,nRec),...
    'HSubsystem',nan(1,nRec),'HChannelMulti',nan(1,nRec),'HSequenceNumber',nan(1,nRec),'HReserved',nan(1,nRec),'HSizeFollowingMessage',nan(1,nRec),...
    'RSeek',nan(1,nRec),'ROnFlag',nan(1,nRec));
%===End JsfHeader Record Allocate
fseek(fId,0,'bof');
for m=1:nRec,
    %===Begin JsfHeader Record Read
    JsfHead.HMarkerForStart(m)=fread(fId,1,'uint16'); %0-1// Marker for the Start of Header = 0x1601
    JsfHead.HVersionOfProtocol(m)=fread(fId,1,'uint8'); %2// Version of Protocol used
    JsfHead.HSessionIdentifier(m)=fread(fId,1,'uint8'); %3// Session Identifier
    JsfHead.HMessageType(m)=fread(fId,1,'uint16'); %4-5// Message Type
    JsfHead.HCommandType(m)=fread(fId,1,'uint8'); %6// Command Type. 2=Normal data source.
    JsfHead.HSubsystem(m)=fread(fId,1,'uint8'); %7// Subsystem for a Multi-System Device. Common  subsystem assignments are as follows: Sub-bottom data - 0; Single frequency side scan data - 20; Lower frequency data of a dual frequency side scan - 20; Higher frequency data of a dual frequency side scan - 21; Higher frequency data of a tri-frequency side scan - 22; Raw serial/UDP/TCP data - 100 (v.1.20); Parsed serial/UDP/TCP data - 101 (v1.20); Raw UDP data - 103 (v.1.18);Parsed UPD data  - 104 (v1.18).
    JsfHead.HChannelMulti(m)=fread(fId,1,'uint8'); %8// Channel for a Multi-Channel Subsystem For Side Scan Subsystems; 0 = Port; 1 = Starboard; For Serial Ports: Port #. Single channel Sub-Bottom systems channel is 0.
    JsfHead.HSequenceNumber(m)=fread(fId,1,'uint8'); %9// Sequence Number
    JsfHead.HReserved(m)=fread(fId,1,'uint16'); %10-11// Reserved
    JsfHead.HSizeFollowingMessage(m)=fread(fId,1,'uint32'); %12-15// Size of following Message in Bytes
    JsfHead.RSeek(m)=ftell(fId); %Message Seeker
    JsfHead.ROnFlag(m)=1; %On/Off flag
    %===End JsfHeader Record Read
    fseek(fId,JsfHead.HSizeFollowingMessage(m),'cof'); %goto block end
end;
fclose(fId);

%===Begin Statistics display
if flStat,
    a1=sparse(JsfHead.HMessageType+1,ones(1,nRec),ones(1,nRec));a1Mess=find(a1)-1;a1Num=nonzeros(a1);
    for n=1:size(a1Mess,1),
        if any(JsfHead.Descript.MessageType.Code==a1Mess(n)), s=JsfHead.Descript.MessageType.Text{JsfHead.Descript.MessageType.Code==a1Mess(n)};
        else s=[num2str(a1Mess(n),'%04d') '=Not Defined'];end;
        fprintf('Mess: %s, Num: %d ',s,a1Num(n));
        L=find(JsfHead.HMessageType==a1Mess(n));L2=size(L,2);
        a2=sparse(JsfHead.HSubsystem(L)+1,ones(1,L2),ones(1,L2));a2Mess=find(a2)-1;a2Num=nonzeros(a2);
        for nn=1:size(a2Mess,1),
            fprintf('[ Subs: %d, Num: %d;',a2Mess(nn),a2Num(nn));
            L=find((JsfHead.HMessageType==a1Mess(n))&(JsfHead.HSubsystem==a2Mess(nn)));L2=size(L,2);
            a3=sparse(JsfHead.HChannelMulti(L)+1,ones(1,L2),ones(1,L2));a3Mess=find(a3)-1;a3Num=nonzeros(a3);
            fprintf(' Chan:');fprintf(' %d',a3Mess);fprintf(', Num:');fprintf(' %d',a3Num);fprintf(' ]');
        end;
        fprintf('\n');
    end;
end;
%===End Statistics display

%mail@ge0mlib.com 03/08/2023