

cs = symmetry('O')
ori = equispacedSO3Grid(cs,symmetry,'resolution',5*degree)
odf = unimodalODF(idquaternion,'halfwidth',0.5*degree);
ebsd = calcEBSD(odf,length(ori));
ori = ebsd.rotations .* orientation(ori(:));
%ori = orientation(randq(100),cs);
%ori = orientation(rotation(symmetry('O')),cs)
DSO3 = DelaunaySO3(ori)

%% check adjacence matrix
hist(sum(DSO3.A_tetra))


%% check neigbouring matrix

DSO3.tetraNeigbour(5,:)

DSO3.tetra([5,DSO3.tetraNeighbour(5,:)],:)

%% check find routing

%[ind,bario] = DSO3.findTetra(orientation('Euler',10*degree,20*degree,5*degree,cs))

[ind,bario] = DSO3.findTetra(orientation('Euler',317*degree,0*degree,0*degree,cs))

%% have there some to many adjecent tetrahegons?
[m,ind] = max(sum(DSO3.A_tetra))

% show them
tetra = find(DSO3.A_tetra(ind,:))

% show vertices
[u,v] = find(DSO3.I_oriTetra(tetra,:))

DSO3(unique(v))

angle_outer(DSO3(unique(v)),DSO3(unique(v))) / degree

tic

q = SO3Grid(1000000);

d = squeeze(double(q));

[K, v] = convhulln(d);

toc

%

cs = symmetry('m-3m');


for k = 1:numel(cs)
  
  
  q1 = cs(k)*q;
  
end

%% define an 

cs = symmetry('O');

x = linspace(-pi,pi,56);
y = linspace(-pi,pi,56);
z = linspace(-pi,pi,56);

[x,y,z] = meshgrid(x,y,z);

v = vector3d(x,y,z);
v = v(norm(v)<pi);

%%

ori = orientation('axis',v,'angle',norm(v),cs)

%%

ind = checkFundamentalRegion(ori);

%%

plot(quaternion(ori(ind)),'scatter')

%%

max(angle(quaternion(ori(ind)))) / degree
