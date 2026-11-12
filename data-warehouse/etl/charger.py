
import csv
import subprocess
from pathlib import Path

DOSSIER = Path(__file__).resolve().parent
FICHIER_CSV = DOSSIER / "mesures_transformees.csv"

CONTENEUR = "smartcity-db-exo5"
UTILISATEUR = "urbanhub_user"
BASE = "urbanhub"


def charger():
    # Lire le fichier CSV transformé
    with FICHIER_CSV.open(
        "r", encoding="utf-8", newline=""
    ) as fichier:
        mesures = list(csv.DictReader(fichier))

    if not mesures:
        print("Aucune mesure à charger.")
        return

    # Construire un fichier SQL temporaire dans le VPS
    # en utilisant les données validées du CSV.
    lignes_sql = ["BEGIN;"]

    # 1. Charger les catégories de trafic
    lignes_sql.extend([
        """
        INSERT INTO decisionnel.dim_trafic
            (niveau_trafic, debit_min, debit_max_exclu)
        VALUES
            ('Faible', 0, 200),
            ('Moyen', 200, 500),
            ('Élevé', 500, NULL),
            ('Inconnu', NULL, NULL)
        ON CONFLICT (niveau_trafic) DO NOTHING;
        """
    ])

    # 2. Charger les autres dimensions
    for mesure in mesures:
        date_heure = mesure["date_heure"]
        date_mesure = mesure["date_mesure"]
        heure = int(mesure["heure"])
        jour_semaine = int(mesure["jour_semaine"])
        mois = int(mesure["mois"])
        annee = int(mesure["annee"])

        # Les valeurs texte doivent être échappées pour SQL
        def sql_texte(valeur):
            return "'" + valeur.replace("'", "''") + "'"

        ville = sql_texte(mesure["ville"])
        zone = sql_texte(mesure["zone"])
        code = sql_texte(mesure["code_polluant"])
        nom = sql_texte(mesure["nom_polluant"])
        unite = sql_texte(mesure["unite"])

        lignes_sql.append(f"""
            INSERT INTO decisionnel.dim_temps
                (date_heure, date_mesure, heure,
                 jour_semaine, mois, annee)
            VALUES
                ('{date_heure}', '{date_mesure}',
                 {heure}, {jour_semaine},
                 {mois}, {annee})
            ON CONFLICT (date_heure) DO NOTHING;
        """)

        lignes_sql.append(f"""
            INSERT INTO decisionnel.dim_localisation
                (ville, zone)
            VALUES ({ville}, {zone})
            ON CONFLICT (ville, zone) DO NOTHING;
        """)

        lignes_sql.append(f"""
            INSERT INTO decisionnel.dim_polluant
                (code_polluant, nom_polluant, unite)
            VALUES ({code}, {nom}, {unite})
            ON CONFLICT (code_polluant, unite) DO NOTHING;
        """)

    # 3. Charger les faits en retrouvant les clés
    for mesure in mesures:
        def sql_texte(valeur):
            return "'" + valeur.replace("'", "''") + "'"

        identifiant = int(mesure["id_mesure_source"])
        concentration = float(mesure["concentration"])

        date_heure = sql_texte(mesure["date_heure"])
        ville = sql_texte(mesure["ville"])
        zone = sql_texte(mesure["zone"])
        code = sql_texte(mesure["code_polluant"])
        unite = sql_texte(mesure["unite"])
        niveau = sql_texte(mesure["niveau_trafic"])

        lignes_sql.append(f"""
            INSERT INTO decisionnel.fact_pollution
                (temps_key, localisation_key,
                 polluant_key, trafic_key,
                 concentration, id_mesure_source)
            SELECT
                t.temps_key,
                l.localisation_key,
                p.polluant_key,
                tr.trafic_key,
                {concentration},
                {identifiant}
            FROM decisionnel.dim_temps t
            CROSS JOIN decisionnel.dim_localisation l
            CROSS JOIN decisionnel.dim_polluant p
            CROSS JOIN decisionnel.dim_trafic tr
            WHERE t.date_heure = {date_heure}
              AND l.ville = {ville}
              AND l.zone = {zone}
              AND p.code_polluant = {code}
              AND p.unite = {unite}
              AND tr.niveau_trafic = {niveau}
            ON CONFLICT (id_mesure_source) DO NOTHING;
        """)

    lignes_sql.append("COMMIT;")

    sql = "\n".join(lignes_sql)

    # Exécuter le SQL dans PostgreSQL via Docker
    commande = [
        "docker", "exec", "-i", CONTENEUR,
        "psql",
        "-X",
        "-v", "ON_ERROR_STOP=1",
        "-U", UTILISATEUR,
        "-d", BASE
    ]

    resultat = subprocess.run(
        commande,
        input=sql,
        text=True,
        capture_output=True,
        check=False
    )

    if resultat.returncode != 0:
        print("Erreur pendant le chargement :")
        print(resultat.stderr)
        raise SystemExit(1)

    print("Chargement terminé.")
    print(f"Mesures lues dans le CSV : {len(mesures)}")
    print(resultat.stdout)


if __name__ == "__main__":
    charger()
