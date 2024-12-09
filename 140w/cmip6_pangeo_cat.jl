using HTTP
using JSON
using DataFrames

# Load the CMIP6 catalog JSON file
catalog_url = "https://storage.googleapis.com/cmip6/pangeo-cmip6.json"
response = HTTP.get(catalog_url)
catalog_data = JSON.parse(String(response.body))

# Convert the catalog into a DataFrame for easy querying
datasets = DataFrame(catalog_data["catalog"])

# Display the first few rows of the catalog
println(first(datasets, 5))

# Query specific datasets (e.g., by model, experiment, variable)
filtered = filter(row -> row["model"] == "CCSM4" &&
                      row["experiment"] == "ssp245" &&
                      row["variable"] == "tas", datasets)

# Display the filtered results
println(filtered)

# Form URLs for remote access
base_url = "https://storage.googleapis.com/gcp-public-data-cmip6"
urls = [joinpath(base_url, row["zstore"]) for row in eachrow(filtered)]
println("Formed URLs:")
println(urls)
