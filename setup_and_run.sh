#!/bin/bash

# Name of the application
APP_NAME="NutSearch v0.1"

# Update package list and install Python3 and pip if not installed
echo "Updating package list..."
sudo apt-get update

echo "Installing Python3 and pip..."
sudo apt-get install -y python3 python3-pip

# Install Flask and requests
echo "Installing Flask and requests..."
pip3 install Flask requests

# Create the application directory
APP_DIR="NutSearch"
mkdir -p $APP_DIR
cd $APP_DIR

# Create app.py
cat <<EOL > app.py
from flask import Flask, request, render_template
import requests

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/proxy', methods=['GET', 'POST'])
def proxy():
    if request.method == 'POST':
        url = request.form['url']
        response = requests.get(url)
        return response.text
    return "Invalid request"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
EOL

# Create templates directory
mkdir -p templates

# Create index.html
cat <<EOL > templates/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NutSearch</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <style>
        body { font-family: Arial, sans-serif; }
        #tabs { display: flex; cursor: pointer; }
        .tab { padding: 10px; border: 1px solid #ccc; margin-right: 5px; }
        .tab-content { display: none; padding: 10px; border: 1px solid #ccc; }
        .active { display: block; }
        .active-tab { background-color: #f0f0f0; }
    </style>
</head>
<body>

<div id="tabs">
    <div class="tab active-tab" onclick="showTab('proxyTab')">Proxy</div>
    <div class="tab" onclick="showTab('erudaTab')">Eruda</div>
</div>

<div id="proxyTab" class="tab-content active">
    <h2>NutSearch Web Proxy</h2>
    <form id="proxyForm">
        <input type="text" name="url" placeholder="Enter URL" required>
        <button type="submit">Load</button>
    </form>
    <div id="proxyResult"></div>
</div>

<div id="erudaTab" class="tab-content">
    <h2>Eruda Console</h2>
    <script src="https://cdn.rawgit.com/liriliri/eruda/master/eruda.min.js"></script>
    <script>eruda.init();</script>
</div>

<script>
    function showTab(tabId) {
        document.querySelectorAll('.tab-content').forEach(tab => {
            tab.classList.remove('active');
        });
        document.querySelectorAll('.tab').forEach(tab => {
            tab.classList.remove('active-tab');
        });
        document.getElementById(tabId).classList.add('active');
        event.target.classList.add('active-tab');
    }

    document.getElementById('proxyForm').onsubmit = async function(event) {
        event.preventDefault();
        const url = event.target.url.value;
        const response = await fetch('/proxy', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams({ url })
        });
        const result = await response.text();
        document.getElementById('proxyResult').innerHTML = result;
    };
</script>

</body>
</html>
EOL

# Run the Flask application
echo "Starting the Flask application..."
python3 app.py
