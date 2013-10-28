%
% This file is part of TopoCell.
% 
% TopoCell is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by 
% the Free Software Foundation, either version 3 of the License, or 
% (at your option) any later version.
% 
% TopoCell is distributed in the hope that it will be useful, 
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License 
% along with TopoCell. If not, see <http://www.gnu.org/licenses/>.
%

function params = dist_membrane_params(args)
%DIST_MEMBRANE_PARAMS Parse extra parameters for dist_membrane function
%     args - extra arguments to be parsed
%   params - structure containing parsed arguments

% Only useVol parameter is necessary, use common function to parse it.
params = filter_particle.common.dist_params_usevol(args);

end % function
