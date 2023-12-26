function Tss1=gLogTss1Read(fName)
%Read Tss1 structure from files created by gComLog program.
%function Tss1=gFLogTss1Read(fName), where
%fName - reading file name or files name or folder name with files (last name's symbol must be '\');
%Tss1 - Tss1 structure:
%Tss1.CompDay - computer day from LOG-file name;
%Tss1.CompTime - computer time;
%Tss1.MotionLAH - (HorizA) horizontal acceleration in cm/s2;
%Tss1.MotionLAZ - (VertA) vertical acceleration in cm/s2;
%Tss1.MotionHeave - heave in m;
%Tss1.MotionF - status flag (Field 06);
%Tss1.MotionRoll - roll in degree;
%Tss1.MotionPitch - pitch in degree.
%Example: Data=gFLogTss1Read('c:\temp\20160408_104958.mtn');plot((Tss1.CompTime(:)-Tss1.CompTime(1))./100,Tss1.Heave);
%
%TSS1 PACKET :XXAAAA_MHHHHQMRRRR_MPPPPZZ
%--------------------------------------------------------------------------------------
%Field	Format	Description                 Range                       Units
%01     “:”     start of packet character	“:”                          3A Hex
%02     XX      horizontal acceleration     0 to 9.81 m/s2              3.83 cm/s2
%03     AAAA	vertical acceleration       –20.48 to +20.47 m/s2       0.0625 cm/s2
%04     _       space character             “ “                         20 Hex
%05     MHHHH	heave                       –99 to +99 m                0.01 m
%06     Q       status flag                 “u,U,g,G,H,f,F”, “?”, “ “     see note
%07     MRRRR	roll                        –99 to +99 °                0.01 °
%08     _       space character             “ “                         20 Hex
%09     MPPPP	pitch                       –99 to +99 °                0.01 °
%10     ZZ      termination characters      <CR><LF>                    0D Hex 0A Hex
%------------------------------------------------------------------------------------
%Format Examples
%:003D50 0000 1482 0085
%:003D4E 0000 -1490 0065
%:003D51 -0005 -0037 0074
%The TSS1 data string contains 27 characters in five data fields.
%A data status flag is included in the packet. This status flag can be modified by the user to allow compatibility with other Teledyne TSS products.
%A heading status flag is also included in the packet identifying the compass status. This status flag can also be modified by the user to allow compatibility with other Teledyne TSS products. Refer to Table 6-24 below for flag details.
%The acceleration fields contain ASCII-coded hexadecimal values: Horizontal acceleration uses units of 3.83cm/s² in the range zero to 9.81m/s²; Vertical acceleration uses units of 0.0625cm/s² in the range –20.48 to +20.48m/s².
%Motion measurements contained in the data string are in real time, valid from the instant when the system transmits the packet start character (‘:’). Motion measurements include ASCII-coded decimal values.
%Heave measurements are in cm in the range –99.99 to +99.99 metres. Positive heave is above datum.
%Roll and pitch measurements are in degrees in the range –90.00° to +90.00°. Positive roll is port-side up, starboard down. 
%Positive pitch is bow up, stern down.
%=========================================
%The primary coordinate system:
%^ x(forward)
%|
%o---> y(right)
%z(up)
%Where Zm for Heading, Ym for Pitch (Left rotation sign is +), Xm for Roll (Left rotation sign is +).
%Warning! Pitch,Roll,Heading must be re-signed to Right Rotation (usually Roll need to change sign).
%========================================
%Status flag: “U”,”G”,”H”,”F” indicate a settled condition; “u”,”g”,”h”,”f” are given during the 3 minutes settling period. “U” is unaided mode,”G” is GPS aided mode, ”H” is heading aided mode, ”F” is full aided mode. For TSS 320 messages, the status field is used to indicate heave quality control: space = OK, “?” = FAIL.

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end; %fName=sortrows(fName);
Tss1=struct('CompDay',[],'CompTime',[],'MotionLAH',[],'MotionLAZ',[],'MotionHeave',[],'MotionF',[],'MotionRoll',[],'MotionPitch',[]);
for nn=1:size(fName,1),
    fNameN=deblank(fName(nn,:));
    %disp(fNameN);
    [fId, mes]=fopen(fNameN,'r');if ~isempty(mes), error(mes);end;
    L=find(fNameN=='\');fNameDay=fNameN(L(end)+1:L(end)+8);
    C=textscan(fId,'%c %8f %c %c %2c %4c %5f %c %5f %5f','Delimiter','','EndOfLine','\r\n');
    fclose(fId);clear fId;
    if ~all(C{1}(:)==C{1}(1)), error('Delemiter 1 (gComLog) is not uniform');end;
    if ~all(C{3}(:)==C{3}(1)), error('Delemiter 2 (gComLog) is not uniform');end;
    if ~all(C{4}(:)==':'), error('Error gFLogTss1Read: TSS1 Field_01 is not '':''');end;
    %Calc fields: CompTime,GpsDay
    CompTime=C{2}'./1000;
    CompDay1=datenum(str2double(fNameDay(1:4)),str2double(fNameDay(5:6)),str2double(fNameDay(7:8)));CompDay=repmat(CompDay1,size(CompTime));
    Tss11=struct('CompDay',CompDay,'CompTime',CompTime,'MotionLAH',hex2dec(C{5})'.*3.83,'MotionLAZ',hex2dec(C{6})'.*0.0625,'MotionHeave',C{7}'.*0.01,'MotionF',C{8}','MotionRoll',C{9}'.*0.01,'MotionPitch',C{10}'.*0.01);
    if any(length(Tss11.CompDay)~=[length(Tss11.CompTime) length(Tss11.MotionLAH) length(Tss11.MotionLAZ) length(Tss11.MotionHeave) length(Tss11.MotionF) length(Tss11.MotionRoll) length(Tss11.MotionPitch)]), error(['Bad structure for file ' fNameN]);end;
    Tss1=gZRowAppend(Tss1,Tss11,size(Tss1.CompDay,2));
end;

%mail@ge0mlib.com 15/09/2017