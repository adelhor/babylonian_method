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
```
## Supporting Types

An object_of_values object is used to hold the iterative calculations from the algorithm.

```sql
create or replace type object_of_values as object(
    iteration number,
    estimation number,
    final_result number);
```
## Algorithm Function

The algorithm function determines the initial estimations and number of iterations needed based on the user's input.

```sql
create or replace function algorithm (user_input_value number)
return object_of_values
is
v_initial_estimation number;
v_number_of_iterations number;
v_aux_variable varchar2(10);
v_power number;
v_d number;
begin
    v_aux_variable := user_input_value;
    if user_input_value >= 1 then
        v_aux_variable := trunc(user_input_value);
        v_d := length(v_aux_variable);
    elsif user_input_value < 1 and user_input_value >0 then
        v_aux_variable := substr(v_aux_variable, instr(v_aux_variable,'.')+1);
        v_d:=0;

        for i in 1..length(v_aux_variable) loop
            if substr(v_aux_variable,i,1) = '0' then
                v_d := v_d+1;
            else
                exit;
            end if;
            v_d := (-1)*v_d; 
        end loop;
    else
        raise_application_error (-20100,'The user input is negative.');
    end if;

    if  mod(v_d,2)=0 then
        v_power:= (v_d-2)/2;
        v_initial_estimation:=6 * power(10,v_power);
    else
        v_power:= (v_d-1)/2;
        v_initial_estimation:=2 * power(10,v_power);
    end if;

    v_number_of_iterations:=length(replace(user_input_value,'.',''))+1;  
    return object_of_values(v_number_of_iterations, v_initial_estimation, 
                            babylonian_method(user_input_value,v_initial_estimation,v_number_of_iterations));
end;
```
## Saving results
We have a PL/SQL block to call the algorithm function and save its output to the results table.

```sql
declare
    v_user_input number := '&Provide_the_number_that_you_want_to_calculate_square_root';
    v_values object_of_values;
begin
    if v_user_input = 0 then
        insert into results values (results_sequance.nextval, 0, 0, 0, 0);
    else
        v_values := algorithm(v_user_input);
        insert into results values (results_sequance.nextval, v_user_input, 
                               v_values.iteration, v_values.estimation, 
                               v_values.final_result);
    end if;

exception
    when others then
        if sqlcode = -20100 then 
            dbms_output.put_line('Error ' || sqlerrm || '. Enter the positive number.');
        else
            dbms_output.put_line('Another error occurred.');
        end if;
end;
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
