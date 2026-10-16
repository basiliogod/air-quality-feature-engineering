%% Fase 4: Feature Selection Methods
fprintf('\n--- A Iniciar Seleção de Atributos ---\n');

% Assume 'data_clean' (normalizada) e 'featureNames' da Fase 2 e 3
X = data_clean{:, featureNames};
y = data_clean.(targetName);
p = length(featureNames);

%% 1. Análise da Relação Individual com o Alvo (Pearson e Spearman)
corrPearson = zeros(p, 1);
corrSpearman = zeros(p, 1);

for i = 1:p
    f = featureNames{i};
    corrPearson(i)  = corr(data_clean.(f), y, 'Type', 'Pearson');
    corrSpearman(i) = corr(data_clean.(f), y, 'Type', 'Spearman');
end

relationTable = table(featureNames', corrPearson, corrSpearman, abs(corrPearson),'VariableNames', {'Feature', 'Pearson_r', 'Spearman_rho', 'Abs_Pearson'});
relationTable = sortrows(relationTable, 'Abs_Pearson', 'descend');
fprintf('\n--- Ranking de Relevância face a CO(GT) ---\n');
disp(relationTable);

%% 2. Aplicação dos Critérios de Seleção
% Critério 1: Eliminação de atributos com fraco poder preditivo individual (|r| < 0.15)
threshold_relevance = 0.15;
weakFeatures = relationTable.Feature(relationTable.Abs_Pearson < threshold_relevance);

fprintf('Atributos Fracos Eliminados (|r| < %.2f):\n', threshold_relevance);
disp(weakFeatures);

% Candidatos retidos após o filtro de relevância
candidateFeatures = relationTable.Feature(relationTable.Abs_Pearson >= threshold_relevance);

% Critério 2: Avaliação de Redundância Mútua e Colinearidade (|r_ij| > 0.85)
corrCandidates = corr(data_clean{:, candidateFeatures});
threshold_redundancy = 0.85;

fprintf('--- Matriz de Correlação entre Candidatos ---\n');
disp(array2table(corrCandidates, 'VariableNames', candidateFeatures, 'RowNames', candidateFeatures));

% Seleção Criteriosa do Subconjunto Final:
% - C6H6_GT_: Medição analítica de maior correlação global (r = 0.93)
% - PT08_S1_CO_: Sensor semicondutor desenhado fisicamente para monitorizar CO
% - PT08_S3_NOx_: Sensor com forte correlação negativa (-0.70), fonte ortogonal
% - NOx_GT_: Marcador primário de combustão veicular a alta temperatura
%
% Atributos removidos por redundância:
% - PT08_S2_NMHC_: Colinear com PT08.S1 e C6H6 (r > 0.95)
% - PT08_S5_O3_: Redundante com os restantes sensores de óxido metálico (r > 0.88)
% - NO2_GT_ e PT08_S4_NO2_: Redundantes com NOx_GT_ e de menor correlação com o alvo

selectedFeatures = {'C6H6_GT_', 'PT08_S1_CO_', 'PT08_S3_NOx_', 'NOx_GT_'};
discardedFeatures = setdiff(featureNames, selectedFeatures);

fprintf('\n==============================================\n');
fprintf('Subconjunto Final de Atributos Selecionados (%d):\n', length(selectedFeatures));
disp(selectedFeatures');
fprintf('Atributos Descartados (%d):\n', length(discardedFeatures));
disp(discardedFeatures');
fprintf('==============================================\n');

%% 3. Geração de Gráficos de Suporte à Seleção
% Gráfico 1: Relevância Individual (Pearson vs Spearman)
figure('Color', 'w', 'Position', [100, 100, 950, 420]);
subplot(1, 2, 1);
bar(categorical(strrep(relationTable.Feature, '_', ' ')), relationTable.Abs_Pearson, 'FaceColor', [0.2 0.45 0.7]);
hold on;
yline(threshold_relevance, 'r--', sprintf('Limiar (|r| = %.2f)', threshold_relevance), 'LineWidth', 1.5);
ylabel('|Coeficiente de Correlação de Pearson|');
title('Relevância Individual face a CO(GT)');
xtickangle(45);
grid on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');

% Gráfico 2: Matriz de Redundância Antes vs Depois
subplot(1, 2, 2);
corrFinal = corr(data_clean{:, selectedFeatures});
imagesc(corrFinal);
colormap(gca, 'parula');
colorbar;
caxis([-1, 1]);
cleanSelectedLabels = strrep(selectedFeatures, '_', ' ');
set(gca, 'XTick', 1:length(selectedFeatures), 'XTickLabel', cleanSelectedLabels, 'XTickLabelRotation', 45);
set(gca, 'YTick', 1:length(selectedFeatures), 'YTickLabel', cleanSelectedLabels);
title('Correlação Cruzada no Subconjunto Final');
axis square;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
saveas(gcf, 'images/feature_selection_summary.png');

%% 4. Criação da Tabela Final Reduzida
data_selected = data_clean(:, [{'Date', 'Time', targetName}, selectedFeatures]);
fprintf('Fase 4 concluída com sucesso.\n');