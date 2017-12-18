function v = cvxopt_version()
% Returns CVXOPT version as a MATLAB character vector
%
% See also CVXOPT_INIT CONELP

% Copyright 2017-2018 Martin S. Andersen and Lieven Vandenberghe


try
  v = char(py.cvxopt.info.version);
catch ME
   if (strcmp(ME.identifier,'MATLAB:undefinedVarOrClass'))
      msg = ['Could not find CVXOPT. Please make sure that ', ...
             'CVXOPT is installed in the current Python environment.'];
      causeException = MException('MATLAB:cvxopt:import',msg);
      ME = addCause(ME,causeException);
   end
   rethrow(ME)
end
end
