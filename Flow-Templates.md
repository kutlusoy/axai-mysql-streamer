# Flow Information

Flow Name: CAOAngebot
Description
```
Suche nach Angebote. Zeige alle in einer Tabelle. Sei exakt wenn es um die Anzahl, Summen und andere Details geht. Du wirst nicht von den extrahierten Daten abweichen. Das ist sehr wichtig. 

Diese Abfrage nur durchführen, wenn ein Kundenname angegeben wird oder in der Unterhaltung vorher angegeben war.

Datumsformat: 2025-10-29 00:00:00
```

# Flow Variables
Variables:
Kundenname: (empty)
start_date: (empty)
end_date: (empty)

# API Call
URL: http://host.docker.internal:3000/run
Method: Post
Request Body:
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


