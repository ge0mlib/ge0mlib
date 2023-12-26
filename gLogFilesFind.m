function fNameList=gLogFilesFind(rootD,TimeS,TimeF)
%Create FilesList using start and final date/time (for files created by gComLog program).
%function fName=gLogFilesFind(rootD,TimeS,TimeE), where
%rootD - root folder with files were created by gComLog program; file names format: YYYYMMDD_HHMMSS.extension (for example 20170909_040000.imu);
%TimeS - start time in format [YYYY MM DD HH MM SS] (for example [2017 05 12 13 40 00]);
%TimeE - final time in format [YYYY MM DD HH MM SS];
%fNameList - files list; the time includes interval with TimeS and TimeF.
%Example: fNam=gLogFilesFind('d:\gLogZ\Imu\',[2017 09 10 00 00 00],[2017 09 10 05 12 15]);Tss1=gLogTss1Read(fNam);

if rootD(end)~='\', rootD=[rootD '\'];end;
dz=dir(rootD);dz([dz.isdir])=[];fName=char(dz.name);

Dx=gNavTime2Time('YMD2Dx',str2num(fName(:,1:8)));Sd=gNavTime2Time('HMS2Sd',str2num(fName(:,10:15)));
DxS=datenum(TimeS(1),TimeS(2),TimeS(3));SdS=TimeS(4).*3600+TimeS(5).*60+TimeS(6);
DxF=datenum(TimeF(1),TimeF(2),TimeF(3));SdF=TimeF(4).*3600+TimeF(5).*60+TimeF(6);
L=find((Dx>=DxS)&(Sd>=SdS)&(Dx<=DxF)&(Sd<=SdF));

if L(1)~=1, nS=L(1)-1;else nS=1;end;
if L(end)~=length(Dx), nF=L(end)+1;else nF=L(end);end;
tmp=fName(nS:nF,:);
fNameList=[repmat(rootD,size(tmp,1),1) tmp];

%mail@ge0mlib.ru 15/09/2017