function EE_sumario(r, w, K_agg, L_agg)
% ----------------------------------------------------------------------- %
%
% Esta función ofrece un resumen del estado estacionario:
%   - Variables agregadas.
%   - Momentos de la distribución
%
% ----------------------------------------------------------------------- %

% Cargar globales relevantes
global eco vv mu matSt pos malla_z malla_a c_pol

fprintf('\nESTADO ESTACIONARIO\n\n')

%% NIVEL AGREGADO

% Calcular cantidades
    % Producción
    Y_agg = K_agg^eco.alpha * L_agg^(1-eco.alpha);
    % Consumo agregado
    C_agg = sum(c_pol.*mu);
    % Bienestar agregado
    W_agg = sum(vv.*mu);

% Mostrar resultados
fprintf("Agregados:\n" + ...
        "- Tipo de interés anual: %2.2f%%.\n" + ...
        "- PIB per cápita: %2.2f.\n" + ...
        "- Ratio de capital sobre PIB: %2.2f.\n" + ...
        "- Bienestar Agregado: %4.4f.\n" + ...
        "- Error en el mercado de bienes: %1.4f.\n\n", ...
        100*r, Y_agg, K_agg/Y_agg, W_agg, C_agg + eco.delta*K_agg - Y_agg);


%% MEDIDAS DE DESIGUALDAD

% Ajustes
n_cuan = 5; % número de cuantiles
top = 10;   % grupo de interés en la distribución

% Momentos de la distribución
    % Renta
    cuan_renta = round(100*cuantiles(n_cuan, w*malla_z(matSt(:,pos.z)), mu, top));
    % Riqueza
    cuan_riq = round(100*cuantiles(n_cuan, malla_a(matSt(:,pos.a)), mu, top));

% Mostrar datos
fprintf("Dispersión (renta):\n" + ...
        "- Rentas del trabajo por cuantiles: %s.\n" + ...
        "- Porcentaje de renta total recibido por el top %d%%: %d%%.\n\n", ...
        join(string(cuan_renta(1:end-1)) + "%"), top, cuan_renta(end));
fprintf("Dispersión (riqueza):\n" + ...
        "- Riqueza por cuantiles: %s.\n" + ...
        "- Porcentaje de riqueza total recibido por el top %d%%: %d%%.\n\n", ...
        join(string(cuan_riq(1:end-1)) + "%"), top, cuan_riq(end));


end