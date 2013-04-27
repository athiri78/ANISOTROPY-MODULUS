function c = char(S3G,varargin)
% convert to char

c = [int2str(numel(S3G)),' orientations'];
res = get(S3G,'resolution');
if ~isempty(res) && ~check_option(varargin,'nores')
  c = [c,', resolution: ',xnum2str(res*180/pi),mtexdegchar];
end
