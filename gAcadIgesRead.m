function [CircXY,LL,PL]=gAcadIgesRead(fName)
%Read circles' center coordinates, Lines and Polylines coordinates from iges-file (AutoCad's export).
%[CircXY,PL,LL]=gAcadIgesRead(fName), where
%fName- name of iges file;
%CircXY- output xy-coordinates and R in three rows (mess 124 and 100);
%LL- output xy-coordinates of start and end Line in PL-structure (mess 110);
%PL- output xy-coordinates of polyline nods in PL-structure (mess 126).
%Example:
%[CircXY,LL,PL]=gAcadIgesRead('e:\021\S2_KP0-KP357_Seabedfeature_20210812i_Mag.iges');

fId=fopen(fName,'r');c=fscanf(fId,'%c',[82,inf])';fclose(fId); %read file as a 82xInf char matrix
if all(c(:,82)==char(10)), c(:,82)=[];else,error('Column(82) must be char(10)');end %delete CR
if all(c(:,81)==char(13)), c(:,81)=[];else,error('Column(81) must be char(12)');end %delete LF
L=c(:,73)=='P';c(~L,:)=[]; %find P-block
if all(diff(str2num(c(74:80)))==1), c(:,74:80)=[];else,error('Column(74:80) must containe consecutive increased numbers');end %check P-block numbers
c(:,73)=[]; %delete P-symbol
%concatenate strings with the same P-numbers
s=cell(size(c,1),1);nn=0;old=-1;
for n=1:size(c,1)
    if str2num(c(n,65:72))~=old, nn=nn+1;s{nn}=c(n,1:64);old=str2num(c(n,65:72));
    else, s{nn}=[s{nn} c(n,1:64)];
    end
end
s(nn+1:end)=[];
%read coordinates
CircXY=zeros(3,size(s,1));PL(1:size(s,1))=struct('GpsE',[],'GpsN',[]);LL(1:size(s,1))=struct('GpsE',[],'GpsN',[]);
nnCirc=0;nnCircR=0;nnPL=0;nnLL=0;
for n=1:size(s,1)
    switch str2num(s{n}(1:find(s{n}==',',1)-1))
        case 124 %read AutoCAD circles
            nnCirc=nnCirc+1;cc=textscan(s{n},'%f%f%f%f%f%f%f%f%f%f%f%f%f;','Delimiter',',','MultipleDelimsAsOne',0);
            CircXY(1:2,nnCirc)=[cc{5};cc{9}];
        case 100 %read AutoCAD circles radius
            nnCircR=nnCircR+1;cc=textscan(s{n},'%f%f%f%f%f%f%f%f%f%f%f;','Delimiter',',','MultipleDelimsAsOne',0);
            if cc{5}==cc{7},CircXY(3,nnCircR)=-cc{5};else,CircXY(3,nnCircR)=nan;end
        case 110 %read AutoCAD lines
            nnLL=nnLL+1;cc=textscan(s{n},'%f','Delimiter',',','MultipleDelimsAsOne',0);
            LL(nnLL).GpsE=cc{1}(2:3:end-4);LL(nnLL).GpsN=cc{1}(3:3:end-4);
        case 126 %read AutoCAD polylines
            nnPL=nnPL+1;cc=textscan(s{n},'%f','Delimiter',',','MultipleDelimsAsOne',0);a=3+6+cc{1}(2)+2+cc{1}(2);%1+cc{1}(2)-cc{1}(3)+2.*cc{1}(3);
            PL(nnPL).GpsE=cc{1}(a+1:3:end-9);PL(nnPL).GpsN=cc{1}(a+2:3:end-9);
    end
end
if nnCirc~=0, CircXY(:,nnCirc+1:end)=[];else,CircXY=[];end %trim circles end
if nnLL~=0, LL(nnLL+1:end)=[];else,LL=struct('GpsE',[],'GpsN',[]);end %trim LL end
if nnPL~=0, PL(nnPL+1:end)=[];else,PL=struct('GpsE',[],'GpsN',[]);end %trim PL end

%mail@ge0mlib.com 06/12/2021