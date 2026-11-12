
import csv
from pathlib import Path

# Dossier contenant le script
DOSSIER = Path(__file__).resolve().parent

# Données fictives pour le TP3
mesures = [
    {
        "id": 1,
        "timestamp": "2026-11-12T08:00:00+00:00",
        "city": "Paris",
        "zone": "Centre",
        "pollutant": "NO2",
        "value": 52.0,
        "unit": "ug/m3",
        "q": 650
    },
    {
        "id": 2,
        "timestamp": "2026-11-12T09:00:00+00:00",
        "city": "Paris",
        "zone": "Centre",
        "pollutant": "NO2",
        "value": 40.0,
        "unit": "ug/m3",
        "q": 350
    },
    {
        "id": 3,
        "timestamp": "2026-11-12T10:00:00+00:00",
        "city": "Paris",
        "zone": "Nord",
        "pollutant": "PM10",
        "value": 25.0,
        "unit": "ug/m3",
        "q": 120
    },
    {
        "id": 4,
        "timestamp": "2026-11-12T18:00:00+00:00",
        "city": "Lyon",
        "zone": "Centre",
        "pollutant": "NO2",
        "value": 68.0,
        "unit": "ug/m3",
        "q": 720
    },
    {
        "id": 5,
        "timestamp": "2026-11-12T19:00:00+00:00",
        "city": "Lyon",
        "zone": "Sud",
        "pollutant": "PM10",
        "value": 18.0,
        "unit": "ug/m3",
        "q": 180
    }
]

# Chemin du fichier CSV à créer
fichier_csv = DOSSIER / "mesures_simulees.csv"

with fichier_csv.open(
    mode="w",
    newline="",
    encoding="utf-8"
) as fichier:
    colonnes = [
        "id",
        "timestamp",
        "city",
        "zone",
        "pollutant",
        "value",
        "unit",
        "q"
    ]

    writer = csv.DictWriter(
        fichier,
        fieldnames=colonnes
    )

    writer.writeheader()
    writer.writerows(mesures)

print(f"Fichier généré : {fichier_csv}")
print(f"Nombre de mesures : {len(mesures)}")
