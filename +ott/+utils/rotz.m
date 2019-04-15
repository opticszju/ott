function R = rotz(angle_deg, varargin)
% Create a 3x3 rotation matrix for rotation about z axis
%
% R = rotz(angle_deg) calculate the rotation matrix for rotations from
% the +x towards +y axis.
%
% R = rotz([a1, a2, a3, ...]) returns a 3xN matrix of rotation matrices
% for each angle in the input.
%
% Optional named arguments:
%   usecell    bool     True to output as cell array instead of 3xN matrix.
%       Default: false.  The cell array has the same shape as angle_deg.
%
% Replacement/extension to Matlab rotz function provided in the
% Phased Array System Toolbox.
%
% This file is part of the optical tweezers toolbox.
% See LICENSE.md for information about using/distributing this file.

p = inputParser;
p.addParameter('usecell', false);
p.parse(varargin{:});

assert(isnumeric(angle_deg), 'angle_deg must be numeric matrix');

theta = angle_deg * pi/180;

if numel(theta) > 1
  if p.Results.usecell

    % Create cell array of rotation matrices
    R = cell(size(theta));
    for ii = 1:numel(theta)
      R{ii} = rotz(theta(ii));
    end
  else

    % Create 3xN matrix of rotation matrices
    R = zeros([3, 3*numel(theta)]);
    for ii = 1:numel(theta)
      R(:, (1:3) + 3*(ii-1)) = rotz(theta(ii));
    end
  end
else

  % Calculate rotation matrix
  R = [cos(theta), -sin(theta), 0;
       sin(theta), cos(theta), 0;
       0, 0, 1];
end
