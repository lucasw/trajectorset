function veh = gen_plots()

rand('twister',2);

width = 100;
tmax = 200;
%for i = [1:100]
    % generate a 2d wind landscape
    % > 0 means winds to east (or +x)
    % < 0 means winds to west (or -x)
    windx = 0.05*(perlin(width,8) -0.5);
    windy = 0.009*(perlin(width,8) -0.5);
    
    veh.x = zeros(1,tmax);
    veh.y = zeros(1,tmax);
    veh.vx = zeros(1,tmax);
    veh.vy = zeros(1,tmax);
    
    veh.x(1) = width/2;
    veh.y(1) = 0;
 
    veh.vx(1) = 0;
    veh.vy(1) = 0.4;
    
    for t = [2:tmax]
        veh.vy(t) = veh.vy(t-1);
        veh.vy(t) = veh.vy(t) + interp2(windy,veh.x(t-1),veh.y(t-1),'linear',0);

        veh.vx(t) = veh.vx(t-1);
        veh.vx(t) = veh.vx(t) + interp2(windx,veh.x(t-1),veh.y(t-1),'linear',0);

        
        veh.x(t) = veh.x(t-1) + veh.vx(t);
        veh.y(t) = veh.y(t-1) + veh.vy(t);
        
        if veh.x(t) > width
            veh.x(t) = veh.x(t) -width;
        end
        
        if (veh.x(t) < 0)
           veh.x(t) = veh.x(t) + width;
        end
        
        if veh.y(t) > width
            veh.y(t) = veh.y(t) -width;
        end
        
        if (veh.y(t) < 0)
           veh.y(t) = veh.y(t) + width;
        end
        
    end
    
    veh.time = [1:tmax];
    
    figure(1);
    subplot(3,1,1);
    caxis([min(min(windx)) max(max(windx))]);
    image(windx,'CDataMapping','scaled');
    colorbar;
    subplot(3,1,2);
    caxis([min(min(windy)) max(max(windy))]);
    image(windy,'CDataMapping','scaled');
    colorbar;
    subplot(3,1,3);
    plot(veh.x, veh.y);
    
    figure(2),
    subplot(2,1,1);
    plot(veh.time, veh.vx);
    subplot(2,1,2);
    plot(veh.time, veh.vy);
%     subplot(2,1,2);
%     mesh(noise);

    
    
    
    xlabel('test');
    
%end


%%
function s = perlin (m, num_iter)
  s = zeros(m);    % output image  
  i = 0;           % iterations

  while  (i < num_iter)
    i = i + 1;
    div = 1+floor(1.6^(i+1));
       
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
