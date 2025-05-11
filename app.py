# app.py
from flask import Flask, jsonify
import os
import json
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# Define Prometheus metrics
REQUEST_COUNT = Counter(
    'app_request_count', 
    'Application Request Count',
    ['method', 'endpoint', 'http_status']
)
REQUEST_LATENCY = Histogram(
    'app_request_latency_seconds', 
    'Application Request Latency',
    ['method', 'endpoint']
)

@app.route('/')
def hello():
    REQUEST_COUNT.labels(
        method='GET', 
        endpoint='/', 
        http_status=200
    ).inc()
    return jsonify(message="Hello from Python Flask App!")

@app.route('/health')
def health():
    REQUEST_COUNT.labels(
        method='GET', 
        endpoint='/health', 
        http_status=200
    ).inc()
    return jsonify(status="ok")

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

# AWS Lambda handler function
def lambda_handler(event, context):
    """AWS Lambda function handler to process API Gateway events"""
    
    # Print the event for debugging
    print('Event: ', event)
    
    # Get HTTP path
    path = event.get('path', '/')
    http_method = event.get('httpMethod', 'GET')
    
    # Process the request based on the path
    if path == '/':
        response_body = {"message": "Hello from Python Flask Lambda!"}
        status_code = 200
    elif path == '/health':
        response_body = {"status": "ok"}
        status_code = 200
    else:
        response_body = {"error": "Not Found"}
        status_code = 404
    
    return {
        "statusCode": status_code,
        "body": jsonify(response_body).get_data(as_text=True),
        "headers": {
            "Content-Type": "application/json"
        }
    }

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 3000))
    app.run(host='0.0.0.0', port=port) 