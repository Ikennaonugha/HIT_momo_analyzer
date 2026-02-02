# MoMo Transaction API Documentation

## Overview

The MoMo Transaction API is a REST API for managing mobile money transactions. It provides endpoints to create, read, update, and delete transaction records.

## Base URL

```
http://localhost:8000
```

## Authentication

All endpoints require HTTP Basic Authentication.

### Credentials

- **Username:** `admin`
- **Password:** `Banana_boy`

### Authentication Header

```
Authorization: Basic YWRtaW46QmFuYW5hX2JveQ==
```

### Example

```bash
curl -u admin:Banana_boy http://localhost:8000/transactions
```

---

## Endpoints

### 1. Get All Transactions

Retrieves a list of all transactions.

- **URL:** `/transactions`
- **Method:** `GET`
- **Auth Required:** Yes

#### Request Example

```bash
curl -X GET http://localhost:8000/transactions \
  -u admin:Banana_boy
```

#### Success Response

- **Code:** `200 OK`
- **Content:**

```json
[
    {
        "id": "TXN1680",
        "transaction_id": "26811810649",
        "sender": "User",
        "receiver": "Jane",
        "amount": 6000.0,
        "currency": "RWF",
        "date": "15 Jan 2025 5:21:46 PM",
        "type": "Payment",
        "body": "*165*S*6000 RWF transferred to Jane Smith (250788999999) from 36521838 at 2025-01-15 17:21:35 . Fee was: 100 RWF. New balance: 58300 RWF. Kugura ama inite cg interineti kuri MoMo, Kanda *182*2*1# .*EN#"
    }
]
```

#### Error Response

- **Code:** `401 Unauthorized`
- **Content:**

```
Unauthorized
```

---

### 2. Get Single Transaction

Retrieves a specific transaction by ID.

- **URL:** `/transactions/{id}`
- **Method:** `GET`
- **Auth Required:** Yes
- **URL Parameters:** `id` (required) - ID in format `TXN###`

#### Request Example

```bash
curl -X GET http://localhost:8000/transactions/TXN1680 \
  -u admin:Banana_boy
```

#### Success Response

- **Code:** `200 OK`
- **Content:**

```json
{
    "id": "TXN1680",
    "transaction_id": "26811810649",
    "sender": "User",
    "receiver": "Jane",
    "amount": 6000.0,
    "currency": "RWF",
    "date": "15 Jan 2025 5:21:46 PM",
    "type": "Payment",
    "body": "*165*S*6000 RWF transferred to Jane Smith (250788999999) from 36521838 at 2025-01-15 17:21:35 . Fee was: 100 RWF. New balance: 58300 RWF. Kugura ama inite cg interineti kuri MoMo, Kanda *182*2*1# .*EN#"
}
```

#### Error Responses

- **Code:** `401 Unauthorized`
- **Content:**

```
Unauthorized
```

- **Code:** `404 Not Found`
- **Content:**

```json
{
    "error": "Transaction not found"
}
```

---

### 3. Create New Transaction

Creates a new transaction. The `id` field is auto-generated.

- **URL:** `/transactions`
- **Method:** `POST`
- **Auth Required:** Yes
- **Content-Type:** `application/json`

#### Request Body

All fields are required except 'id' is required.

```json
{
    "transaction_id": "string",
    "sender": "string",
    "receiver": "string",
    "amount": float,
    "currency": "string",
    "date": "string",
    "type": "string",
    "body": "string"
}
```

#### Request Example

```bash
curl -X POST http://localhost:8000/transactions \
  -u admin:Banana_boy \
  -H "Content-Type: application/json" \
  -d '{
    "transaction_id": "26811810649",
    "sender": "Alice",
    "receiver": "Bob",
    "amount": 5000.0,
    "currency": "RWF",
    "date": "02 Feb 2026 10:30:00 AM",
    "type": "Payment",
    "body": "Payment details here"
  }'
```

#### Success Response

- **Code:** `201 Created`
- **Content:**

```json
{
    "id": "TXN001",
    "transaction_id": "26811810649",
    "sender": "Alice",
    "receiver": "Bob",
    "amount": 5000.0,
    "currency": "RWF",
    "date": "02 Feb 2026 10:30:00 AM",
    "type": "Payment",
    "body": "SMS Message body"
}
```

#### Error Responses

- **Code:** `400 Bad Request`
- **Content:**

```json
{
    "error": "Invalid JSON body"
}
```

- **Code:** `401 Unauthorized`
- **Content:**

```
Unauthorized
```

---

### 4. Update Transaction

Updates an existing transaction. The `id` field cannot be changed and will be preserved.

- **URL:** `/transactions/{transaction_id}`
- **Method:** `PUT`
- **Auth Required:** Yes
- **URL Parameters:** `transaction_id` (required) - Transaction ID in format `TXN###`
- **Content-Type:** `application/json`

#### Request Body

Include only the fields you want to update.

```json
{
    "transaction_id": "string (optional)",
    "sender": "string (optional)",
    "receiver": "string (optional)",
    "amount": float (optional),
    "currency": "string (optional)",
    "date": "string (optional)",
    "type": "string (optional)",
    "body": "string (optional)"
}
```

#### Request Example

```bash
curl -X PUT http://localhost:8000/transactions/TXN1680 \
  -u admin:Banana_boy \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 7000.0,
    "type": "Refund"
  }'
```

#### Success Response

- **Code:** `200 OK`
- **Content:**

```json
{
    "id": "TXN1680",
    "transaction_id": "26811810649",
    "sender": "User",
    "receiver": "Jane",
    "amount": 7000.0,
    "currency": "RWF",
    "date": "15 Jan 2025 5:21:46 PM",
    "type": "Refund",
    "body": "*165*S*6000 RWF transferred to Jane Smith (250788999999) from 36521838 at 2025-01-15 17:21:35 . Fee was: 100 RWF. New balance: 58300 RWF. Kugura ama inite cg interineti kuri MoMo, Kanda *182*2*1# .*EN#"
}
```

#### Error Responses

- **Code:** `400 Bad Request`
- **Content:**

```json
{
    "error": "Invalid JSON body"
}
```

- **Code:** `401 Unauthorized`
- **Content:**

```
Unauthorized
```

- **Code:** `404 Not Found`
- **Content:**

```json
{
    "error": "Transaction not found"
}
```

---

### 5. Delete Transaction

Deletes a transaction by ID.

- **URL:** `/transactions/{transaction_id}`
- **Method:** `DELETE`
- **Auth Required:** Yes
- **URL Parameters:** `transaction_id` (required) - Transaction ID in format `TXN###`

#### Request Example

```bash
curl -X DELETE http://localhost:8000/transactions/TXN1680 \
  -u admin:Banana_boy
```

#### Success Response

- **Code:** `200 OK`
- **Content:**

```json
{
    "message": "Transaction deleted"
}
```

#### Error Responses

- **Code:** `401 Unauthorized`
- **Content:**

```
Unauthorized
```

- **Code:** `404 Not Found`
- **Content:**

```json
{
    "error": "Transaction not found"
}
```

---

## HTTP Status Codes

| Status Code | Description |
|-------------|-------------|
| `200 OK` | Request successful |
| `201 Created` | Resource successfully created |
| `400 Bad Request` | Invalid request body or malformed JSON |
| `401 Unauthorized` | Missing or invalid authentication credentials |
| `404 Not Found` | Endpoint or resource not found |

---

## Transaction Object Schema

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Auto-generated unique identifier (format: `TXN###`) |
| `transaction_id` | string | External transaction reference |
| `sender` | string | Name of the sender |
| `receiver` | string | Name of the receiver |
| `amount` | float | Transaction amount |
| `currency` | string | Currency code (e.g., `RWF`) |
| `date` | string | Transaction date and time |
| `type` | string | Transaction type (e.g., `Payment`, `Refund`) |
| `body` | string | Detailed transaction message/description |

---

## Notes

- All requests must include valid Basic Authentication credentials
- Transaction IDs follow the format `TXN###` (e.g., `TXN001`, `TXN002`, `TXN1680`)
- IDs are auto-generated sequentially when creating new transactions
- The server runs on port `8000` by default
- Data is loaded from `data/processed/transactions.json` at startup
- **Important:** Changes are stored in memory only and are **not persisted** to the file system

---

## Getting Started

### Prerequisites

- Python 3.x
- The `transactions.json` file in `data/processed/` directory

### Running the Server

```bash
python app.py
```

The server will start on `http://localhost:8000`


---
