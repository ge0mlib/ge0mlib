function PR=gFieldsXYZFileRead(fName,stDelim,fiNames,datFormat,varargin)
%Read XYZ file - a special kind of text file in which records starting with the word "Line" signify the start of groups of data. These groups typically are survey lines, but can be used to represent other groupings such as drill holes. The groups read into the cell vector.
%function PR=gFieldsXYZFileRead(fName,stDelim,fiNames,datFormat), where
%fName- reading file name or files name or folder name with files (last name's symbol must be '\');
%stDelim- strings delimiter (usually char([13 10]));
%fiNames- cell array with field names strings for columns; can be define as 'Mag(5)', with single reference number;
%datFormat- string with data format for columns reading;
%varargin- delimiter format; if empty, than '\t'; example {'\t','/',':'};
%PR- output cell vector; PR{nn}.LName contain string located after word "Line"; fields names defined in fiNames; fields data format defined in datFormat.
%Example: 
%PR=gFieldsXYZFileRead('e:\Dagi15.xyz',char([13 10]),{'YearUTC','MonthUTC','DayUTC','HourUTC','MinuteUTC','SecondUTC','E','N','ES','NS','EL','NL','CC','CCS',...
%   'Depth','DepthS','Altitude','AltitudeS','MagSignal','MagAbsTRaw','MagAbsTS'},'%f/%f/%f,%f:%f:%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f');
%---------------------------XYZ file example-------------------------------------------
%/ YearUTC/MonthUTC/DayUTC, HourUTC:MinuteUTC:SecondUTC, E, N, ES, NS, EL, NL, CC, CCS, Depth, DepthS, Altitude, AltitudeS, MagSignal, MagAbsTRaw, MagAbsTS
%Line 0101-D_L_AN_01
%2019/06/02, 14:32:45.075, 681560.744, 5816158.483, 681560.925, 5816158.300, 681555.926, 5816168.085,  11.00,  11.00,  32.60,  32.61,  4.16,  4.16, 1824, 54709.978, 54709.978
%2019/06/02, 14:32:45.199, 681560.845, 5816158.293, 681561.027, 5816158.100, 681556.028, 5816167.885,  11.00,  11.00,  32.64,  32.61,  4.13,  4.13, 1829, 54709.928, 54709.801
%2019/06/02, 14:32:45.339, 681560.959, 5816158.080, 681561.143, 5816157.873, 681556.144, 5816167.659,  11.00,  11.00,  32.60,  32.62,  4.11,  4.10, 1833, 54707.007, 54709.573
%Line 0101-D_L_AN_02
%2019/06/02, 14:32:48.011, 681563.668, 5816153.168, 681563.324, 5816153.563, 681558.339, 5816163.356,  11.00,  11.00,  32.67,  32.67,  3.75,  3.76, 1787, 54708.480, 54708.507
%2019/06/02, 14:32:48.075, 681563.714, 5816153.104, 681563.375, 5816153.460, 681558.391, 5816163.254,  11.00,  11.00,  32.67,  32.67,  3.78,  3.76, 1782, 54708.703, 54708.669
%2019/06/02, 14:32:48.200, 681563.803, 5816152.980, 681563.476, 5816153.258, 681558.494, 5816163.053,  11.00,  11.00,  32.67,  32.67,  3.78,  3.77, 1777, 54708.889, 54708.889
%--------------------------------------------------------------------------------------

if isempty(varargin),varargin{1}='\t';end;
if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end;
nnn=0;keyWord='Line';%key words for SurveyLines, defined by 'Line';
for nn=1:size(fName,1),
    fNameN=deblank(fName(nn,:));[fId, mes]=fopen(fNameN,'r');if ~isempty(mes), error(mes);end;F=fread(fId,inf,'*char')';fclose(fId);clear fId;
    L=[strfind(F,keyWord) numel(F)+1];PR=cell(numel(L)-1,1);
    for nk=1:numel(L)-1;
        F1=F(L(nk):L(nk+1)-1);
        [C,pos]=textscan(F1,[keyWord '%s' stDelim]);LName=C{1}{1};F1(1:pos)=[];
        C=textscan(F1,[datFormat stDelim],'Delimiter',varargin{1},'MultipleDelimsAsOne',0);
        nnn=nnn+1;PR{nnn}.LName=LName;  %PR{nnn}=cell2struct(C,[{'LName'} fiNames],2);
        for n=1:numel(C),
            C{n}=C{n}';%if all(isnumeric(C{n})), C{n}=C{n}';end;
            L1=find(fiNames{n}=='(');L2=find(fiNames{n}==')');
            if ~isempty(L1)||~isempty(L2),
                if isempty(L1)||isempty(L2), error('Field name in "fiNames" must include no bracket or two brackets.');end;
                if (numel(L1)>1)||(numel(L2)>1),error('Field name in "fiNames" must include only single referense number in format: (N)');end;
                PR{nnn}.(fiNames{n}(1:L1-1))(str2num(fiNames{n}(L1+1:L2-1)),:)=C{n};
            else PR{nnn}.(fiNames{n})=C{n};
            end;
        end;
    end;
end;

%mail@ge0mlib.ru 03/10/2021