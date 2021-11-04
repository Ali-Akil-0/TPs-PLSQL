/*
------------------------------------------------------------------------------------------
                                TP 03
                 Procédures, Fonctions et Déclencheurs
                            Sefiane OUAMI
------------------------------------------------------------------------------------------
*/
-- Partie 01 : Les procédures

-- question 01

SET SERVEROUTPUT ON;
DECLARE
    
    PROCEDURE Add_Warehouses(
                             p_warehouse_name IN warehouses.warehouse_name%TYPE ,
                             p_location_id IN warehouses.location_id%TYPE
                             )IS 
    -- variable local pour tester l'existence de location_id(clé etranger) dans la table des locations
    v_id locations.location_id%type;
    BEGIN
     SELECT location_id into v_id from locations where location_id = p_location_id;
     INSERT INTO warehouses(warehouse_name ,location_id) VALUES (p_warehouse_name , p_location_id);
    EXCEPTION 
       when no_data_found then dbms_output.put_line('error : location_id invalide');
       
    END;
BEGIN
    --test
    Add_Warehouses('my warehouse' ,100);
END;

-- question 02
SET SERVEROUTPUT ON;
DECLARE
   
    -- on passe comme para id de warehouse a modifier avec le nouveau nom de warehouse et le nouveau location_id
    PROCEDURE Update_Warehouses( p_location_id IN warehouses.location_id%TYPE ,
                                 p_warehouse_name IN warehouses.warehouse_name%TYPE ,
                                 p_warehouse_id IN warehouses.warehouse_id%TYPE
                             )IS
    
    BEGIN
    -- modification de la ligne demandé
     UPDATE warehouses
     SET warehouse_name = p_warehouse_name ,location_id = p_location_id
     WHERE warehouse_id = p_warehouse_id ;
    END;
BEGIN
    --32 C'est le id de warehouse a modifier 'Bombay' est le nouveau nom 45 est le nouveau location_id
    Update_Warehouses(45 ,'Bombay' , 32);
END;

-- question 03
SET SERVEROUTPUT ON;
DECLARE 
   
    PROCEDURE delete_warehouse( p_ware_id IN WAREHOUSES.WAREHOUSE_ID%type )IS
BEGIN
    DELETE FROM WAREHOUSES WHERE WAREHOUSE_ID = p_ware_id ;    
END ;
BEGIN
    delete_warehouse(32);
END;

-- question 04

SET SERVEROUTPUT ON;
DECLARE 
        v_id WAREHOUSES.WAREHOUSE_ID%type;
         PROCEDURE chercher_warehouses
         ( loca_id IN LOCATIONS.LOCATION_ID%type )
        IS
        CURSOR C_CUR IS SELECT  warehouses.warehouse_name from WAREHOUSES  where   warehouses.location_id = loca_id   ;
        v_name warehouses.warehouse_name%type ; 
        BEGIN
        open C_CUR ;	
        Loop
        FETCH C_CUR INTO v_name ;
        exit when C_CUR%notfound ;
        dbms_output.put_line( v_name  ) ; 
        end loop ;
        close C_CUR ;   
        END ;
BEGIN
--Partie Test 
v_id := '&v_id'  ; 
chercher_warehouses(v_id) ; 
END ;

-- question 05

SET SERVEROUTPUT ON;
DECLARE
    -- L'id de l'employee a calculer CA
    v_employee_id employees.employee_id%TYPE;
    
    PROCEDURE Calcul_CA_emp( p_employee_id IN employees.employee_id%TYPE
                                     )IS
    -- variables locals
            v_nom employees.last_name%type;
            v_total Number(30,2);
            
        BEGIN
             SELECT
               last_name,
               SUM(quantity * unit_price) AS CA_total
             INTO v_nom ,v_total
             FROM
                employees
                JOIN orders ON orders.salesman_id = employees.employee_id
                JOIN order_items ON order_items.order_id = orders.order_id
            WHERE employees.employee_id = p_employee_id
            GROUP BY last_name;
           DBMS_OUTPUT.PUT_LINE('CA total de l''employée = ' || v_total);
        END;
BEGIN   
    Calcul_CA_emp(54);
END;
    
------------------------------------ Partie 02 : Les fonctions ---------------------------------------------

-- question 01
SET SERVEROUTPUT ON;
DECLARE 
    resultat number(30,2);
    FUNCTION total_commande (p_order_id IN orders.order_id%TYPE)
    RETURN NUMBER
    IS
    v_total number(30,2);
    BEGIN
        SELECT  SUM(quantity * unit_price) 
        INTO v_total
        FROM order_items 
        WHERE order_id = p_order_id
        GROUP BY order_id;
        return v_total;  
       
    END;
BEGIN
    resultat := total_commande(18);
    dbms_output.put_line('total de commande : ' || resultat );
END;

-- question 02
SET SERVEROUTPUT ON;
DECLARE
    nb_commandes number;
    FUNCTION f_commandes RETURN Number IS
    resultat number;
    BEGIN
        SELECT COUNT(order_id) INTO resultat FROM orders WHERE status = 'Pending';
        return resultat;
    END;
BEGIN
    nb_commandes := f_commandes();
    DBMS_OUTPUT.PUT_LINE('Le nombre des commandes ayant un status Pending est : ' || nb_commandes);
END;

---------------------------------- Partie 03 : Les déclencheurs ---------------------------------------------

-- question 01
 
  CREATE TRIGGER Resume_commande
    AFTER INSERT ON orders
    FOR EACH ROW
    BEGIN
        dbms_output.put_line('commande ID :' || :new.order_id || 'customer ID :' || :new.customer_id || 'Status :'||:new.status
        || ' ajoute avec success');
    END;

-- question 02

CREATE TRIGGER d_alert
    BEFORE INSERT OR UPDATE ON inventories
    FOR EACH ROW
    BEGIN
        IF(:NEW.quantity < 10) THEN
        dbms_output.put_line('alert : le nombre darticles est inférieur à 10');
        ELSE
        dbms_output.put_line('success');
        END IF;  
    END;

-- question 03

CREATE TRIGGER d_Credit_limit_client
    BEFORE UPDATE ON customers
    FOR EACH ROW
    DECLARE
    -- obtenir le num de jour de modification
    jour NUMBER := EXTRACT (day from sysdate); 
    BEGIN
       IF ( jour > 28 and jour < 30 ) THEN
        ROLLBACK;
        dbms_output.put_line('la modification du CREDIT_LIMIT des clients nest pas autorisé entre le 28 et le 30 de chaque mois');
       END IF ;
    END;
    
-- question 04

CREATE TRIGGER d_emp_HD
    BEFORE INSERT ON employees
    FOR EACH ROW
    DECLARE
    BEGIN
       IF ( :NEW.hire_date > sysdate ) THEN
        ROLLBACK;
        dbms_output.put_line('erreur :hire_date invalide');
       END IF ;
                
    END;
    
-- question 05

CREATE TRIGGER d_resmise
    BEFORE INSERT ON order_items
    FOR EACH ROW
    DECLARE
    BEGIN
       IF ( :NEW.quantity * :NEW.unit_price > 10000) THEN
         :NEW.unit_price := (:NEW.quantity * :NEW.unit_price * 0.95 )/:NEW.quantity ;
         dbms_output.put_line('success avec remise de 5%');
       END IF ;           
    END;
    

