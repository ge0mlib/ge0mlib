function LenNum=gMapPLLength(PL,sm)
%Calculate [length points_num] for poly-lines from Track-polyline structure
%function LenNum=gMapPLLength(PL,sm), where
%PL- track-polyline structure, field used: PL(n).GpsE; PL(n).GpsN; PL(n).GpsZ;
%sm- smooth value;
%LenNum=[length points_num].
%Example: 
%PL=gMapPLReadTxt('c:\temp\SSS\V3LinePlan.txt',1,'-c');gMapPLDraw(100,PL);axis equal;LenNum=gMapPLLength(PL,10);

LenNum=zeros(2,numel(PL));
 for n=1:length(PL),
     L=1:numel(PL(n).GpsE);x=smooth(L,PL(n).GpsE,sm,'loess');y=smooth(L,PL(n).GpsN,sm,'loess');
     if isfield(PL(n),'GpsZ'),z=smooth(L,PL(n).GpsZ,sm,'loess');LenNum(1,n)=sum(sqrt(diff(x).^2+diff(y).^2+diff(z).^2));
     else LenNum(1,n)=sum(sqrt(diff(x).^2+diff(y).^2));end;
     LenNum(2,n)=numel(PL(n).GpsE);
 end;

%mail@ge0mlib.com 19/11/2019