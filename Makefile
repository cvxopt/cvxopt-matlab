MATLAB_ROOT ?= $(shell dirname `which matlab`)/..

.PHONY: all install uninstall test clean

all: CVXOPT\ Toolbox.mltbx

CVXOPT\ Toolbox.prj: .CVXOPT\ Toolbox.prj
	sed 's|\$${PWD}|'"${PWD}"'|g' .CVXOPT\ Toolbox.prj | sed 's|\$${MATLAB_ROOT}|'"${MATLAB_ROOT}"'|g' > CVXOPT\ Toolbox.prj

CVXOPT\ Toolbox.mltbx: CVXOPT\ Toolbox.prj conelp.m cvxopt_version.m cvxopt_init.m cvxopt_test.m doc/GettingStarted.mlx
	$(MATLAB_ROOT)/bin/matlab -nodesktop -nosplash -r "matlab.addons.toolbox.packageToolbox('$<'); exit;"

install: CVXOPT\ Toolbox.prj
	$(MATLAB_ROOT)/bin/matlab -nodesktop -nosplash -r "cvxopt_install; exit;"

uninstall:
	$(MATLAB_ROOT)/bin/matlab -nodesktop -nosplash -r "tbxs = matlab.addons.toolbox.installedToolboxes; for i = 1:length(tbxs), if strcmp(tbxs(i).Name,'CVXOPT Toolbox'), matlab.addons.toolbox.uninstallToolbox(tbxs(i)); end, end, exit;"

test:
	python -c 'import cvxopt'
	cd examples && $(MATLAB_ROOT)/bin/matlab -nodesktop -nojvm -r "cvxopt_test; exit;"

clean:
	-$(RM) CVXOPT\ Toolbox.prj
	-$(RM) CVXOPT\ Toolbox.mltbx

# MATLAB documentation:
# http://www.mathworks.com/help/matlab/ref/matlab.addons.toolbox.packagetoolbox.html
# http://www.mathworks.com/help/matlab/ref/matlab.addons.toolbox.installtoolbox.html
# http://www.mathworks.com/help/matlab/ref/matlab.addons.toolbox.uninstalltoolbox.html
