%% Importing EBSD Data
% How to import EBSD Data
%
%% Open in Editor
%
%% Contents
%
%%
% Importing EBSD data into MTEX is mainly done by creating a instance of
% the class @EBSD from an EBSD data file. Once such an @EBSD object has
% been created, the data can be futher <EBSDModifyData.html manipulated>,
% <EBSDOrientationPlots.html visualized> and <EBSD2odf.html analyzed>, or
% further be generalized by means of <GrainReconstruction.html grain
% reconstruction> with the help of its class [[EBSD_index.html#12,methods]].
%
%% Importing EBSD data using the import wizard
%
% The simplest way to import EBSD data is to use the
% <matlab:import_wizard('EBSD') |import wizard|>. The |import_wizard| can
% be started either by typing into the command line

import_wizard('EBSD'); 

%%
% or by using the start menu item *Start/Toolboxes/MTEX/Import Wizard* and
% switch to the EBSD tab. EBSD Data files can be also imported via the
% <matlab:filebrowser file browser> by choosing *Import Data* from the
% context menu of the selected file, if its file extension was registered
% with <matlab:opentoline(fullfile(mtex_path,'mtex_settings.m'),25,1)
% |mtex_settings.m|>
%
% The import wizard guides through the correct setup of:
%
% * <CrystalSymmetries.html crystal symmetries> associated with phases 
% * specimen symmetry and plotting conventions
% 
% In the end the imported wizard creates a workspace variable or generates
% a m-file loading the data automatically. Furthermore appending a template
% script allows radip data processing.
%
%% Supported Data Formats
%
% The import wizard supports the import of the following EBSD data formats:
%
% || <loadEBSD_ang.html     **.ang*> || TSL single orientation files.             ||
% || <loadEBSD_csv.html     **.csv*> || Oxford single orientation files.          ||
% || <loadEBSD_ctf.html     **.ctf*> || HKL single orientation files.             ||
% || <loadEBSD_sor.html     **.sor*> || LaboTEX single orientation files.         ||
% || <loadEBSD_generic.html **.txt*> || ASCII files with Euler angles as columns. ||
%
% If the data is recognized as an ASCII list of orientations, phase and spatial
% cooridnates in the form 
%
%  alpha_1 beta_1 gamma_1 phase_1 x_1 y_1
%  alpha_2 beta_2 gamma_2 phase_2 x_2 y_2
%  alpha_3 beta_3 gamma_3 phase_3 x_3 y_3
%  .      .       .       .       .   .
%  .      .       .       .       .   .
%  .      .       .       .       .   .
%  alpha_M beta_M gamma_M phase_m x_m y_m
%
% an additional tool supports to associated the columns with the
% corresponding properties.
%
%% The Import Script
%
% EBSD data can be also imported by the command <loadEBSD.html loadEBSD>.
% The |loadEBSD| function automatically detects the data format and imports
% the data, but it might be neccesary to specify the crystal symmetries of
% all occuring phases and additional information about the format.
%
%%
% A script generated by the import wizard has the following form:

% specify how to align the x-axis in plots
plotx2east

% specify crystal and specimen symmetry
CS = {...
  'notIndexed',...
  symmetry('m-3m'),... % crystal symmetry phase 1
  symmetry('m-3m')};   % crystal symmetry phase 2
SS = symmetry('-1');   % specimen symmetry

% file name
fname = fullfile(mtexDataPath,'EBSD','85_829grad_07_09_06.txt');

% import ebsd data
ebsd = loadEBSD(fname,CS,SS,'interface','generic',...
  'ColumnNames', ... 
      { 'id' 'Phase' 'x' 'y'  ...
        'Euler 1' 'Euler 2' 'Euler 3'  ...
        'Mad' 'BC'},...
  'Bunge')

%%
% Running this script imports the data into a variable named
% |ebsd|. From this point, the script can be extended to your needs, e.g:

plot(ebsd,'property','phase')

%% Writing your own interface
%
% In case that the EBSD format is not supported, you can write an interface
% by your own to import the data. Once you have written such an interface
% that reads data from certain data files and generates a EBSD object you
% can integrate this method into MTEX by copying it into the folder
% |MTEX/qta/interfaces| and rename your function |loadEBSD_xxx|. Then it
% will be automatical recognized by the import wizard. Examples how to
% write such an interface can be found in the directory
% |MTEX/qta/interfaces|.
%
%% See also
% Templates

