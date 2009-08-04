function veh = gen_plots()

do_plot = 0;

width = 100;
tmax = 450;
gravity = -0.0020;
acc = 0.0045;
tx = 40;
ty = 70;

max_tdot = pi/20;

for i = [100:999]
    rand('twister',i);
    % generate a 2d wind landscape
    % > 0 means winds to east (or +x)
    % < 0 means winds to west (or -x)
    windx = 0.004*(perlin(width,8) -0.5);
    windy = 0.002*(perlin(width,8) -0.5);
    
    veh_x = zeros(1,tmax);
    veh_y = zeros(1,tmax);
    veh_vx = zeros(1,tmax);
    veh_vy = zeros(1,tmax);
    veh_ax = zeros(1,tmax);
    veh_ay = zeros(1,tmax);
    veh_theta = zeros(1,tmax);
    veh_thetadot = zeros(1,tmax);
    veh_theta_target = zeros(1,tmax);
    veh_theta_target2 = zeros(1,tmax);
    
    veh_x(1) = width/2;
    veh_y(1) = 0;
 
    veh_vx(1) = 0;
    veh_vy(1) = 0;
    

  
    for t = [2:tmax]
        
        dx = tx-veh_x(t-1);
        dy = ty-veh_y(t-1);
        dist = sqrt(dx*dx+dy*dy);
        
        veh_theta_target(t) = atan2( dx,dy );
        veh_theta_target(1:t) = unwrap(veh_theta_target(1:t));
        
        veh_theta_target2(t) = atan2(veh_vx(t-1),veh_vy(t-1));
        veh_theta_target2(1:t) = unwrap(veh_theta_target2(1:t));
        
        veh_thetadot(t) = 0.1*(veh_theta_target(t) - veh_theta(t-1) - 0.3*veh_theta_target2(t));
           
        if (veh_thetadot(t) > max_tdot)
            veh_thetadot(t) = max_tdot;
        elseif (veh_thetadot(t) < -max_tdot)
            veh_thetadot(t) = -max_tdot;
        end
        
        veh_theta(t) = veh_theta(t-1) + veh_thetadot(t);
        
%         if (veh_theta(t) > pi) 
%             veh_theta(t) = veh_theta(t)-2*pi;
%         elseif (veh_theta(t) < -pi)
%             veh_theta(t) = veh_theta(t)+2*pi;
%         end
            
        real_acc = acc*(0.6 + 0.4*dist/width);
        veh_ax(t) = sin(veh_theta(t))*real_acc;
        veh_ay(t) = cos(veh_theta(t))*real_acc + gravity;
        
        veh_vy(t) = veh_vy(t-1) + veh_ay(t);
        veh_vy(t) = veh_vy(t) + interp2(windy,veh_x(t-1),veh_y(t-1),'linear',0);

        veh_vx(t) = veh_vx(t-1) + veh_ax(t);
        veh_vx(t) = veh_vx(t) + interp2(windx,veh_x(t-1),veh_y(t-1),'linear',0);

        
        veh_x(t) = veh_x(t-1) + veh_vx(t);
        veh_y(t) = veh_y(t-1) + veh_vy(t);
        
        if veh_x(t) > width
            veh_x(t) = veh_x(t) -width;
        end
        
        if (veh_x(t) < 0)
           veh_x(t) = veh_x(t) + width;
        end
        
%         if veh_y(t) > width
%             veh_y(t) = veh_y(t) -width;
%         end
        
        if (veh_y(t) < 0)
           veh_y(t) = 0; % veh_y(t) + width;
        end
        
    end
    
    veh_time = [1:tmax];
    
    
    if (do_plot) 
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
    hold on;
    plot(veh_x, veh_y);
    
    figure(2),
    subplot(4,1,1);
    hold on;
    plot(veh_time, veh_x);
    title('x');
    subplot(4,1,2);
    hold on;
    plot(veh_time, veh_y);
    title('y');
    subplot(4,1,3);
    hold on;
    plot(veh_time, veh_vx);
    title('vx');
    subplot(4,1,4);
    hold on;
    plot(veh_time, veh_vy);
    title('vy');
    
        figure(3),
        subplot(2,1,1);
        hold on;
    plot(veh_time, veh_theta,veh_time, veh_theta_target);
    title('theta rad');
    subplot(2,1,2);
    hold on;
    plot(veh_time, veh_thetadot);
    title('thetadot rad/s');
    end;
    
    
    pre = ['data' num2str(i+1e7) filesep]
    mkdir(pre);
    % save to mat files
    save([pre 'veh_time'], 'veh_time');
    save([pre 'veh_x' ],'veh_x'); 
    save([pre 'veh_y' ],'veh_y');
    save([pre 'veh_theta' ],'veh_theta');
    %     mesh(noise);
    
    
    xlabel('test');
    
end


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
