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
        function addenvironmentToPath(testCase)
            testCase.OriginalPath=path;
            addpath(fullfile(pwd,'environment'));
        end
    end
    
    methods (Test)
        function testCP(testCase)
            %testCP tests that cartesian_product in BWTS works as intended
            %i.e. that it returns the combination of all elements within 2
            %or more arrays
            
            %testing the result of a specific case
            actSolution=cartesian_product([1:5],[1:2]);
            expSolution=[1,1;1,2;2,1;2,2;3,1;3,2;4,1;4,2;5,1;5,2];
            testCase.verifyEqual(actSolution,expSolution);
            
            %testing the dimension
            actDim=size(cartesian_product([1:5],[1:2],[1:3]));
            expDim=[5*2*3, 3];
            testCase.verifyEqual(actDim,expDim)
        end
        function testcontainedIn(testCase)
            %testcontainedIn testz the function containedIn in enviornment
            %which return 1 if the first input argument is a point
            %withinthe rectangle defined by the points in T.R=[xmin, ymin;
            %xmax, ymax] and 0 otherwise.
            T.R=[0 0; 1 1];
            
            %test return of 1
            actSolution=containedIn([0.5, 0.5],1,T);
            expSolution=1;
            testCase.verifyEqual(actSolution, expSolution);
            
            %test return of 0
            actSolution=containedIn([2.5, 0.5],1,T);
            expSolution=0;
            testCase.verifyEqual(actSolution, expSolution)
        end
    end
end

