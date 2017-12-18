function sol = conelp(c,G,h,dims,A,b,options)
% CONELP  Solves cone linear program using CVXOPT
%
%   sol = CONELP(c,G,h,dims,A,b,options) solves a pair of primal
%   and dual cone programs
%
%       minimize    c'*x
%       subject to  G*x + s = h
%                   A*x = b
%                   s >= 0
%
%       maximize    -h'*z - b'*y
%       subject to  G'*z + A'*y + c = 0
%                   z >= 0.
%
%   The inequalities are with respect to a cone C defined as the
%   Cartesian product of N + M + 1 cones:
%
%        C = C_0 x C_1 x .... x C_N x C_{N+1} x ... x C_{N+M}.
%
%   The first cone C_0 is the nonnegative orthant of dimension ml.
%   The next N cones are second order cones of dimension mq[0], ...,
%   mq[N-1].  The second order cone of dimension m is defined as
%
%       { (u0, u1) in R x R^{m-1} | u0 >= ||u1||_2 }.
%
%   The next M cones are positive semidefinite cones of order ms[0], ...,
%   ms[M-1] >= 0.
%
%   The input options is an optional struct that can be used to
%   override the default behaviour of conelp. Possible fields are
%   'kktsolver', 'primalstart', 'dualstart', 'abstol', 'reltol',
%   'feastol', 'maxiters', 'refinement', and 'show_progress'.
%
%   For more information, see the CVXOPT User's Guide:
%      http://cvxopt.org/userguide/coneprog.html
%
% Example: solve linear program
%
%   minimize    -4*x1 -5*x2
%   subject to   2*x1 +  x2 <= 3
%                  x1 +2*x2 <= 3
%                  x1       >= 0
%                  x2       >0 0
%
%   c = [-4. -5.]';
%   G = [2 1; 1 2; -1 0; 0 -1];
%   h = [3. 3. 0. 0.]';
%   sol = conelp(c,G,h,dims);
%
% See also CVXOPT_INIT CVXOPT_VERSION

% Copyright 2017-2018 Martin S. Andersen and Lieven Vandenberghe


% Parse options
py_opt = py.dict();
kktsolver = py.None;
primalstart = py.None;
dualstart = py.None;
if exist('options','var')
    if isfield(options,'kktsolver')
        kktsolver = options.kktsolver;
    end
    if isfield(options,'primalstart')
        x = py.cvxopt.matrix(options.primalstart.x(:)');
        s = py.cvxopt.matrix(options.primalstart.s(:)');
        primalstart = py.dict(pyargs('x',x,'s',s));
    end
    if isfield(options,'dualstart')
        z = py.cvxopt.matrix(options.primalstart.z(:)');
        y = py.cvxopt.matrix(options.primalstart.y(:)');
        dualstart = py.dict(pyargs('z',z,'y',y));
    end
    if isfield(options,'maxiters')
        py_opt{'maxiters'} = int32(options.maxiters);
    end
    if isfield(options,'reltol')
        py_opt{'feastol'} = options.feastol;
    end
    if isfield(options,'reltol')
        py_opt{'reltol'} = options.reltol;
    end
    if isfield(options,'abstol')
        py_opt{'abstol'} = options.abstol;
    end
    if isfield(options,'refinement')
        py_opt{'refinement'} = int32(options.refinement);
    end
    if isfield(options,'debug')
        py_opt{'debug'} = logical(options.debug);
    end
    if isfield(options,'show_progress')
        py_opt{'show_progress'} = logical(options.show_progress);
    end
end

% Convert dims struct to Python dict
if exist('dims') ~= 1 || isempty(dims)
    dims = struct('l',size(G,1));
end
if isfield(dims,'l')
    dims.l = int32(dims.l);
else
    dims.l = int32(0);
end
if isfield(dims,'q')
    if length(dims.q) == 1
        % work around MATLAB-Python translation when dims.q is a scalar
        dims.q = py.list([int32(dims.q),int32(0)]);
        dims.q.pop(int32(1));
    else
        dims.q = py.list(int32(dims.q));
    end
else
    dims.q = py.list();
end
if isfield(dims,'s')
    if length(dims.s) == 1
        % work around MATLAB-Python translation when dims.s is a scalar
        dims.s = py.list([int32(dims.s),int32(0)]);
        dims.s.pop(int32(1));
    else
        dims.s = py.list(int32(dims.s));
    end
else
    dims.s = py.list();
end
dims = py.dict(dims);

% Convert problem data to Python objects
cp = py.cvxopt.matrix(full(c(:))');
hp = py.cvxopt.matrix(full(h(:))');
if ~issparse(G)
    % convert to CVXOPT matrix
    Gp = py.cvxopt.matrix(G(:)',py.tuple(int32(size(G))));
else
    % convert to CVXOPT spmatrix
    [I,J,V] = find(G);
    Gp = py.cvxopt.spmatrix(V',int32(I'-1),int32(J'-1),py.tuple(int32(size(G))));
end
Ap = py.None;
bp = py.None;
if nargin >= 6 && ~isempty(A) && ~isempty(b)
    if ~issparse(A)
        % convert to CVXOPT matrix
        Ap = py.cvxopt.matrix(A(:)',py.tuple(int32(size(A))));
    else
        % convert to CVXOPT spmatrix
        [I,J,V] = find(A);
        Ap = py.cvxopt.spmatrix(V',int32(I'-1),int32(J'-1),py.tuple(int32(size(A))));
    end
    bp = py.cvxopt.matrix(b(:)');
end

% Solve problem with CVXOPT
sol_cvxopt = py.cvxopt.solvers.conelp(cp,Gp,hp,dims,Ap,bp,primalstart,dualstart,kktsolver,pyargs('options',py_opt));

% Convert Python solution dictionary to MATLAB struct
keys = py.list(sol_cvxopt.keys());
sol = struct();
for k = 1:length(keys)
    key = keys.pop();
    sol.(strrep(char(key),' ','_')) = sol_cvxopt.get(key);
end

% Convert status string to MATLAB character array
sol.status = char(sol.status);

% Convert number of iterations to MATLAB number
sol.iterations = sol.iterations.double;

% Convert Python 'None' to NaN in MATLAB
if sol.residual_as_primal_infeasibility_certificate == py.None
    sol.residual_as_primal_infeasibility_certificate = nan;
end
if sol.residual_as_dual_infeasibility_certificate == py.None
    sol.residual_as_dual_infeasibility_certificate = nan;
end

% Convert x,y,z,s to MATLAB arrays
sol.x = cellfun(@double,cell(py.list(sol.x)))';
sol.y = cellfun(@double,cell(py.list(sol.y)))';
sol.z = cellfun(@double,cell(py.list(sol.z)))';
sol.s = cellfun(@double,cell(py.list(sol.s)))';

end
