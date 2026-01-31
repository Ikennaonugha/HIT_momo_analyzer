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


class TransactionHandler(BaseHTTPRequestHandler):

    def _send_response(self, status=200, data=None):
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        if data is not None:
            self.wfile.write(json.dumps(data, indent=4).encode())
