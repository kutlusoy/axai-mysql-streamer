-- queryKey: usersByCountry
SELECT
    id,
    name,
    email,
    country,
    created_at
FROM users
WHERE country = ?;
