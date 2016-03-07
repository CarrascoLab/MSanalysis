function [psac, radius] = microsaccPare(x,vel,VFAC,MINDUR,SUPPDUR)
%-------------------------------------------------------------------
%
%  FUNCTION microsaccPare
% modified from microsacc.m
%  Detection of monocular candidates for microsaccades;
%  Please cite: Engbert, R., & Mergenthaler, K. (2006) Microsaccades
%  are triggered by low retinal image slip. Proceedings of the National
%  Academy of Sciences of the United States of America, 103: 7192-7197.
%
%  (modified by NMS Dec. 17 2015)
%
%-------------------------------------------------------------------
%
%  INPUT:
%
%  x(:,1:2)         position vector
%  vel(:,1:2)       velocity vector
%  VFAC             relative velocity threshold
%  MINDUR           minimal saccade duration
%  SUPPDUR    suppresive interval for subsequent saccade candidates
%
%  OUTPUT:
%
%  sac(1:num,1)   onset of saccade
%  sac(1:num,2)   end of saccade
%  sac(1:num,3)   peak velocity of saccade (vpeak)
%  sac(1:num,4)   horizontal component     (dx)
%  sac(1:num,5)   vertical component       (dy)
%  sac(1:num,6)   horizontal amplitude     (dX)
%  sac(1:num,7)   vertical amplitude       (dY)
%
%---------------------------------------------------------------------

% compute threshold
msdx = sqrt( nanmedian(vel(:,1).^2) - (nanmedian(vel(:,1)))^2 );
msdy = sqrt( nanmedian(vel(:,2).^2) - (nanmedian(vel(:,2)))^2 );
if msdx<realmin
    msdx = sqrt( nanmean(vel(:,1).^2) - (nanmean(vel(:,1)))^2 );
    %if msdx<realmin  %% CAUTION: I took this out because the only critical
    %                 %% time when this can occur is for full-time blinks. I take these out
    %                 %% later in the analysis.
    %    error('msdx<realmin in microsacc.m');
    %end
end
if msdy<realmin
    msdy = sqrt( nanmean(vel(:,2).^2) - (nanmean(vel(:,2)))^2 );
    %if msdy<realmin  %% CAUTION: I took this out because the only critical
    %                 %% time when this can occur is for full-time blinks. I take these out
    %                 %% later in the analysis.
    %    error('msdy<realmin in microsacc.m');
    %end
end
radiusx = VFAC*msdx;
radiusy = VFAC*msdy;
radius = [radiusx radiusy];

% compute test criterion: ellipse equation
test = (vel(:,1)/radiusx).^2 + (vel(:,2)/radiusy).^2;
indx = find(test>1);

% determine saccades
N = length(indx);
sac = [];
nsac = 0;
dur = 1;
a = 1;
k = 1;
while k<N
    if indx(k+1)-indx(k)==1
        dur = dur + 1;
    else
        if dur>=MINDUR
            nsac = nsac + 1;
            b = k;
            sac(nsac,:) = [indx(a) indx(b)];
        end
        a = k+1;
        dur = 1;
    end
    k = k + 1;
end

% check for minimum duration
if dur>=MINDUR
    nsac = nsac + 1;
    b = k;
    sac(nsac,:) = [indx(a) indx(b)];
end

% suppress overshoot "saccades"
if ~isempty(sac)
    psac = sac(1,:);    % pared saccade matrix
    s    = 1;           % index of saccades in sac
    sss  = 1;           % boolean for still same saccade
    nsac = 1;           % number of saccades after paring
    supNext = 0;    % should the next saccade be suppressed
    while s<size(sac,1)
        if ~sss % if a new saccade
            if supNext % if the next saccade falls in the suppression window
                s=s+1; % increment the current saccade candidate
                supNext=0; % reset boolean
                if s==size(sac,1) % if this is the last saccade candidate
                    break
                end
            end
            nsac = nsac + 1; % increase # of saccades
            psac(nsac,:) = sac(s,:); % get start and end of putative saccade
            
        end
        if sac(s+1,1)-sac(s,2) <= SUPPDUR
            % if the next saccade starts within the suppression duration
            
            if sac(s+1,2)-sac(s+1,1)>sac(s,2)-sac(s,1) % if 2nd is longer in duration... 
                %merge
                psac(nsac,2) = sac(s+1,2);
                sss = 1;
            else %suppress next
                sss = 0;
                supNext=1;
            end
        else
            sss = 0;
        end
        s = s+1;
    end
    if ~sss
        nsac = nsac + 1;
        psac(nsac,:) = sac(s,:);
    end
else
    psac = [];
    nsac = 0;
end

% compute peak velocity, horizonal and vertical components
for s=1:nsac
    % onset and offset
    a = psac(s,1);
    b = psac(s,2);
    % saccade peak velocity (vpeak)
    vpeak = max( sqrt( vel(a:b,1).^2 + vel(a:b,2).^2 ) );
    psac(s,3) = vpeak;
    % saccade vector (dx,dy)
    dx = x(b,1)-x(a,1);
    dy = x(b,2)-x(a,2);
    psac(s,4) = dx;
    psac(s,5) = dy;
    % saccade amplitude (dX,dY)
    i = psac(s,1):psac(s,2); % index of time points in saccade
    [minx, ix1] = min(x(i,1)); % tp farthest left
    [maxx, ix2] = max(x(i,1)); % tp farthest right
    [miny, iy1] = min(x(i,2)); % tp farthest down
    [maxy, iy2] = max(x(i,2)); % tp farthest up
    dX = sign(ix2-ix1)*(maxx-minx);
    dY = sign(iy2-iy1)*(maxy-miny);
    psac(s,6:7) = [dX dY];
end
