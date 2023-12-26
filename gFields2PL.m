function PL=gFields2PL(Prof,KeyLineDraw,FieldName,FieldKP,FieldX,FieldY,FieldH)
%Read fields from cell (Prof{1..n}) or fields (Prof(1..n)) structure to PL-structure, using sub-fields names (example: 'info.data1.vels')
%function PL=gFields2PL(Prof,KeyLineDraw,FieldName,FieldKP,FieldX,FieldY,FieldH), where
%Prof- cell (Prof{1..n}) or fields (Prof(1..n)) structure for sub-fields extraction;
%keyLineDraw- string key for line drawing: '-r','xb', etc;
%FieldName- sub-field will get to 'PLName'; if empty, than used Prof-data number;
%FieldKP- sub-field will get to 'GpsKP'; if empty, than used numbers 1..n;
%FieldX- sub-field will get to 'GpsE';
%FieldY- sub-field will get to 'GpsN';
%FieldH- sub-field will get to 'GpsZ'; if empty, than not create field 'GpsZ';
%PL- output structure: PL(n).PLName; PL(n).Type; PL(n).KeyLineDraw; PL(n).GpsE; PL(n).GpsN; PL(n).GpsKP.
%Example:
%PL=gFields2PL(Prof,'.-b','PrName','','Mag.GpsEL','Mag.GpsNL','');

Len=length(Prof);PL(1:Len)=struct('PLName',[],'Type','SurveyLineSgy','KeyLineDraw',KeyLineDraw,'GpsE',[],'GpsN',[],'GpsZ',[],'GpsKP',[]);
if isstruct(Prof),
    for n=1:Len,
        if isempty(FieldName), PL(n).PLName=num2str(n,'%04d'); else PL(n).PLName=gFieldsTakeFData(Prof(n),FieldName);end;
        PL(n).GpsE=gFieldsTakeFData(Prof(n),FieldX); PL(n).GpsN=gFieldsTakeFData(Prof(n),FieldY);
        if ~isempty(FieldH), PL(n).GpsZ=Prof(n).(FieldH);end;
        if isempty(FieldKP), PL(n).GpsKP=1:length(PL(n).GpsE); else PL(n).GpsKP=gFieldsTakeFData(Prof(n),FieldKP);end;
    end;
end;
if iscell(Prof),
    for n=1:Len,
        if isempty(FieldName), PL(n).PLName=num2str(n,'%04d'); else PL(n).PLName=gFieldsTakeFData(Prof{n},FieldName);end;
        PL(n).GpsE=gFieldsTakeFData(Prof{n},FieldX); PL(n).GpsN=gFieldsTakeFData(Prof{n},FieldY);
        if ~isempty(FieldH), PL(n).GpsZ=Prof{n}.(FieldH);end;
        if isempty(FieldKP), PL(n).GpsKP=1:length(PL(n).GpsE); else PL(n).GpsKP=gFieldsTakeFData(Prof{n},FieldKP);end;
    end;
end;

%mail@ge0mlib.ru 05/02/2019