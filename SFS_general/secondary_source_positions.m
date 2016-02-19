function x0 = secondary_source_positions(conf)
%SECONDARY_SOURCE_POSITIONS generates the positions, directions, and weights of
%   the secondary sources
%
%   Usage: x0 = secondary_source_positions(conf)
%
%   Input options:
%       conf   - configuration struct (see SFS_config)
%
%   Output options:
%       x0     - secondary source positions, directions and weights
%                [x0 y0 z0 nx0 ny0 nz0 w] / m
%
%   SECONDARY_SOURCES_POSITIONS(conf) generates the positions and directions
%   x0 of secondary sources for a given geometry
%   (conf.secondary_sources.geometry) and array size
%   (conf.secondary_sources.size). Alternatively, if
%   conf.secondary_sources.geomrtry is set to 'custom' the field
%   conf.secondary_sources.x0 is used to supply x0. It can be a [n 7] matrix
%   consiting of n sources or it can be a SOFA file/struct from the source
%   positions are extracted.
%
%   The direction of the sources is given as their unit vectors pointing in the
%   given direction. For a linear array the secondary sources are pointing
%   towards the negative y-direction. If you create a linear array with default
%   position conf.secondary_sources.center = [0 0 0], your listening area is in
%   the area y<0, which means the y value of conf.xref should also be <0!
%
% See also: secondary_source_selection, secondary_source_tapering

%*****************************************************************************
% Copyright (c) 2010-2016 Quality & Usability Lab, together with             *
%                         Assessment of IP-based Applications                *
%                         Telekom Innovation Laboratories, TU Berlin         *
%                         Ernst-Reuter-Platz 7, 10587 Berlin, Germany        *
%                                                                            *
% Copyright (c) 2013-2016 Institut fuer Nachrichtentechnik                   *
%                         Universitaet Rostock                               *
%                         Richard-Wagner-Strasse 31, 18119 Rostock           *
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
% http://github.com/sfstoolbox/sfs                      sfstoolbox@gmail.com *
%*****************************************************************************

% NOTE: If you wanted to add a new type of loudspeaker array, do it in a way,
% that the loudspeakers are ordered in a way, that one can go around for closed
% arrays. Otherwise the tapering window function will not work properly.


%% ===== Checking of input  parameters ===================================
nargmin = 1;
nargmax = 1;
narginchk(nargmin,nargmax);
isargstruct(conf);


%% ===== Configuration ===================================================
% Given secondary sources are used in the 'custom' section
%conf.secondary_sources.x0;
% Array type
geometry = conf.secondary_sources.geometry;
if ~strcmp('custom',geometry)
    % Center of the array
    X0 = conf.secondary_sources.center;
    % Number of secondary sources
    nls = conf.secondary_sources.number;
    x0 = zeros(nls,7);
    % Diameter/length of array
    L = conf.secondary_sources.size;
end


%% ===== Main ============================================================
if strcmp('line',geometry) || strcmp('linear',geometry)
    % === Linear array ===
    %
    %                     y-axis
    %                       ^
    %                       |
    %                       |  secondary sources
    %                       |        |
    %                       |        v
    %  ------x--x--x--x--x--x--x--x--x--x--x-------> x-axis
    %        |  |  |  |  |  |  |  |  |  |  | <- secondary source direction
    %                       |
    %                       |
    %
    %% Positions of the secondary sources
    x0(:,1) = X0(1) + linspace(-L/2,L/2,nls)';
    x0(:,2) = X0(2) * ones(nls,1);
    x0(:,3) = X0(3) * ones(nls,1);
    % Direction of the secondary sources pointing to the -y direction
    x0(:,4:6) = direction_vector(x0(:,1:3),x0(:,1:3)+repmat([0 -1 0],nls,1));
    % Weight each secondary source by the inter-loudspeaker distance
    x0(:,7) = L./(nls-1);
elseif strcmp('circle',geometry) || strcmp('circular',geometry)
    % === Circular array ===
    %
    %                  y-axis
    %                    ^
    %                    |
    %                    x
    %               x    |     x
    %               \    |     /
    %          x_        |         _x
    %            -       |        -
    %       x-_          |          _-x
    %                    |
    %  ----x---------------------------x------> x-axis
    %         _          |          _
    %       x-           |           -x
    %          _-        |        -_
    %         x          |          x
    %              /     |     \
    %              x     |     x
    %                    x
    %                    |
    %
    % 'circle' is special case of 'rounded-box' with fully rounded corners
    t = (0:nls-1)/nls;
    [x0(:,1:3), x0(:,4:6), x0(:,7)] = rounded_box(t,1.0);  % 1.0 for circle
    % Scale unit circle and shift center to X0
    x0(:,1:3) = bsxfun(@plus, x0(:,1:3).*L/2, X0);
    % Scale weights
    x0(:,7) = x0(:,7).*L/2;
elseif strcmp('box',geometry)
    % === Boxed loudspeaker array ===
    %
    %                  y-axis
    %                    ^
    %                    |
    %        x   x   x   x   x   x   x
    %        |   |   |   |   |   |   |
    %     x--            |            --x
    %                    |
    %     x--            |            --x
    %                    |
    %     x--            |            --x
    %                    |
    %  ---x-----------------------------x-----> x-axis
    %                    |
    %     x--            |            --x
    %                    |
    %     x--            |            --x
    %                    |
    %     x--            |            --x
    %        |   |   |   |   |   |   |
    %        x   x   x   x   x   x   x
    %                    |
    %
    % 'box' is special case of 'rounded-box' where there is no rounding
    % and the sources in the corners are skipped
    %
    % Number of secondary sources per linear array
    % ensures that nls/4 is always an integer.
    if rem(nls,4)~=0
        error(['%s: conf.secondary_sources.number has to be a multiple of' ...
            ' 4.'],upper(mfilename));
    else
        nbox = nls/4;
    end
    % Distance between secondary sources
    dx0 = L/(nbox-1);
    % Length of one edge of the rectangular bounding box
    Lbound = L + 2*dx0;
    % Index t for the positions on the boundary
    t = linspace(-L/2,L/2,nbox)./Lbound;  % this skips the corners
    t = [t, t+1, t+2, t+3]*0.25;  % repeat and shift to get all 4 edges
    % 'box' is special case of 'rounded-box' where there is no rounding
    [x0(:,1:3), x0(:,4:6), x0(:,7)] = rounded_box(t,0.0);  % 0.0 for square
    % Scale "unit" box and shift center to X0
    x0(:,1:3) = bsxfun(@plus, x0(:,1:3).*Lbound/2, X0);
    % Scale integration weights
    x0(:,7) = x0(:,7).*Lbound/2;
    % Correct weights of loudspeakers near corners
    corners = [1,nbox,nbox+1,2*nbox,2*nbox+1,3*nbox,3*nbox+1,4*nbox];
    x0(corners,7) = (1 + sqrt(2)) *dx0/2;  % instead of 3/2 * dx0
elseif strcmp('rounded-box', geometry)
    % Ratio for rounding the edges
    ratio = 2*conf.secondary_sources.corner_radius./L;
    t = (0:nls-1)/nls;
    [x0(:,1:3), x0(:,4:6), x0(:,7)] = rounded_box(t, ratio);
    % Scale "unit" rounded-box and shift center to X0
    x0(:,1:3) = bsxfun(@plus, x0(:,1:3).*L/2, X0);
    % Scale integration weights
    x0(:,7) = x0(:,7).*L/2;
elseif strcmp('edge', geometry)
    alpha = conf.secondary_sources.alpha;
    if numel(alpha) == 1;
      alpha = [0, alpha];
    end
    
    nfloor = floor(nls/2);
    nceil = ceil(nls/2);
    
    t = (1:nfloor)*L/nfloor;
    
    x0(1:nfloor,1) = t.*cos(alpha(1));
    x0(1:nfloor,2) = t.*sin(alpha(1));
    x0(1:nfloor,4) = sin(alpha(1));
    x0(1:nfloor,5) = -cos(alpha(1));
   
    if nfloor ~= nceil
      x0(nfloor+1,4) = -cos(0.5*alpha(1)+0.5*alpha(2));
      x0(nfloor+1,5) = -sin(0.5*alpha(1)+0.5*alpha(2));
    end
    
    x0(nceil+1:end,1) = t.*cos(alpha(2));
    x0(nceil+1:end,2) = t.*sin(alpha(2));
    x0(nceil+1:end,4) = -sin(alpha(2));
    x0(nceil+1:end,5) = cos(alpha(2));

    % Scale integration weights
    x0(:,7) = L./nfloor;
elseif strcmp('spherical',geometry) || strcmp('sphere',geometry)
    % Get spherical grid + weights
    [points,weights] = get_spherical_grid(nls,conf);
    % Secondary source positions
    x0(:,1:3) = L/2 * points + repmat(X0,nls,1);
    % Secondary source directions
    x0(:,4:6) = direction_vector(x0(:,1:3),repmat(X0,nls,1));
    % Secondary source weights + distance scaling
    x0(:,7) = weights .* L^2/4;
    % Add integration weights (because we integrate over a sphere) to the grid
    % weights
    [~,theta] = cart2sph(x0(:,1),x0(:,2),x0(:,3)); % get elevation
    x0(:,7) = x0(:,7) .* cos(theta);
elseif strcmp('custom',geometry)
    % Custom geometry definedy by conf.secondary_sources.x0.
    % This could be in the form of a n x 7 matrix, where n is the number of
    % secondary sources or as a SOFA file/struct.
    if ischar(conf.secondary_sources.x0) || isstruct(conf.secondary_sources.x0)
        x0 = sofa_get_secondary_sources(conf.secondary_sources.x0);
    else
        x0 = conf.secondary_sources.x0;
    end
    isargsecondarysource(x0);
else
    error('%s: %s is not a valid array geometry.',upper(mfilename),geometry);
end
