% CVXOPT Toolbox initialization script
%
% Implements workaround to avoid conflict between MATLAB's MKL library and
% BLAS library used by CVXOPT on Linux
%
% See <a href="matlab:web('https://www.mathworks.com/matlabcentral/answers/265247-importing-custom-python-module-fails')">this thread</a> on MATLAB Answers for a similar issue.
%
% See also PY CONELP
%

% Copyright 2017-2018 Martin S. Andersen and Lieven Vandenberghe

if isunix && ~ismac
  [~, ~, cvxopt_py_is_loaded] = pyversion;
  if ~cvxopt_py_is_loaded
    py.sys.setdlopenflags(int32(10));
  else
    warning('cvxopt_init must be executed before Python is loaded to take effect.)');
  end
  clear('cvxopt_py_is_loaded')
end
