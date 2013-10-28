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

function params = dist_params_usevol(args)
%DIST_PARAMS_USEVOL Parse useVol parameter for distance filters
%   args - string containing useVol (0 or 1)
% params - parsed 0 or 1

result = textscan(args, '%d');

params = struct('useVol', result{1});

% Check if useVol is 0 or 1
if ((params.useVol ~= 0) && (params.useVol ~= 1))
    error(['Error parsing useVol parameter, must be 0 or 1, "' params.useVol '" given.']);
end;

end % function