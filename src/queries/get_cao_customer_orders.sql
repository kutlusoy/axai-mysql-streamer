-- ------------------------------------------------------------
-- Name: get_cao_customer_orders
-- Databank: CAO-Faktura
-- Description: Returns all orders for a given customer within a date range.
-- Parameters:
--   1️⃣  Kundenname    (STRING)  – The Cutomername.
--   2️⃣  start_date    (DATE) – Beginning of the period (inclusive).
--   3️⃣  end_date      (DATE) – End of the period (inclusive).
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

-- Annahme: Der Suchstring wird als Variable @suchstring übergeben
-- Beispiel: SET @suchstring = 'Max Mustermann GmbH';

SET @suchstring = '{{Kundenname}}';

SELECT 
    J.REC_ID AS ID,
    CONCAT_WS('', J.QUELLE) AS QUELLE,
    J.AGBNUM AS 'durch Angebot',
    J.VRENUM AS 'Auftragsnummer',
    J.RDATUM AS 'Auftragsdatum',
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
    LEFT OUTER JOIN KARTEN K ON (K.ID = ADRESSEN.REC_ID AND K.TYP = 'K')
    LEFT OUTER JOIN LAND L ON L.ID = ADRESSEN.LAND
    LEFT JOIN VERTRETER V ON V.VERTRETER_ID = ADRESSEN.VERTRETER_ID
    LEFT JOIN MITARBEITER M ON M.MA_ID = ADRESSEN.MA_ID
WHERE 
    J.QUELLE = 8 
    AND J.STADIUM <> 127 
    AND J.TERM_ID <> 99999 
    -- Dynamische Suche nach allen Wörtern im Suchstring
    AND (
        -- Prüfe ob alle Wörter aus dem Suchstring im Kundennamen vorkommen
        UPPER(TRIM(CONCAT_WS(' ', ADRESSEN.ANREDE, ADRESSEN.NAME1, ADRESSEN.NAME2, ADRESSEN.NAME3, ADRESSEN.ABTEILUNG))) LIKE CONCAT('%', SUBSTRING_INDEX(@suchstring, ' ', 1), '%')
        AND (CASE 
            WHEN CHAR_LENGTH(@suchstring) - CHAR_LENGTH(REPLACE(@suchstring, ' ', '')) >= 1 THEN
                UPPER(TRIM(CONCAT_WS(' ', ADRESSEN.ANREDE, ADRESSEN.NAME1, ADRESSEN.NAME2, ADRESSEN.NAME3, ADRESSEN.ABTEILUNG))) LIKE CONCAT('%', SUBSTRING_INDEX(SUBSTRING_INDEX(@suchstring, ' ', 2), ' ', -1), '%')
            ELSE TRUE
        END)
        AND (CASE 
            WHEN CHAR_LENGTH(@suchstring) - CHAR_LENGTH(REPLACE(@suchstring, ' ', '')) >= 2 THEN
                UPPER(TRIM(CONCAT_WS(' ', ADRESSEN.ANREDE, ADRESSEN.NAME1, ADRESSEN.NAME2, ADRESSEN.NAME3, ADRESSEN.ABTEILUNG))) LIKE CONCAT('%', SUBSTRING_INDEX(SUBSTRING_INDEX(@suchstring, ' ', 3), ' ', -1), '%')
            ELSE TRUE
        END)
        AND (CASE 
            WHEN CHAR_LENGTH(@suchstring) - CHAR_LENGTH(REPLACE(@suchstring, ' ', '')) >= 3 THEN
                UPPER(TRIM(CONCAT_WS(' ', ADRESSEN.ANREDE, ADRESSEN.NAME1, ADRESSEN.NAME2, ADRESSEN.NAME3, ADRESSEN.ABTEILUNG))) LIKE CONCAT('%', SUBSTRING_INDEX(SUBSTRING_INDEX(@suchstring, ' ', 4), ' ', -1), '%')
            ELSE TRUE
        END)
    )
    AND J.RDATUM BETWEEN STR_TO_DATE(@start_date_formatted, '%Y-%m-%d') AND STR_TO_DATE(@end_date_formatted, '%Y-%m-%d')
    AND J.STADIUM BETWEEN 1 AND 127
GROUP BY 
    J.REC_ID
ORDER BY 
    J.RDATUM DESC;
