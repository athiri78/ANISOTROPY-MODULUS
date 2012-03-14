function grains = Grain3d(grainSet,ebsd)
% constructor for a 3d-GrainSet
%
% *Grain3d* represents 3d grains. a *Grain3d* represents grains and grain
% boundaries spatially and topologically. It uses formally the class
% [[GrainSet.GrainSet.html,GrainSet]].
%
%% Input
% grainSet - @GrainSet
% ebsd - @EBSD
%
%% See also
% EBSD/calcGrains GrainSet/GrainSet Grain2d/Grain2d



grains = class(struct,'Grain3d',GrainSet(grainSet,ebsd));