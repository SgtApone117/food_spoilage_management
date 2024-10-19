import requests

# Define the URL of the API
url = 'http://127.0.0.1/start'

# Define the headers
headers = {
    'Content-Type': 'application/json'
}

# Make a GET request to the API with headers
response = requests.get(url, headers=headers)

# Check the status code of the response
if response.status_code == 200:
    print('Request was successful!')
    # Print the response content
    print('Response:', response.text)
else:
    print('Request failed with status code:', response.status_code)