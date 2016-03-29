% msg2structs.m for PLAttAcuity
% Merge .msg, .dat & .mat in trial structure for given session.

% %% from scratch
clear all
addpath('../functions/');
dFormat='yyyyMMdd-HHmm'; % format of date in PL_ATTN_ACC data

% experiment design parameters
DIST   = 114;         % Monitor distance in cm
xPx   = 1280;       % monitor pixels along x-axis (1280X960)ç
yPx   = 960;       % monitor pixels along y-axis (1280X960)
xCm   = 40;         % x Monitor width in cm (40X30 cm)
yCm   = 30;         % x Monitor width in cm (40X30 cm)
scrCen = [xPx yPx]/2;  % screen center (intial fixation position)
DPP = pix2deg(xPx,xCm,DIST,1); %pix2deg(xPx,xCm,DIST,1); % degrees per pixel
PPD = deg2pix(xPx,xCm,DIST,1); % pixels per degree
vaLIMS= scrCen*DPP; % visual-angle screen edge eccentricity relative to center

%  file locations %
edfSource= 'Data/'; PathCrop= length(edfSource)+1;
matpath = edfSource;
DatAndMsg='../raw/'; % location of to-be-processed dat files
% result locations %
edfDeposit= '../edf/';
processed='processed/'; problem='problem/';



EDFs=nestList(edfSource, '*.edf');
nEDF=length(EDFs);
fprintf('%d edf files found\n', nEDF)

for fileN=1:nEDF
    fprintf('Extracting %s - %d of %d\n',EDFs(fileN).name, fileN, nEDF)
    
    % maintains file structure in the destination folder
    newEDFLoc=[edfDeposit, EDFs(fileN).path(PathCrop:end)];
    rawOutLoc=[DatAndMsg, EDFs(fileN).path(PathCrop:end)];
    
    % if the goal folders don't exist, create them
    if ~exist(newEDFLoc,'dir')
        mkdir(newEDFLoc)
    end
    
    if ~exist(rawOutLoc,'dir')
        mkdir(rawOutLoc)
    end
    
    % in case there are problems with any of the files...
    try
        copyfile([EDFs(fileN).path, EDFs(fileN).name],... % from source location
            [newEDFLoc, EDFs(fileN).name]); % to processed edf folder
        
        movefile([EDFs(fileN).path, EDFs(fileN).name]); % move edf into Prepare folder
        unix  ('./prepare.sh') %('./preparemv.sh') % apply edf2asc (output to '../raw/')
        
        delete (EDFs(fileN).name) % delete extra edf
        
        movefile([DatAndMsg, EDFs(fileN).name(1:end-4), '*'],...
            rawOutLoc); % move dat & msg into apropriate raw sub-folder
        
    catch    % if something doesn't work
        fprintf('\n\nProblem with %s \nmoving to %s\n',EDFs(fileN).name, problem)
        movefile(EDFs(fileN).name, problem); % move edf into problem folder
        delete([DatAndMsg EDFs(fileN).name(1:end-4)])
    end
    
end


fprintf('\n\nFinished processing EDFs\n')

%%  collect

addpath('../functions/');
dFormat='yyyyMMdd-HHmm'; % format of date in PL_ATTN_ACC data

% experiment design parameters
DIST   = 114;         % Monitor distance in cm
xPx   = 1280;       % monitor pixels along x-axis (1280X960)ç
yPx   = 960;       % monitor pixels along y-axis (1280X960)
xCm   = 40;         % x Monitor width in cm (40X30 cm)
yCm   = 30;         % x Monitor width in cm (40X30 cm)
scrCen = [xPx yPx]/2;  % screen center (intial fixation position)
DPP = pix2deg(xPx,xCm,DIST,1); %pix2deg(xPx,xCm,DIST,1); % degrees per pixel
PPD = deg2pix(xPx,xCm,DIST,1); % pixels per degree
vaLIMS= scrCen*DPP; % visual-angle screen edge eccentricity relative to center

DatAndMsg='../raw/'; % location of to-be-processed msg & dat files
PathCrop= length(DatAndMsg)+1;
matpath = 'Data/';

% result locations %
edfDeposit= '../edf/';
processed='../processed/'; problem='problem/';
outFold ='../sEssStrucs/Prepped/';


nFiles=416; % (any value ~=0)

%  sEssion - struct Files have the following fields :
sessFields={
    'obs'
    'date'
    'type'
    'group'
    'diags'
    'trials'};

%trials has the subfields: 
trialFields={
    'block'
    'trial'
    'diagonal'
    'locTarg'
    'gapLev'
    'gapSz'
    'TgapLoc'
    'DgapLoc'
    'response'
    'correct'
    'keyRT'
    'trialStart'
    'events'};

% xy_pos & blinks are also added for each trial

% events contains time data (ms) relative to trial start :
% experiment specific....
% 'tedfPreCueOn'
% 'tedfPreISIOn'
% 'tedfStimOn'
% 'tedfPostISIOn'
% 'tedfPostCueOn'
% 'tedfPostCueOff'
% 'tedfClr'

% allFiles=nestList(DatAndMsg,'*.msg');
% totN=length(allFiles); 
% problemFiles=0;
% probList=struct;

while nFiles~=0
    % find all files in the folder being processed
    fileList=nestList(DatAndMsg,'*.msg');
    nFiles=length(fileList); % keep running till there are none left
    
    % for each file...
    try
        
        for fileN=1:nFiles % runs for all files if there are no problems
            
            fCode=fileList(fileN).name(1:end-4); % name of fileList(f) minus filetype
            msgstr = [fCode,'.msg']; % .msg file name (message data)
            datstr = [fCode,'.dat']; % .dat file name (gaze position data)
            matstr= [fCode,'.mat']; %  .mat file name (output structure)
            middlePath= fileList(fileN).path(PathCrop:end);
            
            
            % completed session structures go here
            outPath = [outFold...
                middlePath];
            
            % mat & dat files that have been processed go here
            procPath = [processed...
                middlePath];
            
            
            % if there's an error while trying to form the struct, the data files
            % will be pushed here.
            probPath = [processed...
                problem...
                middlePath];
            
            
            % open the msg file
            msgfid = fopen([fileList(fileN).path   msgstr],'r');
            
            % get observer ID and session date
            [obs,sDate]=feed(textscan( fCode, '%*s %s %s', 'Delimiter','_'));
            obs=obs{1}; sDate=datetime(sDate,'InputFormat',dFormat);
            
            fprintf(1,'\nprocessing %s.msg... ',fCode);
            stillTheSameSubject = true;
            
            trialCell = {};
            while stillTheSameSubject
                % predefine critical variables
                defNaNs;
                
                stillTheSameTrial = true;
                while stillTheSameTrial
                    
                    line = fgetl(msgfid); % get a line from the .msg file
                    
                    if ~ischar(line)    % end of file if non-character
                        stillTheSameSubject = 0;
                        break;
                    end
                    
                    if  stillTheSameSubject && ~isempty(line) % skip empty lines
                        lArr = strread(line,'%s'); % array of strings in line
                        
                        
                        if  length(lArr) >= 3 %% to crop problem files use tCut as new start-point and insert ->  str2num( la{2})>tCut &&
                            
                            % these flags will depend on the messages coded into
                            % the EDFs during the experiment
                            switch char(lArr(3))
                                case 'TRIAL_START'
                                    trial = str2double(char(lArr(4)));
                                case 'EVENT_FixationDot'
                                    tedfFix = str2double(char(lArr(2)));
                                case 'EVENT_preCueOn'
                                    tedfPreCueOn = str2double(char(lArr(2)));
                                case 'EVENT_preISIOn'
                                    tedfPreISIOn = str2double(char(lArr(2)));
                                case 'EVENT_stimOn'
                                    tedfStimOn = str2double(char(lArr(2)));
                                case 'EVENT_postISIOn'
                                    tedfPostISIOn = str2double(char(lArr(2)));
                                case 'EVENT_postCueOn'
                                    tedfPostCueOn  = str2double(char(lArr(2)));
                                case 'EVENT_postCueOff'
                                    tedfPostCueOff = str2double(char(lArr(2)));
                                case 'EVENT_ClearScreen'
                                    tedfClr = str2double(char(lArr(2)));
                                case 'TRIAL_END'
                                    trial2 = str2double(char(lArr(4)));
                                case 'TrialData'
                                    % basics
                                    block       = str2double(char(lArr(4)));
                                    trial3      = str2double(char(lArr(5)));
                                    
                                    %Trial data
                                    diagonal   = str2double(char(lArr(6)));
                                    tLoc   = str2double(char(lArr(7)));
                                    gapLev  = str2double(char(lArr(8)));
                                    gapSz   = str2double(char(lArr(9)));
                                    gapLocT   = str2double(char(lArr(10)));
                                    gapLocD      = str2double(char(lArr(11)));
                                    
                                    % response data
                                    response     = str2double(char(lArr(12)));
                                    correct     = str2double(char(lArr(13)));
                                    keyRT      = str2double(char(lArr(14)));
                                    
                                    % time data (computer timestamps)
                                    tFix        = str2double(char(lArr(15)));
                                    tpreCueOn         = str2double(char(lArr(16)));
                                    tpreISIOn       = str2double(char(lArr(17)));
                                    tStimOn   = str2double(char(lArr(18)));
                                    tStimOff        = str2double(char(lArr(19)));
                                    tPostCueOn = str2double(char(lArr(20)));
                                    trespToneOn   = str2double(char(lArr(21)));
                                    tRes     = str2double(char(lArr(22)));
                                    tClear    = str2double(char(lArr(23)));
                                    
                                    stillTheSameTrial = 0;
                            end
                        end
                    end
                end
                
                %tedfClr%
                % check if trial ok and all messages available
                if trial==trial3 && sum(isnan([trial trial3 tedfFix tedfPreCueOn tedfPreISIOn tedfStimOn...
                        tedfPostISIOn tedfPostCueOn tedfPostCueOff  tedfClr ]))==0
                    everythingAvailable = 1;
                else
                    everythingAvailable = 0;
                end
                
                if everythingAvailable
                    
                    tedfPreCueOn    = tedfPreCueOn - tedfFix;
                    tedfPreISIOn    = tedfPreISIOn - tedfFix;
                    tedfStimOn      = tedfStimOn - tedfFix;
                    tedfPostISIOn = tedfPostISIOn - tedfFix;
                    tedfPostCueOn  = tedfPostCueOn  - tedfFix;
                    tedfPostCueOff     = tedfPostCueOff - tedfFix;
                    tedfClr        = tedfClr - tedfFix;
                    
                    tEvents=[tedfPreCueOn tedfPreISIOn tedfStimOn tedfPostISIOn tedfPostCueOn tedfPostCueOff tedfClr];
                    % information concerning a trial
                    trialCell=[trialCell;{block trial diagonal tLoc gapLev gapSz gapLocT gapLocD response correct keyRT ...
                        tedfFix tEvents}];
                    
                elseif trial~=trial2
                    %fprintf(1,'\nMissing Message between TRIALID %i and trialData %i (ignore if last trial)',trial,trial2);
                end
            end
            fclose(msgfid);
            
            % form trials structure
            trials=cell2struct(trialCell,trialFields,2);
            
            % % load data from fileList(f) % %
            datfid=fopen([fileList(fileN).path  datstr]); % open dat file
            datDump=textscan(datfid, '%f %f %f %*f'); % dump contents into a cell
            fclose(datfid); % close file
            
            nTrials=size(trials); % number of trials present in incoming data
            nEvents=length(trials(1).events);% # events
            
            tStamps= [[trials.trialStart]' [trials.trialStart]'+need(trials,:,nEvents,'events')]; % start/stop in timeStamp units
            
            tIndx=zeros(size(tStamps'));
            [~,~,tIndx(:)]=intersect(tStamps,datDump{1}); %find indexes of start/stop time stamps
            
            tDuration=arrayfun(@ (start, stop) start:stop, tIndx(1,:),tIndx(2,:),'uniformoutput',false); % interval of each trial t
            
            %     [sEss.xy_pos]=feed(cellfun(@(interval)... % pull out data
            %         [datDump{2}(interval)-scrCen(1) -(datDump{3}(interval)-scrCen(2))]*DPP,tDuration,'uniformoutput',false));
            
            % get raw data values over trial intervals
            [trials.xy_pos]=feed(cellfun(@(interval) [datDump{2}(interval) (datDump{3}(interval))],tDuration,'uniformoutput',false));
            % identify missing samples
            [trials.blinks] = feed(cellfun(@(POS) POS==-1, {trials.xy_pos}', 'uniformoutput',false));
            % center units (i.e., 0,0 == central fixation)
            [trials.xy_pos] =feed(cellfun(@(POS) POS-ones(length(POS),1)*scrCen,{trials.xy_pos}', 'uniformoutput',false));
            % convert to ºVA and invert y-axis so that larger values correspond
            % with higher up on the screen
            [trials.xy_pos]= feed(cellfun(@(POS) [POS(:,1), -(POS(:,2))]*DPP,{trials.xy_pos}', 'uniformoutput',false));
            
            % load the corresponding mat-file to obtain session details
            load( [matpath...
                middlePath...
                matstr],'-mat', 'constant'); %,'scr');
            
            % arrange all the session data
            sessCell= {obs...
                sDate...
                constant.SESS...
                constant.GROUP...
                constant.DIAG...
                trials};
            % convert to a structure.
            sEss=cell2struct(sessCell,sessFields,2);
            
            if ~exist(outPath,'dir')
                mkdir(outPath)
            end
            
            save([outPath matstr],'sEss')
            fprintf(' \tSuccess! \nSession structure saved in:\t''%s''\n',outPath);
            
            % move msg & dat files into processed/ folder if successful
            if ~exist(procPath,'dir')
                mkdir(procPath)
            end
            movefile([fileList(fileN).path fCode '*'], procPath)
            
        end
    catch
        % move files to a problem folder if catch
        fprintf('\t Uh-oh! There was a problem. \nSetting aside %s for now...\n',fCode);
        if ~exist(probPath,'dir')
            mkdir(probPath)
        end
        % move msg & dat files into processed/ folder if successful
        movefile([fileList(fileN).path fCode '*'], probPath)
    end
    
end
fprintf(1,'\n\nOK!!\n');
