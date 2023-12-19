%% funkce pro intenzitni panoramovani
function [gL, gR] = intensity_pan(alpha, alpha0, law)

    %  alpha - vektor azimutu v radianech
    %  alpha0 - azimut reproduktoru v radianech
    %  law - panoramovani podle sinusoveho nebo tangentoveho zakona ('sin','tan')
    %  gL - zesileni leveho kanalu
    %  gR - zesileni praveho kanalu
    
    % TODO: vypocet zesilovacich cinitelu pro levy a pravy kanal podle rovnic
    % (3) a (4), ulozeni do promennych gL a gR
    if strcmpi(law, 'sin')
        gRsquared = ((sin(alpha0)-sin(alpha)).^2) ./ (2*(sin(alpha0).^2+sin(alpha).^2));
    else %tan law
        gRsquared = ((tan(alpha0)-tan(alpha)).^2) ./ (2*(tan(alpha0).^2+tan(alpha).^2));
    end
    
    gLsquared = 1 - gRsquared;
    gL = sqrt(gLsquared);
    gR = sqrt(gRsquared);
    
    % TODO: vypocet ICLD podle rovnice (5), ulozeni do promenne ICLD
    ICLD = 20*log10(gL./gR);
    
    % vykresleni gL, gR a ICLD, pokud nejsou zadane navratove parametry
    if (nargout < 1) 
        % pokud je alpha skalar
        if (length(alpha)==1)
            disp(strcat('g1=',num2str(gL),', g2=',num2str(gR),', ILCD=',num2str(ICLD)));
        % pokud je alpha vektor
        else
            %figure();
%             plot(alpha*180/pi, gL, 'b', 'LineWidth', 2);
%             hold on;
%             plot(alpha*180/pi, gR, 'r', 'LineWidth', 2);
%             plot(alpha*180/pi, gL.^2+gR.^2, 'g', 'LineWidth', 2);
%             hold off;
%             grid on;
%             ylim([0 1.1]);
%             xlabel('\alpha [\circ] \rightarrow');
%             legend('g_1', 'g_2', 'energie');
    
           % figure();
            plot(alpha*180/pi, ICLD, 'LineWidth', 2);
            grid on;
            xlabel('\alpha [\circ] \rightarrow');
            ylabel('{\itICLD} [dB] \rightarrow');
        end
        clear g1 g2 ICLD;
    end
end