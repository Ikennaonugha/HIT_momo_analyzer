# MoMo SMS Data Processor

## Team Information

**Team Name:** HIT Enterprise Web Dev

**Project Description:**  
An enterprise-level fullstack application that processes Mobile Money (MoMo) SMS transaction data in XML format, cleans and categorizes the data, stores it in a relational database, and provides an interactive web dashboard for data analysis and visualization.

## Team Members

| Name | GitHub Username | Role |
|------|----------------|------|
| Ikenna Onugha | [@IkennaOnugha](https://github.com/IkennaOnugha) | Project Initiator |
| Helen Okereke | [@Helen751](https://github.com/Helen751) | Architecture Designer|
| Oladeji Toluwani | [@ToluwaniOladeji](https://github.com/ToluwaniOladeji) | Scrum Master |
---

## Project Links

- **System Architecture (Draw.io):** 
![MoMo SMS Analytics System Architecture](docs/architecture.png)

[View Project Architecture diagram here](https://viewer.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&edit=_blank&layers=1&nav=1&title=HIT-MoMo%20SMS%20Analytics.drawio&dark=auto#Uhttps%3A%2F%2Fdrive.google.com%2Fuc%3Fid%3D1mZt3cSCx2Y3F8TUrAiWjpK6ndlS66URa%26export%3Ddownload#%7B%22pageId%22%3A%22HOtfubfBUdEroN17rY5i%22%7D)

- **Scrum Board:** 

https://trello.com/invite/b/6964ec42a2764124d9b2113d/ATTI59609c82b8a1cea0c8fa31e266cf794f0E943E2B/momo-sms-analyzer-scrum-board


## Database Architecture
The system uses a MySQL 8.0 database named HIT_momo_analyzer.

Core Entities
Users: Stores KYC information (ID numbers, DOB, Balance).

Transactions: The central ledger for financial movements.

Transaction Participants: A junction table managing roles (Sender/Receiver).

SMS Messages: Stores the raw XML-formatted SMS strings.

System Logs: Tracks processing status and errors.

Data Mapping: SQL to JSON
To bridge the gap between our relational storage and modern API requirements, we map our tables to JSON objects.

| SQL Table | JSON Object | Key Mapping |
|------|----------------|------|
| users | user| id_number → id_number |
| transactions | financials | amount → amount|
| transaction_participants | participants | Map rows to a Nested Array [] |

Complex Object Logic
The system serializes a "Complete Transaction" by joining the transactions table with its participants. In JSON, this is represented as a single object where the sender and receiver are nested inside an array, making it easier for mobile front-ends to render the transaction details.

SQL to JSON Mapping (Task 3 Documentation)

Mapping Logic Documentation: Our serialization strategy converts the flat SQL structure into a hierarchical JSON format. For instance, the Transaction JSON object does not just show the transaction_category_id; it performs a lookup to provide the category_name.

Handling Relationships: > The Many-to-Many relationship in transaction_participants is converted from multiple database rows into a single JSON array of objects. This reduces the number of API calls needed to identify all parties involved in a transfer.


## CRUD OPERATIONS (DATABASE TEST)

### Inserting a new user to the users table (SUCCESS)
![New User Insert](docs/crud%20tests/crud_test2.png)

### Inserting a new transaction (SUCCESS)
![New Transaction Inserted](docs/crud%20tests/crud_test4.png)

### Read Operation: Viewing transactions with their categories sorted fron newest to oldest (SUCCESS)
![Read Transactions](docs/crud%20tests/crud_test3.png)

### Update Operation: Updating the user's account balance (SUCCESS)
![User Balance Update](docs/crud%20tests/crud_test9.png)

### Delete Operation: Deleting a transaction category referenced in transactions (RESTRICTED)
![Delete Transaction Category](docs/crud%20tests/crud_test8.png)

### Insert Operation (Key check: Inserting new transaction specifying a category that does not exist)
![Insert into Transactions](docs/crud%20tests/crud_test6.png)

### Check Constraint: Inserting a negative value to the transaction amount column
![Check Constraint](docs/crud%20tests/crud_test7.png)


## Project Structure

```
.
├── README.md                         # Setup, run, overview
├── .env.example                      # DATABASE_URL or path to SQLite
├── .gitignore                        # Git ignore rules
├── requirements.txt                  # Python dependencies
├── index.html                        # Dashboard entry (static)
├── docs/
│   └── architecture.png              # System architecture diagram
├── web/
│   ├── styles.css                    # Dashboard styling
│   ├── chart_handler.js              # Fetch + render charts/tables
│   └── assets/                       # Images/icons (optional)
├── data/
│   ├── raw/                          # Provided XML input
│   │   └── momo.xml
│   ├── processed/                    # Cleaned/derived outputs for frontend
│   │   └── dashboard.json            # Aggregates the dashboard reads
│   ├── db.sqlite3                    # SQLite DB file
│   └── logs/
│       ├── etl.log                   # Structured ETL logs
│       └── dead_letter/              # Unparsed/ignored XML snippets
├── etl/
│   ├── __init__.py
│   ├── config.py                     # File paths, thresholds, categories
│   ├── parse_xml.py                  # XML parsing (ElementTree/lxml)
│   ├── clean_normalize.py            # Amounts, dates, phone normalization
│   ├── categorize.py                 # Simple rules for transaction types
│   ├── load_db.py                    # Create tables + upsert to SQLite
│   └── run.py                        # CLI: parse -> clean -> categorize -> load -> export JSON
├── api/                              # Optional (bonus)
│   ├── __init__.py
│   ├── app.py                        # Minimal FastAPI with /transactions, /analytics
│   ├── db.py                         # SQLite connection helpers
│   └── schemas.py                    # Pydantic response models
├── scripts/
│   ├── run_etl.sh                    # python etl/run.py --xml data/raw/momo.xml
│   ├── export_json.sh                # Rebuild data/processed/dashboard.json
│   └── serve_frontend.sh             # python -m http.server 8000 (or Flask static)
└── tests/
    ├── test_parse_xml.py             # Small unit tests
    ├── test_clean_normalize.py
    └── test_categorize.py

## Setup Instructions (Coming Soon)

### Prerequisites
- Python 3.8+
- Git
- Web Browser

### Installation
```bash
# Clone the repository
git clone https://github.com/IkennaOnugha/HIT_momo_analyzer.git
cd HIT_momo_analyzer

# Install dependencies
pip install -r requirements.txt

# Copy environment template
cp .env.example .env
```

### Running the Application
```bash
# Run ETL Pipeline
bash scripts/run_etl.sh

# Start Frontend Server
bash scripts/serve_frontend.sh
```

---

## Technologies Used

### Backend
- Python 3.8+
- lxml / ElementTree
- SQLite
- FastAPI 

### Frontend
- HTML5
- CSS3
- JavaScript (ES6+)
- Chart.js / D3.js

### Development Tools
- Git, GitHub and Trello(Project Management)

**Last Updated:** January 2026
