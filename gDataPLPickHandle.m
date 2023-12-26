function outCur=gDataPLPickHandle(inCur,PLName,KeyLineDraw,extrapCur)
%Image/Matrix sub-horizontal polylines handle-picking.
%function outCur=gDataPLPickHandle(inCur,PLName,KeyLineDraw,extrapCur), where
%inCur- PickHandleImg input structure;
%PLName- polyline name;
%KeyLineDraw- string key for line drawing: '-r','xb', etc;
%extrapCur- extrapolation flag to curve borders (create two [pX;pY] points for pX=1 and pX=end);
%outCur- PickHandleImg output structure: P.PLName; P.Type; P.KeyLineDraw; P.pX; P.pY; P.PickL
%outCur.PLName- polyline name;
%%outCur.Type='Horizon';
%outCur.KeyLineDraw- string key for line drawing: '-r','xb', etc;
%outCur.pX- polyline point's horizontal axis coordinates;
%outCur.pY- polyline point's vertical axis coordinates;
%outCur.PickL=[xL yL]- interpolated picked points coordinates for horizontal and vertical axis for each Image pixels.
%Example: [SgyHead,Head,Data]=gSgyRead('c:\temp\2.sgy','',[]);imagesc(Data);P=gDataPLPickHandle([],'123','r',1);P1=gDataPLPickHandle(P,[],[],1);
%outCur=gDataPLPickHandle(outCur.PickL,'123','r',0);
%===Mouse&Keyboard===
%LMK or v-set point; RMK-delete point; MMK-create and redraw "lines"; Space-pause mode; q-picking end.

h=findobj(gcf,'Type','image');hh=get(h);sz=size(hh.CData,2);clear h hh;hold on;%find image width
xP=(1:sz);yP=nan(1,sz);xL=(1:sz);yL=nan(1,sz);
outCur.PLName=PLName;outCur.KeyLineDraw=KeyLineDraw;outCur.Type='Horizon';
%upBorder forming
if isempty(inCur), yP=nan(1,sz);
elseif all(isnumeric(inCur))&&(numel(inCur)==1), yP=repmat(round(inCur),1,sz);
elseif all(isnumeric(inCur))&&(size(inCur,1)==1)&&(size(inCur,2)==sz), yP=inCur;
elseif all(isnumeric(inCur))&&(size(inCur,1)==2), yP(inCur(1,:))=inCur(2,:);
elseif isstruct(inCur),
    yP(inCur.pX)=inCur.pY;
    if isempty(PLName), outCur.PLName=inCur.PLName;end;
    if isempty(KeyLineDraw), outCur.KeyLineDraw=inCur.KeyLineDraw;end;
else error('UpBorder parameter error.');
end;

pP=plot(xP,yP,'+r');pL=plot(xL,yL,'-b');

%picking sycle
but='z';
while (but~='q'),
    [xn,yn,but]=ginput(1);xn=round(xn);yn=round(yn);
    if ((but==1)||(but=='v'))&&(xn>=0)&&(xn<=sz), yP(xn)=yn;set(pP,'Ydata',yP);end;
    if (but==3)&&(xn>=0)&&(xn<=sz), yP(xn)=nan;set(pP,'Ydata',yP);end;
    if (but==2),
        if extrapCur==1, L=find(~isnan(yP));yP(1)=yP(L(1));yP(end)=yP(L(end));set(pP,'Ydata',yP);end;
        L=find(~isnan(yP));yL=interp1(xP(L),yP(L),xL,'linear');set(pL,'Ydata',yL,'Xdata',xL);
    end;
    if but==' ', pause;end;
end;
if extrapCur==1, L=find(~isnan(yP));yP(1)=yP(L(1));yP(end)=yP(L(end));set(pP,'Ydata',yP);end;%extrapolation to image borders
L=find(~isnan(yP));
if numel(L)==1, yL(:)=yP(L);set(pL,'Ydata',yL,'Xdata',xL);%one point
else yL=interp1(xP(L),yP(L),xL,'linear');set(pL,'Ydata',yL,'Xdata',xL);%yL interpolation
end;
outCur.pX=round(xP(L));outCur.pY=round(yP(L));outCur.PickL=[round(xL);round(yL)];%remove nan from pX and yP
hold off;

%mail@ge0mlib.com 19/11/2019