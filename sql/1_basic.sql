
-- 1. Базовая статистика: размер данных и распределение

-- Общее количество записей 
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT playerid) AS unique_players
FROM online_gaming_behavior_dataset;

-- 2. Демографический портер: пол, возраст, регион

-- 2.1 Распределение по полу 
SELECT 
    gender,
    COUNT(*) AS player_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM online_gaming_behavior_dataset
GROUP BY gender
ORDER BY player_count DESC;
-- Вывод: Male = 59.8%, Female = 40.2%

-- 2.2 Распределение по возрасту 
SELECT 
    CASE 
        WHEN age BETWEEN 15 AND 25 THEN '15-25 (Подростки)'
        WHEN age BETWEEN 26 AND 35 THEN '26-35 (Миллениалы)'
        WHEN age BETWEEN 36 AND 45 THEN '36-45 (Зрелые)'
        ELSE '46-49 (Старшие)'
    END AS age_group,
    COUNT(*) AS player_count
FROM online_gaming_behavior_dataset
GROUP BY age_group
ORDER BY age_group;

-- 2.3 Топ-3 регионов по количеству игроков
SELECT 
    location,
    COUNT(*) AS player_count
FROM online_gaming_behavior_dataset
GROUP BY location
ORDER BY player_count DESC
LIMIT 3; -- USA, Europe, Asia

-- 3. Вывод по итогам
/*
ВЫВОД:
1. Гендерное распределение: мужчины составляют ~60% аудитории.
2. Возраст игроков относительно равномерно распределен в диапазоне 15-49 лет.
3. Основные рынки: США (40%), Европа (30%), Азия (20%) — это позволяет строить 
   регионализированные гипотезы на следующих этапах.
*/