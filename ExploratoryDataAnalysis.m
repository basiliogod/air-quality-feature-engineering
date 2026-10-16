%% Fase 3: Exploratory Data Analysis (EDA)
fprintf('\n--- A Iniciar Análise Exploratória de Dados (EDA) ---\n');

% Obter matriz numérica normalizada para modelos espectrais/PCA
X_norm = data_clean{:, featureNames};
y = data_clean.(targetName);

%% 1. Painel de Dispersão com o Alvo (Gráficos 1 a 6) - ESCALA FÍSICA REAL
figure('Color', 'w', 'Position', [100, 100, 1000, 600]);
topFeatures = {'PT08_S1_CO_', 'PT08_S2_NMHC_', 'C6H6_GT_', 'NOx_GT_', 'PT08_S3_NOx_', 'T'};
plotTitles  = {'PT08.S1', 'PT08.S2', 'C6H6(GT)', 'NOx(GT)', 'PT08.S3', 'Temperatura'};
plotXLabels = {'Resposta Sensor', 'Resposta Sensor', 'Concentração [\mug/m^3]', 'Concentração [ppb]', 'Resposta Sensor', 'Temperatura [°C]'};

for i = 1:6
    subplot(2, 3, i);
    f = topFeatures{i};
    x_real = data_clipped.(f);
    
    scatter(x_real, y, 8, [0.2 0.4 0.7], 'filled', 'MarkerFaceAlpha', 0.25);
    hold on;
    % Ajuste polinomial na escala física
    p = polyfit(x_real, y, 2);
    x_lin = linspace(min(x_real), max(x_real), 100);
    y_lin = polyval(p, x_lin);
    plot(x_lin, y_lin, 'r-', 'LineWidth', 2);
    
    title(plotTitles{i}, 'FontSize', 10, 'FontWeight', 'bold');
    xlabel(plotXLabels{i});
    ylabel('CO(GT) [mg/m^3]');
    grid on;
    set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
end
saveas(gcf, 'images/eda_scatter_relations.png');

%% 2. Análise de Componentes Principais (PCA) (Gráficos 7 e 8) - ESCALA NORMALIZADA
% PCA exige dados normalizados para evitar domínio de grandezas com maior variância absoluta
[coeff, score, latent, tsquared, explained] = pca(X_norm);

figure('Color', 'w', 'Position', [100, 100, 950, 400]);

% Gráfico 7: Scree Plot
subplot(1, 2, 1);
pareto(explained);
xlabel('Componente Principal');
ylabel('Variância Explicada (%)');
title('Scree Plot - Variância por Componente');
grid on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');

% Gráfico 8: Projeção 2D (PC1 vs PC2)
subplot(1, 2, 2);
scatter(score(:, 1), score(:, 2), 10, y, 'filled');
colormap(gca, 'jet');
c = colorbar;
c.Label.String = 'CO(GT) [mg/m^3]';
xlabel(sprintf('PC1 (%.1f%%)', explained(1)));
ylabel(sprintf('PC2 (%.1f%%)', explained(2)));
title('Projeção 2D no Espaço PCA');
grid on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
saveas(gcf, 'images/eda_pca_analysis.png');

%% 3. Matriz de Correlação e Interação 3D (Gráficos 9 e 10)
figure('Color', 'w', 'Position', [100, 100, 950, 420]);

% Gráfico 9: Mapa de Calor da Matriz de Correlação (invariante a escala linear)
subplot(1, 2, 1);
allVars = [featureNames, {targetName}];
corrMatrix = corr(data_clean{:, allVars});
cleanVarLabels = strrep(allVars, '_', ' ');

imagesc(corrMatrix);
colormap(gca, 'parula');
colorbar;
caxis([-1, 1]);
set(gca, 'XTick', 1:length(allVars), 'XTickLabel', cleanVarLabels, 'XTickLabelRotation', 45);
set(gca, 'YTick', 1:length(allVars), 'YTickLabel', cleanVarLabels);
title('Matriz de Correlação Cruzada');
axis square;

% Gráfico 10: Relação 3D entre Sensores Primários e o Alvo (Escala Física)
subplot(1, 2, 2);
scatter3(data_clipped.PT08_S1_CO_, data_clipped.PT08_S2_NMHC_, y, 10, y, 'filled');
colormap(gca, 'jet');
xlabel('PT08.S1');
ylabel('PT08.S2');
zlabel('CO(GT) [mg/m^3]');
title('Interação 3D: Sensores vs CO(GT)');
view(45, 25);
grid on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
saveas(gcf, 'images/eda_multivariada.png');

%% 4. Distribuição e Assimetria das Features (Gráficos 11 a 16) - ESCALA FÍSICA REAL
figure('Color', 'w', 'Position', [100, 100, 1000, 600]);
distFeatures = {'PT08_S1_CO_', 'PT08_S2_NMHC_', 'C6H6_GT_', 'NOx_GT_', 'PT08_S3_NOx_', 'RH'};
distTitles   = {'PT08.S1', 'PT08.S2', 'C6H6(GT)', 'NOx(GT)', 'PT08.S3', 'Humidade Relativa'};
distXLabels  = {'Sinal do Sensor', 'Sinal do Sensor', '[\mug/m^3]', '[ppb]', 'Sinal do Sensor', '[%]'};

for i = 1:6
    subplot(2, 3, i);
    feat = distFeatures{i};
    v = data_clipped.(feat);
    histogram(v, 25, 'Normalization', 'pdf', 'FaceColor', [0.3 0.6 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.6);
    hold on;
    x_axis = linspace(min(v), max(v), 200);
    y_norm = normpdf(x_axis, mean(v), std(v));
    plot(x_axis, y_norm, 'r--', 'LineWidth', 1.5);
    title(distTitles{i}, 'FontSize', 10, 'FontWeight', 'bold');
    xlabel(distXLabels{i});
    ylabel('Densidade');
    grid on;
    set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
end
saveas(gcf, 'images/eda_features_distributions.png');

%% 5. Dinâmica Temporal e Padrão Horário (Gráficos 17 e 18) - ESCALA FÍSICA REAL
figure('Color', 'w', 'Position', [100, 100, 1000, 420]);

% Gráfico 17: Perfil Médio Horário (24 Horas)
subplot(1, 2, 1);
tCol = data_clean.Time;
if isnumeric(tCol)
    if all(tCol >= 0 & tCol <= 1)
        hoursArr = floor(tCol * 24);
    else
        hoursArr = floor(tCol);
    end
elseif isduration(tCol)
    hoursArr = floor(hours(tCol));
elseif isdatetime(tCol)
    hoursArr = hour(tCol);
elseif iscell(tCol) || isstring(tCol)
    tStr = string(tCol);
    tStr = regexprep(tStr, '\.', ':');
    hoursArr = hour(datetime(tStr, 'InputFormat', 'HH:mm:ss'));
else
    hoursArr = mod(0:height(data_clean)-1, 24)';
end

hourlyMeanCO = zeros(24, 1);
hourlyStdCO  = zeros(24, 1);
for h = 0:23
    idxH = (hoursArr == h);
    hourlyMeanCO(h+1) = mean(y(idxH));
    hourlyStdCO(h+1)  = std(y(idxH));
end

errorbar(0:23, hourlyMeanCO, hourlyStdCO, '-o', 'Color', [0.8 0.3 0.1],'LineWidth', 1.5, 'MarkerFaceColor', [0.8 0.3 0.1]);
title('Ciclo Diário Médio de CO(GT) (24 Horas)');
xlabel('Hora do Dia (0-23h)');
ylabel('CO(GT) Médio [mg/m^3]');
xlim([-0.5, 23.5]);
grid on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');

% Gráfico 18: Rastreamento Temporal com Eixos Independentes (Unidades Reais)
subplot(1, 2, 2);
sampleWindow = 1:min(300, height(data_clean));
yyaxis left;
plot(sampleWindow, y(sampleWindow), 'b-', 'LineWidth', 1.2);
ylabel('CO(GT) [mg/m^3]');
yyaxis right;
plot(sampleWindow, data_clipped.PT08_S1_CO_(sampleWindow), 'm--', 'LineWidth', 1.2);
ylabel('PT08.S1 (Sinal Bruto)');
xlabel('Horas Consecutivas');
title('Rastreamento Temporal: CO(GT) vs PT08.S1');
grid on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
saveas(gcf, 'images/eda_temporal_patterns.png');

%% 6. Redundância Específica e Pesos PCA (Gráficos 19 e 20)
figure('Color', 'w', 'Position', [100, 100, 950, 420]);

% Gráfico 19: Dispersão Cruzada em Escala Real de Resposta dos Sensores
subplot(1, 2, 1);
scatter(data_clipped.PT08_S1_CO_, data_clipped.PT08_S2_NMHC_, 10, [0.1 0.6 0.3], 'filled', 'MarkerFaceAlpha', 0.4);
hold on;
p_cross = polyfit(data_clipped.PT08_S1_CO_, data_clipped.PT08_S2_NMHC_, 1);
x_s1 = linspace(min(data_clipped.PT08_S1_CO_), max(data_clipped.PT08_S1_CO_), 100);
plot(x_s1, polyval(p_cross, x_s1), 'k-', 'LineWidth', 2);
xlabel('PT08.S1(CO) [Resposta Bruta]');
ylabel('PT08.S2(NMHC) [Resposta Bruta]');
title('Colinearidade Direta entre Sensores');
grid on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');

% Gráfico 20: PCA Loadings em PC1 (com base nos dados normalizados)
subplot(1, 2, 2);
bar(coeff(:, 1), 'FaceColor', [0.3 0.4 0.6]);
set(gca, 'XTick', 1:length(featureNames), 'XTickLabel', strrep(featureNames, '_', ' '), 'XTickLabelRotation', 45);
ylabel('Peso (Loading) em PC1');
title('Contribuição das Features no PC1');
grid on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
saveas(gcf, 'images/eda_redundancy_loadings.png');

fprintf('Fase 3 concluída com sucesso\n');