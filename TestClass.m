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
            
            %testing the dimension of a specific case
            actDim=size(cartesian_product([1:5],[1:2],[1:3]));
            expDim=[5*2*3, 3];
            testCase.verifyEqual(actDim,expDim)
        end
        function testcontainedIn(testCase)
            %testcontainedIn tests the function containedIn in enviornment
            %which should return 1 if the first input argument is a point
            %within the rectangle defined by the points in T.R=[xmin, ymin;
            %xmax, ymax] and 0 otherwise.
            T.R=[0 0; 1 1];
            
            %test return of 1(x in rectangle)
            actSolution=containedIn([0.5, 0.5],1,T);
            expSolution=1;
            testCase.verifyEqual(actSolution, expSolution);
            
            %test return of 0 (x outside of rectangle)
            actSolution=containedIn([2.5, 0.5],1,T);
            expSolution=0;
            testCase.verifyEqual(actSolution, expSolution)
        end
        function testWTSsimple(testCase)
            %testWTSsimple tests the function WTS_simpleconstruction in TS
            %which should return an object with 6 properties describing a 
            %WTS. 
            
            env=env1(); %some example settings
            a=2; b=2;u=1; d=2; l=3; r=4;
            T=WTS_simpleconstruction(env.n, a,b, env.Pi, env.Lap, u,d,l,r,env.init);
            
            %test cases for corners of states
            % rectangle1 should start in 0,0. all rectangles should be a
            % wide and b high. there should be 5 rectangles in horizontal
            % direction and 3 in vertical (giving 15 in total)
            actSolution=T.R(1,:,1);expSolution=[0,0];
            testCase.verifyEqual(actSolution, expSolution);
            actSolution=T.R(2,:,1);expSolution=[a,b];
            testCase.verifyEqual(actSolution, expSolution);
            actSolution=T.R(2,:,env.n);expSolution=[5*a,3*b];
            testCase.verifyEqual(actSolution, expSolution);
            
            %test values that should be transfered directly from input
            actSolution=T.Pi;expSolution=env.Pi;
            testCase.verifyEqual(actSolution, expSolution);
            actSolution=T.current;expSolution=env.init;
            testCase.verifyEqual(actSolution, expSolution);
            
            %test some edges
            % edges should have value:
            %l (left) if q2=q1-1 and mod(q1,5) not 1 (not at left edge)
            actSolution=full(T.adj(2,1));expSolution=l;
            testCase.verifyEqual(actSolution, expSolution);
            %d (down) if q2=q1-5 and q1>5 (not at bottom)
            actSolution=full(T.adj(6,1));expSolution=d;
            testCase.verifyEqual(actSolution, expSolution);
            %r (right) if q2=q1+1 and mod(q1,5) not 0 (not at right edge)
            actSolution=full(T.adj(14,15));expSolution=r;
            testCase.verifyEqual(actSolution, expSolution);
            %u (up) if q2=q1+5 and q1<11 (not at top)
            actSolution=full(T.adj(2,7));expSolution=u;
            testCase.verifyEqual(actSolution, expSolution);
            %0 otherwise (not possible to move from q1 to q2)
            actSolution=full(T.adj(2,6));expSolution=0;
            testCase.verifyEqual(actSolution, expSolution);
            
            % test limits FT which should describe the lines defining the 
            %limits of the workspace on the form of two 2x3 matrix where
            %each row is a limit line, the first element is the value of the
            %parameter which is constant and the 2nd and 3rd is the start 
            %and end values of the parameter that changes. Hence we expect
            %FTi=[imin, jmin, jmax; imax, jmin, jmax]
            % FT2 contains the lines along the x-axis (y constant)
            actSolution=T.FT{2};expSolution=[0, 0, 5*a; 3*b, 0, 5*a];
            testCase.verifyEqual(actSolution, expSolution);
            %FT1 contains the lines along the y-axis (x constant)
            actSolution=T.FT{1};expSolution=[0, 0, 3*b; 5*a, 0, 3*b];
            testCase.verifyEqual(actSolution, expSolution);
        end
        function testenv1(testCase)
            %tests the functions env1 which should return an object with 12
            %properties describing an environment. The tests focus on the
            %units and structure of the properties.
            env=env1();
            
            %n should be an integer valued double (number of regions)
            %test class=double
            actSol=env.n; expSol='double';
            testCase.verifyClass(actSol, expSol);
            %test value of integer
            actMod1=mod(env.n,1); expMod1=0;
            testCase.verifyEqual(actMod1,expMod1);
            
            %Pi should be a row-array of doubles with min 2 values
            %test class of elements
            actSol=env.Pi; expSol='double';
            testCase.verifyClass(actSol, expSol);
            %test number of rows
            actRows=size(actSol,1); expRows=1;
            testCase.verifyEqual(actRows, expRows);
            %test number of columns
            actCol=size(actSol,2); expminCol=2;
            testCase.verifyGreaterThanOrEqual(actCol, expminCol);
            
            %Lap should be a cell of size 1xactCol(from Pi-test)
            actSol=env.Lap; expSol='cell';
            testCase.verifyClass(actSol, expSol);
            actSize=size(actSol);expSize=[1, actCol];
            testCase.verifyEqual(actSize,expSize);
            
            %init should be a double less o equal to n
            actSol=env.init; expSol='double';
            testCase.verifyClass(actSol, expSol);
            expMax=env.n;
            testCase.verifyLessThanOrEqual(actSol, expMax);
        end
        function testNB(testCase)
            %test neighboors.m in MIC which should return a row-array of
            %doubles of size 2,3 or 4
            inp.N=30; inp.N1=6; %number of regions and regions/row
            for x=[1,18,15]
                actSol=neighboors(inp,inp,x);
                if x==1
                    expSol=[x+1, x+inp.N/inp.N1];
                elseif x==18
                    expSol=[x-1, x+inp.N/inp.N1, x-inp.N/inp.N1];
                else
                    expSol=[x+1, x-1, x+inp.N/inp.N1, x-inp.N/inp.N1];
                end
                testCase.verifyEqual(actSol, expSol);
            end
            testCase.verifyClass(actSol, 'double');
        end
        function testrho(testCase)
            %tests rhofunc(dt,ds,eps) in MIC which should return the value
            %of the function:
            %k=rho(dt-ds)/(rho(dt-ds)+rho(eps+ds-dt))
            %rho(s)=exp(-1/s) if s>0, 0 otherwise
            %ds,dt,eps>0
            
            %test case when dt>ds+eps, expect k=1
            dt=5; ds=2; eps=1;
            actSol=rhofunc(dt,ds,eps); expSol=1;
            testCase.verifyEqual(actSol, expSol);
            
            %test case when ds<dt<ds+eps, expect k in (0,1)
            %more specifically k=exp(1/(ds-dt))/(exp(1/(ds-dt))+exp(1/(dt-ds-eps)))
            dt=3; ds=2; eps=2;
            actSol=rhofunc(dt,ds,eps); 
            expSol=exp(1/(ds-dt))/(exp(1/(ds-dt))+exp(1/(dt-ds-eps)));
            testCase.verifyEqual(actSol, expSol);
            testCase.verifyLessThan(actSol, 1);
            testCase.verifyGreaterThan(actSol,0);
            
            %test case when dt<ds, expect k=0
            dt=1; ds=2; eps=1;
            actSol=rhofunc(dt,ds,eps); expSol=0;
            testCase.verifyEqual(actSol, expSol);
        end
        function testSome3(testCase)
            actSol=0; expSol=0;
            testCase.verifyEqual(actSol, expSol);
        end
        function testSome4(testCase)
            actSol=0; expSol=0;
            testCase.verifyEqual(actSol, expSol);
        end
        function testSome5(testCase)
            actSol=0; expSol=0;
            testCase.verifyEqual(actSol, expSol);
        end
        function testSome6(testCase)
            actSol=0; expSol=0;
            testCase.verifyEqual(actSol, expSol);
        end
    end
end

