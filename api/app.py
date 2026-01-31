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
    

    
    def do_GET(self):
        if self.path == "/transactions":
            self._send_response(200, transactions)

        else:
            match = re.match(r"/transactions/(TXN\d+)", self.path)
            if match:
                txn_id = match.group(1)
                txn = transactions_dict.get(txn_id)
                if txn:
                    self._send_response(200, txn)
                else:
                    self._send_response(404, {"error": "Transaction not found"})
            else:
                self._send_response(404, {"error": "Invalid endpoint"})


    def do_POST(self):
        if self.path != "/transactions":
            self._send_response(404, {"error": "Invalid endpoint"})
            return

        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length)

        try:
            new_txn = json.loads(body)

            new_id = f"TXN{str(len(transactions) + 1).zfill(3)}"
            new_txn["id"] = new_id

            transactions.append(new_txn)
            transactions_dict[new_id] = new_txn

            self._send_response(201, new_txn)

        except json.JSONDecodeError:
            self._send_response(400, {"error": "Invalid JSON body"})

    def do_PUT(self):
        match = re.match(r"/transactions/(TXN\d+)", self.path)
        if not match:
            self._send_response(404, {"error": "Invalid endpoint"})
            return

        txn_id = match.group(1)

        if txn_id not in transactions_dict:
            self._send_response(404, {"error": "Transaction not found"})
            return

        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length)

        try:
            updated_data = json.loads(body)
            updated_data["id"] = txn_id

            transactions_dict[txn_id].update(updated_data)
            self._send_response(200, transactions_dict[txn_id])

        except json.JSONDecodeError:
            self._send_response(400, {"error": "Invalid JSON body"})

    def do_DELETE(self):
        match = re.match(r"/transactions/(TXN\d+)", self.path)
        if not match:
            self._send_response(404, {"error": "Invalid endpoint"})
            return

        txn_id = match.group(1)

        txn = transactions_dict.pop(txn_id, None)
        if not txn:
            self._send_response(404, {"error": "Transaction not found"})
            return

        transactions.remove(txn)
        self._send_response(200, {"message": "Transaction deleted"})


def run(server_class=HTTPServer, handler_class=TransactionHandler, port=8000):
    server_address = ("", port)
    httpd = server_class(server_address, handler_class)
    print(f"Server running on port {port}")
    httpd.serve_forever()


if __name__ == "__main__":
    run()
    




    
