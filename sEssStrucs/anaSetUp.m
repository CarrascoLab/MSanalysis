%% expectations
for hide=[]
    
    % structure: sElect
    %
    % with fields:
    %     uniN
    %     obs
    %     file
    %     date
    %     Group
    %     sessN
    %     sType
    %     diagonal
    %     block
    %     trial
    %     locTarg
    %     gapLev
    %     gapSz
    %     gapLocT
    %     gapLocD
    %     response
    %     correct
    %     keyRT
    %     start
    %     events
    %     xy_pos
    %     xy_filt
    %     vel
    %     vThr
    %     numEM
    %     EMon
    %     EMoff
    %     EMdur
    %     vPeak
    %     dist
    %     angDist
    %     amp
    %     angAmp
    %     MScrit
end
%%  Define MS params, select conditions/Trials, init labels
addpath('../functions/');

for hide=1
    
    IDlist=unique({sElect.obs}); % get individual observers
    nObs= length (IDlist); % n observers
    nEvents= length(sElect(1).events); % n events
    lock=0; % event # to lock analysis to
    eFlags={'PreCueOn';    % manual labels of events
        'PreISIOn';
        'StimOn';
        'PostISIOn';
        'PostCueOn';
        'PostCueOff';
        'Clr'; };
    % % % labels % % %
    for hide=1
        %     sElect.(fields):
        for hide=1
            factFields={'sessN', 'Group','diagonal' }; % <- alter this if analyses will use other fields
            [cIndx, cLegs] =factIndx(sElect, {'obs', factFields{:}}); % get indexes for fields of interest
            LAB=cLegs; % obs + {factFields}
            LAB.events=eFlags;
            LAB.Group={'neutral trained', 'valid trained'}; % overwriting is prettier
            LAB.diagonal={'\','/'};
            %   same same!
            LAB.locTarg={'Left-side', 'Right-side'};
            LAB.gapLocT={'Left-side', 'Right-side'};
            LAB.gapLocD={'Left-side', 'Right-side'};
        end
        
        % misc
        for hide=1
            LAB.dCong={'Congruent', 'Incongruent', 'Opposed'};
            LAB.cues={'valid left', 'valid right', 'neutral left', 'neutral right'};
            LAB.Meas={'Accuracy', 'Response Times'};
            %	  LAB.none={'Trials in analysis period'};
            %     LAB.cDur={'300-500 ms', '600-800 ms', '900-1100 ms'};
            %     LAB.taEcc={'4º','8º'};
            %     LAB.start='start points';
            %     LAB.pcueOn='pre-cues';
            %     LAB.rcueOn='resp.-cues';
            %     LAB.tarOn='targets';
        end
        
        %colours
        for hide=1
            LAB.col.none=[0.4 .4 .4]; %; .4 .4 .4];
            LAB.col.Group=[.9 .6 0 ;0 .45 .75];
            LAB.col.Attn=[0 .45 .75];
            LAB.col.Neut=[.9 .6 0];
            LAB.col.Tar=[0 .75 .25];
            LAB.col.dCong=[0 .8 .2; .8 0 .2; 0.5 .1 .9];
            LAB.col.taEcc=[0.7 .1 .2; 0.5 .1 .9];
            LAB.col.sessN= [0.5 .1 .9;0.4 .4 .4; 0 .75 .25];
        end
    end
    
    % % % MS params % % %
    MS.amp.min=0.05; % min microsaccade amplitude (ºva)
    MS.amp.max=1; % max microsaccade amplitude (ºva)
    MS.dur.min =6; % min microsaccade duration(ms)
    MS.dur.max =70; % max microsaccade duration (ms)
    MS.toss=2; % size of eye movement to discard a trial
    
    % set some necessary values
    if lock==0
        WBmax=0;
        WAmax=max([sElect.events]);
        preLock=-1;
        postLock=min(need(sElect,'',nEvents,'events'));
    else
        WBmax= max(need(sElect,'',lock,'events')); % max window before lock
        WAmax= max(need(sElect,'',nEvents,'events')...
            -need(sElect,'',lock,'events')); % max window after lock
        
        preLock=min(need(sElect,'',lock,'events'));
    postLock=min(need(sElect,'',nEvents,'events') -need(sElect,'',lock,'events')); % displayed period
        %
        %                 WAmax= round(quantile(need(sElect,'',nEvents,'events')...
        %             -need(sElect,'',lock,'events'), .9)); % max window after lock
    end
    lAttice=1-WBmax:WAmax; % longest possible timeline
    tPointsMax=length(lAttice); % max possible timepoints
    
    % saccade direction matrix % 
    
    %        plotIndObs=false;  % do you want to make plots showing individual observer data in each condition?
    start=-preLock;     stop=postLock;    halfWindow=40; % temporal smoothing
    spread=start:stop;   % period around the lock to analyze
    polarAng={'angAmp','angDist'};
    typeAng=2; % choose direction measurement type
    
    [i,j,v]=deal(zeros(1,sum([sElect.EMdur])));
    cnt=1;
    for nT= 1:length(sElect) % for each trial
        %         emOnOff=[sElect(nT).EMon;sElect(nT).EMoff]+(WBmax-sElect(nT).events(lock)); % start and end points of eye-movements in lAttice coordinates
        for emN=1:sElect(nT).numEM
            %             section=max(emOnOff(1,emN)-halfWindow,1): min(emOnOff(2,emN)+halfWindow,length(lAttice)); % duration of EM + window
            if lock~=0
                section=(sElect(nT).EMon(emN):sElect(nT).EMoff(emN))... %  EM interval
                +(WBmax-sElect(nT).events(lock)); %adjusted to synch lock times
            else
                section=(sElect(nT).EMon(emN):sElect(nT).EMoff(emN));
            end
            dur=length(section);            % duration  of EM
            i(cnt:cnt+dur-1)=ones(1,dur)*nT;    % row index i.e., trialf
            j(cnt:cnt+dur-1)=section;                % column index i.e., synched interval
            v(cnt:cnt+dur-1)=ones(1,dur)*sElect(nT).(polarAng{typeAng})(emN); % fill vector of sacDir values
            cnt=cnt+dur; % keep count
            %             sacc(nT,section)=true;
            %             saccDir(nT,section)= sElect(nT).(polarAng{typeAng})(emN); %catDir( sElect(nT).(polarAng{typeAng})(emN), sElect(nT).diagonal, sElect(nT).locTarg);
        end
    end
    
    saccDir=sparse(i,j,v,length(sElect), length(lAttice));
    
end
