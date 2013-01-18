%% MTEX Changelog
%
%% MTEX 3.4.0 - 01/2013
%
% *New plotting engine*
%
% MTEX 3.4 features a completely rewritten plotting engine. New features
% includes
%
% * The alignment of the axes in the plot is now described by the options
% |xAxisDirection| which can be |north|, |west|, |south|, or |east|, and
% |zAxisDirection| which can be |outOfPlane| or |intoPlane|.
% * The alignment of the axes can be changed interactively using the new
% MTEX menu which is located in the menubar of each figure.
% * northern and southern hemisphere are now separate axes that can be
% stacked arbitrarily and are marked as north and south.
% * Arbitary plots can be combined in one figure.
% * One can now arbitrarily switch between scatter, contour and smooth
% plots for any data.
% * obsolete options: |fliplr|, |flipud|, |gray|, 
% 
% *Colormap handling*
%
% * User defined colormap can now be stored in the folder |colormaps|, e.g.
% as |red2blueColorMap.m| and can set interactively from the MTEX menu or
% by the command
%
%   mtexColorMap red2blue
%
% *ODF*
%
% * the computation of more then one maximum is back. Use the command
%
%   [modes, values] = calcModes(odf,n)
%
% *EBSD data*
%
% * MTEX is now aware about inconsistent coordinate system used in CTF and
% HKL EBSD files for Euler angles and spatial coordinates. The user can now
% convert either the spatial coordinates or the Euler angles such that they
% become consistent. This can be easily done by the import wizard or via
% the commands
%
%   % convert spatial coordinates to Euler angle coordinate system
%   loadEBSD('filename','convertSpatial2EulerReferenceFrame')
%
%   % convert Euler angles to spatial coordinate system
%   loadEBSD('filename','convertEuler2SpatialReferenceFrame')
%
% * It is now possible to store a color within the variable describing a
%  certain mineral. This makes phase plots of EBSD data and grains more
%  consistent and customizable.
%
%   CS = symmetry('cubic','mineral','Mg','color','red')
%
% * Better rule of thumb for the kernel width when computing an ODF from
% individual orientations via kernel density estimation.
% * inpolygon can be called as
%
%   inpolygon(ebsd,[xmin ymin xmax ymax])
%
% *Tensors*
%
% * new command to compute the Schmid tensor
%
%   R = SchmidTensor(m,n)
%
% * new command to compute Schmid factor and active slip system
%
%   [tauMax,mActive,nActive,tau,ind] = calcShearStress(stressTensor,m,n,'symmetrise')
%
% * it is now possible to define a tensor only by its relevant entries.
% Missing entries are filled such that the symmetry properties are
% satisfied.
%
% * faster, more stable tensor implementation
% * new syntax in tensor indexing to be compatible with other MTEX classes.
% For a 4 rank thensor |C| we have now
%
%   % extract entry 1,1,1,1 in tensor notation
%   C{1,1,1,1}
%
%   % extract entry 1,1 in Voigt notation
%   C{1,1}
% 
% For a list of tensors |C| we have
%
%   % extract the first tensor
%   C(1)
%
% *Import / Export*
%
% * command to export orientations
%
%   export(ori,'fname')
%
% * command to import vector3d
%
%  v   = loadvector3d_generic('fname','ColumnNames',{'x','y','z'})
%  v   = loadvector3d_generic('fname','ColumnNames',{'latitude','longitude'})
%
% * new interface for DRex
% * new interface for Rigaku
% * new interface for Saclay
%
%% MTEX 3.3.2 - 01/2013
%
% *bugfix release*
%
% * fix: better startup when using different MTEX versions
% * fix: backport of the tensor fixes from MTEX 3.4
% * fix: show normal colorbar in ebsd plot if scalar property is plotted
% * fix: http://code.google.com/p/mtex/issues/detail?id=82
% * fix: http://code.google.com/p/mtex/issues/detail?id=76
% * fix: http://code.google.com/p/mtex/issues/detail?id=48
% * fix: http://code.google.com/p/mtex/issues/detail?id=71
% * fix: http://code.google.com/p/mtex/issues/detail?id=70
% * fix: http://code.google.com/p/mtex/issues/detail?id=69
% * fix: http://code.google.com/p/mtex/issues/detail?id=65
% * fix: http://code.google.com/p/mtex/issues/detail?id=68
%
%% MTEX 3.3.1 - 07/2012
%
% *bugfix release*
%
% * fix: single/double convention get sometimes wrong with tensors
% * fix: tensor checks did not respect rounding errors
% * fix: ingorePhase default is now none
% * fix: calcAngleDistribution works with ODF option
% * fix: respect rounding errors when importing pole figures and ODFs
%
%% MTEX 3.3.0 - 06/2012
%
% *Grains: change of internal representation*
%
% Reimplementation of the whole *grain* part:
%
% * The classes @grain, @polygon, @polyeder do not exist any longer. The
% functionality of the classes is mainly replaced by the classes @GrainSet,
% @Grain2d and @Grain3d
% * The class @GrainSet explicitely stores @EBSD. To access @EBSD data
% within a single grain or a set of grains use
%
%   get(grains,'EBSD')
%
% * the grain selector tool for spatial grain plots was removed,
% nevertheless, grains still can be [[GrainSingleAnalysis.html,selected spatially]].
% * scripts using the old grain engine may not work properly, for more
% details of the functionalities and functioning of the @GrainSet please
% see the documention.
% * new functionalities: merge grains with certain boundary.
%
% *EBSD*
%
% * Behavior of the |'ignorePhase'| changed. Now it is called in general
% |'not indexed'| and the not indexed data [[ImportEBSDData.html,is
% imported generally]]. If the crystal symmetry of an @EBSD phase is set to a
% string value, it will be treated as not indexed. e.g. mark the first
% phase as |'not indexed'|
% 
%   CS = {'not indexed',...
%         symmetry('cubic','mineral','Fe'),...
%         symmetry('cubic','mineral','Mg')};
%
% By default, |calcGrains| does also use the |'not Indexed'| phase.
%
% * create custemized orientation colormaps
%
% *Other*
%
% * the comand |set_mtex_option| is obsolete. Use the matlab command 
% |setpref('mtex',...)| instead. Additionally, one can now see all options 
% by the command |getpref('mtex')|
%
%% MTEX 3.2.3 - 03/2012
% 
% *bugfix release*
%
% * allow zooming for multiplot objects again; change the z-order of axes
% * symmetries allows now options a | | x additional to x | | a
% * fix http://code.google.com/p/mtex/issues/detail?id=35
% * fix http://code.google.com/p/mtex/issues/detail?id=38
% * fix http://code.google.com/p/mtex/issues/detail?id=28
% * fix export odf
%
%% MTEX 3.2.1 - 11/2011
%
% *New Features*
%
% * Import and Export to VPSC
% * export EBSD data with all properties
% * improved ODF calculation from pole figures by using quadrature weights
% for the pole figure grid
% * implemented spherical Voronoi decomposition and computation of
% spherical quadrature weights
% * plot odf-space in omega-sections, i.e. generalization of sigma-sections
%
% *Bug Fixes*
%
% * S2Grid behaves more like vector3d
% * vector3d/eq takes antipodal symmetry into account
% * Euler angle conversion was sometimes wrong
% * tensors multipliaction was sometimes wrong
% * rank 3 tensors get options 'doubleConvention' and 'singleConvention'
% for the conversion into the Voigt matrix representation
% * documentation fixes
% * Miller('[100]') gives not the correct result
% * import wizard now generates correct CS definition
% * import filter for uxd files should now work more reliable
%
%% MTEX 3.2 - 05/2011
%
% *3d EBSD Analysis*
%
% This release for the first time supports 3d EBSD data. In particular,
% MTEX is now able to
%
% * import 3d EBSD data from stacked files
% * visualize 3d EBSD data by plotting interactive slices through the
% specimen
% * 3d grain detection
% * topology of 3d grains, i.e. boundaries, neighbouring grains, etc.
%
% *Misorientation Analysis*
%
% * computation of the uncorrelated misorientation distribution (MDF) for
% one or two ODFs
% * computation of the theoretical angle distribution of an ODF or MDF
% * computation of the misorienation to mean for EBSD data
%
% *New Syntax for EBSD and grain variables*
%
% EBSD and grain variables can now be indexed by phase, region or grain /
% ebsd variables. Let us assume we have a two phase ebsd variable
% containing 'Fe' and 'Mg' then can restrict our dataset to the Fe - phase
% only be writting
%
%  ebsd('Fe')
%
% The same works with grains and also with more than one phase. Please have
% a look into the documentation for information how to index ebsd and grain
% variables.
%
% Accordingly the following syntax is now depreciated.
%
%  calcODF(ebsd,'phase',2)
%
% It should be replaced by
%
%  calcODF(ebsd('Fe'))
%
%
% *Other Enhangments*
%
% * better import and export of pole figures, odfs and EBSD data
% * automatic centering of a specimen with repsect to its specimen symmetry
% * download and import tensors from http://www.materialproperties.org/
% * new interfaces for Rigaku, Siemens, Bruker and many other X-ray devices
% and formats
% * support for rank three tensors, i.e, for piezo electricity tensors
% * improved documentation
% * many bug fixes
%
%% MTEX 3.1 - 03/2011
%
% *Tensor Arithmetics* This release introduces tensor analysis into MTEX,
% this includes
%
% * import of tensors via the import wizard
% * basic tensor operations: multiplication, rotation, inversion
% * advanced visualization
% * computation of avaraged tensors from EBSD data and ODFs
% * computation of standard elasticity tensors like: Youngs modulus, linear
% compressibility, Cristoffel tensor, elastic wave velocities
%
% *Other Enhangments*
%
% * support for different crystal reference frame conventions
% * automatic conversion between different reference frames
% * definition of crystal directions in direct and reciprocal space
% * more predefines orientations: Cube, CubeND22, CubeND45, CubeRD, Goss,
% Copper, SR, Brass, PLage, QLage, ...
% * improved EBSD and grain plots
% * new and improved interfaces
% * many bug fixes
%
%
%% MTEX 3.0 - 10/2010
%
% *Crystal Geometry*
%
% This release contains a completely redesigned crystal geometry engine
% which is thought to be much more intuitive and flexible. In particular,
% it introduces two new classes <rotation_index.html rotation> and
% <orientation_index.html orientation> which make it much more easier to
% work with crystal orientations. Resulting features are
%
% * no more need for quaternions
% * support for Bunge, Roe, Matthies, Kocks, and Canova Euler angle
% convention
% * simple definition of fibres
% * simple check whether two orientations are symmetrically equivalent
%
% *Other Enhangments*
%
% * automatic kernel selection in ODF estimation from EBSD data
% * support for Bingham model ODFs
% * esimation of Bingham parameters from EBSD data
% * faster and more accurate EBSD simulation
% * faster grain reconstruction
% * improved documentation
% * impoved output
% * MTEX is now compatibel with NFFT 3.1.3
%
%
%% MTEX 2.0 - 10/2009
%
% *Grain Analysis for EBSD Data*
%
% MTEX is now able to partition spatial EBSD data into grains. This allows
% for the computation of various grain characteristics, as well as the
% computation and visualization of the grain boundaries and neighborhood
% relationships. Main features are:
%
% * Grains statistics (area, diameter, mean orientation, ...)
% * Missorientation analysis
% * Interactive selection of grains by various criteria
% * ODF-calculations for any subset of grains
% * A large palette of plotting possibilities.
%
% *Visualization Improvements*
%
% * ODF fibre plot
% * support for different x-axis alignment - <plotx2north.html
% plotx2north>, <plotx2east.html plotx2east>
% * plot EBSD data with respect to arbitrary properties
% * plot zero regions of ODFs and pole figures white
% * pole figure contour plots
% * color triangle for spatial EBSD plots
%
% *General Improvements*
%
% * ODF import / export
% * rotate EBSD data
% * Pole figure normalization
% * improved interfaces and import wizard
% * speed improvement of several side-functions as well as core-functions
% of @quaternions and spherical grids.
%
% *Incompatible Changes to Previous Versions*
%
% * The flags *reduced* and *axial* have been replaced by the flag
% <AxialDirectional.html antipodal>
%
%% MTEX 1.2 - 05/2009
%
% *Improved EBSD import*
%
% * import weighted EBSD (e.g. from odf modeling)
% * new HKL and Chanel interfaces (.ang and .ctf files)
% * import of multiple phases
% * import of arbitrary properties as MAD, detection error, etc.
%
% *Improved EBSD plotting*
%
% * plot EBSD data in axis angle and Rodrigues space
% * annotations in these spaces
% * plot arbitrary properties as MAD, detection error, etc.
% * better orientation colorcoding
% * superpose odf, pole figure and EBSD plots
% * better interpolation
%
% *General Improvements*
%
% * support for different crystal geometry setups
% * faster and more accurate volume computation
% * improved function modalorientation
% * improved documentation
%
% *Incompatible Changes to Previous Versions*
%
% * The flag *reduced* has been replaced by the flag <AxialDirectional.html
% axial>
%
%% MTEX 1.1 - 12/2008
%
% *Improved Import Wizzard*
%
% * Load CIF files to specify crystal geometry
% * Import EBSD data with coordinates
% * More options to specify the alignment of the specimen coordinate system
% * support for popla *.epf files, *.plf files, and *.nja files
%
%
% *Improved Pole Figure Analysis*
%
% * Background correction and defocussing
% * Outlier detection and elimination
%
% *Improved EBSD Data Support*
%
% * Spatial plot of EBSD data
% * Modify EBSD data in the same way as pole figures
%
% *Improved Plotting*
%
% * GUI to modify plots more easily
% * Annotate orientations into pole figure plots
% * Annotate orientations into ODF sections
% * Coordinate systems for ODF and pole figure plots
% * More flexible and consistent option system
% * Default plotting options like FontSize, Margin, ...
% * Speed improvements
%
% *Bug Fixes*
%
% * ModalOrientation works now much better
% * Plot (0,0) coordinate in ODF plot at upper left
% * Fixed a bug in ODF estimation from EBSD data
%
%
%% MTEX 1.0 - 06/2008
%
% *New Installer Including Binaries for Windows, Linux, and Max OSX*
%
% * MTEX ships now with an automated installer and binaries for Windows,
% Linux, and Mac OSX. This makes it in unnecessary to install any
% additional library and to compile the toolbox. (Thanks to F. Bachmann, C.
% Randau, and F. Wobbe)
%
% *New ODF Class*
%
% * The new function <FourierODF.html FourierODF> provides an easy way to
% define ODFs via their Fourier coefficients. In particular MTEX allows now
% to calculate with those ODFs in the same manner as with any other ODFs.
%
% *New Interfaces*
%
% * New PoleFigure interface for xrdml data (F. Bachmann)
%
% *Improved Plotting*
%
% * Plot EBSD data and continious ODFs into one plot
% * Miller indeces and specimen directions can now be plotted directly into
% pole figures or inverse pole figures.
% * New plotting option north, south for spherical plots
% * Improved colorbar handling
% * Spherical grids
% * More spherical projections
%
% *Incompatible Changes With Previous Releases*
%
% * The flag *hemishpere* in <S2Grid.S2Grid.html S2Grid> has been replaced
% by *north*, *south*, and *antipodal* making it more consistent with the
% plotting routine.
%
% *Improved Documentation*
%
% MTEX comes now with over 500 help pages explaining the mathematical
% concepts, the philisophy behing MTEX and the syntax and usage of all 300
% functions available in MTEX. Furthermore, you find numerous examples and
% tutorials on ODF estimation, data import, calculation of texture
% characteristics, ODF and pole figure plotting, etc.
%
% *Bug Fixes*
%
% * Fixed zero range method
% * Fixed automatic ghost correction
% * Fixed some loadPoleFigure issues
% * Many other bug fixes.
%
%
%% MTEX 0.4 - 04/2008
%
% *Speed Improvments*
%
% * ODF reconstruction and PDF calculation is about *10 times faster* now
% (thanks to the new NFFT 4.0 library)
% * ODF plotting and the calculation of [[ODF.volume.html,volume
% fractions]], the [[ODF.textureindex.html,texture index]], the
% [[ODF.entropy.html,entropy]] and [[ODF.calcFourier.html,Fourier
% coefficients]] is about *100 times faster*
%
% *New Support of EBSD Data Analysis*
%
% * [[ImportEBSDData.html,Import]] EBSD data from arbitrary data formats.
% * New class [[EBSD_index.html,EBSD]] to store and manipulate with EBSD
% data.
% * [[EBSD.plotpdf.html,Plot pole figures]] and inverse pole figures from
% EBSD data.
% * [[EBSD.calcODF.html,Recover]] ODFs from EBSD data via kernel density
% estimation.
% * [[EBSD.calcODF.html,Estimate]] Fourier coefficients from EBSD data.
% * [[ODF.calcEBSD.html,Simulate]] EBSD data from ODFs.
% * [[EBSD.export.html,Export]] EBSD data.
%
% *New Functions*
%
% * [[ODF.fibreVolume.html,fibreVolume]] calculates the
% volume fraction within a fibre.
% * [[ODF.plotFourier.html,plotFourier]] plots the Fourier
% coefficients of an ODF.
% * [[setcolorrange.html,setcolorrange]] and the plotting
% option *colorrange* allow for consistent color coding for arbitrary
% plots.
% * A *colorbar* can be added to any plots.
% * [[mat2quat.html,mat2quat]] and [[quaternion.quat2mat.html,quat2mat]]
% convert rotation matrices to quaternions and vice versa.
%
% *Incompatible Changes With Previous Releases*
%
% * New, more flexibel syntax for the generation of
% [[S2Grid_index.html,S2Grids]]
% * Slightly changed syntax of [[unimodalODF.html,unimodalODF]] and
% [[fibreODF.html,fibreODF]].
% * Default plotting options are set to {}, i.e. 'antipodal' has to add
% manualy if desired
% * Crystal symmetry *triclinic* is not called *tricline* anymore.
%
%
%% MTEX 0.3 - 10/2007
%
% * new function [[ODF.Fourier.html,fourier]] to calculate the
% Fouriercoefficents of an arbitrary ODF
% * new option |ghost correction| in function
% [[PoleFigure.calcODF.html,calcODF]]
% * new option |zero range| in function [[PoleFigure.calcODF.html,calcODF]]
% * new function [[loadEBSD]] to import EBSD data
% * simplified syntax for the import of diffraction data
% * new import wizard for pole figure data
% * support of triclinic crystal [[symmetry_index.html,symmetry]] with
% arbitrary angles between the axes
% * default plotting options may now be specified in mtex_settings.m
% * new plot option _3d_ for a three dimensional spherical plot of pole
% figures
% * contour levels may be specified explicitely in all plot functions
% [[ODF.plotodf.html,plotodf]],[[ODF.plotpdf.html,plotpdf]] and
% [[ODF.plotipdf.html,plotipdf]]
% * new plot option _logarithmic_
% * many bugfixes
%
%
%% MTEX 0.2 - 07/2007
%
% * new functions [[ODF.textureindex.html,textureindex]], [[ODF.entropy.html,entropy]], [[ODF.volume.html,volume]]
% * creatly improved help
% * improved installation
% * new options for plotting routines for specific ODF sections
% * many bugfixes
%
%
%% MTEX 0.1 - 03/2007
%
% * initial release
%
