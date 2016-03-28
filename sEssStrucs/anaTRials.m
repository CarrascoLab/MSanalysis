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
    lock=3; % event # to lock analysis to
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
    else
        WBmax= max(need(sElect,'',lock,'events')); % max window before lock
        WAmax= max(need(sElect,'',nEvents,'events')...
            -need(sElect,'',lock,'events')); % max window after lock
        %
        %                 WAmax= round(quantile(need(sElect,'',nEvents,'events')...
        %             -need(sElect,'',lock,'events'), .9)); % max window after lock
    end
    lAttice=1-WBmax:WAmax; % longest possible timeline
    tPointsMax=length(lAttice); % max possible timepoints
    
    
    
end

%% main sequence plot
% mainSeq(sElect, MS)
for hide=[]
    figure
    
    msInd=[sElect.MScrit];
    a=[sElect.amp] ;v=[sElect.vPeak] ; d= [sElect.EMdur];
    
    subplot(2,2,1)
    % main sequence
    scatter(a(msInd),v(msInd),40,[.6 .6 .6],'marker','.')
    set(gca,'XScale','log')
    set(gca,'YScale','log')
    title('Main Sequence')
    xlabel('Amplitude (º)')
    ylabel('Peak Vel. (º/s)')
    xlim([MS.amp.min-.01 MS.amp.max+1])
    
    subplot(2,2,2)
    % MS Amplitude
    hist(a(msInd),100)
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor',[.8 .8 .8],'EdgeColor',[.6 .6 .6])
    
    title('Amplitude')
    xlabel('Amplitude (º)')
    ylabel('Frequency')
    
    subplot(2,2,3)
    % Peak Velocity of MS
    hist(v(msInd),100);
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor',[.8 .8 .8],'EdgeColor',[.6 .6 .6])
    
    title('Peak Velocity')
    xlabel('Peak Vel. (º/s)')
    ylabel('Frequency')
    
    subplot(2,2,4)
    % MS duration
    hist(d(msInd),100)
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor',[.8 .8 .8],'EdgeColor',[.6 .6 .6])
    
    title('Duration')
    xlabel('Duration (ms)')
    ylabel('Frequency')
    
    for hide=[]
        prbVel=cellfun(@max, {sElect.vPeak},'UniformOutput',false);
        prbVel(cellfun(@isempty, prbVel))={nan};
        prbVel=cell2mat(prbVel);
        cutoff=quantile(v, .95);
        pCrit=find(prbVel>cutoff);
        [ pCrit(1:idivide(length(pCrit),int32(2)))' pCrit( (1:idivide(length(pCrit),int32(2)))+ idivide(length(pCrit),int32(2)) )' ]
    end % checking extreme peak Velocities
end

%% MSrates
% % % ANALYSIS SETUP % % %
if lock == 0
    preLock=-1;
    postLock=min(need(sElect,'',nEvents,'events'));
else
    preLock=min(need(sElect,'',lock,'events'));
    postLock=min(need(sElect,'',nEvents,'events') -need(sElect,'',lock,'events')); % displayed period
end
%     plotIndObs=false;  % do you want to make plots showing individual observer data in each condition?
factFields={'sessN', 'Group','diagonal' };
[cIndx, cLegs] =factIndx(sElect, {'obs', factFields{:}}); % get indexes for fields of interest

figTitles= {'Pre-training'    'Group 1 Change'    'Group 2 Change'    'Post-training'};
defineGroups  = {  factFields %factor fields  determines what fields the below conditions index
    ...
    {  2,  1,  [1 2]   % pretraining
    2,  2,  [1 2] }
    ...
    {  2,  1,  [1 2]   % G1 change
    3,  1,  [1 2] }
    ...
    {  2,  2,  [1 2]   % G2 change
    3,	2,	[1 2] }
    ...
    {  3,  1,  [1 2]   % pretraining
    3,  2,  [1 2] }	};
F2P=prepToPlot(sElect, figTitles, defineGroups,LAB); % figures to be plotted



nFigs=length(F2P);
for hide=1
    F2P=rateAna(sElect,F2P, factFields, lock, lAttice);
    for fig=length(F2P):-1:1 % plot each of the separate figures
        beginInd=find(lAttice==-preLock);
        endInd=find(lAttice==postLock);
        
        figure;
        
        % cmap assumes two groups...
        [hLine{fig},hPatch{fig}]=boundedline(lAttice(beginInd:endInd),...
            F2P(fig).results.avRate( beginInd:endInd,:),...
            F2P(fig).results.rateSEM(beginInd:endInd,1,:),...
            'cmap', LAB.col.Group, 'transparency', .3, 'alpha'); hold on;
        set(hLine{fig}, 'HandleVisibility','off');
        
        % make pretty
        legend(F2P(fig).legend,'Location','NorthWest')
        ylabel('Rate (Hz)'); xlabel ('Time (ms - relative to lock)');
        xlim([-preLock postLock]) % xBounds{fig})
        ylim([0 5])
        grid
        title(F2P(fig).titles)
        
        %    event labeling
        plotEvents(sElect,lock,preLock,postLock,[LAB.events]);
    end
end

for indObs=[]
    indTitles=   cLegs.obs;
    indObservers  = cell( nObs+1,1);
    indObservers {1}={'sessN', 'obs'};
    for ObserverN = 1: nObs
        indObservers {ObserverN+1} = num2cell([(1:length(cLegs.sessN))' ones(3,1)*ObserverN])  ;
    end
    IndPrePost=prepToPlot(sElect, indTitles, indObservers,LAB); % figures to be plotted
    beginInd=find(lAttice==-preLock);
    endInd=find(lAttice==postLock);
    
    for dataSet= IndPrePost
        
        figure;
        
        
%         [hLine{fig},hPatch{fig}]=boundedline(lAttice(beginInd:endInd),...
%             dataSet.results.avRate( beginInd:endInd,:),...
%             dataSet.results.rateSEM(beginInd:endInd,1,:),...
%             'cmap', LAB.col.sessN, 'transparency', .3, 'alpha'); hold on;
%         set(hLine{fig}, 'HandleVisibility','off');
        for lineN=1:dataSet.nGrps
            plot( lAttice(beginInd:endInd), dataSet.results.avRate(beginInd:endInd,lineN),'color',LAB.col.sessN(lineN,:));
            hold on
        end
        % make pretty
        legend(dataSet.legend,'Location','NorthWest')
        ylabel('Rate (Hz)'); xlabel ('Time (ms - relative to lock)');
        xlim([-preLock postLock]) % xBounds{fig})
%         ylim([0 5])
        grid
        title(sprintf('%s (%s)', dataSet.titles, sElect(find(dataSet.Indx', 1, 'first')).Group))
        
        %    event labeling
        plotEvents(sElect,lock,preLock,postLock,[LAB.events]);
    end
end
for hide =[]
    raster subplot
    sp1=subplot('position',[.1 .08 .88 .15]);
    MSrast(sElect(cIndx.(conds){1}),lock,preLock), hold on
    %         set(sp1, 'YTickLabel', {});
    ylabel(cLegs.(conds){1})
    xlabel('Time (ms)');
    xlim([-preLock postLock])
    
    sp2=subplot('position',[.1 .25 .88 .15]);
    MSrast(sElect(cIndx.(conds){2}),lock,preLock), hold on
    ylabel(cLegs.(conds){2})
    set(sp2, 'XTickLabel', {});
    %         set(sp1, 'YTickLabel', {});
    %         xlabel('Time (ms)');
    xlim([-preLock postLock])
    
    % plot bounded line
    sp3=subplot('position',[.1 .44 .88 .5]);
    set(sp3, 'XTickLabel', {});
    %
end


for hide=[]
    cols=get(groot,'defaultaxescolororder');
    for s=1:nObs
        figure;
        for f=1:nFigs
            plot(lAttice, squeeze(rAteArrays{f}(:,s,1)),'--','color', cols(f,:), 'LineWidth', 1.5), hold on
            plot(lAttice, squeeze(rAteArrays{f}(:,s,2)), 'color', cols(f,:), 'LineWidth', 1.5)
            
        end
        xlim([-preLock postLock]); %xlim([max(max(lims(:,:, fig, 1))), min(min(lims(:,:,fig,2)))])
        ylim([0 8])
        xlabel('Time (ms)');
        ylabel('Rate (Hz)');
        title(sprintf('MSrate for %s by cue-type', IDlist{s}))
        legend(legEnts([1 2 1 2 1 2]))
        grid
    end
end



%% proper rate difference measure (within groups)
for hide=1
    % this stuff is not generalized... CAUTION!!
    clear avgDiff indDiffRate stdAvgDiff
    for fig=2:-1:1
        %     for fig=length(cLegs.Group):-1:1
        %         if fig~=1
        indDiffRate{fig}=F2P(fig+1).results.iRates{2}-F2P(fig+1).results.iRates{1};
        %         indDiffRate{fig}=sepFigs{fig+1,6}{2}-sepFigs{fig+1,6}{1};
        avgDiff(:,fig)=nanmean(indDiffRate{fig},2);
        tempDiffSEM(:,fig)=1.96*(nanstd(indDiffRate{fig},0,2)./sqrt(F2P(fig).group(1).nMems));
        %         else
        %             indDiffRate{fig}=[F2P(2).results.iRate{2}-F2P(2).results.iRate{1} F2P(3).results.iRate{2}-F2P(3).results.iRate{1}];
        %             %         indDiffRate{fig}=sepFigs{fig+1,6}{2}-sepFigs{fig+1,6}{1};
        %             avgDiff(:,fig)=nanmean(indDiffRate{fig},2);
        %             stdAvgDiff(:,fig)=nanstd(indDiffRate{fig},0,2);
        %         end
    end
    
    diffCI=nan(size(tempDiffSEM,1),1 ,size(tempDiffSEM,2));
    diffCI(:)=tempDiffSEM(:);
    figure
    
    [diffLines,diffPatchs]=boundedline(lAttice(beginInd:endInd), avgDiff(beginInd:endInd,:), diffCI(beginInd:endInd,1,:), 'transparency', .3, 'alpha');
    set(diffLines, 'HandleVisibility','off');
    
    %     set(diffLines(1),'Color', LAB.col.none);
    %     set(diffPatchs(1),'FaceColor', LAB.col.none);
    
    set(diffLines(1),'Color', LAB.col.Attn);
    set(diffPatchs(1),'FaceColor', LAB.col.Attn);
    
    set(diffLines(2),'Color', LAB.col.Neut);
    set(diffPatchs(2),'FaceColor', LAB.col.Neut);
    
    % make pretty
    legend({'N-trained' 'V-trained'},'Location','NorthWest')
    ylabel('? Rate (Hz)');
    xlim([-preLock postLock]) % xBounds{fig})
    %         ylim([0 5])
    grid
    %    event labeling
    title('Rate change (post-pre)')
    plotEvents (sElect,lock, preLock, postLock, LAB.events)
    
end

for IND_OBS=[]
    for G=2:-1:1
        figure
        L.(cLegs.Group{G})=plot (lAttice(beginInd:endInd), indDiffRate{G}(beginInd:endInd,:), 'color',LAB.col.Group(G,:) );
        hold on; % L.(cLegs.Group{2})=plot (lAttice(b:e), indDiffRate{2}(b:e,:), 'g');
        
        legend([L.(cLegs.Group{G})(1)],'Ind-Obs', 'location', 'NorthWest')
        ylabel('? Rate (Hz)');
        xlim([-preLock postLock]) % xBounds{fig})
        grid
        title(sprintf('Rate change: %s', LAB.Group{G}))
        
        plotEvents (sElect,lock, preLock, postLock, LAB.events)
    end
end
%% gross direction plots....
for hide=[]
    nPoints=100;
    polarAng={'angAmp','angDist'};
    typeAng=2; % choose direction measurement type
    clear poBins
    for fig=length(F2P):-1:1
        figure
        for G =1:  F2P(fig).nGrps
            [d, poBins{fig,G}]= map([sElect(  F2P(fig).Indx(G,:) ).(polarAng{typeAng})],nPoints);
            
            polar(d, poBins{fig,G}); hold on
        end
        title(sprintf('Gross EM º: %s', F2P(fig).titles))
        legend(F2P(fig).legend)
    end
end

%% ind observer characteristics
for hide= []
    nPoints=50;
    for oN=nObs:-1:1
        figure
        [tb,tv]=map([sElect(cIndx.obs{oN}).(polarAng{typeAng})], nPoints);
        obRose{oN}=polar(tb,tv);
        
        title ([' EM rose: ', cLegs.obs{oN}])
    end
    
    pplscore=cell(nObs,2);
    
    % collects accuracies and plots PFs for each observer
    for oN=nObs:-1:1
        pplscore{oN,1}=sprintf ('%s(%s) - First : %.2f %%  Final %.2f %%  ? %.2f %%', ...
            cLegs.obs{oN},...
            sElect(find(cIndx.obs{oN}, 1,'first')).Group,...
            mean([sElect(cIndx.obs{oN}&cIndx.sessN{1}).correct])*100,...
            mean([sElect(cIndx.obs{oN}&cIndx.sessN{2}).correct])*100,...
            (mean([sElect(cIndx.obs{oN}&cIndx.sessN{2}).correct])*100)-mean([sElect(cIndx.obs{oN}&cIndx.sessN{1}).correct])*100 );
        
        allLevs=unique([sElect(cIndx.obs{oN}).gapSz]);
        nLevs=length(allLevs);
        pplscore{oN,2}=zeros(3,nLevs);
        pplscore{oN,2}(1,:) = allLevs(:);
        for lev=nLevs:-1:1
            pplscore{oN,2}(2,lev) = mean([sElect(cIndx.obs{oN}&cIndx.sessN{1}&[sElect.gapLev]'==lev).correct])*100; % Ob
            pplscore{oN,2}(3,lev) = mean([sElect(cIndx.obs{oN}&cIndx.sessN{2}&[sElect.gapLev]'==lev).correct])*100; % Ob
        end
        
        figure
        plot( pplscore{oN,2}(1,:), pplscore{oN,2}(2:3,:))
        ylabel('%-acc.')
        xlabel('Gapsize (º)')
        legend(LAB.sessN)
        title(['PF for : ' cLegs.obs{oN}])
    end
end



%%  accuracy-  as func of MS Onset proximity  relative to target  ( BY CUE TYPE )
%
for hide=[]
    lock=3; % event to lock analysis to
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
            section=(sElect(nT).EMon(emN):sElect(nT).EMoff(emN))... %  EM interval
                +(WBmax-sElect(nT).events(lock)); %adjusted to synch lock times
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
    % each column [i.e., sacc(:,t)] is a vector of (micro)saccade directions for all trials which had a saccade at time t (relative to lock)
    % find(sum(spSacc(:,t),2)) -> obtain a logical of trails with an EM at t
    
    % initialize result storage
    [EMTacc,EMTcnt, EMTse]=deal(cell(nFigs,1)); %  accuracy, # trials and Standard Error of mean
    % 1 cell per figure
    
    for fig=1:nFigs % for each figure in F2P
        [EMTacc(fig),EMTcnt(fig)]=deal({nan( F2P(fig).nGrps ,length(spread))}); % 1 row per condition
        EMTse{fig}=nan(length(spread),1, F2P(fig).nGrps ); % 1 column per condition
        
        for con=1:F2P(fig).nGrps     % for each grouping in figure{fig}
            for t=1:length(spread) % for each time point in analysis period
                
                lCoords=find(lAttice==spread(t))... % index into lAttice coordinates
                    +(-halfWindow:halfWindow); % temporal smoothing window
                
                if any(lCoords<1) || lCoords(end)>length(lAttice)
                    lCoords= lCoords(find(lCoords>1,1,'first'):find(lCoords<=length(lAttice),1,'last')); % trim problematic values of lCoords
                end
                
                whch=any(saccDir(:,lCoords),2); % trails with saccades within window(t)
                
                EMTacc{fig}(con,t)= mean([sElect( whch & F2P(fig).Indx(con,:)' ).correct]); % calculate mean for trials with saccades in the specific condition
                EMTcnt{fig}(con,t)= sum( whch & F2P(fig).Indx(con,:)' ); % count of trials contributing to mean
            end
            EMTse{fig}(:,1,con)=1.96*sqrt( (EMTacc{fig}(con,:).*(1-EMTacc{fig}(con,:))) ./ EMTcnt{fig}(con,:));  % binomial standard error
        end
    end
    
    beginInd=find (lAttice==start);endInd=find (lAttice==stop);
    noSaccIndx=~logical(any(saccDir(:,beginInd:endInd),2)); % all trials not contributing to averages in analysis period
    gMean=mean([sElect(noSaccIndx).correct]); % mean accuracy in non-sacc trials
    pGM=full(sum(noSaccIndx)/length(noSaccIndx)); % percent of trials in grand mean
    
    gSE=1.96*sqrt( (gMean.*(1-gMean))./sum(noSaccIndx) );
    
    for fig=1:4
        figure;
        subplot('position', [.1 .33 .8 .55])
        [bL,bP]=boundedline(spread,gMean*ones(size(spread)),gSE*ones(size(spread)),...
            ':','cmap', LAB.col.none, 'transparency', .3, 'alpha');hold on
        set(bL,'HandleVisibility','off');
        [pcL, pcP]=cellfun(@(perCorr,SEpc) boundedline(spread,perCorr,SEpc,'cmap',LAB.col.Group, 'transparency', .3, 'alpha'),... %
            EMTacc(fig),EMTse(fig), 'Uniformoutput', false); %
        set([pcL{:}],'HandleVisibility','off');
        ylim([.5 1])
        plotEvents (sElect,lock, -start, stop, LAB.events);
        legend([sprintf('Baseline: %.1f%% ', pGM*100), F2P(fig).legend ], 'Location','southeast')
        title( F2P(fig).titles )
        
        % title('Accuracy by cue type as a function of MS onsets relative to target')
        ylabel('Accuracy (%)')
        set(gca,'XTickLabel',{})
        
        subplot('position', [.1 .1 .8 .2])
        plot(spread,EMTcnt{fig}(1,:),'color',[LAB.col.Attn]), hold on
        plot(spread,EMTcnt{fig}(2,:),'color',[LAB.col.Neut])
        plotEvents (sElect,lock, -start, stop,'');
        ylabel('Count')
        xlabel('MS onset relative to Target onset (ms)')
    end
end


%%  diagonal congruency
figTitles= {'Vtrained training', 'Ntrained training'}; %{'Pre-training Neut'    'Pre-training Valid'    'Post-training Neut'    'Post-training Valid' };
factFields={'sessN', 'Group','diagonal' };
defineGroups  = {  factFields %factor fields  determines what fields the below conditions index
    %     {1, 2, [1 2]}}
    %     ...
    {  1,  2,  1   % 'Pre-training Neut'
    1,  2,  2 }
    {1, 1, 1
    1, 1 ,2}  };
%     ...
%     {  1,  2,  1   % 'Pre-training Valid'
%     1,  2,  2 }
%     ...
%     {  2,  1,  1   %  'Post-training Neut'
%     2,	1,	2 }
%     ...
%     {  2,  2,  1   % 'Post-training Valid'
%     2,  2,  2 }	};

[cIndx, cLegs] =factIndx(sElect, {'obs', factFields{:}}); % get indexes for fields of interest

dirXtime=prepToPlot(sElect, figTitles, defineGroups,LAB); % figures to be plotted

for fig=1:length(dirXtime)
    gIndx=any(dirXtime(fig).Indx)';
    [nEM,congMat, incMat, oppMat]=deal(zeros(1,size(saccDir,2)));
    for i=1:length(spread)
        %     lCoords=find(lAttice==spread(i));
        lCoords=find(lAttice==spread(i))... % index into lAttice coordinates
            +(-halfWindow:halfWindow); % span of analysis window
        
        % deal with potentially problematic window border cases
        if lCoords(1)<1
            lCoords= 1:lCoords(end);
        end
        
        if lCoords(end)>length(lAttice)
            lCoords=lCoords(1):length(lAttice); % trim problematic values of lCoords
        end
        
        
        crit=full(any(saccDir(:,lCoords)~=0,2));% identify critical Trails for time t = spread(i)
        %     nEM(i)=sum(~isnan(saccDir(:,lCoords)));
        nEM(i)= sum(gIndx&crit);
        tDiags= [sElect(gIndx&crit).diagonal];
        tTarLoc= [sElect(gIndx&crit).locTarg];
        tDir=arrayfun(@(TR) full(saccDir(TR,lCoords(find(saccDir(TR,lCoords),1,'first')) )), find(gIndx&crit));
        
        catMat=catDir(tDir,tDiags,tTarLoc);
        
        congMat(i)=sum(catMat==1);
        incMat(i)=sum(catMat==0);
        oppMat(i)=sum(catMat==-1);
    end
    
    combMat=[4*congMat./nEM;2*incMat./nEM;4*oppMat./nEM]';
    dirXtime(fig).cong=[4*congMat./nEM;2*incMat./nEM;4*oppMat./nEM]';
    
    figure
    subplot('position', [.1 .33 .8 .55])
    plot(lAttice(beginInd:endInd), combMat(beginInd:endInd,:)), hold on;
    legend ({'Cong', 'Incong','Opp'})
    
    plotEvents(sElect,lock,preLock,postLock,LAB.events);
    xlim([-preLock postLock])
    set(gca,'XTickLabel',{})
    ylabel('Relative Frequency')
    
    subplot('position', [.1 .1 .8 .2])
    
    plot(lAttice(beginInd:endInd), nEM(beginInd:endInd)), hold on;
    plotEvents(sElect,lock,preLock,postLock,'');
    xlim([-preLock postLock])
    ylabel('Total EM')
    
    
    suptitle(sprintf('Diagonal congruency \nGr: %s',dirXtime(fig).titles))
end
%% by diagonal
for hide =[]
    nPoints=50;
    for oN=nObs:-1:1
        figure
        for d=2:-1:1
            [tb,tv]=map([sElect(cIndx.obs{oN}&[sElect.diagonal]'==d).angDist], nPoints);
            obRose{oN,d}=polar(tb,tv); hold on
        end
        
        title ([' EM rose: ', cLegs.obs{oN}])
        legend({'Diag 2' 'Diag 1'})
    end
end
%% direction over time analysis % cue- locked % first saccade only!!
for hide=[]
    lock = 3 ;% possible : 1: nEvents
    split='trType';  % possible: trType, taEcc, Cong, none
    halfWind= 0; start= -100; stop= 700;
    Cmap='hot';
    range=start:stop;
    
    switch lock
        case 'pcueOn'
            lockOns='ClockedMSon'; lockOrd='ClockOrd';
        case 'tarOn'
            lockOns='TlockedMSon'; lockOrd='TlockOrd';
    end
    
    [tt,pName]=combFacts(sElect,{'obs', 'trType','cDur','taEcc'});
    % trTypes - Valid: left(1) right(2) - Neutral:target left (3)  target
    % right(4)
    OB_index= ...true(9,1);
        ismember(IDlist,...      % for all use ->  %
        { 'EC'    'HL'    'ID'    'LD'    'MR'    'NM'    'RD'    'RP'    'WD' }); % <- list desired ID
    
    % trial types to include: [Valid-L Valid-R Neut-L Neut-R]
    T_index =logical([1 1 1 1 ]);
    
    % include trials with : [Short, medium, long ]  SOA
    SOA=[ true true  true];
    
    ECC=[true true ];
    choose =logical(sum(...
        [tt{OB_index,T_index,SOA,ECC}]...
        ,2))';
    
    Nchoose=length(sElect(choose));
    MSflag=cell(length(sElect),2);
    MSexcl=cell(length(sElect),1);
    
    for tr=1:length(sElect) % find(choose)
        MSflag{tr,1}=cell2mat( arrayfun(@(onS,durEM) onS+(-halfWind:durEM+halfWind),...
            [sElect(tr).(lockOns)],...(abs(sElect(tr).(lockOrd))==1)],...
            [sElect(tr).EMdur],...(abs(sElect(tr).(lockOrd))==1)],...
            'uniformoutput', false));
        MSflag{tr,2}=cell2mat( arrayfun(@(ang,durEM) ang*ones(1,2*halfWind+durEM+1),...
            [sElect(tr).cFlipped],...(abs(sElect(tr).(lockOrd))==1)],...
            [sElect(tr).EMdur],...(abs(sElect(tr).(lockOrd))==1)],...
            'uniformoutput', false));
        MSexcl{tr}=sElect(tr).cFlipped(cell2mat(arrayfun(@(onS,durEM) ~(onS<stop & (onS+durEM)>start),...
            [sElect(tr).(lockOns)],...(abs(sElect(tr).(lockOrd))==1)],...
            [sElect(tr).EMdur],...(abs(sElect(tr).(lockOrd))==1)],...
            'uniformoutput', false)));
    end
    
    critical= cellfun(@(MSf) any(ismember(range,MSf)), MSflag(:,1))';
    
    
    CollectedAngs= cell(2,length(range));
    
    for t=find(critical&choose)
        winINDX= MSflag{t,1}-start ;
        winAngs= MSflag{t,2};
        
        winINDX=winINDX(winINDX>0);
        winAngs=winAngs(winINDX>0);
        
        winINDX=winINDX(winINDX<=length(range));
        winAngs=winAngs(winINDX<=length(range));
        
        switch split
            case 'trType'
                switch sElect(t).(split)
                    case {1,2}
                        ct=1;
                    case{3,4}
                        ct=2;
                end
            case 'taEcc'
                switch sElect(t).taEcc
                    case {4}
                        ct=1;
                    case{8}
                        ct=2;
                end
            case 'Cong'
                switch any(sElect(t).Cong(abs(sElect(t).(lockOns))==min(abs(sElect(t).(lockOns)))))
                    case {true}
                        ct=1;
                    case{false}
                        ct=2;
                end
            case 'none'
                ct=[1 2];
        end
        
        for cond=ct
            CollectedAngs(cond,winINDX)=cellfun(@(result,Angs) [result, Angs], CollectedAngs(cond,winINDX), num2cell(winAngs), 'uniformoutput',false);
        end
    end
    
    
    [AngsArray, nEM]=deal(cell(1,2));
    
    for CT=1:2
        
        [pCrit,AngsArray{CT}]=map(CollectedAngs(CT,:),36);
        
        nEM{CT}= cellfun(@length, CollectedAngs(CT,:));
        
        %         SEMamp{CT}= cellfun(@std,CollectedAmps(CT,:))./sqrt(nEM{CT});
    end
    peakCount=max(max(max(AngsArray{:})));
    allFigH(max(allFigH)+1)=figure;
    imagesc(range,[5 355], AngsArray{1}, [0 peakCount]), hold on
    colormap(Cmap)
    xlabel(sprintf('Time relative to %s onset (ms)',lock))
    ylabel('MS direction (0º=right)')
    plot ([0 0],[ylim],'--w')
    text(-20, max(ylim)*.87,  ['\bf',LAB.(lock)],'Rotation',90,'FontSize',18,'Color','white')
    xlim([start stop])
    title(sprintf('MS direction (%s-locked) \n%s:%s ',lock,split,LAB.(split){1}))
    
    allFigH(max(allFigH)+1)=figure;
    imagesc(range,[5 355], AngsArray{2}, [0 peakCount]), hold on
    colormap(Cmap)
    xlabel(sprintf('Time relative to %s onset (ms)',lock))
    ylabel('MS direction (0º=right)')
    plot ([0 0],[ylim],'--w')
    text(-20, max(ylim)*.87,  ['\bf',LAB.(lock)],'Rotation',90,'FontSize',18,'Color','white')
    xlim([start stop])
    title(sprintf('MS direction (%s-locked) \n%s:%s ',lock,split,LAB.(split){2}))
    
    %     allFigH(max(allFigH)+1)=figure; clf
    %
    %     xlabel(sprintf('Time relative to %s onset (ms)',lock))
    %     ylabel('MS direction (0º=right)')
    %         plot ([0 0],[ylim],'--w')
    %         text(-20, max(ylim)*.87,  ['\bf',LAB.(lock)],'Rotation',90,'FontSize',18,'Color','white')
    %     xlim([start stop])
    
    %     text(-15, .8,  ['\bf',LAB.(lock)],'Rotation',90,'FontSize',18)
    
    
end

figTitles= {'Vtrained training', 'Ntrained training'}; %{'Pre-training Neut'    'Pre-training Valid'    'Post-training Neut'    'Post-training Valid' };
factFields={'sessN', 'Group','diagonal' };
defineGroups  = {  factFields %factor fields  determines what fields the below conditions index
    %     {1, 2, [1 2]}}
    %     ...
    {  2,  1,  1   % 'Pre-training Neut'
    3,  1,  2 }
    {2, 2, 1
    3,2 ,2}  };
%     ...
%     {  1,  2,  1   % 'Pre-training Valid'
%     1,  2,  2 }
%     ...
%     {  2,  1,  1   %  'Post-training Neut'
%     2,	1,	2 }
%     ...
%     {  2,  2,  1   % 'Post-training Valid'
%     2,  2,  2 }	};

[cIndx, cLegs] =factIndx(sElect, {'obs', factFields{:}}); % get indexes for fields of interest

dirXtime=prepToPlot(sElect, figTitles, defineGroups,LAB); % figures to be plotted

% pCrit=[1 1 2];
% pCrit=
% gIndx=cIndx.Group{pCrit(1)}&cIndx.sessN{pCrit(2)}&cIndx.diagonal{pCrit(3)} ;

nPoints=90;
tMax=2000;

[dirXtime.result]=deal(zeros(nPoints+1,tMax,2));

for fig=1:length(dirXtime)
    for G=1:dirXtime(fig).nGrps
        gIndx=dirXtime(fig).Indx(G,:)';
        %         pName= sprintf( 'Group: %s, %s session, diag: %d',...
        %             cLegs.Group{dirXtime(fig).group(G).conds{1}},...
        %             cLegs.sessN{dirXtime(fig).group(G).conds{2}},...
        %             cLegs.diagonal{dirXtime(fig).group(G).conds{3}} );
        
        %         DoTmat = zeros(nPoints+1,tMax);
        for t=1: tMax
            if any(saccDir(:,t)~=0)
                [aBins, dirXtime(fig).result(:,t,G)]=map(saccDir(gIndx & saccDir(:,t)~=0,t),nPoints);
            else
                dirXtime(fig).result(:,t,G)=deal(0);
            end
            
            
        end
    end
    dirXtime(fig).diff=diff(dirXtime(fig).result(1:end-1,:,:),1,3);
end


for fig = 1:4
    
    figure
    imagesc(1:tMax, 360*(aBins(1:end-1)/(2*pi)),dirXtime(fig).diff)
    %         set(gca,'YTickLabel',360*(aBins(5:5:end)/(2*pi)))
    colormap(jet)
    plotEvents(sElect,0,0,tMax,LAB.events);
    plot(xlim'*ones(1,3),ones(2,1)*(1:3)* 90, 'k:')
    colorbar
    title(dirXtime(fig).titles)
    
end