drop view if exists "mod_base"."quality_control_checklist_summary";

drop view if exists "mod_quality_control"."supplier_returns_summary";

drop view if exists "mod_wms"."current_inventory";

alter table "mod_base"."articles" drop column "testing";

alter table "mod_base"."bom_articles" drop column "testing";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION mod_base.ensure_single_primary_address()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- If this is being set as primary, unset other primary addresses of the same type for this customer
  IF NEW.is_primary = true THEN
    UPDATE mod_base.customer_addresses
    SET is_primary = false
    WHERE customer_id = NEW.customer_id
      AND address_type = NEW.address_type
      AND id != NEW.id
      AND is_deleted = false;
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_customer_addresses_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    NEW.created_by := COALESCE(
      NEW.created_by,
      auth.uid()
    );

  ELSIF TG_OP = 'UPDATE' THEN
    -- On UPDATE, set the user performing this operation and the updated timestamp
    NEW.updated_by := auth.uid();
    NEW.updated_at := now();
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_quality_control_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    NEW.created_by := COALESCE(NEW.created_by, auth.uid());

    -- Auto-populate domain_id from user's JWT claims if not provided
    IF NEW.domain_id IS NULL THEN
      NEW.domain_id := (SELECT get_my_claim_text('domain_id')::uuid);
    END IF;

    -- Set planned_date to now if not provided and status is PLANNED
    IF NEW.planned_date IS NULL AND NEW.status = 'PLANNED' THEN
      NEW.planned_date := now();
    END IF;

  ELSIF TG_OP = 'UPDATE' THEN
    -- On UPDATE, set the user performing this operation and the updated timestamp
    NEW.updated_by := auth.uid();
    NEW.updated_at := now();

    -- Auto-set timing fields based on status changes
    IF OLD.status != NEW.status THEN
      CASE NEW.status
        WHEN 'IN_PROGRESS' THEN
          IF NEW.started_date IS NULL THEN
            NEW.started_date := now();
          END IF;
        WHEN 'PASSED', 'FAILED' THEN
          IF NEW.completed_date IS NULL THEN
            NEW.completed_date := now();
          END IF;
        ELSE
          -- No automatic timestamp setting for other statuses
      END CASE;
    END IF;
  END IF;

  RETURN NEW;
END;
$function$
;

create or replace view "mod_base"."quality_control_checklist_summary" as  SELECT qccr.id,
    qccr.quality_control_id,
    qccr.checklist_item,
    qccr.result,
    qccr.notes,
    qccr.created_at,
    qccr.created_by,
    qc.code AS qc_code,
    qc.name AS qc_name,
    qc.status AS qc_status,
    qc.purchase_order_item_id,
    a.name AS article_name,
    a.code AS article_code,
    poi.name AS item_name,
    poi.quantity_ordered,
    poi.quantity_received,
    ( SELECT count(*) AS count
           FROM mod_base.quality_control_checklist_results qccr2
          WHERE ((qccr2.quality_control_id = qccr.quality_control_id) AND (qccr2.is_deleted = false))) AS total_checklist_items,
    ( SELECT count(*) AS count
           FROM mod_base.quality_control_checklist_results qccr2
          WHERE ((qccr2.quality_control_id = qccr.quality_control_id) AND (qccr2.result = true) AND (qccr2.is_deleted = false))) AS passed_items,
    ( SELECT count(*) AS count
           FROM mod_base.quality_control_checklist_results qccr2
          WHERE ((qccr2.quality_control_id = qccr.quality_control_id) AND (qccr2.result = false) AND (qccr2.is_deleted = false))) AS failed_items
   FROM (((mod_base.quality_control_checklist_results qccr
     LEFT JOIN mod_base.quality_control qc ON ((qccr.quality_control_id = qc.id)))
     LEFT JOIN mod_base.articles a ON ((qc.article_id = a.id)))
     LEFT JOIN mod_base.purchase_order_items poi ON ((qc.purchase_order_item_id = poi.id)))
  WHERE ((qccr.is_deleted = false) AND ((qc.is_deleted = false) OR (qc.is_deleted IS NULL)))
  ORDER BY qccr.created_at;


CREATE OR REPLACE FUNCTION mod_datalayer.generate_sales_order_code()
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    year_part text;
    month_part text;
    sequence_name text;
    next_val int;
    result text;
BEGIN
    -- Get current year's last 2 digits
    year_part := to_char(CURRENT_DATE, 'YY');

    -- Get current month (2 digits)
    month_part := to_char(CURRENT_DATE, 'MM');

    -- Create a sequence name specific to sales orders with year and month
    sequence_name := 'sales_orders_code_seq_' || year_part || month_part;

    -- Create sequence if it doesn't exist (resets each month)
    EXECUTE format('CREATE SEQUENCE IF NOT EXISTS %I START 1', sequence_name);

    -- Get next value from sequence
    EXECUTE format('SELECT nextval(%L)', sequence_name) INTO next_val;

    -- Format the result: YY + MM + 6-digit number
    result := year_part || month_part || LPAD(next_val::text, 6, '0');

    RETURN result;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_datalayer.generate_sales_order_number()
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    year_part text;
    month_part text;
    sequence_name text;
    next_val int;
    result text;
BEGIN
    -- Get current year's last 2 digits
    year_part := to_char(CURRENT_DATE, 'YY');

    -- Get current month (2 digits)
    month_part := to_char(CURRENT_DATE, 'MM');

    -- Use the SAME sequence as code to ensure they match
    -- This ensures code and sales_order_number are always identical
    sequence_name := 'sales_orders_code_seq_' || year_part || month_part;

    -- Create sequence if it doesn't exist (resets each month)
    EXECUTE format('CREATE SEQUENCE IF NOT EXISTS %I START 1', sequence_name);

    -- Get next value from sequence
    EXECUTE format('SELECT nextval(%L)', sequence_name) INTO next_val;

    -- Format the result: YY + MM + 6-digit number
    result := year_part || month_part || LPAD(next_val::text, 6, '0');

    RETURN result;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_datalayer.generate_sales_order_number_trigger()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    -- Check if sales_order_number is NULL or empty
    IF NEW.sales_order_number IS NULL OR NEW.sales_order_number = '' THEN
        -- If code is already set (from generate_table_code trigger), use it for sales_order_number
        IF NEW.code IS NOT NULL AND NEW.code != '' THEN
            NEW.sales_order_number := NEW.code;
        ELSE
            -- Generate sales_order_number (will use same sequence as code)
            NEW.sales_order_number := mod_datalayer.generate_sales_order_number();
            -- Also set code to match if it's empty
            IF NEW.code IS NULL OR NEW.code = '' THEN
                NEW.code := NEW.sales_order_number;
            END IF;
        END IF;
    ELSIF (NEW.code IS NULL OR NEW.code = '') AND (NEW.sales_order_number IS NOT NULL AND NEW.sales_order_number != '') THEN
        -- If sales_order_number is provided but code is empty, use sales_order_number for code
        NEW.code := NEW.sales_order_number;
    END IF;
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_datalayer.generate_table_code()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    -- Check if code is NULL or empty
    IF NEW.code IS NULL OR NEW.code = '' THEN
        -- Generate code based on table name
        CASE TG_TABLE_NAME
            -- mod_admin tables
            WHEN 'user_profiles' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'UP');
            WHEN 'domains' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'DO');

            -- mod_base tables
            WHEN 'suppliers' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'SU');
            WHEN 'article_categories' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'AC');
            WHEN 'units_of_measure' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'UM');
            WHEN 'articles' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'AR');
            WHEN 'purchase_orders' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'PO');
            WHEN 'purchase_order_items' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'PI');
            WHEN 'customers' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'CU');
            WHEN 'sales_orders' THEN
                -- Use the new format: YYMM + 6-digit increment
                -- If sales_order_number is already set, use it for code to ensure they match
                IF NEW.sales_order_number IS NOT NULL AND NEW.sales_order_number != '' THEN
                    NEW.code := NEW.sales_order_number;
                ELSE
                    NEW.code := mod_datalayer.generate_sales_order_code();
                END IF;
            WHEN 'sales_order_items' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'SI');
            WHEN 'employees' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'EM');
            WHEN 'departments' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'DP');

            -- mod_manufacturing tables
            WHEN 'departments' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'MD');
            WHEN 'locations' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'ML');
            WHEN 'workstations' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'WS');
            WHEN 'work_cycles' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'WC');
            WHEN 'work_steps' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'ST');
            WHEN 'work_orders' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'WO');

            -- mod_pulse tables
            WHEN 'pulse_slas' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'PS');
            WHEN 'pulses' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'PU');
            WHEN 'pulse_checklists' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'PC');
            WHEN 'pulse_progress' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'PP');
            WHEN 'tasks' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'TA');
            WHEN 'notifications' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'NO');

            -- mod_wms tables
            WHEN 'warehouses' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'WH');
            WHEN 'locations' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'LO');
            WHEN 'batches' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'BA');
            WHEN 'shipments' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'SH');
            WHEN 'shipment_items' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'SP');
            WHEN 'receipts' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'RE');
            WHEN 'receipt_items' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'RI');
            WHEN 'inventory_limits' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'IL');

            -- mod_base internal sales orders
            WHEN 'internal_sales_orders' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'ISO');
            WHEN 'internal_sales_order_items' THEN
                NEW.code := mod_datalayer.generate_code_format(TG_TABLE_NAME, 'ISI');
        END CASE;
    END IF;
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.check_coil_weight_warning(coil_weight numeric)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN coil_weight < 50;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.generate_batch_code()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
  year_letter char(1);
  sequence_num integer;
  batch_code text;
BEGIN
  -- Convert year to letter (2025=A, 2026=B, etc.)
  year_letter := chr(65 + (EXTRACT(year FROM now()) - 2025));

  -- Get next sequence number for this year
  SELECT COALESCE(MAX(CAST(SUBSTRING(batch_code FROM 2) AS integer)), 0) + 1
  INTO sequence_num
  FROM mod_manufacturing.coil_production_plans
  WHERE batch_code LIKE year_letter || '%'
  AND batch_code IS NOT NULL;

  -- Handle case where no existing codes
  IF sequence_num IS NULL THEN
    sequence_num := 1;
  END IF;

  -- Format as A1234 (letter + 4-digit number)
  batch_code := year_letter || LPAD(sequence_num::text, 4, '0');

  RETURN batch_code;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.handle_scheduled_items_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    NEW.created_by := COALESCE(
      NEW.created_by,
      auth.uid()
    );

  ELSIF TG_OP = 'UPDATE' THEN
    -- On UPDATE, set the user performing this operation and the updated timestamp
    NEW.updated_by := auth.uid();
    NEW.updated_at := now();
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.create_pulse_for_record()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Create a new pulse record
  INSERT INTO mod_pulse.pulses (
    name,
    description,
    code,
    type,
    status,
    priority,
    domain_id,
    created_by,
    updated_by
  )
  VALUES (
    NEW.name,
    NEW.description,
    NEW.code,
    CASE
      WHEN TG_TABLE_SCHEMA = 'mod_base' AND TG_TABLE_NAME = 'purchase_orders' THEN 'task'
      WHEN TG_TABLE_SCHEMA = 'mod_base' AND TG_TABLE_NAME = 'sales_orders' THEN 'task'
      WHEN TG_TABLE_SCHEMA = 'mod_base' AND TG_TABLE_NAME = 'internal_sales_orders' THEN 'task'
      WHEN TG_TABLE_SCHEMA = 'mod_wms' AND TG_TABLE_NAME = 'receipts' THEN 'task'
      WHEN TG_TABLE_SCHEMA = 'mod_wms' AND TG_TABLE_NAME = 'shipments' THEN 'task'
      WHEN TG_TABLE_SCHEMA = 'mod_manufacturing' AND TG_TABLE_NAME = 'work_orders' THEN 'task'
      ELSE 'task'
    END,
    CASE
      WHEN NEW.status = 'pending' THEN 'open'
      WHEN NEW.status = 'processing' THEN 'in_progress'
      WHEN NEW.status = 'completed' THEN 'resolved'
      WHEN NEW.status = 'canceled' THEN 'closed'
      WHEN NEW.status = 'in_transit' THEN 'in_progress'
      WHEN NEW.status = 'delivered' THEN 'resolved'
      WHEN NEW.status = 'failed' THEN 'closed'
      ELSE 'open'
    END,
    'medium',
    NEW.domain_id,
    NEW.created_by,
    NEW.updated_by
  )
  RETURNING id INTO NEW.id;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.handle_department_notification_configs_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    NEW.created_by := COALESCE(
      NEW.created_by,
      auth.uid()
    );

  ELSIF TG_OP = 'UPDATE' THEN
    -- On UPDATE, set the user performing this operation and the updated timestamp
    NEW.updated_by := auth.uid();
    NEW.updated_at := now();
  END IF;

  RETURN NEW;
END;
$function$
;

create or replace view "mod_quality_control"."supplier_returns_summary" as  SELECT sr.id,
    sr.return_number,
    sr.return_date,
    sr.return_status,
    sr.return_quantity,
    sr.total_cost,
    sr.credit_amount,
    s.name AS supplier_name,
    a.name AS article_name,
    qc.code AS qc_code,
    sr.created_at,
    sr.updated_at
   FROM (((mod_quality_control.supplier_returns sr
     LEFT JOIN mod_base.suppliers s ON ((sr.supplier_id = s.id)))
     LEFT JOIN mod_base.articles a ON ((sr.article_id = a.id)))
     LEFT JOIN mod_base.quality_control qc ON ((sr.quality_control_id = qc.id)))
  WHERE (NOT sr.is_deleted);


CREATE OR REPLACE FUNCTION mod_wms.copy_shipment_address_to_item(p_shipment_item_id uuid, p_address_type character varying DEFAULT 'delivery'::character varying)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_shipment_id UUID;
    v_address_id UUID;
BEGIN
    -- Get the shipment ID from the shipment item
    SELECT shipment_id INTO v_shipment_id
    FROM mod_wms.shipment_items
    WHERE id = p_shipment_item_id;

    IF v_shipment_id IS NULL THEN
        RAISE EXCEPTION 'Shipment item not found';
    END IF;

    -- Copy the shipment's delivery address to the item
    INSERT INTO mod_wms.shipment_item_addresses (
        shipment_item_id,
        address_type,
        address,
        city,
        state,
        zip,
        country,
        province,
        is_primary,
        notes
    )
    SELECT
        p_shipment_item_id,
        p_address_type,
        delivery_address,
        delivery_city,
        delivery_state,
        delivery_zip,
        delivery_country,
        delivery_province,
        true,
        'Copied from shipment global address'
    FROM mod_wms.shipments
    WHERE id = v_shipment_id
    RETURNING id INTO v_address_id;

    RETURN v_address_id;
END;
$function$
;

create or replace view "mod_wms"."current_inventory" as  SELECT sm.article_id,
    a.name AS article_name,
    COALESCE(sm.to_location_id, sm.from_location_id) AS location_id,
    l.name AS location_name,
    sm.batch_id,
    b.batch_number,
    sum(
        CASE
            WHEN (sm.type = 'inbound'::text) THEN sm.quantity_moved
            WHEN (sm.type = 'adjustment'::text) THEN sm.quantity_moved
            WHEN ((sm.type = 'relocation'::text) AND (sm.to_location_id = COALESCE(sm.to_location_id, sm.from_location_id))) THEN sm.quantity_moved
            WHEN ((sm.type = 'relocation'::text) AND (sm.from_location_id = COALESCE(sm.to_location_id, sm.from_location_id))) THEN (- sm.quantity_moved)
            WHEN (sm.type = 'outbound'::text) THEN (- sm.quantity_moved)
            ELSE (0)::numeric
        END) AS quantity,
    0 AS allocated_qty,
    max(sm.movement_date) AS last_movement_date,
    min(sm.created_at) AS created_at,
    max(sm.updated_at) AS updated_at
   FROM (((mod_wms.stock_movements sm
     JOIN mod_base.articles a ON ((sm.article_id = a.id)))
     LEFT JOIN mod_wms.locations l ON ((COALESCE(sm.to_location_id, sm.from_location_id) = l.id)))
     LEFT JOIN mod_wms.batches b ON ((sm.batch_id = b.id)))
  WHERE (a.is_deleted = false)
  GROUP BY sm.article_id, a.name, COALESCE(sm.to_location_id, sm.from_location_id), l.name, sm.batch_id, b.batch_number
 HAVING (sum(
        CASE
            WHEN (sm.type = 'inbound'::text) THEN sm.quantity_moved
            WHEN (sm.type = 'adjustment'::text) THEN sm.quantity_moved
            WHEN ((sm.type = 'relocation'::text) AND (sm.to_location_id = COALESCE(sm.to_location_id, sm.from_location_id))) THEN sm.quantity_moved
            WHEN ((sm.type = 'relocation'::text) AND (sm.from_location_id = COALESCE(sm.to_location_id, sm.from_location_id))) THEN (- sm.quantity_moved)
            WHEN (sm.type = 'outbound'::text) THEN (- sm.quantity_moved)
            ELSE (0)::numeric
        END) > (0)::numeric);


CREATE OR REPLACE FUNCTION mod_wms.delete_item_address(p_address_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
    DELETE FROM mod_wms.shipment_item_addresses WHERE id = p_address_id;
    RETURN FOUND;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.generate_unique_receipt_number()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
  new_number TEXT;
  counter BIGINT;
BEGIN
  -- Start counter at current max numeric suffix + 1 to reduce collisions
  SELECT COALESCE(MAX((regexp_replace(receipt_number, '^RN', ''))::BIGINT), 0) + 1
  INTO counter
  FROM mod_wms.receipts
  WHERE receipt_number ~ '^RN\\d+$';

  IF counter IS NULL OR counter < 1 THEN
    counter := 1;
  END IF;

  LOOP
    new_number := 'RN' || LPAD(counter::TEXT, 6, '0');
    -- Ensure uniqueness across non-deleted rows
    IF NOT EXISTS (
      SELECT 1 FROM mod_wms.receipts WHERE receipt_number = new_number AND is_deleted = false
    ) THEN
      RETURN new_number;
    END IF;
    counter := counter + 1;
    IF counter > 999999 THEN
      RAISE EXCEPTION 'Unable to generate unique receipt number after 999999 attempts';
    END IF;
  END LOOP;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.get_item_all_addresses(p_shipment_item_id uuid)
 RETURNS TABLE(id uuid, address_type character varying, address text, city text, state text, zip text, country text, province text, is_primary boolean, notes text, created_at timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        sia.id,
        sia.address_type,
        sia.address,
        sia.city,
        sia.state,
        sia.zip,
        sia.country,
        sia.province,
        sia.is_primary,
        sia.notes,
        sia.created_at
    FROM mod_wms.shipment_item_addresses sia
    WHERE sia.shipment_item_id = p_shipment_item_id
    ORDER BY sia.address_type, sia.is_primary DESC, sia.created_at;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.get_item_primary_address(p_shipment_item_id uuid, p_address_type character varying DEFAULT 'delivery'::character varying)
 RETURNS TABLE(address text, city text, state text, zip text, country text, province text, address_type character varying, is_primary boolean, notes text)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        sia.address,
        sia.city,
        sia.state,
        sia.zip,
        sia.country,
        sia.province,
        sia.address_type,
        sia.is_primary,
        sia.notes
    FROM mod_wms.shipment_item_addresses sia
    WHERE sia.shipment_item_id = p_shipment_item_id
      AND sia.address_type = p_address_type
      AND sia.is_primary = true;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_receipt_items_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  jwt_domain_id uuid;
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    NEW.created_by := COALESCE(
      NEW.created_by,
      auth.uid()
    );

    -- CRITICAL: Auto-populate domain_id from user's JWT claims
    -- This ensures the domain_id matches what RLS policies check: get_my_claim_text('domain_id')
    -- The RLS SELECT policies require: get_my_claim_text('domain_id')::uuid = domain_id
    -- So we MUST use the exact value from the JWT claim to ensure RLS compliance
    --
    -- Get domain_id from JWT claim (what RLS policies check)
    jwt_domain_id := (SELECT get_my_claim_text('domain_id')::uuid);

    -- Always use JWT claim domain_id if available to ensure RLS compliance
    -- This prevents RLS violations by ensuring domain_id matches what policies check
    IF jwt_domain_id IS NOT NULL THEN
      -- Override with JWT claim to ensure RLS compliance
      NEW.domain_id := jwt_domain_id;
    ELSIF NEW.domain_id IS NULL THEN
      -- If JWT claim is null and domain_id is not provided, use default
      -- Note: domain_id has NOT NULL constraint with default, so this should rarely happen
      NEW.domain_id := 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid;
    END IF;
    -- If domain_id was provided and JWT claim is null, keep the provided value
    -- (though this may still cause RLS issues if it doesn't match user's domain)

  ELSIF TG_OP = 'UPDATE' THEN
    -- On UPDATE, set the user performing this operation and the updated timestamp
    NEW.updated_by := auth.uid();
    NEW.updated_at := now();
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.set_receipt_number_on_insert()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.receipt_number IS NULL OR TRIM(NEW.receipt_number) = '' THEN
    NEW.receipt_number := mod_wms.generate_unique_receipt_number();
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.update_shipment_attachments_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.update_shipment_item_addresses_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.update_shipment_sales_orders_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.upsert_item_address(p_shipment_item_id uuid, p_address_type character varying, p_address text, p_city text, p_state text, p_zip text DEFAULT NULL::text, p_country text DEFAULT NULL::text, p_province text DEFAULT NULL::text, p_is_primary boolean DEFAULT false, p_notes text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_address_id UUID;
    v_existing_primary_id UUID;
BEGIN
    -- If setting as primary, unset any existing primary address of the same type
    IF p_is_primary THEN
        UPDATE mod_wms.shipment_item_addresses
        SET is_primary = false
        WHERE shipment_item_id = p_shipment_item_id
          AND address_type = p_address_type
          AND is_primary = true;
    END IF;

    -- Try to find existing address of the same type
    SELECT id INTO v_address_id
    FROM mod_wms.shipment_item_addresses
    WHERE shipment_item_id = p_shipment_item_id
      AND address_type = p_address_type
    LIMIT 1;

    IF v_address_id IS NOT NULL THEN
        -- Update existing address
        UPDATE mod_wms.shipment_item_addresses
        SET
            address = p_address,
            city = p_city,
            state = p_state,
            zip = p_zip,
            country = p_country,
            province = p_province,
            is_primary = p_is_primary,
            notes = p_notes,
            updated_at = NOW()
        WHERE id = v_address_id;

        RETURN v_address_id;
    ELSE
        -- Insert new address
        INSERT INTO mod_wms.shipment_item_addresses (
            shipment_item_id,
            address_type,
            address,
            city,
            state,
            zip,
            country,
            province,
            is_primary,
            notes
        ) VALUES (
            p_shipment_item_id,
            p_address_type,
            p_address,
            p_city,
            p_state,
            p_zip,
            p_country,
            p_province,
            p_is_primary,
            p_notes
        ) RETURNING id INTO v_address_id;

        RETURN v_address_id;
    END IF;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.add_article_related_search_results(search_query text, limit_count integer DEFAULT 50)
 RETURNS TABLE(table_name text, schema_name text, id text, title text, description text, url text, rank real)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Return early if search query is empty or just whitespace
  IF TRIM(search_query) = '' OR search_query IS NULL THEN
    RETURN;
  END IF;

  -- Search for articles first
  RETURN QUERY
  SELECT
    'articles'::text as table_name,
    'mod_base'::text as schema_name,
    a.id::text as id,
    COALESCE(a.name, '')::text as title,
    COALESCE(a.description, '')::text as description,
    ('/wms/articles/' || a.id || '/inventory')::text as url,
    CASE
      WHEN a.fts IS NOT NULL AND a.fts @@ plainto_tsquery('english', search_query)
      THEN ts_rank(a.fts, plainto_tsquery('english', search_query))::real
      ELSE 0.0::real
    END as rank
  FROM mod_base.articles a
  WHERE a.is_deleted = false
    AND (
      (a.fts IS NOT NULL AND a.fts @@ plainto_tsquery('english', search_query))
      OR LOWER(a.name) LIKE '%' || LOWER(search_query) || '%'
      OR LOWER(a.code) LIKE '%' || LOWER(search_query) || '%'
      OR LOWER(a.sku) LIKE '%' || LOWER(search_query) || '%'
      OR LOWER(COALESCE(a.description, '')) LIKE '%' || LOWER(search_query) || '%'
    )
  ORDER BY rank DESC, a.name ASC
  LIMIT limit_count;

  -- Stock Movements with articles
  RETURN QUERY
  SELECT
    'stock_movements'::text as table_name,
    'mod_wms'::text as schema_name,
    sm.id::text as id,
    (COALESCE(a.name, 'Article') || ' - Stock Movement')::text as title,
    ('Stock movement for ' || COALESCE(a.name, 'article') || ' (' || COALESCE(a.code, '') || ')')::text as description,
    ('/wms/stock_movements/' || sm.id || '?setPassword')::text as url,
    CASE
      WHEN a.fts IS NOT NULL AND a.fts @@ plainto_tsquery('english', search_query)
      THEN (ts_rank(a.fts, plainto_tsquery('english', search_query)) * 0.8)::real
      ELSE 0.0::real
    END as rank
  FROM mod_wms.stock_movements sm
  INNER JOIN mod_base.articles a ON sm.article_id = a.id
  WHERE a.is_deleted = false
    AND (
      (a.fts IS NOT NULL AND a.fts @@ plainto_tsquery('english', search_query))
      OR LOWER(a.name) LIKE '%' || LOWER(search_query) || '%'
      OR LOWER(a.code) LIKE '%' || LOWER(search_query) || '%'
      OR LOWER(a.sku) LIKE '%' || LOWER(search_query) || '%'
    )
  ORDER BY rank DESC, sm.created_at DESC
  LIMIT limit_count;

  -- Receipts with articles (via receipt_items)
  RETURN QUERY
  SELECT DISTINCT
    'receipts'::text as table_name,
    'mod_wms'::text as schema_name,
    r.id::text as id,
    (COALESCE(r.code, r.name, 'Receipt') || ' - ' || COALESCE(a.name, 'Article'))::text as title,
    ('Receipt containing ' || COALESCE(a.name, 'article') || ' (' || COALESCE(a.code, '') || ')')::text as description,
    ('/wms/receipts/' || r.id)::text as url,
    CASE
      WHEN a.fts IS NOT NULL AND a.fts @@ plainto_tsquery('english', search_query)
      THEN (ts_rank(a.fts, plainto_tsquery('english', search_query)) * 0.65)::real
      ELSE 0.0::real
    END as rank
  FROM mod_wms.receipts r
  INNER JOIN mod_wms.receipt_items ri ON ri.receipt_id = r.id
  INNER JOIN mod_base.articles a ON ri.article_id = a.id
  WHERE a.is_deleted = false
    AND r.is_deleted = false
    AND ri.is_deleted = false
    AND (
      (a.fts IS NOT NULL AND a.fts @@ plainto_tsquery('english', search_query))
      OR LOWER(a.name) LIKE '%' || LOWER(search_query) || '%'
      OR LOWER(a.code) LIKE '%' || LOWER(search_query) || '%'
      OR LOWER(a.sku) LIKE '%' || LOWER(search_query) || '%'
    )
  ORDER BY rank DESC, r.created_at DESC
  LIMIT limit_count;

  -- Receipt Items page
  RETURN QUERY
  SELECT DISTINCT
    'receipt_items'::text as table_name,
    'mod_wms'::text as schema_name,
    r.id::text as id,
    (COALESCE(r.code, r.name, 'Receipt') || ' - Items')::text as title,
    ('View items for receipt containing ' || COALESCE(a.name, 'article') || ' (' || COALESCE(a.code, '') || ')')::text as description,
    ('/wms/receipts/' || r.id || '/items')::text as url,
    CASE
      WHEN a.fts IS NOT NULL AND a.fts @@ plainto_tsquery('english', search_query)
      THEN (ts_rank(a.fts, plainto_tsquery('english', search_query)) * 0.6)::real
      ELSE 0.0::real
    END as rank
  FROM mod_wms.receipts r
  INNER JOIN mod_wms.receipt_items ri ON ri.receipt_id = r.id
  INNER JOIN mod_base.articles a ON ri.article_id = a.id
  WHERE a.is_deleted = false
    AND r.is_deleted = false
    AND ri.is_deleted = false
    AND (
      (a.fts IS NOT NULL AND a.fts @@ plainto_tsquery('english', search_query))
      OR LOWER(a.name) LIKE '%' || LOWER(search_query) || '%'
      OR LOWER(a.code) LIKE '%' || LOWER(search_query) || '%'
      OR LOWER(a.sku) LIKE '%' || LOWER(search_query) || '%'
    )
  ORDER BY rank DESC, r.created_at DESC
  LIMIT limit_count;

  -- Shipments with articles (via shipment_items)
  RETURN QUERY
  SELECT DISTINCT
    'shipments'::text as table_name,
    'mod_wms'::text as schema_name,
    s.id::text as id,
    (COALESCE(s.code, s.name, 'Shipment') || ' - ' || COALESCE(a.name, 'Article'))::text as title,
    ('Shipment containing ' || COALESCE(a.name, 'article') || ' (' || COALESCE(a.code, '') || ')')::text as description,
    ('/wms/shipments/' || s.id)::text as url,
    CASE
      WHEN a.fts IS NOT NULL AND a.fts @@ plainto_tsquery('english', search_query)
      THEN (ts_rank(a.fts, plainto_tsquery('english', search_query)) * 0.65)::real
      ELSE 0.0::real
    END as rank
  FROM mod_wms.shipments s
  INNER JOIN mod_wms.shipment_items si ON si.shipment_id = s.id
  INNER JOIN mod_base.articles a ON si.article_id = a.id
  WHERE a.is_deleted = false
    AND s.is_deleted = false
    AND si.is_deleted = false
    AND (
      (a.fts IS NOT NULL AND a.fts @@ plainto_tsquery('english', search_query))
      OR LOWER(a.name) LIKE '%' || LOWER(search_query) || '%'
      OR LOWER(a.code) LIKE '%' || LOWER(search_query) || '%'
      OR LOWER(a.sku) LIKE '%' || LOWER(search_query) || '%'
    )
  ORDER BY rank DESC, s.created_at DESC
  LIMIT limit_count;

  -- Sales Orders with articles (via sales_order_items)
  RETURN QUERY
  SELECT DISTINCT
    'sales_orders'::text as table_name,
    'mod_base'::text as schema_name,
    so.id::text as id,
    (COALESCE(so.code, so.name, 'Sales Order') || ' - ' || COALESCE(a.name, 'Article'))::text as title,
    ('Sales order containing ' || COALESCE(a.name, 'article') || ' (' || COALESCE(a.code, '') || ')')::text as description,
    ('/base/sales-orders/' || so.id)::text as url,
    CASE
      WHEN a.fts IS NOT NULL AND a.fts @@ plainto_tsquery('english', search_query)
      THEN (ts_rank(a.fts, plainto_tsquery('english', search_query)) * 0.65)::real
      ELSE 0.0::real
    END as rank
  FROM mod_base.sales_orders so
  INNER JOIN mod_base.sales_order_items soi ON soi.sales_order_id = so.id
  INNER JOIN mod_base.articles a ON soi.article_id = a.id
  WHERE a.is_deleted = false
    AND so.is_deleted = false
    AND soi.is_deleted = false
    AND (
      (a.fts IS NOT NULL AND a.fts @@ plainto_tsquery('english', search_query))
      OR LOWER(a.name) LIKE '%' || LOWER(search_query) || '%'
      OR LOWER(a.code) LIKE '%' || LOWER(search_query) || '%'
      OR LOWER(a.sku) LIKE '%' || LOWER(search_query) || '%'
    )
  ORDER BY rank DESC, so.created_at DESC
  LIMIT limit_count;

  -- Work Orders with articles
  RETURN QUERY
  SELECT DISTINCT
    'work_orders'::text as table_name,
    'mod_manufacturing'::text as schema_name,
    wo.id::text as id,
    (COALESCE(wo.code, wo.name, 'Work Order') || ' - ' || COALESCE(a.name, 'Article'))::text as title,
    ('Work order for ' || COALESCE(a.name, 'article') || ' (' || COALESCE(a.code, '') || ')')::text as description,
    ('/manufacturing/work_orders/' || wo.id)::text as url,
    CASE
      WHEN a.fts IS NOT NULL AND a.fts @@ plainto_tsquery('english', search_query)
      THEN (ts_rank(a.fts, plainto_tsquery('english', search_query)) * 0.6)::real
      ELSE 0.0::real
    END as rank
  FROM mod_manufacturing.work_orders wo
  INNER JOIN mod_base.articles a ON wo.article_id = a.id
  WHERE a.is_deleted = false
    AND wo.is_deleted = false
    AND (
      (a.fts IS NOT NULL AND a.fts @@ plainto_tsquery('english', search_query))
      OR LOWER(a.name) LIKE '%' || LOWER(search_query) || '%'
      OR LOWER(a.code) LIKE '%' || LOWER(search_query) || '%'
      OR LOWER(a.sku) LIKE '%' || LOWER(search_query) || '%'
    )
  ORDER BY rank DESC, wo.created_at DESC
  LIMIT limit_count;

  -- Production Tasks with articles (work orders with task_id)
  RETURN QUERY
  SELECT DISTINCT
    'production_tasks'::text as table_name,
    'mod_manufacturing'::text as schema_name,
    wo.id::text as id,
    (COALESCE(wo.code, wo.name, 'Production Task') || ' - ' || COALESCE(a.name, 'Article'))::text as title,
    ('Production task for ' || COALESCE(a.name, 'article') || ' (' || COALESCE(a.code, '') || ')')::text as description,
    ('/manufacturing/production-tasks/' || wo.id)::text as url,
    CASE
      WHEN a.fts IS NOT NULL AND a.fts @@ plainto_tsquery('english', search_query)
      THEN (ts_rank(a.fts, plainto_tsquery('english', search_query)) * 0.6)::real
      ELSE 0.0::real
    END as rank
  FROM mod_manufacturing.work_orders wo
  INNER JOIN mod_base.articles a ON wo.article_id = a.id
  WHERE a.is_deleted = false
    AND wo.is_deleted = false
    AND wo.task_id IS NOT NULL
    AND (
      (a.fts IS NOT NULL AND a.fts @@ plainto_tsquery('english', search_query))
      OR LOWER(a.name) LIKE '%' || LOWER(search_query) || '%'
      OR LOWER(a.code) LIKE '%' || LOWER(search_query) || '%'
      OR LOWER(a.sku) LIKE '%' || LOWER(search_query) || '%'
    )
  ORDER BY rank DESC, wo.created_at DESC
  LIMIT limit_count;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.generate_unique_receipt_number()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
    new_number TEXT;
    counter INTEGER := 1;
BEGIN
    LOOP
        new_number := 'RN' || LPAD(counter::TEXT, 4, '0');

        -- Check if this number already exists
        IF NOT EXISTS (
            SELECT 1 FROM mod_wms.receipts
            WHERE receipt_number = new_number
            AND is_deleted = false
        ) THEN
            RETURN new_number;
        END IF;

        counter := counter + 1;

        -- Prevent infinite loop
        IF counter > 9999 THEN
            RAISE EXCEPTION 'Unable to generate unique receipt number after 9999 attempts';
        END IF;
    END LOOP;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_search_suggestions(search_query text, limit_count integer DEFAULT 10)
 RETURNS TABLE(suggestion text, type text, count bigint)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Return common search suggestions
  RETURN QUERY
  SELECT
    'sales order'::text as suggestion,
    'module'::text as type,
    1::bigint as count
  WHERE LOWER('sales order') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'customer'::text as suggestion,
    'module'::text as type,
    1::bigint as count
  WHERE LOWER('customer') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'pulse'::text as suggestion,
    'module'::text as type,
    1::bigint as count
  WHERE LOWER('pulse') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'admin'::text as suggestion,
    'module'::text as type,
    1::bigint as count
  WHERE LOWER('admin') LIKE '%' || LOWER(search_query) || '%'

  ORDER BY count DESC
  LIMIT limit_count;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.global_search(search_query text, limit_count integer DEFAULT 50)
 RETURNS TABLE(table_name text, schema_name text, id text, title text, description text, url text, rank real)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Search across multiple tables with proper error handling
  RETURN QUERY
  -- Search in sales_orders
  SELECT
    'sales_orders'::text as table_name,
    'mod_base'::text as schema_name,
    so.id::text,
    COALESCE(so.code, 'Sales Order') as title,
    COALESCE(so.description, '') as description,
    '/base/sales-orders/' || so.id::text as url,
    1.0::real as rank
  FROM mod_base.sales_orders so
  WHERE (LOWER(COALESCE(so.code, '')) LIKE '%' || LOWER(search_query) || '%'
     OR LOWER(COALESCE(so.description, '')) LIKE '%' || LOWER(search_query) || '%')
    AND NOT so.is_deleted
  LIMIT limit_count;

EXCEPTION
  WHEN OTHERS THEN
    -- If sales_orders table doesn't exist or has issues, continue with other tables
    NULL;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.search_menu_items(search_query text, domain_id text DEFAULT NULL::text)
 RETURNS TABLE(id text, title text, path text, icon text, menu_type text, rank real)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Return menu items that match the search
  RETURN QUERY
  SELECT
    'home'::text as id,
    'Home'::text as title,
    '/'::text as path,
    'home'::text as icon,
    'menu'::text as menu_type,
    1.0::real as rank
  WHERE LOWER('Home') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'pulse'::text as id,
    'Pulse Dashboard'::text as title,
    '/pulse'::text as path,
    'pulse'::text as icon,
    'menu'::text as menu_type,
    0.9::real as rank
  WHERE LOWER('Pulse Dashboard') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'sales-orders'::text as id,
    'Sales Orders'::text as title,
    '/base/sales-orders'::text as path,
    'receipt_long'::text as icon,
    'page'::text as menu_type,
    0.8::real as rank
  WHERE LOWER('Sales Orders') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'customers'::text as id,
    'Customers'::text as title,
    '/base/customers'::text as path,
    'people'::text as icon,
    'page'::text as menu_type,
    0.7::real as rank
  WHERE LOWER('Customers') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'admin'::text as id,
    'Admin'::text as title,
    '/admin'::text as path,
    'admin_panel_settings'::text as icon,
    'page'::text as menu_type,
    0.6::real as rank
  WHERE LOWER('Admin') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'wms'::text as id,
    'WMS'::text as title,
    '/wms'::text as path,
    'warehouse'::text as icon,
    'page'::text as menu_type,
    0.5::real as rank
  WHERE LOWER('WMS') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'manufacturing'::text as id,
    'Manufacturing'::text as title,
    '/manufacturing'::text as path,
    'precision_manufacturing'::text as icon,
    'page'::text as menu_type,
    0.4::real as rank
  WHERE LOWER('Manufacturing') LIKE '%' || LOWER(search_query) || '%';
END;
$function$
;

CREATE OR REPLACE FUNCTION public.simple_global_search(search_query text, limit_count integer DEFAULT 50)
 RETURNS TABLE(table_name text, schema_name text, id text, title text, description text, url text, rank real)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Search in tasks table (NEW - HIGHEST PRIORITY)
  RETURN QUERY
  SELECT
    'tasks'::text as table_name,
    'mod_pulse'::text as schema_name,
    t.id::text,
    COALESCE(t.name, 'Task') as title,
    COALESCE(
      t.description,
      CASE
        WHEN t.status IS NOT NULL THEN 'Status: ' || t.status
        ELSE ''
      END ||
      CASE
        WHEN t.priority IS NOT NULL THEN ' | Priority: ' || t.priority
        ELSE ''
      END
    ) as description,
    '/tasks/' || t.id::text as url,
    1.0::real as rank
  FROM mod_pulse.tasks t
  WHERE (
    LOWER(COALESCE(t.name, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(t.description, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(t.code, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(t.status, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(t.priority, '')) LIKE '%' || LOWER(search_query) || '%'
  )
  AND NOT t.is_deleted
  LIMIT limit_count;

  -- Search in sales_orders table
  RETURN QUERY
  SELECT
    'sales_orders'::text as table_name,
    'mod_base'::text as schema_name,
    so.id::text,
    COALESCE(so.name, so.sales_order_number, 'Sales Order') as title,
    COALESCE(so.description, '') as description,
    '/base/sales-orders/' || so.id::text as url,
    0.9::real as rank
  FROM mod_base.sales_orders so
  WHERE (
    LOWER(COALESCE(so.name, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(so.description, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(so.code, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(so.sales_order_number, '')) LIKE '%' || LOWER(search_query) || '%'
  )
  AND NOT so.is_deleted
  LIMIT limit_count;

  -- Search in customers table
  RETURN QUERY
  SELECT
    'customers'::text as table_name,
    'mod_base'::text as schema_name,
    c.id::text,
    COALESCE(c.name, 'Customer') as title,
    COALESCE(c.description, c.email, '') as description,
    '/base/customers/' || c.id::text as url,
    0.8::real as rank
  FROM mod_base.customers c
  WHERE (
    LOWER(COALESCE(c.name, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(c.description, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(c.code, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(c.email, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(c.contact_name, '')) LIKE '%' || LOWER(search_query) || '%'
  )
  AND NOT c.is_deleted
  LIMIT limit_count;

  -- Search in articles table
  RETURN QUERY
  SELECT
    'articles'::text as table_name,
    'mod_base'::text as schema_name,
    a.id::text,
    COALESCE(a.name, a.sku, 'Article') as title,
    COALESCE(a.description, '') as description,
    '/wms/articles/' || a.id::text as url,
    0.7::real as rank
  FROM mod_base.articles a
  WHERE (
    LOWER(COALESCE(a.name, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(a.description, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(a.code, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(a.sku, '')) LIKE '%' || LOWER(search_query) || '%'
  )
  AND NOT a.is_deleted
  LIMIT limit_count;

  -- Search in suppliers table
  RETURN QUERY
  SELECT
    'suppliers'::text as table_name,
    'mod_base'::text as schema_name,
    s.id::text,
    COALESCE(s.name, 'Supplier') as title,
    COALESCE(s.description, s.email, '') as description,
    '/wms/suppliers/' || s.id::text as url,
    0.6::real as rank
  FROM mod_base.suppliers s
  WHERE (
    LOWER(COALESCE(s.name, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(s.description, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(s.code, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(s.email, '')) LIKE '%' || LOWER(search_query) || '%'
    OR LOWER(COALESCE(s.contact_name, '')) LIKE '%' || LOWER(search_query) || '%'
  )
  AND NOT s.is_deleted
  LIMIT limit_count;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.simple_menu_search(search_query text)
 RETURNS TABLE(id text, title text, path text, icon text, menu_type text, rank real)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Return menu items that match the search
  RETURN QUERY
  -- Home
  SELECT
    'home'::text as id,
    'Home'::text as title,
    '/'::text as path,
    'home'::text as icon,
    'menu'::text as menu_type,
    1.0::real as rank
  WHERE LOWER('Home') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  -- Tasks
  SELECT
    'tasks'::text as id,
    'Tasks'::text as title,
    '/tasks'::text as path,
    'task_alt'::text as icon,
    'page'::text as menu_type,
    0.98::real as rank
  WHERE LOWER('Tasks') LIKE '%' || LOWER(search_query) || '%'

  -- ========== WMS Module ==========
  UNION ALL

  SELECT
    'wms-articles'::text as id,
    'Articles'::text as title,
    '/wms/articles'::text as path,
    'inventory_2'::text as icon,
    'page'::text as menu_type,
    0.95::real as rank
  WHERE LOWER('Articles') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'wms-suppliers'::text as id,
    'Suppliers'::text as title,
    '/wms/suppliers'::text as path,
    'business'::text as icon,
    'page'::text as menu_type,
    0.93::real as rank
  WHERE LOWER('Suppliers') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'wms-receipts'::text as id,
    'Receipts'::text as title,
    '/wms/receipts'::text as path,
    'receipt'::text as icon,
    'page'::text as menu_type,
    0.91::real as rank
  WHERE LOWER('Receipts') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'wms-shipments'::text as id,
    'Shipments'::text as title,
    '/wms/shipments'::text as path,
    'local_shipping'::text as icon,
    'page'::text as menu_type,
    0.89::real as rank
  WHERE LOWER('Shipments') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'wms-stock-movements'::text as id,
    'Stock Movements'::text as title,
    '/wms/stock_movements'::text as path,
    'swap_horiz'::text as icon,
    'page'::text as menu_type,
    0.87::real as rank
  WHERE LOWER('Stock Movements') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'wms-batch-management'::text as id,
    'Batch Management'::text as title,
    '/wms/batch-management'::text as path,
    'view_module'::text as icon,
    'page'::text as menu_type,
    0.85::real as rank
  WHERE LOWER('Batch Management') LIKE '%' || LOWER(search_query) || '%'

  -- ========== Manufacturing Module ==========
  UNION ALL

  SELECT
    'manufacturing-coil-management'::text as id,
    'Coil Management'::text as title,
    '/manufacturing/coil-management'::text as path,
    'settings_ethernet'::text as icon,
    'page'::text as menu_type,
    0.83::real as rank
  WHERE LOWER('Coil Management') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'manufacturing-inventory'::text as id,
    'Inventory Management'::text as title,
    '/manufacturing/inventory-management'::text as path,
    'warehouse'::text as icon,
    'page'::text as menu_type,
    0.81::real as rank
  WHERE LOWER('Inventory Management') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'manufacturing-production-tasks'::text as id,
    'Production Tasks'::text as title,
    '/manufacturing/production-tasks'::text as path,
    'engineering'::text as icon,
    'page'::text as menu_type,
    0.79::real as rank
  WHERE LOWER('Production Tasks') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'manufacturing-schedule'::text as id,
    'Schedule'::text as title,
    '/manufacturing/schedule'::text as path,
    'calendar_today'::text as icon,
    'page'::text as menu_type,
    0.77::real as rank
  WHERE LOWER('Schedule') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'manufacturing-work-orders'::text as id,
    'Work Orders'::text as title,
    '/manufacturing/work_orders'::text as path,
    'assignment'::text as icon,
    'page'::text as menu_type,
    0.75::real as rank
  WHERE LOWER('Work Orders') LIKE '%' || LOWER(search_query) || '%'

  -- ========== Base Module ==========
  UNION ALL

  SELECT
    'base-purchase-orders'::text as id,
    'Purchase Orders'::text as title,
    '/base/purchase-orders'::text as path,
    'shopping_cart'::text as icon,
    'page'::text as menu_type,
    0.73::real as rank
  WHERE LOWER('Purchase Orders') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'base-sales-orders'::text as id,
    'Sales Orders'::text as title,
    '/base/sales-orders'::text as path,
    'receipt_long'::text as icon,
    'page'::text as menu_type,
    0.71::real as rank
  WHERE LOWER('Sales Orders') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'base-customers'::text as id,
    'Customers'::text as title,
    '/base/customers'::text as path,
    'people'::text as icon,
    'page'::text as menu_type,
    0.69::real as rank
  WHERE LOWER('Customers') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'base-employees'::text as id,
    'Employees'::text as title,
    '/base/employees'::text as path,
    'badge'::text as icon,
    'page'::text as menu_type,
    0.67::real as rank
  WHERE LOWER('Employees') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'base-quality-control-types'::text as id,
    'Quality Control Types'::text as title,
    '/base/quality-control-types'::text as path,
    'verified'::text as icon,
    'page'::text as menu_type,
    0.65::real as rank
  WHERE LOWER('Quality Control Types') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'base-analytics'::text as id,
    'Sales and Purchase Analytics'::text as title,
    '/base/sales-and-purchase-analytics'::text as path,
    'analytics'::text as icon,
    'page'::text as menu_type,
    0.63::real as rank
  WHERE LOWER('Sales and Purchase Analytics') LIKE '%' || LOWER(search_query) || '%'

  -- ========== Admin Module ==========
  UNION ALL

  SELECT
    'admin-pages-menu'::text as id,
    'Pages Menu'::text as title,
    '/admin/pages_menu'::text as path,
    'menu_book'::text as icon,
    'page'::text as menu_type,
    0.61::real as rank
  WHERE LOWER('Pages Menu') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'admin-work-cycle-qc'::text as id,
    'Work Cycle and Quality Control'::text as title,
    '/admin/work-cycle-and-quality-control'::text as path,
    'settings'::text as icon,
    'page'::text as menu_type,
    0.59::real as rank
  WHERE LOWER('Work Cycle and Quality Control') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'admin-user-access-roles'::text as id,
    'User Access Roles'::text as title,
    '/admin/user-access-roles'::text as path,
    'admin_panel_settings'::text as icon,
    'page'::text as menu_type,
    0.57::real as rank
  WHERE LOWER('User Access Roles') LIKE '%' || LOWER(search_query) || '%'

  UNION ALL

  SELECT
    'admin-departments'::text as id,
    'Departments'::text as title,
    '/table/mod_manufacturing/departments'::text as path,
    'corporate_fare'::text as icon,
    'page'::text as menu_type,
    0.55::real as rank
  WHERE LOWER('Departments') LIKE '%' || LOWER(search_query) || '%'

  -- ========== Report Module ==========
  UNION ALL

  SELECT
    'report-template'::text as id,
    'Report Template'::text as title,
    '/report/report_template'::text as path,
    'description'::text as icon,
    'page'::text as menu_type,
    0.53::real as rank
  WHERE LOWER('Report Template') LIKE '%' || LOWER(search_query) || '%'

  -- ========== Data Layer Module ==========
  UNION ALL

  SELECT
    'datalayer-warehouse-locations'::text as id,
    'Warehouse Locations'::text as title,
    '/datalayer/warehouse-locations'::text as path,
    'place'::text as icon,
    'page'::text as menu_type,
    0.51::real as rank
  WHERE LOWER('Warehouse Locations') LIKE '%' || LOWER(search_query) || '%';
END;
$function$
;

CREATE OR REPLACE FUNCTION public.test_search_functions()
 RETURNS TABLE(function_name text, status text, result_count bigint)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN QUERY
  SELECT
    'simple_menu_search'::text as function_name,
    'working'::text as status,
    COUNT(*)::bigint as result_count
  FROM simple_menu_search('test');

  RETURN QUERY
  SELECT
    'simple_global_search'::text as function_name,
    'working'::text as status,
    COUNT(*)::bigint as result_count
  FROM simple_global_search('test');

  RETURN QUERY
  SELECT
    'search_menu_items'::text as function_name,
    'working'::text as status,
    COUNT(*)::bigint as result_count
  FROM search_menu_items('test');

  RETURN QUERY
  SELECT
    'get_search_suggestions'::text as function_name,
    'working'::text as status,
    COUNT(*)::bigint as result_count
  FROM get_search_suggestions('test');
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_receipt_supplier_from_po()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- If purchase_order_id is set and supplier_id is not set, get supplier from PO
  IF NEW.purchase_order_id IS NOT NULL AND NEW.supplier_id IS NULL THEN
    SELECT supplier_id INTO NEW.supplier_id
    FROM mod_base.purchase_orders
    WHERE id = NEW.purchase_order_id;
  END IF;

  RETURN NEW;
END;
$function$
;


