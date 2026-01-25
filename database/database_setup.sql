-- configuring the database to use utf8mb4 character set for full unicode support
SET NAMES utf8mb4;

-- Creating the database
CREATE DATABASE IF NOT EXISTS HIT_momo_analyzer;
USE HIT_momo_analyzer;

-- 1. Creating the sms_messages table to store raw sms
CREATE TABLE IF NOT EXISTS sms_messages (
  sms_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Internal unique identifier for each SMS',

  sms_body LONGTEXT NOT NULL COMMENT 'The full raw text content of the SMS message',

  date_recorded DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the SMS message was recorded into the database',

  read_status BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Indicates whether the SMS message has been read/analyzed'
  
) ENGINE=InnoDB;

-- 2. Creating the users/customers table to store personal information
CREATE TABLE IF NOT EXISTS users (
  user_id VARCHAR(15) PRIMARY KEY COMMENT 'Internal unique identifier for each User',

  full_name VARCHAR(100) NOT NULL COMMENT 'Full name of the user',

  phone_number VARCHAR(20) NOT NULL COMMENT 'Phone number of the user associated with their MoMo account',

  id_number VARCHAR(50) NOT NULL COMMENT 'National Id number of the user',

  date_of_birth DATE NOT NULL COMMENT 'Date of birth of the user',

  account_balance DECIMAL(10, 2) NOT NULL DEFAULT 0.00 COMMENT 'Current balance in their account',

  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the user was created',

  -- adding unique constraint to prevent duplicate phone numbers and national id numbers
    CONSTRAINT unique_phone_number UNIQUE (phone_number),
    CONSTRAINT unique_id_number UNIQUE (id_number) 

) ENGINE=InnoDB;

-- 3. Creating the transaction_categories table to store different categories of transactions
CREATE TABLE IF NOT EXISTS transaction_categories (
  transaction_category_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Internal unique identifier for each transaction category',

  category_name VARCHAR(50) NOT NULL COMMENT 'Name of the transaction category',

  category_description VARCHAR(100) NULL COMMENT 'Short description of the purpose of the transaction category',

  -- adding unique constraint to prevent duplicate category names
    CONSTRAINT unique_category_name UNIQUE (category_name)

) ENGINE=InnoDB;

-- 4. Creating the transactions table to store individual transactions from the sms
CREATE TABLE IF NOT EXISTS transactions (
  transaction_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Internal unique identifier for each transaction',

  transaction_category_id INT NOT NULL COMMENT 'Foreign key referencing the transaction category',

  sms_id INT NOT NULL COMMENT 'Foreign key referencing the sms message from which this transaction was extracted',

  transaction_reference VARCHAR(50) NOT NULL COMMENT 'Reference code for the transaction provided in the SMS',

  currency VARCHAR(20) NOT NULL COMMENT 'Currency type of the transaction amount',

  amount DECIMAL(10, 2) NOT NULL COMMENT 'Amount involved in the transaction',

  service_fee DECIMAL(6, 2) NOT NULL DEFAULT 0.00 COMMENT 'Service fee charged for the transaction, 0 if none',

  transaction_status ENUM('SUCCESS', 'FAILED', 'PENDING') NOT NULL COMMENT 'Status of the transaction',

  transaction_date DATETIME NOT NULL COMMENT 'Date and time when the transaction occurred',

  -- Foreign key constraints

    -- each transaction must belong to a valid category and restrict deleting categories with existing transactions
    CONSTRAINT fk_transaction_category FOREIGN KEY (transaction_category_id) REFERENCES transaction_categories(transaction_category_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    -- each transaction must be linked to a valid sms message and restrict deleting sms messages that have been analyzed into transactions
    CONSTRAINT fk_transaction_sms_message FOREIGN KEY (sms_id) REFERENCES sms_messages(sms_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,

    -- Unique Keys for sms_id and transaction_reference to prevent duplicate transactions from the same sms or with the same reference
    CONSTRAINT unique_transactions_sms UNIQUE (sms_id),
    CONSTRAINT unique_transaction_reference UNIQUE (transaction_reference),

    -- adding check constraints to ensure amount and service fee are not negative
    CONSTRAINT chk_amount_positive CHECK (amount >= 0),
    CONSTRAINT chk_fee_positive CHECK (service_fee >= 0),

    -- Foreign key indexes
    KEY idx_transactions_category (transaction_category_id),
    KEY idx_transactions_sms (sms_id),
    KEY idx_transaction_date (transaction_date)

) ENGINE=InnoDB;

-- 5. Creating the Transaction_Participants table to store participants involved in each transaction (Link Table for Many-to-Many relationship of Transactions and Users)
CREATE TABLE IF NOT EXISTS transaction_participants (
    participant_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Internal unique identifier for each transaction participant record',

    transaction_id INT NOT NULL COMMENT 'Foreign key referencing the transaction involved',

    user_id VARCHAR(15) NOT NULL COMMENT 'Foreign key referencing the user involved in the transaction',

    user_role ENUM('SENDER', 'RECEIVER', 'INITIATOR') NOT NULL COMMENT 'Role of the user in the transaction',

    balance_after DECIMAL(10, 2) NOT NULL COMMENT 'Account balance after the transaction was processed for historical tracking',

    -- Foreign key constraints
    -- each participant must be linked to a valid transaction and delete associated participants if the transaction is deleted
    CONSTRAINT fk_transaction_participated FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    -- each participant must be linked to a valid user and restrict deleting users that are involved in transactions
    CONSTRAINT fk_user_participant FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- preventing duplicate entries for the same user in the same transaction with the same role
    CONSTRAINT uq_transaction_user_role UNIQUE (transaction_id, user_id, user_role),

    -- creating indexes for optimization
    KEY idx_tp_transaction (transaction_id),
    KEY idx_tp_user (user_id)
    
) ENGINE=InnoDB;

-- 6. Creating the system_logs table to store logs for each analysis operation
CREATE TABLE IF NOT EXISTS system_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Internal unique identifier for each log entry',

    transaction_id INT NULL COMMENT 'Foreign key referencing the transaction involved, NULL if the log had not processed a transaction successfully',

    sms_id INT NULL COMMENT 'Foreign key referencing the sms message being analyzed, NULL if the SMS message was deleted after logging',

    log_message TEXT NOT NULL COMMENT 'Detailed log message describing the operation or error encountered during analysis',

    logged_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the log entry was created',

    log_level ENUM('INFO', 'WARNING', 'ERROR') NOT NULL COMMENT 'Severity level of the log entry',

    -- Foreign key constraints
    -- each log may be linked to a transaction if analysed successfully, set to NULL if the transaction is deleted
    CONSTRAINT fk_log_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
        ON DELETE SET NULL ON UPDATE CASCADE,

    -- each log may be linked to an sms message, set to NULL if the sms message is deleted
    CONSTRAINT fk_log_sms_message FOREIGN KEY (sms_id) REFERENCES sms_messages(sms_id)
        ON DELETE SET NULL ON UPDATE CASCADE,

    -- adding log indexes for optimization
    KEY idx_logs_level (log_level),
    KEY idx_logs_transaction (transaction_id),
    KEY idx_logs_sms (sms_id)
        
) ENGINE=InnoDB;

-- End of database setup script for HIT_momo_analyzer



-- ==== Staring Records Insertion ====

-- adding sample data in the sms_messages table, ignore if the sms_id already exists
INSERT IGNORE INTO sms_messages (sms_id, sms_body, date_recorded, read_status) VALUES
(1, '<sms protocol="0" address="M-Money" date="1715351458724" type="1" subject="null" body="You have received 2000 RWF from Jane Smith (*********013) on your mobile money account at 2024-05-10 16:30:51. Message from sender: . Your new balance:2000 RWF. Financial Transaction Id: 76662021700." toa="null" sc_toa="null" service_center="+250788110381" read="1" status="-1" locked="0" date_sent="1715351451000" sub_id="6" readable_date="10 May 2024 4:30:58 PM" contact_name="unknown" />', '2026-01-01 10:15:00', TRUE),

(2, '<sms protocol="0" address="M-Money" date="1732361032157" type="1" subject="null" body="You Abebe Chala CHEBUDIE (*********036) have via agent: Agent Sophia (250788999999), withdrawn 50000 RWF from your mobile money account: 36521838 at 2024-11-23 13:23:44 and you can now collect your money in cash. Your new balance: 2401 RWF. Fee paid: 1100 RWF. Message from agent: 1. Financial Transaction Id: 17006777609." toa="null" sc_toa="null" service_center="+250788110383" read="1" status="-1" locked="0" date_sent="1732361024000" sub_id="6" readable_date="23 Nov 2024 1:23:52" contact_name="unknown" />', '2026-01-02 14:30:00', TRUE),

(3, '<sms protocol="0" address="M-Money" date="1715445936412" type="1" subject="null" body="*113*R*A bank deposit of 40000 RWF has been added to your mobile money account at 2024-05-11 18:43:49. Your NEW BALANCE :40400 RWF. Cash Deposit::CASH::::0::250795963036.Thank you for using MTN MobileMoney.*EN#" toa="null" sc_toa="null" service_center="+250788110381" read="1" status="-1" locked="0" date_sent="1715445829000" sub_id="6" readable_date="11 May 2024 6:45:36 PM" contact_name="unknown" />', '2026-01-01 09:45:00', FALSE),  

(4, '<sms protocol="0" address="M-Money" date="1715452495316" type="1" subject="null" body="*165*S*10000 RWF transferred to Samuel Carter (250791666666) from 36521838 at 2024-05-11 20:34:47 . Fee was: 100 RWF. New balance: 28300 RWF. Kugura ama inite cg interineti kuri MoMo, Kanda *182*2*1# .*EN#" toa="null" sc_toa="null" service_center="+250788110381" read="1" status="-1" locked="0" date_sent="1715452487000" sub_id="6" readable_date="11 May 2024 8:34:55 PM" contact_name="unknown" />', '2026-01-08 16:20:00', TRUE),

(5, '<sms protocol="0" address="M-Money" date="1715506895734" type="1" subject="null" body="*162*TxId:13913173274*S*Your payment of 2000 RWF to Airtime with token has been completed at 2024-05-12 11:41:28. Fee was 0 RWF. Your new balance: 25280 RWF . Message: - -. *EN#" toa="null" sc_toa="null" service_center="+250788110381" read="1" status="-1" locked="0" date_sent="1715506888000" sub_id="6" readable_date="12 May 2024 11:41:28 AM" contact_name="unknown" />', '2026-01-05 11:10:00', TRUE),

(6, '<sms address="M-Money" body="Malformed SMS: missing transaction id and amount" />', '2026-01-10 12:00:00', FALSE);

-- Adding sample data in the transaction_categories table, ignore if the category_name already exists
INSERT IGNORE INTO transaction_categories (category_name, category_description) VALUES
('Transfer', 'Money transferred between accounts'),
('Payment', 'Payment for goods or services'),
('Deposit', 'Cash deposit into account'),
('Withdrawal', 'Cash withdrawal from account'),
('Airtime Purchase', 'Purchase of mobile airtime credit');

-- Adding sample data in the users table, ignore if the user_id already exists
INSERT IGNORE INTO users (user_id, full_name, phone_number, id_number, date_of_birth) VALUES
('HIT-User-001', 'Helen Okereke', '+25078678567', 'A123456789', '1990-05-15'),
('HIT-User-002', 'Toluwani Oladeji', '+25078812345', 'B987654321', '1985-10-20'),
('HIT-User-003', 'Ikenna Onugha', '+25078956789', 'C456789123', '2002-07-30'),
('HIT-User-004', 'Samuel Carter', '+25078765432', 'A321654987', '2004-12-05'),
('HIT-User-005', 'Jane Smith', '+25078543210', 'B654987321', '1992-03-25');

-- Adding sample data in the transactions table, ignore if the transaction_reference already exists
INSERT IGNORE INTO transactions (transaction_category_id, sms_id, transaction_reference, currency, amount, service_fee, transaction_status, transaction_date) VALUES
(1, 1, '76662021700', 'RWF', 2000.00, 0.00, 'SUCCESS', '2024-05-10 16:30:51'),
(4, 2, '17006777609', 'RWF', 50000.00, 1100.00, 'SUCCESS', '2024-11-23 13:23:44'),
(3, 3, 'TXN123458', 'RWF', 40000.00, 0.00, 'PENDING', '2024-05-11 18:43:49'),
(1, 4, 'TXN123459', 'RWF', 10000.00, 100.00, 'FAILED', '2024-05-11 20:34:47'),
(5, 5, '13913173274', 'RWF', 2000.00, 0.00, 'SUCCESS', '2024-05-12 11:41:28');

-- Adding sample data in the transaction_participants table, ignore if the combination of transaction_id, user_id, and user_role already exists
INSERT IGNORE INTO transaction_participants (transaction_id, user_id, user_role, balance_after) VALUES
(1, 'HIT-User-005', 'SENDER', 4500.00),
(1, 'HIT-User-001', 'RECEIVER', 2000.00),
(5, 'HIT-User-001', 'INITIATOR', 25280.00),
(3, 'HIT-User-002', 'RECEIVER', 40400.00),
(4, 'HIT-User-004', 'RECEIVER', 28300.00);

-- updating account_balance for users based on sample transactions
UPDATE users
SET account_balance = CASE user_id
  WHEN 'HIT-User-005' THEN 4500
  WHEN 'HIT-User-001' THEN 25280
  WHEN 'HIT-User-002' THEN 40400
  WHEN 'HIT-User-004' THEN 28300
  ELSE account_balance
END
WHERE user_id IN ('HIT-User-005','HIT-User-001','HIT-User-002','HIT-User-004');


-- Adding sample data in the system_logs table
INSERT INTO system_logs (transaction_id, sms_id, log_message, log_level) VALUES
(1, 1, 'Transaction 76662021700 successfully processed from SMS 1', 'INFO'),
(2, 2, 'Transaction 17006777609 successfully processed from SMS 2', 'INFO'),
(NULL, 6, 'Failed to process transaction from SMS 6. No information available on the body', 'ERROR'),
(3, 3, 'Transaction registered on the database', 'INFO'),
(3, 3, 'Could not add the transaction sender information', 'WARNING'),
(5, 5, 'Transaction 13913173274 successfully processed from SMS 5', 'INFO');

-- Adding a check during insert and update to ensure no user under 16 years can be added or updated
DELIMITER $$

CREATE TRIGGER trg_users_min_age BEFORE INSERT ON users FOR EACH ROW
BEGIN
  IF TIMESTAMPDIFF(YEAR, NEW.date_of_birth, CURDATE()) < 16 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'User must be at least 16 years old';
  END IF;
END$$

CREATE TRIGGER trg_users_min_age_update BEFORE UPDATE ON users FOR EACH ROW
BEGIN
  IF TIMESTAMPDIFF(YEAR, NEW.date_of_birth, CURDATE()) < 16 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'User must be at least 16 years old';
  END IF;
END$$

DELIMITER ;
