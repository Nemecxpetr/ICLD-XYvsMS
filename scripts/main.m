%% MPC-EL2 23/24Z Elektroakustika 2: závěrečný projekt
% 
%   Autor: Bc. Petr Němec
%
%   Zadání: 
%         Proveďte výpočet a zobrazení závislosti mezikanálové diference
%         úrovně signálu (ICLD) při stereofonním ozvučení pro mikrofonní
%         techniku XY a MS při použití různých typů kombinovaných
%         akustických přijímačů (subkardioida, kardioida, hyperkardioida)
%         na pozici zdrojů zvuku od -60° do 60° (0° odpovídá ose symetrie
%         konfigurace XY resp. akustická osa mikrofonu M konfigurace MS)
%         a porovnejte je s ICLD sinusového a tangentového zákona.
% 
%         V případě techniky XY bude možné také specifikovat úhel mezi
%         akustickými osami přijímačů a u techniky MS poměr zesílení 
%         složek M a S.
%
%    Vstupní parametry pro XY:         
%         typ přijímače (subkardioida, kardioida, hyperkardioida)
%         úhel mezi akustickými osami přijímačů
%
%    Vstupní parametry pro MS:         
%         typ přijímače M (subkardioida, kardioida, hyperkardioida)
%         zesílení složky S (0 až 1)
%
%    Výstupní parametry:         
%         vektor závislosti ICLD na azimutu zdroje zvuku
%         vektor odpovídajících azimutů
%
%    Literatura:         
%         přednáška Akustické přijímače
%         přednáška Prostorová reprodukce zvuku
clc;
close all;
clear vars;

%% zobrazení pomocných slidů z literatury
%showImg("resources\zadani.png", "Zadání");
%showImg("resources\zakon.png", "Zákony");

%% Volání funkcí pro výpočet ICLD
stereo_baze = 60 * pi/180;
sGain = 1;
xyAngle = 90;

technique = 'XY';
% TODO: change input angle to radians so that it is smaller number in case
% of confusing with MS technique
[ICLD_XY, XY_angle] = vypocetICLD(receiverType.kardioida, xyAngle, technique, stereo_baze, false);
technique = 'MS';
[ICLD_MS, MS_angle] = vypocetICLD(receiverType.kardioida, sGain, technique, stereo_baze, false);


alpha0 = stereo_baze; %30° ---> 60° stereo báze poslechu
alpha = -alpha0:pi/180:alpha0;


figure();
disp(strcat('S gain = ',num2str(sGain),', XY angle = ',num2str(xyAngle)));
plot(XY_angle*180/pi, ICLD_XY, 'LineWidth', 2); hold on;
plot(MS_angle*180/pi, ICLD_MS, 'LineWidth', 2);
intensity_pan(alpha, alpha0, 'sin');
intensity_pan(alpha, alpha0, 'tan');
hold off;
grid on;
xlabel('\alpha [\circ] \rightarrow');
ylabel('{\itICLD} [dB] \rightarrow');  
xy = strcat('XY, pro úhel ', num2str(xyAngle), '° ');
ms = strcat('MS, zesílení složky S = ', num2str(sGain));
legend(xy, ms,'Sinusový zákon', 'Tangentový zákon', 'Location', 'southeast')


%% Funkce:
function [ICLD, ICLD_angle] = vypocetICLD(recType, par, technique, stereo_alpha, debug)
%% Function realizing the computation of ICLD for XY configuration
% Input:
%       recType (enum receiverType): receiver type, f.e. subkardioida,
%          karidioida, hyperkardioida
%       par (float): 
%           If technique XY selected: angle between receiver and acoustic symmetry axis
%           If techniqe MS selected: gain of S element
%       technique (string): 'xy', 'ms' for selected recording technique

% Returns:
%       ICLD_XY (vector): vector of ICLD of left and right channel for
%          ICLD_angle field
%       ICLD_angle (vector): vector field 
% Part of final project for EL2

%% Preparing the azimuth vector
    alpha0 = stereo_alpha; %30° ---> 60° stereo báze poslechu
    alpha = -alpha0:pi/180:alpha0;
    al0 = 180-round(alpha0*180/pi);
    if strcmpi(technique, 'xy')
        [phi, g] = getRecType(recType, debug);
        
        % to change angle use circshift
        rX = circshift(g, ceil(par/2));
        rY = circshift(g, -ceil(par/2));
        plotPolarRec(phi, rX, rY)
       
        L = rX;
        R = rY;
    elseif strcmpi(technique, 'ms')
        % Eight characteristic
        % should be kardioid, but we can experiment with trying different
        [phi, M] = getRecType(recType, debug);
        [~, S] = getRecType(0, debug);
        S = par*circshift(S, 90);

        plotPolarRec(phi, M, S)
        
        %showImg("resources\MS.png", "MS")
        
        L = (M + S) / sqrt(2);
        R = (M - S) / sqrt(2);

        plotPolarRec(phi, L, R);
    end

    % shift back, so that center is at 90 degrees
    L = circshift(L, 180);
    R = circshift(R, 180);
    
    
    %% compute the ICLD
    ICLD = 20*log10(L./R);

    %% Choose only angles of the stereo base
    ICLD = ICLD(al0:end-al0-1);
    ICLD_angle=alpha;
    
    if nargout <1; plotICLD(L, R, ICLD_angle); end
end

function [phi, rr] = getRecType(recType, verbose)
%% Returns gain of specified receiver type centralized for 0°
%   Args:
%       recType: 
%       verbose (bool): show the setting chart
%   Returns:
%       phi: horizotal angle vector
%       rr: sensitivity vector with the same shape as phi corresponding to
%       specified angles
%
    % Vlasnosti přijímačů 1. řádu:
    if verbose; showImg("resources\prijimace_1_order.png", "Parametry přijímačů 1. řádu");end
    switch recType
        case receiverType.subkardioida
            eta0 = 0.7;
            eta1 = 0.3;
        case receiverType.kardioida
            eta0 = 0.5;
            eta1 = 0.5;
        case receiverType.superkardioida
            eta0 = 0.37;
            eta1 = 0.63;
        case receiverType.hyperkardioida
            eta0 = 0.25;
            eta1 = 0.75;
        otherwise % osmička
            eta0 = 0;
            eta1 = 1;
    end
    
    % TODO: upravit pro možnost měnit řád přijímače (byť to pro techniku XY a
    % MS nedává smysl
    % výpočet citlivosti mikrofonu pro zadaný tvar charakteristiky přijímače:
    [phi, theta, r] = directional_3D(eta0, eta1, false);
    % NOTE: r je pole pro 3D hodnoty (phi x theta)
    % momentálně overkill, ale kdybych to chtěl někdy předělat pro 3D s
    % možností nastavení úhlu theta tak to tu nechám takto
    % zobrazení charakteristiky
    % pro další práci stačí pouze horizontální rovina:
    % Výběr horizontální roviny
    idxs = find(theta>=0,1);
    if size(idxs,1)==1
        rr = r(:,idxs); 
    else 
        rr = r(idxs); 
    end
    phi = phi';
end

function [] = showImg(path, name) 
%% shows picture
    img = imread(path);
    f = figure('Name', name);
    f.Position(3:4) = [280 210];
    imshow(img);
end

function [] = plotPolarRec(phi, r1, r2)
%% vyresleni 2D smerove charakteristiky v horizontalni rovine
    figure;
    pox = polaraxes;
    hold on;
    polarplot(phi, r1);
    polarplot(phi, r2);
    hold off;
    pox.ThetaLim = [-180, 180];
    pox.ThetaZeroLocation = 'top';
    pox.ThetaDir = 'clockwise';
    title('pomer citlivosti ');
end

function [] = plotICLD(gL, gR, alpha)
%% Plots the ICLD 
    ICLD = 20*log10(gL./gR);
    % vykresleni gL, gR a ICLD, pokud nejsou zadane navratove parametry
    figure();
    plot(alpha*180/pi, gL, 'b', 'LineWidth', 2);
    hold on;
    plot(alpha*180/pi, gR, 'r', 'LineWidth', 2);
    plot(alpha*180/pi, gL.^2+gR.^2, 'g', 'LineWidth', 2);
    hold off;
    grid on;
    %ylim([0 1.1]);
    xlabel('\alpha [\circ] \rightarrow');
    legend('g_1', 'g_2', 'energie');
    
    figure();
    plot(alpha*180/pi, ICLD, 'b', 'LineWidth', 2);
    grid on;
    xlabel('\alpha [\circ] \rightarrow');
    ylabel('{\itICLD} [dB] \rightarrow');    
end
