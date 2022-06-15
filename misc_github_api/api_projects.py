#from pygithub3 import Github
#ghe = Github(my_connection)


import requests, os

# Get the path
SCRIPT_DIR = os.path.dirname(__file__)
# if ran from ipython in Github_api directory
# SCRIPT_DIR =os.getcwd()
CREDENTIALS_FILE = "ghe_token.txt"
credentials = os.path.join(SCRIPT_DIR, CREDENTIALS_FILE)

# Set the connection credentials

# Get the token

my_token = ''
with open(credentials, 'r') as fd:
    my_token = fd.readline().strip()  # Can't hurt to be paranoid

my_connection = dict(login = "brun",token = my_token,
base_url = "https://github.nceas.ucsb.edu/api/v3/repos/SNAPP/snapp-wg-scicomp/projects",
repo = "snapp-wg-scicomp")

# Connect to the api
headers = {'Authorization': 'token %s' % my_connection['token'], 'Accept': 'application/vnd.github.inertia-preview+json'}
r = requests.get(my_connection['base_url'], headers=headers)
r.json()
