load( 'kitti3d_gt0.mat' )
T = 10; J = 36; % use 10 frames
p2 = zeros( 2 * T , J );
p3_gt = zeros( 3 * T, J );
for i = 1:T
    p2([i i+T],:) = p_cell{i};
    p3_gt([i i+T i+2*T],:) = gt_cell{i};
end

% missing data matrix
md = zeros( size( p2 ) );
md( p2 < 0 ) = 1;
md = md(1:T,:) & md(T+1:2*T,:);

% set md values to 0
p2( p2 < 0 ) = 0;

use_lds = 0;
max_em_iter = 60;
tol = 0.0001;
K = 2;

[P3, S_hat, V, RO, Tr, Z] = em_sfm(p2, md, K, use_lds, tol, max_em_iter);
%%

for i = 1:T
    proj3d = P3([i i+T i+2*T],:);
    
    fileName = strcat('test',string(i),'.txt');
    fileID = fopen(fileName, 'w');
    fprintf(fileID,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n', proj3d);
    fclose(fileID);
    
end
