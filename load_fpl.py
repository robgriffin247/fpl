import dlt
import httpx
from typing import Iterator, Dict, Any


@dlt.resource(name="fpl_bootstrap", write_disposition="replace")
def get_fpl_data() -> Iterator[Dict[str, Any]]:
    """
    Fetch FPL bootstrap-static data and yield each top-level key as a separate record.
    
    The API returns a dict with keys like 'events', 'teams', 'elements', etc.
    We'll yield each as a separate table.
    """
    url = "https://fantasy.premierleague.com/api/bootstrap-static/"
    response = httpx.get(url)
    response.raise_for_status()
    
    data = response.json()
    
    # The bootstrap-static endpoint returns nested data structures
    # Each top-level key becomes its own table
    for key, value in data.items():
        if isinstance(value, list):
            # If it's a list, yield each item with a table hint
            for item in value:
                yield dlt.mark.with_table_name(item, key)
        else:
            # If it's a single value/dict, yield it as-is
            yield dlt.mark.with_table_name({key: value}, "metadata")


@dlt.source
def fpl_source():
    """DLT source for Fantasy Premier League data"""
    return get_fpl_data()


if __name__ == "__main__":
    # Create pipeline pointing to local DuckDB
    pipeline = dlt.pipeline(
        pipeline_name="fpl_pipeline",
        destination=dlt.destinations.duckdb("./data/raw.duckdb"),
        dataset_name="fpl_raw"
    )
    
    # Run the pipeline
    load_info = pipeline.run(fpl_source())
    
    # Print load information
    print(f"Pipeline run completed: {load_info}")
    print(f"Loaded tables: {load_info.dataset_name}")