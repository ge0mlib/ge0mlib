function EllipParam=gNavEllipName2EllipParam(EllipName)
%Get Ellipsoid Parameters [semi_major_axis first_eccentricity] for Ellipsoid Name. 
%function EllipParam=gNavEllipName2EllipParam(EllipName), where
%EllipName - ellipsoid names: sphere, everest, bessel, airy, clarke66, clarke80, international, krasovsky, wgs60, iau65, wgs66, iau68, wgs72, grs80, wgs84, pz90;
%EllipParam - ellipsoid parameters [Semi_major_axis_a  First_eccentricity_et];
%Example: EllipParam=gNavEllipName2EllipParam('wgs84');

switch EllipName,
    case 'sphere', EllipParam=[6371000 0]; %the sphere
    case 'everest', EllipParam=[6377276.345 0.081472980983]; %the 1830 Everest ellipsoid
    case 'bessel', EllipParam=[6377397.155 0.081696831223]; %the 1841 Bessel ellipsoid
    case 'airy', EllipParam=[6377563.396 0.081673382673]; %the 1849 Airy ellipsoid
    case 'clarke66', EllipParam=[6378206.4 0.082271854223]; %the 1866 Clarke ellipsoid
    case 'clarke80', EllipParam=[6378249.145 0.082483400044]; %the 1880 Clarke ellipsoid
    case 'international', EllipParam=[6378388 0.081991889979]; %the 1924 International ellipsoid
    case 'krasovsky40', EllipParam=[6378245 0.081813334017]; %the 1940 Krasovsky ellipsoid
    case 'krasovsky46', EllipParam=[6378245 0.0818133340169312]; %the 1946 Krasovsky ellipsoid
    case 'wgs60', EllipParam=[6378165 0.081813334017]; %the 1960 World Geodetic System ellipsoid
    case 'iau65', EllipParam=[6378160 0.081820179996]; %the 1965 International Astronomical Union ellipsoid
    case 'wgs66', EllipParam=[6378145 0.081820179996]; %the 1966 World Geodetic System ellipsoid
    case 'iau68', EllipParam=[6378160 0.081820563422]; %the 1968 International Astronomical Union ellipsoid
    case 'wgs72', EllipParam=[6378135 0.081818810663]; %the 1972 World Geodetic System ellipsoid
    case 'grs80', EllipParam=[6378137 0.081819191043]; %the 1980 Geodetic Reference System ellipsoid
    case 'wgs84', EllipParam=[6378137 0.0818191908425]; %the 1984 World Geodetic System ellipsoid
    case 'wgs84z', EllipParam=[6378137 0.0818191908426215]; %the 1984 World Geodetic System ellipsoid
    case 'pz90', EllipParam=[6378136 0.081819106528364]; %the 1990 Earth Parameters
    otherwise, error('Error gNavEllipName2EllipParam: invalid Ellipse name');
end;

%mail@ge0mlib.com 15/09/2017