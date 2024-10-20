import requests

# Define the URL of the API
url = 'http://127.0.0.1:5000/getexpiration'  # Ensure the port matches where your FastAPI app is running

# Define the headers
headers = {
    'Content-Type': 'application/json'
}

# Define the JSON body
data = {
    'product': 'pizza'
}

# Make a POST request to the API with headers and JSON body
response = requests.post(url, headers=headers, json=data)

# Check the status code of the response
if response.status_code == 200:
    print('Request was successful!')
    # Print the response content
    print('Response:', response.text)
else:
    print('Request failed with status code:', response.status_code)
    print('Response:', response.text)
