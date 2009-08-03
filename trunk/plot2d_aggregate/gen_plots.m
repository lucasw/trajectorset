function veh = gen_plots()

rand('twister',2);

width = 100;
tmax = 450;
gravity = -0.0020;
acc = 0.0045;
tx = 40;
ty = 70;

max_tdot = pi/20;

%for i = [1:100]
    % generate a 2d wind landscape
    % > 0 means winds to east (or +x)
    % < 0 means winds to west (or -x)
    windx = 0.004*(perlin(width,8) -0.5);
    windy = 0.002*(perlin(width,8) -0.5);
    
    veh.x = zeros(1,tmax);
    veh.y = zeros(1,tmax);
    veh.vx = zeros(1,tmax);
    veh.vy = zeros(1,tmax);
    veh.ax = zeros(1,tmax);
    veh.ay = zeros(1,tmax);
    veh.theta = zeros(1,tmax);
    veh.thetadot = zeros(1,tmax);
    veh.theta_target = zeros(1,tmax);
    veh.theta_target2 = zeros(1,tmax);
    
    veh.x(1) = width/2;
    veh.y(1) = 0;
 
    veh.vx(1) = 0;
    veh.vy(1) = 0;
    

  
    for t = [2:tmax]
        
        dx = tx-veh.x(t-1);
        dy = ty-veh.y(t-1);
        dist = sqrt(dx*dx+dy*dy);
        
        veh.theta_target(t) = atan2( dx,dy );
        veh.theta_target(1:t) = unwrap(veh.theta_target(1:t));
        
        veh.theta_target2(t) = atan2(veh.vx(t-1),veh.vy(t-1));
        veh.theta_target2(1:t) = unwrap(veh.theta_target2(1:t));
        
        veh.thetadot(t) = 0.1*(veh.theta_target(t) - veh.theta(t-1) - 0.3*veh.theta_target2(t));
           
        if (veh.thetadot(t) > max_tdot)
            veh.thetadot(t) = max_tdot;
        elseif (veh.thetadot(t) < -max_tdot)
            veh.thetadot(t) = -max_tdot;
        end
        
        veh.theta(t) = veh.theta(t-1) + veh.thetadot(t);
        
%         if (veh.theta(t) > pi) 
%             veh.theta(t) = veh.theta(t)-2*pi;
%         elseif (veh.theta(t) < -pi)
%             veh.theta(t) = veh.theta(t)+2*pi;
%         end
            
        real_acc = acc*(0.6 + 0.4*dist/width);
        veh.ax(t) = sin(veh.theta(t))*real_acc;
        veh.ay(t) = cos(veh.theta(t))*real_acc + gravity;
        
        veh.vy(t) = veh.vy(t-1) + veh.ay(t);
        veh.vy(t) = veh.vy(t) + interp2(windy,veh.x(t-1),veh.y(t-1),'linear',0);

        veh.vx(t) = veh.vx(t-1) + veh.ax(t);
        veh.vx(t) = veh.vx(t) + interp2(windx,veh.x(t-1),veh.y(t-1),'linear',0);

        
        veh.x(t) = veh.x(t-1) + veh.vx(t);
        veh.y(t) = veh.y(t-1) + veh.vy(t);
        
        if veh.x(t) > width
            veh.x(t) = veh.x(t) -width;
        end
        
        if (veh.x(t) < 0)
           veh.x(t) = veh.x(t) + width;
        end
        
%         if veh.y(t) > width
%             veh.y(t) = veh.y(t) -width;
%         end
        
        if (veh.y(t) < 0)
           veh.y(t) = 0; % veh.y(t) + width;
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
        subplot(4,1,1);
    plot(veh.time, veh.x);
    title('x');
    subplot(4,1,2);
    plot(veh.time, veh.y);
    title('y');
    subplot(4,1,3);
    plot(veh.time, veh.vx);
    title('vx');
    subplot(4,1,4);
    plot(veh.time, veh.vy);
    title('vy');
    
        figure(3),
        subplot(4,1,1);
    plot(veh.time, veh.theta,veh.time, veh.theta_target);
    title('theta rad');
    subplot(4,1,2);
    plot(veh.time, veh.thetadot);
    title('thetadot rad/s');
    subplot(4,1,3);
    plot(veh.time, veh.theta_target2);
    title('theta target');
    subplot(4,1,4);
    plot(veh.time, veh.vy);
    title('vy');
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
