from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import re

DATA_FILE = "transactions.json"

# Load data at startup
def load_transactions():
    try:
        with open(DATA_FILE, "r") as f:
            data = json.load(f)
            return data
    except FileNotFoundError:
        return []

transactions = load_transactions()
transactions_dict = {txn["id"]: txn for txn in transactions}
