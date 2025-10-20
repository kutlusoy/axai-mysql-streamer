# AnythingLLM Flow Templates
Use the templates to get formated and exact results for the *SQL* queries.

---
## <center>For *get_cao_customer_invoices*</center>

### Flow Information
---
**Flow Name:** CaoCustomerInvoices

**Description**
```
Suche nach Rechnungen. Zeige alle in einer Tabelle. Sei exakt wenn es um die Anzahl, Summen und andere Details geht. Du wirst nicht von den extrahierten Daten abweichen. Das ist sehr wichtig. 

Diese Abfrage nur durchführen, wenn ein Kundenname angegeben wird oder in der Unterhaltung vorher angegeben war.

Datumsformat: 2025-10-29 00:00:00
```

### Flow Variables
---
**Variables:**

|Variable name|Initial value|
|-------------|-------------|
|Kundenname:|(empty)|
|start_date:|(empty)|
|end_date:| (empty)|


### API Call
---
|Api call|         |
|--------|---------|
|**URL:**|http://host.docker.internal:3000/run|
|**Method:**|Post|

**Request Body:**
```
{
   "queryKey": "get_cao_customer_invoices",
   "parameters": {
      "Kundenname": "${Kundenname}",
      "start_date": "${start_date}",
      "end_date": "${end_date}"
   }
}
```
---
## For *get_cao_customer_orders*

### Flow Information
---
**Flow Name:** CaoCustomerOrders

**Description**
```
Suche nach Aufträge. Zeige alle in einer Tabelle. Sei exakt wenn es um die Anzahl, Summen und andere Details geht. Du wirst nicht von den extrahierten Daten abweichen. Das ist sehr wichtig. 

Diese Abfrage nur durchführen, wenn ein Kundenname angegeben wird oder in der Unterhaltung vorher angegeben war.

Datumsformat: 2025-10-29 00:00:00
```

### Flow Variables
---
**Variables:**

|Variable name|Initial value|
|-------------|-------------|
|Kundenname:|(empty)|
|start_date:|(empty)|
|end_date:| (empty)|


### API Call
---
|Api call|         |
|--------|---------|
|**URL:**|http://host.docker.internal:3000/run|
|**Method:**|Post|

**Request Body:**
```
{
   "queryKey": "get_cao_customer_orders",
   "parameters": {
      "Kundenname": "${Kundenname}",
      "start_date": "${start_date}",
      "end_date": "${end_date}"
   }
}
```
---
## For *get_cao_customer_offers*

### Flow Information
---
**Flow Name:** CaoCustomerOffers

**Description**
```
Suche nach Angebote. Zeige alle in einer Tabelle. Sei exakt wenn es um die Anzahl, Summen und andere Details geht. Du wirst nicht von den extrahierten Daten abweichen. Das ist sehr wichtig. 

Diese Abfrage nur durchführen, wenn ein Kundenname angegeben wird oder in der Unterhaltung vorher angegeben war.

Datumsformat: 2025-10-29 00:00:00
```

### Flow Variables
---
**Variables:**

|Variable name|Initial value|
|-------------|-------------|
|Kundenname:|(empty)|
|start_date:|(empty)|
|end_date:| (empty)|


### API Call
---
|Api call|         |
|--------|---------|
|**URL:**|http://host.docker.internal:3000/run|
|**Method:**|Post|

**Request Body:**
```
{
   "queryKey": "get_cao_customer_offers",
   "parameters": {
      "Kundenname": "${Kundenname}",
      "start_date": "${start_date}",
      "end_date": "${end_date}"
   }
}
```
---

## For *get_cao_invoice_positions*

### Flow Information
---
**Flow Name:** CaoCustomerInvoicePositions

**Description**
```
Suche nach Text in Bezeichnungen der einzelnen Rechnungspositionen. In der Bezeichnung findest du Artikeldaten, Objekt und Objektadressen, Bestellnummer der Kunden, Durchführungsdatum, Leistungen,  eventuelle Regiestunden und wie viel Personen jeweils wie lange gearbeitet haben. Zeige alle Positionen dieser Rechnung (sortiert nach POS) in einer Tabelle.

Die Rechnungsnummer steht in den einzelnen Positionen immer dabei. Du wirst diese immer mit angeben.

Du wirst alle anderen Details zur Verfügung stellen.

Wenn kein Kunde angegeben, dass Wildcard % nutzen um alle zu durchsuchen.

Ort und Strasse sind optional aber können auch verlangt werden.

Sei exakt wenn es um die Anzahl, Summen und andere Details geht. Du wirst nicht von den extrahierten Daten abweichen. Das ist sehr wichtig. 

Diese Abfrage nur durchführen, wenn ein Kundenname angegeben wird oder in der Unterhaltung vorher angegeben war.

Datumsformat: 2025-10-29 00:00:00
```

### Flow Variables
---
**Variables:**

|Variable name|Initial value|
|-------------|-------------|
|Kundenname:|(empty)|
|Bezeichnung:|(empty)|
|start_date:|(empty)|
|end_date:| (empty)|
|Ort:|(empty)|
|Straße:|(empty)|

Note: City and street refer to invoice header information. If you're searching for streets or addresses in the *Bezeichnung*, you must specify this in the wording (example: search for Vienna in the *Bezeichnung*). 

### API Call
---
|Api call|         |
|--------|---------|
|**URL:**|http://host.docker.internal:3000/run|
|**Method:**|Post|

**Request Body:**
```
{
   "queryKey": "get_cao_invoice_positions",
   "parameters": {
      "Kundenname": "${Kundenname}",
      "start_date": "${start_date}",
      "end_date": "${end_date}",
      "Ort": "${Ort}",
      "Strasse": "${Strasse}"
   }
}
```
---
## For *get_cao_order_positions*

### Flow Information
---
**Flow Name:** CaoCustomerOrderPositions

**Description**
```
Suche nach Text in Bezeichnungen der einzelnen Auftragspositionen. In der Bezeichnung findest du Artikeldaten, Objekt und Objektadressen, Bestellnummer der Kunden, Leistungen, Durchführungsdatum, eventuelle Regiestundendaten. Zeige alle Positionen dieses Auftrages (sortiert nach POS) in einer Tabelle.

Die Auftragsnummer steht in den einzelnen Positionen immer dabei. Du wirst diese immer mit angeben.

Du wirst alle anderen Details zur Verfügung stellen.

Wenn kein Kunde angegeben, dass Wildcard % nutzen um alle zu durchsuchen.

Ort und Strasse sind optional aber können auch verlangt werden.

Sei exakt wenn es um die Anzahl, Summen und andere Details geht. Du wirst nicht von den extrahierten Daten abweichen. Das ist sehr wichtig. 

Diese Abfrage nur durchführen, wenn ein Kundenname angegeben wird oder in der Unterhaltung vorher angegeben war.

Datumsformat: 2025-10-29 00:00:00
```

### Flow Variables
---
**Variables:**

|Variable name|Initial value|
|-------------|-------------|
|Kundenname:|(empty)|
|Bezeichnung:|(empty)|
|start_date:|(empty)|
|end_date:| (empty)|
|Ort:|(empty)|
|Straße:|(empty)|

Note: City and street refer to order header information. If you're searching for streets or addresses in the *Bezeichnung*, you must specify this in the wording (example: search for Vienna in the *Bezeichnung*). 

### API Call
---
|Api call|         |
|--------|---------|
|**URL:**|http://host.docker.internal:3000/run|
|**Method:**|Post|

**Request Body:**
```
{
   "queryKey": "get_cao_order_positions",
   "parameters": {
      "Kundenname": "${Kundenname}",
      "start_date": "${start_date}",
      "end_date": "${end_date}",
      "Ort": "${Ort}",
      "Strasse": "${Strasse}"
   }
}
```
---
## For *get_cao_offer_positions*

### Flow Information
---
**Flow Name:** CaoCustomerOfferPositions

**Description**
```
Suche nach Text in Bezeichnungen der einzelnen Angebotspositionen. In der Bezeichnung findest du Artikeldaten, Objekt und Objektadressen, Leistungen, Durchführungsdatum. Zeige alle Positionen dieses Auftrages (sortiert nach POS) in einer Tabelle.

Die Angebotsnummer sowie die Versionsnummer steht in den einzelnen Positionen immer dabei. Du wirst diese immer mit angeben.

Du wirst alle anderen Details zur Verfügung stellen.

Wenn kein Kunde angegeben, dass Wildcard % nutzen um alle zu durchsuchen.

Ort und Strasse sind optional aber können auch verlangt werden.

Sei exakt wenn es um die Anzahl, Summen und andere Details geht. Du wirst nicht von den extrahierten Daten abweichen. Das ist sehr wichtig. 

Diese Abfrage nur durchführen, wenn ein Kundenname angegeben wird oder in der Unterhaltung vorher angegeben war.

Datumsformat: 2025-10-29 00:00:00
```

### Flow Variables
---
**Variables:**

|Variable name|Initial value|
|-------------|-------------|
|Kundenname:|(empty)|
|Bezeichnung:|(empty)|
|start_date:|(empty)|
|end_date:| (empty)|
|Ort:|(empty)|
|Straße:|(empty)|

Note: City and street refer to order header information. If you're searching for streets or addresses in the *Bezeichnung*, you must specify this in the wording (example: search for Vienna in the *Bezeichnung*). 

### API Call
---
|Api call|         |
|--------|---------|
|**URL:**|http://host.docker.internal:3000/run|
|**Method:**|Post|

**Request Body:**
```
{
   "queryKey": "get_cao_offer_positions",
   "parameters": {
      "Kundenname": "${Kundenname}",
      "start_date": "${start_date}",
      "end_date": "${end_date}",
      "Ort": "${Ort}",
      "Strasse": "${Strasse}"
   }
}
```
---