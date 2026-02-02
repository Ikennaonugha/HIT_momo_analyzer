import json
import time


# Load cleaned transactions from JSON file
with open("../transactions.json", "r") as file:
    transactions_file = json.load(file)   # List of transaction dictionaries

# Linear Search (Scan through List)
def linear_search(transactions_file, target_id):
    # search for a transaction by ID using linear search
    for transaction in transactions_file:
        if transaction["id"] == target_id:
            return transaction
    return None

# Dictionary Lookup (Hash Map)
def build_transaction_dict(transactions_file):
    # Convert into a dictionary of transactions with ID as key
    transaction_dict = {}
    for transaction in transactions_file:
        transaction_dict[transaction["id"]] = transaction
    return transaction_dict

def dict_search(transaction_dict, target_id):
    # Searches for transaction by ID in the dictionary
    return transaction_dict.get(target_id)


# Compare Efficiency
if __name__ == "__main__":
    target_id = 0  # testing ID (incrementing by loop)
    search_limit = 21 # Search Limit/Number of Records to search for
    linear_search_time = 0 # Calculating the total linear search time
    dict_search_time = 0 # Calculating the total dictionary search time

    # Results
    print("Search Results")

    # searching 20+ records using Linear method
    while target_id < search_limit:
        if target_id == 0:
            print("\nLinear Search Result:")
        # Calculating Linear search timing
        start_time = time.time()
        linear_result = linear_search(transactions_file, transactions_file[target_id]["id"])
        linear_time = time.time() - start_time
        print(linear_result)
        linear_search_time += linear_time

        # Increasing target ID after each search
        target_id = target_id + 1

    # resetting target ID to 0, so it starts again for Dictionary search
    target_id = 0

    #searching 20+ records using Dictionary Search Method
    while target_id < search_limit:
        if target_id == 0:
            print("\nDictionary Search Results")
            transaction_dict = build_transaction_dict(transactions_file)
        # Calculating Dictionary search time
        start_time = time.time()
        dict_result = dict_search(transaction_dict, transactions_file[target_id]["id"])
        dict_time = time.time() - start_time
        print(dict_result)
        dict_search_time += dict_time

        # Increasing target ID after each search
        target_id = target_id + 1

    # Printing each search time in both the scientific time and micro seconds in bracket
    print(
        "\nLinear Search Time:",
        linear_search_time,
        "(",
        round(linear_search_time * 1_000_000, 2),
        "microseconds)"
    )
    print(
        "Dictionary Search Time:",
        dict_search_time,
        "(",
        round(dict_search_time * 1_000_000, 2),
        "microseconds)"
    )

    if linear_search_time > dict_search_time:
        print("\n\tDictionary Search Method is more Efficient as it took less time")
    else:
        print("\n\tLinear Search Method is more Efficient as it took less time")
