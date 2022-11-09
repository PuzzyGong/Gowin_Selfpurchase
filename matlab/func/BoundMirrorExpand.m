function B = BoundMirrorExpand(A)

[m,n,k] = size(A);
yi = 2:m+1;
B = zeros(m+2,n,k);
B(yi,1:n,:) = A;
B([1 end],:,:)=A([1 end],:,:);

