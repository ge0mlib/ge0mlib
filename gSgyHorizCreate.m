function Hrz=gSgyHorizCreate(PLdat,sizeDat,V,PLName,KeyLineDraw)
%Create SBP-horizon for time-to-depth conversion, using 1-single value, 2-vector, 3-Horizon structure (see gData).
%function Hrz=gSgyHorizCreate(PLdat,sizeDat,V,PLName,KeyLineDraw), where
%sizeDat- size of Data matrix;
%V- velocity below horizon in m/s (will write to Hrz.Vbelow);
%PLdat- horizons values, in trace number (horizontal) and digit number (vertical); it can be defined: single value; vector for all traces; two-rows vector with trace number and horizon's depth in digits; Horizon structure;
%Horizon structure structure contained fields: Cur.PLName; Cur.KeyLineDraw; Cur.pX; Cur.pY; Cur.PickL
%  Cur.PLName- polyline name;
%  Cur.KeyLineDraw- string key for line drawing: '-r','xb', etc;
%  Cur.pX- polyline point's horizontal axis coordinates;
%  Cur.pY- polyline point's vertical axis coordinates;
%  Cur.PickL=[xL yL]- interpolated picked points coordinates for horizontal and vertical axis for each Image pixels;
%PLName– horizon’s name (will write to Hrz.PLName);
%KeyLineDraw– string key for Horizon (polyline) drawing in MatLab’s figure (for example: '-r','xb'); will write to Hrz.KeyLineDraw;
%Hrz- SBP-horizon for time-to-depth conversion, contained fields:
%  Hrz.PLName- horizon's name;
%  Hrz.KeyLineDraw- string key for line drawing: '-r','xb', etc;
%  Hrz.pX,Hrz.pY- base-points for picking (applied for compatibility with picking functions);
%  Hrz.PickL=[xL yL]- two-rows vector with trace number and horizon's depth in digits (for each Image pixel); if horizon is not exist, than yL(n1..n2)==nan;
%  Hrz.Vbelow- velocity below horizon in m/s;
%Example: Hrz(1)=gSgyHorizCreate(1,size(Data),1500,[],'first','.-b');Hrz(2)=gSgyHorizCreate(Head.UnassignedInt1,size(Data),2000,[],'bottom','.-b');

if isempty(PLdat), error('PLdat must contane data.');end;
if all(isnumeric(PLdat)),
    Hrz=struct('PLName',PLName,'fName','','KeyLineDraw',KeyLineDraw,'pX',[],'pY',[],'PickL',[1:sizeDat(2);nan(1,sizeDat(2))],'Vbelow',V);
    if all(isnumeric(PLdat))&&(numel(PLdat)==1), Hrz.PickL(2,:)=PLdat;
    elseif all(isnumeric(PLdat))&&(size(PLdat,1)==1)&&(size(PLdat,2)==sizeDat(2)), Hrz.PickL(2,:)=PLdat;
    elseif all(isnumeric(PLdat))&&(size(PLdat,1)==2), Hrz.PickL(2,PLdat(1,:))=PLdat(2,:);
    end;
    Hrz.pX=Hrz.PickL(1,:);Hrz.pY=Hrz.PickL(1,:);
elseif isstruct(PLdat),
    Hrz=PLdat;Hrz.Vbelow=V;Hrz.Digit=Digit;Hrz.PhysVal=PhysVal;
    if ~isempty(PLName), Hrz.PLName=PLName;end;
    if ~isempty(KeyLineDraw), Hrz.KeyLineDraw=KeyLineDraw;end;
else error('PLdat type is not correct.');
end;
if any(Hrz.PickL(2,:)>sizeDat(1)),warning('The Horizon is low than Data-matrix');end;

%mail@ge0mlib.com 15/02/2019