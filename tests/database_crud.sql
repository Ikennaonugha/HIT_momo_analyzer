# specifying the database to use
USE HIT_momo_analyzer;
INSERT IGNORE INTO users (user_id, full_name, phone_number, id_number, date_of_birth) VALUES
('HIT-User-006', 'Linda Ikirezi', '+25078678511', 'TZ123456789', '2005-05-15');
SELECT * FROM users WHERE user_id = 'HIT-User-006';

# viewing transactions with their categories from newest to oldest
SELECT t.transaction_id, t.transaction_reference, c.category_name, t.amount, t.transaction_status, t.transaction_date
FROM transactions t
LEFT JOIN transaction_categories c ON c.transaction_category_id = t.transaction_category_id
ORDER BY t.transaction_date DESC;

# inserting new transaction with a transaction category that does not exist
INSERT INTO transactions (transaction_category_id, sms_id, transaction_reference, currency, amount, service_fee, transaction_status, transaction_date)
VALUES (9, 6, 'TESTREF-0001', 'USD', 3000.00, 0.00, 'SUCCESS', NOW());
SELECT * FROM transactions WHERE transaction_reference = 'TESTREF-0001';

# inserting negative amount in transactions (CHECK CONSTRAINTS)
INSERT INTO transactions (transaction_category_id, sms_id, transaction_reference, currency, amount, service_fee, transaction_status, transaction_date)
VALUES (9, 6, 'TESTREF-0001', 'USD', -3000.00, 0.00, 'SUCCESS', NOW());
SELECT * FROM transactions WHERE transaction_reference = 'TESTREF-0001';

#deleting a transaction category that is referenced by existing transactions
DELETE FROM transaction_categories
WHERE transaction_category_id = 1;

select * from transaction_categories;

# updating user balance
UPDATE users
SET account_balance = account_balance + 5000
WHERE user_id = 'HIT-User-002';

SELECT user_id, account_balance FROM users WHERE user_id = 'HIT-User-002';

# This query joins transactions with their categories and participants to display a full transactional flow.
#An INNER JOIN on transaction_participants ensures that only transactions with valid user participation are included.
SELECT t.transaction_id, t.transaction_reference, c.category_name, t.amount, t.transaction_status,
  u.full_name, u.user_id, p.user_role, t.transaction_date
FROM transactions t
JOIN transaction_categories c
  ON c.transaction_category_id = t.transaction_category_id
INNER JOIN transaction_participants p
  ON p.transaction_id = t.transaction_id
LEFT JOIN users u
  ON u.user_id = p.user_id
ORDER BY t.transaction_date DESC, t.transaction_id, p.user_role;

#testing age constraint by inserting a user under 16 years old
INSERT IGNORE INTO users (user_id, full_name, phone_number, id_number, date_of_birth) VALUES
('HIT-User-007', 'Joe Baby', '+25078675564', 'LT123456789', '2015-05-15');
SELECT * FROM users WHERE user_id = 'HIT-User-007';