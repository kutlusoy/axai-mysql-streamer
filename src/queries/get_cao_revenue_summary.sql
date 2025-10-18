-- queryKey: get_cao_revenue_summary
-- Databank: CAO-Faktura
-- Description: Liefert Umsatzzusammenfassung (Netto, MwSt, Brutto) nach Monat/Quartal/Jahr
-- Parameters:
--   :start_date    (DATE) – Beginn des Zeitraums (optional, Standard: 01.01.aktuelles Jahr)
--   :end_date      (DATE) – Ende des Zeitraums (optional, Standard: 31.12.aktuelles Jahr)
--   :group_by      (STRING) – 'month', 'quarter', 'year' (optional, Standard: 'month')

SELECT
    CASE
        WHEN :group_by = 'year' THEN DATE_FORMAT(J.RDATUM, '%Y')
        WHEN :group_by = 'quarter' THEN CONCAT(DATE_FORMAT(J.RDATUM, '%Y'), '-Q', QUARTER(J.RDATUM))
        ELSE DATE_FORMAT(J.RDATUM, '%Y-%m')
    END AS 'Periode',
    COUNT(DISTINCT J.REC_ID) AS 'Anzahl_Rechnungen',
    SUM(J.NSUMME) AS 'Netto',
    SUM(J.MSUMME) AS 'MwSt',
    SUM(J.BSUMME) AS 'Brutto'
FROM
    JOURNAL J
WHERE
    J.QUELLE IN (3, 4) -- Rechnungen
    AND J.STADIUM NOT IN (127) -- ausgenommen storniert
    AND J.RDATUM BETWEEN :start_date AND :end_date
GROUP BY
    CASE
        WHEN :group_by = 'year' THEN DATE_FORMAT(J.RDATUM, '%Y')
        WHEN :group_by = 'quarter' THEN CONCAT(DATE_FORMAT(J.RDATUM, '%Y'), '-Q', QUARTER(J.RDATUM))
        ELSE DATE_FORMAT(J.RDATUM, '%Y-%m')
    END
ORDER BY
    MIN(J.RDATUM);
