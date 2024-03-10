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
```
## Main Function - Babylonian Method

The babylonian_method function takes user input and calculates the square root by performing a set number of iterations.

```sql
CREATE OR REPLACE FUNCTION babylonian_method(
    user_input_value NUMBER,
    initial_estimation NUMBER,
    number_of_iterations NUMBER
) RETURN NUMBER
IS
result_of_each_iteration NUMBER;
BEGIN
    result_of_each_iteration := initial_estimation;
    FOR i IN 1..number_of_iterations LOOP
        result_of_each_iteration := (result_of_each_iteration + user_input_value / result_of_each_iteration) / 2;        
    END LOOP;
    RETURN ROUND(result_of_each_iteration, 3);
END;
```
## Supporting Types

An object_of_values object is used to hold the iterative calculations from the algorithm.

```sql
CREATE OR REPLACE TYPE object_of_values AS OBJECT(
    iteration NUMBER,
    estimation NUMBER,
    final_result NUMBER
);
```
## Algorithm Function

The algorithm function determines the initial estimations and number of iterations needed based on the user's input.

```sql
CREATE OR REPLACE FUNCTION algorithm (user_input_value NUMBER)
RETURN object_of_values
IS
v_initial_estimation NUMBER;
v_number_of_iterations NUMBER;
v_aux_variable VARCHAR2(10);
v_power NUMBER;
v_d NUMBER;
BEGIN
    v_aux_variable := user_input_value;
    IF user_input_value >= 1 THEN
        v_aux_variable := TRUNC(user_input_value);
        v_d := LENGTH(v_aux_variable);
    ELSIF user_input_value < 1 AND user_input_value > 0 THEN
        v_aux_variable := SUBSTR(v_aux_variable, INSTR(v_aux_variable,'.')+1);
        v_d := 0;

        FOR i IN 1..LENGTH(v_aux_variable) LOOP
            IF SUBSTR(v_aux_variable,i,1) = '0' THEN
                v_d := v_d + 1;
            ELSE
                EXIT;
            END IF;
            v_d := (-1) * v_d; 
        END LOOP;
    ELSE
        RAISE_APPLICATION_ERROR (-20100,'The user input is negative.');
    END IF;

    IF MOD(v_d,2) = 0 THEN
        v_power := (v_d-2)/2;
        v_initial_estimation := 6 * POWER(10,v_power);
    ELSE
        v_power := (v_d-1)/2;
        v_initial_estimation := 2 * POWER(10,v_power);
    END IF;

    v_number_of_iterations := LENGTH(REPLACE(user_input_value,'.','')) + 1;  
    RETURN object_of_values(v_number_of_iterations, v_initial_estimation, 
                            babylonian_method(user_input_value, v_initial_estimation, v_number_of_iterations));
END;
```
## Saving results
We have a PL/SQL block to call the algorithm function and save its output to the results table.

```sql
DECLARE
    v_user_input NUMBER := '&Provide_the_number_that_you_want_to_calculate_square_root';
    v_values OBJECT_OF_VALUES;
BEGIN
    IF v_user_input = 0 THEN
        INSERT INTO results VALUES (results_sequence.NEXTVAL, 0, 0, 0, 0);
    ELSE
        v_values := algorithm(v_user_input);
        INSERT INTO results VALUES (results_sequence.NEXTVAL, v_user_input, 
                                   v_values.iteration, v_values.estimation, 
                                   v_values.final_result);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20100 THEN 
            DBMS_OUTPUT.PUT_LINE('Error ' || SQLERRM || '. Enter the positive number.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Another error occurred.');
        END IF;
END;
```
## Viewing Results
To view the results, run the following SQL query:

```sql
SELECT * FROM results;
```
## How to Use
Set up the database by executing the provided SQL statements to create the sequence and results table.
Compile the main function and type definitions in your Oracle environment.
Use the anonymous PL/SQL block to calculate the square root of a number and save the result.
Query the results table to see all the square root calculations.
