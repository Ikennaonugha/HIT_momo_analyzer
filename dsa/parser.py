import xml.etree.ElementTree as ET
import json
import re
import time

def parse_momo_data(file_path):
    try:
        tree = ET.parse(file_path)
        root = tree.getroot()
        transactions_list = []
        non_transactions_list = []

        for index, sms in enumerate(root.findall('sms')):
            body = sms.get('body', '')
            
            # Check if it's a financial transaction
            is_transaction = "RWF" in body

            if not is_transaction:
                # Log non-transactional messages
                non_transaction = {
                    "index": index,
                    "address": sms.get('address'),
                    "date": sms.get('readable_date'),
                    "body": body
                }
                non_transactions_list.append(non_transaction)
                continue # Skip the rest of the loop for this message

            # --- ALL CODE BELOW IS NOW INSIDE THE LOOP ---
            
            # 1. System-Generated ID (Sequential based on valid transactions found so far)
            system_id = f"TXN{str(len(transactions_list) + 1).zfill(3)}"

            # 2. Extract Financial ID
            tx_id_search = re.search(r'(?:TxId:|Transaction Id:)\s*(\d+)', body)
            transaction_id = tx_id_search.group(1) if tx_id_search else "N/A"

            # 3. Improved Amount Extraction
            amount_match = re.search(r'([\d,.]+)\s*RWF', body)
            if amount_match:
                amount_str = amount_match.group(1).replace(',', '')
                try:
                    amount = float(amount_str)
                except ValueError:
                    amount = 0.0
            else:
                amount = 0.0

            # 4. Extract Participants
            from_match = re.search(r'from\s+([A-Za-z\s]{3,25}?)[\s(]', body)
            to_match = re.search(r'to\s+([A-Za-z\s]{3,25}?)[\s\d]', body)
            
            sender = "System/Bank"
            receiver = "User"

            if "received" in body.lower() or "deposit" in body.lower():
                sender = from_match.group(1).strip() if from_match else "MoMo Service"
            elif "transferred" in body.lower() or "payment" in body.lower():
                receiver = to_match.group(1).strip() if to_match else "Unknown Recipient"
                sender = "User"

            # 5. Build the record
            record = {
                "id": system_id,
                "transaction_id": transaction_id,
                "sender": sender,
                "receiver": receiver,
                "amount": amount,
                "currency": "RWF",
                "date": sms.get('readable_date'),
                "type": "Income" if "received" in body.lower() or "deposit" in body.lower() else "Payment",
                "body": body
            }
            transactions_list.append(record)

        return transactions_list, non_transactions_list

    except Exception as e:
        print(f"Error parsing XML: {e}")
        return [], []

if __name__ == "__main__":
    # Ensure this path is correct relative to where you run the script!
    # If running from project root: 'dsa/modified_sms_v2.xml'
    # If running from inside dsa folder: 'modified_sms_v2.xml'
    parsed_data, skipped_data = parse_momo_data('dsa/modified_sms_v2.xml')
    
    if parsed_data or skipped_data:
        print(f"Successfully processed {len(parsed_data) + len(skipped_data)} messages.")
        run_dsa_comparison(parsed_data)
        
        with open('transactions.json', 'w') as f:
            json.dump(parsed_data, f, indent=4)
        
        with open('non_transactions.json', 'w') as f:
            json.dump(skipped_data, f, indent=4)
            
        print(f"Saved: {len(parsed_data)} transactions, {len(skipped_data)} non-transactions.")


