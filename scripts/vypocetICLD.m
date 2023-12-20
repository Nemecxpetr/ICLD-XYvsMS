function [ICLD, ICLD_angle, phi, r1, r2, L, R] = vypocetICLD(recType, technique, par,  stereo_alpha, debug)
%% Function realizing the computation of ICLD for XY configuration
% Input:
%       recType (enum receiverType): receiver type, f.e. subkardioida,
%          karidioida, hyperkardioida
%       technique (string): 'xy', 'ms' for selected recording technique
%       par (float): 
%           If technique XY selected: angle between receiver and acoustic symmetry axis
%           If techniqe MS selected: gain of S element
%       stereo_alpha (float): reproduction stereo base angle (in degrees)
%       debug (bool) : debugging visualisations

% Returns:
%       ICLD_XY (vector): vector of ICLD of left and right channel for
%          ICLD_angle field
%       ICLD_angle (vector): vector field 
% Part of final project for EL2

%% Preparing the azimuth vector
    alpha0 = stereo_alpha*pi/180; %30° ---> 60° stereo báze poslechu
    alpha = -alpha0:pi/180:alpha0;
    al0 = 180-round(alpha0*180/pi);
    if strcmpi(technique, 'xy')
        [phi, g] = getRecType(recType, debug);
        
        % to change angle use circshift
        rX = circshift(g, ceil(par/2));
        rY = circshift(g, -ceil(par/2));
        
        r1 = rX;
        r2 = rY;
        % moved to the app
        %plotPolarRec(phi, rX, rY)
       
        L = rX;
        R = rY;
    elseif strcmpi(technique, 'ms')
        % Eight characteristic
        % should be kardioid, but we can experiment with trying different
        [phi, M] = getRecType(recType, debug);
        [~, S] = getRecType(0, debug);
        S = par*circshift(S, 90);
            
        r1 = M;
        r2 = S;
        % moved to the app
        %plotPolarRec(phi, M, S)
        
        %showImg("resources\MS.png", "MS")
        
        % TODO WTF is going on here?
        % Look at the energy graph of MS
        L = (M + S) / sqrt(2);
        R = (M - S) / sqrt(2);
    end
    
    % shift back, so that center is at 90 degrees
    L = circshift(L, 180);
    R = circshift(R, 180);
    

    %% compute the ICLD
    ICLD = 20*log10(L./R);

    %% Choose only angles of the stereo base
    ICLD = ICLD(al0:end-al0-1);

    %% I dont know if this is correct but it is the easiest way to compare them
    if strcmpi(technique, 'ms')
        ICLD(1:floor(end/2)) = -ICLD(1:floor(end/2));
    end

    ICLD_angle=alpha;
    
    %% visualize
    if nargout <1; plotICLD(L, R, ICLD_angle); end
end