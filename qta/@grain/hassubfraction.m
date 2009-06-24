function b = hassubfraction(grains)
% checks whether given grains has subfractions
%
%% Input
%  grains - @grain
%
%% Output
%  b   - boolean
%

b = ~cellfun('isempty', {grains.subfractions});

