import json

from flask import Flask, request, jsonify
import requests

# Define the URL of the Google Vision API
google_vision_url = 'bruh'
API_KEY = 'bruh'
API_ENDPOINT = 'bruh'

# Define the headers for the Google Vision API
headers = {
    'Content-Type': 'application/json'
}

app = Flask(__name__)

# Sample product expiration database
expirationdb = {
    "milk": "7 days",
    "bread": "5 days",
    "yogurt": "14 days",
    "apple": "30 days",
    "meat": "3 days"
}

@app.route('/analyze', methods=['POST'])
def analyze_image():
    # Get the base64-encoded image from the request
    data = request.json
    image_base64 = data.get('image')

    # Return an error if no image data is provided
    if not image_base64:
        return jsonify({"error": "No image data provided"}), 400

    # Define the JSON body for the Google Vision API request
    vision_data = {
        "requests": [
            {
                "image": {
                    "content": image_base64,  # Base64 image
                },
                "features": [
                    {
                        "type": "LABEL_DETECTION",  # Feature type for image analysis
                        "maxResults": 10,
                    },
                ],
            }
        ]
    }

    # Make a POST request to the Google Vision API
    response = requests.post(google_vision_url, headers={'Content-Type': 'application/json'}, json=vision_data)

    # Check if the request was successful
    if response.status_code == 200:
        # Parse the response from Google Vision API
        vision_response = response.json()
        vision_response_str = json.dumps(vision_response)

        headers = {
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {API_KEY}'
        }

        # Define the request payload
        payload = {
            "model": "gpt-3.5-turbo",  # Replace with the model name you want to use
            "messages": [
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user",
                 "content":
                     f"Here is google vision api response: {vision_response_str}" +
                     " select food item with highest probability and give it's typical expiration date" +
                     " Return your answer as JSON with the following format: {'food_item': food_item_name, 'expiration': {'min': number, 'max': number}} " +
                     "where min and max are the maximum expiration time in days from the date of purchase. Return ONLY the JSON result. " +
                    "if the food item is not found return your answer as JSON with the following format: {'food_item': '-', 'expiration': {'min': 0, 'max': 0}} " +
                 "do not change or add additional information to your answer!"
                 },
            ],
            "max_tokens": 200  # Adjust the number of tokens as needed
        }

        # Send the request
        response = requests.post(API_ENDPOINT, headers=headers, json=payload)

        if response.status_code == 200:
            response_data = response.json()
            food_item_str = response_data['choices'][0]['message']['content'].replace('```json', '').replace('```', '').strip()
            food_item_info = json.loads(food_item_str)
            print("Response:", food_item_info)
            return jsonify({
                "message": "Image analysis complete",
                "food_item": food_item_info['food_item'],
                "expiration_min": food_item_info['expiration']["min"],
                "expiration_max": food_item_info['expiration']["max"]
                # Include the actual response from Google Vision API
            })
        else:
            print("Error:", response.status_code, response.text)
            return jsonify({
                "error": "Image analysis failed",
                "status_code": response.status_code,
                "response": response.text
            }), response.status_code

    else:
        # If the request to Google Vision API fails, return an error message
        return jsonify({
            "error": "Image analysis failed",
            "status_code": response.status_code,
            "response": response.text
        }), response.status_code

# API route to process product text
@app.route('/getexpiration', methods=['POST'])
def get_expiration():
    data = request.json
    product_text = data['product'].lower()  # Convert product text to lowercase
    expiration = expirationdb.get(product_text, "Unknown expiration range")  # Lookup expiration

    return jsonify({"product": product_text, "expiration": expiration})

if __name__ == '__main__':
    app.run(debug=True, port=5000)
