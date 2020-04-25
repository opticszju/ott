function tests = testPlane
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)
  addpath('../../');
end

function testConstruction(testCase)

  normal = [0;0;1];
  offset = 0.0;

  plane = ott.shapes.Plane(normal, offset);
  
  % Check properties
  testCase.verifyEqual(plane.normal, normal);
  testCase.verifyEqual(plane.offset, offset);
  testCase.verifyEqual(plane.maxRadius, Inf);
  testCase.verifyEqual(plane.volume, Inf);
  
  % Check point above and bellow plane
  xyz = [0, 0; 0, 0; 1, -1];
  b = plane.insideXyz(xyz);
  testCase.verifyEqual(b, [true, false]);
end

function testSurf(testCase)

  normal = rand(3, 1);
  offset = 0.0;

  plane = ott.shapes.Plane(normal, offset);
  
  h = figure();
  plane.surf('scale', 2.0);
  close(h);

end
  