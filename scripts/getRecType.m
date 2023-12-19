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