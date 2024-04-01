function EE_figs()

%% PREÁMBULO

% Cargar variables globales
global  n malla_a malla_z matSt pos ind ... % parámetros y estados
        a_pol c_pol vv ...                  % decisiones óptimas y valor
        Q mu                                % transiciones y distribución

% Opciones
tam_f = 16; % tamaño de fuente
tam_l = 2;  % grosor de línea

% Colores
azul = [35 80 217]/255;
naranja = [0.9290 0.6940 0.1250];
rojo = [218 58 52]/255;
gris = [0.5 0.5 0.5];


%% ACUMULACIÓN DE ACTIVOS

% Decisión óptima
figure()
hold on
    % Principal
    plot(malla_a, a_pol(ind.z_min), "LineWidth", tam_l, "Color", rojo)
    plot(malla_a, a_pol(ind.z_med), "LineWidth", tam_l, "Color", naranja)
    plot(malla_a, a_pol(ind.z_max), "LineWidth", tam_l, "Color", azul)
    % 0 acumulación
    plot(malla_a, malla_a, ':', 'Color', gris, 'LineWidth', tam_l)
    % Opciones
    grid on
    set(gca,'FontSize', tam_f)
    % Etiquetas
    title('Acumulación de activos')
    subtitle('por grupo de productividad')
    xlabel('Activos al principio del periodo')
    ylabel('Activos al final del periodo')
    legend('Productividad mínima', 'Productividad media', 'Productividad máxima', ...
           'Location', 'best');
hold off


%% CONSUMO

% Decisión óptima
figure()
hold on
    % Principal
    plot(malla_a, c_pol(ind.z_min), "LineWidth", tam_l, "Color", rojo)
    plot(malla_a, c_pol(ind.z_med), "LineWidth", tam_l, "Color", naranja)
    plot(malla_a, c_pol(ind.z_max), "LineWidth", tam_l, "Color", azul)
    % Opciones
    grid on
    set(gca,'FontSize', tam_f)
    % Etiquetas
    title('Política de consumo')
    subtitle('por grupo de productividad')
    xlabel('Activos al principio del periodo')
    ylabel('Consumo')
    legend('Productividad mínima', 'Productividad media', 'Productividad máxima', ...
           'Location', 'best');
hold off


%% FUNCIÓN DE VALOR

% Valor
figure()
hold on
    % Principal
    plot(malla_a, vv(ind.z_min), "LineWidth", tam_l, "Color", rojo)
    plot(malla_a, vv(ind.z_med), "LineWidth", tam_l, "Color", naranja)
    plot(malla_a, vv(ind.z_max), "LineWidth", tam_l, "Color", azul)
    % Opciones
    grid on
    set(gca,'FontSize', tam_f)
    % Etiquetas
    title('Función de valor')
    subtitle('por grupo de productividad')
    xlabel('Activos al principio del periodo')
    ylabel('Valor')
    legend('Productividad mínima', 'Productividad media', 'Productividad máxima', ...
           'Location', 'best');
hold off


%% DISTRIBUCIÓN DE ACTIVOS

figure()
hold on
    plot(malla_a, accumarray(matSt(:,pos.a), mu .* ind.z_min) / sum(mu(ind.z_min)), ...
         'LineWidth',tam_l,'Color',rojo)
    plot(malla_a, accumarray(matSt(:,pos.a), mu .* ind.z_med) / sum(mu(ind.z_med)), ...
         'LineWidth',tam_l,'Color',naranja)
    plot(malla_a, accumarray(matSt(:,pos.a), mu .* ind.z_max) / sum(mu(ind.z_max)), ...
         'LineWidth',tam_l,'Color',azul)
    % Opciones
    grid on
    set(gca,'FontSize', tam_f)
    % Etiquetas
    title('Distribución de riqueza')
    subtitle('por grupo de productividad')
    xlabel('Activos')
    ylabel('Distribución')
    legend('Productividad mínima', 'Productividad media', 'Productividad máxima', ...
           'Location', 'best');
hold off

end