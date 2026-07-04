
-- Гипотеза №1: игроки из Азии играют дольше за сессию, но реже (проверка)

SELECT 
    location,
    ROUND(AVG(sessionsperweek), 1) AS avg_sessions_per_week,
    ROUND(AVG(avgsessiondurationminutes), 1) AS avg_session_minutes,
    -- Вычисляем общее время в минутах в неделю
    ROUND(AVG(sessionsperweek * avgsessiondurationminutes), 1) AS avg_total_minutes_weekly
FROM online_gaming_behavior_dataset
GROUP BY location
ORDER BY avg_session_minutes DESC;
/*
Вопреки ожиданиям, региональные различия в игровом поведении оказались минимальны: 
все регионы показывают ~9.5 сессий в неделю и ~95 минут на сессию. Это может указывать на то, 
что в данном датасете региональный фактор не является значимым.
*/

-- Гипотеза №2: cложность игры влияет на траты

WITH difficulty_metrics AS (
    SELECT 
        gamedifficulty,
        COUNT(*) AS player_count,
        ROUND(AVG(playtimehours)::numeric, 2) AS avg_playtimehours,
        ROUND(AVG(100.0 * ingamepurchases), 1) AS purchase_percentage
    FROM online_gaming_behavior_dataset
    GROUP BY gamedifficulty
)
SELECT 
    *,
    -- Считаем, во сколько раз Easy-игроки покупают чаще Hard
    ROUND(MAX(purchase_percentage) OVER() / purchase_percentage, 1) AS relative_purchase_multiplier
FROM difficulty_metrics
ORDER BY player_count DESC;
/*
Анализ показал, что сложность игры не влияет на ключевые метрики: 
среднее время игры и конверсия в покупку одинаковы для всех уровней сложности. 
Единственное отличие — размер аудитории: Easy-игроков в 2.5 раза больше, чем Hard-игроков.
*/

-- Гиптеза №3: достижения влияют на вовлеченность

SELECT 
    engagementlevel,
    ROUND(AVG(achievementsunlocked), 1) AS avg_achievements,
    ROUND(AVG(playerlevel), 1) AS avg_level,
    ROUND(AVG(sessionsperweek), 1) AS avg_sessions_per_week,
    COUNT(*) AS player_count
FROM online_gaming_behavior_dataset
GROUP BY engagementlevel
ORDER BY avg_achievements DESC;
/*
Игроки с высокой вовлеченностью (High) проводят в игре в 3 раза больше сессий, чем Low-игроки (14.3 vs 4.5). 
При этом количество достижений и уровень персонажа у High и Medium почти одинаковы. 
Это говорит о том, что вовлченные игроки чаще заходят в игру.
*/

-- Гипотеза №4: уровень сложности влияет на вовлеченность

SELECT 
    gamedifficulty,
    engagementlevel,
    COUNT(*) AS player_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY gamedifficulty), 1) AS percentage_within_difficulty
FROM online_gaming_behavior_dataset
GROUP BY gamedifficulty, engagementlevel
ORDER BY gamedifficulty, engagementlevel;

/*
 Распределение вовлеченности одинаково для всех уровней сложности: ~26% High, ~26% Low, ~48% Medium везде
 */

-- Гипотеза №5: Мужчины чаще играют в Action и Sports, а женщины — в RPG и Simulation.

SELECT 
    gamegenre,
    gender,
    COUNT(*) AS player_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY gamegenre), 1) AS genre_gender_percentage,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY gender), 1) AS total_genre_gender_percentage
FROM online_gaming_behavior_dataset
GROUP BY gamegenre, gender
ORDER BY gamegenre, gender;

/*
 Во всех жанрах одинаковое соотношение полов: ~60% мужчин, ~40% женщин. Никаких жанровых предпочтений нет.
 */

-- Дополнительно: по возрастным группам
WITH age_groups AS (
    SELECT 
        gamegenre,
        CASE 
            WHEN age <= 25 THEN 'Подростки'
            WHEN age BETWEEN 26 AND 35 THEN 'Миллениалы'
            ELSE 'Зрелые'
        END AS age_group
    FROM online_gaming_behavior_dataset
)
SELECT 
    gamegenre,
    age_group,
    COUNT(*) AS player_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY gamegenre), 1) AS genre_age_percentage,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY age_group), 1) AS total_genre_age_percentage
FROM age_groups
GROUP BY gamegenre, age_group
ORDER BY gamegenre, age_group;

/*
 Распределение по возрасту тоже одинаково для всех жанров.
 */

-- Вывод по гипотезам 

/*
Из пяти проверенных гипотез только одна (о связи достижений и вовлеченности)
показала статистически значимую корреляцию. Остальные гипотезы не подтвердились —
все исследованные факторы (регион, сложность, жанр) не влияют на поведение игроков.

Это может быть связано с синтетической природой датасета, где зависимости 
не были заложены искусственно.
*/