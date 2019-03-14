---Copyright Van Dang Tran https://github.com/dangtv/BIRDS
CREATE OR REPLACE VIEW public.dejima_bank AS 
SELECT __dummy__.COL0 AS FIRST_NAME,__dummy__.COL1 AS LAST_NAME,__dummy__.COL2 AS PHONE,__dummy__.COL3 AS ADDRESS 
FROM (SELECT DISTINCT dejima_bank_a4_0.COL0 AS COL0, dejima_bank_a4_0.COL1 AS COL1, dejima_bank_a4_0.COL2 AS COL2, dejima_bank_a4_0.COL3 AS COL3 
FROM (SELECT DISTINCT bank_users_a5_0.FIRST_NAME AS COL0, bank_users_a5_0.LAST_NAME AS COL1, bank_users_a5_0.PHONE AS COL2, bank_users_a5_0.ADDRESS AS COL3 
FROM public.bank_users AS bank_users_a5_0  ) AS dejima_bank_a4_0  ) AS __dummy__;

DROP MATERIALIZED VIEW IF EXISTS public.__dummy__materialized_dejima_bank;

CREATE  MATERIALIZED VIEW public.__dummy__materialized_dejima_bank AS 
SELECT * FROM public.dejima_bank;

CREATE EXTENSION IF NOT EXISTS plsh;

CREATE OR REPLACE FUNCTION public.dejima_bank_run_shell(text) RETURNS text AS $$
#!/bin/sh
echo "---"
sleep 1
curl -X POST -H "Content-Type: application/json" $DEJIMA_API_ENDPOINT -d "{"dejima_table": "bank"}" > /dev/null 2>&1
echo "changes: '$1'"
echo $?
# echo "true"
exit 0
$$ LANGUAGE plsh;

CREATE OR REPLACE FUNCTION public.dejima_bank_delta_exe_shell()
RETURNS trigger 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  DECLARE
  text_var1 text;
  text_var2 text;
  text_var3 text;
  deletion_data text;
  insertion_data text;
  json_data text;
  result text;
  BEGIN
  IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'dejima_bank_delta_action_flag') THEN
    insertion_data := (SELECT (array_to_json(array_agg(t)))::text FROM (SELECT * FROM public.dejima_bank EXCEPT SELECT * FROM public.__dummy__materialized_dejima_bank) as t);
    IF insertion_data IS NOT DISTINCT FROM NULL THEN 
        insertion_data := '[]';
    END IF; 
    deletion_data := (SELECT (array_to_json(array_agg(t)))::text FROM (SELECT * FROM public.__dummy__materialized_dejima_bank EXCEPT SELECT * FROM public.dejima_bank) as t);
    IF deletion_data IS NOT DISTINCT FROM NULL THEN 
        deletion_data := '[]';
    END IF; 
    IF (insertion_data IS DISTINCT FROM '[]') OR (insertion_data IS DISTINCT FROM '[]') THEN 
        json_data := concat('{"view": ' , '"public.dejima_bank"', ', ' , '"insertion": ' , insertion_data , ', ' , '"deletion": ' , deletion_data , '}');
        result := public.dejima_bank_run_shell(json_data);
        IF result = 'true' THEN 
            REFRESH MATERIALIZED VIEW public.__dummy__materialized_dejima_bank;
        ELSE
            RAISE NOTICE 'result from running the sh script: %', result;
            RAISE check_violation USING MESSAGE = 'update on view is rejected by the external tool';
        END IF;
    END IF;
  END IF;
  RETURN NULL;
  EXCEPTION
    WHEN object_not_in_prerequisite_state THEN
        RAISE object_not_in_prerequisite_state USING MESSAGE = 'no permission to insert or delete or update to source relations of public.dejima_bank';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                                text_var2 = PG_EXCEPTION_DETAIL,
                                text_var3 = MESSAGE_TEXT;
        RAISE SQLSTATE 'DA000' USING MESSAGE = 'error on the trigger of public.dejima_bank ; error code: ' || text_var1 || ' ; ' || text_var2 ||' ; ' || text_var3;
        RETURN NULL;
  END;
$$;

DROP TRIGGER IF EXISTS bank_users_detect_update ON public.bank_users;
        CREATE TRIGGER bank_users_detect_update
            AFTER INSERT OR UPDATE OR DELETE ON
            public.bank_users FOR EACH STATEMENT EXECUTE PROCEDURE public.dejima_bank_delta_exe_shell();

CREATE OR REPLACE FUNCTION public.dejima_bank_delta_action()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  DECLARE
  text_var1 text;
  text_var2 text;
  text_var3 text;
  deletion_data text;
  insertion_data text;
  json_data text;
  result text;
  temprecΔ_del_bank_users public.bank_users%ROWTYPE;
temprecΔ_ins_bank_users public.bank_users%ROWTYPE;
  BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'dejima_bank_delta_action_flag') THEN
        -- RAISE NOTICE 'execute procedure dejima_bank_delta_action';
        CREATE TEMPORARY TABLE dejima_bank_delta_action_flag ON COMMIT DROP AS (SELECT true as finish);
        IF EXISTS (SELECT WHERE false )
        THEN 
          RAISE check_violation USING MESSAGE = 'Invalid update on view';
        END IF;
        CREATE TEMPORARY TABLE Δ_del_bank_users WITH OIDS ON COMMIT DROP AS SELECT (ROW(COL0,COL1,COL2,COL3,COL4) :: public.bank_users).* 
            FROM (SELECT DISTINCT Δ_del_bank_users_a5_0.COL0 AS COL0, Δ_del_bank_users_a5_0.COL1 AS COL1, Δ_del_bank_users_a5_0.COL2 AS COL2, Δ_del_bank_users_a5_0.COL3 AS COL3, Δ_del_bank_users_a5_0.COL4 AS COL4 
FROM (SELECT DISTINCT bank_users_a5_0.FIRST_NAME AS COL0, bank_users_a5_0.LAST_NAME AS COL1, bank_users_a5_0.IBAN AS COL2, bank_users_a5_0.ADDRESS AS COL3, bank_users_a5_0.PHONE AS COL4 
FROM public.bank_users AS bank_users_a5_0 
WHERE NOT EXISTS ( SELECT * 
FROM (SELECT DISTINCT __dummy__materialized_dejima_bank_a4_0.FIRST_NAME AS COL0, __dummy__materialized_dejima_bank_a4_0.LAST_NAME AS COL1, __dummy__materialized_dejima_bank_a4_0.PHONE AS COL2, __dummy__materialized_dejima_bank_a4_0.ADDRESS AS COL3 
FROM public.__dummy__materialized_dejima_bank AS __dummy__materialized_dejima_bank_a4_0 
WHERE NOT EXISTS ( SELECT * 
FROM __temp__Δ_del_dejima_bank AS __temp__Δ_del_dejima_bank_a4 
WHERE __temp__Δ_del_dejima_bank_a4.ADDRESS IS NOT DISTINCT FROM __dummy__materialized_dejima_bank_a4_0.ADDRESS AND __temp__Δ_del_dejima_bank_a4.PHONE IS NOT DISTINCT FROM __dummy__materialized_dejima_bank_a4_0.PHONE AND __temp__Δ_del_dejima_bank_a4.LAST_NAME IS NOT DISTINCT FROM __dummy__materialized_dejima_bank_a4_0.LAST_NAME AND __temp__Δ_del_dejima_bank_a4.FIRST_NAME IS NOT DISTINCT FROM __dummy__materialized_dejima_bank_a4_0.FIRST_NAME )  UNION SELECT DISTINCT __temp__Δ_ins_dejima_bank_a4_0.FIRST_NAME AS COL0, __temp__Δ_ins_dejima_bank_a4_0.LAST_NAME AS COL1, __temp__Δ_ins_dejima_bank_a4_0.PHONE AS COL2, __temp__Δ_ins_dejima_bank_a4_0.ADDRESS AS COL3 
FROM __temp__Δ_ins_dejima_bank AS __temp__Δ_ins_dejima_bank_a4_0  ) AS dejima_bank_a4 
WHERE dejima_bank_a4.COL3 IS NOT DISTINCT FROM bank_users_a5_0.ADDRESS AND dejima_bank_a4.COL2 IS NOT DISTINCT FROM bank_users_a5_0.PHONE AND dejima_bank_a4.COL1 IS NOT DISTINCT FROM bank_users_a5_0.LAST_NAME AND dejima_bank_a4.COL0 IS NOT DISTINCT FROM bank_users_a5_0.FIRST_NAME ) ) AS Δ_del_bank_users_a5_0  ) AS Δ_del_bank_users_extra_alias;

CREATE TEMPORARY TABLE Δ_ins_bank_users WITH OIDS ON COMMIT DROP AS SELECT (ROW(COL0,COL1,COL2,COL3,COL4) :: public.bank_users).* 
            FROM (SELECT DISTINCT Δ_ins_bank_users_a5_0.COL0 AS COL0, Δ_ins_bank_users_a5_0.COL1 AS COL1, Δ_ins_bank_users_a5_0.COL2 AS COL2, Δ_ins_bank_users_a5_0.COL3 AS COL3, Δ_ins_bank_users_a5_0.COL4 AS COL4 
FROM (SELECT DISTINCT bank_users_a5_1.FIRST_NAME AS COL0, bank_users_a5_1.LAST_NAME AS COL1, bank_users_a5_1.IBAN AS COL2, dejima_bank_a4_0.COL3 AS COL3, dejima_bank_a4_0.COL2 AS COL4 
FROM (SELECT DISTINCT __dummy__materialized_dejima_bank_a4_0.FIRST_NAME AS COL0, __dummy__materialized_dejima_bank_a4_0.LAST_NAME AS COL1, __dummy__materialized_dejima_bank_a4_0.PHONE AS COL2, __dummy__materialized_dejima_bank_a4_0.ADDRESS AS COL3 
FROM public.__dummy__materialized_dejima_bank AS __dummy__materialized_dejima_bank_a4_0 
WHERE NOT EXISTS ( SELECT * 
FROM __temp__Δ_del_dejima_bank AS __temp__Δ_del_dejima_bank_a4 
WHERE __temp__Δ_del_dejima_bank_a4.ADDRESS IS NOT DISTINCT FROM __dummy__materialized_dejima_bank_a4_0.ADDRESS AND __temp__Δ_del_dejima_bank_a4.PHONE IS NOT DISTINCT FROM __dummy__materialized_dejima_bank_a4_0.PHONE AND __temp__Δ_del_dejima_bank_a4.LAST_NAME IS NOT DISTINCT FROM __dummy__materialized_dejima_bank_a4_0.LAST_NAME AND __temp__Δ_del_dejima_bank_a4.FIRST_NAME IS NOT DISTINCT FROM __dummy__materialized_dejima_bank_a4_0.FIRST_NAME )  UNION SELECT DISTINCT __temp__Δ_ins_dejima_bank_a4_0.FIRST_NAME AS COL0, __temp__Δ_ins_dejima_bank_a4_0.LAST_NAME AS COL1, __temp__Δ_ins_dejima_bank_a4_0.PHONE AS COL2, __temp__Δ_ins_dejima_bank_a4_0.ADDRESS AS COL3 
FROM __temp__Δ_ins_dejima_bank AS __temp__Δ_ins_dejima_bank_a4_0  ) AS dejima_bank_a4_0, public.bank_users AS bank_users_a5_1 
WHERE bank_users_a5_1.FIRST_NAME = dejima_bank_a4_0.COL0 AND bank_users_a5_1.LAST_NAME = dejima_bank_a4_0.COL1 AND NOT EXISTS ( SELECT * 
FROM public.bank_users AS bank_users_a5 
WHERE bank_users_a5.PHONE IS NOT DISTINCT FROM dejima_bank_a4_0.COL2 AND bank_users_a5.ADDRESS IS NOT DISTINCT FROM dejima_bank_a4_0.COL3 AND bank_users_a5.LAST_NAME IS NOT DISTINCT FROM bank_users_a5_1.LAST_NAME AND bank_users_a5.FIRST_NAME IS NOT DISTINCT FROM bank_users_a5_1.FIRST_NAME )  UNION SELECT DISTINCT dejima_bank_a4_0.COL0 AS COL0, dejima_bank_a4_0.COL1 AS COL1, 'unknown' AS COL2, dejima_bank_a4_0.COL3 AS COL3, dejima_bank_a4_0.COL2 AS COL4 
FROM (SELECT DISTINCT __dummy__materialized_dejima_bank_a4_0.FIRST_NAME AS COL0, __dummy__materialized_dejima_bank_a4_0.LAST_NAME AS COL1, __dummy__materialized_dejima_bank_a4_0.PHONE AS COL2, __dummy__materialized_dejima_bank_a4_0.ADDRESS AS COL3 
FROM public.__dummy__materialized_dejima_bank AS __dummy__materialized_dejima_bank_a4_0 
WHERE NOT EXISTS ( SELECT * 
FROM __temp__Δ_del_dejima_bank AS __temp__Δ_del_dejima_bank_a4 
WHERE __temp__Δ_del_dejima_bank_a4.ADDRESS IS NOT DISTINCT FROM __dummy__materialized_dejima_bank_a4_0.ADDRESS AND __temp__Δ_del_dejima_bank_a4.PHONE IS NOT DISTINCT FROM __dummy__materialized_dejima_bank_a4_0.PHONE AND __temp__Δ_del_dejima_bank_a4.LAST_NAME IS NOT DISTINCT FROM __dummy__materialized_dejima_bank_a4_0.LAST_NAME AND __temp__Δ_del_dejima_bank_a4.FIRST_NAME IS NOT DISTINCT FROM __dummy__materialized_dejima_bank_a4_0.FIRST_NAME )  UNION SELECT DISTINCT __temp__Δ_ins_dejima_bank_a4_0.FIRST_NAME AS COL0, __temp__Δ_ins_dejima_bank_a4_0.LAST_NAME AS COL1, __temp__Δ_ins_dejima_bank_a4_0.PHONE AS COL2, __temp__Δ_ins_dejima_bank_a4_0.ADDRESS AS COL3 
FROM __temp__Δ_ins_dejima_bank AS __temp__Δ_ins_dejima_bank_a4_0  ) AS dejima_bank_a4_0 
WHERE NOT EXISTS ( SELECT * 
FROM public.bank_users AS bank_users_a5 
WHERE bank_users_a5.LAST_NAME IS NOT DISTINCT FROM dejima_bank_a4_0.COL1 AND bank_users_a5.FIRST_NAME IS NOT DISTINCT FROM dejima_bank_a4_0.COL0 ) ) AS Δ_ins_bank_users_a5_0  ) AS Δ_ins_bank_users_extra_alias; 

FOR temprecΔ_del_bank_users IN ( SELECT * FROM Δ_del_bank_users) LOOP 
            DELETE FROM public.bank_users WHERE ROW(FIRST_NAME,LAST_NAME,IBAN,ADDRESS,PHONE) IS NOT DISTINCT FROM  temprecΔ_del_bank_users;
            END LOOP;
DROP TABLE Δ_del_bank_users;

INSERT INTO public.bank_users SELECT * FROM  Δ_ins_bank_users; 
DROP TABLE Δ_ins_bank_users;

        insertion_data := (SELECT (array_to_json(array_agg(t)))::text FROM (SELECT * FROM __temp__Δ_ins_dejima_bank EXCEPT SELECT * FROM public.__dummy__materialized_dejima_bank) as t);
        IF insertion_data IS NOT DISTINCT FROM NULL THEN 
            insertion_data := '[]';
        END IF; 
        deletion_data := (SELECT (array_to_json(array_agg(t)))::text FROM (SELECT * FROM __temp__Δ_del_dejima_bank INTERSECT SELECT * FROM public.__dummy__materialized_dejima_bank) as t);
        IF deletion_data IS NOT DISTINCT FROM NULL THEN 
            deletion_data := '[]';
        END IF; 
        IF (insertion_data IS DISTINCT FROM '[]') OR (insertion_data IS DISTINCT FROM '[]') THEN 
            json_data := concat('{"view": ' , '"public.dejima_bank"', ', ' , '"insertion": ' , insertion_data , ', ' , '"deletion": ' , deletion_data , '}');
            result := public.dejima_bank_run_shell(json_data);
            IF result = 'true' THEN 
                REFRESH MATERIALIZED VIEW public.__dummy__materialized_dejima_bank;
            ELSE
                RAISE NOTICE 'result from running the sh script: %', result;
                RAISE check_violation USING MESSAGE = 'update on view is rejected by the external tool';
            END IF;
        END IF;
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN object_not_in_prerequisite_state THEN
        RAISE object_not_in_prerequisite_state USING MESSAGE = 'no permission to insert or delete or update to source relations of public.dejima_bank';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                                text_var2 = PG_EXCEPTION_DETAIL,
                                text_var3 = MESSAGE_TEXT;
        RAISE SQLSTATE 'DA000' USING MESSAGE = 'error on the trigger of public.dejima_bank ; error code: ' || text_var1 || ' ; ' || text_var2 ||' ; ' || text_var3;
        RETURN NULL;
  END;
$$;

CREATE OR REPLACE FUNCTION public.dejima_bank_materialization()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  DECLARE
  text_var1 text;
  text_var2 text;
  text_var3 text;
  BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = '__temp__Δ_ins_dejima_bank' OR table_name = '__temp__Δ_del_dejima_bank')
    THEN
        -- RAISE NOTICE 'execute procedure dejima_bank_materialization';
        REFRESH MATERIALIZED VIEW public.__dummy__materialized_dejima_bank;
        CREATE TEMPORARY TABLE __temp__Δ_ins_dejima_bank ( LIKE public.__dummy__materialized_dejima_bank INCLUDING ALL ) WITH OIDS ON COMMIT DROP;
        CREATE CONSTRAINT TRIGGER __temp__dejima_bank_trigger_delta_action
        AFTER INSERT OR UPDATE OR DELETE ON 
            __temp__Δ_ins_dejima_bank DEFERRABLE INITIALLY DEFERRED 
            FOR EACH ROW EXECUTE PROCEDURE public.dejima_bank_delta_action();

        CREATE TEMPORARY TABLE __temp__Δ_del_dejima_bank ( LIKE public.__dummy__materialized_dejima_bank INCLUDING ALL ) WITH OIDS ON COMMIT DROP;
        CREATE CONSTRAINT TRIGGER __temp__dejima_bank_trigger_delta_action
        AFTER INSERT OR UPDATE OR DELETE ON 
            __temp__Δ_del_dejima_bank DEFERRABLE INITIALLY DEFERRED 
            FOR EACH ROW EXECUTE PROCEDURE public.dejima_bank_delta_action();
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN object_not_in_prerequisite_state THEN
        RAISE object_not_in_prerequisite_state USING MESSAGE = 'no permission to insert or delete or update to source relations of public.dejima_bank';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                                text_var2 = PG_EXCEPTION_DETAIL,
                                text_var3 = MESSAGE_TEXT;
        RAISE SQLSTATE 'DA000' USING MESSAGE = 'error on the trigger of public.dejima_bank ; error code: ' || text_var1 || ' ; ' || text_var2 ||' ; ' || text_var3;
        RETURN NULL;
  END;
$$;

DROP TRIGGER IF EXISTS dejima_bank_trigger_materialization ON public.dejima_bank;
CREATE TRIGGER dejima_bank_trigger_materialization
    BEFORE INSERT OR UPDATE OR DELETE ON
      public.dejima_bank FOR EACH STATEMENT EXECUTE PROCEDURE public.dejima_bank_materialization();

CREATE OR REPLACE FUNCTION public.dejima_bank_update()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  DECLARE
  text_var1 text;
  text_var2 text;
  text_var3 text;
  BEGIN
    -- RAISE NOTICE 'execute procedure dejima_bank_update';
    IF TG_OP = 'INSERT' THEN
      -- raise notice 'NEW: %', NEW;
      DELETE FROM __temp__Δ_del_dejima_bank WHERE ROW(FIRST_NAME,LAST_NAME,PHONE,ADDRESS) IS NOT DISTINCT FROM NEW;
      INSERT INTO __temp__Δ_ins_dejima_bank SELECT (NEW).*; 
    ELSIF TG_OP = 'UPDATE' THEN
      DELETE FROM __temp__Δ_ins_dejima_bank WHERE ROW(FIRST_NAME,LAST_NAME,PHONE,ADDRESS) IS NOT DISTINCT FROM OLD;
      INSERT INTO __temp__Δ_del_dejima_bank SELECT (OLD).*;
      DELETE FROM __temp__Δ_del_dejima_bank WHERE ROW(FIRST_NAME,LAST_NAME,PHONE,ADDRESS) IS NOT DISTINCT FROM NEW;
      INSERT INTO __temp__Δ_ins_dejima_bank SELECT (NEW).*; 
    ELSIF TG_OP = 'DELETE' THEN
      -- raise notice 'OLD: %', OLD;
      DELETE FROM __temp__Δ_ins_dejima_bank WHERE ROW(FIRST_NAME,LAST_NAME,PHONE,ADDRESS) IS NOT DISTINCT FROM OLD;
      INSERT INTO __temp__Δ_del_dejima_bank SELECT (OLD).*;
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN object_not_in_prerequisite_state THEN
        RAISE object_not_in_prerequisite_state USING MESSAGE = 'no permission to insert or delete or update to source relations of public.dejima_bank';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                                text_var2 = PG_EXCEPTION_DETAIL,
                                text_var3 = MESSAGE_TEXT;
        RAISE SQLSTATE 'DA000' USING MESSAGE = 'error on the trigger of public.dejima_bank ; error code: ' || text_var1 || ' ; ' || text_var2 ||' ; ' || text_var3;
        RETURN NULL;
  END;
$$;

DROP TRIGGER IF EXISTS dejima_bank_trigger_update ON public.dejima_bank;
CREATE TRIGGER dejima_bank_trigger_update
    INSTEAD OF INSERT OR UPDATE OR DELETE ON
      public.dejima_bank FOR EACH ROW EXECUTE PROCEDURE public.dejima_bank_update();


DROP TRIGGER IF EXISTS dejima_insurance_trigger_update ON public.dejima_insurance;
CREATE TRIGGER dejima_insurance_trigger_update
    INSTEAD OF INSERT OR UPDATE OR DELETE ON
      public.dejima_insurance FOR EACH ROW EXECUTE PROCEDURE public.dejima_insurance_update();

