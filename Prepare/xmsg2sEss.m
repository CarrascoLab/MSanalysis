% xmsg2struct.m for PLAttAcuity
% Merge .msg, .dat & .mat in trial structure for given session.

% %% from scratch
% % 
% % clear all
% % unix ('./preparemv.sh') % ('./prepare.sh') % 

%%  collect
nFiles=416; % (any value ~=0)

addpath('../functions/');
%  file locations %
source= ''; matpath = source;% i.e., pwd, could be altered maybe?
dataTODOpath='../raw/'; % location of to-be-processed dat files 
% result locations %
processed='processed/'; pblem='pblem/';
outpath ='../sEssStrucs/';

dFormat='yyyymmdd-HHMM'; % format of date in PL_ATTN_ACC data 

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
    
%  sEssion - struct Files have the following fields (+ SessType & Group)  :
fields={'obs'
'sEssDate'
'block'
'trial'
'diagonal'
'locTarg'
'gapLev'
'gapSz'
'gapLocT'
'gapLocD'
'response'
'correct'
'keyRT'
'start'
'events'};

% events contains: 
% 'tedfPreCueOn'
% 'tedfPreISIOn'
% 'tedfStimOn'
% 'tedfPostISIOn' 
% 'tedfPostCueOn'
% 'tedfPostCueOff'
% 'tedfClr'


while nFiles~=0
fileList=dir(sprintf( '%s*.msg',dataTODOpath));
nFiles=length(fileList);  

% for each file... 
try

for f=1:nFiles
    
    fCode=fileList(f).name(1:end-4); %file name
    msgstr = sprintf('%s.msg',fCode); 
    datstr = sprintf('%s.dat',fCode);
    matstr= sprintf('%s.mat',fCode);
    msgfid = fopen([dataTODOpath   msgstr],'r');
%     [id,date]=cell2mat(feed(textscan( fCode, '%*s %s %s', 'Delimiter','_')));
    
    [id,sessDate]=feed(textscan( fCode, '%*s %s %s', 'Delimiter','_'));
    id=id{1}; sessDate=sessDate{:};
    
    fprintf(1,'\nprocessing ... %s.msg ',fCode);
    stillTheSameSubject = 1;
    
    mCell = {};
    while stillTheSameSubject
        % predefine critical variables
        defNaNs;
        
        stillTheSameTrial = 1;
        while stillTheSameTrial
            
            line = fgetl(msgfid);
            if ~ischar(line)    % end of file
                stillTheSameSubject = 0;
                break;
            end
            
            if ~isempty(line) && stillTheSameSubject % skip empty lines
                la = strread(line,'%s'); % array of strings in line
                
                
                if  length(la) >= 3 %% to crop problem files use tCut as new start-point and insert ->  str2num( la{2})>tCut &&
                    switch char(la(3))
                        case 'TRIAL_START'
                            trial = str2double(char(la(4)));
                        case 'EVENT_FixationDot'
                            tedfFix = str2double(char(la(2)));
                        case 'EVENT_preCueOn'
                            tedfPreCueOn = str2double(char(la(2)));
                        case 'EVENT_preISIOn'
                            tedfPreISIOn = str2double(char(la(2)));
                        case 'EVENT_stimOn'
                            tedfStimOn = str2double(char(la(2)));
                        case 'EVENT_postISIOn'
                            tedfPostISIOn = str2double(char(la(2)));
                        case 'EVENT_postCueOn'
                            tedfPostCueOn  = str2double(char(la(2)));
                        case 'EVENT_postCueOff'
                            tedfPostCueOff = str2double(char(la(2)));
                        case 'EVENT_ClearScreen'
                            tedfClr = str2double(char(la(2)));
                        case 'TRIAL_END'
                            trial2 = str2double(char(la(4)));
                        case 'TrialData'
                            % basics
                            block       = str2double(char(la(4)));
                            trial3      = str2double(char(la(5)));
                            
                            %Trial data
                            diagonal   = str2double(char(la(6)));
                            tLoc   = str2double(char(la(7)));
                            gapLev  = str2double(char(la(8)));
                            gapSz   = str2double(char(la(9)));
                            gapLocT   = str2double(char(la(10)));
                            gapLocD      = str2double(char(la(11)));
                            
                            % response data
                            response     = str2double(char(la(12)));
                            correct     = str2double(char(la(13)));
                            keyRT      = str2double(char(la(14)));
                            
                            % time data (computer timestamps)
                            tFix        = str2double(char(la(15)));
                            tpreCueOn         = str2double(char(la(16)));
                            tpreISIOn       = str2double(char(la(17)));
                            tStimOn   = str2double(char(la(18)));
                            tStimOff        = str2double(char(la(19)));
                            tPostCueOn = str2double(char(la(20)));
                            trespToneOn   = str2double(char(la(21)));
                            tRes     = str2double(char(la(22)));
                            tClear    = str2double(char(la(23)));
                            
                            stillTheSameTrial = 0;
                    end
                end
            end
        end
        
        %tedfClr%
        % check if trial ok and all messages available
        if trial==trial3 && sum(isnan([trial trial3 tedfFix tedfPreCueOn tedfPreISIOn tedfStimOn tedfPostISIOn tedfPostCueOn tedfPostCueOff  tedfClr ]))==0
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
            mCell=[mCell;{id sessDate  block trial diagonal tLoc gapLev gapSz gapLocT gapLocD response correct keyRT ...
                tedfFix tEvents}];
            
        elseif trial~=trial2
            %fprintf(1,'\nMissing Message between TRIALID %i and trialData %i (ignore if last trial)',trial,trial2);
        end
    end
    fclose(msgfid);
    sEss=cell2struct(mCell,fields,2);
    load(sprintf('%s%s.mat',matpath,fCode),'-mat', 'constant'); %,'scr');
    [sEss.sType]=deal(constant.SESS);
    
    % % load data from fileList(f) % %
    datfid=fopen([dataTODOpath datstr]); % open dat file
    datDump=textscan(datfid, '%f %f %f %*f'); % dump contents
    fclose(datfid); % close  
    nTrials=length(sEss); % number of trials present in incoming data 
    nEvents=length(sEss(1).events);
    
    tStamps= [[sEss.start]' [sEss.start]'+need(sEss,:,nEvents,'events')]; % start/stop timestamps
    
    tIndx=zeros(size(tStamps'));
    [~,~,tIndx(:)]=intersect(tStamps,datDump{1}); %find indexes of time stamps 
    
    tDuration=arrayfun(@ (start, stop) start:stop, tIndx(1,:),tIndx(2,:),'uniformoutput',false); % interval of each trial t
    
%     [sEss.xy_pos]=feed(cellfun(@(interval)... % pull out data
%         [datDump{2}(interval)-scrCen(1) -(datDump{3}(interval)-scrCen(2))]*DPP,tDuration,'uniformoutput',false));
    
     [sEss.xy_pos]=feed(cellfun(@(interval) [datDump{2}(interval) (datDump{3}(interval))],tDuration,'uniformoutput',false));
%     sEss.blinks=xy_pos==-1;
    [sEss.blinks] = feed(cellfun(@(POS) POS==-1, {sEss.xy_pos}', 'uniformoutput',false));
    [sEss.xy_pos] =feed(cellfun(@(POS) POS-ones(length(POS),1)*scrCen,{sEss.xy_pos}', 'uniformoutput',false));
    [sEss.xy_pos]= feed(cellfun(@(POS) [POS(:,1), -(POS(:,2))]*DPP,{sEss.xy_pos}', 'uniformoutput',false));
    

    outstr = sprintf('%s%s',outpath,matstr);
    save(outstr,'sEss')
     fprintf(1,' Success!\n',fCode);
%     % move files into processed/ folder if succesful  
    unix(sprintf('mv %s%s %s', dataTODOpath, msgstr,sprintf('%s%s%s', dataTODOpath, processed, msgstr)));
    unix(sprintf('mv %s%s %s', dataTODOpath, datstr,sprintf('%s%s%s', dataTODOpath, processed, datstr)));
	unix(sprintf('mv %s%s %s', source, matstr,sprintf('%s%s%s', source, processed, matstr)));
end
catch
    % move files to a problem folder if catch
    fprintf(1,'\nproblem processing %s.msg\nSet aside for now...\n',fCode);
    unix(sprintf('mv %s%s %s', dataTODOpath, msgstr,sprintf('%s%s%s', dataTODOpath, pblem, msgstr)));
    unix(sprintf('mv %s%s %s', dataTODOpath, datstr,sprintf('%s%s%s', dataTODOpath, pblem, datstr)));
end

end 
fprintf(1,'\n\nOK!!\n');
