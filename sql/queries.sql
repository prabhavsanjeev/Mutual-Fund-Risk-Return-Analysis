-- Query 1: Average risk and return by category
SELECT 
    category,
    ROUND(AVG(sd), 2) AS avg_risk,
    ROUND(AVG(returns_3yr), 2) AS avg_return_3yr,
    ROUND(AVG(sharpe), 2) AS avg_sharpe
FROM funds
GROUP BY category
ORDER BY avg_sharpe DESC;


-- Query 2: CTE - Top 5 funds per category by Sharpe ratio
WITH ranked_funds AS (
    SELECT 
        scheme_name,
        category,
        sharpe,
        returns_3yr,
        RANK() OVER (PARTITION BY category ORDER BY sharpe DESC) AS rank_in_category
    FROM funds
    WHERE fund_size_cr >= 100
)
SELECT * FROM ranked_funds
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category;

-- Query 3: JOIN - Risk level with readable labels
CREATE TABLE IF NOT EXISTS risk_labels (
    risk_level INTEGER,
    risk_label TEXT
);

DELETE FROM risk_labels;

INSERT INTO risk_labels VALUES 
(1, 'Low Risk'),
(2, 'Low to Moderate'),
(3, 'Moderate'),
(4, 'Moderately High'),
(5, 'High'),
(6, 'Very High');

SELECT 
    r.risk_label,
    COUNT(*) AS total_funds,
    ROUND(AVG(f.returns_3yr), 2) AS avg_return_3yr,
    ROUND(AVG(f.sharpe), 2) AS avg_sharpe
FROM funds f
JOIN risk_labels r ON f.risk_level = r.risk_level
GROUP BY r.risk_label
ORDER BY f.risk_level;

-- Query 4: Does expense ratio affect returns?
SELECT 
    CASE 
        WHEN expense_ratio < 0.5 THEN 'Low Expense (<0.5%)'
        WHEN expense_ratio BETWEEN 0.5 AND 1.0 THEN 'Medium Expense (0.5-1%)'
        ELSE 'High Expense (>1%)'
    END AS expense_category,
    COUNT(*) AS total_funds,
    ROUND(AVG(returns_3yr), 2) AS avg_return_3yr,
    ROUND(AVG(sharpe), 2) AS avg_sharpe
FROM funds
GROUP BY expense_category
ORDER BY avg_return_3yr DESC;


-- Query 5: Top AMCs by average Sharpe ratio (min 10 funds)
SELECT 
    amc_name,
    COUNT(*) AS total_funds,
    ROUND(AVG(sharpe), 2) AS avg_sharpe,
    ROUND(AVG(returns_3yr), 2) AS avg_return_3yr
FROM funds
GROUP BY amc_name
HAVING COUNT(*) >= 10
ORDER BY avg_sharpe DESC
LIMIT 10;