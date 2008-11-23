function save(pf,filename,varargin)
% save pole figure in an ASCII file
%
% the pole figure data for each crystal direction are stored in a seperate 
% ASCII file. The ASCII file contains three columns - |theta| - |rho| -
% |intensity|, where (|theta|, |rho|) are the polar coordinates of the specimen
% directions and |intensity| is the diffraction intensity
%
%% Input
%  pf       - @PoleFigure
%  filename - string
%
%% Options
%  DEGREE - theta / rho output in degree instead of radians
%
%% See also
% loadPoleFigure_txt

for i = 1:length(pf)
  dname = [filename,'_',char(pf(i).h),'.txt'];

  [theta,rho] = polar(pf(i).r);
	if check_option(varargin,'DEGREE')
		theta = theta * 180'/pi;		
		rho = rho * 180'/pi;
	end
	d = [theta(:),rho(:),pf(i).data(:)]; %#ok<NASGU>
  save(dname,'d','-ASCII');
    
end
