from pyinaturalist import get_observations
from datetime import datetime, timedelta
import pandas as pd
from sqlalchemy import create_engine, text
import os


#
# EXTRACT
#

# Extrahiert Observationsdaten von der INaturalist-API 
# in einer bestimmten Region (98502 = Hildesheim) in einem bestimmten Zeitraum
def extract_biodiversity_data(place_id=98502, days=14):

    timespan = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")

    print(f"Suche Beobachtungen seit: {timespan}")

    response = get_observations(
        iconic_taxa=['Aves', 'Mammalia', 'Amphibia', 'Reptilia'],
        place_id=place_id,
        quality_grade='research',
        d1=timespan,
        has_photos=True,
        geo=True, # nur Einträge mit Koordinaten
        per_page=100
    )

    print(f"Es wurden {response['total_results']} Einträge gefunden.")

    return response

#
# TRANSFORM
#

def transform_data(raw_data):

    df = pd.json_normalize(raw_data)

    # Falls gar keine Daten gefunden wurden, leere DataFrames zurückgeben
    if df.empty:
        return pd.DataFrame(), pd.DataFrame()

    columns_to_filter = [
    "id",
    "species_guess",
    "observed_on",
    "taxon.threatened",
    "taxon.name",
    "taxon.id",
    "taxon.iconic_taxon_name",
    "location",
    "photos",
    ]

    df = df[[c for c in columns_to_filter if c in df.columns]]

    # Location aufteilen
    df["latitude"] = df["location"].apply(lambda x: x[0] if isinstance(x, list) and len(x) >= 2 else None)
    df["longitude"] = df["location"].apply(lambda x: x[1] if isinstance(x, list) and len(x) >= 2 else None)
    df = df.drop(columns=["location"])

    # Foto herausfiltern
    df["photo_url"] = df["photos"].apply(lambda x: x[0]["url"] if isinstance(x, list) and len(x) > 0 and "url" in x[0] else None)    
    df = df.drop(columns=["photos"])

    # Daten für die zwei Tabellen aufteilen
    df_species = df[["taxon.id", "taxon.name", "taxon.iconic_taxon_name", "taxon.threatened"]]
    df_observations = df[["id", "taxon.id", "species_guess", "observed_on", "latitude", "longitude", "photo_url"]]

    # IDs in String umwandeln und Duplikate entfernen
    df_species['taxon.id'] = df_species['taxon.id'].astype(str)
    df_species = df_species.drop_duplicates(subset=["taxon.id"])
    df_observations['id'] = df_observations['id'].astype(str)
    df_observations['taxon.id'] = df_observations['taxon.id'].astype(str)
    df_observations = df_observations.drop_duplicates(subset=['id'])
    # Zeitstempel in datetime umwandeln
    df_observations['observed_on'] = pd.to_datetime(df_observations['observed_on'], utc=True)

    # Fehlende IDs herausfiltern
    df_species = df_species.dropna(subset=["taxon.id"])
    df_observations = df_observations.dropna(subset=["id", "taxon.id"])

    # Spalten umbenennen
    df_species = df_species.rename(columns={
    "taxon.id": "taxon_id",
    "taxon.name": "name",
    "taxon.iconic_taxon_name": "iconic_taxon_name",
    "taxon.threatened": "threatened"
    })

    df_observations = df_observations.rename(columns={
        "taxon.id": "taxon_id"
    })

    return df_species, df_observations



#
# LOAD
#

def load(df_species, df_observations, engine):

    with engine.begin() as conn:

        #
        # Tabelle "species"
        #

        # Alle derzeitigen IDs aus der Tabelle species holen
        existing_ids_species_df = pd.read_sql("SELECT taxon_id FROM species", conn)
        existing_ids_species = existing_ids_species_df['taxon_id'].astype(str).tolist()

        # Arten die schon in der Datenbank drinne sind herausfiltern
        df_species_new = df_species[~df_species['taxon_id'].isin(existing_ids_species)]

        if not df_species_new.empty:
            df_species_new.to_sql(
                name="species",
                con=conn,
                if_exists='append',
                index=False
            )
            print(f"Es wurden {len(df_species_new)} neue Arten hinzugefügt!")
        else:
            print("Keine neuen Arten in den aktuellen Beobachtungen gefunden.")

        #
        # Tabelle "observations"
        #
        df_observations.to_sql(
            name="observations",
            con=conn,
            if_exists='append',
            index=False
        )
        print(f"Es wurden {len(df_observations)} neue Beobachtungen hinzugefügt!")







# ETL-Pipeline

NEON_DB_URL = os.getenv("NEON_DB_URL")
if not NEON_DB_URL:
    raise ValueError("Neon-Schlüssel nicht gefunden!")

engine = create_engine(NEON_DB_URL)

try: 
    raw_data = extract_biodiversity_data()
    df_species, df_observations = transform_data(raw_data.get('results',[]))
    load(df_species, df_observations, engine)

except Exception as e:
    print(f"Ein Fehler ist aufgetreten: {e}")
