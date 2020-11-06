function tests = testPointmatch
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)

  % Ensure the ott package is in our path
  addpath('../../');

  % Target T-matrix
  testCase.TestData.Tmie = ott.tmatrix.Mie(0.1, 'relative_index', 1.2);

end

function testFromStarShape(testCase)

  shape = ott.shape.Sphere(0.1);
  index = 1.2;
  tmatrix = ott.tmatrix.Pointmatch.FromShape(shape, index);

  testCase.verifyEqual(tmatrix.relative_index, index, 'index');
  testCase.verifyEqual(tmatrix.xySymmetry, true, 'xy');
  testCase.verifyEqual(tmatrix.zRotSymmetry, 0, 'z');

  % Compare T-matrix data to target
  Tmie = testCase.TestData.Tmie;
  testCase.assertEqual(tmatrix.Nmax, Tmie.Nmax, 'Nmax');
  testCase.verifyEqual(tmatrix.data, Tmie.data, ...
      'AbsTol', 1.0e-6, 'Tmie');

end

function testDefaultProgressCallback(testCase)

  ott.tmatrix.Pointmatch.DefaultProgressCallback(...
    struct('stage', 'setup', 'iteration', 1, 'total', 1));

end

function testSymmetryOptions(testCase)

  radius = 0.1;
  shape = ott.shape.Sphere(radius);
  index = 1.2;
  Tmie = testCase.TestData.Tmie;
  
  Nmax = ott.utils.ka2nmax(2*pi*radius);

  ntheta = 2*(Nmax + 2);
  nphi = 3*(Nmax + 2)+1;

  theta = ((1:ntheta)-0.5)/ntheta * pi;
  phi = ((1:nphi)-1)/nphi * 2*pi;

  [theta, phi] = meshgrid(theta, phi);

  % Calculate shape radii and normals
  radii = shape.starRadii(theta, phi);
  rtp = [radii(:), theta(:), phi(:)].';

  % Calculate surface normals
  nxyz = shape.normalsRtp(rtp);
  nrtp = ott.utils.xyzv2rtpv(nxyz, ott.utils.rtp2xyz(rtp));
  
  tmatrix = ott.tmatrix.Pointmatch(...
      rtp, nrtp, index, 'Nmax', Nmax, ...
      'zRotSymmetry', 0, 'xySymmetry', false);
  testCase.verifyEqual(tmatrix.data, Tmie.data, ...
      'AbsTol', 1.0e-6, 'wy=0, z=0');
  
  tmatrix = ott.tmatrix.Pointmatch(...
      rtp, nrtp, index, 'Nmax', Nmax, ...
      'zRotSymmetry', 2, 'xySymmetry', false);
  testCase.verifyEqual(tmatrix.data, Tmie.data, ...
      'AbsTol', 1.0e-6, 'xy=2, z=0');
  
  tmatrix = ott.tmatrix.Pointmatch(...
      rtp, nrtp, index, 'Nmax', Nmax, ...
      'zRotSymmetry', 2, 'xySymmetry', true);
  testCase.verifyEqual(tmatrix.data, Tmie.data, ...
      'AbsTol', 1.0e-6, 'xy=2, z=1');

end

function testInternalMie(testCase)

  shape = ott.shape.Sphere(1.0);
  index = 1.2;
  
  [~, Tmie] = ott.tmatrix.Mie(shape.radius, ...
      'relative_index', index);

  [~, tmatrix] = ott.tmatrix.Pointmatch.FromShape(shape, index);
  
  testCase.verifyEqual(tmatrix.data, Tmie.data, ...
    'AbsTol', 1.0e-6, 'internal');
end

% TODO: Test other parts of code (see tests in v2)

