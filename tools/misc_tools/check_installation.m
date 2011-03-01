function check_installation
% check whether all binaries are working properly



%% -------------- check tmp dir ------------------------------
if strfind(get_mtex_option('tempdir',tempdir),' ')
  hline()
  disp('Warning: The path MTEX uses for temporary files');
  disp(['  tempdir = ''' get_mtex_option('tempdir') '''']);
  disp('contains white spaces!');
  disp(['Please change this in your <a href="matlab:edit mtex_settings.m">' ...
    'mtex_settings.m</a>!']);
  hline()
end

check_binaries;
check_mex;
check_mex_blas;

%% ------------ check for binaries --------------------------
function check_binaries

[th,rh] = polar(S2Grid('equispaced','points',10));
	
th = fft_theta(th);
rh = fft_rho(rh);

gh = [reshape(rh,1,[]);reshape(th,1,[])];
r = [reshape(rh,1,[]);reshape(th,1,[])];

c = ones(size(th));

Al = ones(size(th));

try
    
  f = call_extern('odf2pf','EXTERN',gh,r,c,Al);
  assert(any(f));
  
catch %#ok<*CTCH>
  
  if ismac && strcmp(get_mtex_option('architecture'),'maci') % maybe it is a 64 bit mac
    try
      set_mtex_option('architecture','maci64');
      f = call_extern('odf2pf','EXTERN',gh,r,c,Al);
      assert(any(f));
      return
    catch
      set_mtex_option('architecture','maci');
    end    
  end
  
  hline()
  disp('  MTEX binary check failed!');  
  disp(' ');
  disp('  The original error message was:');
  e = lasterror; %#ok<*LERR>
  disp(['  ',e.message]); 
   
  disp(' ');
  disp('  Check the following options:');  
  disp(['  * ' doclink('compilation','Compile') ' the binaries yourself.']);
  disp('  * Ask the maintainer for help!');
  hline()
end


%%    ----------- check mex files ---------------------------
function check_mex

% set mex/directory
mexpath = fullfile(mtex_path,'c','mex',get_mtex_option('architecture'));
addpath(mexpath,0);

% check for mex files
if fast_check_mex, return;end
        
hline('-');
disp('Checking mex files failed!');

% check old mex version
if exist(fullfile(mexpath,'v7.1'),'dir')
    
  % change path  
  rmpath(mexpath);
  addpath(fullfile(mexpath,'v7.1'));
  disp('> Trying now with older version.');
  if fast_check_mex
    disp('> Hurray - everythink works!')
    disp(' ');
    try
      copyfile(fullfile(mexpath,'v7.1','*.*'),mexpath,'f');
      % restore path
      rmpath(fullfile(mexpath,'v7.1'));
      addpath(mexpath);
    catch
      hline()
      disp('> Error while copying!')
      disp('> You should copy');
      disp(['  ' fullfile(mexpath,'v7.1')]);
      disp(' to ');
      disp(['  ', mexpath]);
      disp('> before starting the next session');
      hline()
      disp(' ');
    end    
    return
  else
    disp('> Checking old mex files failed!');
    % restore path
    rmpath(fullfile(mexpath,'v7.1'));
    addpath(mexpath);   
  end
end   

disp('> Trying now to recompile mex files.');
opwd = pwd;
cd(fullfile(mtex_path,'c','mex'));
mex_install(mtex_path,false);
cd(opwd);    
    
if ~fast_check_mex
%   disp('> Hurray - everythink works!')
% else
  hline()
  disp('  MTEX: Couldn''t get the mex files working!');
  disp('   ');
  disp('  The original error message was:');
  e = lasterror;
  disp(['  ' e.message]);
  
  disp(' ');
  disp('  Contact author for help!');
  hline()
end
hline('-')


%%    ----------- check mex blas files ---------------------------

function check_mex_blas

% set mex/directory
mexpath = fullfile(mtex_path,'c','mex',get_mtex_option('architecture'));
addpath(mexpath,0);

% check for mex files
if fast_check_mex_blas, return;end
   
hline('-')
disp('Checking mex files including blas library failed!');


disp('> Trying now to recompile mex files including blas library.');
opwd = pwd;
cd(fullfile(mtex_path,'c','mex'));
mex_install(mtex_path,true);
cd(opwd);    
    
if ~fast_check_mex_blas
%   disp('> Hurray - everythink works!')
% else
  hline()
  disp('  MTEX: Couldn''t get the mex files including blas working!');
  disp('  MTEX: Tensor arithmetics may not work!');
  disp('  ');
  disp('  The original error message was:');
  e = lasterror;
  disp(['  ' e.message]);
  
  disp(' ');
  disp('  Contact author for help!');
  hline()
end
hline('-')

%% ----------------------------------------------------------------------
function e = fast_check_mex

e = 1;
try
  S3G = SO3Grid(100,symmetry,symmetry);
  dot_outer(S3G,idquaternion,'epsilon',pi/10);
catch
  e = 0;  
end

%% -----------------------------------------------------------------------
function e = fast_check_mex_blas

e = 1;
try
  T = tensor(eye(3));
  assert(~any(isnan(double(EinsteinSum(T,[-1 -2],T,[-1 -2])))));
catch
  e = 0;  
end


function hline(st)
if nargin < 1, st = '*'; end
disp(repmat(st,1,80));
