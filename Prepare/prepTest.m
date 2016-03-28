%% from scratch
nFiles=416; % (any value ~=0)
addpath('../functions/');

%  file locations %
edfSource= 'Data/'; PathCrop= length(edfSource)+1; 
source= ''; matpath = source;% i.e., pwd, could be altered maybe?
DatAndMsg='../raw/'; % location of to-be-processed dat files 
% result locations %
edfDeposit= '../edf/';
processed='processed/'; pblem='pblem/';
outpath ='../sEssStrucs/';

dFormat='yyyymmdd-HHMM'; % format of date in PL_ATTN_ACC data 

EDFs=nestList(edfSource, '*.edf');

for fileN=1:length(EDFs)
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
    
    try
        
    copyfile([EDFs(fileN).path, EDFs(fileN).name],... % from source location
        [newEDFLoc, EDFs(fileN).name]); % to processed edf folder
    
    movefile([EDFs(fileN).path, EDFs(fileN).name]); % move edf into Prepare folder
    unix  ('./preparemv.sh') % apply edf2asc (output to '../raw/')
    
    
    movefile([DatAndMsg, EDFs(fileN).name(1:end-4), '*'],...
        rawOutLoc); % move edf into Prepare folder
    
    catch    % if something doesn't work
        movefile(EDFs(fileN).name, pblem); % move edf into problem folder
        delete([DatAndMsg EDFs(fileN).name(1:end-4)])
    end
        
        
end





% % %% from scratch
% nFiles=416; % (any value ~=0)
% addpath('../functions/');
% 
% %  file locations %
% edfSource= 'Data/'; PathCrop= length(edfSource)+1; 
% source= ''; matpath = source;% i.e., pwd, could be altered maybe?
% DatAndMsg='../raw/'; % location of to-be-processed dat files 
% % result locations %
% edfDeposit= '../edf/';
% processed='processed/'; pblem='pblem/';
% outpath ='../sEssStrucs/';
% 
% dFormat='yyyymmdd-HHMM'; % format of date in PL_ATTN_ACC data 
% 
% EDFs=nestList(edfSource, '*.edf');
% 
% for fileN=1:length(EDFs)
%     % maintains file structure in the destination folder
%     newEDFLoc=[edfDeposit, EDFs(fileN).path(PathCrop:end)];
%     rawOutLoc=[DatAndMsg, EDFs(fileN).path(PathCrop:end)];
%     
%     % if the goal folders don't exist, create them
%     if ~exist(newEDFLoc,'dir')
%         mkdir(newEDFLoc)
%     end
%     
%     if ~exist(rawOutLoc,'dir')
%         mkdir(rawOutLoc)
%     end
%     
% 
%     copyfile([EDFs(fileN).path, EDFs(fileN).name],... % from source location
%         [newEDFLoc, EDFs(fileN).name]); % to processed edf folder
%     
%     movefile([EDFs(fileN).path, EDFs(fileN).name]); % move edf into Prepare folder
% 
%         
% end
% unix  ('./preparemv.sh') % apply edf2asc (output to '../raw/')
% 
%     
% % 
% % for fileN=1:length(EDFs)   
% %     rawOutLoc=[DatAndMsg, EDFs(fileN).path(PathCrop:end)];
% %     if ~exist(rawOutLoc,'dir')
% %         mkdir(rawOutLoc)
% %     end
% %     movefile([DatAndMsg, EDFs(fileN).name(1:end-4), '*'],...
% %         rawOutLoc); % move edf into Prepare folder
% % end
% % 

