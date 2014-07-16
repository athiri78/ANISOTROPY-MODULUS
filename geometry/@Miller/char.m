function c = char(m,varargin)
% Miller indece to string
%
% Options
%  no_scopes
%  latex
%  commasep

c = cell(length(m),1);

% output format
format = extract_option(varargin,{'hkl','uvw','UVTW'});
if ~isempty(format), m.dispStyle = format{1};end

for i = 1:length(m)
  
  abc = m.subSet(i).(m.dispStyle);
  
  switch m.dispStyle

    case {'uvw','UVTW'}
     
      if check_option(varargin,{'tex','latex'})
        leftBracket = '['; %'\left\langle ';
        rightBracket = ']';% '\right\rangle';
      else
        leftBracket = '[';%'<';
        rightBracket = ']';%'>';
      end
    
    case {'hkl','hkil'}
    
      if check_option(varargin,{'tex','latex'})
        leftBracket = '(';%'\{';
        rightBracket = ')';% '\}';
      else
        leftBracket = '(';%'{';
        rightBracket = ')';% '}';
      end
  end

  
  % only display rounded results
  if all(isappr(round(abc),abc))
    s = barchar(abc,varargin{:});
  else
    s = '---';
  end
  
  % add scopes
  if ~check_option(varargin,'NO_SCOPES'), s = [leftBracket s rightBracket]; end %#ok<AGROW>
  if check_option(varargin,'LaTeX'), s = ['$' s '$']; end %#ok<AGROW>
  
  c{i} = s;
end

if ~check_option(varargin,'cell'), c = strcat(c{:});end

% -----------------------------------------------------------------

function s=barchar(i,varargin)

comma = check_option(varargin,'commasep');
i = round(i);
s = '';
for j = 1:length(i)
  if (i(j)<0) && check_option(varargin,'latex')
    s = [s,'\bar{',int2str(-i(j)),'}']; %#ok<AGROW>
  else
    s = [s,int2str(i(j))]; %#ok<AGROW>
  end
  
  if comma && j < length(i)
    s = [s,','];
  end
end
