function [ rate, scale, lims ] = MSrate( msArray, lock, tArray)
% MSrate
%   input: msArray - eye movement & trial details
%               lock - the column of msArray the analysis is centered on
%               tArray - trial details
%
%         ** if lock ==0, locked on t=0 (trial start) ** 

% assumed columns of  input arrays:
% % % TArray % % % % %    |   % % % msArray % % %
% 1. sub inits                         |    1. sub init
% 2. file name                       |    2. file name
% 3. trial #                             |    3. trial #
% 4. pre-cue onset                |    4. pre-cue onset
% 5. target onset                   |   5. target onset
% 6. resp. cue onset              |    6. resp. cue onset   
% 7.  end (RT + 200ms )       |    7. trial end
% 8.  cue type                        |   8.  cue- type
% 9.  cue-duration bin           |   9. cue duration
% 10. eccentricity                  |  10. eccentricity
% 11. Correct?                        |   11. correct  
% 12.  xy position                   |   12. sac onset
% 13.  velocity                       |   13. sac offset
%                                             |   14. sac duration
%                                             |   15.   peak vel
%                                             |   16.  sac distance
%                                             |   17.    dist. ang.
%                                             |   18.   sac amplitude
%                                             |   19.amp. ang.
% % % % % % % % % % % % % % % % % % % % % % % %
eArray=cell2mat(tArray(:,7)); % trial endpoints

% set wb, wa & nt
if lock==0 % from start point
    wb=-1;
    wa= max(eArray); % window after
    nt=sum( eArray*ones(1,wa) > ones(size(eArray))*(1:wa) );
    
    MSonsets=cell2mat(msArray(:,12));
else % with lockpoint centered
    lArray=cell2mat(tArray(:,lock)); % lock points
    wb= max(lArray)-1; % window before lock
    wa= max(eArray-lArray); % window after lock
    nt=ones(size(eArray))*(-wb:wa); % just initializing nt
    nt=sum((eArray-lArray)* ones(1,size(nt,2)) > nt & nt > (-lArray)*ones(1,size(nt,2))) ; % count trials at each time point
    
    MSonsets=cell2mat(msArray(:,12))-cell2mat(msArray(:,lock));
end


[rate, scale] = gausRate(MSonsets,wb,wa,nt);

if lock==0
    lims=[1  find(nt< (max(nt)*1/3),1,'first')];
else
    lims= [find(scale'<0 & nt<(max(nt)*1/3),1,'last'), find(scale'>0 & nt<(max(nt)*1/3),1,'first')];
    lims= scale(lims)';
end

rate=rate(1:end-1)';
scale=scale(1:end-1)';
end

