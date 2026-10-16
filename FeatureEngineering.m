%% Fase 5: Feature Engineering
fprintf('\n--- A Iniciar Engenharia de Atributos ---\n');

% Assume 'data_clean' (normalizada) e 'data_clipped' (escalas reais) em memória
y = data_clean.(targetName);

%% 1. Extração Robusta da Hora do Dia
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

%% 2. Engenharia de Novos Atributos
% Atributo 1 e 2: Transformação Cíclica Temporal (Seno e Cosseno da Hora)
% Evita a descontinuidade artificial entre 23:00 e 00:00 numa rede neuronal
hour_sin = sin(2 * pi * hoursArr / 24);
hour_cos = cos(2 * pi * hoursArr / 24);

% Atributo 3: Rácio Químico Sensorial (PT08.S1 / PT08.S3)
% Combina o sensor alvo de CO com o sensor oxidante inverso, amplificando o contraste
ratio_s1_s3 = data_clipped.PT08_S1_CO_ ./ (data_clipped.PT08_S3_NOx_ + eps);

% Normalização Min-Max dos novos atributos para compatibilidade com redes neuronais
ratio_s1_s3_norm = (ratio_s1_s3 - min(ratio_s1_s3)) / (max(ratio_s1_s3) - min(ratio_s1_s3));
hour_sin_norm = (hour_sin + 1) / 2; % mapear de [-1, 1] para [0, 1]
hour_cos_norm = (hour_cos + 1) / 2;

%% 3. Avaliação Estatística da Informação Adicionada
r_sin = corr(hour_sin, y, 'Type', 'Pearson');
r_cos = corr(hour_cos, y, 'Type', 'Pearson');
r_ratio = corr(ratio_s1_s3, y, 'Type', 'Pearson');
rho_ratio = corr(ratio_s1_s3, y, 'Type', 'Spearman');

fprintf('\n--- Avaliação dos Novos Atributos Engenheirados ---\n');
fprintf('Hour_Sin         -> Pearson r: %.4f\n', r_sin);
fprintf('Hour_Cos         -> Pearson r: %.4f\n', r_cos);
fprintf('Ratio_S1_S3      -> Pearson r: %.4f | Spearman rho: %.4f\n', r_ratio, rho_ratio);

%% 4. Visualizações dos Novos Atributos
figure('Color', 'w', 'Position', [100, 100, 950, 420]);

% Subplot 1: Representação Cíclica 24h no Plano Trigonométrico
subplot(1, 2, 1);
scatter(hour_sin, hour_cos, 25, hoursArr, 'filled');
colormap(gca, 'hsv');
c = colorbar;
c.Label.String = 'Hora do Dia (0-23h)';
xlabel('sen(2\pi \times Hora / 24)');
ylabel('cos(2\pi \times Hora / 24)');
title('Codificação Cíclica Contínua do Tempo');
axis equal; grid on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');

% Subplot 2: Relação entre o Rácio Químico PT08.S1/PT08.S3 e CO(GT)
subplot(1, 2, 2);
scatter(ratio_s1_s3, y, 10, [0.15 0.5 0.35], 'filled', 'MarkerFaceAlpha', 0.3);
hold on;
p_ratio = polyfit(ratio_s1_s3, y, 1);
x_range = linspace(min(ratio_s1_s3), max(ratio_s1_s3), 100);
plot(x_range, polyval(p_ratio, x_range), 'r-', 'LineWidth', 2);
xlabel('Rácio PT08.S1 / PT08.S3');
ylabel('CO(GT) [mg/m^3]');
title(sprintf('Rácio Sensorial vs CO(GT) (r = %.2f)', r_ratio));
grid on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');

saveas(gcf, 'images/feature_engineering_analysis.png');

%% 5. Consolidação na Tabela Final de Dados
data_clean.Hour_Sin = hour_sin_norm;
data_clean.Hour_Cos = hour_cos_norm;
data_clean.Ratio_S1_S3 = ratio_s1_s3_norm;

fprintf('Fase 5 concluída com sucesso.\n');