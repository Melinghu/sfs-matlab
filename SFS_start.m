function SFS_start()
%SFS_START Start the Sound Field Synthesis Toolbox
%
%   Usage: SFS_start;
%
%   SFS_START starts the Sound Field Synthesis Toolbox (SFS). 
%   This function must be run first in order to add the path's to Matlab.
%
%   see also: SFS_config, SFS_version

%*****************************************************************************
% Copyright (c) 2010-2012 Quality & Usability Lab                            *
%                         Deutsche Telekom Laboratories, TU Berlin           *
%                         Ernst-Reuter-Platz 7, 10587 Berlin, Germany        *
%                                                                            *
% This file is part of the Sound Field Synthesis-Toolbox (SFS).              *
%                                                                            *
% The SFS is free software:  you can redistribute it and/or modify it  under *
% the terms of the  GNU  General  Public  License  as published by the  Free *
% Software Foundation, either version 3 of the License,  or (at your option) *
% any later version.                                                         *
%                                                                            *
% The SFS is distributed in the hope that it will be useful, but WITHOUT ANY *
% WARRANTY;  without even the implied warranty of MERCHANTABILITY or FITNESS *
% FOR A PARTICULAR PURPOSE.                                                  *
% See the GNU General Public License for more details.                       *
%                                                                            *
% You should  have received a copy  of the GNU General Public License  along *
% with this program.  If not, see <http://www.gnu.org/licenses/>.            *
%                                                                            *
% The SFS is a toolbox for Matlab/Octave to  simulate and  investigate sound *
% field  synthesis  methods  like  wave  field  synthesis  or  higher  order *
% ambisonics.                                                                *
%                                                                            *
% http://dev.qu.tu-berlin.de/projects/sfs-toolbox       sfstoolbox@gmail.com *
%*****************************************************************************

% AUTHOR: Hagen Wierstorf
% $LastChangedDate$
% $LastChangedRevision$
% $LastChangedBy$


%% ===== Configuration ===================================================
printbanner = false;


%% ===== Adding Path's ===================================================

% Get the basepath as the directory this function resides in.
% The 'which' solution below is more portable than 'mfilename'
% becase old versions of Matlab does not have "mfilename('fullpath')"
basepath=which('SFS_start');
% Kill the function name from the path.
basepath=basepath(1:end-12);

% Add the base path and the needed sub-directories
if exist('addpath')
    addpath(basepath);
    addpath([basepath,'/scripts']);
    addpath([basepath,'/SFS_analysis']);
    addpath([basepath,'/SFS_binaural_synthesis']);
    addpath([basepath,'/SFS_general']);
    addpath([basepath,'/SFS_helper']);
    addpath([basepath,'/SFS_ir']);
    addpath([basepath,'/SFS_monochromatic']);
    addpath([basepath,'/SFS_plotting']);
    addpath([basepath,'/SFS_time_domain']);
    addpath([basepath,'/SFS_HRTF_extrapolation']);
    addpath([basepath,'/validation']);
    if isoctave
        addpath([basepath,'/SFS_octave']);
    end
else
    path(path,basepath);
    path(path,[basepath,'/scripts']);
    path(path,[basepath,'/SFS_analysis']);
    path(path,[basepath,'/SFS_binaural_synthesis']);
    path(path,[basepath,'/SFS_general']);
    path(path,[basepath,'/SFS_helper']);
    path(path,[basepath,'/SFS_ir']);
    path(path,[basepath,'/SFS_monochromatic']);
    path(path,[basepath,'/SFS_plotting']);
    path(path,[basepath,'/SFS_time_domain']);
    path([basepath,'/SFS_HRTF_extrapolation']);
    path(path,[basepath,'/validation']);
    if isoctave
        path(path,[basepath,'/SFS_octave']);
    end
end


%% ===== Banner ==========================================================
if(printbanner)
    printf('SFS %1.1f successfully initialized.\n',SFS_version);
end

