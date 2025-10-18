-- queryKey: get_cao_top_products
-- Databank: CAO-Faktura
-- Description: Top 10 Produkte/Positionen nach Umsatz (Brutto)
-- Parameters:
--   :start_date    (DATE) – Beginn des Zeitraums (optional)
--   :end_date      (DATE) – Ende des Zeitraums (optional)
--   :limit         (INT)  – Anzahl der Top-Produkte (optional, Standard: 10)

SELECT
    jp.BEZEICHNUNG AS 'Produkt',
    COUNT(jp.REC_ID) AS 'Anzahl_Verkäufe',
    SUM(jp.MENGE) AS 'Gesamtmenge',
    SUM(jp.GPREIS) AS 'Brutto_Umsatz',
    AVG(jp.EPREIS) AS 'Durchschnittspreis'
FROM
    JOURNALPOS jp
    INNER JOIN JOURNAL j ON jp.VRENUM = j.VRENUM AND jp.QUELLE = j.QUELLE
WHERE
    jp.QUELLE IN (3, 4)
    AND j.STADIUM NOT IN (127)
    AND j.RDATUM BETWEEN :start_date AND :end_date
    AND jp.VRENUM NOT LIKE '%storno%'
GROUP BY
    jp.BEZEICHNUNG
ORDER BY
    SUM(jp.GPREIS) DESC
LIMIT :limit;
