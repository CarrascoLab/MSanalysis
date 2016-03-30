% PreProSessions.m
% gather selected sessions
% combine them in to a single structure, filter the data in each trial and
% detect saccadic eye-movements

% clear all
%% Parameters

% determines the type of filtering the raw Eyelink gaze position undergoes
filtType=3; filtName={ 'not', 'z-ord', 'kal'}; % 1= none, 2= zero-order, 3= kalman

% eye movement parameters
LAMBDA=6; % std velocity threshold factor
minDur=6; % minimum duration of MS
VELTYPE   = 2;          % velocity type for saccade detection (n-measure smoothing )
SuppInt  = 25;         % suppressive interval for subsequent saccadic events
blinkBorder = 100;          % buffer portion around blinks to excise
bbPad=ones(2*blinkBorder,1); % used in the process of padding the blinks
critEvent=5; % number of trial event used to determine trials that should be thrown out

%   eFlags={'PreCueOn';    % manual labels of events
%         'PreISIOn';
%         'StimOn';
%         'PostISIOn';
%         'PostCueOn';
%         'PostCueOff';
%         'Clr'; };

% adjustable params
MS.amp.min=0.05; % min microsaccade amplitude (ºva)
MS.amp.max=1; % max microsaccade amplitude (ºva)
MS.dur.min =6; % min microsaccade duration(ms)
MS.dur.max =70; % max microsaccade duration (ms)
MS.toss=2; % size of eye movement to discard a trial

fprintf('\nPerforming eye-movement analysis...\nLambda =%i \t Min Duration= %i \nOvershoot Suppression interval = %i\nMax MS amp =%f\tMin MS amp = %f\n%s filtering data...\n',...
    LAMBDA, minDur, SuppInt, MS.amp.max,MS.amp.min, filtName{filtType})


%% Setup

addpath('../functions/');
%  file locations %
source='_select/';
dFormat='yyyyMMdd-HHmm';

% experiment design parameters
trialsPerSession=1120;
SAMP=1000; % expected sample rate
DIST   = 114;         % Monitor distance in cm
xPx   = 1280;       % monitor pixels along x-axis (1280X960)
yPx   = 960;       % monitor pixels along y-axis (1280X960)
xCm   = 40;         % x Monitor width in cm (40X30 cm)
yCm   = 30;         % x Monitor width in cm (40X30 cm)
scrCen = [xPx yPx]/2;  % screen center (intial fixation position)
DPP = pix2deg(xPx,xCm,DIST,1); % degrees per pixel
PPD = deg2pix(xPx,xCm,DIST,1); % pixels per degree
vaLIMS= scrCen*DPP; % visual-angle screen edge eccentricity relative to center


%% INFO
% EXPECTED INPUT FIELDS
%     obs
%     sEssDate
%     block
%     trial
%     diagonal
%     locTarg
%     gapLev
%     gapSz
%     gapLocT
%     gapLocD
%     response
%     correct
%     keyRT
%     start
%     events \\\
%     tedfPreCueOn
%     tedfPreISIOn
%     tedfStimOn
%     tedfPostISIOn
%     tedfPostCueOn
%     tedfPostCueOff
%     tedfClr
%     xy_pos
%     sType

% OUTPUT FORMAT %
% n-length structure vector "TRials" with fields:
% ob: string [1 X n] - observer ID
% file: string [1X n] - the filename of the data source (minus extension)
% uniN: double [1x1] - uniquely indentifying number for each trial
% Corr: double [1X1] - response accuracy 0=incorrect, 1=correct
% RT: double [1 X 1] - duration in MS betweeen response tone and key press
% xy_pos: double [trEnd X 2] - (x,y) gaze coordinates in ºva
% xy_vel: double [trEnd X 2] - (dx,dy) velocity of gaze positiong in ºva/s
% vThr: double [1X2] - horizontal and vertical components of velocity threshold oval
% numEM: double [1X1] - # of em detected in trail
% EMon: double [1 X numEM] - em onset
% EMoff: double [1 X numEM]- em end point
% EMdur: double [1 X numEM] - em duration
% vPeak: double [1 X numEM] - max velocity of this em
% dist: double [1 X numEM]- distance between start and end points (º va)
% angDist: double [1 X numEM]- angle between start and end points (radians, 0=rightward)
% amp: double [1 X numEM] - total em amplitude (º va; max difference of coordinates)
% angAmp: double [1 X numEM] - angle of amplitude (radians, 0=rightward)
% blinks: logical [trEnd X 2] - flags timepoints where gaze position was lost

%    \event timing/    %
% pcueOn: double [1 X 1] - timepoint of the precue relative to the begining of the trial
% tarOn: double [1 X 1] - timepoint of the target relative to the begining of the trial
% rcueOn: double [1 X 1] - timepoint of the response-cue relative to the begining of the trial
% trType: double [1 X 1] - trial type (1=valid left, 2= valid right, 3= neutral left, 4= neutral right)
% trEnd: double [1X1] - last timepoint of trial
% cDur: double [1 X 1] - cue duration bin ( 300|600|900 )
% taEcc: double [1X1] - target eccentricty (4|8)

% % % % % % % % % % % % % % % % % % % % % % % %


%%  Load & combine sEss structures

fileList = nestList(source,'*.mat'); % dir(sprintf('%s*.mat',source));
nFiles=length(fileList);

fprintf('\n%i files identified...\n\n',nFiles)

% load sEssions
for f=nFiles:-1:1
    
    fCode=fileList(f).name(1:end-4); % file code
    fPath=fileList(f).path; % file path
    fprintf('Getting %i/%i - %s ...\n', nFiles+1-f, nFiles, fCode)
    
    
    % % load sEss: fileList(f) % %
    load(sprintf('%s%s.mat',fPath,fCode));
    sEssions(f)=sEss;
    clear sEss
end
IDlist=unique({sEssions.obs});
nObs= length (IDlist);

fprintf('\n%i unique observers within data set.\n',nObs)

% date -> session number
for obN=1:nObs % for each observer
    oIndx= strcmp(IDlist(obN), {sEssions.obs});
    % sort the sessions by date
    [~,order]= sort([sEssions(oIndx).date]);
    % and assign the appropriate number to the session
    [sEssions(oIndx).num]=feed(order);
end
    
% rm - in session RT outliers  % % <- debateable 
% rm - blinks before critEvent# 
% filter trials
% calc velocity 
% padded-blink blotting ( -> nan)
for f=1:nFiles
    
     % % %         % % %
    % % %  Cleaning % % %
     % % %         % % %
    
    fprintf('Removing problem trials (i.e., early blink or RT outlier)...\n')
    
    % % % RT outliers within each session % % %
    zRT= zscore([sEssions(f).trials.keyRT]); % RT zscores for each trial in the session
    rtOutlier=abs(zRT)>2; % trials to discard (all the trials with |RTzs| > 2)
    
    % % % Blinks % % %
    blIndx= cellfun(@(Blnx) any(any(Blnx)),{sEssions(f).trials.blinks}); % trials with blinks/missing
    earlyBlinks=false(size(rtOutlier));
    
    earlyBlinks(blIndx)=cellfun...
        (@(BLNX,critEV)...
        (find(BLNX,1,'first')-blinkBorder)<critEV,... % was the blink or border before the crucial event
        {sEssions(f).trials(blIndx).blinks},... % blink data
        num2cell(need(sEssions(f).trials, blIndx,critEvent, 'events'))'); % timing of critical event on a per trial basis
    
    % count trials meeting either of these criteria and then chuck them
    sEssions(f).discardedTrials=sum(rtOutlier|earlyBlinks);
    sEssions(f).trials=sEssions(f).trials(~(rtOutlier|earlyBlinks));
    blIndx=blIndx(~(rtOutlier|earlyBlinks));
    nTrials=length(sEssions(f).trials);
    
     % % % Filtering % % %
    % % %     &       % % %
     % % % Velocity  % % %
    
    fprintf('%s filtering data...\n', filtName{filtType})

    switch filtType
        case 1 % no filtering
            [sEssions(f).trials.xy_filt]=feed({sEssions(f).trials.xy_pos});
        case 2 % zero phase digital filter & FIR (gaussian)
            % temp vars forcellfun %
            [b, a]=deal(cell(1,nTrials)); a(:)={1}; b(:)={fir1(35,0.05)};
            [sEssions(f).trials.xy_filt]=feed(cellfun(@filtfilt, b,a,{sEssions(f).trials.xy_pos},'UniformOutput',0));
            
        case 3 % kalman (not-quite) filtering
            [sEssions(f).trials.xy_filt]=feed(cellfun(@KalFilt, {sEssions(f).trials.xy_pos},'UniformOutput',0));
    end
    
    fprintf('Calculating velocity... \n')
    
    % temp vars for vecvel %
    [vt, sr]=deal(cell(1,nTrials)); vt(:)={VELTYPE}; sr(:)={SAMP};
    
    [sEssions(f).trials.vel]=feed(cellfun(@vecvel,{sEssions(f).trials.xy_filt},sr, vt,'UniformOutput',0));
    
    % % % remove missing periods  % % %
    for t=find(blIndx)
        padBlinks= logical(conv( double(sEssions(f).trials(t).blinks(:,1)),... %missing values
            bbPad,'same')); % bbpad length determined by blinkBorder
        sEssions(f).trials(t).blinks(:,2)= padBlinks;
        
        [sEssions(f).trials(t).xy_pos(padBlinks,:),...
            sEssions(f).trials(t).xy_filt(padBlinks,:),...
            sEssions(f).trials(t).vel(padBlinks,:)]=deal(nan);
    end
    
end


% saccade detection 

algorithmChoice=input('Which algorithm?: \n 1. microsaccMerge \n 2. microsaccPare \n 3. microsacc \n')

switch
    case 1
        algo=@(a,b,c,d,e) microsaccMerge(a,b,c,d,e);
    case 2
        algo=@(a,b,c,d,e) microsaccPare(a,b,c,d,e);
    case 3
        algo=@(a,b,c,d,e) microsacc(a,b,c,d,e);
    otherwise
           algorithmChoice=input...
               ('Which algorithm?: \n 1. microsaccMerge \n 2. microsaccPare \n 3. microsacc \n')
end

algo=@(a,b,c,d,e) microsaccPare(a,b,c,d,e);
for f=1:nFiles
    nTrials=length(sEssions(f).trials);
     % % %           % % %
    % % %  Saccade  % % %
     % % % Detection % % %
    fprintf('Identifying saccades... \n')    
    % temp variables for (micro)saccade detection %
    [vTh,md,si,a]=deal(cell(1,nTrials)); vTh(:)={LAMBDA }; md(:)={minDur}; si(:)={SuppInt}; a(:)={1};

    % detect EMs
    [emParams, radius]=cellfun(@(a,b,c,d,e) algo(a,b,c,d,e),...
    {sEssions(f).trials.xy_filt},{sEssions(f).trials.vel}, ...
    vTh, md,si,'UniformOutput',0);
%     [emParams, radius]=cellfun(@microsaccPare,...
%         {sEssions(f).trials.xy_filt},{sEssions(f).trials.vel}, ...
%         vTh, md,si,'UniformOutput',0); 
    
    [sEssions(f).trials.vThr]=radius{:}; % Velocity component thresholds
    msParams= cellfun(@saccpar, emParams,'UniformOutput',0); % get saccade params
    % % %

    % % % assign EM paramaters to trials  % % %
    % number of saccadic EM detected in each trial:
    [sEssions(f).trials.numEM]=feed(cellfun(@size,msParams, a,'UniformOutput',0));
    % index of trials with at least 1 EM
    indx=[sEssions(f).trials.numEM]~=0;
    
    [sEssions(f).trials(indx).EMon]     =feed(cellfun(@(x) x(:,1)',	msParams(indx),'UniformOutput',0));
    [sEssions(f).trials(indx).EMoff]    =feed(cellfun(@(x) x(:,2)',	msParams(indx),'UniformOutput',0));
    [sEssions(f).trials(indx).EMdur]    =feed(cellfun(@(x) x(:,3)',	msParams(indx),'UniformOutput',0));
    [sEssions(f).trials(indx).vPeak]    =feed(cellfun(@(x) x(:,4)',	msParams(indx),'UniformOutput',0));
    [sEssions(f).trials(indx).dist]     =feed(cellfun(@(x) x(:,5)',	msParams(indx),'UniformOutput',0));
    [sEssions(f).trials(indx).angDist]  =feed(cellfun(@(x) x(:,6)',	msParams(indx),'UniformOutput',0));
    [sEssions(f).trials(indx).amp]      =feed(cellfun(@(x) x(:,7)',	msParams(indx),'UniformOutput',0));
    [sEssions(f).trials(indx).angAmp]   =feed(cellfun(@(x) x(:,8)',	msParams(indx),'UniformOutput',0));
    % % %
    
% %     % a check for EMs with amp > MS.toss occurring before critEvent
% %     badEM{f}=arrayfun( @(Ti)... discard trials
% %     sEssions(f).trials(Ti).EMon... % if the onset of eye-movements
% %     ([sEssions(f).trials(Ti).amp]>MS.toss)... % with amplitude greater than the discard size
% %     <= sEssions(f).trials(Ti).events(critEvent),... % happened before the target
% %     1:nTrials,'UniformOutput',false);
% % 
% %     badEM{f}=cellfun(@any, badEM{f});

%create a field flagging detected EM satisfying MS criteria
[sEssions(f).trials.MScrit]=feed(cellfun(@(dXY,dT)...
    (dXY>=MS.amp.min &...
    dXY<= MS.amp.max & ...
    dT<MS.dur.max & ...
    dT>=MS.dur.min),... %anonymous function
    {sEssions(f).trials.amp}, {sEssions(f).trials.EMdur}, 'UniformOutput', false)); % input cells (distance & duration

% % in other words
%    [sEssions(f).trials.MScrit]=
%       [sEssions(f).trials.dist]>=nMS... % larger than min size
%     & [sEssions(f).trials.dist]<=xMS... % smaller than max
%     & [sEssions(f).trials.EMdur]<xDur... % shorter dur than max
%     & [sEssions(f).trials.EMdur]>=nDur; % longer dur than min

end
% clean up
clear b a vt sr vTh md si


fprintf('\n Finished! %0.2f%% of trials kept (%d/%d)\n',...
(sum(arrayfun(@(ses) length(ses.trials), sEssions))/sum([sEssions.discardedTrials arrayfun(@(ses) length(ses.trials), sEssions)]))*100,...
sum(arrayfun(@(ses) length(ses.trials), sEssions)),...
sum([sEssions.discardedTrials arrayfun(@(ses) length(ses.trials), sEssions)]))


% %% clean up unnessary variables
% clear msParams zRT badEM blIndx dump fileList fCode fDate fGroup trInd...
%     fPath fSess indx missing overWrite radius rtOutlier sEss source...
%     TRials f blinkBorder critEvent tr trialsPerSession