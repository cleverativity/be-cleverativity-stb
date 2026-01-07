alter table "mod_base"."customers" drop column "testing";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION mod_quality_control.generate_return_number()
 RETURNS text
 LANGUAGE plpgsql
AS $function$DECLARE
    v_year text;
    v_sequence integer;
    v_return_number text;
BEGIN
    v_year := EXTRACT(YEAR FROM CURRENT_DATE)::text;

    -- Get next sequence for this year
    SELECT COALESCE(MAX(CAST(SUBSTRING(return_number FROM 12) AS integer)), 0) + 1
    INTO v_sequence
    FROM mod_quality_control.supplier_returns
    WHERE return_number LIKE 'RET-' || v_year || '-%';

    v_return_number := 'RET-' || v_year || '-' || LPAD(v_sequence::text, 4, '0');

    RETURN v_return_number;
END;$function$
;


