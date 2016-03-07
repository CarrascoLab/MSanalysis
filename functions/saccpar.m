function sac = saccpar(sac);
%-------------------------------------------------------------------
%
%  FUNCTION saccpar.m
%
%  (Version 1.0, 01 AUG 05)
%
%-------------------------------------------------------------------
%
%  INPUT: binocular saccade matrix from FUNCTION binsacc.m
%
%  sac(:,1:7)       monocular microsaccades (from microsacc.m)
%
%  OUTPUT:
%
%  sac(:,1:8)       Parameters 
%
%---------------------------------------------------------------------
if size(sac,1)>0
    % 1. Onset
    a = sac(:,1);

    % 2. Offset
    b = sac(:,2);

    % 3. Duration
    D = b-a+1;

    % 4. Peak velocity
    vpeak = sac(:,3);

    % 6. Saccade distance
    dist = sqrt(sac(:,4).^2+sac(:,5).^2);
    angd = atan2(sac(:,5),sac(:,4));

    % 7. Saccade amplitude
    ampl = sqrt(sac(:,6).^2+sac(:,7).^2);
    anga = atan2(sac(:,7),sac(:,6));

    sac = [a b D vpeak dist angd ampl anga];
else
    sac = [];
end