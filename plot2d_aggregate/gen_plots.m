function gen_plots()

rand('twister',2);

%for i = [1:100]
    % generate a 2d noise landscape
    noise = perlin(100,8);
    
    
    figure(1);
    subplot(2,1,1);
    image(noise*65);
    colorbar;
    subplot(2,1,2);
    mesh(noise);
    %theta;
    
    
    
    xlabel('test');
    
%end


%%
function s = perlin (m, num_iter)
  s = zeros(m);    % output image  
  i = 0;           % iterations

  while  (i < num_iter)
    i = i + 1;
    div = 1+floor(1.6^(i+1))
       
    base = rand(div);
    % make a 3x3 tile of base so that interp will wrap the interpolation
    
    base = [base, base, base; base, base, base; base, base, base];  
    gx = div+1+[0:m-1]/(m+1)*div; % only extract the middle tile values
    d = interp2(base, gx,gx', 'spline');

    s = s + d/(1.6^i);
  end
  
   max_n = max(max(s));
   min_n = min(min(s));
  s= (s-min_n)/(max_n-min_n);
  
%%
