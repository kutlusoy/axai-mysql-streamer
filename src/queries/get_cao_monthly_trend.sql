-- queryKey: get_cao_monthly_trend
-- Databank: CAO-Faktura
-- Description: Monatlicher Umsatztrend mit Wachstumsrate
-- Parameters:
--   :start_date    (DATE) – Beginn des Zeitraums (optional)
--   :end_date      (DATE) – Ende des Zeitraums (optional)

SELECT
    Monat,
    Anzahl_Rechnungen,
    Brutto_Umsatz,
    LAG(Brutto_Umsatz) OVER (ORDER BY Monat) AS Vorheriger_Monat,
    ROUND(
        (Brutto_Umsatz - LAG(Brutto_Umsatz) OVER (ORDER BY Monat)) 
        / NULLIF(LAG(Brutto_Umsatz) OVER (ORDER BY Monat), 0) * 100, 2
    ) AS Wachstum_Prozent
FROM (
    SELECT
        DATE_FORMAT(J.RDATUM, '%Y-%m') AS Monat,
        COUNT(J.REC_ID) AS Anzahl_Rechnungen,
        SUM(J.BSUMME) AS Brutto_Umsatz
    FROM
        JOURNAL J
    WHERE
        J.QUELLE IN (3, 4)
        AND J.STADIUM NOT IN (127)
    AND J.RDATUM BETWEEN :start_date AND :end_date
    GROUP BY
        DATE_FORMAT(J.RDATUM, '%Y-%m')
) AS MonthlyData
ORDER BY Monat;