import requests
import base64 #g

def encode_image_to_base64(image_path):
    # Open the image file in binary mode
    with open(image_path, "rb") as image_file:
        # Read the image data
        image_data = image_file.read()
        # Encode the image data to base64
        base64_encoded_data = base64.b64encode(image_data)
        # Convert the base64 encoded data to a string
        base64_encoded_string = base64_encoded_data.decode('utf-8')
    return base64_encoded_string

# Example usage
image_path = 'C:\\Users\\donle\\Downloads\\food_spoilage_management\\fast_api\\classic-cheese-pizza-FT-RECIPE0422-31a2c938fc2546c9a07b7011658cfd05.jpg'
encoded_image = encode_image_to_base64(image_path)

# Define the URL of the API
url = 'http://127.0.0.1:5000/analyze'  # Ensure the port matches where your FastAPI app is running

# Define the headers
headers = {
    'Content-Type': 'application/json'
}

# Define the JSON body
data = { 
    "image": encoded_image
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
