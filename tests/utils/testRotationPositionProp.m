function tests = testRotationPositionProp
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)
  addpath('../../');
end

function testNargoutCheck(testCase)

  beam = ott.utils.RotationPositionProp();
  
  testCase.verifyWarning(@() beam.rotateX(5), ...
    'ott:utils:nargoutCheck:no_outputs');
end

function testLocalTranslation(testCase)

  obj = ott.utils.RotationPositionProp();
  obj = obj.rotateY(pi/2);
  obj = obj.translateXyz([0;0;1], 'origin', 'local');
  
  testCase.verifyEqual(obj.position, [1;0;0], 'AbsTol', 1.0e-15);
  testCase.verifyEqual(obj.local2global([0;0;0]), obj.position, 'loc2glob');
  testCase.verifyEqual(obj.global2local(obj.position), [0;0;0], 'glob2loc');

end
