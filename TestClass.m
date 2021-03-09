classdef TestClass < matlab.unittest.TestCase
    %TESTCLASS Contains my test-functions which ensures that some testable 
    %functions work as intended. All folders are added to the path and then
    %a variety of testcases are performed.
    
    properties
        OriginalPath
    end
    
    methods(TestMethodSetup)
        %add folders to path
        function addFOLDERSToPath(testCase)
            testCase.OriginalPath=path;
            addpath(fullfile(pwd,'BWTS'));
            addpath(fullfile(pwd,'environment'));
            addpath(fullfile(pwd,'TS'));
            addpath(fullfile(pwd,'hardsoftupd'));
            addpath(fullfile(pwd,'HRI and learning'));
            addpath(fullfile(pwd,'path'));
            addpath(fullfile(pwd,'MIC'));
            addpath(fullfile(pwd,'softonly'));
            addpath(fullfile(pwd,'TAhd'));
            addpath(fullfile(pwd,'visualization'));
            %used only for documentation of figures/data, probably not
            %needed by the test functions, added to avoid confusion.
            addpath(fullfile(pwd,'figures'));
            addpath(fullfile(pwd,'logs'));
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
        function testWTSsimple(testCase)
            %testWTSsimple tests the function WTS_simpleconstruction in TS
            %which returns an object with 6 properties describing a WTS.
            env=env1(); %some example settings
            a=2; b=2;u=1; d=2; l=3; r=4;
            
            %test return of 1
            T=WTS_simpleconstruction(env.n, a,b, env.Pi, env.Lap, u,d,l,r,env.init);
            
            %test cases for corners of states
            actSolution=T.R(1,:,1);expSolution=[0,0];
            testCase.verifyEqual(actSolution, expSolution);
            actSolution=T.R(2,:,1);expSolution=[a,b];
            testCase.verifyEqual(actSolution, expSolution);
            actSolution=T.R(2,:,env.n);expSolution=[5*a,3*b];
            testCase.verifyEqual(actSolution, expSolution);
            
            %test values that should be directly from input
            actSolution=T.Pi;expSolution=env.Pi;
            testCase.verifyEqual(actSolution, expSolution);
            actSolution=T.current;expSolution=env.init;
            testCase.verifyEqual(actSolution, expSolution);
            
            %test some edges
            actSolution=full(T.adj(2,1));expSolution=l;
            testCase.verifyEqual(actSolution, expSolution);
            actSolution=full(T.adj(6,1));expSolution=d;
            testCase.verifyEqual(actSolution, expSolution);
            actSolution=full(T.adj(14,15));expSolution=r;
            testCase.verifyEqual(actSolution, expSolution);
            actSolution=full(T.adj(2,7));expSolution=u;
            testCase.verifyEqual(actSolution, expSolution);
             actSolution=full(T.adj(2,6));expSolution=0;
             testCase.verifyEqual(actSolution, expSolution);
            
            % test limits
            actSolution=T.FT{2};expSolution=[0, 0, 5*a; 3*b, 0, 5*a];
            testCase.verifyEqual(actSolution, expSolution);
            actSolution=T.FT{1};expSolution=[0, 0, 3*b; 5*a, 0, 3*b];
            testCase.verifyEqual(actSolution, expSolution);
        end
    end
end

