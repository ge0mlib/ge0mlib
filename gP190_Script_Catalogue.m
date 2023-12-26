%script gP190_Script_Catalogue;
%Start script with command >>> {'Xtf','c:\ET4200_xtf\'};gTraining01_Catalogue; <<< or the same.
%Create P1/90, coordinate catalogue and script with trackplots for AutoCAD using folder contained Xtf-files.
%The link to Xtf-files example: http://ge0mlib.com/g/example/ET4200_xtf.zip
%The link to Training detailed description: http://ge0mlib.com/g/gTraining01_Catalogue.pdf

gKey=ans;
if strcmp(gKey{1},'Xtf'), %start processing for Xtf-files
    %Read root folder
    try RootDir=gKey{2};catch,RootDir='c:\temp\ET4200_xtf\';end;
    %Read Xtf-files to Dataset
    NavS=struct('TargCode',2);
    NavP=struct('EllipParam',[6378137 0.0818191908],'ProjParam',[0 141 0.9996 500000 0], 'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',6);
    [XtfHead,Head,Data]=gXtf000DatasetImport(RootDir,'',[],0,[],[],'HPingNumber','HShipYcoordinate', 'HShipXcoordinate', NavS,NavP,[]);
    %Create P1/90 files
    NavOutGeog=struct('EllipParam',[6378137 0.0818191908],'ProjParam',[0 141 0.9996 500000 0], 'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',2);
    NavOutProj=struct('EllipParam',[6378137 0.0818191908],'ProjParam',[0 141 0.9996 500000 0], 'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',1);
    [P190Head,PHead]=gP190DTEN2P190(XtfHead,Head,NavP,NavOutGeog,NavOutProj,[RootDir 'ReadMe\P190_Header.txt'],'S',('   ')','1','1',' ',' ');
    gP190Write([RootDir 'ReadMe\'],P190Head,PHead,1,'NNMMM');
    %Create coordinates catalogue with step 10 pings
    gP1902Cat(P190Head,PHead,[RootDir 'ReadMe\gTraining01_Survey_Catalogue.txt'],'gTraining01_Survey',10);
    %Create and draw polyline-structure
    PL=gP1902PL(PHead,'.-b');gMapPLDraw(100,PL);axis equal; gMapTickLabel(100,'%8.1f',8);
    %Create AutoCAD script with trackplots
    gMapPL2AcadExport([RootDir 'ReadMe\gTraining01_Survey_Trackplot.scr'],PL,[7 0 0 0 3],[1 1000],[6 0 5000 0],2,1,1);
end;
if strcmp(gKey{1},'Jsf'), %start processing for Jsf-files
    %Read root folder
    try RootDir=gKey{2};catch,RootDir='c:\temp\ET4200_jsf\';end;
    %Read Jsf-files to Dataset
    NavS=struct('TargCode',2);
    NavP=struct('EllipParam',[6378137 0.0818191908],'ProjParam',[0 141 0.9996 500000 0], 'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',6);
    [JsfHead,Head,Data]=gJsf0080DatasetImport(RootDir,'',[],0,20,[],[],'PingNumber',NavS,NavP,[]);
    %Create P1/90 files
    NavOutGeog=struct('EllipParam',[6378137 0.0818191908],'ProjParam',[0 141 0.9996 500000 0], 'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',2);
    NavOutProj=struct('EllipParam',[6378137 0.0818191908],'ProjParam',[0 141 0.9996 500000 0], 'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',1);
    [P190Head,PHead]=gP190DTEN2P190(JsfHead,Head,NavP,NavOutGeog,NavOutProj,[RootDir 'ReadMe\P190_Header.txt'],'S',('   ')','1','1',' ',' ');
    gP190Write([RootDir 'ReadMe\'],P190Head,PHead,1,'NNMMM');
    %Create coordinates catalogue with step 10 pings
    gP1902Cat(P190Head,PHead,[RootDir 'ReadMe\gTraining01_Survey_Catalogue.txt'],'gTraining01_Survey',10);
    %Create and draw polyline-structure
    PL=gP1902PL(PHead,'.-b');gMapPLDraw(101,PL);axis equal; gMapTickLabel(101,'%8.1f',8);
    %Create AutoCAD script with trackplots
    gMapPL2AcadExport([RootDir 'ReadMe\gTraining01_Survey_Trackplot.scr'],PL,[7 0 0 0 3],[1 1000],[6 0 5000 0],2,1,1);
end;
if strcmp(gKey{1},'Sgy'), %start processing for Sgy-files
    %Read root folder
    try RootDir=gKey{2};catch,RootDir='c:\temp\ET3200SX512i_sgy\';end;
    %Read Sgy-files to Dataset
    [SgyHead,Head,Data]=gSgyDatasetImport(RootDir,'',[],[],[],'TraceSequenceFile','GroupX','GroupY',[],[],[]);
    NavP=struct('EllipParam',[6378137 0.0818191908],'ProjParam',[0 141 0.9996 500000 0], 'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',6);
    %Create P1/90 files
    NavOutGeog=struct('EllipParam',[6378137 0.0818191908],'ProjParam',[0 141 0.9996 500000 0], 'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',2);
    NavOutProj=struct('EllipParam',[6378137 0.0818191908],'ProjParam',[0 141 0.9996 500000 0], 'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',1);
    [P190Head,PHead]=gP190DTEN2P190(SgyHead,Head,NavP,NavOutGeog,NavOutProj,'d:\8\ET3200SX512i\ReadMe\P190_Header.txt','S',('   ')','1','1',' ',' ');
    gP190Write([RootDir 'ReadMe\'],P190Head,PHead,1,'NNMMM');
    %Create coordinates catalogue with step 10 pings
    gP1902Cat(P190Head,PHead,[RootDir 'ReadMe\gTraining01_Survey_Catalogue.txt'],'gTraining01_Survey',10);
    %Create and draw polyline-structure
    PL=gP1902PL(PHead,'.-b');gMapPLDraw(101,PL);axis equal; gMapTickLabel(101,'%8.1f',8);
    %Create AutoCAD script with trackplots
    gMapPL2AcadExport([RootDir 'ReadMe\gTraining01_Survey_Trackplot.scr'],PL,[7 0 0 0 3],[1 1000],[6 0 5000 0],2,1,1);
end;

%mail@ge0mlib.com 18/02/2020