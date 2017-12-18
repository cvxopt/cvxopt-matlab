%% Example from cvxopt/examples/doc/chap8/conelp.py
% See also: http://cvxopt.org/userguide/coneprog.html#linear-cone-programs
clc, close, clear

c = [-6 -4 -5]';
G = [ 16 7  24  -8   8  -1  0 -1  0  0  7  -5   1  -5   1  -7   1  -7  -4;
     -14 2   7 -13 -18   3  0  0 -1  0  3  13  -6  13  12 -10  -6 -10 -28;
       5 0 -15  12  -6  17  0  0  0 -1  9   6  -6   6  -7  -7  -6  -7 -11]';
h = [ -3 5  12  -2 -14 -13 10  0  0  0 68 -30 -19 -30  99  23 -19  23  10]';
dims = struct('l', 2, 'q', [4, 4], 's', [3]);

opts = struct('kktsolver','ldl','maxiters',50,'refinement',2, ...
              'reltol',1e-10,'abstol',1e-10,'feastol',1e-10);

sol = conelp(c,G,h,dims,[],[],opts);

disp(['Status: ', sol.status])
disp('x = ')
disp(sol.x)
disp('z = ')
disp(sol.z)
