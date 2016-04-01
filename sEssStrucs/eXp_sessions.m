function eXp_sessions(sEssions,LAB)
% NMS 2015
% requires structure containing field: 'trials'
% with trial containing subfields: 'block',  'trial',  'diagonal',  'locTarg',
%     'gapLev',  'gapSz',  'TgapLoc',  'DgapLoc',  'response',
%     'correct',  'keyRT',  'trialStart',  'events',  'xy_pos',  'blinks',
%     'xy_filt',  'vel',  'vThr',  'numEM',  'EMon',  'EMoff',  'EMdur',
%     'vPeak',  'dist',  'angDist',  'amp',  'angAmp',  'MScrit',
%
% run PreProsEssions followed by anaSetUp

%%  initializing values for GUI

% observer, session & trial
[ID] = (1); % observer n
[SE] = 1; % session n
[TR,defTR] = deal(1); % trial n
tMAX= sEssions(SE).trials(TR).events(end);
IDlist=unique({sEssions.obs}, 'stable');
nObs= length (IDlist);
sesNs=1:length(sEssions); % unique({sElect.file});
nTrials= length(sEssions(SE).trials);
[B, E] = deal([]);

% position plot limits
[X1, defX1] = deal(-1.5); % left edge of plot
[X2, defX2]  = deal(1.5); % right edge of plot
[Y1, defY1] = deal(-1.5); % top edge of plot
[Y2, defY2]  = deal(1.5); % bottom edge of plot

% trace plot limits (VTP & PTP)
[T1, defT1] = deal(1); % timepoint 1 - left edge of plot
[T2]  = (tMAX); % timepoint 2 - right edge of plot

% labeling
cueTypes=({'valid','neut.'});
tarLocs=({'left','right'});
respAcc=({'incorr.','corr.' });
diags=({'UL-DR', 'LL-UR'});

%% initialize figure & subplots
h=figure(1);
clf

% % initialize subplots % %
% velocity space
VSP=subplot ('position', [ 0.0800    0.6    0.300    0.30]);
title('2D Velocity Space')
xlabel('º/s'), ylabel('º/s')
grid on, hold on;

% location space
PSP=subplot ('position', [ 0.0300    0.2    0.300    0.30]);
axis equal, title('Gaze position relative to fixation')
xlabel('º va'), ylabel('º va')
grid on, hold on;

% velocity trace
VTP=subplot ('position', [ 0.4    0.6    0.55    0.30]);
title('Velocity Trace')
xlabel('Time (ms)'), ylabel('Velocity (º/s)')
grid on, hold on;

% location trace
PTP=subplot ('position', [ 0.4    0.2    0.55    0.3]);
title('Position Trace')
xlabel('Time (ms)'), ylabel('Position relative to fixation (º va)')
grid on, hold on;

% kick it off! 
reTP
rePSP
reVSP

%%  ID, SE 
% % drop menus % %

% % % select observer % % %
% make it : init position and string
hID=uicontrol('Style', 'popupmenu','FontSize', 12,...
    'Units','Normalized','Position',[0.12,.95,.06,.03], ...
    'String', IDlist, 'Callback', @IDorSE);
% label it
hIDtext = uicontrol('Style','text','FontSize', 12,...
    'Units','Normalized','Position',[0.08,.95,.04,.03], ...
    'String', 'Obs:');  %


% % % select session % % %
hSE=uicontrol('Style', 'popupmenu','FontSize', 12,...
    'Units','Normalized','Position',[0.2,.95,.07,.03],...
    'String', sesNs, 'Callback', @IDorSE);
% label
hSesText = uicontrol('Style','text','Units','Normalized','Position',[0.18,.95,.02,.03],...
    'String', 'Session:','FontSize', 12);

    function IDorSE(source,callbackdata) % ID or SE changed
        if any([ID SE]~=[hID.Value hSE.Value])
            switch find([ID SE]~=[hID.Value hSE.Value])
                case 1
                    ID=source.Value;
                    SE= find(strcmp({sEssions.obs},IDlist(ID)),1,'first'); % find first session for observer # ID
                case 2
                    SE=source.Value;
                    ID=find(strcmp(sEssions(SE).obs,IDlist)); % get ID# of observer in session (SE)
            end
            
            % update # of trials
            nTrials= length(sEssions(SE).trials);
            
            % reset plotted trial
            tMAX= sEssions(SE).trials(TR).events(end);            
            X1=defX1;   X2=defX2;
            Y1=defY1;   Y2=defY2;
            TR=defTR;   T1=defT1;    T2=tMAX;

        end
        reTP
        rePSP
        reVSP
        upGUI
    end

%% Stop pushbutton
hStop = uicontrol('Style','togglebutton','Units','Normalized',...
    'BackgroundColor',[1,0,0],...
    'Position',[0.01,.95,.04,.03],...
    'String','Stop',...
    'Value',0,...
    'Callback', @DONE);


    function DONE(source,callbackdata)
        fprintf('All done...\nByeeEEEE! \n\n')
        close (h)
    end
%% PSP %%
% %  input textboxes % %

% X limits - position plot
hXlim1=uicontrol('Style', 'Edit','FontSize', 12,...
    'Units','Normalized','Position',[.05,0.13,.05,.025] ,...
    'Value',X1, 'String', num2str(X1),...
    'Callback', @XY_lims);
hXlim2=uicontrol('Style', 'Edit','FontSize', 12,...
    'Units','Normalized','Position',[.11,0.13,.05,.025],...
    'Value',X2 , 'String', num2str(X2),...
    'Callback', @XY_lims);
hXtext = uicontrol('Style','text','Units','Normalized','Position',[0,0.13,.05,.025],...
    'String','X-lims(º):','FontSize', 12);

% Y lims - position plot
hYlim1=uicontrol('Style', 'Edit','FontSize', 12,...
    'Units','Normalized','Position',[.22,0.13,.05,.025] ,...
    'Value',Y1,'String', num2str(Y1),...
    'Callback', @XY_lims);
hYlim2=uicontrol('Style', 'Edit','FontSize', 12,...
    'Units','Normalized','Position',[.28,0.13,.05,.025],...
    'Value',Y2, 'String', num2str(Y2),...
    'Callback', @XY_lims);
hYtext = uicontrol('Style','text','Units','Normalized','Position',[0.17,0.13,.05,.025],...
    'String','Y-lims(º):','FontSize', 12);

    function XY_lims (source,callbackdata)
        % insure new value is acceptable
        if isnan(str2double(source.String))
            source.String=num2str(source.Value);
            fprintf('New value must be a number\n')
            return
        else
            newN=str2double(source.String);
        end
        
        if source.Value~=newN
            % control dependent stuff
            switch find(~([hXlim1.Value, hXlim2.Value, hYlim1.Value, hYlim2.Value]==...
                    str2num([hXlim1.String, ' ', hXlim2.String, ' ', hYlim1.String, ' ', hYlim2.String, ' '])))
                case 1
                    X1=newN;
                    if X2<=X1 % check for invalid value
                        X2=X1+1;
                        disp('X2 must be greater than X1')
                    end
                case 2
                    X2=newN;
                    if X2<=X1
                        X1=X2-1;
                        disp('X2 must be greater than X1')
                    end % check for invalid value
                case 3
                    Y1=newN;
                    if Y2<=Y1,
                        Y2=Y1+1;
                        disp('Y2 must be greater than Y1')
                    end % check for invalid value
                case 4
                    Y2=newN;
                    if Y2<=Y1
                        Y1=Y2-1;
                        disp('Y2 must be greater than Y1')
                    end % check for invalid value
            end
            
            %refresh plot
            rePSP
            upGUI
        end
        
        % applied in every case
        source.Value=newN;
        source.String=num2str(newN);
    end

% % % refresh relative position plot (PSP) % % %
    function rePSP
        
        subplot(PSP)
        cla % clear subplot
        
                    % plot position
                    plot(sEssions(SE).trials(TR).xy_filt(T1:T2,1),sEssions(SE).trials(TR).xy_filt(T1:T2,2),...
                        'linewidth',.7,...
                        'color', [.6 .6 .6],...
                        'marker','o',...
                        'markersize',4)
        
        for i=1:length(B)
            % highlight detected MSs
            plot(sEssions(SE).trials(TR).xy_filt(B(i):E(i),1),...
                sEssions(SE).trials(TR).xy_filt(B(i):E(i),2),...
                'color', [1 .2 .2],'linewidth',2)
        end
        
        % XY limits
        xlim([X1,X2])
        ylim([Y1,Y2])
    end
%% VSP %%

% % % refresh 2D Velocity plot (VSP) % % %
    function reVSP
        
        subplot(VSP)
        cla % clear subplot
        % plot threshold radius
        plot(cosd(0:360)*sEssions(SE).trials(TR).vThr(1),sind(0:360)*sEssions(SE).trials(TR).vThr(2))
        axis equal
        
        % plot instantaenous velocity in 2D
        plot(sEssions(SE).trials(TR).vel(T1:T2,1),sEssions(SE).trials(TR).vel(T1:T2,2),'linewidth',1, 'color', [.6 .6 .6])
        plot(sEssions(SE).trials(TR).vel(T1:T2,1),sEssions(SE).trials(TR).vel(T1:T2,2),'o','linewidth',1, 'color', [.6 .6 .6])
        
        % highlight detected MSs
        start=[];
        stop=[];
        nMsD=0;
        for i=1:sEssions(SE).trials(TR).numEM
            if ~(T1 > sEssions(SE).trials(TR).EMoff(i) || T2 < sEssions(SE).trials(TR).EMon(i) )
                nMsD=nMsD+1;
                start(nMsD)=max(T1,sEssions(SE).trials(TR).EMon(i));
                stop(nMsD)=min(T2,sEssions(SE).trials(TR).EMoff(i));
                
                plot(sEssions(SE).trials(TR).vel(start(nMsD):stop(nMsD),1),sEssions(SE).trials(TR).vel(start(nMsD):stop(nMsD),2),'--','linewidth',1, 'color', [.6 .1 .1])
                plot(sEssions(SE).trials(TR).vel(start(nMsD):stop(nMsD),1),sEssions(SE).trials(TR).vel(start(nMsD):stop(nMsD),2),'o','linewidth',1, 'color', [.6 .1 .1])
            end
        end
    end

%%  PTP & VTP  %%
% Trial select slider, label & edit box
hTRsl = uicontrol('Style','Slider','Units','Normalized','Position',[.15,0.085,.75,.025],...
    'Min',1,'Max',nTrials,'SliderStep',[1/nTrials,.05],...
    'Value',TR, 'Callback', @nTR);
hTRtext = uicontrol('Style','text','Units','Normalized', 'Position',[0,0.085,.045,.025],...
    'String','Trial:','FontSize', 12);
hTRin=uicontrol('Style', 'Edit','Units','Normalized','Position',[.05,0.085,.08,.025] ,...
    'Value',TR,'String', num2str(TR),'FontSize', 12,...
    'Callback', @nTR);

    function nTR(source,callbackdata)
        switch source.Style
            case 'edit'
                newTR=str2double(source.String);
                if ~isnan(newTR) && (newTR>0 && newTR>=nTrials)
                    TR=newTR;
                else
                    source.String=num2str(source.Value);
                    fprintf('Invalid trial number entered')
                    return
                end
            case 'slider'
                TR= round(source.Value);
        end
        tMAX= sEssions(SE).trials(TR).events(end);
        T1=defT1;   T2=tMAX;
        X1=defX1;   X2=defX2;
        Y1=defY1;   Y2=defY2;
        
        reTP
        reVSP
        rePSP
        upGUI
    end

% time-window T1 slider, label & edit box
hT1sl = uicontrol('Style','Slider','Units','Normalized','Position',[.15,.055,.75,.025],...
    'Value',T1,'Min',1,'Max',sEssions(SE).trials(TR).events(end-1),    ...
    'SliderStep',[1/(tMAX-1),50/(tMAX-1)],...
    'Callback',@upT1);
hT1text = uicontrol('Style','text','Units','Normalized','Position',[0,.055,.04,.025],...
    'String','T1:','FontSize', 12);
hT1in=uicontrol('Style', 'Edit','Units','Normalized','Position',[.05,0.055,.08,.025] ,...
    'Value',T1,'String', num2str(T1),'FontSize', 12,...
    'Callback',@upT1);

% time-window T2 slider, label & edit box
hT2sl = uicontrol('Style','Slider','Units','Normalized','Position',[.15,.025,.75,.025],...
    'Value',T2,'Min',2,'Max',tMAX,...
    'SliderStep',[1/(tMAX-1),50/(tMAX-1)],...
    'Callback',@upT2);
hT2text = uicontrol('Style','text','Units','Normalized','Position',[0,.025,.04,.025],...
    'String','T2:','FontSize', 12);
hT2in=uicontrol('Style', 'Edit','Units','Normalized','Position',[.05,.025,.08,.025] ,...
    'Value',T2,'String', num2str(T2),'FontSize', 12,...
    'Callback',@upT2);

    function upT1(source,callbackdata) % T1  changed
        switch source.Style
            case 'edit'
                newT1=str2double(source.String);
                if ~isnan(newT1) && (newT1>0 && newT1< tMAX)
                    T1=newT1;
                else
                    source.String=num2str(source.Value);
                    return
                end
                
            case 'slider'
                T1= round(source.Value);
        end
        if T2<=T1
            T2=T1+1;
        end
        % update all
        reTP
        reVSP
        rePSP
        upGUI
    end

    function upT2(source,callbackdata) % T2 changed
        switch source.Style
            case 'edit'
                newT2=str2double(source.String);
                if ~isnan(newT2) && (newT2>1 && newT2<=tMAX)
                    T2=newT2;
                else
                    source.String=num2str(source.Value);
                    return
                end
                
            case 'slider'
                T2= round(source.Value);
        end
        
        if T2<=T1
            T1=T2-1;
        end
        % update all
        reTP
        reVSP
        rePSP
        upGUI
    end


    function reTP
        [B,E]=getMSs(T1,T2);
        % %  % Position trace plot % % %
        subplot(PTP)
        cla % clear subplot
        
        % position trace
        plot (T1:T2,sEssions(SE).trials(TR).xy_filt(T1:T2,1),'b','linewidth',1)
        plot (T1:T2,sEssions(SE).trials(TR).xy_filt(T1:T2,2),'g','linewidth',1)
        legend({'X-pos','Y-pos'},'location','northwest'      )
        
        % highlight detected MSs
        for i=1:length(B)
            plot( B(i):E(i), sEssions(SE).trials(TR).xy_filt(B(i):E(i),:), 'r','linewidth',2)
        end
        Yextremes= [min(sEssions(SE).trials(TR).xy_filt(:)) max(sEssions(SE).trials(TR).xy_filt(:))];
        Yextremes= Yextremes+[-.05 .05];
        
        % limits
        xlim([T1-50 T2+50])
        ylim(Yextremes)
        % label events
        plotEvents(sEssions(SE).trials(TR),1,-T1,T2,'')
        
        % % % Velocity Trace  sub-plot % % %
        subplot(VTP)
        cla % clear subplot
        % velocity trace
        plot (T1:T2,sEssions(SE).trials(TR).vel(T1:T2,1),'b','linewidth',1)
        plot (T1:T2,sEssions(SE).trials(TR).vel(T1:T2,2),'g','linewidth',1)
        
        legend({'X-vel','Y-vel'})
        
        % highlight detected MSs
        for i=1:length(B)
            plot( B(i):E(i), sEssions(SE).trials(TR).vel(B(i):E(i),:), 'r','linewidth',2)
        end
        
        % Limits
        Yextremes= [min(sEssions(SE).trials(TR).vel(:)) max(sEssions(SE).trials(TR).vel(:))]; %* 1.05;
        Yextremes= Yextremes+[-.05 .05];
        xlim([T1-50 T2+50])
        ylim(Yextremes)
        
        % label cue and target events timing
        plotEvents(sEssions(SE).trials(TR),1,-T1,T2,LAB.events)
    end % refresh PTP & VTP (trace plots) 


    function upGUI    % update the values in the interface
        % TR
        set (hTRsl, ...
            'Max',nTrials,...
            'SliderStep',[1/nTrials,.05],...
            'Value', TR);
        hTRin.Value=TR;     hTRin.String=num2str(TR);
        % T1
        set(hT1sl, 'Max', tMAX-1,...
            'SliderStep',[1/(tMAX-1),50/(tMAX-1)],...
            'Value',T1)
        hT1in.Value=T1;     hT1in.String=num2str(T1);
        %T2
        set(hT2sl, 'Max', tMAX,...
            'SliderStep',[1/(tMAX-1), 50/(tMAX-1)],...
            'Value',T2)
        hT2in.Value=T2;     hT2in.String=num2str(T2);
        % X1 & X2
        hXlim1.Value=X1;    hXlim1.String=num2str(X1);
        hXlim2.Value=X2;    hXlim2.String=num2str(X2);
        % Y1 & Y2
        hYlim1.Value=Y1;    hYlim1.String=num2str(Y1);
        hYlim2.Value=Y2;    hYlim2.String=num2str(Y2);
         suptitle(sprintf('Group: %s   SessN: %s   Diagonal: %d \nT-loc: %d   Resp: %s    sacEM: %d',...
                sEssions(SE).group,...
                sEssions(SE).num,...
                sEssions(SE).trials(TR).diagonal,...
                sEssions(SE).trials(TR).locTarg,...
                respAcc{ sEssions(SE).trials(TR).correct+1} ,...
                sEssions(SE).trials(TR).numEM ))
    end

    function [B,E]=getMSs(T1,T2) % get MS beginning and end 
        clear B E
        % find MSs in time-window
        MSs2show=find(~(T1>sEssions(SE).trials(TR).EMoff |T2<sEssions(SE).trials(TR).EMoff));
        nMSs=length(MSs2show);
        
        if nMSs~=0;
            % get begining and end of MSs
            for i=MSs2show(end:-1:1)
                B(nMSs)=max(T1,sEssions(SE).trials(TR).EMon(i));
                E(nMSs)=min(T2,sEssions(SE).trials(TR).EMoff(i));
                nMSs=nMSs-1; % adjust counter
            end
        else
            B=[]; E=[];
        end
    end  
end