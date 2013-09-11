function [q,omega] = project2FundamentalRegion(q,CS1,q_ref)
% projects quaternions to a fundamental region
%
% Syntax
%   project2FundamentalRegion(q,CS)       % to FR around idquaternion
%   project2FundamentalRegion(q,CS,q_ref) % to FR around reference rotation
%   project2FundamentalRegion(q,CS1,CS2)  % misorientation to FR around id
%
% Input
%  q        - @quaternion
%  CS1, CS2 - crystal @symmetry
%  q_ref    - reference @quaternion single or size(q) == size(q_ref)
%
% Output
%  q     - @quaternion
%  omega - rotational angle to reference quaternion
%

% get quaternions
qCS1 = quaternion(CS1);
q = quaternion(q);

if nargin < 3, q_ref = idquaternion; end
if isa(q_ref,'symmetry')
  qCS2  = quaternion(q_ref);  % second crystal symmetry
  q_ref = idquaternion;       % reference rotation must be identity
else
  qCS2  = idquaternion;
  q_ref = quaternion(q_ref);
end

q = reshape(q,[],1);

% compute distance to reference orientation
omega = abs(dot(q,q_ref));

% may be we can skip something
ind   = omega < cos(getMaxAngle(CS1,qCS2)/2);
if ~any(ind) || length(qCS1) == 1
  omega = 2*acos(min(1,omega));
  return;
end

% restrict to quaternion which are not yet it FR
if length(q) == numel(ind)
  q_sub = quaternion(q.subsref(ind));
else
  q_sub = quaternion(q);
end

% if q_ref was a list of reference rotations
if length(q_ref) == numel(ind), q_ref = subsref(q_ref,ind); end

% use that angle( CS2*q*CS1 ) =  angle( q * CS1 * inv(CS2) )
[uCS,m,~] = unique(qCS1*inv(qCS2),'antipodal'); %#ok<MINV>
[i,j]     = ind2sub([length(qCS1),length(qCS2)],m);

% compute all distances to the fundamental regions
omegaSym  = abs(dot_outer(inv(q_sub).*q_ref,uCS));

% find symmetry elements projecting to fundamental region
[omega(ind),nx] = max(omegaSym,[],2);

% project to fundamental region
q = q.subsasgn(ind,inv(qCS2.subsref(j(nx))).*q_sub.*qCS1.subsref(i(nx)));

% compute angle
omega = 2*acos(min(1,omega));

