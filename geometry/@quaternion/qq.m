function T = qq(q,varargin)
% returns w * q' * q
% 
%% Input
%  q - list of quaternions
%  w - list of weights

ql = [q.a(:), q.b(:), q.c(:), q.d(:)];
T = ql.'*ql;

% weigths
if ~isempty(varargin) && check_option(varargin,'weights')
  w = get_option(varargin,'weights',ones(1,numel(q)));
  w = reshape(w,1,[]);
  w = w./sum(w);
  w = repmat(w,4,1);
  T = w(:,1:numel(q)).* T;
end




