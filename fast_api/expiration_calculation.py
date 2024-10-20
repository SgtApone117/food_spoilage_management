from flask import Flask, request, jsonify
import requests

# Define the URL of the API
url = 'https://vision.googleapis.com/v1/images:annotate?key='  # Ensure the port matches where your FastAPI app is running

# Define the headers

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
    data = request.json
    image_base64 = data.get('image')

    if not image_base64:
        return jsonify({"error": "No image data provided"}), 400

    

    # Define the JSON body
    data = {
        "image": {
                "content": image_base64, 
                },
                "features": [
                {
                    "type": "LABEL_DETECTION",
                    "maxResults": 10,
                },
                ],
        
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

        return jsonify({"message": "Image analysis complete", "status": "success"})
`

# API route to process product text
@app.route('/getexpiration', methods=['POST'])
def get_expiration():
    data = request.json
    product_text = data['product'].lower()  # Convert product text to lowercase
    expiration = expirationdb.get(product_text, "Unknown expiration range")  # Lookup expiration

    return jsonify({"product": product_text, "expiration": expiration})

if __name__ == '__main__':
    app.run(debug=True, port=5000)  