
import csv
from datetime import datetime, timezone
from pathlib import Path

DOSSIER = Path(__file__).resolve().parent

FICHIER_SOURCE = DOSSIER / "mesures_simulees.csv"
FICHIER_SORTIE = DOSSIER / "mesures_transformees.csv"

NOMS_POLLUANTS = {
    "NO2": "Dioxyde d'azote",
    "PM10": "Particules PM10",
    "O3": "Ozone"
}


def classifier_trafic(q):
    """Classe le trafic selon les seuils fictifs du TP3."""
    if q is None or q < 0:
        return "Inconnu"
    if q < 200:
        return "Faible"
    if q < 500:
        return "Moyen"
    return "Élevé"


def transformer_mesure(mesure):
    """Transforme une observation source pour l'entrepôt."""

    # Convertir le timestamp source en UTC
    date_utc = datetime.fromisoformat(
        mesure["timestamp"]
    ).astimezone(timezone.utc)

    code_polluant = mesure["pollutant"].strip().upper()

    # Lire q, ou signaler une valeur manquante
    q_texte = mesure["q"].strip()
    q = float(q_texte) if q_texte else None

    return {
        "id_mesure_source": int(mesure["id"]),
        "date_heure": date_utc.strftime("%Y-%m-%d %H:%M:%S"),
        "date_mesure": date_utc.strftime("%Y-%m-%d"),
        "heure": date_utc.hour,
        "jour_semaine": date_utc.isoweekday(),
        "mois": date_utc.month,
        "annee": date_utc.year,
        "ville": mesure["city"].strip(),
        "zone": mesure["zone"].strip() or "Zone inconnue",
        "code_polluant": code_polluant,
        "nom_polluant": NOMS_POLLUANTS.get(
            code_polluant, code_polluant
        ),
        "unite": mesure["unit"].strip(),
        "niveau_trafic": classifier_trafic(q),
        "concentration": float(mesure["value"])
    }


def main():
    with FICHIER_SOURCE.open(
        "r", encoding="utf-8", newline=""
    ) as fichier:
        lecteur = csv.DictReader(fichier)
        mesures = [
            transformer_mesure(ligne)
            for ligne in lecteur
        ]

    if not mesures:
        print("Aucune mesure à transformer.")
        return

    with FICHIER_SORTIE.open(
        "w", encoding="utf-8", newline=""
    ) as fichier:
        writer = csv.DictWriter(
            fichier,
            fieldnames=list(mesures[0].keys())
        )
        writer.writeheader()
        writer.writerows(mesures)

    print(f"Fichier transformé : {FICHIER_SORTIE}")
    print(f"Nombre de mesures transformées : {len(mesures)}")

    for mesure in mesures:
        print(
            f"Mesure {mesure['id_mesure_source']} : "
            f"{mesure['code_polluant']} - "
            f"{mesure['niveau_trafic']} - "
            f"{mesure['concentration']} {mesure['unite']}"
        )


if __name__ == "__main__":
    main()
