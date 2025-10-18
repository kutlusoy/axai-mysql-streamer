-- ------------------------------------------------------------
-- Name: get_cao_customer_invoices
-- Databank: CAO-Faktura
-- Description: Returns all invoices for a given customer within a date range.
-- Parameters:
--   1️⃣  Kundenname    (STRING)  – The Cutomername.
--   2️⃣  start_date    (DATE) – Beginning of the period (inclusive).
--   3️⃣  end_date      (DATE) – End of the period (inclusive).
-- ------------------------------------------------------------

SELECT 
    J.REC_ID AS ID,
    CONCAT_WS('', J.QUELLE) AS QUELLE,
    J.AGBNUM AS 'initial Angebot',
    J.ATRNUM AS 'initial Auftrag',
    J.VRENUM AS 'Rechnungsnummer',
    J.RDATUM AS 'Rechnungsdatum',
    CONCAT_WS(' ', J.KUN_NAME1, J.KUN_NAME2, J.KUN_NAME3) AS 'Kunden Name',
    J.ADDR_ID as 'Adressen ID',
    J.NSUMME as 'Netto Summe',
    J.MSUMME as 'Mehrwertsteuer',
    J.BSUMME as 'Brutto Summe',
    J.STADIUM as 'Stadium',
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
        WHEN J.STADIUM = 11 THEN 'Angewiesen (Überweisung/Lastschrift)'
        WHEN J.STADIUM = 127 THEN 'Storno'
        ELSE 'Unbekannt'
    END AS 'Stadium Text',
    J.PROJEKT as Projekt,
    J.ORGNUM as 'Kunden Bestellnummer',
    J.WAEHRUNG as 'Währung',
    CONCAT(
        TRIM(CONCAT_WS(' ', AD.ANREDE, AD.NAME1, AD.NAME2, AD.NAME3)), 
        ', ', 
        AD.STRASSE, 
        ', ', 
        AD.LAND, 
        ' ', 
        AD.PLZ, 
        ' ', 
        AD.ORT
    ) AS 'Lieferanschrift',
    ADRESSEN.KUNNUM1 as 'Kundennummer',
    TRIM(BOTH ', ' FROM CONCAT_WS('', 
        IF(ADRESSEN.NAME1 IS NULL OR TRIM(ADRESSEN.NAME1) = '', '', CONCAT(ADRESSEN.NAME1, ', ')),
        IF(ADRESSEN.NAME2 IS NULL OR TRIM(ADRESSEN.NAME2) = '', '', CONCAT(ADRESSEN.NAME2, ', ')),
        IF(ADRESSEN.NAME3 IS NULL OR TRIM(ADRESSEN.NAME3) = '', '', CONCAT(ADRESSEN.NAME3, ', '))
    )) AS KUNDENSTRING
FROM 
    JOURNAL J
    LEFT JOIN JOURNALPOS JP ON JP.JOURNAL_ID = J.REC_ID
    LEFT OUTER JOIN ADRESSEN_LIEF AD ON AD.REC_ID = J.LIEF_ADDR_ID
    INNER JOIN ADRESSEN ON ADRESSEN.REC_ID = J.ADDR_ID
WHERE 
    J.QUELLE IN (3, 4) 
    AND J.STADIUM <> 127 
    AND J.TERM_ID <> 99999 
    -- Dynamische Suche nach allen Wörtern im Suchstring
    AND (
        -- Prüfe ob alle Wörter aus dem Suchstring im Kundennamen vorkommen
        UPPER(TRIM(CONCAT_WS(' ', ADRESSEN.ANREDE, ADRESSEN.NAME1, ADRESSEN.NAME2, ADRESSEN.NAME3, ADRESSEN.ABTEILUNG))) LIKE CONCAT('%', :word1, '%')
        AND (:word2 IS NULL OR UPPER(TRIM(CONCAT_WS(' ', ADRESSEN.ANREDE, ADRESSEN.NAME1, ADRESSEN.NAME2, ADRESSEN.NAME3, ADRESSEN.ABTEILUNG))) LIKE CONCAT('%', :word2, '%'))
        AND (:word3 IS NULL OR UPPER(TRIM(CONCAT_WS(' ', ADRESSEN.ANREDE, ADRESSEN.NAME1, ADRESSEN.NAME2, ADRESSEN.NAME3, ADRESSEN.ABTEILUNG))) LIKE CONCAT('%', :word3, '%'))
        AND (:word4 IS NULL OR UPPER(TRIM(CONCAT_WS(' ', ADRESSEN.ANREDE, ADRESSEN.NAME1, ADRESSEN.NAME2, ADRESSEN.NAME3, ADRESSEN.ABTEILUNG))) LIKE CONCAT('%', :word4, '%'))
    )
    AND J.RDATUM BETWEEN :start_date AND :end_date
    AND J.STADIUM BETWEEN 1 AND 127
GROUP BY 
    J.REC_ID
ORDER BY 
    J.RDATUM DESC;
