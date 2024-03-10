# Babylonian Method Square Root Calculator

This Oracle PL/SQL application calculates the square root of a given number using the Babylonian method.

## Database Setup

To prepare your database for the application, run the following commands:

```sql
DROP TABLE results;
DROP SEQUENCE results_sequence;

CREATE SEQUENCE results_sequence START WITH 1 INCREMENT BY 1;
CREATE TABLE results (
    id NUMBER PRIMARY KEY,
    input_value NUMBER NOT NULL, 
    number_of_iterations NUMBER NOT NULL, 
    estimation NUMBER NOT NULL, 
    final_result NUMBER NOT NULL
);
