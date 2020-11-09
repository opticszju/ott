classdef Cube < ott.shape.Shape ...
    & ott.shape.mixin.CoordsCart ...
    & ott.shape.mixin.Patch ...
    & ott.shape.mixin.IntersectMinAll
% Simple geometric cube.
% Inherits from :class:`Shape`.
%
% Properties
%   - width        -- Width of the cube
%
% Additional properties inherited from base.

% Copyright 2018-2020 Isaac Lenton
% This file is part of the optical tweezers toolbox.
% See LICENSE.md for information about using/distributing this file.

  properties
    width         % Width of cube
  end

  properties (Dependent)
    maxRadius          % Maximum particle radius
    volume             % Particle volume
    boundingBox        % Cartesian coordinate bounding box (no rot/pos)
    starShaped         % True if the particle is star-shaped
    xySymmetry         % True if the particle is xy-plane mirror symmetric
    zRotSymmetry       % z-axis rotational symmetry of particle
    verts              % Vertices describing cube
    faces              % Faces describing cube
  end

  methods
    function shape = Cube(varargin)
      % Construct a cube.
      %
      % Usage
      %   shape = Cube(width, ...)
      %   Parameters can be passed as named arguments.
      %
      % Additional parameters are passed to base.

      p = inputParser;
      p.addOptional('width', 1.0);
      p.KeepUnmatched = true;
      p.parse(varargin{:});
      unmatched = ott.utils.unmatchedArgs(p);

      shape = shape@ott.shape.Shape(unmatched{:});
      shape.width = p.Results.width;
    end
  end

  methods (Hidden)
    function b = insideXyzInternal(shape, xyz)
      assert(size(xyz, 1) == 3, 'xyz must be 3xN matrix');
      b = all(abs(xyz) <= shape.width./2, 1);
    end

    function n = normalsXyzInternal(shape, xyz)

      assert(size(xyz, 1) == 3, 'xyz must be 3xN matrix');

      % Determine which dimensions are inside
      tol = 1.0e-3.*shape.width;
      inside = abs(xyz) < (shape.width./2 + tol);

      % Calculate normals
      n = sign(xyz) .* double(~inside);

      % Normalise vectors (creates nans for interior points)
      n = n ./ vecnorm(n);

    end

    function [P, N, dist] = intersectAllInternal(shape, x0, x1)
      % Calculate intersection with faces
      %
      % Always returns 3x2xN array of intersections.  If the ray starts
      % from inside the geometry, the second column is NaN.

      % Reshape points (3x1xM)
      Q1 = reshape(x0, 3, 1, []);
      D = reshape(x1 - x0, 3, 1, []);

      % Calculate normals (3x6)
      N = [[0;0;1], [0;0;-1], [1;0;0],[-1;0;0], [0;1;0],[0;-1;0]];
      P0 = shape.width.*N./2;

      % Ensure size of D and N match (3x6xM)
      N = repmat(N, 1, 1, size(D, 3));
      D = repmat(D, 1, size(N, 2), 1);
      Q1 = repmat(Q1, 1, size(N, 2), 1);

      % Calculate distance to intersection
      dist = dot(P0 - Q1, N)./dot(D, N);
      
      % Calculate intersection points (3x6xM)
      P = Q1 + dist.*D;

      % Remove points outside faces
      w = shape.width./2 + eps(1);
      I = [abs(P(1, 1:2, :)) > w | abs(P(2, 1:2, :)) > w, ...
           abs(P(2, 3:4, :)) > w | abs(P(3, 3:4, :)) > w, ...
           abs(P(1, 5:6, :)) > w | abs(P(3, 5:6, :)) > w];
      
      % Remove intersections in the opposite direction
      found = dist >= 0 & ~I;
      dist(~found) = nan;
      P(:, ~found) = nan;
      N(:, ~found) = nan;
      
      % Sort intersection and keep max 2
      [~, idx1] = min(dist, [], 2);
      dist2 = dist;
      idx1 = sub2ind([size(dist, 2), size(dist, 3)], idx1(:).', 1:numel(idx1));
      dist2(:, idx1) = nan;
      [~, idx2] = min(dist2, [], 2);
      idx2 = sub2ind([size(dist, 2), size(dist, 3)], idx2(:).', 1:numel(idx2));
      idx = [idx1; idx2];
      
      dist = reshape(dist(:, idx), 1, 2, []);
      P = reshape(P(:, idx), 3, 2, []);
      N = reshape(N(:, idx), 3, 2, []);
    end

    function varargout = intersectInternal(shape, varargin)
      % Disambiguate
      [varargout{1:nargout}] = intersectInternal@ ...
          ott.shape.mixin.IntersectMinAll(shape, varargin{:});
    end

    function shape = scaleInternal(shape, sc)
      shape.width = shape.width * sc;
    end
  end

  methods % Getters/setters
    function shape = set.width(shape, val)
      assert(isnumeric(val) && isscalar(val) && val >= 0, ...
          'width must be positive numeric scalar');
      shape.width = val;
    end

    function r = get.maxRadius(shape)
      r = sqrt(3*(shape.width/2).^2);
    end
    function shape = set.maxRadius(shape, val)
      assert(isnumeric(val) && isscalar(val) && val >= 0, ...
          'maxRadius must be positive numeric scalar');
      shape.width = sqrt(r.^2./3).*2;
    end

    function v = get.volume(shape)
      v = shape.width.^3;
    end
    function shape = set.volume(shape, val)
      assert(isnumeric(val) && isscalar(val) && val >= 0, ...
          'volume must be positive numeric scalar');
      shape.width = val.^(1/3);
    end

    function bb = get.boundingBox(shape)
      bb = [-1, 1; -1, 1; -1, 1].*shape.width./2;
    end

    function b = get.starShaped(~)
      b = true;
    end
    function b = get.xySymmetry(~)
      b = true;
    end
    function q = get.zRotSymmetry(~)
      q = 4;
    end

    function verts = get.verts(shape)
      X = [1, 1, -1, -1, 1, 1, -1, -1];
      Y = [-1, 1, 1, -1, -1, 1, 1, -1];
      Z = [-1, -1, -1, -1, 1, 1, 1, 1];

      verts = [X(:), Y(:), Z(:)].' .* shape.width./2;
    end

    function faces = get.faces(~)
      faces = [1, 2, 6, 5; 2, 3, 7, 6; 3, 4, 8, 7; 4, 1, 5, 8; ...
          2, 1, 4, 3; 5, 6, 7, 8].';
    end
  end
end
