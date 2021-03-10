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
        function testhTAsah(testCase)
            %tests hybridTAsoftandhard(dead) in TAhd which should return an
            %object with 11 properties. Here we focus on testing units and
            %size
            A=hybridTAsoftandhard([1 2]);
            
            %S should be an array of doubles, length is hard-coded to 17
            % for more gerenarl use we will allow any array of doubles
            % counting from 1 upwards
            actSol=A.S; sizeSol=size(actSol,2); expSol=1:sizeSol;
            testCase.verifyEqual(actSol, expSol);
            testCase.verifyClass(actSol, 'double');
            
            %init should be a double with an integer value in the set
            %(1,max(A.S)
            actSol=A.init; expMax=max(A.S);
            %double class
            testCase.verifyClass(actSol, 'double');
            %in expected set
            testCase.verifyGreaterThanOrEqual(actSol,1);
            testCase.verifyLessThanOrEqual(actSol, expMax);
            %integer-value
            testCase.verifyEqual(mod(actSol,1),0);
            
            % final is an array of doubles (possibly with 1 element) each
            % element must satisfy the same properties as init.
            actSol=A.final; 
            %double class
            testCase.verifyClass(actSol, 'double');
            %properties of elements
            for i=actSol
                %in expected set
                testCase.verifyGreaterThanOrEqual(i,1);
                testCase.verifyLessThanOrEqual(i, expMax);
                %integer-value
                testCase.verifyEqual(mod(i,1),0);
            end
            % AP is an array of doubles with hard-coded data 1:4
            % for more gerenarl use we will allow any array of doubles
            % counting from 1 upwards
            actSol=A.AP; sizeSol=size(actSol,2); expSol=1:sizeSol;
            testCase.verifyEqual(actSol, expSol);
            %X has the same constraints as AP
            actSol=A.X; sizeSol=size(actSol,2); expSol=1:sizeSol;
            testCase.verifyEqual(actSol, expSol);
            %Xv should be the input value
            actSol=A.Xv; expSol=[1 2];
            testCase.verifyEqual(actSol, expSol);
            %Ix and Ixup should be a matrices of size |S|x|S| with values 0
            %or x in X
            actSol=A.Ix;  actSol2=A.Ixup;
            testCase.verifySize(actSol, [length(A.S), length(A.S)]);
            testCase.verifySize(actSol2, [length(A.S), length(A.S)]);
            %check values
            actValuation=double(ismember(actSol,[0, 1:length(A.X)]));
            actValuation2=double(ismember(actSol2,[0, 1:length(A.X)]));
            expValuation=ones(size(actSol));
            testCase.verifyEqual(actValuation, expValuation);
            testCase.verifyEqual(actValuation2, expValuation);
            %Ih should be a 3x|S| matrix with same values allowed as Ix and Ixup
            actSol=A.Ih; 
            testCase.verifySize(actSol, [3, length(A.S)]);
            actValuation=double(ismember(actSol, [0, 1:length(A.X)]));
            testCase.verifyEqual(actValuation, ones(size(actSol)));
            %act should be an array of doubles 
            actSol=A.act; 
            testCase.verifyClass(actSol, 'double');
            %trans should be a matrix of size |S|x|act|x|X| with doubles
            %taking on values in (1, |S|)
            actSol=A.trans; 
            testCase.verifyClass(actSol, 'double');
            testCase.verifySize(actSol, [length(A.S), max(A.act), length(A.X)]);
            actValuation=double(ismember(actSol, 0:length(A.S)));
            testCase.verifyEqual(actValuation, ones(size(actSol)));
        end
        function testP2(testCase)
            %Tests product2(T,A,set) in BWTS which should return an object
            %with 9 properties
            %some setting needed to create T and A (no impact on P)
            sett.opt_c=33; sett.eps=0.1; sett.u_joint=0; sett.lin_ass=0; 
            sett.rest=0.01;dead=[1 3];
            %construct P
            T=TS_construction(env1(),sett);A=hybridTAsoftandhard(dead);
            if size(A.Ix,1)==1
                set=1;
            else
                set=2;
            end
            P=product2(T,A,set);
            
            % S should contain the combos of all states in A and T
            actSol=P.S; N=size(actSol, 1);
            testCase.verifySize(actSol, [length(T.S)*length(A.S), 2]);
            testCase.verifyClass(actSol, 'double');
            testCase.verifyEqual(double(ismember(actSol(:,1),T.S)), ones(N,1));
            testCase.verifyEqual(double(ismember(actSol(:,2),A.S)), ones(N,1));
            
            % Q shoule be an array 1:N where N is the number of rows in S
            actSol=P.Q;
            testCase.verifyEqual(actSol, 1:N);
            
            %trans  should be a NxN matrix with positive definite values
            %they are not restricted to integers and may alos be inf. If
            %the value is not inf it must be projected from T.adj
            actSol=P.trans;
            testCase.verifySize(actSol, [N, N]);
            for elem=find(~isinf(actSol))'
                col=ceil(elem/N); row=elem+(1-col)*N;
                pi=P.S(row,1); pi2=P.S(col,1);
                testCase.verifyEqual(actSol(elem), full(T.adj(pi, pi2)));
            end
            
            %final should be an array of projected states from A
            actSol=P.final; actVal=double(ismember(P.S(actSol,2),A.final)); 
            expVal=ones(size(actVal));
            testCase.verifyEqual(actVal, expVal);
            
            % Ix and Ih should be projected from A (Ih transposed)
            actSol1=P.Ix; actSol2=P.Ih;
            for q=1:N
                for q2=1:N
                    testCase.verifyEqual(actSol1(q,q2),A.Ix(P.S(q,2),P.S(q2,2)));
                end
                for h=1:2
                    testCase.verifyEqual(actSol2(q,h),A.Ih(h, P.S(q,2)));
                end
            end
            %init should be projecyed from A and T
            actSol=P.init; expSol=[T.current, A.init];
            testCase.verifyEqual(P.S(actSol,:),expSol);
            %X and Xv should be copies from A
            testCase.verifyEqual(P.X, A.X); 
            testCase.verifyEqual(P.Xv, A.Xv); 
            
        end
        function testGS(testCase)
            %tests graphSearch(P,c,init_set) which should return an object with
            %9 properties. c must be in [0,1] and init_set is optional
            
            %Create an example P
            sett.opt_c=33; sett.eps=0.1; sett.u_joint=0; sett.lin_ass=0; 
            sett.rest=0.001;dead=[0.1 0.2];
            %construct P
            T=TS_construction(env2(),sett);A=hybridTAsoftandhard(dead);
            if size(A.Ix,1)==1
                set=1;
            else
                set=2;
            end
            P=product2(T,A,set);
            %construct an example gS
            gS=graphSearch(P,0.1);
            
            %path should be an array of values from P.Q
            actSol=gS.path; N=length(actSol);
            %check that it is an array
            testCase.verifySize(actSol, [1, N]);
            %check that values are allowed
            actVal=double(ismember(actSol,P.Q));
            testCase.verifyEqual(actVal, ones(1,N));
            
            %Fdh, Fdc, Fdd and Ftime should all be scalars >=0
            actSol1=gS.Fdh; actSol2=gS.Fdc; actSol3=gS.Fdd; actSol4=gS.Ftime;
            for elem=[actSol1, actSol2, actSol3, actSol4]
                testCase.verifySize(elem,[1 1]);
                testCase.verifyGreaterThanOrEqual(elem,0);
            end
            
            %time_vector, DD and DC should all be arrays of values >=0
            %which increases or stay the same, i.e. x(k+1)>=x(k), x(1)>=0,
            %the length of the arrays should be same as for path, i.e. N
            actSol=gS.time_vector;
            testCase.verifySize(actSol, [1,N]);
            last=0;
            for elem=actSol
                testCase.verifyGreaterThanOrEqual(elem,last);
                last=elem;
            end
            actSol=gS.DC;
            testCase.verifySize(actSol, [1,N]);
            last=0;
            for elem=actSol
                testCase.verifyGreaterThanOrEqual(elem,last);
                last=elem;
            end
            actSol=gS.DD;
            testCase.verifySize(actSol, [1,N]);
            last=0;
            for elem=actSol
                testCase.verifyGreaterThanOrEqual(elem,last);
                last=elem;
            end
            %trans should be a direct copy of P.trans
            actSol=gS.trans; expSol=P.trans;
            testCase.verifyEqual(actSol, expSol);
        end
        function testTAPr(testCase)
            %test taProject(path,P) which should return an array x of doubles
            %included in A.S such that P.S(path(i),2)=x(i)
            
            %construct an example of a P and some paths
            sett.opt_c=33; sett.eps=0.1; sett.u_joint=0; sett.lin_ass=0; 
            sett.rest=0.001;dead=[0.1 0.2];
            %construct P
            T=TS_construction(env2(),sett);A=hybridTAsoftandhard(dead);
            if size(A.Ix,1)==1
                set=1;
            else
                set=2;
            end
            P=product2(T,A,set);
            gS=graphSearch(P,0.5); gS2=graphSearch(P,1); gS3=graphSearch(P,0);
            path1=gS.path; path2=gS2.path; path3=gS3.path;
            %test the different cases
            actSol=taProject(path1,P); expSol=P.S(path1,2);
            testCase.verifyEqual(actSol, expSol);
            actSol=taProject(path2,P); expSol=P.S(path2,2);
            testCase.verifyEqual(actSol, expSol);
            actSol=taProject(path3,P); expSol=P.S(path3,2);
            testCase.verifyEqual(actSol, expSol);
        end
    end
end

