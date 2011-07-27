function ebsd = EBSD(varargin)
% constructor
%
% *EBSD* is the low level constructor for an *EBSD* object representing EBSD
% data. For importing real world data you might want to use the predefined
% [[ImportEBSDData.html,EBSD interfaces]]. You can also simulate EBSD data
% from an ODF using [[ODF.simulateEBSD.html,simulateEBSD]].
%
%% Syntax
%  ebsd = EBSD(orientations,CS,SS,...,param,val,...)
%
%% Input
%  orientations - @orientation
%  CS,SS        - crystal / specimen @symmetry
%
%% Options
%  Comment  - string
%  phase    - specifing the phase of the EBSD object
%  options  - struct with fields holding properties for each orientation
%  xy       - spatial coordinates n x 2, where n is the number of input orientations
%  unitCell - for internal use
%
%% See also
% ODF/simulateEBSD EBSD/calcODF loadEBSD

if nargin==1 && isa(varargin{1},'EBSD') % copy constructor
  ebsd = varargin{1};
  return
else
  rotations = rotation(varargin{:});
end

ebsd.comment = [];

ebsd.comment = get_option(varargin,'comment',[]);
ebsd.rotations = rotations(:);
ebsd.phase = get_option(varargin,'phase',ones(numel(ebsd.rotations),1));

% take symmetry from orientations
if nargin >= 1 && isa(varargin{1},'orientation')

  ebsd.SS = get(varargin{1},'SS');
  ebsd.CS = {get(varargin{1},'CS')};

else

  % specimen symmetry
  if nargin >= 3 && isa(varargin{3},'symmetry') && ~isCS(varargin{3})
    ebsd.SS = varargin{3};
  else
    ebsd.SS = get_option(varargin,'SS',symmetry);
  end

  % set up crystal symmetries
  if nargin >= 2 && ((isa(varargin{2},'symmetry') && isCS(varargin{2}))...
      || (isa(varargin{2},'cell') && isa(varargin{2}{1},'symmetry')))
    CS = ensurecell(varargin{2});
  else
    CS = ensurecell(get_option(varargin,'CS',{}));
  end

  % spread crystal symmetries over phases
  phases = unique(ebsd.phase);
  if numel(CS) < max(phases)
    if numel(CS) < numel(phases)
      if isempty_cell(CS), CS = symmetry('cubic');end
      CS = repmat(CS(1),1,max(ebsd.phase));
    else
      CSS(phases) = CS;
      CS = CSS;
    end
  end
  ebsd.CS = CS;

end



ebsd.options = get_option(varargin,'options',struct);
ebsd.unitCell = get_option(varargin,'unitCell',[]);

ebsd = class(ebsd,'EBSD');
