function cuan = cuantiles(n_cuan, datos, distr, top)
    % Preparación: divisiones
    divs = linspace(0,1,n_cuan+1);
    divs = divs(2:end);
    % Ordenar nodos de menor a mayor cantidad
    [datos_ord, i_ord] = sort(datos);
    % Distribución acumulada
    distr_ord = distr(i_ord);
    distr_acum = cumsum(distr_ord)/sum(distr_ord);
    % Cuota asociada
    cuota_acum = cumsum(datos_ord.*distr_ord)/sum(datos_ord.*distr_ord);
    % Descartar elementos con masa cerca de 0
    i_aux = (distr_ord > 1e-15);
    % Interpolar los cuantiles de interés
    aux_cuan = interp1(distr_acum(i_aux), cuota_acum(i_aux), divs, 'linear', 'extrap');
    % Cuota del top
    cuota_top = 1 - interp1(distr_acum(i_aux), cuota_acum(i_aux), 1-top/100);
    % Devolver resultados
    cuan = [diff([0, aux_cuan]), cuota_top];
end