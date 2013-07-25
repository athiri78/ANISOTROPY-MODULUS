function h = hkl(h)
% change crystal direction convention to hkl coordinates if not done yet
%
% See also
% Miller/uvw

h.options.uvw = false;

if ~check_option(h,'hkl')
  h = set_option(h,'hkl');
end