function grains = calcGrains(ebsd,varargin)
% 2d and 3d construction of GrainSets from spatially indexed EBSD data
%
%% Syntax
% grains = calcGrains(ebsd,'angle',10*degree)
%
%% Input
%  ebsd   - @EBSD
%
%% Output
%  grains  - @Grain2d | @Grain3d
%% Options
%  threshold|angle - array of threshold angles per phase of mis/disorientation in radians
%  augmentation    - bounds the spatial domain
%
%    * |'cube'|
%    * |'auto'|
%
%% Flags
%  unitcell     - omit voronoi decomposition and treat a unitcell lattice
%
%% See also
% GrainSet/GrainSet

%% parse input parameters

thresholds = get_option(varargin,{'angle','threshold'},15*degree,'double');

%% remove not indexed phases

if ~check_option(varargin,'keepNotIndexed')
  disp('  I''m removing all not indexed phases. The option "keepNotIndexed" keeps them.');
  
  ebsd = subsref(ebsd,~isNotIndexed(ebsd));
  
end

%% verify inputs

if numel(thresholds) == 1 && numel(ebsd.CS) > 1
  thresholds = repmat(thresholds,size(ebsd.CS));
end

if isa(ebsd,'GrainSet'),  ebsd = get(ebsd,'ebsd'); end

if all(isfield(ebsd.options,{'x','y','z'}))
  x_D = get(ebsd,'xyz');
  [Xt m n]  = unique(x_D(:,[3 2 1]),'first','rows'); %#ok<ASGLU>
elseif all(isfield(ebsd.options,{'x','y'}))
  x_D = get(ebsd,'xy');
  [Xt m n]  = unique(x_D(:,[2 1]),'first','rows'); %#ok<ASGLU>
else
  error('mtex:GrainGeneration','no Spatial Data!');
end
clear Xt

% check for duplicated data points
if numel(m) ~= numel(n)
  warning('mtex:GrainGeneration','spatially duplicated data points, perceed by erasing them')
end
clear n

% sort X
x_D = x_D(m,:);

% sort ebsd accordingly
ebsd = subsref(ebsd,m);
clear m

% get the location x of voronoi-generators D
[d,dim] = size(x_D);

%% spatial decomposition
% decomposite the spatial domain into cells D with vertices x_V,

switch dim
  case 2
    
    [x_V,D] = spatialdecomposition(x_D,ebsd.unitCell,varargin{:});
    
    % now we need some adjacencies and incidences
    iv = [D{:}];            % nodes incident to cells D
    id = zeros(size(iv));   % number the cells
    
    p = [0; cumsum(cellfun('prodofsize',D))];
    for k=1:numel(D), id(p(k)+1:p(k+1)) = k; end
    
    % next vertex
    indx = 2:numel(iv)+1;
    indx(p(2:end)) = p(1:end-1)+1;
    ivn = iv(indx);
    
    % edges list
    F = [iv(:), ivn(:)];
    % should be unique (i.e one edge is incident to two cells D)
    [F, b, ie] = unique(sort(F,2),'rows');
    
    % edges incident to cells, E x D
    I_FD = sparse(ie,id,1);
    
    % vertices incident to cells, V x D
    I_VD = sparse(iv,id,1,size(x_V,1),d);
    
    % adjacent cells, D x D
    A_D = triu(I_VD'*I_VD>1,1);
    
    [Dl,Dr] = find(A_D);  % list of cells
    
    clear I_VD iv id ie p b indx ivn
    
  case 3
    
    [Dl,Dr,sz,dz,lz] = spatialdecomposition3d(x_D,ebsd.unitCell,varargin{:});
    
    % adjacent cells, D x D
    A_D = sparse(double(Dl),double(Dr),1,d,d);
    
    clear x_D
    
end

%% segmentation

% neighboured locations x_D, i.e. cells {D_l,D_r} in A_D

criterion = false(size(Dl));

notIndexed = isNotIndexed(ebsd);

for p = 1:numel(ebsd.phaseMap)
  
  % neighboured cells Dl and Dr have the same phase
  ndx = ebsd.phase(Dl) == p & ebsd.phase(Dr) == p;
  criterion(ndx) = true;
  
  % check, whether they are indexed
  ndx = ndx & ~notIndexed(Dl) & ~notIndexed(Dr);
  
  % now check whether the have a misorientation heigher or lower than a
  % threshold
  
  % due to memory we split the computation
  csndx = [uint32(0:1000000:sum(ndx)-1) sum(ndx)];
  for k=1:numel(csndx)-1
    andx = ndx & cumsum(ndx) > csndx(k) & cumsum(ndx) <= csndx(k+1);
    
    o_Dl = orientation(ebsd.rotations(Dl(andx)),ebsd.CS{p},ebsd.SS);
    o_Dr = orientation(ebsd.rotations(Dr(andx)),ebsd.CS{p},ebsd.SS);
    
    criterion(andx) = dot(o_Dl,o_Dr) > cos(thresholds(p)/2);
  end
    
  clear o_Dl o_Dr ndx csndx andx
end

%%

% adjacency of cells that have no common boundary
A_Do = sparse(double(Dl(criterion)),double(Dr(criterion)),true,d,d);
A_Do = A_Do | A_Do';

A_Db = sparse(double(Dl(~criterion)),double(Dr(~criterion)),true,d,d);
A_Db = A_Db | A_Db';

clear Dl Dr criterion notIndexed p k

%% retrieve neighbours

I_DG = sparse(1:d,double(connectedComponents(A_Do)),1);    % voxels incident to grains
A_G = I_DG'*A_Db*I_DG;                     % adjacency of grains

clear A_Do

%% interior and exterior grain boundaries

sub = (A_Db * I_DG & I_DG)';                      % voxels that have a subgrain boundary
[i,j] = find( diag(any(sub,1))*double(A_Db) ); % all adjacence to those
sub = any(sub(:,i) & sub(:,j),1);              % pairs in a grain

A_Db_int = sparse(i(sub),j(sub),1,d,d);
A_Db_ext = A_Db - A_Db_int;                        % adjacent over grain boundray

clear A_Db sub i j

%% create incidence graphs

% now do
switch dim
  case 2
    I_FDbg = diag(sum(I_FD,2)==1)*I_FD;
  case 3
    % construct faces as needed
    if numel(sz) == 3
      i = find(any(A_Db_int,2) | any(A_Db_ext,2));  % voxel that are incident to grain boudaries
      [x_V,F,I_FD,I_FDbg] = spatialdecomposition3d(sz,uint32(i(:)),dz,lz);
    else % its voronoi decomposition
      v = sz; clear sz
      F = dz; clear dz
      I_FD  = lz; clear lz;
      
      D_Fbg = sum(abs(I_FD),2)==1;
      I_FDbg = D_Fbg * I_FD;
    end
end

D_Fbg   = diag(any(I_FDbg,2));
clear I_FDbg

[ix,iy] = find(A_Db_ext);
clear A_Db_ext
D_Fext  = diag(sum(abs(I_FD(:,ix)) & abs(I_FD(:,iy)),2)>0);

I_FDext = (D_Fext| D_Fbg)*I_FD;
clear D_Fext D_Fbg I_FDbg

[ix,iy] = find(A_Db_int);
clear A_Db_int
D_Fsub  = diag(sum(abs(I_FD(:,ix)) & abs(I_FD(:,iy)),2)>0);
I_FDsub = D_Fsub*I_FD;
clear I_FD I_FDbg D_Fsub ix iy

%% sort edges of boundary when 2d case

switch dim
  case 2
    I_FDext = EdgeOrientation(I_FDext,F,x_V,x_D);
    I_FDsub = EdgeOrientation(I_FDsub,F,x_V,x_D);
    
    b = BoundaryFaceOrder(D,F,I_FDext,I_DG);
    
    clear x_D D
    
end

%% mean orientation and phase

[d,g] = find(I_DG);

grainSize     = full(sum(I_DG>0,1));
grainRange    = [0 cumsum(grainSize)];
firstD        = d(grainRange(2:end));
phase         = ebsd.phase(firstD);
q             = quaternion(ebsd.rotations);
meanRotation  = q(firstD);

indexedPhases = ~cellfun('isclass',ebsd.CS(:),'char');
doMeanCalc    = find(grainSize(:)>1 & indexedPhases(phase));

cellMean      = cell(size(doMeanCalc));
for k = 1:numel(doMeanCalc)
  cellMean{k} = d(grainRange(doMeanCalc(k))+1:grainRange(doMeanCalc(k)+1));
end
cellMean = partition(q,cellMean);

for k=1:numel(doMeanCalc)
  qMean = project2FundamentalRegion(cellMean{k}, ...
    ebsd.CS{phase(doMeanCalc(k))},ebsd.SS,meanRotation(doMeanCalc(k)));
  cellMean{k} = mean(qMean);
end
meanRotation(doMeanCalc) = [cellMean{:}];

clear grainSize grainRange indexedPhases doMeanCalc cellMean q g qMean


%%

grainSet.comment  = ebsd.comment;
%', thresholds: ' ...
%  sprintf(['%3.1f' mtexdegchar ', '],thresholds/degree)];
%grainSet.comment(end-1:end) = [];

grainSet.A_D      = logical(A_D);   clear A_D;
grainSet.I_DG     = logical(I_DG);  clear I_DG;
grainSet.A_G      = logical(A_G);   clear A_G;
grainSet.meanRotation = meanRotation;  clear meanRotation;
% grain.rotations    = ebsd.rotations;
grainSet.phase    = phase;          clear phase;
%
grainSet.I_FDext  = I_FDext;        clear I_FDext;
grainSet.I_FDsub  = I_FDsub;        clear I_FDsub;
% model.I_VE     = logical(I_VE);
grainSet.F        = F;              clear F;
grainSet.V        = x_V;            clear x_V;
grainSet.options  = struct;

%% Grain average value of EBSD properties

[i,j] = find(grainSet.I_DG);

cc = full(sum(grainSet.I_DG>0,1));
cs = [0 cumsum(cc)];

fields = fieldnames(ebsd.options);

for n = 1:length(fields)
  values = ebsd.options.(fields{n});
  meanValues = values(i(cs(2:end)));

  for k = find( cc > 1)
    ndx = i(cs(k)+1:cs(k+1));
    meanValues(k) = mean(values(ndx));
  end
  
  grainSet.options.(strcat('mean_', fields{n})) = meanValues;
end

%% Mean misorientation

[g,d] = find(grainSet.I_DG'); clear I_DG;
ebsd.options.mis2mean = inverse(ebsd.rotations(d)).* reshape(grainSet.meanRotation(g),[],1);

%% Boundary edge order

switch dim
  case 2
    
    grainSet.options.boundaryEdgeOrder = b;
    grains = Grain2d(grainSet,ebsd);
    
  case 3
    
    grains = Grain3d(grainSet,ebsd);
    
end


%% some sub-routines for 2d case
function I_ED = EdgeOrientation(I_ED,E,x_V,x_D)
% compute the orientaiton of an edge -1, 1

[e,d] = find(I_ED);

% in complex plane with x_D as point of orign
e1d = complex(x_V(E(e,1),1) - x_D(d,1), x_V(E(e,1),2) - x_D(d,2));
e2d = complex(x_V(E(e,2),1) - x_D(d,1), x_V(E(e,2),2) - x_D(d,2));

I_ED = sparse(e,d,sign(angle(e1d./e2d)),size(I_ED,1),size(I_ED,2));


function b = BoundaryFaceOrder(D,F,I_FD,I_DG)


I_FG = I_FD*I_DG;
[i,d,s] = find(I_FG);

b = cell(max(d),1);

onePixelGrain = full(sum(I_DG,1)) == 1;
[id,jg] = find(I_DG(:,onePixelGrain));
b(onePixelGrain) = D(id);
% close single cells

for k = find(onePixelGrain)
  b{k} = [b{k} b{k}(1)];
end
% b(onePixelGrain) = cellfun(@(x) [x x(1)],  b(onePixelGrain),...
%   'UniformOutput',false);


cs = [0 cumsum(full(sum(I_FG~=0,1)))];
for k=find(~onePixelGrain)
  ndx = cs(k)+1:cs(k+1);
  
  E1 = F(i(ndx),:);
  s1 = s(ndx); % flip edge
  E1(s1>0,[2 1]) = E1(s1>0,[1 2]);
  
  b{k} = EulerCycles(E1(:,1),E1(:,2));
  
end

for k=find(cellfun('isclass',b(:)','cell'))
  boundary = b{k};
  [ignore,order] = sort(cellfun('prodofsize', boundary),'descend');
  b{k} = boundary(order);
end

