classdef Miller < vector3d
%(InferiorClasses = {?vector3d,?S2Grid})
  properties
    CS        % crystal symmetry
    dispStyle = 'hkl' % output convention hkl or uvw
  end
  
  properties (Dependent = true)    
    hkl       % direct coordinates    
    h
    k
    i
    l
    uvw       % reciprocal coordinates
    u
    v
    t
    w
  end
    
  methods

    function m = Miller(varargin)
      % define a crystal direction by Miller indice
      %
      % Syntax
      % m = Miller(h,k,l,cs) -
      % m = Miller(h,k,l,cs,'hkl') -
      % m = Miller(h,k,l,cs,'pole') -
      % m = Miller(h,k,i,l,cs) -
      % m = Miller('(hkl)',cs) -
      % m = Miller(u,v,w,cs,'uvw') -
      % m = Miller(u,v,t,w,cs,'uvw') -
      % m = Miller(u,v,w,cs,'direction') -
      % m = Miller('[uvw]',cs) -
      % m = Miller('[uvw]\[uvw],cs) -
      % m = Miller('(hkl)\(hkl),cs) -
      % m = Miller(x,cs) -
      %
      %
      % Input
      %  h,k,l,i(optional) - Miller indice of the plane normal
      %  u,v,w,t(optional) - Miller indice of a direction
      %  x  - @vector3d
      %  cs - crystal @symmetry
      %
      % See also
      % vector3d_index symmetry_index
      
      % check for symmetry
      m.CS = getClass(varargin,'symmetry',symmetry);

      if nargin == 0 %empty constructor

        return
  
      elseif isa(varargin{1},'Miller') % copy constructor
  
        m = varargin{1};
        return;
  
      elseif isa(varargin{1},'vector3d') % vector3d
  
        if any(norm(varargin{1}) == 0)
          error('(0,0,0) is not a valid Miller index');
        end
        
        [m.x,m.y,m.z] = double(varargin{1});
        m.opt = varargin{1}.opt;
        m.antipodal = varargin{1}.antipodal;
        
        % hkl and uvw
      elseif isa(varargin{1},'double')
        
        % get hkls and uvw from input
        nparam = min([length(varargin),4,find(cellfun(@(x) ~isa(x,'double'),varargin),1)-1]);
        
        % check for right input
        if nparam < 3, error('You need at least 3 Miller indice!');end
        
        % check fourth coefficient is right
        if nparam==4 && all(varargin{1} + varargin{2} + varargin{3} ~= 0)
          if check_option(varargin,{'uvw','uvtw','direction'})
            warning(['Convention u+v+t=0 violated! I assume t = ',int2str(-varargin{1} - varargin{2})]); %#ok<WNTAG>
          else
            warning(['Convention h+k+i=0 violated! I assume i = ',int2str(-varargin{1} - varargin{2})]); %#ok<WNTAG>
          end
        end
        
        % set coordinates
        coord = cellfun(@(c) c(:),varargin(1:nparam));
        if check_option(varargin,{'uvw','uvtw','direction'});          
          
          m.uvw = coord;
          
        elseif check_option(varargin,'xyz');
          
          m.x = coord(:,1);
          m.y = coord(:,2);
          m.z = coord(:,3);
          m.dispStyle = 'xyz';
          
        else          
          
          m.hkl = coord;
          
        end
        
      end

      % add antipodal symmetry ?
      m.antipodal = check_option(varargin,'antipodal');

    end
    
    % -----------------------------------------------------------
    function hkl = get.hkl(m)
      
      % get reciprocal axes
      M = squeeze(double(get(m.CS,'axes*'))).';
      
      % get xyz coordinates
      v = reshape(double(m),[],3).';

      % compute reciprocal coordinates
      hkl = (M \ v)';

      % add fourth component for trigonal and hexagonal systems
      if any(strcmp(Laue(m.CS),{'-3','-3m','6/m','6/mmm'}))
        hkl = [hkl(:,1:2),-hkl(:,1)-hkl(:,2),hkl(:,3)];
      end
      
    end
    
    function h = get.h(m), h = m.hkl(:,1);end
    function k = get.k(m), k = m.hkl(:,2);end
    function i = get.i(m), i = m.hkl(:,3);end
    function l = get.l(m), l = m.hkl(:,end);end
        
    % ------------------------------------------------------------
    function m = set.hkl(m,hkl)
      % 
      % hkl must have the format [h,k,l] or [h k i l]
      
      % remove i 
      hkl = hkl(:,[1:2,end]);
      
      % get reciprocal axes
      M = squeeze(double(get(m.CS,'axes*')));
      
      % compute x, y, z coordinates
      m.x = hkl * M(:,1);
      m.y = hkl * M(:,2);
      m.z = hkl * M(:,3); 
      
      % set default display style
      m.dispStyle = 'hkl';
      
    end
    
    
    % -----------------------------------------------------------
    function uvtw = get.uvw(m)
    
      % get crystal coordinate system (a,b,c)
      M = squeeze(double(m.CS.axis)).';

      % get x, y, z coordinates
      xyz = reshape(double(m),[],3).';

      % compute u, v, w coordinates
      uvtw = (M \ xyz)';

      % add fourth component for trigonal and hexagonal systems
      if any(strcmp(Laue(m.CS),{'-3','-3m','6/m','6/mmm'}))
    
        uvtw(:,4) = uvtw(:,3);
        uvtw(:,3) = -(uvtw(:,1) + uvtw(:,2))./3;
        [uvtw(:,1), uvtw(:,2)] = deal((2*uvtw(:,1)-uvtw(:,2))./3,(2*uvtw(:,2)-uvtw(:,1))./3);
  
      end
    end
      
    function u = get.u(m), u = m.uvw(:,1);end
    function v = get.v(m), v = m.uvw(:,2);end
    function t = get.t(m), t = m.uvw(:,3);end
    function w = get.w(m), w = m.uvw(:,end);end
        
    % ------------------------------------------------------------
    
    function m = set.uvw(m,uvw)
      %
      % uvw must be of format [u v w] or [u v t w] 
      
      % correct for 4 component vectors
      if size(uvw,2) == 4
        
        uvw = [uvw(:,1)-uvw(:,3),uvw(:,2)-uvw(:,3),uvw(:,4)];
        
      elseif any(strcmp(Laue(m.CS),{'-3','-3m','6/m','6/mmm'}))
        
        uvw = [2*uvw(:,1) + uvw(:,2),2*uvw(:,2) + uvw(:,1),uvw(:,3)];
        
      end
               
      % get direct axes 
      M = squeeze(double(m.CS.axis));
      
      % compute x, y, z coordinates
      m.x = uvw * M(:,1);
      m.y = uvw * M(:,2);
      m.z = uvw * M(:,3);
      
      % set default display style
      m.dispStyle = 'uvw';
      
    end
    
  end
      
end

