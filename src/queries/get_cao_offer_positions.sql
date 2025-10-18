-- ------------------------------------------------------------
-- Name: get_offer_positions
-- Databank: CAO-Faktura
-- Description: Returns offer positions matching search criteria with offer headers
-- Parameters:
--   1️⃣  Kundenname    (STRING)  – Customer name search term
--   2️⃣  Bezeichnung   (STRING)  – Position description search term  
--   3️⃣  start_date    (DATE)    – Beginning of the period (inclusive)
--   4️⃣  end_date      (DATE)    – End of the period (inclusive)
--   5️⃣  Ort           (STRING)  – Customer city search term (optional)
--   6️⃣  Strasse       (STRING)  – Customer street search term (optional)
-- ------------------------------------------------------------

SET @kunden_suchstring = {{Kundenname}};
SET @bezeichnung_suchstring = {{Bezeichnung}};
SET @ort_suchstring = COALESCE({{Ort}}, '');
SET @strasse_suchstring = COALESCE({{Strasse}}, '');

SELECT 
    j.REC_ID AS 'Angebot ID',
    jp.VRENUM as 'Angebotsnummer',
    DATE_FORMAT(j.RDATUM, '%d.%m.%Y') as 'Angebotsdatum',
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
    j.STADIUM as 'Status',
    CASE 
        WHEN j.STADIUM = 1 THEN 'In Bearbeitung'
        WHEN j.STADIUM = 2 THEN 'Offen'
        WHEN j.STADIUM = 3 THEN 'Erledigt'
        WHEN j.STADIUM = 8 THEN 'Angenommen mit Skonto'
        WHEN j.STADIUM = 9 THEN 'Angenommen'
        ELSE 'Unbekannt'
    END AS 'Status Text',
    j.WAEHRUNG as 'Währung'
FROM JOURNALPOS jp
INNER JOIN JOURNAL j ON jp.VRENUM = j.VRENUM AND jp.QUELLE = j.QUELLE 
INNER JOIN ADRESSEN ON ADRESSEN.REC_ID = j.ADDR_ID
WHERE 
    jp.QUELLE = 1 
    AND jp.VRENUM NOT LIKE '%storno%'
    -- Dynamische Kundensuche nach allen Wörtern im Suchstring
    AND (
        UPPER(TRIM(CONCAT_WS(' ', ADRESSEN.ANREDE, ADRESSEN.NAME1, ADRESSEN.NAME2, ADRESSEN.NAME3, ADRESSEN.ABTEILUNG))) LIKE CONCAT('%', SUBSTRING_INDEX(@kunden_suchstring, ' ', 1), '%')
        AND (CASE 
            WHEN CHAR_LENGTH(@kunden_suchstring) - CHAR_LENGTH(REPLACE(@kunden_suchstring, ' ', '')) >= 1 THEN
                UPPER(TRIM(CONCAT_WS(' ', ADRESSEN.ANREDE, ADRESSEN.NAME1, ADRESSEN.NAME2, ADRESSEN.NAME3, ADRESSEN.ABTEILUNG))) LIKE CONCAT('%', SUBSTRING_INDEX(SUBSTRING_INDEX(@kunden_suchstring, ' ', 2), ' ', -1), '%')
            ELSE TRUE
        END)
        AND (CASE 
            WHEN CHAR_LENGTH(@kunden_suchstring) - CHAR_LENGTH(REPLACE(@kunden_suchstring, ' ', '')) >= 2 THEN
                UPPER(TRIM(CONCAT_WS(' ', ADRESSEN.ANREDE, ADRESSEN.NAME1, ADRESSEN.NAME2, ADRESSEN.NAME3, ADRESSEN.ABTEILUNG))) LIKE CONCAT('%', SUBSTRING_INDEX(SUBSTRING_INDEX(@kunden_suchstring, ' ', 3), ' ', -1), '%')
            ELSE TRUE
        END)
        AND (CASE 
            WHEN CHAR_LENGTH(@kunden_suchstring) - CHAR_LENGTH(REPLACE(@kunden_suchstring, ' ', '')) >= 3 THEN
                UPPER(TRIM(CONCAT_WS(' ', ADRESSEN.ANREDE, ADRESSEN.NAME1, ADRESSEN.NAME2, ADRESSEN.NAME3, ADRESSEN.ABTEILUNG))) LIKE CONCAT('%', SUBSTRING_INDEX(SUBSTRING_INDEX(@kunden_suchstring, ' ', 4), ' ', -1), '%')
            ELSE TRUE
        END)
    )
    -- Bezeichnungssuche
    AND UPPER(jp.BEZEICHNUNG) LIKE CONCAT('%', UPPER(@bezeichnung_suchstring), '%')
    -- Datumsbereich
    AND j.RDATUM BETWEEN {{start_date}} AND {{end_date}}
    -- Ortsfilter (optional)
    AND (LENGTH(@ort_suchstring) = 0 OR UPPER(j.KUN_ORT) LIKE CONCAT('%', UPPER(@ort_suchstring), '%'))
    -- Straßenfilter (optional)
    AND (LENGTH(@strasse_suchstring) = 0 OR UPPER(j.KUN_STRASSE) LIKE CONCAT('%', UPPER(@strasse_suchstring), '%'))
ORDER BY jp.VRENUM, jp.POSITION;
