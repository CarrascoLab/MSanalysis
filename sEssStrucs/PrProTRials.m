% anaPreproTRials.m
% combine info and complete TRials structure for selected SESSion structs
% clear all
%% Parameters

% determines the type of filtering the raw Eyelink gaze position undergoes
filtType=3; filtName={ 'not', 'z-ord', 'kal'}; % 1= none, 2= zero-order, 3= kalman

% eye movement parameters
LAMBDA=6; % std velocity threshold factor
minDur=6; % minimum duration of MS
VELTYPE   = 2;          % velocity type for saccade detection (n-measure smoothing )
SuppInt  = 25;         % suppressive interval for subsequent saccadic events
blinkBorder = 100;          % portion around blinks to excise
critEvent=5;

% adjustable params
MS.amp.min=0.05; % min microsaccade amplitude (ºva)
MS.amp.max=1; % max microsaccade amplitude (ºva)
MS.dur.min =6; % min microsaccade duration(ms)
MS.dur.max =70; % max microsaccade duration (ms)
MS.toss=2; % size of eye movement to discard a trial

fprintf('Performing eye-movement analysis...\nLambda =%i \t Min Duration= %i \nOvershoot Suppression interval = %i\nMax MS amp =%f\tMin MS amp = %f\nData %s filtered',...
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


%%  Load & combine SESSion structures

fileList = nestList(source,'*.mat'); % dir(sprintf('%s*.mat',source));
nFiles=length(fileList);

fprintf('\n%i files identified...\n\n',nFiles)

TrialN=0; % counter for unique trials

TRials=struct('uniN',num2cell(1:trialsPerSession*nFiles)); % initialize TRials struct

for f=1:nFiles
    
    fCode=fileList(f).name(1:end-4);
    fprintf('Processing %i/%i - %s...\n', f, nFiles, fCode)
    fPath=fileList(f).path;
    [fGroup, fSess]  =feed(textscan(fPath, '%*s%s%s', 'Delimiter', '/'));
    fDate=textscan(fCode,'%*s %*s %s', 'Delimiter','_');
    % % load sEss: fileList(f) % %
    load(sprintf('%s%s.mat',fPath,fCode))
    
    nTrials=length(sEss); % number of trials present in incoming session
    trInd=((TrialN+1):(TrialN+nTrials))'; % index of unique trial numbers for incoming data
    
    % % % assign basic attributes for each trial % % %
    % file/session attributes
    [TRials(trInd).obs]=sEss.obs; % observer identifier
    [TRials(trInd).file]=deal(fCode); % file name (minus extension)
    [TRials(trInd).date]=deal(fDate{:});
    [TRials(trInd).Group]=deal(fGroup{:});
    [TRials(trInd).sessN]=deal(fSess{:});
    [TRials(trInd).sType]=sEss.sType;
    [TRials(trInd).diagonal]=sEss.diagonal;
    % trial attributes
    [TRials(trInd).block]=sEss.block;
    [TRials(trInd).trial]=sEss.trial;
    [TRials(trInd).locTarg]=sEss.locTarg;
    [TRials(trInd).gapLev]=sEss.gapLev;
    [TRials(trInd).gapSz]=sEss.gapSz;
    [TRials(trInd).gapLocT]=sEss.gapLocT;
    [TRials(trInd).gapLocD]=sEss.gapLocD;
    [TRials(trInd).response]=sEss.response;
    [TRials(trInd).correct]=sEss.correct;
    [TRials(trInd).keyRT]=sEss.keyRT;
    % trial event timing
    [TRials(trInd).start]=sEss.start; % raw time stamp
    [TRials(trInd).events]=sEss.events; % relative to trial start
    %     subsumed
    % 'tedfPreCueOn'
    %             [TRials(trInd).tedfPreISIOn]=sEss.tedfPreISIOn;
    %             [TRials(trInd).tedfStimOn]=sEss.tedfStimOn;
    %             [TRials(trInd).tedfPostISIOn]=sEss.tedfPostISIOn;
    %             [TRials(trInd).tedfPostCueOn]=sEss.tedfPostCueOn;
    %             [TRials(trInd).tedfPostCueOff]=sEss.tedfPostCueOff;
    %             [TRials(trInd).tedfClr]=sEss.tedfClr;
    % position
    [TRials(trInd).xy_pos]=sEss.xy_pos;
    [TRials(trInd).blinks]=sEss.blinks;
    
    % % %
    
    TrialN=TrialN+nTrials; % increment trial counter
end

TRials=TRials(1:TrialN); % crop excessive structures if any.


IDlist=unique({TRials.obs});
nObs= length (IDlist);

fprintf('%d trials loaded, \nfrom %d observers.\n\n',TrialN, nObs)
%% Fill in TRials:  filter xy_pos and calculate velocity
fprintf('%s filter selected. \n', filtName{filtType})
% % % set-up temp variable for cellfun % % %
[vt, sr, vTh, md, b, a, si]=deal(cell(1,TrialN));
vt(:)={VELTYPE}; sr(:)={SAMP};
a(:)={1}; b(:)={fir1(35,0.05)};
nEvents=length(TRials(1).events);

vTh(:)={LAMBDA }; md(:)={minDur}; si(:)={SuppInt};
% % %

% % % filtering and velocity calculation % % %
fprintf('filtering data...\n')
switch filtType
    case 1 % no filtering
        [TRials.xy_filt]=feed({TRials.xy_pos});
    case 2 % zero phase digital filter & FIR (gaussian)
        [TRials.xy_filt]=feed(cellfun(@filtfilt, b,a,{TRials.xy_pos},'UniformOutput',0));
    case 3 % kalman filtering
        [TRials.xy_filt]=feed(cellfun(@KalFilt, {TRials.xy_pos},'UniformOutput',0));
end
fprintf('Calculating velocity... \n', filtName{filtType})
[TRials.vel]=feed(cellfun(@vecvel,{TRials.xy_filt},sr, vt,'UniformOutput',0));



%% discarding problem trials 
fprintf('Removing problem trials... \n(i.e., early blink/em or RT outlier)\n')

blIndx= cellfun(@(Blnx) any(any(Blnx)),{TRials.blinks});
for tr=find(blIndx)
    missing=find(TRials(tr).blinks(:,1));
    if ~isempty(missing)
        overWrite=false(size(TRials(tr).xy_pos(:,1)));
        
        %         switch filtType
        %             case 1
        %                 overWrite( missing,:)=true;
        %             case 2
        %                 missing= arrayfun(@(MSN) MSN-blinkBorder:MSN+blinkBorder, missing,'uniformoutput', false);
        %                 overWrite(unique([missing{:}]),:)= true;
        %             case 3
        %                 missing= arrayfun(@(MSN) MSN:MSN+blinkBorder, missing,'uniformoutput', false);
        %                 overWrite(unique([missing{:}]),:)= true;
        %         end
        
        missing= arrayfun(@(absent) absent-blinkBorder:absent+blinkBorder, missing,'uniformoutput', false);
        overWrite(unique([missing{:}]))= true;
        
        if length(overWrite)~=length(TRials(tr).xy_pos)
            overWrite=overWrite(length(TRials(tr).xy_pos));
        end
        % place holders for time point when gaze position was lost
        %         TRials(tr).xy_filt(overWrite)=nan;
        %         TRials(tr).vel(overWrite)=nan;
        TRials(tr).blinks(:,2)=overWrite;         
        
        
    end
    TRials(tr).xy_filt(TRials(tr).blinks(:,2),:)=nan;
    TRials(tr).vel(TRials(tr).blinks(:,2),:)=nan;
end

% tr=find(blIndx);
% 
% [emParams, radius]=cellfun(@microsaccPare,...
%     {TRials(blIndx).xy_filt},{TRials(blIndx).vel},...
%     num2cell(ones(1,sum(blIndx))*VFAC), num2cell(ones(1,sum(blIndx))*minDur),num2cell(ones(1,sum(blIndx))*SuppInt), ...
%     'UniformOutput',0); % detect EMs
% [TRials(blIndx).vThr]=radius{:}; % Velocity component thresholds
% msParams= cellfun(@saccpar, emParams,'UniformOutput',0); % get saccade params
% % % %
% 
% % % % assign EM paramaters to TRials  % % %
% % number of saccadic EM detected in each trial:
% [TRials(blIndx).numEM]=feed(cellfun(@size,msParams, num2cell(ones(1,sum(blIndx))*1),'UniformOutput',0));
% % index of trials with at least 1 EM
% NZindx=[TRials(blIndx).numEM]~=0;
% CorrIndx=[TRials.numEM]~=0 & blIndx;
% 
% [TRials(CorrIndx).EMon]=feed(cellfun(@(x) x(:,1)', msParams(NZindx),'UniformOutput',0));
% [TRials(CorrIndx).EMoff]=feed(cellfun(@(x) x(:,2)', msParams(NZindx),'UniformOutput',0));
% [TRials(CorrIndx).EMdur]=feed(cellfun(@(x) x(:,3)', msParams(NZindx),'UniformOutput',0));
% [TRials(CorrIndx).vPeak]=feed(cellfun(@(x) x(:,4)', msParams(NZindx),'UniformOutput',0));
% [TRials(CorrIndx).dist]=feed(cellfun(@(x) x(:,5)', msParams(NZindx),'UniformOutput',0));
% [TRials(CorrIndx).angDist]=feed(cellfun(@(x) x(:,6)', msParams(NZindx),'UniformOutput',0));
% [TRials(CorrIndx).amp]=feed(cellfun(@(x) x(:,7)', msParams(NZindx),'UniformOutput',0));
% [TRials(CorrIndx).angAmp]=feed(cellfun(@(x) x(:,8)', msParams(NZindx),'UniformOutput',0));
% % % %

dump=false(size(TRials));
dump(blIndx)=cellfun (@(BLNX,critEV) (find(BLNX,1,'first')-blinkBorder)<critEV,... % was the blink or border before the crucial event 
    {TRials(blIndx).blinks},... % blink data 
    num2cell(need(TRials, blIndx,critEvent, 'events'))'); % event timing on a per trial basis 

% % % RT outliers % % %
zRT=cell2mat(...
    cellfun( @(Obsvr)...
    zscore([TRials(strcmp({TRials.obs}, Obsvr)).keyRT]),... % zscore RTs separately for each observer (from IDlist)
    IDlist,'UniformOutput',false));

rtOutlier=abs(zRT)>2; % discard all the trials with RTzs > 2

%crop 
TRials=TRials (~(rtOutlier|dump));

%clean up 
% clear zRT rtOutlier dump missing overWrite blIndx

%% detect saccadic eye-movement
% % % %
vTh=vTh (~(rtOutlier|dump));
md=md (~(rtOutlier|dump));
si=si (~(rtOutlier|dump));

fprintf('Identifying saccades... \n')
% % % detect saccade like eye movements % % %
[emParams, radius]=cellfun(@microsaccPare,...
    {TRials.xy_filt},{TRials.vel},vTh, md,si, ...
    'UniformOutput',0); % detect EMs
[TRials.vThr]=radius{:}; % Velocity component thresholds
msParams= cellfun(@saccpar, emParams,'UniformOutput',0); % get saccade params
% % %

a=a(~(rtOutlier|dump));
% % % assign EM paramaters to TRials  % % %
% number of saccadic EM detected in each trial:
[TRials.numEM]=feed(cellfun(@size,msParams, a,'UniformOutput',0));
% index of trials with at least 1 EM
indx=[TRials.numEM]~=0;

[TRials(indx).EMon]=feed(cellfun(@(x) x(:,1)', msParams(indx),'UniformOutput',0));
[TRials(indx).EMoff]=feed(cellfun(@(x) x(:,2)', msParams(indx),'UniformOutput',0));
[TRials(indx).EMdur]=feed(cellfun(@(x) x(:,3)', msParams(indx),'UniformOutput',0));
[TRials(indx).vPeak]=feed(cellfun(@(x) x(:,4)', msParams(indx),'UniformOutput',0));
[TRials(indx).dist]=feed(cellfun(@(x) x(:,5)', msParams(indx),'UniformOutput',0));
[TRials(indx).angDist]=feed(cellfun(@(x) x(:,6)', msParams(indx),'UniformOutput',0));
[TRials(indx).amp]=feed(cellfun(@(x) x(:,7)', msParams(indx),'UniformOutput',0));
[TRials(indx).angAmp]=feed(cellfun(@(x) x(:,8)', msParams(indx),'UniformOutput',0));
% % %



badEM=arrayfun( @(Ti)... discard trials
    TRials(Ti).EMon... % if the onset of eye-movements
    ([TRials(Ti).amp]>MS.toss)... % with amplitude greater than the discard size
    <= TRials(Ti).events(critEvent),... % happened before the target
    1:length(TRials),'UniformOutput',false);

badEM=cellfun(@any, badEM); % discard trials with inappropriate EMs

% clean up
clear vt sr b
% clean up
clear vTh md si a

% % % blink stuff % % %


% 
% % also check for blinks
% Bmark=(([-1 -1]-scrCen)*DPP).*[1 -1]; % position blinks or other loss of gaze measurement would register as
% 
% %check each trial and EM for blink and then remove EMs containing a blink
% blinks=0;
% for selTR=1:length(sElect)
%     blIndx=logical([]);
%     for em=sElect(selTR).numEM:-1:1
%         period=sElect(selTR).EMon(em):sElect(selTR).EMoff(em);
%         blIndx(em)=any(sElect(selTR).xy_pos(period,1)==Bmark(1) & sElect(selTR).xy_pos(period,2)==Bmark(2));
%     end
%     if any(blIndx)
%         blinks=blinks+1;
%         % if any part of the EM was a blink
%         % flush the corresponding EM parameters
%         sElect(selTR).EMdur(blIndx)= [];
%         sElect(selTR).EMon(blIndx)= [];
%         sElect(selTR).EMoff(blIndx)= [];
%         sElect(selTR).vPeak(blIndx)= [];
%         sElect(selTR).dist(blIndx)= [];
%         sElect(selTR).angDist(blIndx)= [];
%         sElect(selTR).amp(blIndx)= [];
%         sElect(selTR).angAmp(blIndx)= [];
%         sElect(selTR).MScrit(blIndx)= [];
%         sElect(selTR).numEM=length(sElect(selTR).EMon);
%     end
% end
% 


sElect=TRials(~(badEM)); % sElect only trials without these problems


%create a field flagging detected EM satisfying MS criteria
[sElect.MScrit]=feed(cellfun(@(dXY,dT)...
    (dXY>=MS.amp.min &...
    dXY<= MS.amp.max & ...
    dT<MS.dur.max & ...
    dT>=MS.dur.min),... %anonymous function
    {sElect.amp}, {sElect.EMdur}, 'UniformOutput', false)); % input cells (distance & duration


% % in other words
% [sElect.MScrit]= [sElect.dist]>=nMS... % larger than min size
%     & [sElect.dist]<=xMS... % smaller than max
%     & [sElect.EMdur]<xDur... % shorter dur than max
%     & [sElect.EMdur]>=nDur; % longer dur than min



pKept= length(sElect)/TrialN;

fprintf('\nsElect structure prepared and ready for analysis!\n%.2f%% of trials kept\n\n',pKept*100)

%% clean up unnessary variables
clear msParams zRT badEM blIndx dump fileList fCode fDate fGroup trInd...
    fPath fSess indx missing overWrite radius rtOutlier sEss source...
    TRials f blinkBorder critEvent tr trialsPerSession