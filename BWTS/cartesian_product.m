%cartesian_product.m
%A. Nikou

function set = cartesian_product(varargin)
%Cartesian (direct) product of input sets; input sets must be row vectors
%obtain a matrix (or a cell if uncomment last line), each row is an element of the product

N=zeros(1,nargin);
for i=1:nargin
    if isempty(varargin{i}) %if any of inputs is empty, the result is also empty
        set=[];
        return
    end
    varargin{i}=unique(varargin{i});    %eliminate repeated elements from a subset (and order subsets ascending)
    N(i)=length(varargin{i});   %vector N will contain the number of elements of each subset
end
N=[1 N 1];  %add 2 elements of 1 in order to execute the "for"-loop for the last and first subset
            %(otherwise we would have got error because of index i)
set=zeros(prod(N),nargin);  %size of a matrix that will contain on each row a element of the cartesian product
for i = nargin:-1:1 %go backward through inputs (add columns starting with the last one)
    prod_val=prod(N(i+2:length(N)));    %to avoid multiple computations of same value
    col=zeros(prod_val*length(varargin{i}), 1); %preallocate vector col
    for j=1:length(varargin{i})
        col(1+prod_val*(j-1) : prod_val*j)=repmat(varargin{i}(j),prod(N(i+2:length(N))),1);  %store values in preallocated vector col
    end
    col=repmat(col,prod(N(1:i)),1);   %the whole column until now is repeated
                                      %(in order to add before it columns with 
                                      %elements from previous sets)
                                      %N(i+1) is now the number of elements of subset i
    set(:,i)=col;
end
