-- ------------------------------------------------------------
-- queryKey: get_cao_order_positions
-- Databank: CAO-Faktura
-- Description: Returns order positions matching search criteria with order headers
-- Parameters:
--   1️⃣  Kundenname    (STRING)  – Customer name search term
--   2️⃣  Bezeichnung   (STRING)  – Position description search term  
--   3️⃣  start_date    (DATE)    – Beginning of the period (inclusive)
--   4️⃣  end_date      (DATE)    – End of the period (inclusive)
--   5️⃣  Ort           (STRING)  – Customer city search term (optional)
--   6️⃣  Strasse       (STRING)  – Customer street search term (optional)
-- ------------------------------------------------------------

SELECT 
    j.REC_ID AS 'Auftrags ID',
    jp.VRENUM as 'Auftragsnummer',
    DATE_FORMAT(j.RDATUM, '%d.%m.%Y') as 'Auftrags Datum',
    j.KUN_NUM as 'Kundennummer',
    CONCAT_WS(' ', j.KUN_NAME1, j.KUN_NAME2, j.KUN_NAME3) as 'Kundenname',
    j.KUN_ORT as 'Kunden Ort',
    j.KUN_STRASSE as 'Kunden Straße',
    jp.POSITION as 'Pos',
    FORMAT(jp.MENGE,2) as 'Menge',
    jp.ME_EINHEIT as 'Einheit',
    FORMAT(jp.EPREIS,2) as 'Einzelpreis',
    FORMAT(jp.GPREIS,2) as 'Gesamtpreis',
    jp.BEZEICHNUNG as 'Bezeichnung',
    j.STADIUM as 'Stadium',
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
    j.WAEHRUNG as 'Währung'
FROM JOURNALPOS jp
INNER JOIN JOURNAL j ON jp.VRENUM = j.VRENUM AND jp.QUELLE = j.QUELLE 
INNER JOIN ADRESSEN ON ADRESSEN.REC_ID = j.ADDR_ID
WHERE 
    jp.QUELLE = 8
    AND jp.VRENUM NOT LIKE '%storno%'
    -- Dynamische Kundensuche nach allen Wörtern im Suchstring
    AND (
        UPPER(TRIM(CONCAT_WS(' ', ADRESSEN.ANREDE, ADRESSEN.NAME1, ADRESSEN.NAME2, ADRESSEN.NAME3, ADRESSEN.ABTEILUNG))) LIKE CONCAT('%', :word1, '%')
        AND (:word2 IS NULL OR UPPER(TRIM(CONCAT_WS(' ', ADRESSEN.ANREDE, ADRESSEN.NAME1, ADRESSEN.NAME2, ADRESSEN.NAME3, ADRESSEN.ABTEILUNG))) LIKE CONCAT('%', :word2, '%'))
        AND (:word3 IS NULL OR UPPER(TRIM(CONCAT_WS(' ', ADRESSEN.ANREDE, ADRESSEN.NAME1, ADRESSEN.NAME2, ADRESSEN.NAME3, ADRESSEN.ABTEILUNG))) LIKE CONCAT('%', :word3, '%'))
        AND (:word4 IS NULL OR UPPER(TRIM(CONCAT_WS(' ', ADRESSEN.ANREDE, ADRESSEN.NAME1, ADRESSEN.NAME2, ADRESSEN.NAME3, ADRESSEN.ABTEILUNG))) LIKE CONCAT('%', :word4, '%'))
    )
    -- Bezeichnungssuche
    AND UPPER(jp.BEZEICHNUNG) LIKE CONCAT('%', :Bezeichnung, '%')
    -- Datumsbereich
    AND j.RDATUM BETWEEN :start_date AND :end_date
    -- Ortsfilter (optional)
    AND (:Ort IS NULL OR UPPER(j.KUN_ORT) LIKE CONCAT('%', :Ort, '%'))
    -- Straßenfilter (optional)
    AND (:Strasse IS NULL OR UPPER(j.KUN_STRASSE) LIKE CONCAT('%', :Strasse, '%'))
ORDER BY jp.VRENUM, jp.POSITION;
