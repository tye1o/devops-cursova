# tests/test_app.py
import pytest
import sys
import os

# Додаємо кореневу директорію проекту до шляху пошуку модулів
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import json
from app import app, lambda_handler

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_hello_world(client):
    """Test Flask route '/' returns 'Hello, World!'"""
    response = client.get('/')
    assert response.status_code == 200
    assert b'Hello, World!' in response.data

def test_lambda_handler_root():
    """Test AWS Lambda handler for root path"""
    # Create a mock API Gateway event
    event = {
        'path': '/',
        'httpMethod': 'GET',
        'headers': {},
        'queryStringParameters': {},
        'body': None
    }
    
    # Call the lambda handler
    response = lambda_handler(event, {})
    
    # Check the response
    assert response['statusCode'] == 200
    assert response['body'] == 'Hello, World!'
    assert response['headers']['Content-Type'] == 'text/plain'

def test_lambda_handler_not_found():
    """Test AWS Lambda handler for non-existent path"""
    # Create a mock API Gateway event
    event = {
        'path': '/non-existent',
        'httpMethod': 'GET',
        'headers': {},
        'queryStringParameters': {},
        'body': None
    }
    
    # Call the lambda handler
    response = lambda_handler(event, {})
    
    # Check the response
    assert response['statusCode'] == 404
    assert json.loads(response['body']) == {'error': 'Not Found'}
    assert response['headers']['Content-Type'] == 'application/json' 