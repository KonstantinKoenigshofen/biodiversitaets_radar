import pandas as pd
from sqlalchemy import create_engine
import os
import json

NEON_DB_URL = os.getenv("NEON_DB_URL")
if not NEON_DB_URL:
    raise ValueError("Neon-Schlüssel nicht gefunden!")

engine = create_engine(NEON_DB_URL)

with engine.connect() as conn:

    # Daten für die Karte holen (alle Beobachtungen der letzten 30 Tage)
    query_map = """
            SELECT o.latitude, o.longitude, o.photo_url, o.species_guess, s.name as scientific_name, s.iconic_taxon_name
            FROM observations o
            JOIN species s ON o.taxon_id = s.taxon_id
            WHERE o.observed_on >= NOW() - INTERVAL '30 days'
        """
    df_map = pd.read_sql(query_map, conn)
    # Also JSON abspeichern ("records" macht daraus eine JSON-Liste)
    df_map.to_json("docs/map_data.json", orient="records", force_ascii=False)
    print(f"map_data.json wurde erstellt. {len(df_map)} Einträge wurden auf die Karte hinzugefügt.")

    #
    # Daten für die Statistiken unter der Karte holen
    #

    # Top 5 Arten der letzten 30 Tage
    query_top5 = """
        SELECT o.species_guess as name, COUNT(o.id) as count
        FROM observations o
        WHERE o.observed_on >= NOW() - INTERVAL '30 days'
        GROUP BY o.species_guess
        ORDER BY count DESC
        LIMIT 5
    """
    df_top5 = pd.read_sql(query_top5, conn)

    # Verteilung der Tiergruppen (30 Tage)
    query_categories = """
        SELECT s.iconic_taxon_name as category, COUNT(o.id) as count
        FROM observations o
        JOIN species s ON o.taxon_id = s.taxon_id
        WHERE o.observed_on >= NOW() - INTERVAL '30 days'
        GROUP BY s.iconic_taxon_name
    """
    df_categories = pd.read_sql(query_categories, conn)

    # Antworten in einem Dictionary zusammenfügen
    stats_data = {
        "top_5_species": df_top5.to_dict(orient="records"),
        "categories": df_categories.to_dict(orient="records"),
    }

    with open("docs/stats.json", "w", encoding="utf-8") as f:
        json.dump(stats_data, f, ensure_ascii=False, indent=4)

    print("stats.json erstellt.")