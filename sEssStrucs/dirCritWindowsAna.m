lock=1;
halfSmoothingWindow=30; % ms
Window.PreCrit=-600:0;
Window.PostCrit=0:800;
LAB.Window={'PreCrit' 'PostCrit'};
polarAng={'angAmp','angDist'};
typeAng=2; % choose direction measurement type

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

critWindFields={'sessN', 'Group','diagonal', 'locTarg' };
[cIndx, cLegs] =factIndx(sElect, {'obs', critWindFields{:}}); % get indexes for fields of interest

figTitles= {'Pre-training: nTR'  'Pre-training: vTR'...
    'Training: nTR'  'Training: vTR'...
    'Post-training: nTR' 'Post-training: vTR'};
defineGroups  = {  critWindFields %factor fields  determines what fields the below conditions index
    ...
    {  2,  1,  1, 1   % pretraining nTR
    2,  1,  2, 1
    2,  1,  1, 2
    2,  1,  2, 2 }
    ...
    {  2,  2,  1, 1   % pretraining vTR
    2,  2,  2, 1
    2,  2,  1, 2
    2,  2,  2, 2 }
    ...
    {  1,  1,  1, 1   % training nTR
    1,  1,  2, 1
    1,  1,  1, 2
    1,  1,  2, 2 }
    ...
    {  1,  2,  1, 1   % training vTR
    1,  2,  2, 1
    1,  2,  1, 2
    1,  2,  2, 2 }
    ...
    {  3,  1,  1, 1   % post-training nTR
    3,  1,  2, 1
    3,  1,  1, 2
    3,  1,  2, 2 }
    ...
    {  3,  2,  1, 1   % post-training vTR
    3,  2,  2, 1
    3,  2,  1, 2
    3,  2,  2, 2 }
    ...
    };

CritWinds=prepToPlot(sElect, figTitles, defineGroups,LAB); % figures to be plotted
nFigs=length(CritWinds);


%%  Pre-train, whole trial
nBins=90;
polarRhoLimit=500;
for fig = 1:2
    [collectedEMdir, polCount]= deal(cell(CritWinds(fig).nGrps,1));
    figure
    scaleSetLine=polar((0:1/90:1)*2*pi, polarRhoLimit*ones(1,91),'w'); hold on
    set(scaleSetLine, 'HandleVisibility','off');
    for grp= 1:CritWinds(fig).nGrps
        collectedEMdir{grp}= [sElect(CritWinds(fig).Indx(grp,:)).(polarAng{typeAng})];
        [binCenters,polCount{grp}]=map(collectedEMdir{grp},nBins);
        
        polar(binCenters,polCount{grp})
    end
    title(CritWinds(fig).titles)
    legend(CritWinds(fig).legend)
end


%% WINDOWS...
nBins=90;
polarRhoLimit=190;
MSdirections= {sElect.(polarAng{typeAng})};
[MSdirections{cellfun(@isempty, MSdirections)}]=deal(nan);
% MSdirections=[MSdirections{:}];

lockedOnsets = cellfun( @(onsets, lockPt) onsets-lockPt, {sElect.EMon}, num2cell(need(sElect,'',lock,'events')'), 'uniformoutput', false);
[lockedOnsets{cellfun(@isempty, lockedOnsets)}]=deal(nan);
% lockedOnsets=[lockedOnsets{:}];

lockedOffsets = cellfun( @(onsets, lockPt) onsets-lockPt, {sElect.EMoff}, num2cell(need(sElect,'',lock,'events')'), 'uniformoutput', false);
[lockedOffsets{cellfun(@isempty, lockedOffsets)}]=deal(nan);
% lockedOffsets=[lockedOffsets{:}];

% critPreWindow
for windNum=1:length(LAB.Window)
    
    for fig = 1: length (CritWinds)
        figure
        scaleSetLine=polar((0:1/90:1)*2*pi, polarRhoLimit*ones(1,91),'w'); hold on
        set(scaleSetLine, 'HandleVisibility','off');
        
        for grp= 1:CritWinds(fig).nGrps
            gIndx= CritWinds(fig).Indx(grp,:);
            collectDirs= [MSdirections{gIndx}];
            collectOn= [lockedOnsets{gIndx}];
            collectOff= [lockedOffsets{gIndx}];
            EMinWindow=~(collectOff<Window.(LAB.Window{windNum})(1)) & ~(collectOn>Window.(LAB.Window{windNum})(end));
            
            [binCenters,CritWinds(fig).(LAB.Window{windNum}).map{grp}]=map( collectDirs(EMinWindow),nBins);
            
            polar(binCenters,CritWinds(fig).(LAB.Window{windNum}).map{grp}), hold on
        end
        title( sprintf ( '%s (%s)', CritWinds(fig).titles, LAB.Window{windNum}))
        legend ( CritWinds(fig).legend)
    end
end

%%  categorize locations

for fig=1:length(CritWinds)
    gIndx=any(CritWinds(fig).Indx)';
    [nEM,congMat, hCongMat, vCongMat, oppMat]=deal(zeros(1,size(saccDir,2)));
    for i=1:length(spread)
        %     lCoords=find(lAttice==spread(i));
        lCoords=find(lAttice==spread(i))... % index into lAttice coordinates
            +(-halfSmoothingWindow:halfSmoothingWindow); % span of analysis window
        
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
        tDiags= [sElect(gIndx&crit).diagonal]; % tested diagonals
        tTarLoc= [sElect(gIndx&crit).locTarg]; % target locations
        tDir=arrayfun(@(TR) full(saccDir(TR,lCoords(find(saccDir(TR,lCoords),1,'first')) )), find(gIndx&crit));
        
        catMat=catDir2(tDir,tDiags,tTarLoc);
        
        congMat(i)=sum(catMat==1);
        hCongMat(i)=sum(catMat==2);
        vCongMat(i)=sum(catMat==-2);
        oppMat(i)=sum(catMat==-1);
    end
    
    combMat=[4*congMat./nEM;2*hCongMat./nEM;4*oppMat./nEM]';
    CritWinds(fig).cong= %[4*congMat./nEM;2*hCongMat./nEM;4*oppMat./nEM]';
    
    %     figure
    %     subplot('position', [.1 .33 .8 .55])
    %     plot(lAttice(beginInd:endInd), combMat(beginInd:endInd,:)), hold on;
    %     legend ({'Cong', 'Incong','Opp'})
    %
    %     plotEvents(sElect,lock,preLock,postLock,LAB.events);
    %     xlim([-preLock postLock])
    %     set(gca,'XTickLabel',{})
    %     ylabel('Relative Frequency')
    %
    %     subplot('position', [.1 .1 .8 .2])
    %
    %     plot(lAttice(beginInd:endInd), nEM(beginInd:endInd)), hold on;
    %     plotEvents(sElect,lock,preLock,postLock,'');
    %     xlim([-preLock postLock])
    %     ylabel('Total EM')
    %
    %
    %     suptitle(sprintf('Diagonal congruency \nGr: %s',CritWinds(fig).titles))
end