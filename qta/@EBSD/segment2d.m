function [grains ebsd] = segment2d(ebsd,varargin)
% angle threshold segmentation of ebsd data 
%
%% Input
%  ebsd   - @EBSD
%
%% Output
%  grains  - @grain
%  ebsd    - connected @EBSD data
%
%% Options
%  angle         - array of threshold angles per phase of mis/disorientation in radians
%  augmentation  - 'cube'/ 'cubeI' / 'sphere'
%  angletype     - misorientation (default) / disorientation 
%  distance      - maximum distance allowed between neighboured measurments
%
%% Flags
%  unitcell     - omit voronoi decomposition and treat a unitcell lattice
%
%% Example
%  [grains ebsd] = segment2d(ebsd(1:2),'angle',[10 15]*degree,'augmentation','cube')
%
%% See also
% grain/grain

%% segmentation
% prepare data

s = tic;

thresholds = get_option(varargin,'angle',15*degree);
if numel(thresholds) == 1 && numel(ebsd) > 1
  thresholds = repmat(thresholds,size(ebsd));
end


xy = vertcat(ebsd.xy);

if isempty(xy), error('no spatial data');end

% sort for voronoi
[xy m n]  = unique(xy,'first','rows');

if numel(m) ~= numel(n)
  warning('mtex:GrainGeneration','spatially duplicated data points, perceed by erasing them')
  ind = ~ismember(1:sum(sampleSize(ebsd)),m);
  [grains ebsd] = segment2d(delete(ebsd,ind),varargin{:});
  return
end

phase_ebsd = get(ebsd,'phase');
phase_ebsd = mat2cell(phase_ebsd,ones(size(phase_ebsd)),1)';

% generate long phase vector
l = sampleSize(ebsd);
rl = [ 0 cumsum(l)];
phase = ones(1,sum(l));
for i=1:numel(ebsd)
  phase( rl(i)+(1:l(i)) ) = i;
end



phase = phase(m);



%% grid neighbours

[neighbours vert cells] = neighbour(xy, varargin{:});
  [sm sn] = size(neighbours); %preserve size of sparse matrices
[ix iy]= find(neighbours);

%% maximum distance between neighbours

if check_option(varargin,'distance')
  distance = sqrt(sum((xy(ix,:)-xy(iy,:)).^2,2));
  distance = distance > get_option(varargin,'distance',max(distance),'double');
  distance = sparse(ix,iy,distance,sm,sn);
  distance = xor(distance,neighbours);
  [ix iy]= find(distance);
else
  distance = neighbours;
end


%% disconnect by phase

phases = sparse(ix,iy,phase(ix) ~= phase(iy),sm,sn);
phases = xor(phases,distance);
[ix iy]= find(phases);

%% disconnect by missorientation

angles = sparse(sm,sn);

zl = m(ix);
zr = m(iy);

for i=1:numel(ebsd)
  %   restrict to correct phase
  ind = rl(i) < zl & zl <=  rl(i+1);
  
  zll = zl(ind)-rl(i); zrr = zr(ind)-rl(i);
  mix = ix(ind); miy = iy(ind);
  
  %   compute distances
  o1 = ebsd(i).orientations(zll);
  o2 = ebsd(i).orientations(zrr);
  omega = angle(o1,o2);
  
  ind = omega > thresholds(i);
  
  angles = angles + sparse(mix(ind),miy(ind),1,sm,sn);
end

% disconnect regions
regions = xor(angles,phases); 

clear angles phases


%% convert to tree graph

ids = graph2ids(regions);


%% retrieve neighbours

T2 = xor(regions,neighbours); %former neighbours
T2 = T2 + T2';
T1 = sparse(ids,1:length(ids),1);
T3 = T1*T2;
nn = T3*T1'; %neighbourhoods of regions
             %self reference if interior has not connected neighbours

%% subfractions 

inner = T1 & T3 ;
[ix iy] = find(inner);
[ix ndx] = sort(ix);
cfr = unique(ix);
cfr = sparse(1,cfr,1:length(cfr),1,length(nn));
iy = iy(ndx);

if ~isempty(iy)
  innerc = mat2cell(iy,histc(ix,unique(ix)),1);

  %partners
  [lx ly] = find(T2(iy,iy));
  nx = [iy(lx) iy(ly)];
  ll = sortrows(sort(nx,2));
  ll = ll(1:2:end,:); % subractions


  nl = size(ll,1);
  lines = zeros(nl,2);

  for k=1:nl
    left = cells{ll(k,1)};
    right = cells{ll(k,2)};
    mm = ismember(left, right);
    lines(k,:) = left(mm);  
  end

  xx = [vert(lines(:,1),1) vert(lines(:,2),1)];
  yy = [vert(lines(:,1),2) vert(lines(:,2),2)];

  nic = length(innerc);
  fractions = cell(size(nic));

  for k=1:nic
    mm = ismember(ll,innerc{k});
    mm = mm(:,1);
    fr.xx = xx(mm,:)';
    fr.yy = yy(mm,:)'; 
    fr.pairs = m(ll(mm,:));
      if numel(fr.pairs) <= 2, fr.pairs = fr.pairs'; end
    fractions{k} = fr;
  end
else
  fractions = cell(0);
end
                
%clean up
clear T1 T2 T3 regions angel_treshold


%% conversion to cells

ids = ids(n); %sort back
phase = phase(n);
cells = cells(n);

%store grain id's into ebsd option field
cids =  [0 cumsum(sampleSize(ebsd))];
checksum =  fix(rand(1)*16^8); %randi(16^8);
checksumid = [ 'grain_id' dec2hex(checksum)];
for k=1:numel(ebsd)
	ide = ids(cids(k)+1:cids(k+1));
	ebsd(k).options.(checksumid) = ide(:);
 
	[ide ndx] = sort(ide(:));
	pos = [0 ;find(diff(ide)); numel(ide)];
	aind = ide(pos(1:end-1)+1);
  
  orientations(aind) = ...
    partition(ebsd(k).orientations(ndx),pos);
end

% cell ids
[ix iy] = sort(ids);
id = cell(1,ix(end));
pos = [0 find(diff(ix)) numel(ix)];
for l=1:numel(pos)-1
  id{l} = iy(pos(l)+1:pos(l+1));
end


nc = length(id);

% neighbours
[ix iy] = find(nn);
pos = [0; find(diff(iy)); numel(iy)];
if ~isempty(ix)
  nn = cell(1,nc);
  for l=1:nc
    nn{l} = ix(pos(l)+1:pos(l+1));
  end
else
  nn = cell(1);
end

nfr = sparse(1,iy(pos(2:end)),1:numel(pos)-1,1,length(nn));

vdisp(['  ebsd segmentation: '  num2str(toc(s)) ' sec'],varargin{:});


%% retrieve polygons
s = tic;

ply = createpolygons(cells,id,vert);

comment =  ['from ' ebsd(1).comment];


neigh = cell(1,nc);
neigh(find(nfr)) = nn;
fract = cell(1,nc);
fract(find(cfr)) = fractions;

%cf = cellfun(@numel,orientations)>1;
orientations = cellfun(@mean,orientations,'uniformoutput',false);

cid = cell(1,nc);
cchek = cell(1,nc);
ccom = cell(1,nc);
cprop = cell(1,nc);
phase_ebsd = cell(1,nc);
tstruc = struct;
for i=1:numel(cchek)
  cid{i} = i;
  cchek{i} = checksum;
  ccom{i} = comment;
  cprop{i} = tstruc;
  phase_ebsd{i} = phase(id{i}(1));
end 

gr = struct('id',cid,...
       'cells',id,...
       'neighbour',neigh,...    %       'polygon',[],...
       'checksum',cchek,...
       'subfractions',fract,...       
       'phase',phase_ebsd,...
       'orientation',orientations,...
       'properties',cprop,...
       'comment',ccom);

grains = grain(gr,ply);




vdisp(['  grain generation:  '  num2str(toc(s)) ' sec' ],varargin{:});
vdisp(' ',varargin{:})




function ids = graph2ids(A)

%elimination tree
[parent] = etree(A);

n = length(parent);
ids = zeros(1,n);
isleaf = parent ~= 0;

k = sum(~isleaf);
%set id for each tree in forest
for i = n:-1:1,
  if isleaf(i)   
    ids(i) = ids(parent(i));
  else
    ids(i) = k;
    k = k - 1;
  end 
end;


function [F v c] = neighbour(xy,varargin)
% voronoi neighbours

[v c] = spatialdecomposition(xy,'voronoi',varargin{:});

il = cat(2,c{:});
jl = zeros(1,length(il));

cl = cellfun('length',c);
ccl = [ 0 ;cumsum(cl)];

if ~check_option(varargin,'unitcell')
  %sort everything clockwise  
  parts = [0:10000:numel(c)-1 numel(c)];
  
  f = false(size(c));
  for l=1:numel(parts)-1
    ind = parts(l)+1:parts(l+1);
    cv = v( il( ccl(ind(1))+1:ccl(ind(end)+1) ),:);
        
    r = diff(cv);
    r = r(1:end-1,1).*r(2:end,2)-r(2:end,1).*r(1:end-1,2);
    r = r > 0;
    
    f( ind ) = r( ccl(ind)+1-ccl(ind(1)) );
  end
  
  for i=1:length(c)
    jl(ccl(i)+1:ccl(i+1)) = i;    
    if f(i), l = c{i}; c{i} = l(end:-1:1); end
  end
  
  clear cv parts ind r f
else  
  for i=1:length(c)
    jl(ccl(i)+1:ccl(i+1)) = i;
  end
end

  % vertice map
T = sparse(jl,il,1); 
  clear jl il
T(:,1) = 0; %inf

%edges
F = T * T';
  clear T;
F = triu(F,1);
F = F > 1;


function ply = createpolygons(cells,regionids,verts)

rcells = cells([regionids{:}]);

gl = [rcells{:}];
  %shift indices
indi = 1:length(gl);
inds = indi+1;
c1 = cellfun('length',rcells); 
cr1 = cellfun('length',regionids);
r1 = cumsum(c1);
r2 = [1 ; r1+1];
r2(end) =[];  
inds(r1) = r2;

cc = [0; r1];
crc = [0 cumsum(cr1)];

gr = gl(inds); %partner pointel

clear rcells r1 r2 indi c1 inds

ii = [gl(:) gr(:)]; % linels  
% remove double edges
ii = sort(ii,2);
gll = ii(:,1);
grr = ii(:,2);

clear ii

ndx = 1:numel(gll);
[ig,ind] = sort(grr);
ndx = ndx(ind);
[ig,ind] = sort(gll(ndx));
ndx = ndx(ind);

clear ig ind

gll = gll(ndx);
grr = grr(ndx);

[k ib] = sort(ndx);

clear ndx k

nr = length(regionids);
p = struct(polygon);
ply = repmat(p,1,nr);

for k =1:nr
  sel = cc(crc(k)+1)+1:cc(crc(k+1)+1);

  if cr1(k) > 1
    %remove double entries
    [ig nd] = sort(ib(sel));
    dell = diff(gll(ig)) == 0 &  diff(grr(ig)) == 0;
    dell = find(dell);
    sel( nd([dell dell+1]) ) = []; 
  
    border = converttoborder(gl(sel), gr(sel));
    
    psz = numel(border);    
    if psz == 1
      
      v = border{1};
      xy = verts(v,:);
      ply(k).xy = xy;
      ply(k).point_ids = v;

      ply(k).envelope = reshape([min(xy); max(xy)],1,[]);
      
    else
      
      hply = repmat(p,1,psz);
      
      for l=1:psz
        
        v = border{l};
        xy = verts(v,:);
        hply(l).xy = xy;
        hply(l).point_ids = v;   
        
        hply(l).envelope = reshape([min(xy); max(xy)],1,[]);
        
      end
      hply = polygon(hply);
      
      [ig ndx] = sort(area(hply),'descend');
      
      ply(k) = hply(ndx(1));      
      ply(k).holes = hply(ndx(2:end));
      
    end
  else
    % finish polygon
    v = [gl(sel) gl(sel(1))];
    xy = verts(v,:);
    ply(k).xy = xy;
    ply(k).point_ids = v;
    
    ply(k).envelope = reshape([min(xy); max(xy)],1,[]);
    
  end
  
end

ply = polygon(ply);



function plygn = converttoborder(gl, gr)
% this should be done faster

if isempty(gl)
  plygn = {};
  return
end


nf = length(gr)*2;  
f = zeros(1,nf);  %minimum size
  
%hamiltonian  trials
f(1) = gl(1);
cc = 0; 
      
k=2;
while 1
  ro = find(f(k-1) == gr);
  n = numel(ro);
  if n>0
    ro = ro(n);
    f(k) = gl(ro);     
  else 
    ro = find(gr>0);
    if ~isempty(ro)
      ro = ro(1);
      f(k) = gl(ro);
      cc(end+1) = k-1;
    else
      cc(end+1) = k-1;
      break;
    end 
  end
    
  gr(ro) = -1;
  k = k+1;
end

  
%convert to cells
nc = numel(cc)-1; 
if nc > 1, plygn = cell(1,nc); end
for k=1:nc 
  if k > 1
    plygn{k} = [f(cc(k)+1:cc(k+1)) f(cc(k)+1)];
  else
    plygn{k} = f(cc(k)+1:cc(k+1));
  end
end  


