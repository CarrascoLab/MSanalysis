function [ list ] = nestList( folder,form )
% finds all files with the specified form in the given location and its subfolders 
% returns a structure with fields: name, date, bytes, isdir, datenum & (relative) path
%
% folder=string with the starting folder (if blank i.e, '' or [], uses pwd)
% form=string of the file format (not including path)  
% asterisks function as wild cards when included in the form 
% i.e. '*.msg' would gater all files ending in '.msg'

% if folder is not specified, use pwd
if isempty(folder)
    folder=[pwd '/'];
end

if ~isdir(folder)
    error ('Folder/Path ''%s'' was not found.\n',folder)
end

% get all matching files in the current layer of the file structure 
list=dir(sprintf('%s%s',folder,form));
if ~isempty(list)
    [list.path]=deal(folder);
    % allocate an additional field 
end

% check folder contents for subfolders
temp=dir(sprintf('%s', folder));
% we want to exclude the system files '.' & '..' 
deeper=temp( ~(strcmp('.',{temp.name})|strcmp('..',{temp.name}))...
    &[temp.isdir]==1 ); % and get a list of everything else marked as a folder

% explore each of the subfolders 
for branch=1:length(deeper)
    % call nestList again for each subfolder with the same form
    addl= nestList( sprintf('%s%s/',folder,deeper(branch).name), form);
        % recursion makes me feel so good about myself :P
        
    if ~isempty(addl) % if this call found any appropriate files 
        if ~isempty(list) 
            list(end+1:end+length(addl))=addl; % add it to the list
        else % or if there's nothing on the list yet
            list=addl; % start the list
        end
    end
    
end



end

