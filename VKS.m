function rho = VKS()

    %Set up VideoWriter
%     movieObj = VideoWriter('VKS.avi');
%     movieObj.FrameRate = 30;
%     open(movieObj);
    
    hold off;
    uFilePrefix = 'smallr/u_';
    vFilePrefix = 'smallr/v_';
    filePost = '.dat';
    x = linspace (0,32,129);
    y = linspace (0,16,65);
    dx = x(2)-x(1);
    dy = y(2)-y(1);
    dt = .7*dx;

    rho = zeros(129, 65);

    for i=1:129
        for j=1:65
            if (x(i)==0 && abs(y(j)-8)<=2)
                rho(i,j) = 1;
            else
                rho(i,j)=0;
            end
        end
    end

    rho_new=rho;

    for dat_step = 1:999
        fileNumber = sprintf('%03i', dat_step);
        uFileName = strcat(uFilePrefix, fileNumber, filePost);
        vFileName = strcat(vFilePrefix, fileNumber, filePost);
        U = csvread(uFileName);
        V = csvread(vFileName);
        U=U';
        V=V';

        for j=1:65
            if abs(y(j)-8)<=2
                rho(1,j) = 1;
            end
        end

        for i=1:129
            for j=1:65
                u = U(i, j);
                v = V(i, j);

                if u <= 0 %this is branch 1: u <= 0
                    if i==129 %this is boundary case 2
                        drx = -rho(i,j)/dx;
                    else
                        drx = (rho(i+1,j)-rho(i,j))/dx;
                    end

                else %this is branch 2: u > 0
                    if i==1 %boundary case 1
                        drx = rho(i,j)/dx;
                    else
                        drx = (rho(i,j)-rho(i-1,j))/dx;
                    end
                end %drx is set
                
                
                if v <= 0 %this is branch 3: v <= 0
                    if j==65 %this isboundary case 4
                        dry = -rho(i,j)/dy;
                    else
                        dry = (rho(i,j+1)-rho(i,j))/dy;
                    end
                    
                else %this is branch 4: v > 0
                    if j==1 %boundary case 3
                        dry = rho(i,j)/dy;
                    else
                        dry = (rho(i,j)-rho(i,j-1))/dy;
                    end
                end %dry is set
                
                % this is it
                rho_new(i,j) = -dt*(u*drx + v*dry) + rho(i,j);
            end
        end
        
        contourf(rho_new');
        %mesh(rho_new);
        pause(.06); %999 steps in 60 seconds
        rho=rho_new;
        
        %Write a frame of video for the current iteration
%         writeVideo(movieObj, getframe);
    end
    %Movie's over...
%     close (movieObj);
end
