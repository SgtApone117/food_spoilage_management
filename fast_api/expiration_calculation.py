from flask import Flask, request, jsonify
import requests

# Define the URL of the Google Vision API
url = 'https://vision.googleapis.com/v1/images:annotate?key='  # Replace with your actual API key

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
    response = requests.post(url, headers=headers, json=vision_data)

    # Check if the request was successful
    if response.status_code == 200:
        # Parse the response from Google Vision API
        vision_response = response.json()

        # Return the response from Google Vision API to the client
        return jsonify({
            "message": "Image analysis complete",
            "vision_response": vision_response  # Include the actual response from Google Vision API
        })
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
