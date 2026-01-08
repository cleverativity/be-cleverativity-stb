set check_function_bodies = off;

CREATE OR REPLACE FUNCTION mod_base.handle_internal_production_date_change()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_deleted_count integer;
    v_updated_count integer;
    v_new_production_date date;
BEGIN
    -- Only process if production_date actually changed
    IF (OLD.production_date IS DISTINCT FROM NEW.production_date) THEN

        -- Case 1: production_date changed from date to NULL → DELETE work orders
        IF OLD.production_date IS NOT NULL AND NEW.production_date IS NULL THEN
            RAISE NOTICE 'Internal: production_date changed from % to NULL. Deleting work orders for internal_sales_order_id: %, article_id: %',
                         OLD.production_date, NEW.sales_order_id, NEW.article_id;

            -- Validate required IDs
            IF NEW.sales_order_id IS NULL OR NEW.article_id IS NULL THEN
                RAISE WARNING 'Cannot delete work orders: sales_order_id or article_id is NULL. sales_order_id: %, article_id: %',
                              NEW.sales_order_id, NEW.article_id;
            ELSE
                -- Delete work orders associated with this internal sales order item
                DELETE FROM mod_manufacturing.work_orders
                WHERE internal_sales_order_id = NEW.sales_order_id
                  AND article_id = NEW.article_id
                  AND is_deleted = false;

                GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

                RAISE NOTICE 'Internal: DELETED % work orders for internal_sales_order_id: %, article_id: %',
                             v_deleted_count, NEW.sales_order_id, NEW.article_id;
            END IF;

        -- Case 2: production_date changed from date to date → UPDATE work order scheduled_start
        ELSIF OLD.production_date IS NOT NULL AND NEW.production_date IS NOT NULL THEN
            -- Convert production_date (date) to scheduled_start (timestamp)
            v_new_production_date := NEW.production_date;

            RAISE NOTICE 'Internal: production_date changed from % to %. Updating work order scheduled_start for internal_sales_order_id: %, article_id: %',
                         OLD.production_date, NEW.production_date, NEW.sales_order_id, NEW.article_id;

            -- Validate required IDs
            IF NEW.sales_order_id IS NULL OR NEW.article_id IS NULL THEN
                RAISE WARNING 'Cannot update work orders: sales_order_id or article_id is NULL. sales_order_id: %, article_id: %',
                              NEW.sales_order_id, NEW.article_id;
            ELSE
                -- Update scheduled_start for all work orders associated with this item
                -- Set scheduled_start to the start of the production_date (00:00:00)
                UPDATE mod_manufacturing.work_orders
                SET scheduled_start = v_new_production_date::timestamp without time zone,
                    updated_at = NOW(),
                    updated_by = COALESCE(NEW.updated_by, auth.uid())
                WHERE internal_sales_order_id = NEW.sales_order_id
                  AND article_id = NEW.article_id
                  AND is_deleted = false;

                GET DIAGNOSTICS v_updated_count = ROW_COUNT;

                RAISE NOTICE 'Internal: UPDATED % work orders scheduled_start to % for internal_sales_order_id: %, article_id: %',
                             v_updated_count, v_new_production_date, NEW.sales_order_id, NEW.article_id;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_production_date_change()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_deleted_count integer;
    v_updated_count integer;
    v_new_production_date date;
BEGIN
    -- Only process if production_date actually changed
    IF (OLD.production_date IS DISTINCT FROM NEW.production_date) THEN

        -- Case 1: production_date changed from date to NULL → DELETE work orders
        IF OLD.production_date IS NOT NULL AND NEW.production_date IS NULL THEN
            RAISE NOTICE 'Regular: production_date changed from % to NULL. Deleting work orders for sales_order_id: %, article_id: %',
                         OLD.production_date, NEW.sales_order_id, NEW.article_id;

            -- Validate required IDs
            IF NEW.sales_order_id IS NULL OR NEW.article_id IS NULL THEN
                RAISE WARNING 'Cannot delete work orders: sales_order_id or article_id is NULL. sales_order_id: %, article_id: %',
                              NEW.sales_order_id, NEW.article_id;
            ELSE
                -- Delete work orders associated with this sales order item
                DELETE FROM mod_manufacturing.work_orders
                WHERE sales_order_id = NEW.sales_order_id
                  AND article_id = NEW.article_id
                  AND is_deleted = false;

                GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

                RAISE NOTICE 'Regular: DELETED % work orders for sales_order_id: %, article_id: %',
                             v_deleted_count, NEW.sales_order_id, NEW.article_id;
            END IF;

        -- Case 2: production_date changed from date to date → UPDATE work order scheduled_start
        ELSIF OLD.production_date IS NOT NULL AND NEW.production_date IS NOT NULL THEN
            -- Convert production_date (date) to scheduled_start (timestamp)
            v_new_production_date := NEW.production_date;

            RAISE NOTICE 'Regular: production_date changed from % to %. Updating work order scheduled_start for sales_order_id: %, article_id: %',
                         OLD.production_date, NEW.production_date, NEW.sales_order_id, NEW.article_id;

            -- Validate required IDs
            IF NEW.sales_order_id IS NULL OR NEW.article_id IS NULL THEN
                RAISE WARNING 'Cannot update work orders: sales_order_id or article_id is NULL. sales_order_id: %, article_id: %',
                              NEW.sales_order_id, NEW.article_id;
            ELSE
                -- Update scheduled_start for all work orders associated with this item
                -- Set scheduled_start to the start of the production_date (00:00:00)
                UPDATE mod_manufacturing.work_orders
                SET scheduled_start = v_new_production_date::timestamp without time zone,
                    updated_at = NOW(),
                    updated_by = COALESCE(NEW.updated_by, auth.uid())
                WHERE sales_order_id = NEW.sales_order_id
                  AND article_id = NEW.article_id
                  AND is_deleted = false;

                GET DIAGNOSTICS v_updated_count = ROW_COUNT;

                RAISE NOTICE 'Regular: UPDATED % work orders scheduled_start to % for sales_order_id: %, article_id: %',
                             v_updated_count, v_new_production_date, NEW.sales_order_id, NEW.article_id;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.update_production_date_on_work_order_scheduled_start_update()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_rows_updated integer;
  v_production_date date;
BEGIN
  -- Only process if scheduled_start changed and is not NULL
  IF NEW.scheduled_start IS NULL OR NEW.scheduled_start = OLD.scheduled_start THEN
    RETURN NEW;
  END IF;

  -- Convert timestamp to date for production_date field
  -- Use DATE_TRUNC to avoid timezone conversion issues
  v_production_date := DATE_TRUNC('day', NEW.scheduled_start)::date;

  -- Handle regular sales orders
  IF NEW.sales_order_id IS NOT NULL THEN
    UPDATE mod_base.sales_order_items
    SET production_date = v_production_date,
        updated_at = NOW(),
        updated_by = COALESCE(NEW.updated_by, auth.uid())
    WHERE sales_order_id = NEW.sales_order_id
      AND article_id = NEW.article_id
      AND is_deleted = false;

    GET DIAGNOSTICS v_rows_updated = ROW_COUNT;

    IF v_rows_updated > 0 THEN
      RAISE NOTICE 'Updated production_date for % sales_order_items (sales_order_id: %, article_id: %)',
                   v_rows_updated, NEW.sales_order_id, NEW.article_id;
    ELSE
      RAISE WARNING 'No sales_order_items found to update (sales_order_id: %, article_id: %)',
                    NEW.sales_order_id, NEW.article_id;
    END IF;
  END IF;

  -- Handle internal sales orders
  IF NEW.internal_sales_order_id IS NOT NULL THEN
    UPDATE mod_base.internal_sales_order_items
    SET production_date = v_production_date,
        updated_at = NOW(),
        updated_by = COALESCE(NEW.updated_by, auth.uid())
    WHERE sales_order_id = NEW.internal_sales_order_id
      AND article_id = NEW.article_id
      AND is_deleted = false;

    GET DIAGNOSTICS v_rows_updated = ROW_COUNT;

    IF v_rows_updated > 0 THEN
      RAISE NOTICE 'Updated production_date for % internal_sales_order_items (internal_sales_order_id: %, article_id: %)',
                   v_rows_updated, NEW.internal_sales_order_id, NEW.article_id;
    ELSE
      RAISE WARNING 'No internal_sales_order_items found to update (internal_sales_order_id: %, article_id: %)',
                    NEW.internal_sales_order_id, NEW.article_id;
    END IF;
  END IF;

  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Log error but don't fail the update
  RAISE WARNING 'Error updating production_date on work order scheduled_start update: %', SQLERRM;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.fn_trigger_fcm_push()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  PERFORM
    net.http_post(
      url := 'https://hffdufdierbghwcnjswt.supabase.co/functions/v1/push',
      headers := '{"Content-Type": "application/json"}'::jsonb,
      body := jsonb_build_object(
        'record', row_to_json(NEW)::jsonb,
        'event', 'INSERT'
      ),
      timeout_milliseconds := 1000
    );
  RETURN NEW;
END;
$function$
;

CREATE TRIGGER internal_sales_order_items_production_date_change_trigger AFTER UPDATE ON mod_base.internal_sales_order_items FOR EACH ROW WHEN ((old.production_date IS DISTINCT FROM new.production_date)) EXECUTE FUNCTION mod_base.handle_internal_production_date_change();

CREATE TRIGGER sales_order_items_production_date_change_trigger AFTER UPDATE ON mod_base.sales_order_items FOR EACH ROW WHEN ((old.production_date IS DISTINCT FROM new.production_date)) EXECUTE FUNCTION mod_base.handle_production_date_change();

CREATE TRIGGER trigger_update_production_date_on_work_order_scheduled_start_up AFTER UPDATE OF scheduled_start ON mod_manufacturing.work_orders FOR EACH ROW WHEN (((new.scheduled_start IS NOT NULL) AND (new.scheduled_start IS DISTINCT FROM old.scheduled_start))) EXECUTE FUNCTION mod_manufacturing.update_production_date_on_work_order_scheduled_start_update();


