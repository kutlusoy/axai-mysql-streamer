-- queryKey: get_cao_payment_status
-- Databank: CAO-Faktura
-- Description: Zahlungsstatus-Übersicht (offen, bezahlt, gemahnt etc.)
-- Parameters:
--   :start_date    (DATE) – Beginn des Zeitraums (optional)
--   :end_date      (DATE) – Ende des Zeitraums (optional)

SELECT
    CASE 
        WHEN J.STADIUM = 0 THEN 'In Bearbeitung'
        WHEN J.STADIUM = 1 THEN 'Lieferschein gedruckt'
        WHEN J.STADIUM = 2 THEN 'Offen'
        WHEN J.STADIUM = 3 THEN '1x gemahnt'
        WHEN J.STADIUM = 4 THEN '2x gemahnt'
        WHEN J.STADIUM = 5 THEN '3x gemahnt'
        WHEN J.STADIUM = 6 THEN 'INKASSO'
        WHEN J.STADIUM = 7 THEN 'Teilzahlung'
        WHEN J.STADIUM = 8 THEN 'Bezahlt mit Skonto'
        WHEN J.STADIUM = 9 THEN 'Bezahlt'
        WHEN J.STADIUM = 11 THEN 'Angewiesen'
        WHEN J.STADIUM = 127 THEN 'Storno'
        ELSE 'Unbekannt'
    END AS 'Status',
    COUNT(J.REC_ID) AS 'Anzahl',
    SUM(J.BSUMME) AS 'Brutto_Summe'
FROM
    JOURNAL J
WHERE
    J.QUELLE IN (3, 4)
    AND J.RDATUM BETWEEN :start_date AND :end_date
GROUP BY
    J.STADIUM
ORDER BY
    SUM(J.BSUMME) DESC;
