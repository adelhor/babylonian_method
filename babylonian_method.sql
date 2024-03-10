drop table results;
drop sequence results_sequance;

create sequence results_sequance start with 1 increment by 1;
create table results (id number primary key,
                     input_value number not null, 
                     number_of_iteration number not null, 
                     estimation number not null, 
                     final_result number not null);

----------------------MAIN FUNCTION - BABYLONIAN METHOD--------------------------
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

---------------CREATING AN OBJECT OF VALUES DETERMINED FROM THE ALGORITHM---------------
create or replace type object_of_values as object(
    iteration number,
    estimation number,
    final_result number);
/
-----------FUNCTION THAT CALCULATES ESTIMATIONS AND NUMBER OF ITERATIONS----------------
create or replace function algorithm (user_input_value number)
return object_of_values
is
v_initial_estimation number;
v_number_of_iterations number;
v_aux_variable varchar2(10);

--D=2*(v_power)+1 or D=2*(v_power)+2
v_power number;
v_d number;
begin
    v_aux_variable := user_input_value;
    --checking the range of the number provided by the user (user_input_value)
    if user_input_value >= 1 then
        v_aux_variable := trunc(user_input_value);
        v_d := length(v_aux_variable);
    elsif user_input_value < 1 and user_input_value >0 then
        v_aux_variable := substr(v_aux_variable, instr(v_aux_variable,'.')+1);
        v_d:=0;
		
		--calculation the number of zeros after decimal point
        for i in 1..length(v_aux_variable) loop
            if substr(v_aux_variable,i,1) = '0' then
                v_d := v_d+1;
            else
                exit;
            end if;
			--negative number of zeros immediately to the right of the decimal point
            v_d := (-1)*v_d; 
        end loop;
    else
        raise_application_error (-20100,'The user input is negative.');
    end if;
    
--checking if the parameter v_d is even or odd
    if  mod(v_d,2)=0 then
        v_power:= (v_d-2)/2;
        v_initial_estimation:=6 * power(10,v_power);
    else
        v_power:= (v_d-1)/2;
        v_initial_estimation:=2 * power(10,v_power);
    end if;
	
	--number of digits (+1) in the number provided by the user
    v_number_of_iterations:=length(replace(user_input_value,'.',''))+1; 
    
    return object_of_values(v_number_of_iterations, v_initial_estimation, 
                        babylonian_method(user_input_value,v_initial_estimation,v_number_of_iterations));
end;
/

-------------------CALLING THE FUNCTION AND SAVING TO THE TABLE 'results'-------------------
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
/

select * from results;
