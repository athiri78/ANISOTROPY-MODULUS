function WizardFinish( api )

if api.Export.getGenerateScriptFile()
  
  generateScript();
  
else
  
  generateWorkspaceVariable();
  
end

  function generateWorkspaceVariable()
    
    slots = api.getDataType();
    
    for k=1:7
      d = api.getData(k);
      slotData{k} = [d{:}];
      slotFiles{k} = api.getFiles(k);
    end
    
    if any(slots >= 4) % polefigure data to be corrected
      try
        data = correct(slotData{4},...
          'Background',slotData{5},...
          'Defoccusing',slotData{6},...
          'DefoccusingBackground',slotData{7});
      catch
        data = slotData{4};
      end
    else
      data = slotData{slots(1)};
    end
    
    assignin('base',api.Export.getWorkspaceName(),data);
    
  end

  function generateScript()
    
    Export = api.Export;
    
    getSS         = Export.getOptSpecimen;
    getODF        = Export.getOptODF;
    getEBSD       = Export.getOptEBSD;
    
    getInterf     = Export.getInterface;
    getInterfOpts = Export.getInterfaceOptions;
    
    % specify crystal and specimen symmetries
    data = api.getData();
    data = [data{:}];
    
    str = loadTemplate(class(data));
    
    % crystal symmetry
    replaceMarkup('{crystal symmetry}'       , @getCrystalSymmetry      );
    replaceMarkup('{specimen symmetry}'      , @getSpecimenSymmetry     );
    
    % plotting convention
    replaceMarkup('{xAxisDirection}'         , @getXAxis                );
    replaceMarkup('{zAxisDirection}'         , @getZAxis                );
    
    % file paths
    optfiles = {'','bg ','def ','defbg '};
    
    for j=1:numel(optfiles)
      
      pathMarkup = ['{path to ' optfiles{j} 'files}'];
      fileMarkup = ['{' optfiles{j} 'file names}'];
      loadMarkup = ['pf_' optfiles{j} '= '];
      
      replaceMarkup(pathMarkup          , {@getFilePath,  optfiles{j}}, ...
        {@getLines,pathMarkup,-1:0}                                     );
      replaceMarkup(fileMarkup          , {@getFileNames, optfiles{j}}, ...
        {@getLines,fileMarkup,0}                                        );
      
      replaceMarkup(loadMarkup          , {@getLoadFile,  optfiles{j}}, ...
        {@getLines,loadMarkup,-2:0}                                     );
      
    end
    
    % if miller indices
    replaceMarkup('{Miller}'             , @getMiller               );
    
    % if structure coefficents
    replaceMarkup('c = {structural coefficients}'  , @getCoefficients , ...
      {@getLines,'c = {structural coefficients}',-2:1}                  );
    replaceMarkup('{structural coefficients}', @hasCoefficient        , ...
      '{structural coefficients},'                                      );
    
    % if there is bg, defocussing,...
    replaceMarkup('{corrections}'            , @getCorrections        , ...
      {@getLines,'{corrections}',[-1 0]}                                );
    
    % if 3d ebsd loaded from layes
    replaceMarkup('{Z-values}'               , @getZValues            , ...
      {@getLines,'{Z-values}',-2:1});
    replaceMarkup('{Z}'                      , @getZ                  , ...
      ',{Z}');
    
    % loadData replacements
    replaceMarkup('{interface}'              , @getInterface          , ...
      ',{interface}'                                                    );
    replaceMarkup('{options}'                , @getInterfaceOptions   , ...
      ',{options}'                                                      );
    
    % odf interface things
    replaceMarkup('{kernel name}'            , @getODFKernelName        );
    replaceMarkup('{halfwidth}'              , @getODFHalfwidth         );
    replaceMarkup('{method}'                 , @getODFMethod            );
    replaceMarkup('{resolution}'             , @getODFResolution      , ...
      '''resolution'',{resolution},'                                    );
    
    % data corections
    replaceMarkup('{phi1},{Phi},{phi2}'      , @getEulerRot           , ...
      {@getLines,'{phi1},{Phi},{phi2}',-2:1}                            );
    
    replaceMarkup('{rotationOption}'         , @getEulerRotOptions    , ...
      ',{rotationOption}'                                               );
    
    
    deleteDoubleEmptyLines();
    
    openUntitled(str);
    
    
    % ---------------- private functions ----------------------------------
    function replaceMarkup(token,repFun,delToken)
      
      if any(strfind(str,token))
        
        repFun = parseArg(repFun);
        
        if ~isempty(repFun)
          str = strrep(str,token,repFun);
        else
          
          delToken = parseArg(delToken);
          str = strrep(str,delToken,'');
          
        end
        
      end
      
      function fun = parseArg(fun)
        
        fun = ensurecell(fun);
        
        if isa(fun{1},'function_handle')
          fun = feval(fun{:});
        end
        
        if iscell(fun)
          fun = breakCells(fun);
        end
        
      end
      
      function str = breakCells(cells)
        
        lineBreaks = [...
          repmat({sprintf('\n')},numel(cells)-1,1); ...
          {''}];
        
        leadingWhiteSpace = [...
          {''}; ...
          repmat({'  '},numel(cells)-1,1)];
        
        cells = strcat(leadingWhiteSpace,cells(:),lineBreaks);
        
        str = [cells{:}];
        
      end
      
    end
       
    function lines = getLines(markup,offset)
      
      lineBreaks = [0 strfind(str,sprintf('\n')) numel(str)];
      match =  strfind(str,markup);
      
      if any(match)
        
        line = lineBreaks(1:end-1) < match & match < lineBreaks(2:end);
        lines = find(line)+offset;
        lines = str(lineBreaks(min(lines))+1:max(lineBreaks(lines+1)));
        
      else
        
        lines = '';
        
      end
      
    end
      
    function str = loadTemplate(dataType)
      
      %load template file
      file = fullfile(mtex_path,'templates','import',...
        ['load' dataType 'template.m']);
      
      fid = efopen(file);
      str = reshape(fread(fid,'*char'),1,[]);
      fclose(fid);
      
    end
    
    function deleteDoubleEmptyLines()
      
      lineBreaks = strfind(str,sprintf('\n'));
      
      lb = diff(lineBreaks)==1;
      lb = find(lb(1:end-1) & lb(2:end));
      
      for k = numel(lb):-1:1
        str(lineBreaks(lb(k))+1:lineBreaks(lb(k)+1)) = [];
      end
      
    end
    
    function openUntitled( str, fname )
      
      err = javachk('mwt','The MATLAB Editor');
      if ~isempty(err)
        local_display_mcode(str,'cmdwindow');  %??
      end
      
      if ~getMTEXpref('SaveToFile')
        try
          EditorServices = com.mathworks.mlservices.MLEditorServices;
          if ~verLessThan('matlab','7.11')
            EditorServices.getEditorApplication.newEditor(str);
          else
            EditorServices.newDocument(str,true);
          end
        catch %#ok<CTCH>
          setMTEXpref('SaveToFile',true);
          openUntitled( str, fname );
        end
      else
        [file path] = uiputfile([fname '.m']);
        if ischar(file)
          fname = fullfile(path,file);
          fid = fopen(fname,'w');
          fwrite(fid,str);
          fclose(fid);
          edit(fname);
        else
          error('no data file specified')
        end
      end
      
    end
    
    % ------------------ replaceMarkup Strings ----------------------------
    function str = getCrystalSymmetry()
      
      if isa(data,'EBSD')
        cs = get(data,'CSCell');
      else
        cs = {get(data,'CS')};
      end
      
      str = toString(cs);
      
      if numel(str) > 1
        str = [{'{... '} strcat(str(1:end-1),',...') strcat(str(end),'}')];
      end
      
      function str = toString(cs)
        
        for i=1:numel(cs)
          
          if isempty(cs{i})
            
            tmpString = 'symmetry()';
            
          elseif ischar(cs{i});
            
            tmpString = ['''' cs{i} ''''];
            
          else
            
            [axLength,axAngles] = get_axisangel(cs{i});
            
            opt = {};
            % for non cubic symmetries
            if ~any(strcmp(get(cs{i},'Laue'),{'m-3','m-3m'}))
              opt = [opt {axLength}]; %#ok<AGROW>
            end
            
            % for triclinic and monoclinic get angles
            if any(strcmp(get(cs{i},'Laue'),{'-1','2/m'}))
              opt = [opt {[n2s([axAngles{:}]),'*degree']}]; %#ok<AGROW>
            end
            
            opt = [opt get(cs{i},'alignment')]; %#ok<AGROW>
            
            mineral = get(cs{i},'mineral');
            if ~isempty(mineral)
              opt = [opt,{'mineral',mineral}];  %#ok<AGROW>
            end
            
            color = get(cs{i},'color');
            if ~isempty(color)
              opt = [opt,{'color',color}];  %#ok<AGROW>
            end
            
            tmpString = strcat('symmetry(''', get(cs{i},'name'),'''',option2str(opt,'quoted'),')');
            
          end
          
          str{i} = tmpString;
          
        end
        
      end
      
    end
    
    function str = getSpecimenSymmetry()
      
      str = ['symmetry(''',strrep(char(get(data,'SS')),'"',''), ''')'];
      
    end
    
    function str = getXAxis()
      
      xaxis = 1 + mod(getSS('direction')-1,4);
      
      str = ['''' NWSE(xaxis) ''''];
      
    end
    
    function str = getZAxis()
      
      % plotting convention
      zaxis = 1 + (getSS('direction') > 4);
      
      str = ['''' UpDown(zaxis) ''''];
      
    end
    
    function path = leastCommonPath(files)
      
      if numel(files)> 1
        path = fileparts(files{1}(1:find(any(diff(double(char(files)))),1,'first')));
      else
        path = fileparts(files{1});
      end
      
    end
    
    function files = getFilesByOpt(opt)
      
      slot = find(strcmpi(strtrim(opt),{'','bg','def','defbg'}))+3;
      if slot > 4
        files = api.getFiles(slot);
      else
        files = api.getFiles();
      end
      
    end
    
    function str = getFilePath(opt)
      
      files = getFilesByOpt(opt);
      
      if ~isempty(files)
        str = [''''  leastCommonPath(files) ''''];
      else
        str = '';
      end
      
    end
    
    function str = getFileNames(opt)
      
      files = getFilesByOpt(opt);
      
      if ~isempty(files)
        
        fnames = strrep(files,leastCommonPath(files),'');
        fnames = strcat('[pname ''',fnames,''']');
        
        if numel(fnames) > 1
          fnames = ['{...' strcat(fnames,',...') '}'];
        end
        
        str = fnames(:);
        
      else
        
        str = '';
        
      end
      
    end
    
    function str = getLoadFile(opt)
      
      if ~isempty(getFilesByOpt(opt))
        str = ['pf_'  opt '= '];
      else
        str = '';
      end
      
    end
    
    function str = getZValues()
      
      if getEBSD('is3d')
        Z = getEBSD('Z');
        
        Z = cellstr(strcat(cellfun(@num2str,Z(:)),',...'));
        Z(end) = {[Z{end}(1:end-4) ' ]']};
        str = [{'['}; Z(:)];
        
      else
        str = '';
      end
      
    end
    
    function str = getZ()
      
      if getEBSD('is3d')
        str = '''3d'',Z';
      else
        str = '';
      end
      
    end
    
    function str = getCorrections()
      
      types = api.getDataType()-4;
      types = types(types > 0);
      
      if ~isempty(types)
        % background, defoccusing, defoccusing background
        d = {'bg','def','defbg'};
        d = d(types);
        
        str = [strcat({''''},d,{''','}); strcat({'pf_'},d,{','})];
        str = [str{:}];
        str = str(1:end-1);
        
      else
        str = '';
      end
      
    end
    
    function str = hasCoefficient()
      
      if length(get(data,'c')) > length(data)
        str = {'''superposition'',c'};
      else
        str = '';
      end
      
    end
    
    function str = getCoefficients()
      
      % specifiy structural coefficients for superposed pole figures
      if length(get(data,'c')) > length(data)
        c = [];
        for k = 1:length(data)
          c = strcat(c,n2s(get(data(k),'c')),',');
        end
        cstr = strcat('c = {',c(1:end-1),'}');
      else
        cstr = '';
      end
      str = cstr;
      
    end
    
    function str = getMiller()
      
      str = {'{ ...'};      
      eps = 10e4;
      
      for k = 1:length(data)
        h = get(data(k),'h');        
        
        hkl = round(get(h,'hkl')*eps)./eps;

        sh = strcat('Miller(',num2str(hkl,'%d,'),'CS)');
    
        if size(sh,1) > 1
          sh = strcat(sh,', ');
          sh = reshape(sh',1,[]);
          sh = ['[' sh(1:end-1) ']'];          
        end
        
        str = [str [sh ',...']];        
      end
      str = [ str '}'];
      
    end
    
    function str = getODFKernelName()
      
      str = ['''' get(get(data,'psi'),'name') ''''];
      
    end
    
    function str = getODFHalfwidth()
      
      hw  = get(get(data,'psi'),'halfwidth');
      str = [xnum2str(hw/degree) '*degree'];
      
    end
    
    function str = getODFMethod()
      
      methods = {'''interp''','''density'''};
      
      str = methods{1+getODF('method')};
      
    end
    
    function str = getODFResolution()
      
      if getODF('exact')
        str = [num2str(getODF('approx')) '*degree'];
      else
        str = '';
      end
      
    end
    
    function str = getInterface()
      
      str = ['''interface'',''' getInterf() ''''];
      
    end
    
    function str = getInterfaceOptions()
      
      str = option2str(getInterfOpts(),'quoted');
      if ~isempty(str)
        str(1:2) = [];
        str = {'...' ; str };
      end
      
    end
    
    function str = getEulerRot()
      
      rot = getSS('rotate');
      if ~isnull(angle(rot))
        [p(1) p(2) p(3)] = Euler(rot,'ZXZ');
        str = [strrep(xnum2str(p/degree),' ','*degree,') '*degree'];
      else
        str = '';
      end
    end
    
    function str = getEulerRotOptions()
      
      rotationOptions = {'','''keepXY''','''keepEuler'''};
      str = rotationOptions{getSS('rotOption')};
      
    end
    
    function s = n2s(n)
      
      s = num2str(n(:).');
      s = regexprep(s,'\s*',',');
      if length(n) > 1, s = ['[',s,']'];end
      
    end
    
  end


end