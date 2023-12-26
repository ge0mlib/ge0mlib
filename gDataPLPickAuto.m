function outCur=gDataPLPickAuto(Data,Pt,param,upBorder,dnBorder,PLName,KeyLineDraw)
%Image/Matrix sub-horizontal polylines auto-picking.
%function outCur=gDataPLPickAuto(Data,Pt,param,upBorder,dnBorder,PLName,KeyLineDraw), where
%Data- 2D matrix with data for autopicking;
%Pt- input polyline coordinates for autopicking: 1)polyline struct; 2)2 rows [X;Y];
%param- autopick parameters: 1)up border for "search window"; 2)down border for "search window"; 3)autopick condition 1-max, 2-min, 3-bigger than A, 4-smaller than A; 4)A for 3-4 conditions;
%upBorder- upper autopicking border polyline coordinates; there are: 1)polyline struct; 2)one number; 3)row Y; 4)if empty, than =1; 5)one rows polyline current_trace's_point_number for all traces;
%dnBorder- down autopicking border polyline coordinates; there are: 1)polyline struct; 2)one number; 3)row Y; 4)if empty, than =1; 5)one rows polyline current_trace's_point_number for all traces;
%PLName- polyline name;
%KeyLineDraw- string key for line drawing: '-r','xb', etc;
%outCur- PickAutoImg output structure: P.PLName; P.Type; P.KeyLineDraw; P.pX; P.pY; P.PickL
%outCur.PLName- polyline name;
%outCur.Type='Horizon';
%outCur.KeyLineDraw- string key for line drawing: '-r','xb', etc;
%outCur.pX- autopick input polyline horizontal axis coordinates;
%outCur.pY- autopick input polyline vertical axis coordinates;
%outCur.PickL=[xL yL]- autopick coordinates for horizontal and vertical axis for each Image pixels.
%Example (bottom picking):
%[SgyHead,Head,Data]=gSgyRead('c:\temp\2.sgy','',[]);imagesc(Data,[-1000 1000]);colormap('gray');outCur=gDataPLPickHandle([],'123','r',0);
%outCurA=gDataPLPickAuto(Data,outCur,[3 3 2],[],[],'123','.-b');hold on;plot(outCurA.PickL(2,:),'.b');
%outCur=gDataPLPickHandle(outCur.PickL,'123','r',0);

sData2=size(Data,2);
%upBorder forming
if isempty(upBorder), upBorder=ones(1,sData2);
elseif all(isnumeric(upBorder))&&(numel(upBorder)==1), upBorder=repmat(round(upBorder),1,sData2);
elseif all(isnumeric(upBorder))&&(numel(upBorder)==sData2), upBorder=[1:sData2;upBorder(:)'];
elseif isstruct(upBorder), upBorder=round(upBorder.PickL(2,:));
else error('UpBorder parameter error.');
end;
if numel(upBorder)~=sData2, error('UpBorder numel~=size(Data,2).');end;
%dnBorder forming
if isempty(dnBorder), dnBorder=repmat(size(Data,1),1,sData2);
elseif isnumeric(dnBorder)&&(numel(dnBorder)==1), dnBorder=repmat(round(dnBorder),1,sData2);
elseif isnumeric(dnBorder)&&(numel(dnBorder)==sData2), dnBorder=[1:sData2;dnBorder(:)'];
elseif isstruct(dnBorder), dnBorder=round(dnBorder.PickL(2,:));
else error('DnBorder parameter error.');
end;
if numel(dnBorder)~=sData2, error('DnBorder numel~=size(Data,2).');end;
%Pt forming
if isstruct(Pt),
    if isempty(PLName), PLName=Pt.PLName;end;
    if isempty(KeyLineDraw), KeyLineDraw=Pt.KeyLineDraw;end;
    Pt=[Pt.pX;Pt.pY];
end;
%raw for autopicking
out=nan(1,sData2);

%================main cycle=================
d=0;fl=true;
while fl,
    fl=false;
    for nn=1:size(Pt,2),%cycle for Pt-points
        %go right from Pt(1,nn) to d
        X=Pt(1,nn)+d;fl1=false;
        if (X<=sData2)&&(isnan(out(X))),
            if d==0,Y=Pt(2,nn);else Y=out(X-1);end;
            dyup=Y-param(1);dydn=Y+param(2);
            if dyup<upBorder(X), dyup=upBorder(X);end;if dydn>dnBorder(X), dydn=dnBorder(X);end;
            dd=Data(dyup:dydn,X);
            switch param(3),
                case 1,[~,L]=max(dd); case 2,[~,L]=min(dd); case 3,L=find(dd>param(4)); case 4,L=find(dd<param(4));
            end;
            if ~isempty(L),out(X)=L(1)+dyup-1;
            elseif d==0,out(nn)=Y;
            elseif upBorder(X)>out(X-1),out(X)=upBorder(X);elseif dnBorder(X)<out(X-1),out(X)=dnBorder(X);
            else out(X)=out(X-1);
            end;
            fl1=true;
        end;
        %go left from Pt(1,nn) to d
        X=Pt(1,nn)-d;fl2=false;
        if (X>0)&&(isnan(out(X))),
            if d==0,Y=Pt(2,nn);else Y=out(X+1);end;
            dyup=Y-param(1);dydn=Y+param(2);
            if dyup<upBorder(X), dyup=upBorder(X);end;if dydn>dnBorder(X), dydn=dnBorder(X);end;
            dd=Data(dyup:dydn,X);
            switch param(3),
                case 1,[~,L]=max(dd); case 2,[~,L]=min(dd); case 3,L=find(dd>param(4)); case 4,L=find(dd<param(4));
            end;
            if ~isempty(L),out(X)=L(1)+dyup-1;
            elseif d==0,out(nn)=Y;
            elseif upBorder(X)>out(X+1),out(X)=upBorder(X);elseif dnBorder(X)<out(X+1),out(X)=dnBorder(X);
            else out(X)=out(X+1);
            end;
            fl2=true;
        end;
        fl=fl|fl1|fl2;
    end;
    d=d+1;
end;
outCur.PLName=PLName;outCur.KeyLineDraw=KeyLineDraw;outCur.Type='Horizon';
outCur.pX=Pt(1,:);outCur.pY=Pt(2,:);outCur.PickL=[1:sData2;out];

%mail@ge0mlib.com 31/01/2021