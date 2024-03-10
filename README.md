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
/

## Main Function - Babylonian Method

Define the function to perform the square root calculation.

```sql
create or replace function babylonian_method(
    user_input_value number,
    initial_estimation number,
    number_of_iterations number)
return number
is
result_of_each_iteration number;
begin
    result_of_each_iteration := initial_estimation;
    for i in 1..number_of_iterations loop 
        result_of_each_iteration := (result_of_each_iteration + user_input_value/result_of_each_iteration)/2;        
    end loop;
    return round(result_of_each_iteration,3);
end;
/
