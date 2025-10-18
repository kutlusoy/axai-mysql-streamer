-- queryKey: get_cao_top_customers
-- Databank: CAO-Faktura
-- Description: Top 10 Kunden nach Umsatz (Brutto) im Zeitraum
-- Parameters:
--   :start_date    (DATE) – Beginn des Zeitraums (optional)
--   :end_date      (DATE) – Ende des Zeitraums (optional)
--   :limit         (INT)  – Anzahl der Top-Kunden (optional, Standard: 10)

SELECT
    CONCAT_WS(' ', J.KUN_NAME1, J.KUN_NAME2, J.KUN_NAME3) AS 'Kunde',
    ADRESSEN.KUNNUM1 as 'Kundennummer',
    COUNT(J.REC_ID) AS 'Anzahl_Rechnungen',
    SUM(J.NSUMME) AS 'Netto',
    SUM(J.MSUMME) AS 'MwSt',
    SUM(J.BSUMME) AS 'Brutto'
FROM
    JOURNAL J
    INNER JOIN ADRESSEN ON ADRESSEN.REC_ID = J.ADDR_ID
WHERE
    J.QUELLE IN (3, 4)
    AND J.STADIUM NOT IN (127)
    AND J.RDATUM BETWEEN :start_date AND :end_date
GROUP BY
    J.ADDR_ID, J.KUN_NAME1, J.KUN_NAME2, J.KUN_NAME3, ADRESSEN.KUNNUM1
ORDER BY
    SUM(J.BSUMME) DESC
LIMIT :limit;
