import requests, unicodecsv

access_token = '::access token::'
url = "https://github.nceas.ucsb.edu/api/v3/repos/NCEAS/sasap-data/issues"

# Data structures to hold issue info
column_names = set()
issues = []

# Query GitHub API to get first batch of issues
response = requests.get(url=url, params={"access_token": access_token})

# The GitHub issues API sends issues in batches instead of all at once.
# If this is not the last batch, there will be a link to the "next" batch
# in response.links, which is a dictionary
links = response.links

while "next" in links:
    print links["next"]["url"]

    # Get the issue data in json format
    response = response.json()

    # Add issue data to column name and issue data structures
    for issue in response:
        column_names.update(issue.keys())
        issues.append(issue)

    # Get url of next batch, then make new query to get the next batch
    next_url = links["next"]["url"]
    response = requests.get(next_url)
    links = response.links

# Create a file to write to
output_file = open("github_issues.csv", "w")

# Convert column_names from set to list to write to file
column_names = list(column_names)

# Write data from response to CSV file
writer = unicodecsv.DictWriter(output_file, column_names)
writer.writeheader()
for issue in issues:
    writer.writerow(issue)
