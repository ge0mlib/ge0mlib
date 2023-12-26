function VelMat=gSgyHoriz2VelMatrix(Hrz,sizeDat,fl)
%Create Velocity matrix for time-to-depth conversion, using horizons structure.
%function VelMat=gSgyHoriz2VelMatrix(Hrz,sizeDat,fl), where
%Hrz(1..m)- horizon for time-to-depth conversion, contained fields:
%  Hrz(n).PLName- horizon's name; 
%  Hrz(n).KeyLineDraw- string key for line drawing: '-r','xb', etc;
%  Hrz(n).pX, Hrz.pY- base-points for picking (applied for compatibility with picking functions);
%  Hrz(n).PickL=[xL yL]- two-rows vector with trace number and horizon's depth in digits (for each Image pixel); if horizon is not exist, than yL(n1..n2)==nan;
%  Hrz(n).Vbelow- velocity below horizons in m/s;
%  Hrz(n).Digit- scalar, one digit "length" (step for Data matrix);
%sizeDat- size of Data matrix;
%fl- the method of Velocity matrix filling;
%VelMat- Velocity Matrix same size with Data matrix filled using horizons (based on Velocities below horizons).
%Example: Hrz(1)=gSgyHorizCreate(1,size(Data),1500,[],'time','first','.-b');Hrz(2)=gSgyHorizCreate(Head.UnassignedInt1,size(Data),2000,[],'time','bottom','.-b');VelMat=gSgyHoriz2VelMatrix(Hrz,size(Data),1);

VelMat=zeros(sizeDat);
switch fl,
    case 1, %take horizons from first to last, and fill Vbelow to Velosity matrix below horizon; WARNING! the horizons must follow form up to down
        [x1,~]=ndgrid(1:sizeDat(1),1:sizeDat(2));
        for n=1:numel(Hrz),
            Hr=repmat(Hrz(n).PickL(2,:),sizeDat(1),1); %create matrix with horizon's depth-in-digits
            VelMat(Hr<=x1)=Hrz(n).Vbelow; %find all values below or equal horizon's depth-in-digits, and set Vbelow
        end;
    otherwise, error('Unexpected method of Velosity matrix filling');
end;

%mail@ge0mlib.com 15/02/2019