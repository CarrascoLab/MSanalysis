function [ list ] = nestList( folder,form )
% finds all files with the specified form in the given path and subfolders within that path
% returns a structure with fields: name, date, byes, isdir, datenum & (relative) path
% folder=string with the starting folder (if blank i.e, '' or [], uses pwd)
% form=string of the file format (not including path)  i.e. '*.msg'

list=dir(sprintf('%s%s',folder,form));
if ~isempty(list)
    [list.path]=deal(folder);
end

temp=dir(sprintf('%s', folder));
deeper=temp(~(strcmp('.',{temp.name})|strcmp('..',{temp.name}))&[temp.isdir]==1);

for branch=1:length(deeper)
    addl= nestList( sprintf('%s%s/',folder,deeper(branch).name), form);
    if ~isempty(addl)
        if ~isempty(list)
            list(end+1:end+length(addl))=addl;
        else
            list=addl;
        end
    end
end



end

