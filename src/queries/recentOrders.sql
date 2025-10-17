-- queryKey: recentOrders
SELECT
    o.id,
    o.user_id,
    u.name AS user_name,
    o.total,
    o.created_at
FROM orders o
JOIN users u ON o.user_id = u.id
WHERE o.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY o.created_at DESC
LIMIT 100;
