function CC=gLogCableCounterRead(fName,Form)
%Read CableCounter structure from files created by gComLog/gComCC program.
%function CC=gLogCableCounterRead(fName,Form), where
%fName - reading file name or files name or folder name with files (last name's symbol must be '\');
%Form - Data Message Format: gLogCMax,gLogCMaxRaw,gLogHYTek,gComCC,gLogMKII;
%CC - Cable Counter structure:
%CC.CompDay - computer day from LOG-file name;
%CC.CompTime - computer time, second per day;
%CC.CableLen - cable length, m.
%Format logging Examples:
%C-Max (0x0D line delimiter): ~36019588,+0033m
%C-Max_Raw (0x0D or 0x0D 0x0A line delimiter): ~70634035,+0059
%T_count (0x0D line delimiter): ~40618534,CL-0002m
%gLogMKII (20chars+0x0D line delimiter, "spase" added; Length "L" means first): ~55245049,L=6.9m    <x0D>~55245564,S=0.0m/m  <x0D>
%gComCC (0x0D 0x0A line delimiter): ~36019588,0033
%Example: CC=gLogCableCounterRead('c:\temp\mag\CC\',2);plot(CC.CompTime(:)-CC.CompTime(1),CC.LenCC,'.');

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end; %fName=sortrows(fName);
CC=struct('CompDay',[],'CompTime',[],'CableLen',[]);CCCode=[];CableCode=[]; %CCCode is char for data nature identification (see 'gLogMKII')
for n=1:size(fName,1),
    fNameN=deblank(fName(n,:));
    %disp(fNameN);
    [fId, mes]=fopen(fNameN,'r');if ~isempty(mes), error(mes);end;
    L=find(fNameN=='\');fNameDay=fNameN(L(end)+1:L(end)+8);
    CompDay1=datenum(str2double(fNameDay(1:4)),str2double(fNameDay(5:6)),str2double(fNameDay(7:8)));
    switch Form,
        case 'gLogCMax',
            C=textscan(fId,'%c %8f %c %5f %c','Delimiter','','EndOfLine','\r');
            if ~all(C{1}(:)==C{1}(1)), error('Delemiter 1 (gComLog) is not uniform');end;
            if ~all(C{3}(:)==C{3}(1)), error('Delemiter 2 (gComLog) is not uniform');end;
            if ~all(C{5}=='m'), error('m - litter is not uniform');end;
            CompTime=C{2}'./1000;CompDay=repmat(CompDay1,size(CompTime));CableLen=C{4}';
        case 'gLogCMaxRaw'
            C=textscan(fId,'%c %8f %c %5f','Delimiter','','EndOfLine','\r');
            if ~all(C{1}(:)==C{1}(1)), error('Delemiter 1 (gComLog) is not uniform');end;
            if ~all(C{3}(:)==C{3}(1)), error('Delemiter 2 (gComLog) is not uniform');end;
            CompTime=C{2}'./1000;CompDay=repmat(CompDay1,size(CompTime));CableLen=C{4}';
        case 'gLogHYTek',
            C=textscan(fId,'%c %8f %c %2c %5f %c','Delimiter','','EndOfLine','\r');
            if ~all(C{1}(:)==C{1}(1)), error('Delemiter 1 (gComLog) is not uniform');end;
            if ~all(C{3}(:)==C{3}(1)), error('Delemiter 2 (gComLog) is not uniform');end;
            if ~(all(C{4}(:,1)=='C')&&all(C{4}(:,2)=='L')), error('CL - litters is not uniform');end;
            if ~all(C{6}=='m'), error('m - litter is not uniform');end;
            CompTime=C{2}'./1000;CompDay=repmat(CompDay1,size(CompTime));CableLen=C{5}';
        case 'gComCC',
            C=textscan(fId,'%c %8f %c %4f','Delimiter',',','EndOfLine','\r\n');
            if ~all(C{1}(:)==C{1}(1)), error('Delemiter 1 (gComCC) is not uniform');end;
            if ~all(C{3}(:)==C{3}(1)), error('Delemiter 2 (gComCC) is not uniform');end;
            CompTime=C{2}'./1000;CompDay=repmat(CompDay1,size(CompTime));CableLen=C{4}';
        case 'gLogMKII', % ~55245049,L=6.9m    <x0D>~55245564,S=0.0m/m  <x0D>
            C=textscan(fId,'%c %8f %c %c %c %f %s','Delimiter','','EndOfLine','\r');
            if ~all(C{1}(:)==C{1}(1)), error('Delemiter 1 (gComCC) is not uniform');end;
            if ~all(C{3}(:)==C{3}(1)), error('Delemiter 2 (gComCC) is not uniform');end;
            if ~all(C{5}(:)=='='), error('Message symbol 2 is not ''=''');end;
            CompTime=C{2}'./1000;CompDay=repmat(CompDay1,size(CompTime));CableLen=C{6}';CableCode=C{4}';
        otherwise, error('Cable counter Format not found');
    end;
    CC.CompDay=[CC.CompDay CompDay];CC.CompTime=[CC.CompTime CompTime];CC.CableLen=[CC.CableLen CableLen];CCCode=[CCCode CableCode];
    fclose(fId);
end;
%CCCode processing
switch Form,
    case 'gLogMKII',
        a=find(~diff(CCCode))+1;if ~isempty(a),CC.CompDay(a)=[];CC.CompTime(a)=[];CC.CableLen(a)=[];CCCode(a)=[];warning('L and S symbols interlacing was detected and removed');end;
        if CCCode(1)~='L',CC.CompDay(1)=[];CC.CompTime(1)=[];CC.CableLen(1)=[];CCCode(1)=[];end;
        if CCCode(end)~='S',CC.CompDay(end)=[];CC.CompTime(end)=[];CC.CableLen(end)=[];CCCode(end)=[];end;
        CC.CompDay=CC.CompDay(1:2:end);CC.CompTime=CC.CompTime(1:2:end);CC.CableSpd=CC.CableLen(2:2:end);CC.CableLen=CC.CableLen(1:2:end);
end;
%delete time repeat
a=round(mean(CC.CompDay));TimeZ=(CC.CompDay-a).*86400+CC.CompTime;
L=find(diff(TimeZ)==0);CC.CompDay(L)=[];CC.CompTime(L)=[];CC.CableLen(L)=[];

%mail@ge0mlib.com 13/07/2020