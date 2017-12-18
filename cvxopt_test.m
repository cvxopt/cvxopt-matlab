% CVXOPT Toolbox test script

% Copyright 2017-2018 Martin S. Andersen and Lieven Vandenberghe

clear all

% Identify test environment
if ismac
  disp('      Platform: macOS')
elseif isunix
  cvxopt_init
  disp('      Platform: Linux/Unix')
elseif ispc
  disp('      Platform: Windows')
else
  disp('      Platform: unknown')
end
disp(['MATLAB version: ', version])
disp(['CVXOPT version: ', cvxopt_version])
pyversion

% Test case 1
c = [-4. -5.]';
G = [2 1; 1 2; -1 0; 0 -1];
h = [3. 3. 0. 0.]';
dims = struct('l', 4);
sol = conelp(c,G,h,dims,[],[],struct('show_progress',0));
if strcmp(sol.status, 'optimal')
  disp('Test 1: OK')
end

% Test case 2
c = [-6 -4 -5]';
G = [ 16 7  24  -8   8  -1  0 -1  0  0  7  -5   1  -5   1  -7   1  -7  -4;
     -14 2   7 -13 -18   3  0  0 -1  0  3  13  -6  13  12 -10  -6 -10 -28;
       5 0 -15  12  -6  17  0  0  0 -1  9   6  -6   6  -7  -7  -6  -7 -11]';
h = [ -3 5  12  -2 -14 -13 10  0  0  0 68 -30 -19 -30  99  23 -19  23  10]';
dims = struct('l', 2, 'q', [4, 4], 's', [3]);
sol = conelp(c,G,h,dims,[],[],struct('show_progress',0));
if strcmp(sol.status, 'optimal')
  disp('Test 2: OK')
end

% Test case 3: adds equality constraint to previous test case
A = ones(1,3);
b = 1.0;
sol = conelp(c,G,h,dims,A,b,struct('show_progress',0));
if strcmp(sol.status, 'optimal')
  disp('Test 3: OK')
end

clear all
