
DROP TABLE IF EXISTS powerbi_dashboard;


CREATE TABLE powerbi_dashboard AS
SELECT 
    -- Срезы для фильтрации
    location,
    gender,
    CASE 
        WHEN age <= 25 THEN 'Подростки (15-25)'
        WHEN age BETWEEN 26 AND 35 THEN 'Миллениалы (26-35)'
        ELSE 'Зрелые (36+)'
    END AS age_group,
    gamegenre,
    gamedifficulty,
    engagementlevel,
    
    -- Количество игроков в этом срезе
    COUNT(DISTINCT playerid) AS players_count,
    
    -- Суммы (для расчета процентов)
    SUM(ingamepurchases) AS total_purchases,
    SUM(playtimehours) AS total_playtime_hours,
    SUM(sessionsperweek) AS total_sessions,
    
    -- Средние 
    ROUND(AVG(playtimehours)::numeric, 2) AS avg_playtime_hours,
    ROUND(AVG(sessionsperweek)::numeric, 1) AS avg_sessions_per_week,
    ROUND(AVG(avgsessiondurationminutes)::numeric, 1) AS avg_session_minutes,
    ROUND(AVG(achievementsunlocked)::numeric, 1) AS avg_achievements,
    ROUND(AVG(playerlevel)::numeric, 1) AS avg_player_level

FROM online_gaming_behavior_dataset
GROUP BY 
    location,
    gender,
    CASE 
        WHEN age <= 25 THEN 'Подростки (15-25)'
        WHEN age BETWEEN 26 AND 35 THEN 'Миллениалы (26-35)'
        ELSE 'Зрелые (36+)'
    END,
    gamegenre,
    gamedifficulty,
    engagementlevel;

-- Проверяем данные

-- Сколько строк 
SELECT COUNT(*) AS total_rows FROM powerbi_dashboard;

-- Проверяем, что общее количество игроков совпадает с исходным
SELECT 
    SUM(players_count) AS total_players,
    SUM(total_purchases) AS total_purchases
FROM powerbi_dashboard;

-- Смотрим структуру
SELECT * FROM powerbi_dashboard LIMIT 5;


-- Создаем индексы для ускорения

CREATE INDEX idx_pbi_location ON powerbi_dashboard(location);
CREATE INDEX idx_pbi_gender ON powerbi_dashboard(gender);
CREATE INDEX idx_pbi_engagement ON powerbi_dashboard(engagementlevel);
CREATE INDEX idx_pbi_genre ON powerbi_dashboard(gamegenre);
