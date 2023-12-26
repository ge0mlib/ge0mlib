function flOut=gUhrGeoSense_DirRenameShotId2FFID(DirName,fLogName)
%Rename Seg-d files in DirName, named by SHOTID to FFID. Get data from Station Log-file was created Multi-Trace Data Acquisition software (GEO Marine Survey Systems) for MultiTrace station.%function Log=gUhrGeoSense_DirRenameShotId2FFID(DirName,fLogName), where
%DirName - folder with Seg-d files, named using SHOTID;
%fLogName - Log-file name, will used to create structure with fields: FFID, SHOTID, LINE, SN, TS, CompDay, CompTime1, GpsE, GpsN, FIX, GpsDay, GpsTime, CompDay2, CompTime2;
%Log file format example >> FFID,455, SHOTID,6621, LINE,130, SN,18661018, TS,800.0, 25/08/2017 12:55:24.203 UTC,VESSEL_X,648047.970000000, VESSEL_Y,8163329.690000000, VESSEL_FIX,455.000000000, VESSEL_HDG,125510.220000000, VESSEL_AZI,0.000000000, VESSEL_FEA,0.000000000, VESSEL_SPEED,393308.209639116, VESSEL_GPSTIME,25/08/2017 12:55:24.166 UTC,
%Example: flOut=gUhrGeoSense_DirRenameShotId2FFID('c:\temp\Day1\18661018\');

Log=gUhrGeoSense_StreamerLogRead(fLogName); %read Log
if DirName(end)~='\',DirName=[DirName '\'];end;
dz=dir(DirName);dz([dz.isdir])=[];fName=[repmat(DirName,length(dz),1) char(dz.name)]; %read Seg-d Dir
mkdir(DirName,'Not_In_Log');

flOut=1;Log.FFIDExist=false(size(Log.SHOTID));
for n=1:size(fName,1),
    L=find(fName(n,:)=='_');ShotId=str2num(fName(n,L(end)+1:L(end)+6));LL=find(ShotId==Log.SHOTID);L1=find(fName(n,:)=='\');
    if ~isempty(LL),
        if ~all(size(LL)==1), error(['There are several ShotId:' num2str(ShotId) ' in Log line numbers:' num2str(LL)]);end;
        Log.FFIDExist(LL)=true;
        fNameNew=[fName(n,1:L1(end)) num2str(Log.FFID(LL),'%06d') '.segd'];
        [fSt,fMs]=movefile(fName(n,:),fNameNew);
        if fSt~=1, warning([fMs ';  fName:' fName(n,:)]);flOut=0;end;
    else
        disp(['Mess: SHOTID ' ShotId 'not find in Log and moved to Not_In_Log folder;']);
        [fSt,fMs]=movefile(fName(n,:),[DirName 'Not_In_Log' fName(n,L1(end):end)]);
        if fSt~=1, warning([fMs ';  fName:' fName(n,:)]);flOut=0;end;
   end;
end;

for n=1:size(Log.FFID,1),
    if ~Log.FFIDExist(n), disp(['Mess: FFID/FIX/SHOTID ' num2str(Log.FFID(n)) '/' num2str(Log.FIX(n)) '/' num2str(Log.SHOTID(n)) ' are presented in Log, but not find in files;']);end;
    if (n~=1)&&(Log.FFID(n)-Log.FFID(n-1)~=1),disp(['Mess: Miss(Over)FFID in Log FFID/FIX/SHOTID ' num2str(Log.FFID(n-1)) '/' num2str(Log.FIX(n-1)) '/' num2str(Log.SHOTID(n-1)) ' to ' num2str(Log.FFID(n)) '/' num2str(Log.FIX(n)) '/' num2str(Log.SHOTID(n)) ';']);end;
    if (n~=1)&&(Log.FIX(n)-Log.FIX(n-1)~=1),disp(['Mess: Miss(Over)FIX in Log FFID/FIX/SHOTID ' num2str(Log.FFID(n-1)) '/' num2str(Log.FIX(n-1)) '/' num2str(Log.SHOTID(n-1)) ' to ' num2str(Log.FFID(n)) '/' num2str(Log.FIX(n)) '/' num2str(Log.SHOTID(n)) ';']);end;
end;

%mail@ge0mlib.com 23/09/2017