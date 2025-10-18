-- ------------------------------------------------------------
-- Name: get_order_positions
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

-- Datumsformatierung für verschiedene Eingabeformate
SET @start_input = '{{start_date}}';
SET @end_input = '{{end_date}}';

-- Funktion zur Erkennung und Umwandlung verschiedener Datumsformate
SET @start_date_formatted = CASE
    -- Format: DD.MM.YYYY -> YYYY-MM-DD
    WHEN @start_input REGEXP '^[0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}$' THEN
        DATE_FORMAT(STR_TO_DATE(@start_input, '%d.%m.%Y'), '%Y-%m-%d')
    -- Format: YYYY-MM-DD (bereits korrekt)
    WHEN @start_input REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN
        @start_input
    -- Format: YYYY-MM (ergänze zum Monatsende)
    WHEN @start_input REGEXP '^[0-9]{4}-[0-9]{2}$' THEN
        DATE_FORMAT(LAST_DAY(CONCAT(@start_input, '-01')), '%Y-%m-%d')
    -- Standard: Eingabe direkt verwenden (kann angepasst werden)
    ELSE @start_input
END;

SET @end_date_formatted = CASE
    -- Format: DD.MM.YYYY -> YYYY-MM-DD
    WHEN @end_input REGEXP '^[0-9]{1,2}\\.[0-9]{1,2}\\.[0-9]{4}$' THEN
        DATE_FORMAT(STR_TO_DATE(@end_input, '%d.%m.%Y'), '%Y-%m-%d')
    -- Format: YYYY-MM-DD (bereits korrekt)
    WHEN @end_input REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN
        @end_input
    -- Format: YYYY-MM (ergänze zum Monatsende)
    WHEN @end_input REGEXP '^[0-9]{4}-[0-9]{2}$' THEN
        DATE_FORMAT(LAST_DAY(CONCAT(@end_input, '-01')), '%Y-%m-%d')
    -- Standard: Eingabe direkt verwenden
    ELSE @end_input
END;

SET @kunden_suchstring = '{{Kundenname}}';
SET @bezeichnung_suchstring = '{{Bezeichnung}}';
SET @ort_suchstring = COALESCE('{{Ort}}', '');
SET @strasse_suchstring = COALESCE('{{Strasse}}', '');

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
    jp.QUELLE = 3 
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
    AND j.RDATUM BETWEEN STR_TO_DATE(@start_date_formatted, '%Y-%m-%d') AND STR_TO_DATE(@end_date_formatted, '%Y-%m-%d')
    -- Ortsfilter (optional)
    AND (LENGTH(@ort_suchstring) = 0 OR UPPER(j.KUN_ORT) LIKE CONCAT('%', UPPER(@ort_suchstring), '%'))
    -- Straßenfilter (optional)
    AND (LENGTH(@strasse_suchstring) = 0 OR UPPER(j.KUN_STRASSE) LIKE CONCAT('%', UPPER(@strasse_suchstring), '%'))
ORDER BY jp.VRENUM, jp.POSITION;
