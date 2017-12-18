% MATLAB script for installing CVXOPT Toolbox
%
% See also CVXOPT_INIT CVXOPT_TEST CVXOPT_VERSION CONELP

% Copyright 2017-2018 Martin S. Andersen and Lieven Vandenberghe

if ispc
   warning('This toolbox has not been tested with MATLAB for Windows.');
end
if verLessThan('matlab', '8.4')
    error('CVXOPT Toolbox requires MATLAB 8.4 (R2014b) or later');
elseif verLessThan('matlab', '9.0')
    disp(['This version of MATLAB does not include functions for managing toolboxes. ', ...
          'Please install the toolbox manually.']);
else
    if ~exist('CVXOPT Toolbox.mltbx')
        matlab.addons.toolbox.packageToolbox('CVXOPT Toolbox.prj');
    end
    matlab.addons.toolbox.installToolbox('CVXOPT Toolbox.mltbx');
end
