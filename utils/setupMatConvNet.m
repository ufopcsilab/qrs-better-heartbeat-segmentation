function setupMatConvNet(matConvNetPath, varargin)
  % SETUP()  Initialize the practical
  %   SETUP() initializes the practical. SETUP('useGpu', true) does
  %   the same, but compiles the GPU supprot as well.

  matConvNetPath = addSlash(matConvNetPath);
  % We neeed to delete the mex files when we run the code in Russell server
  if strcmp(getMyHostName(), 'russell')
      system(['rm ' matConvNetPath 'matconvnet/matlab/mex/*.*']);
  end

  if matConvNetPath(end) ~= '/'
      matConvNetPath = [matConvNetPath '/'];
  end

  addpath([ matConvNetPath ]);
  addpath([ matConvNetPath 'matconvnet']);
  addpath([ matConvNetPath 'matconvnet/examples']);
  addpath([ matConvNetPath 'matconvnet/matlab/']);
  addpath([ matConvNetPath 'matconvnet/matlab/simplenn']);
  addpath([ matConvNetPath 'vlfeat/toolbox/']);

  vl_setup(); % From VL-Feat
  vl_setupnn(); % From MatConvNet

  opts.useGpu = true ;
  opts.verbose = false ;
  opts = vl_argparse(opts, varargin) ;

  try
    vl_nnconv(single(1),single(1),[]) ;
  catch
    warning('VL_NNCONV() does not seem to be compiled. Trying to compile it now.') ;
    vl_compilenn('enableGpu', opts.useGpu, 'verbose', opts.verbose, ...
                 'enableImreadJpeg', false) ;
  end

  if opts.useGpu
    try
      vl_nnconv(gpuArray(single(1)),gpuArray(single(1)),[]) ;
    catch
      warning('GPU support does not seem to be compiled in MatConvNet. Trying to compile it now.') ;
      vl_compilenn('enableGpu', opts.useGpu, 'verbose', opts.verbose, ...
                   'enableImreadJpeg', false) ;
    end
  end

  % The EC2 has incorrect screen size which leads to a tiny font in figures
  [~, hostname] = system('hostname') ;
  if strcmp(hostname(1:3), 'ip-')
    set(0, 'DefaultAxesFontSize', 30) ;
  end

end
