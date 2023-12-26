function [Head3,Data3]=gWfrMergeData(Head1,Data1,BgVal1,Head2,Data2,BgVal2,IntKey)
%Merge Image1 and Image2 using world-data. The features: a) Image2 is cover up Image1; b) world file's Line2_D (skewX) and Line3_B (skewY) must be zero.
%function [Head3,Data3]=gWfrMergeData(Head1,Data1,BgVal1,Head2,Data2,BgVal2,IntKey), where
%Head - header structure, which includes:
%Head.Color - colormap for palette image;
%Head.Wf - world-file values: [scaleX 0 0 scaleY left_up_angle_X left_up_angle_Y];
%Head.K=[a b] – multiple (a) and shift (b) for "Data Original Value" calculation from Color; DataOriginalValue=a*Color+b;
%Head.BgVal – the code of “absent” color (it is means – no data for raster’s pixel with BgVal code);
%Data - raster-image or matrix image;
%Head1,Data1 - input underlying images;
%Head2,Data2 - input overlying images;
%BgVal1, BgVal2 - forsed code of “absent” color for Image1 and Image2; the OutputImage.BgVal=BgVal1; if empty, then Head.BgVal values are used;
%IntKey - key for colormap correction; if 0 than OutputImage.Color palette and OutputImage.K will be coped from Head1.Color.
%Head3,Data3 - output merged image.
%Example: [Head3,Data3]=gWfrMergeData(Head1,Data1,[],Head2,Data2,[],0);
%=============================
%Additional features.
%0) SkewX and skewY are zero. Will be changed in future.
%1) If IntKey==1:
%   -- try to Combine Colors using Head1.K and Head2.K values;
%   -- else try to find overlap area for Image1 and Image2 and calculate Head.K.
%2) Means that palette for palette-image is gray - for calculations used Head.Color(:,1) column only.
%3) Means that Head1.Wf(1)==Head2.Wf(1), Head1.Wf(4)==Head2.Wf(4); the OutputImage.Wf(1)=Head1.Wf(1), OutputImage.Wf(4)=Head1.Wf(4).
%=============================

if Head1.Wf(2)||Head1.Wf(3)||Head2.Wf(2)||Head2.Wf(3), error('gWfrMergeData --> sorry, this feature is not realized now // Line2_D (skewX) and Line3_B (skewY) must be zero');end;
if isempty(BgVal1)&&isempty(Head1.BgVal),error('gWfrMergeData --> BgVal and Head1.BgVal are empty');end;
if isempty(BgVal2)&&isempty(Head2.BgVal),error('gWfrMergeData --> BgVal and Head2.BgVal are empty');end;
if ~isempty(BgVal1),Head1.BgVal=BgVal1;end; if ~isempty(BgVal2),Head2.BgVal=BgVal2;end;

if ~all(Head1.Color==Head2.Color), warning('gWfrMergeData --> paletters are different');end;
if Head1.Wf(1)~=Head2.Wf(1), warning('gWfrMergeData --> X-steps are different');end;
if Head1.Wf(4)~=Head2.Wf(4), warning('gWfrMergeData --> Y-steps are different');end;
%find Head.Wf values for merged area
Wf17=(size(Data1,2)-1).*Head1.Wf(1)+Head1.Wf(5);% - right_dn_angle_X for Data1
Wf18=(size(Data1,1)-1).*Head1.Wf(4)+Head1.Wf(6);% - right_dn_angle_Y for Data1
Wf27=(size(Data2,2)-1).*Head2.Wf(1)+Head2.Wf(5);% - right_dn_angle_X for Data2
Wf28=(size(Data2,1)-1).*Head2.Wf(4)+Head2.Wf(6);% - right_dn_angle_Y for Data2
minX=min([Head1.Wf(5) Head2.Wf(5)]);maxX=max([Wf17 Wf27]);minY=min([Wf18 Wf28]);maxY=max([Head1.Wf(6) Head2.Wf(6)]);
numX=round((maxX(1)-minX(1))./Head1.Wf(1)+1);numY=round((maxY(1)-minY(1))./-Head1.Wf(4)+1);
%create [Head3,Data3] from [Head1,Data1] to merged area zone
Data3=repmat(feval(class(Data1),Head1.BgVal),numY,numX);
Data3(round((Head1.Wf(6)-maxY)./Head1.Wf(4)+1):round((Wf18-maxY)./Head1.Wf(4)+1),round((Head1.Wf(5)-minX)./Head1.Wf(1)+1):round((Wf17-minX)./Head1.Wf(1)+1))=Data1;
Head3=Head1;Head3.Wf=[Head1.Wf(1) 0 0 Head1.Wf(4) minX maxY];
%create [Head4,Data4] from [Head2,Data2] to merged area zone
Data4=repmat(feval(class(Data2),Head2.BgVal),numY,numX);
Data4(round((Head2.Wf(6)-maxY)./Head2.Wf(4)+1):round((Wf28-maxY)./Head2.Wf(4)+1),round((Head2.Wf(5)-minX)./Head2.Wf(1)+1):round((Wf27-minX)./Head2.Wf(1)+1))=Data2;
Head4=Head2;Head4.Wf=[Head2.Wf(1) 0 0 Head2.Wf(4) minX maxY];
%try to Combine Colors
if IntKey,
    %calculation for Head.K are presented
    if ~isempty(Head3.K)&&~isempty(Head4.K),
        [Head3,Data3,Head4,Data4]=gWfrCombineColors(Head3,Data3,Head4,Data4,[],[]);
    else
        %find overlaped Data1 and Data2 parts >> try to calculate Head.K
        if isnan(Head3.BgVal), L1=~isnan(Data3); else L1=(Data3~=Head3.BgVal);end;
        if isnan(Head4.BgVal), L2=~isnan(Data4); else L2=(Data4~=Head4.BgVal);end;
        L=L1&L2;
        if isempty(L),
            %cannot calculate
            warning('gWfrMergeData --> Datum has not overlay for Color correction, Color was not corrected');
        else
            if isempty(Head3.K),Head3.K=[1 0];end;
            %create statistics
            if isempty(Head3.Color),D3=double(Data3(L))./Head3.K(1)-Head3.K(2);else D3=double(Head3.Color(Data3(L),1))./Head3.K(1)-Head3.K(2);end;
            if isempty(Head4.Color),D4=double(Data4(L));else D4=double(Head4.Color(Data4(L),1));end;
            Len=numel(D3);[n1,n2]=ndgrid(1:Len,1:Len);Lz=tril(n1,-1)~=0;sInd=[n2(Lz) n1(Lz)];
            SgA=(D3(sInd(:,2))-D3(sInd(:,1)))./(D4(sInd(:,2))-D4(sInd(:,1)));
            SgB=D3(sInd(:,2))-SgA.*D4(sInd(:,2));
            Lz0=isnan(SgA)|isnan(SgB)|isinf(SgA)|isinf(SgB);SgA(Lz0)=[];SgB(Lz0)=[];
            SigmaK=[3 2.5];%robust stigmation koeffs
            for nn=SigmaK,
                Lz1=1;Lz2=1;
                while ~(isempty(Lz1)&&isempty(Lz2)),
                    Lz1=find(abs(SgA-mean(SgA))>std(SgA).*nn);SgA(Lz1)=[];SgB(Lz1)=[];
                    Lz2=find(abs(SgB-mean(SgB))>std(SgB).*nn);SgA(Lz2)=[];SgB(Lz2)=[];
                end;
            end;
            Head4.K=[mean(SgA) mean(SgB)];%StatS=std(SgA);StatS=std(SgB);StatV=numel(SgA);
            [Head3,Data3,Head4,Data4]=gWfrCombineColors(Head3,Data3,Head4,Data4,[],[]);
            warning('gWfrMergeData --> Datum has overlay, Color was corrected using stat');
        end;
    end;
else
    warning('gWfrMergeData --> Color was not corrected by user setings');
end;
%copy "good" data from Data4 to Data3_func_output
if isnan(Head4.BgVal), L=~isnan(Data4); else L=(Data4~=Head4.BgVal);end;
Data3(L)=Data4(L);

%mail@ge0mlib.com 19/06/2018