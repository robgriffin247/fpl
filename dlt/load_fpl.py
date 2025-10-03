import dlt
import httpx


@dlt.resource(
    name="fpl_data",
    write_disposition="replace"
)
def get_data():
    url = "https://fantasy.premierleague.com/api/bootstrap-static/"
    response = httpx.get(url)
    response.raise_for_status()
    
    data = response.json()
    
    # Endpoint returns nested data structures
    # Each top-level key becomes its own table
    for key, value in data.items():
        if isinstance(value, list):
            # If list, yield each item with table hint
            for item in value:
                yield dlt.mark.with_table_name(item, key)
        else:
            # If single value/dict, yield as-is
            yield dlt.mark.with_table_name({key: value}, "metadata")


@dlt.source
def fpl_source():
    return get_data()


if __name__ == "__main__":
    pipeline = dlt.pipeline(
        pipeline_name="fpl_pipeline",
        destination=dlt.destinations.duckdb("./data/raw.duckdb"),
        dataset_name="fpl"
    )
    
    load_info = pipeline.run(fpl_source())
    
    print(load_info)