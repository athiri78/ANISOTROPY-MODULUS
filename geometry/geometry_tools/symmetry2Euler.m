function [maxalpha,maxbeta,maxgamma] = symmetry2Euler(CS,SS)
% maximum euler angles for crystal and specimen symmetry
% 
%% Syntax
%  [maxalpha,maxbeta,maxgamma] = symmetry2Euler(CS,CS)
%
%% Input
%  CS - crystal @symmetry
%  SS - specimen @symmetry
%
%% Output
% maxalpha,maxbeta,maxgamma - maximum euler angles

% alpha
if rotangle_max_y(CS) == pi && rotangle_max_y(SS) == pi
  maxalpha = pi/2;
else
  maxalpha = rotangle_max_z(SS);
end

% beta
maxbeta = min(rotangle_max_y(CS),rotangle_max_y(SS))/2;

% gamma
maxgamma = rotangle_max_z(CS);
