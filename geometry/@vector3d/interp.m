function yi = interp(v,y,vi,varargin)
% dirty spherical interpolation - including some smoothing

if check_option(varargin,'nearest')
  
  [ind,d] = find(v,vi);
  yi = y(ind);
  yi(d > 2*v.resolution) = nan;
  yi = reshape(yi,size(vi));
  
else
  
  res = v.resolution;
  psi = deLaValeePoussinKernel('halfwidth',res/2);
  
  % take the 4 largest values out of each row
  omega = angle_outer(vi,v,varargin{:});
  [so,j] = sort(omega,2);
  
  i = repmat((1:size(omega,1)).',1,4);
  if check_option(varargin,'inverseDistance')
    M = 1./so(:,1:4); M = min(M,1e10);
  else
    M = psi.RK(cos(so(:,1:4)));
  end
  
  M = repmat(1./sum(M,2),1,size(M,2)) .* M;
  M = sparse(i,j(:,1:4),M,size(omega,1),size(omega,2));
  
  yi = M * y(:);
  
end
  
end
