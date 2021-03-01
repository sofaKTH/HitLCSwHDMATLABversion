classdef TestClass < matlab.unittest.TestCase
    %TESTCLASS Contains my test-functions which ensures that the functions
    %works as intended.
    
    properties
        OriginalPath
    end
    
    methods(TestMethodSetup)
        %add folders to path
        function addBWTSToPath(testCase)
            testCase.OriginalPath=path;
            addpath(fullfile(pwd,'BWTS'));
        end
    end
    
    methods (Test)
        function testCP(testCase)
            %testCP tests that cartesian_product in BWTS works as intended
            %i.e. that it returns the combination of all elements within 2
            %arrays
            actSolution=cartesian_product([1:5],[1:2]);
            expSolution=[1,1;1,2;2,1;2,2;3,1;3,2;4,1;4,2;5,1;5,2];
            testCase.verifyEqual(actSolution,expSolution);
        end
    end
end

