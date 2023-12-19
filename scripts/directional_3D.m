% zobrazeni 3D smerove charakteristiky smeroveho prijimace 1. radu

% eta0 = 0.3;
% eta1 = 1 - eta0;
% 
% [Q, IQ, DF, alpha] = directional_3D(eta0, eta1);
% 
% disp(strcat("Q=",num2str(Q)));
% disp(strcat("IQ=",num2str(IQ),"dB"));
% disp(strcat("DF=",num2str(DF)));
% disp(strcat("alpha=",num2str(alpha*180/pi),"deg"));

function [phi, theta, r] = directional_3D(eta0, eta1, varargin)

% eta0 - citlivost prijimace 0. radu
% eta1 - citlivost prijimace 1. radu
% show (bool) - if true shows the graphs
% Q - cinitel smerovosti
% IQ - index smerovosti
% DF - cinitel vzdalenosti
% alpha - sirka laloku


%% Loading optional arguments
if ~isempty(varargin)
    show = varargin{1};
end

    %% vypocet parametru
    % TODO: vypocet cinitele smerovosti, indexu smerovosti, cinitele 
    % vzdalenosti a sirky laloku podle rovnic (4) az (7), 
    % ulozeni do promennych Q, IQ, DF a alpha
    Q = 3/(3*eta0.^2+eta1.^2);
    IQ = 10*log10(Q);
    DF = sqrt(Q);
    alpha = 2*acos((0.5-eta0)/eta1);
    
    %% vypocet smerove funkce
    % TODO: vytvoreni vektoru pro uhly azimutu (phi) a elevace (theta) v radianech
    % ulozeni do vektoru phi a theta
    phi = (0:1:360)/180*pi;
    theta = (-90:1:90)/180*pi;
    % varianta s linspace
    % theta = linspace(-pi/2,pi/2,181);
    % phi = linspace(0,2*pi,361);
    
    % TODO: vypocet smerove funkce - varianta s cykly for
    % 1) vytvorit dva vnorene cykly for pro vsechny prvky vektoru phi a vektoru theta
    % 2) uvnitr cyklu vypocitat hodnoty smerove funkce pro dany azimut a elevaci
    %    podle rovnice (1), ulozit do matice r
    % 3) prevod r, phi a theta na kartezske souradnice, ulozeni do matic x, y a z
    
    % priprava nulovych matic pro ulozeni smerove funkce a pozic v kartezskych souradnicich
    r = zeros(length(phi),length(theta)); % vzdalenost od pocatku grafu = smerova funkce
    x = zeros(length(phi),length(theta)); 
    y = zeros(length(phi),length(theta)); 
    z = zeros(length(phi),length(theta)); 
    
    for m = 1:length(phi)
        for n = 1:length(theta)
            % vypocet smerove funkce pro dany azimut a elevaci z rovnice (1)
            % ulozeni do 2D matice r
            r(m,n) = abs(eta0 + eta1.*cos(phi(m)).*cos(theta(n)));
            % prevod na kartezske souradnice, ulozeni do 2D matic x, y a z
            [x(m,n),y(m,n),z(m,n)] = sph2cart(phi(m),theta(n),r(m,n));
        end
    end
    
%     % vypocet smerove funkce - varianta s maticemi
%     % vytvoreni matic z vektoru phi a theta
%     [theta2D,phi2D] = meshgrid(theta,phi);
%     % vypocet matice r (smerove funcke) pro smery z matic phi a theta z rovnice (5)
%     r = abs((eta0 + eta1.*cos(phi2D).*cos(theta2D)));
%     % prevod na kartezske souradnice
%     [x,y,z] = sph2cart(phi2D,theta2D,r);
    
    %% vykresleni 3D smerove charakteristiky
    if show
    figure;
    colormap('copper');
    if length(r)>1
        mesh(x,y,z,r);
    else
        mesh(x,y,z);
    end
    axis equal;
    colorbar;
    xlabel('{\itx} \rightarrow');
    ylabel('{\ity} \rightarrow');
    zlabel('{\itz} \rightarrow');
    
    %% vyresleni 2D smerove charakteristiky v horizontalni rovine
    if size(phi,1)==1, phi = phi'; end
    idxs = find(theta>=0,1);
    if size(idxs,1)==1
        rr = r(:,idxs); 
    else 
        rr = r(idxs); 
    end
    figure;
    plot(phi(:,1)-pi, fftshift(rr),'LineWidth',2);
    grid on;
    axis([-pi pi 0 1]);
    xlabel('{\it\phi} [rad] \rightarrow');
    ylabel('{\itr} \rightarrow');
    title(['pomer citlivosti ' num2str(eta0) '/' num2str(eta1)]);
    figure;
    polarplot(phi(:,1)-pi, fftshift(rr));
    title(['pomer citlivosti ' num2str(eta0) '/' num2str(eta1)]);
    end

disp("Function birectional_3D Returned:");
disp(strcat("Q=",num2str(Q)));
disp(strcat("IQ=",num2str(IQ),"dB"));
disp(strcat("DF=",num2str(DF)));
disp(strcat("alpha=",num2str(alpha*180/pi),"deg"));

end