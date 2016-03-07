function [ collected ] = need( base, include, selection, varargin)
% need(le) - pull out one piece of a cell or field from multiple instances with identical features
% need(base, include, selection) <- for cells
% need(base, include, selection, field) <- for strucs
%
% base - the cell or struc in question
% include- the subset within the larger structure/cell to gather
% selection - the portion of the final reference to get (integers, logical) [default-> :]
% varargin (optional field) - if base is a struct this is the relevant
% field to extract data from
%
if isstruct(base)
    type=1;
elseif iscell(base)
    type=2;
else
    error('inappropriate data type (i.e., base ~= cell || struct )')
end

if islogical(include)
    indx=find(include);
elseif isnumeric(include)
    indx=include;
elseif ~isnumeric(include)&&~islogical(include)
    indx=1:numel(base);
%     fprintf ('\nGathering from all... \n To choose a subset pass a logical [size(base)] or a vector of subindexes in varargin{1}\n ')
end

if mod(type, 2)
    if ~exist('varargin', 'var'), error( 'need a field for data type: struct'), end
    field=varargin{1};
    if  ~isfield(base, field), error( 'varargin must be a string corresponding to a field in base'), end
end

collected=cell(size(indx));
switch type
    case 1
        % quick error detection
        if islogical(selection), assert(all(size(selection)==size(base(indx(1)).(field))))
        elseif isnumeric(selection), assert (max(selection)<=numel(base(indx(1)).(field))&& min(selection)>0)
        else error('Inappropriate selection passed')
        end
        
        for i=1:length(indx)
            collected{i}= [base(indx(i)).(field)(selection)];
        end
        
    case 2
        if islogical(selection), assert( all( size(selection)==size(base{indx(1)} ) ))
        elseif isnumeric(selection), assert ( max(selection)<=numel(base{indx(1)} ) && min(selection)>0)
        else error('Inappropriate selection passed')
        end
        
        for i=1:length(indx)
            collected{i}= [base{indx(i)}(selection)];
        end
        
end
try
    collected=cell2mat(collected)';
catch
    error(sprintf('!! data type mismatch !! \n\n\n'))
end
end

