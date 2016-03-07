%%  trial explore GUI:
% NMS 2015
% requires structure "sElect"


% % % load .mat file containing structure % % %
if ~exist ('sElect','var')
    filtType=3; % 1= none, 2= zero-order, 3= kalman
    
    switch filtType
        case 1 % no filtering
            load('trStruc.mat')
        case 2 % zero phase digital filter & FIR (gaussian)
            load('trStrucZO.mat')
        case 3 % kalman filtering
            load('trStrucKal.mat')
    end
end
% % %

% addpath('funcs/');

% EXPECTED INPUT
% n-length structure vector "TRials" with fields:
% ob: string [1 X n] - observer ID
% file: string [1X n] - the filename of the data source (minus extension)
% pcueOn: double [1 X 1] - timepoint of the precue relative to the begining of the trial
% tarOn: double [1 X 1] - timepoint of the target relative to the begining of the trial
% rcueOn: double [1 X 1] - timepoint of the response-cue relative to the begining of the trial
% trType: double [1 X 1] - trial type (1=valid left, 2= valid right, 3= neutral left, 4= neutral right)
% trEnd: double [1X1] - last timepoint of trial
% cDur: double [1 X 1] - cue duration bin ( 300|600|900 )
% taEcc: double [1X1] - target eccentricty (4|8)
% Corr: double [1X1] - response accuracy 0=incorrect, 1=correct
% pos: double [trEnd X 2] - (x,y) gaze coordinates in ºva
% vel: double [trEnd X 2] - (dx,dy) velocity of gaze positiong in ºva/s
% vThr: double[1X2] - horizontal and vertical components of velocity threshold oval
% numEM: double [1X1] - # of em detected in trail
% EMon: double [numEMX1] - em onset
% EMoff: double [numEMX1] - em end point
% EMdur: double [numEMX1] - em duration
% vPeak: double [numEMX1] - max velocity of this em
% dist: double [numEMX1] - distance between start and end points (º va)
% angDist: double [numEMX1] - angle between start and end points (radians, 0=rightward)
% amp: double [numEMX1] - total em amplitude (º va; max difference of coordinates)
% angAmp: double [numEMX1] - angle of amplitude (radians, 0=rightward)
% % % % % % % % % % % % % % % % % % % % % % % %

IDlist=unique({sElect.obs});
nObs= length (IDlist);
nTrials= length(sElect);
FileNs=unique({sElect.file});
% labeling
cueTypes=({'valid','neut.'});
tarLocs=({'left','right'});
respAcc=({'incorr.','corr.' });

% initializing values for GUI
% position plot limits
X1=-1.5; % left
X2=1.5; % right
Y1=-1.5; % bottom
Y2=1.5; % top

TR = 1; % trial n
T1 = 1; % timepoint plot t1
T2  = 1000; % t1

%% focus to figure
h=figure;

%Stop pushbutton
hStop = uicontrol('Style','togglebutton','Units','Normalized',...
    'BackgroundColor',[1,0,0],'Position',[0.01,.95,.04,.03],'String','Stop','Value',0);

% % drop menus % %
% select observer
% make it : init position and string
hID=uicontrol('Style', 'popupmenu','Units','Normalized','Position',[0.12,.95,.06,.03], ...
    'String', IDlist,'FontSize', 12);
% label it
hIDtext = uicontrol('Style','text','Units','Normalized','Position',[0.08,.95,.04,.03], ...
    'String', 'Obs:','FontSize', 12);  %

% select file
hFile=uicontrol('Style', 'popupmenu','Units','Normalized','Position',[0.2,.95,.07,.03],...
    'String', FileNs,'FontSize', 12);
hFileText = uicontrol('Style','text','Units','Normalized','Position',[0.18,.95,.02,.03],...
    'String', 'File:','FontSize', 12);

% % % radio buttons % % %
lock = uibuttongroup('Position',[0.70 0.95 .25 .03]);
L0 = uicontrol(lock,'Style', 'radiobutton',...
    'Units','Normalized',...
    'String','no lock',...
    'Position',[0. 0 .3 1]);
LC = uicontrol(lock,'Style','radiobutton',...
    'Units','Normalized',...
    'String','c-lock',...
    'Position',[0.33 0 .3 1]);
LT = uicontrol(lock,'Style','radiobutton',...
    'Units','Normalized',...
    'String','t-lock',...
    'Position',[0.66 0 .3 1]);

Lstate=get(get(lock,'SelectedObject'),'String');
% filter
% hFilt=uicontrol('Style', 'popupmenu','Units','Normalized','Position',[0.33,.95,.1,.02], 'String', Filts);
% hFiltText = uicontrol('Style','text','Units','Normalized', 'Position',[0.33,.975,.1,.02], 'String', 'Filter type');

% %  input boxes % %
% X limits - position plot
hXlim1=uicontrol('Style', 'Edit','Units','Normalized','Position',[.05,0.13,.05,.025] ,...
    'Value',X1,'String', num2str(X1),'FontSize', 12);
hXlim2=uicontrol('Style', 'Edit','Units','Normalized','Position',[.11,0.13,.05,.025],...
    'Value',X2 , 'String', num2str(X2),'FontSize', 12);
hXtext = uicontrol('Style','text','Units','Normalized','Position',[0,0.13,.05,.025],...
    'String','X-lims(º):','FontSize', 12);

% Y lims - position plot
hYlim1=uicontrol('Style', 'Edit','Units','Normalized','Position',[.22,0.13,.05,.025] ,...
    'Value',Y1,'String', num2str(Y1),'FontSize', 12);
hYlim2=uicontrol('Style', 'Edit','Units','Normalized','Position',[.28,0.13,.05,.025],...
    'Value',Y2, 'String', num2str(Y2),'FontSize', 12);
hYtext = uicontrol('Style','text','Units','Normalized','Position',[0.17,0.13,.05,.025],...
    'String','Y-lims(º):','FontSize', 12);

% % %  sliders % % %
% Trial select slider
hTRs = uicontrol('Style','Slider','Units','Normalized','Position',[.15,0.085,.75,.025],...
    'Min',1,'Max',nTrials,'SliderStep',[1/nTrials,180/nTrials],  'Value',TR);
hTRtext = uicontrol('Style','text','Units','Normalized', 'Position',[0,0.085,.045,.025],...
    'String','Trial:','FontSize', 12);
hTRi=uicontrol('Style', 'Edit','Units','Normalized','Position',[.05,0.085,.08,.025] ,...
    'Value',TR,'String', num2str(TR),'FontSize', 12);

% time-window T1 slider, label & edit box
hT1s = uicontrol('Style','Slider','Units','Normalized','Position',[.15,.055,.75,.025],...
    'Value',T1,'Min',1,'Max',sElect(TR).events(end)-1,    'SliderStep',[1/(sElect(TR).events(end)-1),50/(sElect(TR).events(end)-1)]);
hT1text = uicontrol('Style','text','Units','Normalized','Position',[0,.055,.04,.025],...
    'String','T1:','FontSize', 12);
hT1i=uicontrol('Style', 'Edit','Units','Normalized','Position',[.05,0.055,.08,.025] ,...
    'Value',T1,'String', num2str(T1),'FontSize', 12);

% time-window T2 slider, label & edit box
hT2s = uicontrol('Style','Slider','Units','Normalized','Position',[.15,.025,.75,.025],...
    'Value',T2,'Min',2,'Max',sElect(TR).events(end),'SliderStep',[1/(sElect(TR).events(end)-1),50/(sElect(TR).events(end)-1)]);
hT2text = uicontrol('Style','text','Units','Normalized','Position',[0,.025,.04,.025],...
    'String','T2:','FontSize', 12);
hT2i=uicontrol('Style', 'Edit','Units','Normalized','Position',[.05,.025,.08,.025] ,...
    'Value',T2,'String', num2str(T2),'FontSize', 12);

% initial values:
ID = get(hID,'Value');
FileN = get(hFile,'Value');
cTR=TR;
cT1=T1; cT2=T2;
cY1=Y1; cY2=Y2;
cX1=X1; cX2=X2;
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
title('Velocity Trace'), xlabel('Time (ms)'), ylabel('Velocity (º/s)'), grid on, hold on;
% location trace
PTP=subplot ('position', [ 0.4    0.2    0.55    0.3]);
title('Position Trace'), xlabel('Time (ms)'), ylabel('Position relative to fixation (º va)'), grid on, hold on;

drawnow
UP=true;
%% Loop till user hits 'stop' button
while ~get(hStop,'Value')
    %check lock status
    cLstate=get(get(lock,'SelectedObject'),'String');
    if ~strcmp(cLstate,Lstate)
        Lstate=cLstate;
        UP=1;
    end
    % check observer and file
    cID = get(hID,'Value');
    cFileN = get(hFile,'Value');
    
    % if the observer or session have changed
    if ID~=cID
        cTR= find(strcmp({sElect.obs},IDlist(cID)),1,'first');
        UP=2;
    elseif FileN~=cFileN
        cTR= find(strcmp({sElect.file},FileNs(cFileN)),1,'first');
        UP=2;
    end
    
    if ~UP % check trial values
        cTRs= round(get(hTRs,'Value'));
        if ~isnan(str2double(get(hTRi,'String'))), cTRi= str2double(get(hTRi,'String')); end
        if TR~=cTRs
            cTR=cTRs;
            UP=2;
        elseif TR~=cTRi && ismember(cTR,1:length(sElect))
            cTR=cTRi;
            UP=2;
        end
    end
    
    if ~UP % check T1 values
        cT1s = round(get(hT1s,'Value'));
        if ~isnan(str2double(get(hT1i,'String'))), cT1i= str2double(get(hT1i,'String')); end
        if T1~=cT1s
            cT1=cT1s;
            UP=1;
        elseif T1~=cT1i && ismember (cT1i, 1:sElect(TR).events(end)-1)
            cT1=cT1i;
            UP=1;
        end
    end
    if ~UP % check T2 values
        cT2s  = round(get(hT2s,'Value'));
        if ~isnan(str2double(get(hT2i,'String'))), cT2i= str2double(get(hT2i,'String')); end
        if T2~=cT2s
            cT2=cT2s;
            UP=1;
        elseif T2~=cT2i && ismember (cT2i, 2:sElect(TR).events(end))
            cT2=cT2i;
            UP=1;
        end
    end
    
    % check/update limits in postion plot
    if ~UP
        if ~isnan(str2double(get(hXlim1,'String')))
            cX1 =  str2double(get(hXlim1,'String'));
        end
        if ~isnan(str2double(get(hXlim2,'String')))
            cX2 =  str2double(get(hXlim2,'String'));
        end
        if ~isnan(str2double(get(hYlim1,'String')))
            cY1 =  str2double(get(hYlim1,'String'));
        end
        if ~isnan(str2double(get(hYlim2,'String')))
            cY2 =  str2double(get(hYlim2,'String'));
        end
        if (X1~=cX1||X2~=cX2||Y1~=cY1||Y2~=cY2)
            UP=3;
        end
    end
    
    % if any value has changed, update slider labels and figure:
    % main plotting updating section
    if UP
        switch UP
            case 1
                % only Trace window
                if get(LC,'Value')
                    cT1=sElect(TR).pcueOn-50;
                elseif get(LT,'Value')
                    cT1=sElect(TR).tarOn-50;
                else % no lock applied
                    % start must be less than the trial duration
                    if (sElect(TR).events(end)<=cT1); cT1=sElect(TR).events(end)-1; end
                end
                if (sElect(TR).events(end)<T2); cT2=sElect(TR).events(end); end % end must also be less than trial duration
                if (cT2<cT1); cT2=cT1+1; end   % end must be after the start
                %	update everything
                T1=cT1;
                T2=cT2;
                set(hT1s,'Value',T1);
                set(hT1i,'String',num2str(T1));
                set(hT2s,'Value',T2);
                set(hT2i,'String',num2str(T2));
            case 2
                % trial change
                TR=cTR ;% update trial number
                % set ID
                ID=find(strcmp(IDlist,sElect(TR).obs));
                set(hID,'Value', ID)
                % set File
                FileN= find(strcmp(FileNs,sElect(TR).file));
                set(hFile,'Value',FileN)
                % check cT1&cT2 values
                if get(LC,'Value')
                    cT1=sElect(TR).pcueOn-50;
                elseif get(LT,'Value')
                    cT1=sElect(TR).tarOn-50;
                else % no lock applied
                    % start must be less than the trial duration
                    if (sElect(TR).events(end)<=cT1); cT1=sElect(TR).events(end)-1; end
                end
                if (sElect(TR).events(end)<cT2); cT2=sElect(TR).events(end); end % end must also be less than trial duration
                if (cT2<cT1); cT2=cT1+1; end   % end must be after the start
                % update everything else
                % T1 stuff
                T1=cT1;
                set(hT1s,'Value',T1);
                set(hT1i,'String',num2str(T1));
                set(hT1s, 'Max', sElect(TR).events(end)-1,'SliderStep',[1/(sElect(TR).events(end)-1),50/(sElect(TR).events(end)-1)] )
                % T2 stuff
                T2=cT2;
                set(hT2s,'Value',T2);
                set(hT2i,'String',num2str(T2));
                set(hT2s, 'Max', sElect(TR).events(end),'SliderStep',[1/(sElect(TR).events(end)-1),50/(sElect(TR).events(end)-1)] )
                % TR stuff
                set(hTRi,'String',num2str(TR))
                set(hTRs,'Value',TR)
                
            case 3
                % only PSP limits
                if cX2<=cX1; cX2=cX1+1; disp('X2 must be greater than X1'), end
                if cY2<=cY1; cY2=cY1+1; disp('Y2 must be greater than Y1'), end
                X1=cX1;
                X2=cX2;
                Y1=cY1;
                Y2=cY2;
                set(hXlim1, 'String', num2str(X1))
                set(hXlim2, 'String', num2str(X2))
                set(hYlim1, 'String', num2str(Y1))
                set(hYlim2, 'String', num2str(Y2))
        end
        
        
        % % % 2D Velocity plot  % % %
        subplot(VSP)
        cla % clear subplot
        % plot threshold radius
        plot(cosd(0:360)*sElect(TR).vThr(1),sind(0:360)*sElect(TR).vThr(2))
        axis equal
        
        % plot instantaenous velocity in 2D
        plot(sElect(TR).vel(T1:T2,1),sElect(TR).vel(T1:T2,2),'linewidth',1, 'color', [.6 .6 .6])
        plot(sElect(TR).vel(T1:T2,1),sElect(TR).vel(T1:T2,2),'o','linewidth',1, 'color', [.6 .6 .6])
        
        % highlight detected MSs
        start=[];
        stop=[];
        nMsD=0;
        for i=1:sElect(TR).numEM
            if ~(T1 > sElect(TR).EMoff(i) || T2 < sElect(TR).EMon(i) )
                nMsD=nMsD+1;
                start(nMsD)=max(T1,sElect(TR).EMon(i));
                stop(nMsD)=min(T2,sElect(TR).EMoff(i));
                
                plot(sElect(TR).vel(start(nMsD):stop(nMsD),1),sElect(TR).vel(start(nMsD):stop(nMsD),2),'--','linewidth',1, 'color', [.6 .1 .1])
                plot(sElect(TR).vel(start(nMsD):stop(nMsD),1),sElect(TR).vel(start(nMsD):stop(nMsD),2),'o','linewidth',1, 'color', [.6 .1 .1])
            end
        end
        
        % % % relative position plot % % %
        subplot(PSP)
        cla % clear subplot
        % plot position
        plot(sElect(TR).xy_filt(T1:T2,1),sElect(TR).xy_filt(T1:T2,2),...
            'linewidth',.7,...
            'color', [.6 .6 .6],...
            'marker','o',...
            'markersize',4)
        
        % highlight detected MSs
        for i=1:nMsD
            plot(sElect(TR).xy_filt(start(i):stop(i),1),sElect(TR).xy_filt(start(i):stop(i),2),'color', [1 .2 .2],'linewidth',2)
        end
        
        % limits
        xlim([X1,X2])
        ylim([Y1,Y2])
        
        % %  % Position trace plot % % %
        subplot(PTP)
        cla % clear subplot
        % position trace
        plot (T1:T2,sElect(TR).xy_filt(T1:T2,1),'b','linewidth',1)
        plot (T1:T2,sElect(TR).xy_filt(T1:T2,2),'g','linewidth',1)
        legend({'X-pos','Y-pos'},'location','northwest'      )
        
        % highlight detected MSs
        for i=1:nMsD
            plot( (start(i):stop(i)), sElect(TR).xy_filt(start(i):stop(i),:), 'r--','linewidth',2)
        end
        Yextremes= [min(min( sElect(TR).xy_filt(T1:T2,:))) max(max(sElect(TR).xy_filt(T1:T2,:)))];
        Yextremes= Yextremes+[-.05 .05];
        % label events
        for ev=length(sElect(TR).events)-1:-1:1
            if sElect(TR).events(ev)>T1 && T2>sElect(TR).events(ev)
                hEvents(ev)=plot([sElect(TR).events(ev),sElect(TR).events(ev)], Yextremes, 'm--','linewidth',2);
                text(sElect(TR).events(ev)+length(T1:T2)*.01, min(Yextremes)+diff(Yextremes)/10, LAB.events(ev),'Rotation',90)
            end
        end
        
        % labels & limits
        xlim([T1-50 T2+50])
        ylim(Yextremes)
        
        % % % Velocity Trace  sub-plot % % %
        subplot(VTP)
        cla % clear subplot
        % velocity trace
        plot (T1:T2,sElect(TR).vel(T1:T2,1),'b','linewidth',1)
        plot (T1:T2,sElect(TR).vel(T1:T2,2),'g','linewidth',1)

        legend({'X-vel','Y-vel'})
        
        % highlight detected MSs
        for i=1:nMsD
            plot( (start(i):stop(i)), sElect(TR).vel(start(i):stop(i),:), 'r--','linewidth',2)
        end
        
        Yextremes= [min(min( sElect(TR).vel(T1:T2,:))) max(max(sElect(TR).vel(T1:T2,:)))] * 1.05 ;
        % cue and target timing
       % label events
        for ev=length(sElect(TR).events)-1:-1:1
            if sElect(TR).events(ev)>T1 && T2>sElect(TR).events(ev)
                hEvents(ev)=plot([sElect(TR).events(ev),sElect(TR).events(ev)], Yextremes, 'm--','linewidth',2);
                text(sElect(TR).events(ev)+length(T1:T2)*.01, min(Yextremes)+diff(Yextremes)/10, LAB.events(ev),'Rotation',90)
            end
        end
        
        % Limits
        xlim([T1-50 T2+50])
        ylim(Yextremes)
        
        suptitle(sprintf('Group: %s   Sess: %s   Diagonal: %d \nT-loc: %d   Resp: %s    sacEM: %d',...
            sElect(TR).Group,...
            sElect(TR).sessN,...
            sElect(TR).diagonal,...
            sElect(TR).locTarg,...
            respAcc{ sElect(TR).correct+1} ,...
            sElect(TR).numEM ))
        UP=false;
    end
    pause(0.1);
end
disp('Done!');
% close(h)