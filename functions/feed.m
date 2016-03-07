function [ varargout ] = feed( inputArray)
% take a numeric or cell array and return a comma separated list of its
% contents
if iscell(inputArray)
    varargout=inputArray(1:nargout);
elseif isnumeric(inputArray)||islogical(inputArray)
    inputArray=num2cell(inputArray);
    inputArray=inputArray(:)';
    varargout=inputArray(1:nargout);
end

end

