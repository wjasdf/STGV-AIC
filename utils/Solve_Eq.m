function R = Solve_Eq(R0, uvx, uvy, beta , b, lambda, method)
    if (~exist('b','var'))
       b = 0;
       lambda = 0;
    end
    if (~exist('method','var'))
       method = 'pcg';
    end

    [h, w] = size(R0);
    hw = h * w;
   
    %% calculate the five-point positive definite Laplacian matrix
    uvx = uvx(:);
    uvy = uvy(:);
    ux = padarray(uvx, h, 'pre'); ux = ux(1:end-h);
    uy = padarray(uvy, 1, 'pre'); uy = uy(1:end-1);
    D = uvx+ux+uvy+uy;
    T = spdiags([-uvx, -uvy],[-h,-1],hw,hw);
    %% calculate the variable of linear system  
    MN = T + T' + spdiags(D, 0, hw, hw);
    % i2 = I.^2;
    i2 = sparse(1:hw,1:hw,1,hw,hw);
    DEN = i2 + beta * MN +lambda * speye(hw,hw);
    NUM = R0+lambda * b;
    
    %% solve the linear system
    switch method
        case 'pcg'
            L = ichol(DEN,struct('michol','on'));
            [dst,flag1] = pcg(DEN, NUM(:), 0.01, 40, L, L'); 
            R1 = reshape(dst, h, w);

        case 'minres'
            [dst,~] = minres(DEN,NUM(:), 0.01, 40);
            R1 = reshape(dst, h, w);
        case 'bicg'
            [L,U] = ilu(DEN,struct('type','ilutp','droptol',0.01));
            [dst,~] = bicg(DEN,NUM(:), 0.01, 40, L, U);
            R1 = reshape(dst, h, w);

        case 'direct'
            [dst,~] = DEN\NUM(:); %#ok<RHSFN>
            R1 = reshape(dst, h, w);

    end
    if flag1
        dst= DEN\NUM(:); 
        R1 = reshape(dst, h, w);
    end
    
    R=R1;
   
end
