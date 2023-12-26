function gMapPLWriteTxt(fName,PL,keyWrite)
%Export Track-polyline structure to txt-file.
%gMapPLWriteTxt(fName,PL,numDig), where
%fName- file or folder name for export;
%PL- polyline structure: PL(n).PLName; PL(n).Type; PL(n).KeyLineDraw; PL(n).GpsE; PL(n).GpsN; PL(n).GpsKP
%keyWrite(1)- Track-polyline type code.
%if keyWrite(1)=1 >> 'LinePlan', than all lines write to single file with name "fName", in "LinePlan file format";
%if keyWrite(1)=2 >> 'PipeLineTrack', than each line write to oun file with names "PL(n).PLName" at folder "fName", in "PipeLineTrack" file format;
%if keyWrite(1)=3 >> 'LinePlanKP', than all lines write to single file with name "fName", in "LinePlanKP file format".
%keyWrite(2)- digits number for numbers in file.
%Example: gMapPLWriteTxt('c:\temp\PL1.txt',PL,[1 3]);
%==============1-LinePlan file format=====================
%There are rows included LineName and E/Lat, N/Lon coordinates:
%LineName1, E1, N1, ..., En, Nn
%.............
%LineNameN, E1, N1, ..., En, Nn
%the delimiter is '\t'.
%===============2-PipeLineTrack file format=======================
%There are a number of columns included E, N, KP(?), Z(?); columns positions are defined in keyRead;
%E, N, KP, Z, PipeD
%.............
%En, Nn, KPn, Zn, PipeDn
%the delimiter is '\t'.
%===============3-LinePlanKP file format=======================
%There are rows included E, N, KP:
%LineName1, E1, N1, KP1, ..., En, Nn, KPn
%.............
%LineNameN, E1, N1, KP1, ..., En, Nn, KPn
%the delimiter is '\t'.
%==============Axis========================================
%^y/N
%|
%o--->x/E

switch keyWrite(1),
    case 1 %LinePlaning file format;all lines write in one file
        fId=fopen(fName,'w');
        for n=1:length(PL),
            fprintf(fId,'%s\t',PL(n).PLName);fprintf(fId,['%0.' num2str(keyWrite(2)) 'f\t'],[PL(n).GpsE;PL(n).GpsN]);fseek(fId,-1,0);fprintf(fId,'\r\n');
        end;
        fclose(fId);
    case 2 %PipeLine file format;each line write in to oun file, with name PL(n).PLName
        for n=1:length(PL),
            if isfield(PL(n),'GpsKP'),GpsKP=PL(n).GpsKP;else GpsKP=[];end;
            if isfield(PL(n),'GpsZ'),GpsZ=PL(n).GpsZ;else GpsZ=[];end;
            if isfield(PL(n),'PipeD'),PipeD=PL(n).PipeD;else PipeD=[];end;
            A=[PL(n).GpsE;PL(n).GpsN GpsKP GpsZ PipeD];
            dlmwrite([fName '\' PL(n).PLName '.txt'],A','delimiter','\t','precision',['%.' num2str(keyWrite(2)) 'f']);
        end;
    case 3,
        fId=fopen(fName,'w');
        for n=1:length(PL),
            fprintf(fId,'%s\t',PL(n).PLName);fprintf(fId,['%0.' num2str(keyWrite(2)) 'f\t'],[PL(n).GpsE;PL(n).GpsN;PL(n).GpsKP]);fseek(fId,-1,0);fprintf(fId,'\r\n');
        end;
        fclose(fId);
    otherwise, error('Unexpected keyWrite(1) code');
end;

%mail@ge0mlib.com 18/11/2019