SET foreign_key_checks = 0;
-- Start a Transaction
START TRANSACTION;

[users]

-- Update the primary table (user table)
UPDATE user SET username = @new_username WHERE username = @old_username;

-- Update tables with foreign key references to user(username)
UPDATE delegate SET owner_id = @new_username WHERE owner_id = @old_username;
UPDATE delegate SET delegate_id = @new_username WHERE delegate_id = @old_username;
UPDATE memo SET user_id = @new_username WHERE user_id = @old_username;
UPDATE memo_history SET ref_user_id = @new_username WHERE ref_user_id = @old_username;
UPDATE memo_reference SET ref_user_id = @new_username WHERE ref_user_id = @old_username;
UPDATE memo_signature SET signer_id = @new_username WHERE signer_id = @old_username;
UPDATE memo_signature SET delegate_id = @new_username WHERE delegate_id = @old_username;
UPDATE memo_subscription SET subscriber_id = @new_username WHERE subscriber_id = @old_username;
UPDATE memo_subscription SET subscription_id = @new_username WHERE subscription_id = @old_username;

-- Update the _signers column in memo table
UPDATE memo SET _signers = REPLACE(_signers, @old_username, @new_username) WHERE _signers LIKE CONCAT('%', @old_username, '%');

-- Update the distribution column in memo table
UPDATE memo
SET distribution = REPLACE(distribution, @old_username, @new_username)
WHERE distribution LIKE CONCAT('%', @old_username, '%');

-- Update the memo_ref column in memo_history table
UPDATE memo_history
SET memo_ref = CONCAT(@new_username, '-', SUBSTRING(memo_ref, LOCATE('-', memo_ref) + 1))
WHERE memo_ref LIKE CONCAT(@old_username, '-%');

-- Update the ref_user_id in memo_history table
UPDATE memo_history
SET ref_user_id = @new_username
WHERE ref_user_id = @old_username;

-- Commit the transaction
COMMIT;
SET foreign_key_checks = 1;
