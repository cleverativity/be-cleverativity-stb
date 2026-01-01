


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "app_auth";


ALTER SCHEMA "app_auth" OWNER TO "postgres";


CREATE SCHEMA IF NOT EXISTS "common";


ALTER SCHEMA "common" OWNER TO "postgres";


CREATE SCHEMA IF NOT EXISTS "mod_admin";


ALTER SCHEMA "mod_admin" OWNER TO "postgres";


CREATE SCHEMA IF NOT EXISTS "mod_base";


ALTER SCHEMA "mod_base" OWNER TO "postgres";


CREATE SCHEMA IF NOT EXISTS "mod_crm";


ALTER SCHEMA "mod_crm" OWNER TO "postgres";


CREATE SCHEMA IF NOT EXISTS "mod_datalayer";


ALTER SCHEMA "mod_datalayer" OWNER TO "postgres";


CREATE SCHEMA IF NOT EXISTS "mod_home";


ALTER SCHEMA "mod_home" OWNER TO "postgres";


CREATE SCHEMA IF NOT EXISTS "mod_hr";


ALTER SCHEMA "mod_hr" OWNER TO "postgres";


CREATE SCHEMA IF NOT EXISTS "mod_manufacturing";


ALTER SCHEMA "mod_manufacturing" OWNER TO "postgres";


CREATE SCHEMA IF NOT EXISTS "mod_pulse";


ALTER SCHEMA "mod_pulse" OWNER TO "postgres";


CREATE SCHEMA IF NOT EXISTS "mod_quality_control";


ALTER SCHEMA "mod_quality_control" OWNER TO "postgres";


CREATE SCHEMA IF NOT EXISTS "mod_wms";


ALTER SCHEMA "mod_wms" OWNER TO "postgres";


CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgsodium";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "http" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."defect_severity_type" AS ENUM (
    'MINOR',
    'MAJOR',
    'CRITICAL'
);


ALTER TYPE "public"."defect_severity_type" OWNER TO "postgres";


CREATE TYPE "public"."qc_status_type" AS ENUM (
    'PLANNED',
    'IN_PROGRESS',
    'PASSED',
    'FAILED',
    'HOLD',
    'PENDING_REVIEW',
    'CONDITIONALLY_ACCEPTED',
    'REJECTED'
);


ALTER TYPE "public"."qc_status_type" OWNER TO "postgres";


CREATE TYPE "public"."return_status_type" AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED',
    'IN_TRANSIT',
    'RECEIVED_BY_SUPPLIER',
    'CREDIT_ISSUED',
    'REPLACEMENT_SENT',
    'CLOSED'
);


ALTER TYPE "public"."return_status_type" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "common"."set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "common"."set_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_admin"."delete_avatar"("avatar_url" "text", OUT "status" integer, OUT "content" "text") RETURNS "record"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  select
      into status, content
           result.status, result.content
      from mod_admin.delete_storage_object('avatars', avatar_url) as result;
end;
$$;


ALTER FUNCTION "mod_admin"."delete_avatar"("avatar_url" "text", OUT "status" integer, OUT "content" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_admin"."delete_background_image"("background_image_url" "text", OUT "status" integer, OUT "content" "text") RETURNS "record"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  select
      into status, content
           result.status, result.content
      from mod_admin.delete_storage_object('background_images', background_image_url) as result;
end;
$$;


ALTER FUNCTION "mod_admin"."delete_background_image"("background_image_url" "text", OUT "status" integer, OUT "content" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_admin"."delete_old_avatar"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  status int;
  content text;
begin
  if coalesce(old.avatar_url, '') <> ''
      and (tg_op = 'DELETE' or (old.avatar_url <> new.avatar_url)) then
    select
      into status, content
      result.status, result.content
      from mod_admin.delete_avatar(old.avatar_url) as result;
    if status <> 200 then
      raise warning 'Could not delete avatar: % %', status, content;
    end if;
  end if;
  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;


ALTER FUNCTION "mod_admin"."delete_old_avatar"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_admin"."delete_old_background_image"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  status int;
  content text;
begin
  if coalesce(old.background_image_url, '') <> ''
      and (tg_op = 'DELETE' or (old.background_image_url <> new.background_image_url)) then
    select
      into status, content
      result.status, result.content
      from mod_admin.delete_background_image(old.background_image_url) as result;
    if status <> 200 then
      raise warning 'Could not delete background image: % %', status, content;
    end if;
  end if;
  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;


ALTER FUNCTION "mod_admin"."delete_old_background_image"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_admin"."delete_old_profile"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  delete from mod_admin.user_profiles where id = old.id;
  return old;
end;
$$;


ALTER FUNCTION "mod_admin"."delete_old_profile"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_admin"."delete_storage_object"("bucket" "text", "object" "text", OUT "status" integer, OUT "content" "text") RETURNS "record"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  project_url text := 'https://ccyaftqytacgudiwlhsm.supabase.co';
  service_role_key text := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNjeWFmdHF5dGFjZ3VkaXdsaHNtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczOTk2NjM3MCwiZXhwIjoyMDU1NTQyMzcwfQ.hcZT5DpPgRYYHKeDSd9G-gXWwuwruYNF6guk_SXx_xs'; --  full access needed
  url text := project_url||'/storage/v1/object/'||bucket||'/'||object;
begin
  select
      into status, content
           result.status::int, result.content::text
      FROM extensions.http((
    'DELETE',
    url,
    ARRAY[extensions.http_header('authorization','Bearer '||service_role_key)],
    NULL,
    NULL)::extensions.http_request) as result;
end;
$$;


ALTER FUNCTION "mod_admin"."delete_storage_object"("bucket" "text", "object" "text", OUT "status" integer, OUT "content" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_admin"."handle_domain_modules_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_admin"."handle_domain_modules_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_admin"."handle_domain_users_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if tg_op = 'insert' then
  -- if the insert doesn't explicitly provide created_by,
  -- default to the user performing this operation.
  new."created_by" := coalesce(
    new."created_by",
    auth.uid()
  );
  
  elsif tg_op = 'update' then
  -- on update, set the user performing this operation and the updated timestamp
  new."updated_by" := auth.uid();
  new."updated_at" := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_admin"."handle_domain_users_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_admin"."handle_domains_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if tg_op = 'insert' then
  -- if the insert doesn't explicitly provide created_by,
  -- default to the user performing this operation.
  new."created_by" := coalesce(
    new."created_by",
    auth.uid()
  );
  
  elsif tg_op = 'update' then
  -- on update, set the user performing this operation and the updated timestamp
  new."updated_by" := auth.uid();
  new."updated_at" := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_admin"."handle_domains_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_admin"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_first_name text;
    v_last_name text;
    v_description text;
    v_phone text;
    v_company text;
    v_address text;
    v_city text;
    v_province text;
    v_zip_code text;
    v_country text;
    v_domain_id uuid;
    v_department_ids uuid[];
    v_dept_id uuid;
    v_dept_json jsonb;
    v_error_message text;
BEGIN
    -- Initialize error handling
    BEGIN
        -- Get the default domain_id, fallback to a hardcoded one if needed
        SELECT id INTO v_domain_id 
        FROM mod_admin.domains 
        WHERE id = 'f89402d3-1096-405c-9919-e1f3f121ad84'::uuid
        LIMIT 1;
        
        -- Fallback if domain doesn't exist
        IF v_domain_id IS NULL THEN
            v_domain_id := 'f89402d3-1096-405c-9919-e1f3f121ad84'::uuid;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error getting domain_id: %', SQLERRM;
        v_domain_id := 'f89402d3-1096-405c-9919-e1f3f121ad84'::uuid;
    END;

    -- Extract names with proper length handling
    BEGIN
        v_first_name := NULLIF(TRIM(COALESCE(
            (NEW.raw_user_meta_data->>'firstName')::text,
            (NEW.raw_app_meta_data->>'firstName')::text,
            'User'  -- Default value that meets the constraint
        )), '');

        v_last_name := NULLIF(TRIM(COALESCE(
            (NEW.raw_user_meta_data->>'lastName')::text,
            (NEW.raw_app_meta_data->>'lastName')::text,
            'Account'  -- Default value that meets the constraint
        )), '');
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error extracting names: %', SQLERRM;
        v_first_name := 'User';
        v_last_name := 'Account';
    END;

    -- Extract additional fields from user metadata
    BEGIN
        v_description := COALESCE(
            (NEW.raw_user_meta_data->>'jobTitle')::text,
            (NEW.raw_app_meta_data->>'jobTitle')::text,
            ''
        );

        v_phone := COALESCE(
            (NEW.raw_user_meta_data->>'phone')::text,
            (NEW.raw_app_meta_data->>'phone')::text,
            ''
        );

        v_company := COALESCE(
            (NEW.raw_user_meta_data->>'companyName')::text,
            (NEW.raw_app_meta_data->>'companyName')::text,
            ''
        );

        v_address := COALESCE(
            (NEW.raw_user_meta_data->>'address')::text,
            (NEW.raw_app_meta_data->>'address')::text,
            ''
        );

        v_city := COALESCE(
            (NEW.raw_user_meta_data->>'city')::text,
            (NEW.raw_app_meta_data->>'city')::text,
            ''
        );

        v_province := COALESCE(
            (NEW.raw_user_meta_data->>'province')::text,
            (NEW.raw_app_meta_data->>'province')::text,
            ''
        );

        v_zip_code := COALESCE(
            (NEW.raw_user_meta_data->>'zipCode')::text,
            (NEW.raw_app_meta_data->>'zipCode')::text,
            ''
        );

        v_country := COALESCE(
            (NEW.raw_user_meta_data->>'country')::text,
            (NEW.raw_app_meta_data->>'country')::text,
            ''
        );
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error extracting metadata fields: %', SQLERRM;
    END;

    -- Extract department IDs from metadata with improved error handling
    BEGIN
        v_department_ids := ARRAY[]::uuid[];
        
        -- Try to get departmentIds from user metadata first
        IF NEW.raw_user_meta_data ? 'departmentIds' THEN
            v_dept_json := NEW.raw_user_meta_data->'departmentIds';
            
            -- Handle both array and string (JSON) formats
            IF jsonb_typeof(v_dept_json) = 'array' THEN
                -- Direct array format
                SELECT array_agg(value::uuid) INTO v_department_ids
                FROM jsonb_array_elements_text(v_dept_json)
                WHERE value IS NOT NULL AND value != '';
            ELSIF jsonb_typeof(v_dept_json) = 'string' THEN
                -- String format (JSON stringified array) - parse it
                BEGIN
                    v_dept_json := v_dept_json::text::jsonb;
                    IF jsonb_typeof(v_dept_json) = 'array' THEN
                        SELECT array_agg(value::uuid) INTO v_department_ids
                        FROM jsonb_array_elements_text(v_dept_json)
                        WHERE value IS NOT NULL AND value != '';
                    END IF;
                EXCEPTION WHEN OTHERS THEN
                    RAISE WARNING 'Error parsing departmentIds string: %', SQLERRM;
                END;
            END IF;
        -- Fallback to app metadata
        ELSIF NEW.raw_app_meta_data ? 'departmentIds' THEN
            v_dept_json := NEW.raw_app_meta_data->'departmentIds';
            
            IF jsonb_typeof(v_dept_json) = 'array' THEN
                SELECT array_agg(value::uuid) INTO v_department_ids
                FROM jsonb_array_elements_text(v_dept_json)
                WHERE value IS NOT NULL AND value != '';
            ELSIF jsonb_typeof(v_dept_json) = 'string' THEN
                BEGIN
                    v_dept_json := v_dept_json::text::jsonb;
                    IF jsonb_typeof(v_dept_json) = 'array' THEN
                        SELECT array_agg(value::uuid) INTO v_department_ids
                        FROM jsonb_array_elements_text(v_dept_json)
                        WHERE value IS NOT NULL AND value != '';
                    END IF;
                EXCEPTION WHEN OTHERS THEN
                    RAISE WARNING 'Error parsing departmentIds from app metadata: %', SQLERRM;
                END;
            END IF;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Error extracting department IDs: %', SQLERRM;
        v_department_ids := ARRAY[]::uuid[];
    END;

    -- Insert into user_profiles with all available fields including address fields
    BEGIN
        INSERT INTO mod_admin.user_profiles (
            id,
            "firstName",
            "lastName",
            description,
            phone,
            mobile,
            company,
            address,
            city,
            province,
            zip_code,
            country,
            enabled,
            created_at,
            updated_at
        )
        VALUES (
            NEW.id,
            v_first_name,
            v_last_name,
            v_description,
            v_phone,
            v_phone, -- Use phone for mobile as well
            v_company,
            v_address,
            v_city,
            v_province,
            v_zip_code,
            v_country,
            true, -- Enable new users by default
            COALESCE(NEW.created_at, NOW()),
            COALESCE(NEW.updated_at, NOW())
        );
    EXCEPTION WHEN OTHERS THEN
        v_error_message := 'Failed to create user_profile: ' || SQLERRM;
        RAISE WARNING '%', v_error_message;
        -- Don't re-raise here - continue with other inserts
    END;

    -- Insert into employees table
    BEGIN
        INSERT INTO mod_base.employees (
            id,
            name,
            description,
            last_name,
            phone,
            domain_id,
            created_at,
            updated_at
        )
        VALUES (
            NEW.id,
            v_first_name,
            v_description,
            v_last_name,
            v_phone,
            v_domain_id,
            COALESCE(NEW.created_at, NOW()),
            COALESCE(NEW.updated_at, NOW())
        );
    EXCEPTION WHEN OTHERS THEN
        v_error_message := 'Failed to create employee record: ' || SQLERRM;
        RAISE WARNING '%', v_error_message;
        -- Don't re-raise here - continue with other inserts
    END;

    -- Insert into domain_users table
    BEGIN
        INSERT INTO mod_admin.domain_users (
            user_id,
            domain_id,
            role,
            created_at,
            updated_at
        )
        VALUES (
            NEW.id,
            v_domain_id,
            'user',
            COALESCE(NEW.created_at, NOW()),
            COALESCE(NEW.updated_at, NOW())
        );
    EXCEPTION WHEN OTHERS THEN
        v_error_message := 'Failed to create domain_users record: ' || SQLERRM;
        RAISE WARNING '%', v_error_message;
        -- Don't re-raise here - continue with department assignments
    END;

    -- Insert department assignments if any departments were selected
    IF array_length(v_department_ids, 1) > 0 THEN
        FOREACH v_dept_id IN ARRAY v_department_ids
        LOOP
            BEGIN
                INSERT INTO mod_base.employees_departments (
                    employee_id,
                    department_id,
                    role,
                    domain_id,
                    created_at,
                    updated_at
                )
                VALUES (
                    NEW.id,
                    v_dept_id,
                    'worker', -- Default role for new employees
                    v_domain_id,
                    COALESCE(NEW.created_at, NOW()),
                    COALESCE(NEW.updated_at, NOW())
                );
            EXCEPTION WHEN OTHERS THEN
                v_error_message := 'Failed to create department assignment for ' || v_dept_id || ': ' || SQLERRM;
                RAISE WARNING '%', v_error_message;
                -- Continue with next department
            END;
        END LOOP;
    END IF;

    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    -- Log the error but don't abort the transaction
    -- This allows the user creation to complete even if some side effects fail
    RAISE WARNING 'Error in handle_new_user trigger for user %: %', NEW.id, SQLERRM;
    -- Return NEW to allow the user creation to succeed
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_admin"."handle_new_user"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_admin"."handle_new_user"() IS 'Creates user profile, domain user record, employee record, and department assignments when a new user signs up. Improved error handling prevents transaction abortion and allows user creation to succeed even if some side effects fail.';



CREATE OR REPLACE FUNCTION "mod_admin"."handle_user_deletion"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Delete from employees_departments first (due to foreign key constraints)
    DELETE FROM mod_base.employees_departments WHERE employee_id = OLD.id;
    
    -- Delete from employees table
    DELETE FROM mod_base.employees WHERE id = OLD.id;
    
    -- Delete from domain_users table
    DELETE FROM mod_admin.domain_users WHERE user_id = OLD.id;
    
    -- Note: user_profiles will be automatically deleted due to CASCADE constraint
    
    RETURN OLD;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error in handle_user_deletion trigger: %', SQLERRM;
    RETURN OLD;
END;
$$;


ALTER FUNCTION "mod_admin"."handle_user_deletion"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_admin"."handle_user_deletion"() IS 'Handles cascade deletion of user-related records when a user is deleted from auth.users. Deletes from employees_departments, employees, domain_users, and user_profiles tables.';



CREATE OR REPLACE FUNCTION "mod_admin"."handle_userprofile_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_admin"."handle_userprofile_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_admin"."is_subdomain"("child" "uuid", "parent" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE
    AS $$
with recursive hierarchy as (
    select id, parent_domain_id from mod_admin.domains where id = child
    union all
    select d.id, d.parent_domain_id 
    from mod_admin.domains d 
    join hierarchy h on d.id = h.parent_domain_id
)
select exists (select 1 from hierarchy where parent_domain_id = parent);
$$;


ALTER FUNCTION "mod_admin"."is_subdomain"("child" "uuid", "parent" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."alert_quality_control_failed"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  notification_name TEXT;
  notification_description TEXT;
  article_name TEXT;
  work_order_name TEXT;
BEGIN
  -- Only proceed if status changed to FAILED
  IF NEW.status = 'FAILED' AND (OLD.status IS NULL OR OLD.status != 'FAILED') THEN
    -- Get article name if article_id exists
    IF NEW.article_id IS NOT NULL THEN
      SELECT name INTO article_name 
      FROM mod_base.articles 
      WHERE id = NEW.article_id;
    ELSE
      article_name := 'Unknown Article';
    END IF;
    
    -- Get work order name if work_order_id exists
    IF NEW.work_order_id IS NOT NULL THEN
      SELECT name INTO work_order_name 
      FROM mod_manufacturing.work_orders 
      WHERE id = NEW.work_order_id;
    ELSE
      work_order_name := 'Standalone QC';
    END IF;
    
    -- Create notification name and description
    notification_name := 'Quality Control Failed: ' || COALESCE(NEW.name, 'QC-' || NEW.id::text);
    notification_description := 'Quality control for ' || article_name || 
                              CASE 
                                WHEN NEW.work_order_id IS NOT NULL THEN ' (Work Order: ' || work_order_name || ')'
                                ELSE ''
                              END ||
                              ' has failed. Quantity checked: ' || NEW.quantity_checked ||
                              ', Passed: ' || NEW.quantity_passed ||
                              ', Failed: ' || NEW.quantity_failed;
    
    -- Add additional details if notes exist
    IF NEW.notes IS NOT NULL AND NEW.notes != '' THEN
      notification_description := notification_description || '. Notes: ' || NEW.notes;
    END IF;
    
    -- Insert notification for the WMS manager
    INSERT INTO mod_pulse.notifications (
      name,
      description,
      type,
      user_id,
      created_by,
      domain_id,
      department_id
    ) VALUES (
      notification_name,
      notification_description,
      'sla_warning',
      '0d26df09-2cf1-4b69-89ca-668db5201153'::uuid, -- WMS Manager ID
      NEW.updated_by,
      COALESCE(NEW.domain_id, 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid), -- Use QC domain_id or default domain
      NULL -- department_id - can be set later if needed
    );
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."alert_quality_control_failed"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."calculate_qc_status"("p_quantity_checked" integer, "p_quantity_passed" integer, "p_quantity_failed" integer, "p_acceptance_number" integer, "p_rejection_number" integer) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- If nothing checked yet
    IF p_quantity_checked = 0 THEN
        RETURN 'PLANNED';
    END IF;

    -- If all items checked
    IF p_quantity_checked = (p_quantity_passed + p_quantity_failed) THEN
        -- If failed items exceed rejection number
        IF p_quantity_failed > p_rejection_number THEN
            RETURN 'FAILED';
        -- If failed items within acceptance number
        ELSIF p_quantity_failed <= p_acceptance_number THEN
            RETURN 'PASSED';
        ELSE
            RETURN 'PENDING_REVIEW';
        END IF;
    ELSE
        RETURN 'IN_PROGRESS';
    END IF;
END;
$$;


ALTER FUNCTION "mod_base"."calculate_qc_status"("p_quantity_checked" integer, "p_quantity_passed" integer, "p_quantity_failed" integer, "p_acceptance_number" integer, "p_rejection_number" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."cleanup_work_orders_on_internal_unschedule"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Check if production_date was unscheduled (changed from date to NULL)
    IF OLD.production_date IS NOT NULL AND NEW.production_date IS NULL THEN
        -- Delete work orders associated with this internal sales order item
        -- Match by internal_sales_order_id (which corresponds to sales_order_id in internal_sales_order_items) and article_id
        DELETE FROM mod_manufacturing.work_orders
        WHERE internal_sales_order_id = NEW.sales_order_id
          AND article_id = NEW.article_id
          AND is_deleted = false;
        
        RAISE NOTICE 'Deleted work orders for internal_sales_order_id: %, article_id: %', 
                     NEW.sales_order_id, NEW.article_id;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."cleanup_work_orders_on_internal_unschedule"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_base"."cleanup_work_orders_on_internal_unschedule"() IS 'Automatically deletes work orders when an internal sales order item production date is unscheduled (set to NULL)';



CREATE OR REPLACE FUNCTION "mod_base"."cleanup_work_orders_on_unschedule"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Check if production_date was unscheduled (changed from date to NULL)
    IF OLD.production_date IS NOT NULL AND NEW.production_date IS NULL THEN
        -- Delete work orders associated with this sales order item
        -- Match by sales_order_id and article_id to be specific
        DELETE FROM mod_manufacturing.work_orders
        WHERE sales_order_id = NEW.sales_order_id
          AND article_id = NEW.article_id
          AND is_deleted = false;
        
        RAISE NOTICE 'Deleted work orders for sales_order_id: %, article_id: %', 
                     NEW.sales_order_id, NEW.article_id;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."cleanup_work_orders_on_unschedule"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_base"."cleanup_work_orders_on_unschedule"() IS 'Automatically deletes work orders when a sales order item production date is unscheduled (set to NULL)';



CREATE OR REPLACE FUNCTION "mod_base"."count_active_records"("table_name" "text", "schema_name" "text" DEFAULT 'mod_base'::"text") RETURNS bigint
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    result bigint;
    query_text text;
BEGIN
    -- Build dynamic query to count active records
    query_text := format(
        'SELECT COUNT(*) FROM %I.%I WHERE is_deleted = false',
        schema_name,
        table_name
    );
    
    EXECUTE query_text INTO result;
    
    RETURN COALESCE(result, 0);
EXCEPTION
    WHEN OTHERS THEN
        -- Return 0 if there's any error
        RETURN 0;
END;
$$;


ALTER FUNCTION "mod_base"."count_active_records"("table_name" "text", "schema_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."count_total_records"("table_name" "text", "schema_name" "text" DEFAULT 'mod_base'::"text") RETURNS bigint
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    result bigint;
    query_text text;
BEGIN
    -- Build dynamic query to count total records
    query_text := format(
        'SELECT COUNT(*) FROM %I.%I',
        schema_name,
        table_name
    );
    
    EXECUTE query_text INTO result;
    
    RETURN COALESCE(result, 0);
EXCEPTION
    WHEN OTHERS THEN
        -- Return 0 if there's any error
        RETURN 0;
END;
$$;


ALTER FUNCTION "mod_base"."count_total_records"("table_name" "text", "schema_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."create_quality_control_for_shipment"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  qc_type_imballo_id uuid := '0ce07adb-7839-4064-ab4e-cf47058ea181';
  qc_type_ddt_id uuid := '11e50e4a-c5e2-4d79-9681-feca2d8897d1';
  qc_type_imballo_record mod_base.quality_control_types%ROWTYPE;
  qc_type_ddt_record mod_base.quality_control_types%ROWTYPE;
BEGIN
  -- Get QC type records to populate name, description, and code
  SELECT * INTO qc_type_imballo_record
  FROM mod_base.quality_control_types
  WHERE id = qc_type_imballo_id AND is_deleted = false;
  
  SELECT * INTO qc_type_ddt_record
  FROM mod_base.quality_control_types
  WHERE id = qc_type_ddt_id AND is_deleted = false;
  
  -- Create first QC record: Verifica imballo idoneo
  IF qc_type_imballo_record.id IS NOT NULL THEN
    INSERT INTO mod_base.quality_control (
      name,
      description,
      code,
      status,
      avatar_url,
      shipment_id,
      quality_control_type_id,
      domain_id,
      reference_type,
      reference_id,
      started_date,
      created_by
    ) VALUES (
      qc_type_imballo_record.name,
      qc_type_imballo_record.description,
      qc_type_imballo_record.code || '-' || substring(NEW.id::text, 1, 8),
      'IN_PROGRESS',
      '',
      NEW.id,
      qc_type_imballo_record.id,
      NEW.domain_id,
      CASE 
        WHEN NEW.sales_order_id IS NOT NULL THEN 'SALES_ORDER'
        ELSE NULL
      END,
      CASE 
        WHEN NEW.sales_order_id IS NOT NULL THEN NEW.sales_order_id
        ELSE NEW.id
      END,
      now(),
      NEW.created_by
    );
  END IF;
  
  -- Create second QC record: Verifica DDT
  IF qc_type_ddt_record.id IS NOT NULL THEN
    INSERT INTO mod_base.quality_control (
      name,
      description,
      code,
      status,
      avatar_url,
      shipment_id,
      quality_control_type_id,
      domain_id,
      reference_type,
      reference_id,
      started_date,
      created_by
    ) VALUES (
      qc_type_ddt_record.name,
      qc_type_ddt_record.description,
      qc_type_ddt_record.code || '-' || substring(NEW.id::text, 1, 8),
      'IN_PROGRESS',
      '',
      NEW.id,
      qc_type_ddt_record.id,
      NEW.domain_id,
      CASE 
        WHEN NEW.sales_order_id IS NOT NULL THEN 'SALES_ORDER'
        ELSE NULL
      END,
      CASE 
        WHEN NEW.sales_order_id IS NOT NULL THEN NEW.sales_order_id
        ELSE NEW.id
      END,
      now(),
      NEW.created_by
    );
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."create_quality_control_for_shipment"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_base"."create_quality_control_for_shipment"() IS 'Automatically creates 2 quality control records (Verifica imballo idoneo and Verifica DDT) when a new shipment is created. The QC records are set to IN_PROGRESS status and linked to the shipment via shipment_id.';



CREATE OR REPLACE FUNCTION "mod_base"."direct_alert_new_sales_order"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  notification_name TEXT;
  notification_description TEXT;
BEGIN
  -- Create notification name and description (without item count)
  notification_name := 'Nuovo Ordine di Vendita: ' || NEW.name;
  notification_description := 'L''ordine ' || NEW.sales_order_number || ' è stato creato';
  
  -- Insert notification for the specified user
  INSERT INTO mod_pulse.notifications (
    name,
    description,
    type,
    user_id,
    created_by,
    domain_id,
    department_id
  ) VALUES (
    notification_name,
    notification_description,
    'new_pulse',
    'c128077b-84a5-48b9-ac14-822477d62a87'::uuid,
    NEW.created_by,
    NEW.domain_id,
    NULL -- department_id - can be set later if needed
  );
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."direct_alert_new_sales_order"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."ensure_single_primary_address"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "mod_base"."ensure_single_primary_address"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."generate_serial_number_for_sales_order_item"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_article_record mod_base.articles%ROWTYPE;
    v_category_id UUID;
    v_current_year INTEGER;
    v_year_suffix TEXT;
    v_prefix TEXT;
    v_counter_record mod_base.serial_number_counters%ROWTYPE;
    v_next_incremental INTEGER;
    v_quantity INTEGER;
    v_serial_numbers TEXT[];
    v_serial_number TEXT;
    v_i INTEGER;
    
    -- Category UUIDs for serial number generation
    v_serbatoi_category_id UUID := 'ccbfd8c9-dc44-450c-a9ac-349e6b6350e0'; -- Serbatoi
    v_scambiatori_srs_category_id UUID := 'f938840d-d929-450e-af27-e0e678bda7fe'; -- Scambiatori di calore SRS
    v_preparatori_category_id UUID := 'd932470c-2c0b-4f5e-81be-509dbf71709c'; -- Preparatori
    v_coibentazioni_category_id UUID := '0e5c0b11-e04f-471a-a7d8-7a522356eb81'; -- Coibentazioni
    v_bollittori_category_id UUID := '1f7d33e4-b80b-40da-922f-a69863c76f75'; -- Bollittori
    v_defangatori_category_id UUID := '812aac37-04e7-4c8a-870e-8a7bd58f0c92'; -- Defangatori
    v_scambiatori_piastre_sp_category_id UUID := '47e1315c-a8d8-4776-b4ff-8652856f877d'; -- Scambiatori di calore a piastre SP
    
    v_needs_serial_number BOOLEAN := FALSE;
BEGIN
    -- Skip if this is a recipe component (is_recipe = true)
    IF NEW.is_recipe = true THEN
        RETURN NEW;
    END IF;
    
    -- Get the article record
    SELECT * INTO v_article_record
    FROM mod_base.articles
    WHERE id = NEW.article_id
    AND is_deleted = false;
    
    -- If article not found, skip
    IF v_article_record.id IS NULL THEN
        RETURN NEW;
    END IF;
    
    -- Check if article qualifies for serial number generation
    -- Option 1: Article type is 'heat_exchanger' -> use Scambiatori di calore SRS category
    IF v_article_record.type = 'heat_exchanger' THEN
        v_needs_serial_number := TRUE;
        v_category_id := v_scambiatori_srs_category_id;
    -- Option 2: Article belongs to one of the specific categories
    ELSIF v_article_record.category_id IN (
        v_serbatoi_category_id,
        v_scambiatori_srs_category_id,
        v_preparatori_category_id,
        v_coibentazioni_category_id,
        v_bollittori_category_id,
        v_defangatori_category_id,
        v_scambiatori_piastre_sp_category_id
    ) THEN
        v_needs_serial_number := TRUE;
        v_category_id := v_article_record.category_id;
    END IF;
    
    -- If article doesn't qualify, skip
    IF NOT v_needs_serial_number OR v_category_id IS NULL THEN
        RETURN NEW;
    END IF;
    
    -- Get current year and year suffix (last 2 digits)
    v_current_year := EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;
    v_year_suffix := LPAD((v_current_year % 100)::TEXT, 2, '0');
    
    -- Extract prefix from article name (first 2 characters)
    -- Handle cases where name might be shorter or have spaces
    v_prefix := UPPER(SUBSTRING(TRIM(v_article_record.name) FROM 1 FOR 2));
    
    -- If prefix is less than 2 characters, skip
    IF LENGTH(v_prefix) < 2 THEN
        RETURN NEW;
    END IF;
    
    -- Get or create counter for this category and year
    -- First, try to insert (will fail silently if exists due to unique constraint)
    INSERT INTO mod_base.serial_number_counters (
        category_id,
        year,
        last_incremental_number,
        created_by,
        updated_by
    ) VALUES (
        v_category_id,
        v_current_year,
        0,
        NEW.created_by,
        NEW.created_by
    )
    ON CONFLICT (category_id, year) DO NOTHING;
    
    -- Now select with FOR UPDATE to lock the row (prevents concurrent modifications)
    SELECT * INTO v_counter_record
    FROM mod_base.serial_number_counters
    WHERE category_id = v_category_id
    AND year = v_current_year
    FOR UPDATE;
    
    -- This should never be NULL after the INSERT ... ON CONFLICT, but check anyway
    IF v_counter_record.id IS NULL THEN
        RAISE EXCEPTION 'Failed to get or create serial number counter for category % and year %', v_category_id, v_current_year;
    END IF;
    
    -- Get quantity (convert to integer, rounding if needed)
    v_quantity := GREATEST(1, ROUND(NEW.quantity_ordered)::INTEGER);
    
    -- Initialize array for serial numbers
    v_serial_numbers := ARRAY[]::TEXT[];
    
    -- Generate serial numbers for each unit
    FOR v_i IN 1..v_quantity LOOP
        -- Increment the counter
        v_next_incremental := v_counter_record.last_incremental_number + 1;
        
        -- Build serial number: PREFIX + YY + zero-padded incremental number (5 digits)
        v_serial_number := v_prefix || v_year_suffix || LPAD(v_next_incremental::TEXT, 5, '0');
        
        -- Add to array
        v_serial_numbers := array_append(v_serial_numbers, v_serial_number);
        
        -- Update counter for next iteration
        v_counter_record.last_incremental_number := v_next_incremental;
    END LOOP;
    
    -- Update the counter in the database
    UPDATE mod_base.serial_number_counters
    SET last_incremental_number = v_counter_record.last_incremental_number,
        updated_at = NOW(),
        updated_by = NEW.created_by
    WHERE id = v_counter_record.id;
    
    -- Join serial numbers with comma and update the sales_order_item
    UPDATE mod_base.sales_order_items
    SET serial_number = array_to_string(v_serial_numbers, ','),
        updated_at = NOW()
    WHERE id = NEW.id;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."generate_serial_number_for_sales_order_item"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_base"."generate_serial_number_for_sales_order_item"() IS 'Automatically generates serial numbers for sales_order_items when inserted. 
Qualifies articles if type = "heat_exchanger" (uses Scambiatori di calore SRS category) 
or if category is one of: Serbatoi, Scambiatori di calore SRS, Preparatori, Coibentazioni, Bollittori, Defangatori, Scambiatori di calore a piastre SP.
Generates serial numbers in format PREFIX[YY][incremental_nr] where incremental_nr is zero-padded to 5 digits.
For quantity_ordered > 1, generates multiple serial numbers comma-separated.
Skips recipe components (is_recipe = true).';



CREATE OR REPLACE FUNCTION "mod_base"."get_checklist_results_summary"("qc_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    result jsonb;
BEGIN
    SELECT jsonb_build_object(
        'total_items', COUNT(*),
        'passed_items', COUNT(*) FILTER (WHERE result = true),
        'failed_items', COUNT(*) FILTER (WHERE result = false),
        'pass_rate', ROUND(
            (COUNT(*) FILTER (WHERE result = true)::decimal / NULLIF(COUNT(*), 0) * 100), 2
        ),
        'items', jsonb_agg(
            jsonb_build_object(
                'checklist_item', checklist_item,
                'result', result,
                'notes', notes,
                'created_at', created_at
            ) ORDER BY created_at
        )
    ) INTO result
    FROM mod_base.quality_control_checklist_results
    WHERE quality_control_id = qc_id
      AND is_deleted = false;
    
    RETURN COALESCE(result, jsonb_build_object(
        'total_items', 0,
        'passed_items', 0,
        'failed_items', 0,
        'pass_rate', 0,
        'items', '[]'::jsonb
    ));
END;
$$;


ALTER FUNCTION "mod_base"."get_checklist_results_summary"("qc_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_announcements_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_base"."handle_announcements_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_archive_sales_order_on_status_completed"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Safety guard: only process when status changes to 'completed'
    IF NEW.status IS DISTINCT FROM 'completed' OR OLD.status = 'completed' THEN
        RETURN NEW;
    END IF;

    -- Wrap entire logic in error handling to prevent transaction rollback
    BEGIN
        -- Archive the sales order
        UPDATE mod_base.sales_orders
        SET is_archived = TRUE,
            updated_at = NOW(),
            updated_by = NEW.updated_by
        WHERE id = NEW.id
          AND is_archived = FALSE; -- Only update if not already archived
        
        IF FOUND THEN
            RAISE NOTICE 'Successfully archived sales order % (status changed to completed)', NEW.id;
        END IF;

    EXCEPTION WHEN OTHERS THEN
        -- Log the error but don't abort the transaction
        -- This allows the sales order status update to complete even if archiving fails
        RAISE WARNING 'Error in handle_archive_sales_order_on_status_completed for sales order %: %', NEW.id, SQLERRM;
        -- Return NEW to allow the sales order status update to succeed
    END;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."handle_archive_sales_order_on_status_completed"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_base"."handle_archive_sales_order_on_status_completed"() IS 'On update of sales_orders status to completed, sets is_archived = TRUE for the sales order. Includes error handling to prevent transaction rollback - sales order status update will succeed even if archiving fails.';



CREATE OR REPLACE FUNCTION "mod_base"."handle_article_categories_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_base"."handle_article_categories_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_articles_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_base"."handle_articles_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_customer_addresses_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "mod_base"."handle_customer_addresses_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_customers_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_base"."handle_customers_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_departments_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_base"."handle_departments_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_employees_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_base"."handle_employees_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_employees_departments_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_base"."handle_employees_departments_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_internal_sales_order_completion_on_manufacturing"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_internal_sales_order_id UUID;
    v_total_items INTEGER;
    v_manufactured_items INTEGER;
BEGIN
    -- Only process when is_manufactured changes to TRUE
    IF NEW.is_manufactured = TRUE AND (OLD.is_manufactured IS NULL OR OLD.is_manufactured = FALSE) THEN
        
        -- Get the sales_order_id (which references internal_sales_orders) from the updated item
        v_internal_sales_order_id := NEW.sales_order_id;
        
        -- Skip if no sales_order_id
        IF v_internal_sales_order_id IS NULL THEN
            RAISE NOTICE 'Internal sales order item % has no sales_order_id, skipping completion check', NEW.id;
            RETURN NEW;
        END IF;
        
        -- Count total items and manufactured items for this internal sales order
        -- Only count non-deleted items
        SELECT 
            COUNT(*) FILTER (WHERE is_deleted = false),
            COUNT(*) FILTER (WHERE is_deleted = false AND is_manufactured = true)
        INTO 
            v_total_items,
            v_manufactured_items
        FROM mod_base.internal_sales_order_items
        WHERE sales_order_id = v_internal_sales_order_id;
        
        -- Check if all items are manufactured
        IF v_total_items > 0 AND v_manufactured_items = v_total_items THEN
            -- Update the internal sales order status to 'completed'
            UPDATE mod_base.internal_sales_orders
            SET status = 'completed',
                updated_at = NOW(),
                updated_by = NEW.updated_by
            WHERE id = v_internal_sales_order_id
              AND status IS DISTINCT FROM 'completed'; -- Only update if not already completed
            
            IF FOUND THEN
                RAISE NOTICE 'Successfully marked internal sales order % as completed (all % items are manufactured)', 
                             v_internal_sales_order_id, v_total_items;
            END IF;
        ELSE
            RAISE NOTICE 'Internal sales order % has % manufactured items out of % total items. Not marking as completed yet.', 
                         v_internal_sales_order_id, v_manufactured_items, v_total_items;
        END IF;
        
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."handle_internal_sales_order_completion_on_manufacturing"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_base"."handle_internal_sales_order_completion_on_manufacturing"() IS 'Trigger function that automatically marks an internal sales order as completed when all its items are manufactured (is_manufactured = TRUE)';



CREATE OR REPLACE FUNCTION "mod_base"."handle_new_employee"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  update mod_base.employees e
    set name = coalesce(up."firstName", 'Unknown'),
        last_name = coalesce(up."lastName", 'Unknown'),
        phone = coalesce(up.phone, 'N/A')
  from mod_admin.user_profiles up
  where up.id = new.id
    and e.id = new.id;

  return new;
end;
$$;


ALTER FUNCTION "mod_base"."handle_new_employee"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_profiles_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    user_id UUID := auth.uid();
    -- user_primary_domain_id UUID; -- REMOVED
BEGIN
    IF (TG_OP = 'INSERT') THEN
        NEW.created_by := user_id;
        NEW.updated_by := user_id; -- Set updated_by on insert as well
        NEW.updated_at := timezone('utc'::text, now()); -- Ensure updated_at is set on insert

        -- Attempt to set domain_id from user's primary domain if not provided -- REMOVED Logic
        --  IF NEW.domain_id IS NULL THEN
             -- Corrected assumption: Get domain_id from mod_base.domains based on a user's role or another relation if needed
             -- This example assumes a users_domains table exists linking users to their primary domain
             -- Adjust this logic based on your actual schema structure for determining a user's domain
             -- SELECT primary_domain_id INTO user_primary_domain_id FROM mod_base.users_domains WHERE mod_base.users_domains.user_id = user_id AND mod_base.users_domains.is_primary = TRUE LIMIT 1;

             -- IF user_primary_domain_id IS NULL THEN
             --    RAISE EXCEPTION 'User % does not have a primary domain set or mod_base.users_domains table/logic is incorrect. Cannot insert profile without domain_id.', user_id;
             -- ELSE
             --     NEW.domain_id := user_primary_domain_id;
             -- END IF;
        --  END IF;

         -- Ensure created_by is set if not already done by the caller (should reference auth.uid())
         IF NEW.created_by IS NULL THEN
            NEW.created_by := user_id;
         END IF;

    ELSIF (TG_OP = 'UPDATE') THEN
        -- Check if actual data changed, excluding audit fields that are handled by the trigger
        -- Compare relevant data fields, not the entire row if audit fields change predictably
        IF ROW(NEW.id, /* NEW.domain_id, */ NEW.fcm_token) IS DISTINCT FROM ROW(OLD.id, /* OLD.domain_id, */ OLD.fcm_token) THEN -- REMOVED domain_id from comparison
             NEW.updated_by := user_id;
             NEW.updated_at := timezone('utc'::text, now());
             -- Prevent changing the primary key
             IF OLD.id <> NEW.id THEN RAISE EXCEPTION 'Cannot change the user ID (id) of a profile.'; END IF;
             -- Decide if domain_id should be updatable -- REMOVED Check
             -- IF OLD.domain_id <> NEW.domain_id THEN RAISE EXCEPTION 'Changing the domain ID (domain_id) of a profile is not allowed.'; END IF;
         ELSE
             -- If no relevant data changed, keep old updated_at and updated_by to avoid unnecessary audit trail noise
             NEW.updated_at = OLD.updated_at;
             NEW.updated_by = OLD.updated_by;
        END IF;
        -- Ensure updated_by always reflects the current user making the change if there was a change
        IF ROW(NEW.id, /* NEW.domain_id, */ NEW.fcm_token) IS DISTINCT FROM ROW(OLD.id, /* OLD.domain_id, */ OLD.fcm_token) THEN -- REMOVED domain_id from comparison
            NEW.updated_by := user_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."handle_profiles_audit"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_base"."handle_profiles_audit"() IS 'Handles setting audit fields (created_by, updated_by, updated_at) for profiles.';



CREATE OR REPLACE FUNCTION "mod_base"."handle_purchase_order_items_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_base"."handle_purchase_order_items_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_purchase_orders_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_base"."handle_purchase_orders_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_quality_control_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "mod_base"."handle_quality_control_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_quality_control_types_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    NEW.created_by := COALESCE(NEW.created_by, auth.uid());
  ELSIF TG_OP = 'UPDATE' THEN
    NEW.updated_by := auth.uid();
    NEW.updated_at := now();
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."handle_quality_control_types_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_sales_order_completion_on_manufacturing"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_sales_order_id UUID;
    v_total_items INTEGER;
    v_manufactured_items INTEGER;
BEGIN
    -- Only process when is_manufactured changes to TRUE
    IF NEW.is_manufactured = TRUE AND (OLD.is_manufactured IS NULL OR OLD.is_manufactured = FALSE) THEN
        
        -- Get the sales_order_id from the updated item
        v_sales_order_id := NEW.sales_order_id;
        
        -- Skip if no sales_order_id
        IF v_sales_order_id IS NULL THEN
            RAISE NOTICE 'Sales order item % has no sales_order_id, skipping completion check', NEW.id;
            RETURN NEW;
        END IF;
        
        -- Count total items and manufactured items for this sales order
        -- Only count non-deleted items
        SELECT 
            COUNT(*) FILTER (WHERE is_deleted = false),
            COUNT(*) FILTER (WHERE is_deleted = false AND is_manufactured = true)
        INTO 
            v_total_items,
            v_manufactured_items
        FROM mod_base.sales_order_items
        WHERE sales_order_id = v_sales_order_id;
        
        -- Check if all items are manufactured
        IF v_total_items > 0 AND v_manufactured_items = v_total_items THEN
            -- Update the sales order status to 'completed'
            UPDATE mod_base.sales_orders
            SET status = 'completed',
                updated_at = NOW(),
                updated_by = NEW.updated_by
            WHERE id = v_sales_order_id
              AND status != 'completed'; -- Only update if not already completed
            
            IF FOUND THEN
                RAISE NOTICE 'Successfully marked sales order % as completed (all % items are manufactured)', 
                             v_sales_order_id, v_total_items;
            END IF;
        ELSE
            RAISE NOTICE 'Sales order % has % manufactured items out of % total items. Not marking as completed yet.', 
                         v_sales_order_id, v_manufactured_items, v_total_items;
        END IF;
        
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."handle_sales_order_completion_on_manufacturing"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_base"."handle_sales_order_completion_on_manufacturing"() IS 'Trigger function that automatically marks a sales order as completed when all its items are manufactured (is_manufactured = TRUE)';



CREATE OR REPLACE FUNCTION "mod_base"."handle_sales_order_items_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_base"."handle_sales_order_items_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_sales_orders_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_base"."handle_sales_orders_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_serial_number_counters_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
        NEW.updated_at := NOW();
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."handle_serial_number_counters_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_suppliers_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_base"."handle_suppliers_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_units_of_measure_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_base"."handle_units_of_measure_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."handle_update_sales_order_status_on_all_items_shipped"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_total_items INTEGER;
    v_shipped_items INTEGER;
    v_sales_order_id UUID;
BEGIN
    -- Safety guard: only process when is_shipped changes to TRUE
    IF NEW.is_shipped IS NOT TRUE OR (OLD.is_shipped IS NOT DISTINCT FROM TRUE) THEN
        RETURN NEW;
    END IF;

    -- Get the sales_order_id from the updated item
    v_sales_order_id := NEW.sales_order_id;
    
    -- Skip if no sales_order_id
    IF v_sales_order_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- Wrap the entire logic in error handling to prevent transaction rollback
    BEGIN
        -- Count total items for this sales order (excluding deleted items)
        SELECT COUNT(*)
        INTO v_total_items
        FROM mod_base.sales_order_items
        WHERE sales_order_id = v_sales_order_id
          AND is_deleted = FALSE;

        -- Count items that are shipped (is_shipped = TRUE)
        SELECT COUNT(*)
        INTO v_shipped_items
        FROM mod_base.sales_order_items
        WHERE sales_order_id = v_sales_order_id
          AND is_deleted = FALSE
          AND is_shipped = TRUE;

        -- If all items are shipped, update the sales order status to 'completed'
        IF v_total_items > 0 AND v_shipped_items = v_total_items THEN
            -- Update the sales order status to 'completed'
            UPDATE mod_base.sales_orders
            SET status = 'completed',
                updated_at = NOW(),
                updated_by = NEW.updated_by
            WHERE id = v_sales_order_id
              AND status IS DISTINCT FROM 'completed'; -- Only update if not already completed
            
            IF FOUND THEN
                RAISE NOTICE 'Successfully marked sales order % as completed (all % items are shipped)', 
                             v_sales_order_id, v_total_items;
            END IF;
        ELSE
            RAISE NOTICE 'Sales order % has % shipped items out of % total items. Not marking as completed yet.', 
                         v_sales_order_id, v_shipped_items, v_total_items;
        END IF;

    EXCEPTION WHEN OTHERS THEN
        -- Log the error but don't abort the transaction
        -- This allows the sales_order_item update to complete even if updating sales_order status fails
        RAISE WARNING 'Error in handle_update_sales_order_status_on_all_items_shipped for sales_order_item % (sales_order_id: %): %', 
            NEW.id, v_sales_order_id, SQLERRM;
        -- Return NEW to allow the sales_order_item update to succeed
    END;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."handle_update_sales_order_status_on_all_items_shipped"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_base"."handle_update_sales_order_status_on_all_items_shipped"() IS 'On update of sales_order_items is_shipped to TRUE, checks if all items for that sales_order_id are shipped. If so, updates the sales_order status to completed. Includes error handling to prevent transaction rollback.';



CREATE OR REPLACE FUNCTION "mod_base"."internal_sales_order_items_production_date_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  notification_name TEXT;
  notification_description TEXT;
  production_message TEXT;
  internal_sales_order_name TEXT;
BEGIN
  -- Only proceed if production_date actually changed
  IF OLD.production_date IS DISTINCT FROM NEW.production_date THEN
    -- Get the internal sales order name for context
    SELECT name INTO internal_sales_order_name 
    FROM mod_base.internal_sales_orders 
    WHERE id = NEW.sales_order_id;  -- sales_order_id in internal_sales_order_items references internal_sales_orders.id
    
    -- Determine the production message based on the new production_date
    IF NEW.production_date IS NULL THEN
      production_message := 'la data di produzione inizierà a [DA DEFINIRE]';
    ELSE
      production_message := 'la produzione è stata spostata al ' || NEW.production_date::text;
    END IF;
    
    -- Create notification name and description
    notification_name := 'Aggiornamento Produzione: ' || NEW.name;
    notification_description := 'L''ordine interno "' || COALESCE(internal_sales_order_name, 'Ordine Interno Sconosciuto') || '" - Articolo "' || NEW.name || '" ' || production_message;
    
    -- Only send notification if there's a created_by user
    IF NEW.created_by IS NOT NULL THEN
      -- Insert notification for the user who created the item
      INSERT INTO mod_pulse.notifications (
        name,
        description,
        type,
        user_id,
        created_by,
        domain_id,
        department_id
      ) VALUES (
        notification_name,
        notification_description,
        'update_pulse',
        NEW.created_by, -- Notify the user who created the item
        NEW.updated_by, -- The user who made the production date change
        NEW.domain_id,
        NULL -- department_id - can be set later if needed
      );
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."internal_sales_order_items_production_date_notification"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_base"."internal_sales_order_items_production_date_notification"() IS 'Creates notifications when production_date changes on internal_sales_order_items. Queries internal_sales_orders table for order context.';



CREATE OR REPLACE FUNCTION "mod_base"."internal_sales_order_items_scheduling_notification_for_fabrizio"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  notification_name TEXT;
  notification_description TEXT;
  internal_sales_order_name TEXT;
  internal_sales_order_number TEXT;
BEGIN
  -- Only proceed if production_date was set (changed from NULL to a date)
  -- This means the order was scheduled
  IF OLD.production_date IS NULL AND NEW.production_date IS NOT NULL THEN
    -- Get the internal sales order name and number for context
    -- Use table alias to avoid ambiguity with variable names
    SELECT iso.name, iso.sales_order_number INTO internal_sales_order_name, internal_sales_order_number
    FROM mod_base.internal_sales_orders iso
    WHERE iso.id = NEW.sales_order_id;
    
    -- Create notification name and description
    notification_name := 'Ordine Interno Programmato: ' || COALESCE(internal_sales_order_number, internal_sales_order_name, 'Ordine Interno Sconosciuto');
    notification_description := 'L''ordine interno "' || COALESCE(internal_sales_order_name, 'Ordine Interno Sconosciuto') || 
                              '" (Numero: ' || COALESCE(internal_sales_order_number, 'Non disponibile') || 
                              ') - Articolo "' || NEW.name || 
                              '" è stato programmato per la produzione il ' || TO_CHAR(NEW.production_date, 'DD/MM/YYYY');
    
    -- Insert notification for Fabrizio
    INSERT INTO mod_pulse.notifications (
      name,
      description,
      type,
      user_id,
      created_by,
      domain_id,
      department_id
    ) VALUES (
      notification_name,
      notification_description,
      'new_pulse',
      '0d26df09-2cf1-4b69-89ca-668db5201153'::uuid, -- FABRIZIO's UUID
      NEW.updated_by, -- The user who scheduled the order
      NEW.domain_id,
      NULL -- department_id - can be set later if needed
    );
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."internal_sales_order_items_scheduling_notification_for_fabrizio"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_base"."internal_sales_order_items_scheduling_notification_for_fabrizio"() IS 'Creates notifications for Fabrizio (UUID: 0d26df09-2cf1-4b69-89ca-668db5201153) when internal sales order items are scheduled (production_date changes from NULL to a date). Queries internal_sales_orders table for order context.';



CREATE OR REPLACE FUNCTION "mod_base"."process_heat_exchanger_boms"("bom_data_array" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  parent_item jsonb;
  component_item jsonb;
  v_parent_article_id text;  -- Use 'v_' prefix to distinguish from column names
  v_component_article_id text;  -- Use 'v_' prefix to distinguish from column names
  quantity_val numeric;
  position_val integer;
  note_val text;
  inserted_count integer := 0;
  error_count integer := 0;
  errors jsonb := '[]'::jsonb;
  bom_data jsonb;
  processed_parents text[] := '{}';  -- Track which parent articles we've already processed
BEGIN
  -- Loop through each parent article's BOM data
  FOR parent_item IN SELECT * FROM jsonb_array_elements(bom_data_array)
  LOOP
    v_parent_article_id := parent_item->>'parent_article_id';
    
    -- Skip if we've already processed this parent article (handles duplicates in array)
    IF v_parent_article_id = ANY(processed_parents) THEN
      CONTINUE;
    END IF;
    
    -- Mark this parent as processed
    processed_parents := array_append(processed_parents, v_parent_article_id);
    
    bom_data := parent_item->'bom_data';
    
    -- Delete any existing BOM relationships for this parent article first
    -- This handles duplicates the same way as the old process: delete all, then insert new
    DELETE FROM mod_base.bom_articles
    WHERE parent_article_id = v_parent_article_id::uuid;
    
    -- Loop through each component in the BOM
    FOR component_item IN SELECT * FROM jsonb_array_elements(bom_data)
    LOOP
      BEGIN
        v_component_article_id := component_item->>'component_article_id';
        quantity_val := (component_item->>'quantity')::numeric;
        position_val := (component_item->>'position')::integer;
        note_val := component_item->>'note';
        
        -- Insert new BOM relationship
        INSERT INTO mod_base.bom_articles (
          parent_article_id,
          component_article_id,
          quantity,
          position,
          note
        ) VALUES (
          v_parent_article_id::uuid,
          v_component_article_id::uuid,
          quantity_val,
          position_val,
          COALESCE(note_val, '')
        );
        
        inserted_count := inserted_count + 1;
        
      EXCEPTION WHEN OTHERS THEN
        error_count := error_count + 1;
        errors := errors || jsonb_build_object(
          'parent_article_id', v_parent_article_id,
          'component_article_id', v_component_article_id,
          'error', SQLERRM
        );
      END;
    END LOOP;
  END LOOP;
  
  -- Return result
  RETURN jsonb_build_object(
    'success', error_count = 0,
    'inserted_count', inserted_count,
    'error_count', error_count,
    'errors', errors
  );
END;
$$;


ALTER FUNCTION "mod_base"."process_heat_exchanger_boms"("bom_data_array" "jsonb") OWNER TO "postgres";


COMMENT ON FUNCTION "mod_base"."process_heat_exchanger_boms"("bom_data_array" "jsonb") IS 'Processes heat exchanger BOM data from frontend array and creates bom_articles records. Called after sales order creation.';



CREATE OR REPLACE FUNCTION "mod_base"."sales_order_items_production_date_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  notification_name TEXT;
  notification_description TEXT;
  production_message TEXT;
  sales_order_name TEXT;
BEGIN
  -- Only proceed if production_date actually changed
  IF OLD.production_date IS DISTINCT FROM NEW.production_date THEN
    -- Get the sales order name for context
    SELECT name INTO sales_order_name 
    FROM mod_base.sales_orders 
    WHERE id = NEW.sales_order_id;
    
    -- Determine the production message based on the new production_date
    IF NEW.production_date IS NULL THEN
      production_message := 'la data di produzione inizierà a [DA DEFINIRE]';
    ELSE
      production_message := 'la produzione è stata spostata al ' || NEW.production_date::text;
    END IF;
    
    -- Create notification name and description
    notification_name := 'Aggiornamento Produzione: ' || NEW.name;
    notification_description := 'L''ordine "' || COALESCE(sales_order_name, 'Ordine Sconosciuto') || '" - Articolo "' || NEW.name || '" ' || production_message;
    
    -- Only send notification if there's a created_by user
    IF NEW.created_by IS NOT NULL THEN
      -- Insert notification for the user who created the item
      INSERT INTO mod_pulse.notifications (
        name,
        description,
        type,
        user_id,
        created_by,
        domain_id,
        department_id
      ) VALUES (
        notification_name,
        notification_description,
        'update_pulse',
        NEW.created_by, -- Notify the user who created the item
        NEW.updated_by, -- The user who made the production date change
        NEW.domain_id,
        NULL -- department_id - can be set later if needed
      );
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."sales_order_items_production_date_notification"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."sales_order_items_scheduling_notification_for_fabrizio"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  notification_name TEXT;
  notification_description TEXT;
  sales_order_name TEXT;
  sales_order_number TEXT;
BEGIN
  -- Only proceed if production_date was set (changed from NULL to a date)
  -- This means the order was scheduled
  IF OLD.production_date IS NULL AND NEW.production_date IS NOT NULL THEN
    -- Get the sales order name and number for context
    -- Use table alias to avoid ambiguity with variable names
    SELECT so.name, so.sales_order_number INTO sales_order_name, sales_order_number
    FROM mod_base.sales_orders so
    WHERE so.id = NEW.sales_order_id;
    
    -- Create notification name and description
    notification_name := 'Ordine Programmato: ' || COALESCE(sales_order_number, sales_order_name, 'Ordine Sconosciuto');
    notification_description := 'L''ordine "' || COALESCE(sales_order_name, 'Ordine Sconosciuto') || 
                              '" (Numero: ' || COALESCE(sales_order_number, 'Non disponibile') || 
                              ') - Articolo "' || NEW.name || 
                              '" è stato programmato per la produzione il ' || TO_CHAR(NEW.production_date, 'DD/MM/YYYY');
    
    -- Insert notification for Fabrizio
    INSERT INTO mod_pulse.notifications (
      name,
      description,
      type,
      user_id,
      created_by,
      domain_id,
      department_id
    ) VALUES (
      notification_name,
      notification_description,
      'new_pulse',
      '0d26df09-2cf1-4b69-89ca-668db5201153'::uuid, -- FABRIZIO's UUID
      NEW.updated_by, -- The user who scheduled the order
      NEW.domain_id,
      NULL -- department_id - can be set later if needed
    );
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."sales_order_items_scheduling_notification_for_fabrizio"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_base"."sales_order_items_scheduling_notification_for_fabrizio"() IS 'Creates notifications for Fabrizio (UUID: 0d26df09-2cf1-4b69-89ca-668db5201153) when sales order items are scheduled (production_date changes from NULL to a date). Queries sales_orders table for order context.';



CREATE OR REPLACE FUNCTION "mod_base"."sales_order_status_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  notification_name TEXT;
  notification_description TEXT;
  status_message TEXT;
BEGIN
  -- Only proceed if status actually changed
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    -- Determine the status message based on the new status
    CASE NEW.status
      WHEN 'active' THEN
        status_message := 'è ora "Attivo" in produzione';
      WHEN 'completed' THEN
        status_message := 'è ora "Completato"';
      WHEN 'canceled' THEN
        status_message := 'è stato cancellato';
      WHEN 'pending' THEN
        status_message := 'è ora "In Attesa"';
      WHEN 'processing' THEN
        status_message := 'è ora "In Elaborazione"';
      WHEN 'ready_for_packing' THEN
        status_message := 'è ora "Pronto per l''Imballaggio"';
      WHEN 'ready_for_delivery' THEN
        status_message := 'è ora "Pronto per la Consegna"';
      WHEN 'paused' THEN
        status_message := 'è stato "Messo in Pausa"';
      ELSE
        status_message := 'lo stato è stato aggiornato a "' || COALESCE(NEW.status, 'Sconosciuto') || '"';
    END CASE;
    
    -- Create notification name and description
    notification_name := 'Aggiornamento Stato Ordine: ' || NEW.name;
    notification_description := 'L''ordine "' || NEW.name || '" che hai aggiunto ' || status_message;
    
    -- Only send notification if there's a created_by user
    IF NEW.created_by IS NOT NULL THEN
      -- Insert notification for the user who created the order
      INSERT INTO mod_pulse.notifications (
        name,
        description,
        type,
        user_id,
        created_by,
        domain_id,
        department_id
      ) VALUES (
        notification_name,
        notification_description,
        'update_pulse',
        NEW.created_by, -- Notify the user who created the order
        NEW.updated_by, -- The user who made the status change
        NEW.domain_id,
        NULL -- department_id - can be set later if needed
      );
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."sales_order_status_notification"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."send_notification_to_department_members"("p_title" "text", "p_text" "text", "p_department_id" "uuid", "p_created_by" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    employee_record RECORD;
BEGIN
    FOR employee_record IN
        SELECT e.id
        FROM mod_base.employees e
        JOIN mod_base.employees_departments ed ON e.id = ed.employee_id
        WHERE ed.department_id = p_department_id
        AND e.id <> p_created_by  -- Exclude the sender
    LOOP
        INSERT INTO mod_pulse.notifications (name, description, user_id, created_at, created_by)
        VALUES (p_title, p_text, employee_record.id, now(), p_created_by);
    END LOOP;
END;
$$;


ALTER FUNCTION "mod_base"."send_notification_to_department_members"("p_title" "text", "p_text" "text", "p_department_id" "uuid", "p_created_by" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."send_notification_to_user"("p_title" "text", "p_text" "text", "p_user_id" "uuid", "p_created_by" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    INSERT INTO mod_pulse.notifications (name, description, user_id, created_at, created_by)
    VALUES (p_title, p_text, p_user_id, now(), p_created_by);
END;
$$;


ALTER FUNCTION "mod_base"."send_notification_to_user"("p_title" "text", "p_text" "text", "p_user_id" "uuid", "p_created_by" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."update_bom_articles_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."update_bom_articles_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."update_purchase_order_item_completion"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Update is_completed based on received quantity
    NEW.is_completed := (NEW.quantity_received >= NEW.quantity_ordered);
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."update_purchase_order_item_completion"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."update_quality_control_checklist_results_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    NEW.updated_by = auth.uid();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."update_quality_control_checklist_results_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_base"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_base"."update_updated_at_column"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_datalayer"."generate_code_format"("table_name" "text", "table_prefix" "text") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    year_part text;
    sequence_name text;
    next_val int;
    result text;
BEGIN
    -- Get current year's last 2 digits
    year_part := to_char(CURRENT_DATE, 'YY');
    
    -- Create a sequence name specific to this table
    sequence_name := table_name || '_code_seq';
    
    -- Create sequence if it doesn't exist
    EXECUTE format('CREATE SEQUENCE IF NOT EXISTS %I START 1', sequence_name);
    
    -- Get next value from sequence
    EXECUTE format('SELECT nextval(%L)', sequence_name) INTO next_val;
    
    -- Format the result: PREFIX + YY + '-' + 6-digit number
    result := table_prefix || year_part || '-' || LPAD(next_val::text, 6, '0');
    
    RETURN result;
END;
$$;


ALTER FUNCTION "mod_datalayer"."generate_code_format"("table_name" "text", "table_prefix" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_datalayer"."generate_sales_order_code"() RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "mod_datalayer"."generate_sales_order_code"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_datalayer"."generate_sales_order_number"() RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "mod_datalayer"."generate_sales_order_number"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_datalayer"."generate_sales_order_number_trigger"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "mod_datalayer"."generate_sales_order_number_trigger"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_datalayer"."generate_table_code"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "mod_datalayer"."generate_table_code"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_datalayer"."handle_fields_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_datalayer"."handle_fields_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_datalayer"."handle_main_menu_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_datalayer"."handle_main_menu_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_datalayer"."handle_modules_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_datalayer"."handle_modules_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_datalayer"."handle_page_categories_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_datalayer"."handle_page_categories_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_datalayer"."handle_pages_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_datalayer"."handle_pages_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_datalayer"."handle_pages_departments_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by := COALESCE(NEW.created_by, auth.uid());
        NEW.created_at := COALESCE(NEW.created_at, now());
    ELSIF TG_OP = 'UPDATE' THEN
        NEW.updated_by := auth.uid();
        NEW.updated_at := now();
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_datalayer"."handle_pages_departments_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_datalayer"."handle_tables_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_datalayer"."handle_tables_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_datalayer"."populate_sort_orders"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    current_sort_order INTEGER := 2000;
BEGIN
    -- First, preserve fields with sort_order = 1
    -- (no update needed for these)

    -- Update standard fields with fixed sort_order values
    UPDATE mod_datalayer.fields
    SET sort_order = CASE field_name
        WHEN 'id' THEN 1000
        WHEN 'avatar_url' THEN 1010
        WHEN 'name' THEN 1020
        WHEN 'description' THEN 1030
        WHEN 'status' THEN 9000
        WHEN 'created_at' THEN 9010
        WHEN 'created_by' THEN 9020
        WHEN 'updated_at' THEN 9030
        WHEN 'updated_by' THEN 9040
        WHEN 'is_deleted' THEN 9090
        ELSE sort_order
    END
    WHERE field_name IN ('id', 'avatar_url', 'name', 'description', 
                        'status', 'created_at', 'created_by', 'updated_at', 
                        'updated_by', 'is_deleted');

    -- Update remaining fields with sequential sort_order values
    -- Only update fields that don't have sort_order = 1 and aren't standard fields
    WITH ordered_fields AS (
        SELECT id, field_name,
               ROW_NUMBER() OVER (ORDER BY field_name) as row_num
        FROM mod_datalayer.fields
        WHERE sort_order != 1
        AND field_name NOT IN ('id', 'avatar_url', 'name', 'description', 
                             'status', 'created_at', 'created_by', 'updated_at', 
                             'updated_by', 'is_deleted')
    )
    UPDATE mod_datalayer.fields f
    SET sort_order = 2000 + (of.row_num - 1) * 10
    FROM ordered_fields of
    WHERE f.id = of.id;
END;
$$;


ALTER FUNCTION "mod_datalayer"."populate_sort_orders"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_datalayer"."sync_fields"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Upsert fields (columns) for tables in modules (schemas) starting with mod_
    WITH constraints_info AS (
        SELECT 
            c.table_schema,
            c.table_name,
            c.column_name,
            c.data_type,
            c.is_nullable,
            COALESCE(bool_or(tc.constraint_type = 'PRIMARY KEY'), FALSE) as is_primary_key,
            COALESCE(bool_or(tc.constraint_type = 'FOREIGN KEY'), FALSE) as is_foreign_key,
            MAX(CASE WHEN tc.constraint_type = 'FOREIGN KEY' THEN ccu.table_schema END) as references_schema,
            MAX(CASE WHEN tc.constraint_type = 'FOREIGN KEY' THEN ccu.table_name END) as references_table,
            MAX(CASE WHEN tc.constraint_type = 'FOREIGN KEY' THEN ccu.column_name END) as references_field
        FROM information_schema.columns c
        -- Join with mod_datalayer.tables to ensure we only process registered tables
        INNER JOIN mod_datalayer.tables mt 
            ON c.table_schema = mt.schema_name 
            AND c.table_name = mt.table_name
        LEFT JOIN information_schema.key_column_usage kcu 
            ON c.table_schema = kcu.table_schema 
            AND c.table_name = kcu.table_name 
            AND c.column_name = kcu.column_name
        LEFT JOIN information_schema.table_constraints tc 
            ON kcu.constraint_name = tc.constraint_name 
            AND kcu.table_schema = tc.table_schema
        LEFT JOIN information_schema.constraint_column_usage ccu 
            ON tc.constraint_name = ccu.constraint_name 
            AND tc.table_schema = ccu.table_schema
        WHERE c.table_schema LIKE 'mod_%'
        GROUP BY c.table_schema, c.table_name, c.column_name, c.data_type, c.is_nullable
    )
    INSERT INTO mod_datalayer.fields (
        schema_name, 
        table_name, 
        field_name, 
        name, 
        data_type, 
        is_nullable,
        is_primary_key,
        is_foreign_key,
        references_schema,
        references_table,
        references_field,
        is_deleted, 
        created_at, 
        updated_at
    )
    SELECT 
        table_schema,
        table_name,
        column_name,
        column_name,
        data_type,
        is_nullable = 'YES',
        is_primary_key,
        is_foreign_key,
        references_schema,
        references_table,
        references_field,
        FALSE,
        NOW(),
        NOW()
    FROM constraints_info
    ON CONFLICT (schema_name, table_name, field_name) DO UPDATE
    SET data_type = EXCLUDED.data_type,
        is_nullable = EXCLUDED.is_nullable,
        is_primary_key = EXCLUDED.is_primary_key,
        is_foreign_key = EXCLUDED.is_foreign_key,
        references_schema = EXCLUDED.references_schema,
        references_table = EXCLUDED.references_table,
        references_field = EXCLUDED.references_field,
        is_deleted = FALSE,
        updated_at = EXCLUDED.updated_at;

    -- Mark fields that no longer exist as deleted
    UPDATE mod_datalayer.fields
    SET is_deleted = TRUE, updated_at = NOW()
    WHERE (schema_name, table_name, field_name) NOT IN (
        SELECT c.table_schema, c.table_name, c.column_name
        FROM information_schema.columns c
        INNER JOIN mod_datalayer.tables mt 
            ON c.table_schema = mt.schema_name 
            AND c.table_name = mt.table_name
        WHERE c.table_schema LIKE 'mod_%'
    )
    AND is_deleted = FALSE;
END;
$$;


ALTER FUNCTION "mod_datalayer"."sync_fields"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_datalayer"."sync_modules"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Upsert modules (schemas) that start with mod_
    INSERT INTO mod_datalayer.modules (schema_name, name, public_folder, code_folder, title, is_deleted, created_at, updated_at)
    SELECT 
        nspname, 
        substring(nspname FROM 5),  -- Remove 'mod_' prefix for name
        substring(nspname FROM 5),  -- Example for public_folder
        substring(nspname FROM 5),  -- Example for code_folder
        substring(nspname FROM 5),  -- Example for title
        FALSE, 
        NOW(), 
        NOW()
    FROM pg_namespace
    WHERE nspname LIKE 'mod_%'
    ON CONFLICT (schema_name) DO UPDATE
    SET 
        name = EXCLUDED.name,
        public_folder = EXCLUDED.public_folder,
        code_folder = EXCLUDED.code_folder,
        is_deleted = FALSE, 
        updated_at = EXCLUDED.updated_at;

    -- Mark modules (schemas) that no longer exist as deleted
    UPDATE mod_datalayer.modules
    SET is_deleted = TRUE, updated_at = NOW()
    WHERE schema_name NOT IN (
        SELECT nspname
        FROM pg_namespace
        WHERE nspname LIKE 'mod_%'
    )
    AND is_deleted = FALSE;
END;
$$;


ALTER FUNCTION "mod_datalayer"."sync_modules"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_datalayer"."sync_tables"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Upsert tables for modules (schemas) that start with mod_
    INSERT INTO mod_datalayer.tables (name, table_name, schema_name, is_deleted, created_at, updated_at)
    SELECT tablename, tablename, schemaname, FALSE, NOW(), NOW()
    FROM pg_tables
    WHERE schemaname LIKE 'mod_%'
    ON CONFLICT (schema_name, table_name) DO UPDATE
    SET is_deleted = FALSE, updated_at = EXCLUDED.updated_at;

    -- Mark tables that no longer exist as deleted
    UPDATE mod_datalayer.tables
    SET is_deleted = TRUE, updated_at = NOW()
    WHERE (schema_name, table_name) NOT IN (
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE schemaname LIKE 'mod_%'
    )
    AND is_deleted = FALSE;
END;
$$;


ALTER FUNCTION "mod_datalayer"."sync_tables"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_datalayer"."update_fields_input_options"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    current_schema_name text;
    current_table_name text;
    current_column_name text;
    check_clause text;
    options text[];
    option_json jsonb;
    insert_count integer;
    update_count integer;
BEGIN
    RAISE NOTICE 'Starting field options update...';

    FOR current_schema_name, current_table_name, current_column_name, check_clause IN 
        SELECT DISTINCT
            table_schema,
            table_name,
            column_name,
            cc.check_clause
        FROM information_schema.check_constraints cc
        JOIN information_schema.constraint_column_usage ccu 
            ON cc.constraint_name = ccu.constraint_name
            AND cc.constraint_schema = ccu.constraint_schema
        WHERE table_schema LIKE 'mod_%'
        AND cc.check_clause LIKE '%ANY (ARRAY[%'
    LOOP
        RAISE NOTICE 'Processing constraint - Schema: %, Table: %, Column: %, Check: %',
            current_schema_name, current_table_name, current_column_name, check_clause;

        -- Extract the values from the ARRAY[] clause
        options := (
            SELECT array_agg(trim(both '''' from option))
            FROM regexp_split_to_table(
                regexp_replace(
                    check_clause,
                    '.*ARRAY\[(.*?)\].*',
                    '\1'
                ),
                ','
            ) AS option
        );

        -- Clean up the options by removing the ::text parts
        options := (
            SELECT array_agg(regexp_replace(option, '::text', '', 'g'))
            FROM unnest(options) AS option
        );

        IF options IS NOT NULL THEN
            RAISE NOTICE 'Extracted options: %', options;

            -- Create JSON array of options
            option_json := (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'label', trim(both '''' from option),
                        'value', trim(both '''' from option),
                        'color', 'primary'
                    )
                )
                FROM unnest(options) AS option
            );

            RAISE NOTICE 'Created JSON: %', option_json;

            -- First, try to insert if record doesn't exist
            INSERT INTO mod_datalayer.fields 
                (schema_name, table_name, field_name, input_options)
            SELECT 
                current_schema_name,
                current_table_name,
                current_column_name,
                option_json
            WHERE NOT EXISTS (
                SELECT 1 
                FROM mod_datalayer.fields 
                WHERE schema_name = current_schema_name
                AND table_name = current_table_name
                AND field_name = current_column_name
            )
            RETURNING 1 INTO insert_count;

            IF insert_count > 0 THEN
                RAISE NOTICE 'Inserted new field record for %.%.%', 
                    current_schema_name, current_table_name, current_column_name;
            ELSE
                -- Update if input_options is null or empty array
                UPDATE mod_datalayer.fields
                SET input_options = option_json
                WHERE schema_name = current_schema_name
                AND table_name = current_table_name
                AND field_name = current_column_name
                AND (input_options IS NULL OR input_options::text = '[]')
                RETURNING 1 INTO update_count;

                IF update_count > 0 THEN
                    RAISE NOTICE 'Updated existing field record for %.%.%', 
                        current_schema_name, current_table_name, current_column_name;
                ELSE
                    RAISE NOTICE 'Record exists and has input_options set for %.%.%', 
                        current_schema_name, current_table_name, current_column_name;
                END IF;
            END IF;
        END IF;
    END LOOP;

    RAISE NOTICE 'Field options update completed.';
END;
$$;


ALTER FUNCTION "mod_datalayer"."update_fields_input_options"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."check_coil_weight_warning"("coil_weight" numeric) RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  RETURN coil_weight < 50;
END;
$$;


ALTER FUNCTION "mod_manufacturing"."check_coil_weight_warning"("coil_weight" numeric) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."create_work_order_quality_summary"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Insert a new quality summary record for the work order
    INSERT INTO mod_manufacturing.work_order_quality_summary (
        work_order_id,
        passed_count,
        failed_count,
        total_count,
        overall_status,
        inspector_notes,
        domain_id,
        shared_with,
        created_by,
        updated_by
    ) VALUES (
        NEW.id,
        0,
        0,
        0,
        'PENDING',
        '',
        NEW.domain_id,
        NEW.shared_with,
        NEW.created_by,
        NEW.created_by
    );
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_manufacturing"."create_work_order_quality_summary"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."create_work_orders_for_scheduling"("p_order_item_id" "uuid", "p_scheduled_date" timestamp without time zone, "p_order_type" "text", "p_article_product_type" "text", "p_user_id" "uuid", "p_domain_id" "uuid", "p_article_id" "uuid", "p_article_name" "text", "p_quantity_ordered" integer, "p_assigned_to" "uuid" DEFAULT NULL::"uuid", "p_assigned_department_id" "uuid" DEFAULT NULL::"uuid", "p_priority" integer DEFAULT 2, "p_expected_end_date" timestamp without time zone DEFAULT NULL::timestamp without time zone) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_workflow_id uuid;
  v_work_cycle_ids uuid[];
  v_work_cycles record;
  v_work_steps record;
  v_work_order_id uuid;
  v_task_id uuid;
  v_work_order_code text;
  v_work_order_name text;
  v_work_order_description text;
  v_step_index integer := 0;
  v_work_step_index integer := 0;
  v_created_work_steps_count integer := 0;
  v_failed_work_steps_count integer := 0;
  v_assigned_department_id uuid;
  v_fallback_department_id uuid;
  v_sales_order_id uuid;
  v_internal_sales_order_id uuid;
  v_order_id uuid;
  v_items_table_name text;
  v_errors jsonb := '[]'::jsonb;
  v_result jsonb;
  v_barcode text;
  v_task_status text;
  v_task_priority text;
  v_work_step_barcode text;
  v_template_workstation_id uuid;
  v_template_work_step_type text;
  v_template_estimated_time interval;
  v_workstation_id uuid;
  v_article_category_id uuid;
  v_article_type text;
  v_is_dirt_separator_workflow boolean := false;
  v_need_unload boolean := true;
  v_rows_updated integer;
  v_production_date date;
BEGIN
  -- Determine which table to use and get order ID
  IF p_order_type = 'internal' THEN
    v_items_table_name := 'internal_sales_order_items';
    SELECT sales_order_id INTO v_order_id
    FROM mod_base.internal_sales_order_items
    WHERE id = p_order_item_id;
    v_internal_sales_order_id := v_order_id;
    v_sales_order_id := NULL;
  ELSE
    v_items_table_name := 'sales_order_items';
    SELECT sales_order_id INTO v_order_id
    FROM mod_base.sales_order_items
    WHERE id = p_order_item_id;
    v_sales_order_id := v_order_id;
    v_internal_sales_order_id := NULL;
  END IF;

  -- Get fallback department if no department provided
  v_assigned_department_id := p_assigned_department_id;

  IF v_assigned_department_id IS NULL THEN
    -- Try to get department from work cycle first (will be done per cycle)
    -- Otherwise get any department as fallback
    SELECT id INTO v_fallback_department_id
    FROM mod_base.departments
    WHERE is_deleted = false
      AND domain_id = p_domain_id
    LIMIT 1;

    v_assigned_department_id := v_fallback_department_id;
  END IF;

  -- Get article's category_id and type to check workflow requirements
  SELECT category_id, type INTO v_article_category_id, v_article_type
  FROM mod_base.articles
  WHERE id = p_article_id;

  -- Determine if this article should use dirt separator workflow
  -- Either type = 'dirt_separator' OR category_id matches one of the following:
  -- Coibentazioni, Bollittori, Defangatori, Serbatoi, Preparatori, Scambiatori di calore a piastre SP
  v_is_dirt_separator_workflow := (
    p_article_product_type = 'dirt_separator'
    OR v_article_category_id = ANY(ARRAY[
      '0e5c0b11-e04f-471a-a7d8-7a522356eb81'::uuid, -- Coibentazioni
      '1f7d33e4-b80b-40da-922f-a69863c76f75'::uuid, -- Bollittori
      '812aac37-04e7-4c8a-870e-8a7bd58f0c92'::uuid, -- Defangatori
      'ccbfd8c9-dc44-450c-a9ac-349e6b6350e0'::uuid, -- Serbatoi
      'd932470c-2c0b-4f5e-81be-509dbf71709c'::uuid, -- Preparatori
      '47e1315c-a8d8-4776-b4ff-8652856f877d'::uuid  -- Scambiatori di calore a piastre SP
    ])
  );

  -- Determine workflow ID based on article product type and category
  IF v_article_type = 'custom' THEN
    -- Custom articles use Lavorazione speciale workflow
    v_workflow_id := '0543bd40-6303-498b-b25a-655e76ce464e'::uuid; -- Lavorazione speciale
    v_need_unload := false; -- Custom workflow does not need unload
  ELSIF p_article_product_type = 'heat_exchanger' THEN
    v_workflow_id := 'c56a6f0c-55d6-4f36-b0fd-1c4754e65bc8'::uuid; -- Produzione scambiatore
  ELSIF v_is_dirt_separator_workflow THEN
    v_workflow_id := '8ae390f7-47c5-417d-9dd9-fffe72639b8a'::uuid; -- Produzione defangatore
    v_need_unload := false; -- Dirt separator workflow does not need unload
  ELSIF p_order_type = 'internal' AND (
        p_article_product_type = 'plate_material'
        OR (v_article_category_id IS NOT NULL AND v_article_category_id = '5df48973-1785-48b9-9892-9e3902dc1223'::uuid)
      ) THEN
    v_workflow_id := 'adf7f990-ed1b-4030-ab1d-956fef1ff191'::uuid; -- Produzione piastre
    v_need_unload := false; -- Piastre workflow does not need unload
  ELSIF p_order_type = 'internal' AND (
        v_article_category_id IS NOT NULL AND v_article_category_id = '94bfac1b-f87b-452f-8661-2b6c45ebe6ff'::uuid
      ) THEN
    v_workflow_id := '01016d46-4ba1-4bc7-b140-260121b31742'::uuid; -- Sagome (Shapes)
    v_need_unload := true; -- Sagome workflow needs unload
  ELSE
    v_workflow_id := '3042a080-3ee6-434f-b646-bda5fdd7bb02'::uuid;
  END IF;

  -- Get work cycles based on type
  IF v_article_type = 'custom' THEN
    -- For custom articles: get work cycles from Lavorazione speciale workflow via junction table
    SELECT ARRAY_AGG(work_cycle_id) INTO v_work_cycle_ids
    FROM mod_manufacturing.work_flows_work_cycles
    WHERE work_flow_id = v_workflow_id;
  ELSIF p_article_product_type = 'heat_exchanger' THEN
    -- For heat exchangers: get work cycles from workflow via junction table
    SELECT ARRAY_AGG(work_cycle_id) INTO v_work_cycle_ids
    FROM mod_manufacturing.work_flows_work_cycles
    WHERE work_flow_id = v_workflow_id;
  ELSIF v_is_dirt_separator_workflow THEN
    -- For dirt separators and articles with categories: Coibentazioni, Bollittori, Defangatori,
    -- Serbatoi, Preparatori, Scambiatori di calore a piastre SP: get work cycles from workflow via junction table
    SELECT ARRAY_AGG(work_cycle_id) INTO v_work_cycle_ids
    FROM mod_manufacturing.work_flows_work_cycles
    WHERE work_flow_id = v_workflow_id;
  ELSIF p_order_type = 'internal' AND (
        p_article_product_type = 'plate_material'
        OR (v_article_category_id IS NOT NULL AND v_article_category_id = '5df48973-1785-48b9-9892-9e3902dc1223'::uuid)
      ) THEN
    -- For internal orders with plate_material or articles with Piastre category: get work cycles from Produzione piastre workflow
    SELECT ARRAY_AGG(work_cycle_id) INTO v_work_cycle_ids
    FROM mod_manufacturing.work_flows_work_cycles
    WHERE work_flow_id = v_workflow_id;
  ELSIF p_order_type = 'internal' AND (
        v_article_category_id IS NOT NULL AND v_article_category_id = '94bfac1b-f87b-452f-8661-2b6c45ebe6ff'::uuid
      ) THEN
    -- For internal orders with Sagome (Shapes) category: get work cycles from Sagome workflow
    SELECT ARRAY_AGG(work_cycle_id) INTO v_work_cycle_ids
    FROM mod_manufacturing.work_flows_work_cycles
    WHERE work_flow_id = v_workflow_id;
  ELSE
    -- For other articles: get work cycles where required_for_all = true
    SELECT ARRAY_AGG(id) INTO v_work_cycle_ids
    FROM mod_manufacturing.work_cycles
    WHERE required_for_all = true
      AND is_deleted = false;
  END IF;

  -- Create ONE work order (regardless of number of work cycles)
  BEGIN
    v_work_order_code := 'WO-' || EXTRACT(EPOCH FROM NOW())::bigint::text;
    v_barcode := 'WO-' || EXTRACT(EPOCH FROM NOW())::bigint::text || '-' ||
                 LPAD(FLOOR(RANDOM() * 1000000)::text, 6, '0');
    v_work_order_name := p_article_name;
    v_work_order_description := COALESCE(p_article_name, 'Work order for ' || p_article_name);

    -- Determine department for work order
    v_assigned_department_id := COALESCE(
      p_assigned_department_id,
      v_fallback_department_id
    );

    -- Create task first (work orders are linked to tasks)
    v_task_status := 'pending';
    v_task_priority := CASE
      WHEN p_priority = 1 THEN 'high'
      WHEN p_priority = 2 THEN 'medium'
      ELSE 'low'
    END;

    INSERT INTO mod_pulse.tasks (
      name,
      description,
      code,
      pulse_id,
      status,
      priority,
      domain_id,
      created_by,
      updated_by,
      assigned_id,
      assigned_department_id,
      avatar_url,
      barcode,
      is_deleted,
      shared_with
    ) VALUES (
      v_work_order_name,
      v_work_order_description,
      v_work_order_code,
      v_sales_order_id,
      v_task_status,
      v_task_priority,
      p_domain_id,
      p_user_id,
      p_user_id,
      p_assigned_to,
      v_assigned_department_id,
      '',
      'TASK-' || EXTRACT(EPOCH FROM NOW())::bigint::text || '-' ||
      SUBSTRING(MD5(RANDOM()::text) FROM 1 FOR 13),
      false,
      ARRAY[]::text[]
    )
    RETURNING id INTO v_task_id;

    -- Create single work order (no work_cycle_id since we'll have multiple work steps)
    INSERT INTO mod_manufacturing.work_orders (
      name,
      code,
      description,
      notes,
      article_id,
      sales_order_id,
      internal_sales_order_id,
      quantity,
      scheduled_start,
      scheduled_end,
      priority,
      status,
      domain_id,
      created_by,
      updated_by,
      avatar_url,
      barcode,
      is_deleted,
      shared_with,
      work_cycle_id,
      task_id,
      need_unload
    ) VALUES (
      v_work_order_name,
      v_work_order_code,
      v_work_order_description,
      '',
      p_article_id,
      v_sales_order_id,
      v_internal_sales_order_id,
      p_quantity_ordered,
      p_scheduled_date,
      p_expected_end_date,
      p_priority,
      'pending',
      p_domain_id,
      p_user_id,
      p_user_id,
      '',
      v_barcode,
      false,
      ARRAY[]::text[],
      NULL, -- No work_cycle_id since we have multiple work steps
      v_task_id,
      v_need_unload
    )
    RETURNING id INTO v_work_order_id;

  EXCEPTION WHEN OTHERS THEN
    IF v_task_id IS NOT NULL THEN
      DELETE FROM mod_pulse.tasks WHERE id = v_task_id;
    END IF;
    RETURN jsonb_build_object(
      'success', false,
      'created_count', 0,
      'failed_count', 1,
      'message', 'Failed to create work order',
      'errors', jsonb_build_array(jsonb_build_object('error', SQLERRM))
    );
  END;

  -- If work cycles found, create one work step per work cycle
  IF v_work_cycle_ids IS NOT NULL AND array_length(v_work_cycle_ids, 1) > 0 THEN
    -- Loop through work cycles and create one work step per cycle
    FOR v_work_cycles IN
      SELECT wc.*
      FROM mod_manufacturing.work_cycles wc
      WHERE wc.id = ANY(v_work_cycle_ids)
        AND wc.is_deleted = false
      ORDER BY wc.sort_order
    LOOP
      BEGIN
        v_work_step_index := v_work_step_index + 1;

        -- Initialize template variables
        v_template_workstation_id := NULL;
        v_template_work_step_type := 'processing';
        v_template_estimated_time := NULL;

        -- Get first work step template from this cycle to get workstation and other details
        SELECT ws.workstation_id, ws.type, ws.estimated_time
        INTO v_template_workstation_id, v_template_work_step_type, v_template_estimated_time
        FROM mod_manufacturing.work_steps ws
        WHERE ws.work_cycle_id = v_work_cycles.id
          AND ws.is_deleted = false
          AND ws.work_order_id IS NULL -- Template steps don't have work_order_id
        ORDER BY ws.sort_order
        LIMIT 1;

        -- Use template values if available, otherwise use defaults
        v_workstation_id := v_template_workstation_id;

        -- If no workstation found, we need to get a default one
        IF v_workstation_id IS NULL THEN
          SELECT id INTO v_workstation_id
          FROM mod_manufacturing.workstations
          WHERE is_deleted = false
            AND domain_id = p_domain_id
          LIMIT 1;
        END IF;

        -- Generate barcode for work step
        v_work_step_barcode := 'WS-' || EXTRACT(EPOCH FROM NOW())::bigint::text || '-' ||
                               LPAD(FLOOR(RANDOM() * 1000000)::text, 6, '0') || '-' ||
                               SUBSTRING(MD5(RANDOM()::text) FROM 1 FOR 6);

        -- Create work step for this work cycle, linked to work order
        -- workstation_id can be NULL if no workstation is found
        INSERT INTO mod_manufacturing.work_steps (
          name,
          description,
          code,
          type,
          sort_order,
          estimated_time,
          workstation_id,
          work_cycle_id,
          work_order_id, -- Link to the work order
          avatar_url,
          barcode,
          domain_id,
          created_by,
          updated_by,
          is_deleted,
          shared_with
        ) VALUES (
          v_work_cycles.name, -- Use work cycle name as work step name
          COALESCE(v_work_cycles.description, v_work_cycles.name),
          COALESCE(v_work_cycles.code, 'WC') || '-' || v_work_step_index::text,
          COALESCE(v_template_work_step_type, 'processing'),
          v_work_step_index, -- Global sort order across all work steps
          COALESCE(v_template_estimated_time, v_work_cycles.estimated_time),
          v_workstation_id, -- Can be NULL if no workstation found
          v_work_cycles.id,
          v_work_order_id, -- Link to work order
          '',
          v_work_step_barcode,
          p_domain_id,
          p_user_id,
          p_user_id,
          false,
          ARRAY[]::text[]
        );

        v_created_work_steps_count := v_created_work_steps_count + 1;

      EXCEPTION WHEN OTHERS THEN
        v_failed_work_steps_count := v_failed_work_steps_count + 1;
        v_errors := v_errors || jsonb_build_object(
          'work_cycle', v_work_cycles.name,
          'error', SQLERRM
        );
      END;
    END LOOP;
  END IF;

  -- Update production_date in order items table
  BEGIN
    -- Convert timestamp to date (production_date is a DATE field, not timestamp)
    v_production_date := p_scheduled_date::date;

    -- Reset row count
    v_rows_updated := 0;

    IF v_items_table_name = 'internal_sales_order_items' THEN
      UPDATE mod_base.internal_sales_order_items
      SET production_date = v_production_date,
          updated_at = NOW(),
          updated_by = p_user_id
      WHERE id = p_order_item_id
        AND is_deleted = false;
      GET DIAGNOSTICS v_rows_updated = ROW_COUNT;
    ELSE
      UPDATE mod_base.sales_order_items
      SET production_date = v_production_date,
          updated_at = NOW(),
          updated_by = p_user_id
      WHERE id = p_order_item_id
        AND is_deleted = false;
      GET DIAGNOSTICS v_rows_updated = ROW_COUNT;
    END IF;

    -- Check if any rows were actually updated
    IF v_rows_updated = 0 THEN
      RAISE WARNING 'No rows updated for production_date. Order item ID: %, Table: %, Scheduled date: %',
                   p_order_item_id, v_items_table_name, v_production_date;
      v_errors := v_errors || jsonb_build_object(
        'operation', 'update_production_date',
        'error', 'No rows were updated. Order item may not exist, be deleted, or ID mismatch.',
        'order_item_id', p_order_item_id,
        'table', v_items_table_name,
        'scheduled_date', v_production_date
      );
    ELSE
      RAISE NOTICE 'Successfully updated production_date for order item ID: %, Table: %, Date: %',
                   p_order_item_id, v_items_table_name, v_production_date;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    -- Log error but don't fail the whole operation
    RAISE WARNING 'Error updating production_date: % (Order item ID: %, Table: %)',
                 SQLERRM, p_order_item_id, v_items_table_name;
    v_errors := v_errors || jsonb_build_object(
      'operation', 'update_production_date',
      'error', SQLERRM,
      'order_item_id', p_order_item_id,
      'table', v_items_table_name,
      'sqlstate', SQLSTATE
    );
  END;

  -- Update sales order production_start_date and status
  BEGIN
    IF p_order_type = 'internal' THEN
      UPDATE mod_base.internal_sales_orders
      SET production_start_date = p_scheduled_date,
          status = 'active',
          updated_at = NOW(),
          updated_by = p_user_id
      WHERE id = v_order_id;
    ELSE
      UPDATE mod_base.sales_orders
      SET production_start_date = p_scheduled_date,
          status = 'active',
          updated_at = NOW(),
          updated_by = p_user_id
      WHERE id = v_order_id;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    -- Log error but don't fail the whole operation
    v_errors := v_errors || jsonb_build_object(
      'operation', 'update_sales_order',
      'error', SQLERRM
    );
  END;

  -- Return result
  -- Note: 'created_count' is used by frontend to check if work orders were created
  -- Since we create 1 work order + multiple work steps, we return 1 if work order was created
  RETURN jsonb_build_object(
    'success', v_failed_work_steps_count = 0 AND v_work_order_id IS NOT NULL,
    'work_order_id', v_work_order_id,
    'work_order_created', v_work_order_id IS NOT NULL,
    'created_count', CASE WHEN v_work_order_id IS NOT NULL THEN 1 ELSE 0 END, -- Frontend expects this
    'work_steps_created_count', v_created_work_steps_count,
    'work_steps_failed_count', v_failed_work_steps_count,
    'errors', v_errors,
    'order_item_id', p_order_item_id,
    'scheduled_date', p_scheduled_date
  );
END;
$$;


ALTER FUNCTION "mod_manufacturing"."create_work_orders_for_scheduling"("p_order_item_id" "uuid", "p_scheduled_date" timestamp without time zone, "p_order_type" "text", "p_article_product_type" "text", "p_user_id" "uuid", "p_domain_id" "uuid", "p_article_id" "uuid", "p_article_name" "text", "p_quantity_ordered" integer, "p_assigned_to" "uuid", "p_assigned_department_id" "uuid", "p_priority" integer, "p_expected_end_date" timestamp without time zone) OWNER TO "postgres";


COMMENT ON FUNCTION "mod_manufacturing"."create_work_orders_for_scheduling"("p_order_item_id" "uuid", "p_scheduled_date" timestamp without time zone, "p_order_type" "text", "p_article_product_type" "text", "p_user_id" "uuid", "p_domain_id" "uuid", "p_article_id" "uuid", "p_article_name" "text", "p_quantity_ordered" integer, "p_assigned_to" "uuid", "p_assigned_department_id" "uuid", "p_priority" integer, "p_expected_end_date" timestamp without time zone) IS 'Creates ONE work order and multiple work steps (one per work cycle) for scheduling items. Handles heat exchangers (via Produzione scambiatore workflow), dirt separators and articles with categories: Coibentazioni, Bollittori, Defangatori, Serbatoi, Preparatori, Scambiatori di calore a piastre SP (via Produzione defangatore workflow), internal orders with plate_material (via Produzione piastre workflow), and other articles (via required_for_all cycles). Also creates associated tasks and updates production_date.';



CREATE OR REPLACE FUNCTION "mod_manufacturing"."generate_batch_code"() RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "mod_manufacturing"."generate_batch_code"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."handle_departments_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_manufacturing"."handle_departments_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."handle_internal_work_order_manufacturing_status"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_internal_sales_order_id UUID;
    v_article_id UUID;
BEGIN
    -- Only process when status changes to 'completed'
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
        
        -- Get the internal_sales_order_id and article_id from the completed work order
        v_internal_sales_order_id := NEW.internal_sales_order_id;
        v_article_id := NEW.article_id;
        
        -- Skip if no internal_sales_order_id or article_id
        IF v_internal_sales_order_id IS NULL OR v_article_id IS NULL THEN
            RAISE NOTICE 'Work order % has no internal_sales_order_id or article_id, skipping internal manufacturing check', NEW.id;
            RETURN NEW;
        END IF;
        
        -- Update the internal_sales_order_item to mark as manufactured
        UPDATE mod_base.internal_sales_order_items
        SET is_manufactured = true,
            updated_at = NOW(),
            updated_by = NEW.updated_by
        WHERE sales_order_id = v_internal_sales_order_id
          AND article_id = v_article_id;
        
        -- Check if update was successful
        IF FOUND THEN
            RAISE NOTICE 'Successfully marked internal sales order item as manufactured for article % in internal sales order %', 
                         v_article_id, v_internal_sales_order_id;
        ELSE
            RAISE WARNING 'No internal sales order item found to mark as manufactured for article % in internal sales order %', 
                          v_article_id, v_internal_sales_order_id;
        END IF;
        
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_manufacturing"."handle_internal_work_order_manufacturing_status"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_manufacturing"."handle_internal_work_order_manufacturing_status"() IS 'Trigger function that automatically marks internal sales order items as manufactured when a work order with internal_sales_order_id is completed';



CREATE OR REPLACE FUNCTION "mod_manufacturing"."handle_locations_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_manufacturing"."handle_locations_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."handle_new_table_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_manufacturing"."handle_new_table_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."handle_production_logs_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_manufacturing"."handle_production_logs_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."handle_recipes_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- If the INSERT doesn't explicitly provide created_by,
        -- default to the user performing this operation.
        new.created_by := coalesce(
            new.created_by,
            auth.uid()
        );
    ELSIF TG_OP = 'UPDATE' THEN
        -- On UPDATE, set the user performing this operation and the updated timestamp
        new.updated_by := auth.uid();
        new.updated_at := now();
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_manufacturing"."handle_recipes_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."handle_scheduled_items_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "mod_manufacturing"."handle_scheduled_items_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."handle_work_cycles_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Maintain updated_at timestamp on updates only
  IF TG_OP = 'UPDATE' THEN
    NEW.updated_at := now();
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_manufacturing"."handle_work_cycles_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."handle_work_order_manufacturing_status"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_sales_order_id UUID;
    v_article_id UUID;
BEGIN
    -- Only process when status changes to 'completed'
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
        
        -- Get the sales_order_id and article_id from the completed work order
        v_sales_order_id := NEW.sales_order_id;
        v_article_id := NEW.article_id;
        
        -- Skip if no sales_order_id or article_id
        IF v_sales_order_id IS NULL OR v_article_id IS NULL THEN
            RAISE NOTICE 'Work order % has no sales_order_id or article_id, skipping manufacturing check', NEW.id;
            RETURN NEW;
        END IF;
        
        -- Update the sales_order_item to mark as manufactured
        UPDATE mod_base.sales_order_items
        SET is_manufactured = true,
            updated_at = NOW(),
            updated_by = NEW.updated_by
        WHERE sales_order_id = v_sales_order_id
          AND article_id = v_article_id;
        
        -- Check if update was successful
        IF FOUND THEN
            RAISE NOTICE 'Successfully marked sales order item as manufactured for article % in sales order %', 
                         v_article_id, v_sales_order_id;
        ELSE
            RAISE WARNING 'No sales order item found to mark as manufactured for article % in sales order %', 
                          v_article_id, v_sales_order_id;
        END IF;
        
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_manufacturing"."handle_work_order_manufacturing_status"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_manufacturing"."handle_work_order_manufacturing_status"() IS 'Trigger function that automatically marks sales order items as manufactured when a work order is completed';



CREATE OR REPLACE FUNCTION "mod_manufacturing"."handle_work_order_quality_summary_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
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
        
        -- Update completed_at if status changed to a final state
        IF OLD.overall_status != NEW.overall_status AND 
           NEW.overall_status IN ('PASSED', 'FAILED') AND
           NEW.completed_at IS NULL THEN
            NEW.completed_at := now();
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_manufacturing"."handle_work_order_quality_summary_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."handle_work_order_status_notifications"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_department_id UUID := '59333c3d-da35-4b5b-9122-391d327df937'; -- Administration / Production Scheduling department
    v_notification_name TEXT;
    v_notification_description TEXT;
    v_work_order_name TEXT;
    v_article_name TEXT;
    v_sales_order_number TEXT;
    v_employee_record RECORD;
    v_notification_code TEXT;
BEGIN
    -- Only process if status actually changed and is one of our target statuses
    IF OLD.status IS DISTINCT FROM NEW.status AND NEW.status IN ('in_progress', 'paused', 'completed') THEN
        
        -- Get work order details for notification
        SELECT 
            wo.name,
            a.name as article_name,
            so.sales_order_number
        INTO v_work_order_name, v_article_name, v_sales_order_number
        FROM mod_manufacturing.work_orders wo
        LEFT JOIN mod_base.articles a ON a.id = wo.article_id
        LEFT JOIN mod_base.sales_orders so ON so.id = wo.sales_order_id
        WHERE wo.id = NEW.id;
        
        -- Set notification content based on status transition
        IF OLD.status = 'pending' AND NEW.status = 'in_progress' THEN
            v_notification_name := 'Lavoro Iniziato';
            v_notification_description := 'L''Ordine di Lavoro "' || COALESCE(v_work_order_name, 'Sconosciuto') || 
                '" per l''articolo "' || COALESCE(v_article_name, 'Sconosciuto') || 
                '" (ODV: ' || COALESCE(v_sales_order_number, 'Sconosciuto') || ') è stato avviato.';
        ELSIF OLD.status = 'in_progress' AND NEW.status = 'paused' THEN
            v_notification_name := 'Lavoro In Sospeso';
            v_notification_description := 'L''Ordine di Lavoro "' || COALESCE(v_work_order_name, 'Sconosciuto') || 
                '" per l''articolo "' || COALESCE(v_article_name, 'Sconosciuto') || 
                '" (ODV: ' || COALESCE(v_sales_order_number, 'Sconosciuto') || ') è stato messo in pausa.';
        ELSIF OLD.status = 'paused' AND NEW.status = 'in_progress' THEN
            v_notification_name := 'Lavoro Ripreso';
            v_notification_description := 'L''Ordine di Lavoro "' || COALESCE(v_work_order_name, 'Sconosciuto') || 
                '" per l''articolo "' || COALESCE(v_article_name, 'Sconosciuto') || 
                '" (ODV: ' || COALESCE(v_sales_order_number, 'Sconosciuto') || ') è stato ripreso.';
        ELSIF OLD.status = 'in_progress' AND NEW.status = 'completed' THEN
            v_notification_name := 'Lavoro Completato';
            v_notification_description := 'L''Ordine di Lavoro "' || COALESCE(v_work_order_name, 'Sconosciuto') || 
                '" per l''articolo "' || COALESCE(v_article_name, 'Sconosciuto') || 
                '" (ODV: ' || COALESCE(v_sales_order_number, 'Sconosciuto') || ') è stato completato.';
        END IF;
        
        -- Generate unique notification code
        v_notification_code := 'WO_STATUS_' || NEW.status || '_' || NEW.id || '_' || extract(epoch from now())::text;
        
        -- Loop through all employees in the Administration / Production Scheduling department
        FOR v_employee_record IN 
            SELECT ed.employee_id
            FROM mod_base.employees_departments ed
            WHERE ed.department_id = v_department_id
            AND ed.is_deleted = false
        LOOP
            -- Insert individual notification for each employee
            INSERT INTO mod_pulse.notifications (
                name,
                description,
                code,
                user_id,
                pulse_id,
                type,
                is_read,
                avatar_url,
                barcode,
                domain_id,
                shared_with,
                is_deleted,
                created_at,
                updated_at,
                created_by,
                updated_by,
                department_id
            ) VALUES (
                v_notification_name,
                v_notification_description,
                v_notification_code,
                v_employee_record.employee_id, -- Individual employee notification
                NULL, -- No specific pulse
                'update_pulse',
                false,
                '', -- No avatar
                regexp_replace(gen_random_uuid()::text, '-', '', 'g'),
                NEW.domain_id,
                ARRAY['*'], -- Shared with all departments
                false,
                NOW(),
                NOW(),
                NEW.updated_by,
                NEW.updated_by,
                v_department_id -- Target department: Administration / Production Scheduling
            );
        END LOOP;
        
        RAISE NOTICE 'Work order status notifications created for work order % with status % - sent to all employees in Administration / Production Scheduling department', NEW.id, NEW.status;
        
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_manufacturing"."handle_work_order_status_notifications"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_manufacturing"."handle_work_order_status_notifications"() IS 'Trigger function that creates individual notifications for each employee in the Administration / Production Scheduling department when work order status changes occur (pending→in_progress, in_progress→paused, paused→in_progress, in_progress→completed)';



CREATE OR REPLACE FUNCTION "mod_manufacturing"."handle_work_orders_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_manufacturing"."handle_work_orders_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."handle_work_steps_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_manufacturing"."handle_work_steps_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."handle_workstations_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_manufacturing"."handle_workstations_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."update_article_loaded_for_all_work_orders"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Only proceed if article_loaded is being set to TRUE
  IF NEW.article_loaded = TRUE AND (OLD.article_loaded IS NULL OR OLD.article_loaded = FALSE) THEN
    
    -- Update all other work orders for the same sales_order_id and article_id
    -- to also have article_loaded = TRUE
    UPDATE mod_manufacturing.work_orders 
    SET 
      article_loaded = TRUE,
      updated_at = NOW()
    WHERE 
      sales_order_id = NEW.sales_order_id 
      AND article_id = NEW.article_id 
      AND id != NEW.id  -- Don't update the current work order (it's already updated)
      AND article_loaded = FALSE;  -- Only update if not already loaded
    
    -- Log the update for debugging
    RAISE NOTICE 'Updated article_loaded=TRUE for all work orders with sales_order_id=%, article_id=%', 
      NEW.sales_order_id, NEW.article_id;
      
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_manufacturing"."update_article_loaded_for_all_work_orders"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."update_article_unloaded_for_all_work_orders"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Only proceed if article_unloaded is being set to TRUE
  IF NEW.article_unloaded = TRUE AND (OLD.article_unloaded IS NULL OR OLD.article_unloaded = FALSE) THEN
    
    -- Update all other work orders for the same sales_order_id and article_id
    -- to also have article_unloaded = TRUE
    UPDATE mod_manufacturing.work_orders 
    SET 
      article_unloaded = TRUE,
      updated_at = NOW()
    WHERE 
      sales_order_id = NEW.sales_order_id 
      AND article_id = NEW.article_id 
      AND id != NEW.id  -- Don't update the current work order (it's already updated)
      AND article_unloaded = FALSE;  -- Only update if not already unloaded
    
    -- Log the update for debugging
    RAISE NOTICE 'Updated article_unloaded=TRUE for all work orders with sales_order_id=%, article_id=%', 
      NEW.sales_order_id, NEW.article_id;
      
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_manufacturing"."update_article_unloaded_for_all_work_orders"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."update_production_date_on_work_order_insert"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_rows_updated integer;
  v_production_date date;
BEGIN
  -- Only process if scheduled_start is provided
  IF NEW.scheduled_start IS NULL THEN
    RETURN NEW;
  END IF;

  -- Convert timestamp to date for production_date field
  v_production_date := NEW.scheduled_start::date;

  -- Handle regular sales orders
  IF NEW.sales_order_id IS NOT NULL THEN
    UPDATE mod_base.sales_order_items
    SET production_date = v_production_date,
        updated_at = NOW(),
        updated_by = COALESCE(NEW.created_by, auth.uid())
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
        updated_by = COALESCE(NEW.created_by, auth.uid())
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
  -- Log error but don't fail the insert
  RAISE WARNING 'Error updating production_date on work order insert: %', SQLERRM;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_manufacturing"."update_production_date_on_work_order_insert"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_manufacturing"."update_production_date_on_work_order_insert"() IS 'Automatically updates production_date in sales_order_items or internal_sales_order_items when a work order is inserted with a scheduled_start date. Matches by sales_order_id/internal_sales_order_id and article_id.';



CREATE OR REPLACE FUNCTION "mod_manufacturing"."update_sales_order_in_production_on_work_order_status"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_rows_updated integer;
BEGIN
  -- Only process when status changes from 'pending' to 'in_progress'
  IF OLD.status = 'pending' AND NEW.status = 'in_progress' THEN
    
    -- Handle regular sales orders only (internal_sales_orders don't have in_production field)
    IF NEW.sales_order_id IS NOT NULL THEN
      -- Only update if in_production is not already TRUE (avoid unnecessary updates)
      UPDATE mod_base.sales_orders
      SET in_production = true,
          updated_at = NOW(),
          updated_by = COALESCE(NEW.updated_by, NEW.created_by, auth.uid())
      WHERE id = NEW.sales_order_id
        AND is_deleted = false
        AND in_production = false;  -- Only update if not already TRUE
      
      GET DIAGNOSTICS v_rows_updated = ROW_COUNT;
      
      IF v_rows_updated > 0 THEN
        RAISE NOTICE 'Updated in_production to TRUE for sales_order_id: % (work_order_id: %)', 
                     NEW.sales_order_id, NEW.id;
      ELSIF v_rows_updated = 0 THEN
        -- This is normal if in_production was already TRUE, so we don't log a warning
        RAISE NOTICE 'Sales order already has in_production = TRUE (sales_order_id: %, work_order_id: %)', 
                     NEW.sales_order_id, NEW.id;
      END IF;
    END IF;
    
    -- Note: Internal sales orders don't have in_production field, so we skip them
    -- They use is_production_complete instead, which is managed differently
  END IF;

  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Log error but don't fail the update
  RAISE WARNING 'Error updating in_production on work order status change: % (work_order_id: %)', 
               SQLERRM, NEW.id;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_manufacturing"."update_sales_order_in_production_on_work_order_status"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_manufacturing"."update_sales_order_in_production_on_work_order_status"() IS 'Automatically sets in_production = TRUE on sales_orders when a work order status changes from pending to in_progress. Only handles regular sales_orders.';



CREATE OR REPLACE FUNCTION "mod_manufacturing"."update_sales_order_status_on_work_order_in_progress"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_sales_order_id UUID;
    v_internal_sales_order_id UUID;
BEGIN
    -- Only process when status changes to 'in_progress'
    IF NEW.status = 'in_progress' AND (OLD.status IS NULL OR OLD.status != 'in_progress') THEN
        
        -- Get the sales_order_id and internal_sales_order_id from the work order
        v_sales_order_id := NEW.sales_order_id;
        v_internal_sales_order_id := NEW.internal_sales_order_id;
        
        -- Update sales_order if it exists
        IF v_sales_order_id IS NOT NULL THEN
            UPDATE mod_base.sales_orders
            SET status = 'processing',
                updated_at = NOW(),
                updated_by = NEW.updated_by
            WHERE id = v_sales_order_id
              AND status != 'processing'; -- Only update if not already processing
            
            IF FOUND THEN
                RAISE NOTICE 'Successfully updated sales order % status to "processing" when work order % changed to "in_progress"', 
                             v_sales_order_id, NEW.id;
            END IF;
        END IF;
        
        -- Update internal_sales_order if it exists
        IF v_internal_sales_order_id IS NOT NULL THEN
            UPDATE mod_base.internal_sales_orders
            SET status = 'processing',
                updated_at = NOW(),
                updated_by = NEW.updated_by
            WHERE id = v_internal_sales_order_id
              AND status != 'processing'; -- Only update if not already processing
            
            IF FOUND THEN
                RAISE NOTICE 'Successfully updated internal sales order % status to "processing" when work order % changed to "in_progress"', 
                             v_internal_sales_order_id, NEW.id;
            END IF;
        END IF;
        
        -- Log if neither exists (should not happen based on constraint, but good to log)
        IF v_sales_order_id IS NULL AND v_internal_sales_order_id IS NULL THEN
            RAISE NOTICE 'Work order % changed to "in_progress" but has no associated sales_order_id or internal_sales_order_id', NEW.id;
        END IF;
        
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_manufacturing"."update_sales_order_status_on_work_order_in_progress"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_manufacturing"."update_sales_order_status_on_work_order_in_progress"() IS 'Trigger function that automatically updates the status of related sales_order or internal_sales_order to "processing" when a work order status changes to "in_progress"';



CREATE OR REPLACE FUNCTION "mod_manufacturing"."update_work_cycle_categories_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_manufacturing"."update_work_cycle_categories_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_manufacturing"."update_work_flows_work_cycles_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_manufacturing"."update_work_flows_work_cycles_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."create_pulse_for_record"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "mod_pulse"."create_pulse_for_record"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_pulse"."create_pulse_for_record"() IS 'Creates a pulse record for various tables including internal_sales_orders. Updated to handle internal_sales_orders table.';



CREATE OR REPLACE FUNCTION "mod_pulse"."delete_chat_attachment"("file_url" "text", OUT "status" integer, OUT "content" "text") RETURNS "record"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  object_path text;
begin
  -- Extract object path from the file URL
  object_path := replace(file_url, rtrim(current_setting('supabase_storage.public_url'), '/') || '/chat_attachments/', '');
  
  select
    into status, content
    result.status, result.content
    from mod_admin.delete_storage_object('chat_attachments', object_path) as result;
end;
$$;


ALTER FUNCTION "mod_pulse"."delete_chat_attachment"("file_url" "text", OUT "status" integer, OUT "content" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."delete_old_chat_attachment"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  status int;
  content text;
begin
  if coalesce(old.file_url, '') <> '' then
    select
      into status, content
      result.status, result.content
      from mod_pulse.delete_chat_attachment(old.file_url) as result;
    if status <> 200 then
      raise warning 'Could not delete chat attachment: % %', status, content;
    end if;
  end if;
  return old;
end;
$$;


ALTER FUNCTION "mod_pulse"."delete_old_chat_attachment"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."get_user_notifications"("p_limit" integer DEFAULT 50, "p_offset" integer DEFAULT 0, "p_is_read" boolean DEFAULT NULL::boolean) RETURNS TABLE("id" "uuid", "name" "text", "description" "text", "code" "text", "type" "text", "is_read" boolean, "avatar_url" "text", "barcode" "text", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "created_by" "uuid", "updated_by" "uuid", "pulse_id" "uuid", "total_count" bigint)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  current_user_id UUID;
  total_notifications BIGINT;
BEGIN
  -- Get the current authenticated user ID
  current_user_id := auth.uid();
  
  -- If no user is authenticated, return empty result
  IF current_user_id IS NULL THEN
    RETURN;
  END IF;
  
  -- Get total count for pagination
  SELECT COUNT(*) INTO total_notifications
  FROM mod_pulse.notifications
  WHERE user_id = current_user_id
    AND is_deleted = false
    AND (p_is_read IS NULL OR is_read = p_is_read);
  
  -- Return notifications with pagination
  RETURN QUERY
  SELECT 
    n.id,
    n.name,
    n.description,
    n.code,
    n.type,
    n.is_read,
    n.avatar_url,
    n.barcode,
    n.created_at,
    n.updated_at,
    n.created_by,
    n.updated_by,
    n.pulse_id,
    total_notifications
  FROM mod_pulse.notifications n
  WHERE n.user_id = current_user_id
    AND n.is_deleted = false
    AND (p_is_read IS NULL OR n.is_read = p_is_read)
  ORDER BY n.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;


ALTER FUNCTION "mod_pulse"."get_user_notifications"("p_limit" integer, "p_offset" integer, "p_is_read" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."handle_department_notification_configs_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "mod_pulse"."handle_department_notification_configs_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."handle_new_task_notifications"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  notification_name TEXT;
  notification_description TEXT;
  task_assignee_name TEXT;
  task_department_name TEXT;
BEGIN
  -- Create base notification name and description
  notification_name := 'New Task: ' || NEW.name;
  notification_description := 'A new task has been assigned: ' || NEW.name;
  
  -- Add description if available
  IF NEW.description IS NOT NULL AND NEW.description != '' THEN
    notification_description := notification_description || ' - ' || NEW.description;
  END IF;
  
  -- Add due date if available
  IF NEW.due_date IS NOT NULL THEN
    notification_description := notification_description || ' (Due: ' || 
      to_char(NEW.due_date, 'YYYY-MM-DD HH24:MI') || ')';
  END IF;

  -- Create notification for assigned user (if assigned_id is not null)
  IF NEW.assigned_id IS NOT NULL THEN
    -- Get assignee name for better notification context
    SELECT name INTO task_assignee_name
    FROM mod_base.employees 
    WHERE id = NEW.assigned_id;
    
    -- Insert notification for the assigned user
    INSERT INTO mod_pulse.notifications (
      name,
      description,
      type,
      user_id,
      created_by,
      domain_id,
      department_id,
      pulse_id
    ) VALUES (
      notification_name,
      notification_description,
      'new_pulse',
      NEW.assigned_id,
      NEW.created_by,
      NEW.domain_id,
      NEW.assigned_department_id,
      NEW.pulse_id
    );
  END IF;

  -- Create notification for assigned department (if assigned_department_id is not null)
  IF NEW.assigned_department_id IS NOT NULL THEN
    -- Get department name for better notification context
    SELECT name INTO task_department_name
    FROM mod_base.departments 
    WHERE id = NEW.assigned_department_id;
    
    -- Insert notification for the department (using shared_with array)
    INSERT INTO mod_pulse.notifications (
      name,
      description,
      type,
      user_id,
      created_by,
      domain_id,
      department_id,
      pulse_id,
      shared_with
    ) VALUES (
      notification_name || ' (Department)',
      notification_description || ' - Assigned to ' || COALESCE(task_department_name, 'Department'),
      'new_pulse',
      NULL, -- No specific user for department notifications
      NEW.created_by,
      NEW.domain_id,
      NEW.assigned_department_id,
      NEW.pulse_id,
      ARRAY[NEW.assigned_department_id::text] -- Share with the specific department
    );
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_pulse"."handle_new_task_notifications"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."handle_notifications_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_pulse"."handle_notifications_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."handle_pulse_chat_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_pulse"."handle_pulse_chat_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."handle_pulse_chat_files_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_pulse"."handle_pulse_chat_files_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."handle_pulse_checklists_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_pulse"."handle_pulse_checklists_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."handle_pulse_comments_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_pulse"."handle_pulse_comments_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."handle_pulse_conversation_participants_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_pulse"."handle_pulse_conversation_participants_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."handle_pulse_progress_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_pulse"."handle_pulse_progress_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."handle_pulse_sla_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_pulse"."handle_pulse_sla_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."handle_pulses_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_pulse"."handle_pulses_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."handle_record_deletion"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Delete the corresponding pulse record
  DELETE FROM mod_pulse.pulses WHERE id = OLD.id;
  RETURN OLD;
END;
$$;


ALTER FUNCTION "mod_pulse"."handle_record_deletion"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."handle_task_assignment_updates"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  notification_name TEXT;
  notification_description TEXT;
  task_assignee_name TEXT;
  task_department_name TEXT;
  old_assignee_name TEXT;
  old_department_name TEXT;
  new_assignee_name TEXT;
  new_department_name TEXT;
BEGIN
  -- Check if assigned_id was changed
  IF OLD.assigned_id IS DISTINCT FROM NEW.assigned_id THEN
    -- Get names for better context
    IF OLD.assigned_id IS NOT NULL THEN
      SELECT name INTO old_assignee_name
      FROM mod_base.employees 
      WHERE id = OLD.assigned_id;
    END IF;
    
    IF NEW.assigned_id IS NOT NULL THEN
      SELECT name INTO new_assignee_name
      FROM mod_base.employees 
      WHERE id = NEW.assigned_id;
    END IF;
    
    -- Create notification for the new assignee (if not null)
    IF NEW.assigned_id IS NOT NULL THEN
      notification_name := 'Task Assigned: ' || NEW.name;
      notification_description := 'Task "' || NEW.name || '" has been assigned to you';
      
      -- Add description if available
      IF NEW.description IS NOT NULL AND NEW.description != '' THEN
        notification_description := notification_description || ' - ' || NEW.description;
      END IF;
      
      -- Add due date if available
      IF NEW.due_date IS NOT NULL THEN
        notification_description := notification_description || ' (Due: ' || 
          to_char(NEW.due_date, 'YYYY-MM-DD HH24:MI') || ')';
      END IF;
      
      -- Insert notification for the new assignee
      INSERT INTO mod_pulse.notifications (
        name,
        description,
        type,
        user_id,
        created_by,
        domain_id,
        department_id,
        pulse_id
      ) VALUES (
        notification_name,
        notification_description,
        'update_pulse',
        NEW.assigned_id,
        NEW.updated_by,
        NEW.domain_id,
        NEW.assigned_department_id,
        NEW.pulse_id
      );
    END IF;
    
    -- Create notification for the old assignee (if not null) - task was unassigned
    IF OLD.assigned_id IS NOT NULL AND NEW.assigned_id IS NULL THEN
      notification_name := 'Task Unassigned: ' || NEW.name;
      notification_description := 'Task "' || NEW.name || '" has been unassigned from you';
      
      INSERT INTO mod_pulse.notifications (
        name,
        description,
        type,
        user_id,
        created_by,
        domain_id,
        department_id,
        pulse_id
      ) VALUES (
        notification_name,
        notification_description,
        'update_pulse',
        OLD.assigned_id,
        NEW.updated_by,
        NEW.domain_id,
        NEW.assigned_department_id,
        NEW.pulse_id
      );
    END IF;
  END IF;

  -- Check if assigned_department_id was changed
  IF OLD.assigned_department_id IS DISTINCT FROM NEW.assigned_department_id THEN
    -- Get department names for better context
    IF OLD.assigned_department_id IS NOT NULL THEN
      SELECT name INTO old_department_name
      FROM mod_base.departments 
      WHERE id = OLD.assigned_department_id;
    END IF;
    
    IF NEW.assigned_department_id IS NOT NULL THEN
      SELECT name INTO new_department_name
      FROM mod_base.departments 
      WHERE id = NEW.assigned_department_id;
    END IF;
    
    -- Create notification for the new department (if not null)
    IF NEW.assigned_department_id IS NOT NULL THEN
      notification_name := 'Task Department Assignment: ' || NEW.name;
      notification_description := 'Task "' || NEW.name || '" has been assigned to ' || 
        COALESCE(new_department_name, 'your department');
      
      -- Add description if available
      IF NEW.description IS NOT NULL AND NEW.description != '' THEN
        notification_description := notification_description || ' - ' || NEW.description;
      END IF;
      
      -- Add due date if available
      IF NEW.due_date IS NOT NULL THEN
        notification_description := notification_description || ' (Due: ' || 
          to_char(NEW.due_date, 'YYYY-MM-DD HH24:MI') || ')';
      END IF;
      
      -- Insert notification for the new department
      INSERT INTO mod_pulse.notifications (
        name,
        description,
        type,
        user_id,
        created_by,
        domain_id,
        department_id,
        pulse_id,
        shared_with
      ) VALUES (
        notification_name,
        notification_description,
        'update_pulse',
        NULL, -- No specific user for department notifications
        NEW.updated_by,
        NEW.domain_id,
        NEW.assigned_department_id,
        NEW.pulse_id,
        ARRAY[NEW.assigned_department_id::text] -- Share with the specific department
      );
    END IF;
    
    -- Create notification for the old department (if not null) - task was unassigned from department
    IF OLD.assigned_department_id IS NOT NULL AND NEW.assigned_department_id IS NULL THEN
      notification_name := 'Task Department Unassignment: ' || NEW.name;
      notification_description := 'Task "' || NEW.name || '" has been unassigned from ' || 
        COALESCE(old_department_name, 'your department');
      
      INSERT INTO mod_pulse.notifications (
        name,
        description,
        type,
        user_id,
        created_by,
        domain_id,
        department_id,
        pulse_id,
        shared_with
      ) VALUES (
        notification_name,
        notification_description,
        'update_pulse',
        NULL, -- No specific user for department notifications
        NEW.updated_by,
        NEW.domain_id,
        OLD.assigned_department_id,
        NEW.pulse_id,
        ARRAY[OLD.assigned_department_id::text] -- Share with the old department
      );
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_pulse"."handle_task_assignment_updates"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."handle_tasks_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_pulse"."handle_tasks_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."mark_all_notifications_as_read"() RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  current_user_id UUID;
  updated_rows INTEGER;
BEGIN
  -- Get the current authenticated user ID
  current_user_id := auth.uid();
  
  -- If no user is authenticated, return 0
  IF current_user_id IS NULL THEN
    RETURN 0;
  END IF;
  
  -- Update all unread notifications as read
  UPDATE mod_pulse.notifications
  SET is_read = TRUE,
      updated_at = NOW(),
      updated_by = current_user_id
  WHERE user_id = current_user_id
    AND is_deleted = false
    AND is_read = FALSE;
  
  -- Get the number of updated rows
  GET DIAGNOSTICS updated_rows = ROW_COUNT;
  
  RETURN updated_rows;
END;
$$;


ALTER FUNCTION "mod_pulse"."mark_all_notifications_as_read"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."mark_notification_as_read"("p_notification_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  current_user_id UUID;
  updated_rows INTEGER;
BEGIN
  -- Get the current authenticated user ID
  current_user_id := auth.uid();
  
  -- If no user is authenticated, return false
  IF current_user_id IS NULL THEN
    RETURN FALSE;
  END IF;
  
  -- Update the notification as read
  UPDATE mod_pulse.notifications
  SET is_read = TRUE,
      updated_at = NOW(),
      updated_by = current_user_id
  WHERE id = p_notification_id
    AND user_id = current_user_id
    AND is_deleted = false;
  
  -- Check if any rows were updated
  GET DIAGNOSTICS updated_rows = ROW_COUNT;
  
  RETURN updated_rows > 0;
END;
$$;


ALTER FUNCTION "mod_pulse"."mark_notification_as_read"("p_notification_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_pulse"."update_pulse_status"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Update the corresponding pulse record
  UPDATE mod_pulse.pulses
  SET 
    status = CASE 
      WHEN NEW.status = 'pending' THEN 'open'
      WHEN NEW.status = 'processing' THEN 'in_progress'
      WHEN NEW.status = 'completed' THEN 'resolved'
      WHEN NEW.status = 'canceled' THEN 'closed'
      WHEN NEW.status = 'in_transit' THEN 'in_progress'
      WHEN NEW.status = 'delivered' THEN 'resolved'
      WHEN NEW.status = 'failed' THEN 'closed'
      ELSE status
    END,
    updated_at = NOW(),
    updated_by = NEW.updated_by
  WHERE id = NEW.id;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_pulse"."update_pulse_status"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_quality_control"."generate_return_number"() RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
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
END;
$$;


ALTER FUNCTION "mod_quality_control"."generate_return_number"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."calculate_total_available_stock"() RETURNS numeric
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN COALESCE(
        (SELECT SUM(i.quantity)
         FROM mod_wms.inventory i
         WHERE i.quantity > 0),
        0
    );
END;
$$;


ALTER FUNCTION "mod_wms"."calculate_total_available_stock"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."copy_shipment_address_to_item"("p_shipment_item_id" "uuid", "p_address_type" character varying DEFAULT 'delivery'::character varying) RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "mod_wms"."copy_shipment_address_to_item"("p_shipment_item_id" "uuid", "p_address_type" character varying) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."count_low_stock_items"() RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN (
        SELECT COUNT(DISTINCT i.article_id)
        FROM mod_wms.inventory i
        JOIN mod_wms.inventory_limits il ON il.article_id = i.article_id
        WHERE i.quantity < il.min_stock
    );
END;
$$;


ALTER FUNCTION "mod_wms"."count_low_stock_items"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."count_out_of_stock_items"() RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN (
        SELECT COUNT(DISTINCT article_id)
        FROM mod_wms.inventory
        WHERE quantity <= 0 OR quantity IS NULL
    );
END;
$$;


ALTER FUNCTION "mod_wms"."count_out_of_stock_items"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."debug_relocation_movement"("p_article_id" "uuid", "p_from_location_id" "uuid", "p_to_location_id" "uuid", "p_batch_id" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("location_name" "text", "batch_number" "text", "current_quantity" numeric, "movement_type" "text")
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.name as location_name,
        COALESCE(b.batch_number, 'No Batch') as batch_number,
        i.quantity as current_quantity,
        CASE 
            WHEN i.location_id = p_from_location_id THEN 'SOURCE'
            WHEN i.location_id = p_to_location_id THEN 'DESTINATION'
            ELSE 'OTHER'
        END as movement_type
    FROM mod_wms.inventory i
    JOIN mod_wms.locations l ON i.location_id = l.id
    LEFT JOIN mod_wms.batches b ON i.batch_id = b.id
    WHERE i.article_id = p_article_id
      AND (i.location_id = p_from_location_id OR i.location_id = p_to_location_id)
      AND (p_batch_id IS NULL OR i.batch_id = p_batch_id)
      AND i.quantity > 0
    ORDER BY movement_type, l.name;
END;
$$;


ALTER FUNCTION "mod_wms"."debug_relocation_movement"("p_article_id" "uuid", "p_from_location_id" "uuid", "p_to_location_id" "uuid", "p_batch_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "mod_wms"."debug_relocation_movement"("p_article_id" "uuid", "p_from_location_id" "uuid", "p_to_location_id" "uuid", "p_batch_id" "uuid") IS 'Debug function to show current inventory state for source and destination locations before/after relocations.';



CREATE OR REPLACE FUNCTION "mod_wms"."delete_item_address"("p_address_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    DELETE FROM mod_wms.shipment_item_addresses WHERE id = p_address_id;
    RETURN FOUND;
END;
$$;


ALTER FUNCTION "mod_wms"."delete_item_address"("p_address_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."generate_unique_receipt_number"() RETURNS "text"
    LANGUAGE "plpgsql"
    AS $_$
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
$_$;


ALTER FUNCTION "mod_wms"."generate_unique_receipt_number"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."get_historical_inventory_stats"("target_date" timestamp with time zone) RETURNS json
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    result json;
BEGIN
    WITH historical_inventory AS (
        SELECT 
            i.article_id,
            i.quantity,
            sm.movement_date
        FROM mod_wms.inventory i
        LEFT JOIN mod_wms.stock_movements sm ON sm.article_id = i.article_id
        WHERE sm.movement_date <= target_date
        ORDER BY sm.movement_date DESC
    )
    SELECT json_build_object(
        'totalProducts', (
            SELECT COUNT(DISTINCT article_id) 
            FROM mod_wms.inventory
        ),
        'availableStock', (
            SELECT COALESCE(SUM(quantity), 0)
            FROM mod_wms.inventory
            WHERE quantity > 0
        ),
        'lowStock', (
            SELECT COUNT(DISTINCT i.article_id)
            FROM mod_wms.inventory i
            JOIN mod_wms.inventory_limits il ON il.article_id = i.article_id
            WHERE i.quantity < il.min_stock
        ),
        'outOfStock', (
            SELECT COUNT(DISTINCT article_id)
            FROM mod_wms.inventory
            WHERE quantity <= 0 OR quantity IS NULL
        )
    ) INTO result;

    RETURN result;
END;
$$;


ALTER FUNCTION "mod_wms"."get_historical_inventory_stats"("target_date" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."get_item_all_addresses"("p_shipment_item_id" "uuid") RETURNS TABLE("id" "uuid", "address_type" character varying, "address" "text", "city" "text", "state" "text", "zip" "text", "country" "text", "province" "text", "is_primary" boolean, "notes" "text", "created_at" timestamp with time zone)
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "mod_wms"."get_item_all_addresses"("p_shipment_item_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."get_item_primary_address"("p_shipment_item_id" "uuid", "p_address_type" character varying DEFAULT 'delivery'::character varying) RETURNS TABLE("address" "text", "city" "text", "state" "text", "zip" "text", "country" "text", "province" "text", "address_type" character varying, "is_primary" boolean, "notes" "text")
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "mod_wms"."get_item_primary_address"("p_shipment_item_id" "uuid", "p_address_type" character varying) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."handle_article_components_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- If the INSERT doesn't explicitly provide created_by,
        -- default to the user performing this operation.
        new.created_by := coalesce(
            new.created_by,
            auth.uid()
        );
    ELSIF TG_OP = 'UPDATE' THEN
        -- On UPDATE, set the user performing this operation and the updated timestamp
        new.updated_by := auth.uid();
        new.updated_at := now();
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_wms"."handle_article_components_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."handle_batches_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_wms"."handle_batches_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."handle_inbound_stock_movement"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Only process inbound movements
    IF NEW.type != 'inbound' THEN
        RETURN NEW;
    END IF;

    -- Step 1: Mark receipt item as moved if receipt_item_id is provided
    IF NEW.receipt_item_id IS NOT NULL THEN
        UPDATE mod_wms.receipt_items
        SET 
            is_moved = TRUE,
            moved_date = NOW(),
            updated_at = NOW(),
            updated_by = NEW.updated_by
        WHERE id = NEW.receipt_item_id;
    END IF;

    -- Step 2: Create inventory record if batch_id is provided
    -- Skip if no batch_id provided (let application handle this case)
    IF NEW.batch_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- Since batch_id is unique, always create a new inventory record
    -- Each inbound movement with a batch_id creates a separate inventory entry
    INSERT INTO mod_wms.inventory (
        article_id,
        location_id,
        batch_id,
        quantity,
        allocated_qty,
        domain_id,
        created_by,
        updated_by,
        created_at,
        updated_at
    ) VALUES (
        NEW.article_id,
        NEW.to_location_id,
        NEW.batch_id,
        NEW.quantity_moved,
        0, -- Start with 0 allocated quantity
        NEW.domain_id,
        NEW.created_by,
        NEW.updated_by,
        NOW(),
        NOW()
    );

    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_wms"."handle_inbound_stock_movement"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_wms"."handle_inbound_stock_movement"() IS 'Trigger function that automatically marks receipt items as moved and creates new inventory records when inbound stock movements are inserted. Updates receipt_items.is_moved to TRUE and sets moved_date when receipt_item_id is provided. Creates inventory records when batch_id is provided.';



CREATE OR REPLACE FUNCTION "mod_wms"."handle_inventory_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
        NEW.updated_at := NOW();
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_wms"."handle_inventory_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."handle_inventory_limits_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_wms"."handle_inventory_limits_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."handle_loading_stock_movement"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    source_inventory RECORD;
    destination_inventory RECORD;
BEGIN
    -- Only process loading movements
    IF NEW.type != 'loading' THEN
        RETURN NEW;
    END IF;

    -- Check if both from_location_id and to_location_id are provided
    IF NEW.from_location_id IS NOT NULL AND NEW.to_location_id IS NOT NULL THEN
        -- Step 1: Check if source inventory exists and has enough quantity
        SELECT * INTO source_inventory
        FROM mod_wms.inventory
        WHERE article_id = NEW.article_id
          AND location_id = NEW.from_location_id
          AND (batch_id = NEW.batch_id OR (batch_id IS NULL AND NEW.batch_id IS NULL));

        -- If source inventory doesn't exist, raise an error
        IF NOT FOUND THEN
            RAISE EXCEPTION 'No inventory record found for Article ID: %, Location ID: %, Batch ID: %. Cannot deduct quantity.',
                NEW.article_id, NEW.from_location_id, NEW.batch_id;
        END IF;

        -- Check if there's enough quantity to deduct
        IF source_inventory.quantity < NEW.quantity_moved THEN
            RAISE EXCEPTION 'Insufficient quantity in source location. Available: %, Required: %',
                source_inventory.quantity, NEW.quantity_moved;
        END IF;

        -- Step 2: Deduct quantity from source location
        UPDATE mod_wms.inventory
        SET quantity = quantity - NEW.quantity_moved,
            updated_at = NOW(),
            updated_by = NEW.updated_by
        WHERE article_id = NEW.article_id
          AND location_id = NEW.from_location_id
          AND (batch_id = NEW.batch_id OR (batch_id IS NULL AND NEW.batch_id IS NULL));

        -- Step 3: Add quantity to destination location (UPSERT)
        INSERT INTO mod_wms.inventory (
            article_id,
            location_id,
            batch_id,
            quantity,
            allocated_qty,
            domain_id,
            created_by,
            updated_by,
            created_at,
            updated_at
        ) VALUES (
            NEW.article_id,
            NEW.to_location_id,
            NEW.batch_id,
            NEW.quantity_moved,
            0, -- Start with 0 allocated quantity
            NEW.domain_id,
            NEW.created_by,
            NEW.updated_by,
            NOW(),
            NOW()
        )
        ON CONFLICT (article_id, location_id, batch_id) 
        DO UPDATE SET
            quantity = inventory.quantity + NEW.quantity_moved,
            updated_at = NOW(),
            updated_by = NEW.updated_by;

    ELSE
        -- Fallback: Only add to destination (original behavior)
        -- This handles cases where only to_location_id is provided
        INSERT INTO mod_wms.inventory (
            article_id,
            location_id,
            batch_id,
            quantity,
            allocated_qty,
            domain_id,
            created_by,
            updated_by,
            created_at,
            updated_at
        ) VALUES (
            NEW.article_id,
            NEW.to_location_id,
            NEW.batch_id,
            NEW.quantity_moved,
            0, -- Start with 0 allocated quantity
            NEW.domain_id,
            NEW.created_by,
            NEW.updated_by,
            NOW(),
            NOW()
        )
        ON CONFLICT (article_id, location_id, batch_id) 
        DO UPDATE SET
            quantity = inventory.quantity + NEW.quantity_moved,
            updated_at = NOW(),
            updated_by = NEW.updated_by;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_wms"."handle_loading_stock_movement"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_wms"."handle_loading_stock_movement"() IS 'Trigger function that automatically updates inventory table when loading stock movements are inserted. For loading movements with both from_location_id and to_location_id: deducts quantity from source location and adds to destination location. Handles both batched and non-batched inventory scenarios with proper error handling.';



CREATE OR REPLACE FUNCTION "mod_wms"."handle_locations_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_wms"."handle_locations_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."handle_original_receipt_item_id"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    found_receipt_item_id UUID;
BEGIN
    -- Wrap in exception handling to ensure INSERT always succeeds even if tracing fails
    BEGIN
        -- Scenario A: If receipt_item_id is directly provided, use it as original
        IF NEW.receipt_item_id IS NOT NULL THEN
            NEW.original_receipt_item_id := NEW.receipt_item_id;
            RETURN NEW;
        END IF;

        -- Scenario B: If from_location_id exists, trace back to find original receipt
        -- Look for ANY movement type that moved stock TO the current movement's FROM location
        -- This works recursively because each movement should already have original_receipt_item_id set
        IF NEW.from_location_id IS NOT NULL AND NEW.article_id IS NOT NULL THEN
            -- Find the most recent movement that moved stock TO the current movement's FROM location
            -- Use COALESCE to prefer original_receipt_item_id (for recursive tracing) over receipt_item_id
            SELECT 
                COALESCE(sm.original_receipt_item_id, sm.receipt_item_id) INTO found_receipt_item_id
            FROM mod_wms.stock_movements sm
            WHERE sm.to_location_id = NEW.from_location_id
              AND sm.article_id = NEW.article_id
              AND (
                  -- Match batch_id if both are specified, or both are NULL
                  (sm.batch_id = NEW.batch_id) 
                  OR (sm.batch_id IS NULL AND NEW.batch_id IS NULL)
              )
              AND sm.is_deleted = false
              AND (
                  sm.receipt_item_id IS NOT NULL 
                  OR sm.original_receipt_item_id IS NOT NULL
              )
            ORDER BY sm.movement_date DESC, sm.created_at DESC
            LIMIT 1;

            -- If we found a receipt_item_id, use it
            IF found_receipt_item_id IS NOT NULL THEN
                NEW.original_receipt_item_id := found_receipt_item_id;
            END IF;
        END IF;

        -- Scenario C: If no traceable origin found, leave as NULL (no action needed)

    EXCEPTION
        WHEN OTHERS THEN
            -- If anything goes wrong, log the error but don't prevent the INSERT
            -- Leave original_receipt_item_id as NULL and continue
            -- This ensures the stock movement is still created even if receipt tracing fails
            RAISE WARNING 'Failed to trace original_receipt_item_id for stock movement: %', SQLERRM;
    END;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_wms"."handle_original_receipt_item_id"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_wms"."handle_original_receipt_item_id"() IS 'Trigger function that automatically populates original_receipt_item_id when a new stock movement is inserted. If receipt_item_id is provided, it copies it. Otherwise, it traces back through stock_movements (any movement type) to find the original receipt. Works recursively through multiple relocations. Includes error handling to ensure INSERT always succeeds even if tracing fails.';



CREATE OR REPLACE FUNCTION "mod_wms"."handle_outbound_unloading_stock_movement"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    source_inventory_record RECORD;
    destination_inventory_record RECORD;
    new_source_quantity NUMERIC(12, 4);
    new_destination_quantity NUMERIC(12, 4);
    error_message TEXT;
BEGIN
    -- Only process outbound and unloading movements
    IF NEW.type NOT IN ('outbound', 'unloading') THEN
        RETURN NEW;
    END IF;

    -- Ensure from_location_id is provided for these movement types
    IF NEW.from_location_id IS NULL THEN
        RAISE EXCEPTION 'From location is required for % movement type.', NEW.type;
    END IF;

    -- Find the specific source inventory record using exact match
    -- This ensures we're working with the specific inventory record that was selected
    SELECT * INTO source_inventory_record
    FROM mod_wms.inventory
    WHERE article_id = NEW.article_id
      AND location_id = NEW.from_location_id
      AND batch_id IS NOT DISTINCT FROM NEW.batch_id; -- Handles NULL = NULL

    -- If no source inventory record found
    IF NOT FOUND THEN
        -- Get available inventory records for better error message
        DECLARE
            available_records TEXT;
        BEGIN
            SELECT string_agg(
                format('Location: %s, Batch: %s, Qty: %s', 
                    location_id, 
                    COALESCE(batch_id::TEXT, 'NULL'), 
                    quantity
                ), 
                '; '
            ) INTO available_records
            FROM mod_wms.inventory
            WHERE article_id = NEW.article_id;
            
            error_message := format(
                'No inventory record found for Article ID: %s, Location ID: %s, Batch ID: %s. Stock movement recorded but inventory not updated. Available inventory: %s',
                NEW.article_id, NEW.from_location_id, COALESCE(NEW.batch_id::TEXT, 'NULL'), 
                COALESCE(available_records, 'None')
            );
            -- Log warning instead of raising exception to allow stock movement to be recorded
            -- This handles cases where articles are shipped without inventory (e.g., manufactured items)
            RAISE WARNING '%', error_message;
            -- Return NEW to allow stock movement record to be created even without inventory update
            RETURN NEW;
        END;
    END IF;

    -- Check if sufficient quantity is available at source
    IF source_inventory_record.quantity < NEW.quantity_moved THEN
        error_message := format(
            'Insufficient quantity available for Article ID: %s, Location ID: %s, Batch ID: %s. Requested: %s, Available: %s. Stock movement recorded but inventory not updated.',
            NEW.article_id, NEW.from_location_id, COALESCE(source_inventory_record.batch_id::TEXT, 'NULL'), NEW.quantity_moved, source_inventory_record.quantity
        );
        -- Log warning instead of raising exception to allow stock movement to be recorded
        -- This handles cases where articles are shipped without sufficient inventory
        RAISE WARNING '%', error_message;
        -- Return NEW to allow stock movement record to be created even without inventory update
        RETURN NEW;
    END IF;

    -- Calculate new quantity after deduction from source
    new_source_quantity := source_inventory_record.quantity - NEW.quantity_moved;

    -- Update the specific source inventory record using its ID
    UPDATE mod_wms.inventory
    SET quantity = new_source_quantity,
        updated_at = NOW(),
        updated_by = NEW.updated_by
    WHERE id = source_inventory_record.id; -- Use the ID of the found record for update

    -- Special handling for unloading movements with destination location
    IF NEW.type = 'unloading' AND NEW.to_location_id IS NOT NULL THEN
        -- Check if destination inventory record exists
        SELECT * INTO destination_inventory_record
        FROM mod_wms.inventory
        WHERE article_id = NEW.article_id
          AND location_id = NEW.to_location_id
          AND batch_id IS NOT DISTINCT FROM NEW.batch_id; -- Handles NULL = NULL

        -- If destination record exists, add to it
        IF FOUND THEN
            new_destination_quantity := destination_inventory_record.quantity + NEW.quantity_moved;
            
            UPDATE mod_wms.inventory
            SET quantity = new_destination_quantity,
                updated_at = NOW(),
                updated_by = NEW.updated_by
            WHERE id = destination_inventory_record.id;
        ELSE
            -- Create new inventory record at destination
            INSERT INTO mod_wms.inventory (
                article_id,
                location_id,
                batch_id,
                quantity,
                created_at,
                updated_at,
                created_by,
                updated_by
            ) VALUES (
                NEW.article_id,
                NEW.to_location_id,
                NEW.batch_id,
                NEW.quantity_moved,
                NOW(),
                NOW(),
                NEW.created_by,
                NEW.updated_by
            );
        END IF;
    END IF;

    -- If source quantity becomes 0, we could optionally delete the record
    -- For now, we'll keep it with 0 quantity for audit purposes
    -- Uncomment the following lines if you want to delete zero-quantity records:
    -- IF new_source_quantity = 0 THEN
    --     DELETE FROM mod_wms.inventory
    --     WHERE id = source_inventory_record.id;
    -- END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_wms"."handle_outbound_unloading_stock_movement"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_wms"."handle_outbound_unloading_stock_movement"() IS 'Trigger function that automatically updates inventory quantities when outbound or unloading stock movements are inserted. For outbound movements: deducts from source location. For unloading movements: deducts from source location and adds to destination location (if to_location_id is provided). If inventory is missing or insufficient, logs a warning but allows stock movement record to be created (handles cases where articles are shipped without inventory). Uses specific inventory record ID for precise updates.';



CREATE OR REPLACE FUNCTION "mod_wms"."handle_receipt_items_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_wms"."handle_receipt_items_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."handle_receipt_items_inbound_on_insert"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    receipt_name TEXT;
BEGIN
    -- Safety guard: ensure only the intended rows are processed
    IF NEW.is_moved IS DISTINCT FROM TRUE OR NEW.moved_date IS NOT NULL THEN
        RETURN NEW;
    END IF;

    -- Fetch the receipt name
    SELECT name INTO receipt_name
    FROM mod_wms.receipts
    WHERE id = NEW.receipt_id;

    -- Insert corresponding inbound stock movement
    INSERT INTO mod_wms.stock_movements (
        article_id,
        batch_id,
        from_location_id,
        to_location_id,
        quantity_moved,
        reason,
        reference_doc_type,
        reference_doc_id,
        type,
        domain_id,
        created_by,
        updated_by,
        receipt_item_id
    ) VALUES (
        NEW.article_id,
        NEW.batch_id,
        NULL,                      -- inbound has no from_location
        NEW.location_id,           -- destination is the receipt item's location
        NEW.quantity_received,     -- move the received quantity
        'Articolo ricevuto spostato - ' || COALESCE(receipt_name, ''),
        'RECEIPT',
        NEW.receipt_id,
        'inbound',
        NEW.domain_id,
        NEW.created_by,
        NEW.updated_by,
        NEW.id                     -- link back to the receipt item
    );

    -- Update the receipt item to set moved_date
    UPDATE mod_wms.receipt_items
    SET 
        moved_date = NOW(),
        updated_at = NOW(),
        updated_by = NEW.updated_by
    WHERE id = NEW.id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_wms"."handle_receipt_items_inbound_on_insert"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_wms"."handle_receipt_items_inbound_on_insert"() IS 'On insert into receipt_items with is_moved=TRUE and moved_date IS NULL, inserts an inbound stock_movements row using quantity_received and location_id.';



CREATE OR REPLACE FUNCTION "mod_wms"."handle_receipts_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_wms"."handle_receipts_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."handle_relocation_stock_movement"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    source_inventory_record RECORD;
    target_inventory_record RECORD;
    target_batch_id UUID;
    error_message TEXT;
BEGIN
    -- Only process relocation movements
    IF NEW.type != 'relocation' THEN
        RETURN NEW;
    END IF;

    -- Ensure both from_location_id and to_location_id are provided for relocation
    IF NEW.from_location_id IS NULL OR NEW.to_location_id IS NULL THEN
        RAISE EXCEPTION 'Both from location and to location are required for relocation movement type.';
    END IF;

    -- Ensure from and to locations are different
    IF NEW.from_location_id = NEW.to_location_id THEN
        RAISE EXCEPTION 'Source and destination locations must be different for relocation movement.';
    END IF;

    -- Determine the target batch_id for the inventory lookup
    target_batch_id := NEW.batch_id;

    -- Find the specific source inventory record using exact match
    -- This ensures we're working with the specific inventory record that was selected
    SELECT * INTO source_inventory_record
    FROM mod_wms.inventory
    WHERE article_id = NEW.article_id
      AND location_id = NEW.from_location_id
      AND batch_id IS NOT DISTINCT FROM target_batch_id; -- Handles NULL = NULL

    -- If no source inventory record found at all
    IF NOT FOUND THEN
        -- Get available inventory records for better error message
        DECLARE
            available_records TEXT;
        BEGIN
            SELECT string_agg(
                format('Location: %s, Batch: %s, Qty: %s', 
                    location_id, 
                    COALESCE(batch_id::TEXT, 'NULL'), 
                    quantity
                ), 
                '; '
            ) INTO available_records
            FROM mod_wms.inventory
            WHERE article_id = NEW.article_id;
            
            error_message := format(
                'No inventory record found for Article ID: %s, Source Location ID: %s, Batch ID: %s. Cannot relocate quantity. Available inventory: %s',
                NEW.article_id, NEW.from_location_id, COALESCE(target_batch_id::TEXT, 'NULL'), 
                COALESCE(available_records, 'None')
            );
            RAISE EXCEPTION '%', error_message;
        END;
    END IF;

    -- Check if sufficient quantity is available in source location
    IF source_inventory_record.quantity < NEW.quantity_moved THEN
        error_message := format(
            'Insufficient quantity available for relocation. Article ID: %s, Source Location ID: %s, Batch ID: %s. Requested: %s, Available: %s.',
            NEW.article_id, NEW.from_location_id, COALESCE(source_inventory_record.batch_id::TEXT, 'NULL'), NEW.quantity_moved, source_inventory_record.quantity
        );
        RAISE EXCEPTION '%', error_message;
    END IF;

    -- Deduct quantity from the specific source inventory record using its ID
    UPDATE mod_wms.inventory
    SET quantity = quantity - NEW.quantity_moved,
        updated_at = NOW(),
        updated_by = NEW.updated_by
    WHERE id = source_inventory_record.id;

    -- Check if target location already has inventory for this article and batch
    SELECT * INTO target_inventory_record
    FROM mod_wms.inventory
    WHERE article_id = NEW.article_id
      AND location_id = NEW.to_location_id
      AND batch_id IS NOT DISTINCT FROM target_batch_id;

    -- If target location has existing inventory, add to it
    IF FOUND THEN
        UPDATE mod_wms.inventory
        SET quantity = quantity + NEW.quantity_moved,
            updated_at = NOW(),
            updated_by = NEW.updated_by
        WHERE id = target_inventory_record.id;
    ELSE
        -- If no existing inventory at target location, create new record
        INSERT INTO mod_wms.inventory (
            article_id, 
            location_id, 
            batch_id, 
            quantity, 
            allocated_qty, 
            domain_id, 
            created_by, 
            updated_by, 
            created_at, 
            updated_at
        ) VALUES (
            NEW.article_id, 
            NEW.to_location_id, 
            target_batch_id, 
            NEW.quantity_moved, 
            0, 
            NEW.domain_id, 
            NEW.created_by, 
            NEW.updated_by, 
            NOW(), 
            NOW()
        );
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_wms"."handle_relocation_stock_movement"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_wms"."handle_relocation_stock_movement"() IS 'Trigger function that automatically handles inventory updates when relocation stock movements are inserted. Deducts quantity from source location and adds to destination location. Ensures sufficient stock is available before relocation.';



CREATE OR REPLACE FUNCTION "mod_wms"."handle_shipment_items_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_wms"."handle_shipment_items_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."handle_shipments_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_wms"."handle_shipments_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."handle_shipments_outbound_on_status_change"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_item RECORD;
BEGIN
    -- Safety guard: only process when status changes to 'loaded'
    IF NEW.status IS DISTINCT FROM 'loaded' OR OLD.status = 'loaded' THEN
        RETURN NEW;
    END IF;

    -- Wrap entire logic in error handling to prevent transaction rollback
    BEGIN
        -- Loop through all shipment_items for this shipment
        FOR v_item IN 
            SELECT 
                id,
                article_id,
                batch_id,
                location_id,
                quantity_shipped,
                domain_id,
                created_by,
                updated_by
            FROM mod_wms.shipment_items
            WHERE shipment_id = NEW.id
              AND is_deleted = FALSE
        LOOP
            -- Skip items without location_id (non-manufactured items)
            IF v_item.location_id IS NULL THEN
                CONTINUE;
            END IF;

            BEGIN
                -- Insert corresponding outbound stock movement for each item
                INSERT INTO mod_wms.stock_movements (
                    article_id,
                    batch_id,
                    from_location_id,
                    to_location_id,
                    quantity_moved,
                    reason,
                    type,
                    domain_id,
                    created_by,
                    updated_by
                ) VALUES (
                    v_item.article_id,
                    v_item.batch_id,
                    v_item.location_id,        -- outbound from the shipment item's location
                    NULL,                       -- outbound has no to_location
                    v_item.quantity_shipped,    -- move the shipped quantity
                    'Uscita da spedizione ' || NEW.code,
                    'outbound',
                    v_item.domain_id,
                    v_item.created_by,
                    v_item.updated_by
                );
            EXCEPTION WHEN OTHERS THEN
                -- Log error for this specific item but continue processing other items
                -- This allows shipment status update to succeed even if stock movement creation fails
                RAISE WARNING 'Error creating outbound stock movement for shipment_item % (article_id: %, location_id: %): %', 
                    v_item.id, v_item.article_id, v_item.location_id, SQLERRM;
            END;
        END LOOP;

    EXCEPTION WHEN OTHERS THEN
        -- Log the error but don't abort the transaction
        -- This allows the shipment status update to complete even if stock movement creation fails
        RAISE WARNING 'Error in handle_shipments_outbound_on_status_change for shipment %: %', NEW.id, SQLERRM;
        -- Return NEW to allow the shipment status update to succeed
    END;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_wms"."handle_shipments_outbound_on_status_change"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_wms"."handle_shipments_outbound_on_status_change"() IS 'On update of shipments status to loaded, inserts outbound stock_movements rows for each shipment_item using quantity_shipped and location_id. Skips items without location_id (non-manufactured items). Includes error handling to prevent transaction rollback - shipment status update will succeed even if stock movement creation fails (e.g., missing inventory).';



CREATE OR REPLACE FUNCTION "mod_wms"."handle_stock_movements_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_wms"."handle_stock_movements_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."handle_transport_stock_movement"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    source_inventory RECORD;
    destination_inventory RECORD;
BEGIN
    -- Only process transport movements
    IF NEW.type != 'transport' THEN
        RETURN NEW;
    END IF;

    -- Check if both from_location_id and to_location_id are provided
    IF NEW.from_location_id IS NOT NULL AND NEW.to_location_id IS NOT NULL THEN
        -- Step 1: Check if source inventory exists and has enough quantity
        SELECT * INTO source_inventory
        FROM mod_wms.inventory
        WHERE article_id = NEW.article_id
          AND location_id = NEW.from_location_id
          AND (batch_id = NEW.batch_id OR (batch_id IS NULL AND NEW.batch_id IS NULL));

        -- If source inventory doesn't exist, raise an error
        IF NOT FOUND THEN
            RAISE EXCEPTION 'No inventory record found for Article ID: %, Location ID: %, Batch ID: %. Cannot deduct quantity.',
                NEW.article_id, NEW.from_location_id, NEW.batch_id;
        END IF;

        -- Check if there's enough quantity to deduct
        IF source_inventory.quantity < NEW.quantity_moved THEN
            RAISE EXCEPTION 'Insufficient quantity in source location. Available: %, Required: %',
                source_inventory.quantity, NEW.quantity_moved;
        END IF;

        -- Step 2: Deduct quantity from source location
        UPDATE mod_wms.inventory
        SET quantity = quantity - NEW.quantity_moved,
            updated_at = NOW(),
            updated_by = NEW.updated_by
        WHERE article_id = NEW.article_id
          AND location_id = NEW.from_location_id
          AND (batch_id = NEW.batch_id OR (batch_id IS NULL AND NEW.batch_id IS NULL));

        -- Step 3: Add quantity to destination location (UPSERT)
        -- Check if destination inventory record exists
        SELECT * INTO destination_inventory
        FROM mod_wms.inventory
        WHERE article_id = NEW.article_id
          AND location_id = NEW.to_location_id
          AND (batch_id = NEW.batch_id OR (batch_id IS NULL AND NEW.batch_id IS NULL));

        IF FOUND THEN
            -- Update existing record
            UPDATE mod_wms.inventory
            SET quantity = quantity + NEW.quantity_moved,
                updated_at = NOW(),
                updated_by = NEW.updated_by
            WHERE article_id = NEW.article_id
              AND location_id = NEW.to_location_id
              AND (batch_id = NEW.batch_id OR (batch_id IS NULL AND NEW.batch_id IS NULL));
        ELSE
            -- Insert new record
            INSERT INTO mod_wms.inventory (
                article_id,
                location_id,
                batch_id,
                quantity,
                allocated_qty,
                domain_id,
                created_by,
                updated_by,
                created_at,
                updated_at
            ) VALUES (
                NEW.article_id,
                NEW.to_location_id,
                NEW.batch_id,
                NEW.quantity_moved,
                0, -- Start with 0 allocated quantity
                NEW.domain_id,
                NEW.created_by,
                NEW.updated_by,
                NOW(),
                NOW()
            );
        END IF;

    ELSE
        -- Fallback: Only add to destination (original behavior)
        -- This handles cases where only to_location_id is provided
        -- Check if destination inventory record exists
        SELECT * INTO destination_inventory
        FROM mod_wms.inventory
        WHERE article_id = NEW.article_id
          AND location_id = NEW.to_location_id
          AND (batch_id = NEW.batch_id OR (batch_id IS NULL AND NEW.batch_id IS NULL));

        IF FOUND THEN
            -- Update existing record
            UPDATE mod_wms.inventory
            SET quantity = quantity + NEW.quantity_moved,
                updated_at = NOW(),
                updated_by = NEW.updated_by
            WHERE article_id = NEW.article_id
              AND location_id = NEW.to_location_id
              AND (batch_id = NEW.batch_id OR (batch_id IS NULL AND NEW.batch_id IS NULL));
        ELSE
            -- Insert new record
            INSERT INTO mod_wms.inventory (
                article_id,
                location_id,
                batch_id,
                quantity,
                allocated_qty,
                domain_id,
                created_by,
                updated_by,
                created_at,
                updated_at
            ) VALUES (
                NEW.article_id,
                NEW.to_location_id,
                NEW.batch_id,
                NEW.quantity_moved,
                0, -- Start with 0 allocated quantity
                NEW.domain_id,
                NEW.created_by,
                NEW.updated_by,
                NOW(),
                NOW()
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_wms"."handle_transport_stock_movement"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_wms"."handle_transport_stock_movement"() IS 'Trigger function that automatically updates inventory table when transport stock movements are inserted. For transport movements with both from_location_id and to_location_id: deducts quantity from source location and adds to destination location. For transport movements with only to_location_id: adds quantity to destination location. Handles both batched and non-batched inventory scenarios with proper error handling.';



CREATE OR REPLACE FUNCTION "mod_wms"."handle_update_sales_order_items_is_shipped_on_loaded"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_shipment_item RECORD;
    v_sales_order_ids UUID[];
    v_sales_order_id UUID;
BEGIN
    -- Safety guard: only process when status changes to 'loaded'
    IF NEW.status IS DISTINCT FROM 'loaded' OR OLD.status = 'loaded' THEN
        RETURN NEW;
    END IF;

    -- Wrap the entire update logic in error handling to prevent transaction rollback
    BEGIN
        -- Get sales order IDs from junction table
        BEGIN
            SELECT ARRAY_AGG(sales_order_id) INTO v_sales_order_ids
            FROM mod_wms.shipment_sales_orders
            WHERE shipment_id = NEW.id;
        EXCEPTION WHEN OTHERS THEN
            -- Log error but continue with fallback
            RAISE WARNING 'Error getting sales order IDs from junction table for shipment %: %', NEW.id, SQLERRM;
            v_sales_order_ids := NULL;
        END;

        -- Fallback: If no junction records found, use shipment.sales_order_id
        IF v_sales_order_ids IS NULL OR array_length(v_sales_order_ids, 1) IS NULL THEN
            IF NEW.sales_order_id IS NOT NULL THEN
                v_sales_order_ids := ARRAY[NEW.sales_order_id];
            ELSE
                -- No sales orders linked, nothing to update
                RETURN NEW;
            END IF;
        END IF;

        -- Loop through all shipment_items for this shipment
        FOR v_shipment_item IN 
            SELECT 
                article_id
            FROM mod_wms.shipment_items
            WHERE shipment_id = NEW.id
              AND is_deleted = FALSE
        LOOP
            BEGIN
                -- Update sales_order_items where:
                -- - sales_order_id matches one of the linked sales orders
                -- - article_id matches the shipment_item's article_id
                -- - is_deleted = false
                UPDATE mod_base.sales_order_items
                SET 
                    is_shipped = TRUE,
                    updated_at = NOW()
                WHERE sales_order_id = ANY(v_sales_order_ids)
                  AND article_id = v_shipment_item.article_id
                  AND is_deleted = FALSE
                  AND is_shipped = FALSE; -- Only update if not already set to avoid unnecessary updates
            EXCEPTION WHEN OTHERS THEN
                -- Log error for this specific item but continue processing other items
                RAISE WARNING 'Error updating is_shipped for sales_order_item (article_id: %, sales_order_ids: %): %', 
                    v_shipment_item.article_id, v_sales_order_ids, SQLERRM;
            END;
        END LOOP;

    EXCEPTION WHEN OTHERS THEN
        -- Log the error but don't abort the transaction
        -- This allows the shipment status update to complete even if updating is_shipped fails
        RAISE WARNING 'Error in handle_update_sales_order_items_is_shipped_on_loaded for shipment %: %', NEW.id, SQLERRM;
        -- Return NEW to allow the shipment status update to succeed
    END;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_wms"."handle_update_sales_order_items_is_shipped_on_loaded"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_wms"."handle_update_sales_order_items_is_shipped_on_loaded"() IS 'On update of shipments status to loaded, updates is_shipped = TRUE on sales_order_items that match the shipment_items by article_id and sales_order_id (from junction table or direct relationship). Includes error handling to prevent transaction rollback - shipment status update will succeed even if updating is_shipped fails.';



CREATE OR REPLACE FUNCTION "mod_wms"."handle_warehouses_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if TG_OP = 'INSERT' then
    -- If the INSERT doesn't explicitly provide created_by,
    -- default to the user performing this operation.
    new.created_by := coalesce(
      new.created_by,
      auth.uid()
    );
  
  elsif TG_OP = 'UPDATE' then
    -- On UPDATE, set the user performing this operation and the updated timestamp
    new.updated_by := auth.uid();
    new.updated_at := now();
  end if;

  return new;
end;
$$;


ALTER FUNCTION "mod_wms"."handle_warehouses_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."receipt_items_notification_for_serena"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  notification_name TEXT;
  notification_description TEXT;
  receipt_name TEXT;
  article_name TEXT;
  discrepancy_message TEXT;
  should_notify BOOLEAN := FALSE;
BEGIN
  -- Initialize discrepancy_message
  discrepancy_message := '';
  
  -- Check if we need to send a notification
  -- Condition 1: quantity_received is different from quantity_ordered
  IF NEW.quantity_received IS DISTINCT FROM NEW.quantity_ordered THEN
    should_notify := TRUE;
    IF NEW.quantity_received < NEW.quantity_ordered THEN
      discrepancy_message := 'Quantità ricevuta (' || NEW.quantity_received::text || ') inferiore alla quantità ordinata (' || NEW.quantity_ordered::text || ')';
    ELSIF NEW.quantity_received > NEW.quantity_ordered THEN
      discrepancy_message := 'Quantità ricevuta (' || NEW.quantity_received::text || ') superiore alla quantità ordinata (' || NEW.quantity_ordered::text || ')';
    END IF;
  END IF;
  
  -- Condition 2: quantity_damaged is greater than 0
  IF COALESCE(NEW.quantity_damaged, 0) > 0 THEN
    should_notify := TRUE;
    IF discrepancy_message != '' THEN
      discrepancy_message := discrepancy_message || ' e ' || NEW.quantity_damaged::text || ' articoli danneggiati';
    ELSE
      discrepancy_message := NEW.quantity_damaged::text || ' articoli danneggiati';
    END IF;
  END IF;
  
  -- Only proceed if we need to send a notification
  IF should_notify THEN
    -- Get the receipt name for context
    SELECT r.name INTO receipt_name
    FROM mod_wms.receipts r
    WHERE r.id = NEW.receipt_id;
    
    -- Get the article name for context
    SELECT a.name INTO article_name 
    FROM mod_base.articles a
    WHERE a.id = NEW.article_id;
    
    -- Create notification name and description
    notification_name := 'Discrepanza Ricevimento: ' || COALESCE(article_name, NEW.name);
    notification_description := 'Nel ricevimento "' || COALESCE(receipt_name, 'Ricevimento Sconosciuto') || 
                                '" - Articolo "' || COALESCE(article_name, NEW.name) || 
                                '" - ' || discrepancy_message;
    
    -- Insert notification for Serena
    INSERT INTO mod_pulse.notifications (
      name,
      description,
      type,
      user_id,
      created_by,
      domain_id,
      department_id
    ) VALUES (
      notification_name,
      notification_description,
      'update_pulse',
      '0d26df09-2cf1-4b69-89ca-668db5201153'::uuid, -- FABRIZIO's UUID
      NEW.created_by,
      NEW.domain_id,
      NULL -- department_id - can be set later if needed
    );
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_wms"."receipt_items_notification_for_serena"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_wms"."receipt_items_notification_for_serena"() IS 'Creates notifications for Serena when receipt items are inserted with quantity discrepancies (quantity_received != quantity_ordered) or when quantity_damaged > 0. Queries receipts and articles tables for context.';



CREATE OR REPLACE FUNCTION "mod_wms"."set_receipt_number_on_insert"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF NEW.receipt_number IS NULL OR TRIM(NEW.receipt_number) = '' THEN
    NEW.receipt_number := mod_wms.generate_unique_receipt_number();
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_wms"."set_receipt_number_on_insert"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."update_sales_order_items_has_shipment"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  shipment_record RECORD;
  sales_order_ids UUID[];
  shipment_item_record RECORD;
  v_shipment_id UUID;
  v_article_id UUID;
BEGIN
  -- Determine shipment_id and article_id based on which table triggered this
  IF TG_TABLE_NAME = 'shipments' THEN
    -- Triggered from shipments INSERT
    v_shipment_id := NEW.id;
    v_article_id := NULL; -- Will process all items
  ELSIF TG_TABLE_NAME = 'shipment_items' THEN
    -- Triggered from shipment_items INSERT
    v_shipment_id := NEW.shipment_id;
    v_article_id := NEW.article_id; -- Process specific article
  ELSE
    RAISE WARNING 'Unexpected table name in trigger: %', TG_TABLE_NAME;
    RETURN NEW;
  END IF;

  -- Wrap entire logic in error handling to prevent transaction rollback
  BEGIN
    -- Get the shipment record
    BEGIN
      SELECT * INTO shipment_record
      FROM mod_wms.shipments
      WHERE id = v_shipment_id;
    EXCEPTION WHEN OTHERS THEN
      RAISE WARNING 'Error fetching shipment record for shipment_id %: %', v_shipment_id, SQLERRM;
      RETURN NEW;
    END;

    -- If shipment doesn't exist, return
    IF NOT FOUND THEN
      RAISE WARNING 'Shipment % not found', v_shipment_id;
      RETURN NEW;
    END IF;

    -- Get sales order IDs from junction table
    BEGIN
      SELECT ARRAY_AGG(sales_order_id) INTO sales_order_ids
      FROM mod_wms.shipment_sales_orders
      WHERE shipment_id = v_shipment_id;
    EXCEPTION WHEN OTHERS THEN
      RAISE WARNING 'Error getting sales order IDs from junction table for shipment %: %', v_shipment_id, SQLERRM;
      sales_order_ids := NULL;
    END;

    -- Fallback: If no junction records found, use shipment.sales_order_id
    IF sales_order_ids IS NULL OR array_length(sales_order_ids, 1) IS NULL THEN
      IF shipment_record.sales_order_id IS NOT NULL THEN
        sales_order_ids := ARRAY[shipment_record.sales_order_id];
        RAISE NOTICE 'Using fallback sales_order_id: %', shipment_record.sales_order_id;
      ELSE
        -- No sales orders linked, nothing to update
        RAISE NOTICE 'No sales orders linked to shipment %', v_shipment_id;
        RETURN NEW;
      END IF;
    END IF;

    RAISE NOTICE 'Processing shipment % with sales_order_ids: %', v_shipment_id, sales_order_ids;

    -- Process shipment_items
    -- If triggered from shipment_items INSERT, only process that specific article
    -- Otherwise, process all shipment_items for this shipment
    FOR shipment_item_record IN
      SELECT DISTINCT article_id
      FROM mod_wms.shipment_items
      WHERE shipment_id = v_shipment_id
        AND is_deleted = false
        AND (v_article_id IS NULL OR article_id = v_article_id)
    LOOP
      BEGIN
        -- Update sales_order_items where:
        -- - sales_order_id matches one of the linked sales orders
        -- - article_id matches the shipment_item's article_id
        -- - is_deleted = false
        UPDATE mod_base.sales_order_items
        SET 
          has_shipment = TRUE,
          updated_at = NOW()
        WHERE sales_order_id = ANY(sales_order_ids)
          AND article_id = shipment_item_record.article_id
          AND is_deleted = false
          AND has_shipment = false; -- Only update if not already set to avoid unnecessary updates;

        IF FOUND THEN
          RAISE NOTICE 'Updated has_shipment = TRUE for sales_order_items with sales_order_id IN % AND article_id = %', 
                       sales_order_ids, shipment_item_record.article_id;
        ELSE
          RAISE NOTICE 'No matching sales_order_items found for sales_order_id IN % AND article_id = %', 
                       sales_order_ids, shipment_item_record.article_id;
        END IF;
      EXCEPTION WHEN OTHERS THEN
        -- Log error for this specific item but continue processing other items
        RAISE WARNING 'Error updating has_shipment for sales_order_item (article_id: %, sales_order_ids: %): %', 
            shipment_item_record.article_id, sales_order_ids, SQLERRM;
      END;
    END LOOP;

  EXCEPTION WHEN OTHERS THEN
    -- Log the error but don't abort the transaction
    -- This allows the shipment/shipment_item creation to complete even if updating has_shipment fails
    RAISE WARNING 'Error in update_sales_order_items_has_shipment for shipment %: %', v_shipment_id, SQLERRM;
    -- Return NEW to allow the shipment/shipment_item creation to succeed
  END;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_wms"."update_sales_order_items_has_shipment"() OWNER TO "postgres";


COMMENT ON FUNCTION "mod_wms"."update_sales_order_items_has_shipment"() IS 'Updates has_shipment flag on sales_order_items when a new shipment is created or shipment_items are added. Matches shipment_items by article_id to sales_order_items in linked sales orders. Includes error handling to prevent transaction rollback.';



CREATE OR REPLACE FUNCTION "mod_wms"."update_shipment_attachments_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_wms"."update_shipment_attachments_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."update_shipment_item_addresses_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_wms"."update_shipment_item_addresses_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."update_shipment_sales_orders_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "mod_wms"."update_shipment_sales_orders_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "mod_wms"."upsert_item_address"("p_shipment_item_id" "uuid", "p_address_type" character varying, "p_address" "text", "p_city" "text", "p_state" "text", "p_zip" "text" DEFAULT NULL::"text", "p_country" "text" DEFAULT NULL::"text", "p_province" "text" DEFAULT NULL::"text", "p_is_primary" boolean DEFAULT false, "p_notes" "text" DEFAULT NULL::"text") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "mod_wms"."upsert_item_address"("p_shipment_item_id" "uuid", "p_address_type" character varying, "p_address" "text", "p_city" "text", "p_state" "text", "p_zip" "text", "p_country" "text", "p_province" "text", "p_is_primary" boolean, "p_notes" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."add_article_related_search_results"("search_query" "text", "limit_count" integer DEFAULT 50) RETURNS TABLE("table_name" "text", "schema_name" "text", "id" "text", "title" "text", "description" "text", "url" "text", "rank" real)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."add_article_related_search_results"("search_query" "text", "limit_count" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_user_sales_orders_access"() RETURNS TABLE("user_id" "uuid", "domain_id" "uuid", "role" "text", "jwt_domain_id" "text", "jwt_role" "text", "can_access_sales_orders" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT 
    auth.uid() as user_id,
    du.domain_id,
    du.role,
    get_my_claim_text('domain_id') as jwt_domain_id,
    get_my_claim_text('role') as jwt_role,
    CASE 
      WHEN du.user_id IS NOT NULL THEN true
      WHEN get_my_claim_text('role') = 'superAdmin' THEN true
      ELSE false
    END as can_access_sales_orders
  FROM mod_admin.domain_users du
  WHERE du.user_id = auth.uid()
  UNION ALL
  SELECT 
    auth.uid() as user_id,
    NULL::uuid as domain_id,
    NULL::text as role,
    get_my_claim_text('domain_id') as jwt_domain_id,
    get_my_claim_text('role') as jwt_role,
    CASE 
      WHEN get_my_claim_text('role') = 'superAdmin' THEN true
      ELSE false
    END as can_access_sales_orders
  WHERE NOT EXISTS (
    SELECT 1 FROM mod_admin.domain_users du WHERE du.user_id = auth.uid()
  );
END;
$$;


ALTER FUNCTION "public"."check_user_sales_orders_access"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_claim"("uid" "uuid", "claim" "text") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN 'error: access denied';
      ELSE        
        update auth.users set raw_app_meta_data = 
          raw_app_meta_data - claim where id = uid;
        return 'OK';
      END IF;
    END;
$$;


ALTER FUNCTION "public"."delete_claim"("uid" "uuid", "claim" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_unique_receipt_number"() RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."generate_unique_receipt_number"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_active_departments"() RETURNS TABLE("id" "uuid", "name" character varying)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT d.id, d.name::varchar
  FROM mod_base.departments d
  WHERE NOT d.is_deleted
  ORDER BY d.name;
END;
$$;


ALTER FUNCTION "public"."get_active_departments"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_active_departments"() IS 'Returns active departments from mod_base schema.';



CREATE OR REPLACE FUNCTION "public"."get_claim"("uid" "uuid", "claim" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
    DECLARE retval jsonb;
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN '{"error":"access denied"}'::jsonb;
      ELSE
        select coalesce(raw_app_meta_data->claim, null) from auth.users into retval where id = uid::uuid;
        return retval;
      END IF;
    END;
$$;


ALTER FUNCTION "public"."get_claim"("uid" "uuid", "claim" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_claims"("uid" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
    DECLARE retval jsonb;
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN '{"error":"access denied"}'::jsonb;
      ELSE
        select raw_app_meta_data from auth.users into retval where id = uid::uuid;
        return retval;
      END IF;
    END;
$$;


ALTER FUNCTION "public"."get_claims"("uid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_employees_with_details"() RETURNS TABLE("id" "uuid", "name" character varying, "last_name" character varying, "description" character varying, "email" character varying, "phone" character varying, "department_names" character varying[])
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT 
    e.id,
    e.name::varchar,
    e.last_name::varchar,
    e.description::varchar,
    COALESCE(u.email, 'No email')::varchar as email,
    COALESCE(e.phone, 'No phone')::varchar as phone,
    COALESCE(
      ARRAY_AGG(d.name::varchar) FILTER (WHERE d.name IS NOT NULL), 
      ARRAY[]::varchar[]
    ) as department_names
  FROM mod_base.employees e
  LEFT JOIN auth.users u ON e.id = u.id
  LEFT JOIN mod_base.employees_departments ed ON e.id = ed.employee_id AND ed.is_deleted = false
  LEFT JOIN mod_base.departments d ON ed.department_id = d.id AND d.is_deleted = false
  WHERE e.is_deleted = false
  GROUP BY e.id, e.name, e.last_name, e.description, u.email, e.phone
  ORDER BY e.created_at DESC;
END;
$$;


ALTER FUNCTION "public"."get_employees_with_details"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_employees_with_details"() IS 'Returns employees with their user email and department assignments. Joins employees, auth.users, and departments tables.';



CREATE OR REPLACE FUNCTION "public"."get_jwt_claim_domain_id"() RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN get_my_claim('domain_id');
END;
$$;


ALTER FUNCTION "public"."get_jwt_claim_domain_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_claim"("claim" "text") RETURNS "jsonb"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  	coalesce(nullif(current_setting('request.jwt.claims', true), '')::jsonb -> 'app_metadata' -> claim, null)
$$;


ALTER FUNCTION "public"."get_my_claim"("claim" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_claim_text"("claim" "text") RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
  SELECT 
    trim(both '\"' from coalesce(nullif(current_setting('request.jwt.claims', true), '')::jsonb -> 'app_metadata' -> claim, null)::text)
$$;


ALTER FUNCTION "public"."get_my_claim_text"("claim" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_claims"() RETURNS "jsonb"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  	coalesce(nullif(current_setting('request.jwt.claims', true), '')::jsonb -> 'app_metadata', '{}'::jsonb)::jsonb
$$;


ALTER FUNCTION "public"."get_my_claims"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_search_suggestions"("search_query" "text", "limit_count" integer DEFAULT 10) RETURNS TABLE("suggestion" "text", "type" "text", "count" bigint)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."get_search_suggestions"("search_query" "text", "limit_count" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_notifications"("p_limit" integer DEFAULT 50, "p_offset" integer DEFAULT 0, "p_is_read" boolean DEFAULT NULL::boolean) RETURNS TABLE("id" "uuid", "name" "text", "description" "text", "code" "text", "type" "text", "is_read" boolean, "avatar_url" "text", "barcode" "text", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "created_by" "uuid", "updated_by" "uuid", "pulse_id" "uuid", "total_count" bigint)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  current_user_id UUID;
  total_notifications BIGINT;
BEGIN
  -- Get the current authenticated user ID
  current_user_id := auth.uid();
  
  -- If no user is authenticated, return empty result
  IF current_user_id IS NULL THEN
    RETURN;
  END IF;
  
  -- Get total count for pagination
  SELECT COUNT(*) INTO total_notifications
  FROM mod_pulse.notifications
  WHERE user_id = current_user_id
    AND is_deleted = false
    AND (p_is_read IS NULL OR is_read = p_is_read);
  
  -- Return notifications with pagination
  RETURN QUERY
  SELECT 
    n.id,
    n.name,
    n.description,
    n.code,
    n.type,
    n.is_read,
    n.avatar_url,
    n.barcode,
    n.created_at,
    n.updated_at,
    n.created_by,
    n.updated_by,
    n.pulse_id,
    total_notifications
  FROM mod_pulse.notifications n
  WHERE n.user_id = current_user_id
    AND n.is_deleted = false
    AND (p_is_read IS NULL OR n.is_read = p_is_read)
  ORDER BY n.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;


ALTER FUNCTION "public"."get_user_notifications"("p_limit" integer, "p_offset" integer, "p_is_read" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_page_access"("user_department_ids" "uuid"[]) RETURNS TABLE("page_id" "uuid", "page_name" "text", "page_path" "text", "page_title" "text", "is_restricted" boolean, "has_access" boolean, "is_visible" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id as page_id,
        p.name as page_name,
        p.path as page_path,
        p.title as page_title,
        CASE 
            WHEN pd.page_id IS NOT NULL THEN true 
            ELSE false 
        END as is_restricted,
        CASE 
            WHEN pd.page_id IS NOT NULL AND pd.department_id = ANY(user_department_ids) THEN true
            WHEN pd.page_id IS NULL THEN true  -- Unrestricted pages are accessible
            ELSE false
        END as has_access,
        COALESCE(p.is_visible, true) as is_visible  -- Default to true if null
    FROM mod_datalayer.pages p
    LEFT JOIN mod_datalayer.pages_departments pd ON p.id = pd.page_id
    WHERE COALESCE(p.is_visible, true) = true;  -- Only return visible pages
END;
$$;


ALTER FUNCTION "public"."get_user_page_access"("user_department_ids" "uuid"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."global_search"("search_query" "text", "limit_count" integer DEFAULT 50) RETURNS TABLE("table_name" "text", "schema_name" "text", "id" "text", "title" "text", "description" "text", "url" "text", "rank" real)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."global_search"("search_query" "text", "limit_count" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_claims_admin"() RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
  BEGIN
    IF session_user = 'authenticator' THEN
      --------------------------------------------
      -- To disallow any authenticated app users
      -- from editing claims, delete the following
      -- block of code and replace it with:
      -- RETURN FALSE;
      --------------------------------------------
      IF extract(epoch from now()) > coalesce((current_setting('request.jwt.claims', true)::jsonb)->>'exp', '0')::numeric THEN
        return false; -- jwt expired
      END IF;
      If current_setting('request.jwt.claims', true)::jsonb->>'role' = 'service_role' THEN
        RETURN true; -- service role users have admin rights
      END IF;
      IF coalesce((current_setting('request.jwt.claims', true)::jsonb)->'app_metadata'->'claims_admin', 'false')::bool THEN
        return true; -- user has claims_admin set to true
      ELSE
        return false; -- user does NOT have claims_admin set to true
      END IF;
      --------------------------------------------
      -- End of block 
      --------------------------------------------
    ELSE -- not a user session, probably being called from a trigger or something
      return true;
    END IF;
  END;
$$;


ALTER FUNCTION "public"."is_claims_admin"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mark_all_notifications_as_read"() RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  current_user_id UUID;
  updated_rows INTEGER;
BEGIN
  -- Get the current authenticated user ID
  current_user_id := auth.uid();
  
  -- If no user is authenticated, return 0
  IF current_user_id IS NULL THEN
    RETURN 0;
  END IF;
  
  -- Update all unread notifications as read
  UPDATE mod_pulse.notifications
  SET is_read = TRUE,
      updated_at = NOW(),
      updated_by = current_user_id
  WHERE user_id = current_user_id
    AND is_deleted = false
    AND is_read = FALSE;
  
  -- Get the number of updated rows
  GET DIAGNOSTICS updated_rows = ROW_COUNT;
  
  RETURN updated_rows;
END;
$$;


ALTER FUNCTION "public"."mark_all_notifications_as_read"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."mark_notification_as_read"("p_notification_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  current_user_id UUID;
  updated_rows INTEGER;
BEGIN
  -- Get the current authenticated user ID
  current_user_id := auth.uid();
  
  -- If no user is authenticated, return false
  IF current_user_id IS NULL THEN
    RETURN FALSE;
  END IF;
  
  -- Update the notification as read
  UPDATE mod_pulse.notifications
  SET is_read = TRUE,
      updated_at = NOW(),
      updated_by = current_user_id
  WHERE id = p_notification_id
    AND user_id = current_user_id
    AND is_deleted = false;
  
  -- Check if any rows were updated
  GET DIAGNOSTICS updated_rows = ROW_COUNT;
  
  RETURN updated_rows > 0;
END;
$$;


ALTER FUNCTION "public"."mark_notification_as_read"("p_notification_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."my_set_config"("key" "text", "value" "text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
begin
  perform set_config(key, value, false);
end;
$$;


ALTER FUNCTION "public"."my_set_config"("key" "text", "value" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."safe_alter_enum_type"("p_type_name" "text", "p_new_values" "text"[]) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_existing_values text[];
    v_value text;
BEGIN
    -- Get existing enum values
    SELECT array_agg(enumlabel::text ORDER BY enumsortorder)
    INTO v_existing_values
    FROM pg_enum
    WHERE enumtypid = (SELECT oid FROM pg_type WHERE typname = p_type_name);

    -- Add new values that don't exist
    FOREACH v_value IN ARRAY p_new_values LOOP
        IF NOT v_value = ANY(v_existing_values) THEN
            EXECUTE 'ALTER TYPE ' || p_type_name || ' ADD VALUE ''' || v_value || '''';
        END IF;
    END LOOP;
END;
$$;


ALTER FUNCTION "public"."safe_alter_enum_type"("p_type_name" "text", "p_new_values" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."search_menu_items"("search_query" "text", "domain_id" "text" DEFAULT NULL::"text") RETURNS TABLE("id" "text", "title" "text", "path" "text", "icon" "text", "menu_type" "text", "rank" real)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."search_menu_items"("search_query" "text", "domain_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_claim"("uid" "uuid", "claim" "text", "value" "jsonb") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN 'error: access denied';
      ELSE        
        update auth.users set raw_app_meta_data = 
          raw_app_meta_data || 
            json_build_object(claim, value)::jsonb where id = uid;
        return 'OK';
      END IF;
    END;
$$;


ALTER FUNCTION "public"."set_claim"("uid" "uuid", "claim" "text", "value" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."simple_global_search"("search_query" "text", "limit_count" integer DEFAULT 50) RETURNS TABLE("table_name" "text", "schema_name" "text", "id" "text", "title" "text", "description" "text", "url" "text", "rank" real)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."simple_global_search"("search_query" "text", "limit_count" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."simple_menu_search"("search_query" "text") RETURNS TABLE("id" "text", "title" "text", "path" "text", "icon" "text", "menu_type" "text", "rank" real)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."simple_menu_search"("search_query" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."test_search_functions"() RETURNS TABLE("function_name" "text", "status" "text", "result_count" bigint)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."test_search_functions"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_expected_delivery_date"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    latest_production_date DATE;
    current_expected_date DATE;
    new_expected_date DATE;
BEGIN
    -- Only proceed if production_date has changed
    IF (TG_OP = 'UPDATE' AND OLD.production_date = NEW.production_date) THEN
        RETURN NEW;
    END IF;
    
    -- Skip if production_date is being set to NULL
    IF (TG_OP = 'UPDATE' AND NEW.production_date IS NULL) THEN
        RETURN NEW;
    END IF;
    
    -- Skip if production_date is NULL in INSERT
    IF (TG_OP = 'INSERT' AND NEW.production_date IS NULL) THEN
        RETURN NEW;
    END IF;
    
    -- Get the current expected_delivery_date from sales_orders
    SELECT expected_delivery_date INTO current_expected_date
    FROM mod_base.sales_orders
    WHERE id = NEW.sales_order_id;
    
    -- Find the latest production_date among all items in this sales_order
    -- that have a production_date set
    SELECT MAX(production_date) INTO latest_production_date
    FROM mod_base.sales_order_items
    WHERE sales_order_id = NEW.sales_order_id
      AND production_date IS NOT NULL
      AND is_deleted = false;
    
    -- Only update if we found a valid production_date
    IF latest_production_date IS NOT NULL THEN
        -- If there's no current expected_delivery_date, set it to the latest production_date
        IF current_expected_date IS NULL THEN
            new_expected_date := latest_production_date;
        ELSE
            -- Compare dates and use the later one
            IF latest_production_date > current_expected_date THEN
                new_expected_date := latest_production_date;
            ELSE
                -- No update needed, keep current date
                RETURN NEW;
            END IF;
        END IF;
        
        -- Update the sales_order with the new expected_delivery_date
        UPDATE mod_base.sales_orders
        SET expected_delivery_date = new_expected_date,
            updated_at = NOW()
        WHERE id = NEW.sales_order_id;
        
        -- Log the update for debugging (optional)
        RAISE NOTICE 'Updated expected_delivery_date for sales_order % from % to %', 
            NEW.sales_order_id, current_expected_date, new_expected_date;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_expected_delivery_date"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_receipt_supplier_from_po"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- If purchase_order_id is set and supplier_id is not set, get supplier from PO
  IF NEW.purchase_order_id IS NOT NULL AND NEW.supplier_id IS NULL THEN
    SELECT supplier_id INTO NEW.supplier_id
    FROM mod_base.purchase_orders
    WHERE id = NEW.purchase_order_id;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_receipt_supplier_from_po"() OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "app_auth"."employees_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "app_auth"."employees_code_seq" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "app_auth"."user_profiles_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "app_auth"."user_profiles_code_seq" OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "mod_admin"."domain_modules" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "domain_id" "uuid" NOT NULL,
    "module_id" "uuid" NOT NULL,
    "is_enabled" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_admin"."domain_modules" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_admin"."domain_users" (
    "user_id" "uuid" NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "role" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "domain_users_role_check" CHECK (("role" = ANY (ARRAY['superAdmin'::"text", 'admin'::"text", 'user'::"text", 'guest'::"text"])))
);


ALTER TABLE "mod_admin"."domain_users" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_admin"."domains" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "key" "text" NOT NULL,
    "description" "text",
    "modules" "text" NOT NULL,
    "productName" "text" NOT NULL,
    "productDescription" "text" NOT NULL,
    "folder" "text" NOT NULL,
    "sort" integer DEFAULT 0 NOT NULL,
    "deployable" boolean DEFAULT false,
    "deployUrl" "text",
    "parent_domain_id" "uuid",
    "avatar_url" "text",
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("key", ''::"text")) || ' '::"text") || COALESCE("description", ''::"text")) || ' '::"text") || COALESCE("productName", ''::"text")) || ' '::"text") || COALESCE("productDescription", ''::"text")))) STORED
);


ALTER TABLE "mod_admin"."domains" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_admin"."user_profiles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "firstName" "text" DEFAULT '-'::"text",
    "lastName" "text" DEFAULT '-'::"text",
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "phone" "text" DEFAULT ''::"text" NOT NULL,
    "mobile" "text" DEFAULT ''::"text" NOT NULL,
    "company" "text" DEFAULT ''::"text" NOT NULL,
    "contact" "text" DEFAULT ''::"text" NOT NULL,
    "enabled" boolean DEFAULT false,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "background_image_url" "text" DEFAULT ''::"text" NOT NULL,
    "address" "text" DEFAULT ''::"text",
    "city" "text" DEFAULT ''::"text",
    "province" "text" DEFAULT ''::"text",
    "zip_code" "text" DEFAULT ''::"text",
    "country" "text" DEFAULT ''::"text",
    "button_color" "text" DEFAULT 'primary'::"text" NOT NULL,
    "theme_mode" "text" DEFAULT 'auto'::"text" NOT NULL,
    "custom_primary_color" "text",
    "custom_secondary_color" "text",
    "custom_tertiary_color" "text",
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((((((((COALESCE("firstName", ''::"text") || ' '::"text") || COALESCE("lastName", ''::"text")) || ' '::"text") || COALESCE("phone", ''::"text")) || ' '::"text") || COALESCE("mobile", ''::"text")) || ' '::"text") || COALESCE("company", ''::"text")) || ' '::"text") || COALESCE("description", ''::"text")))) STORED,
    "sidebar_right_open" boolean DEFAULT true NOT NULL,
    CONSTRAINT "button_color_check" CHECK (("button_color" = ANY (ARRAY['primary'::"text", 'secondary'::"text", 'tertiary'::"text"]))),
    CONSTRAINT "custom_primary_color_hex_check" CHECK ((("custom_primary_color" IS NULL) OR ("custom_primary_color" ~ '^#[0-9A-Fa-f]{6}$'::"text"))),
    CONSTRAINT "custom_secondary_color_hex_check" CHECK ((("custom_secondary_color" IS NULL) OR ("custom_secondary_color" ~ '^#[0-9A-Fa-f]{6}$'::"text"))),
    CONSTRAINT "custom_tertiary_color_hex_check" CHECK ((("custom_tertiary_color" IS NULL) OR ("custom_tertiary_color" ~ '^#[0-9A-Fa-f]{6}$'::"text"))),
    CONSTRAINT "firstName_length" CHECK (("char_length"("firstName") >= 1)),
    CONSTRAINT "lastName_length" CHECK (("char_length"("lastName") >= 1)),
    CONSTRAINT "theme_mode_check" CHECK (("theme_mode" = ANY (ARRAY['light'::"text", 'dark'::"text", 'auto'::"text"]))),
    CONSTRAINT "user_profiles_name_check" CHECK (((("char_length"("firstName") >= 1) OR ("firstName" IS NULL)) AND (("char_length"("lastName") >= 1) OR ("lastName" IS NULL))))
);


ALTER TABLE "mod_admin"."user_profiles" OWNER TO "postgres";


COMMENT ON COLUMN "mod_admin"."user_profiles"."address" IS 'User address from registration form';



COMMENT ON COLUMN "mod_admin"."user_profiles"."city" IS 'User city from registration form';



COMMENT ON COLUMN "mod_admin"."user_profiles"."province" IS 'User province/state from registration form';



COMMENT ON COLUMN "mod_admin"."user_profiles"."zip_code" IS 'User zip/postal code from registration form';



COMMENT ON COLUMN "mod_admin"."user_profiles"."country" IS 'User country from registration form';



COMMENT ON COLUMN "mod_admin"."user_profiles"."button_color" IS 'User preference for button color theme: primary, secondary, or tertiary';



COMMENT ON COLUMN "mod_admin"."user_profiles"."theme_mode" IS 'User preference for theme mode: light, dark, or auto';



COMMENT ON COLUMN "mod_admin"."user_profiles"."custom_primary_color" IS 'User custom primary button color as hex value (e.g., #1976d2)';



COMMENT ON COLUMN "mod_admin"."user_profiles"."custom_secondary_color" IS 'User custom secondary button color as hex value (e.g., #26a69a)';



COMMENT ON COLUMN "mod_admin"."user_profiles"."custom_tertiary_color" IS 'User custom tertiary button color as hex value (e.g., #9c27b0)';



COMMENT ON COLUMN "mod_admin"."user_profiles"."sidebar_right_open" IS 'User preference for right sidebar visibility: true = open, false = closed';



CREATE OR REPLACE VIEW "mod_admin"."user_domain_info_view" WITH ("security_invoker"='on') AS
 SELECT "up"."lastName",
    "up"."firstName",
    "u"."email",
    "u"."id" AS "user_id",
    "d"."name" AS "domain_name",
    "d"."id" AS "domain_id"
   FROM ((("mod_admin"."user_profiles" "up"
     JOIN "auth"."users" "u" ON (("up"."id" = "u"."id")))
     JOIN "mod_admin"."domain_users" "du" ON (("du"."user_id" = "u"."id")))
     JOIN "mod_admin"."domains" "d" ON (("du"."domain_id" = "d"."id")))
  WHERE (("up"."is_deleted" = false) AND ("d"."is_deleted" = false));


ALTER VIEW "mod_admin"."user_domain_info_view" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "mod_admin"."user_profiles_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_admin"."user_profiles_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."announcements" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "title" "text" DEFAULT ''::"text" NOT NULL,
    "content" "text" DEFAULT ''::"text" NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid",
    "shared_with" "text"[],
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_base"."announcements" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."article_categories" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "color" "text" DEFAULT '#808080'::"text"
);


ALTER TABLE "mod_base"."article_categories" OWNER TO "postgres";


COMMENT ON COLUMN "mod_base"."article_categories"."color" IS 'Color code (hex) used for category tags and visual indicators';



CREATE SEQUENCE IF NOT EXISTS "mod_base"."article_categories_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_base"."article_categories_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."articles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "sku" "text" NOT NULL,
    "category_id" "uuid",
    "article_type" "text",
    "unit_of_measure_id" "uuid",
    "current_weight" numeric(12,4) DEFAULT 0,
    "current_length" numeric(12,4) DEFAULT 0,
    "width" numeric(12,4) DEFAULT 0,
    "height" numeric(12,4) DEFAULT 0,
    "cost" numeric(12,4) DEFAULT 0,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "load_weight" numeric(12,4) DEFAULT NULL::numeric,
    "allocated_weight" numeric(12,4) DEFAULT NULL::numeric,
    "load_length" numeric(12,4) DEFAULT NULL::numeric,
    "committed_length" numeric(12,4) DEFAULT NULL::numeric,
    "transaction_type" "text" DEFAULT 'internal'::"text",
    "type" character varying(50),
    "parent_article_id" "uuid",
    "heat_exchanger_model" character varying(50),
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("code", ''::"text")) || ' '::"text") || COALESCE("description", ''::"text")) || ' '::"text") || COALESCE("sku", ''::"text")) || ' '::"text") || COALESCE("article_type", ''::"text")))) STORED,
    "material_name" "text" DEFAULT ''::"text",
    "tech_code" "text" DEFAULT ''::"text",
    "sales_code" "text" DEFAULT ''::"text",
    CONSTRAINT "articles_article_type_check" CHECK (("article_type" = ANY (ARRAY['raw_material'::"text", 'semi_finished'::"text", 'finished_product'::"text"]))),
    CONSTRAINT "articles_transaction_type_check" CHECK (("transaction_type" = ANY (ARRAY['purchase'::"text", 'sale'::"text", 'internal'::"text"]))),
    CONSTRAINT "articles_type_check" CHECK (((("type")::"text" = ANY (ARRAY[('heat_exchanger'::character varying)::"text", ('pump'::character varying)::"text", ('dirt_separator'::character varying)::"text", ('brazed'::character varying)::"text", ('transport'::character varying)::"text", ('custom'::character varying)::"text", ('plate_material'::character varying)::"text", ('gasket_material'::character varying)::"text", ('manifold_material'::character varying)::"text", ('frame_material'::character varying)::"text", ('heat_exchanger_model'::character varying)::"text", ('pump_series'::character varying)::"text", ('pump_model'::character varying)::"text", ('component_article'::character varying)::"text", ('other'::character varying)::"text"])) OR ("type" IS NULL)))
);


ALTER TABLE "mod_base"."articles" OWNER TO "postgres";


COMMENT ON TABLE "mod_base"."articles" IS 'Added material_name, tech_code, and sales_code fields on 2025-11-01 for enhanced article categorization';



COMMENT ON COLUMN "mod_base"."articles"."current_weight" IS 'Current weight of the article';



COMMENT ON COLUMN "mod_base"."articles"."current_length" IS 'Current length of the article';



COMMENT ON COLUMN "mod_base"."articles"."load_weight" IS 'Weight currently in process for delivery or being prepared';



COMMENT ON COLUMN "mod_base"."articles"."allocated_weight" IS 'Weight reserved for a job or order';



COMMENT ON COLUMN "mod_base"."articles"."load_length" IS 'Length currently being processed or picked';



COMMENT ON COLUMN "mod_base"."articles"."committed_length" IS 'Length reserved for specific jobs/orders';



COMMENT ON COLUMN "mod_base"."articles"."transaction_type" IS 'Indicates how the article is used in transactions: purchase (from suppliers), sale (to customers), or internal (company use)';



COMMENT ON COLUMN "mod_base"."articles"."type" IS 'Specific product type/category (e.g., heat_exchanger, pump, dirt_separator, component_article) - more specific than article_type. component_article is used for specific component instances that should not appear in material selection dropdowns.';



COMMENT ON COLUMN "mod_base"."articles"."parent_article_id" IS 'Reference to parent article for hierarchical relationships (e.g., product variants, sub-components)';



COMMENT ON COLUMN "mod_base"."articles"."heat_exchanger_model" IS 'Heat exchanger model identifier (e.g., SP24T, SP24TL) for precise filtering';



COMMENT ON COLUMN "mod_base"."articles"."material_name" IS 'Material name identifier for the article';



COMMENT ON COLUMN "mod_base"."articles"."tech_code" IS 'Technical code used for engineering/manufacturing purposes';



COMMENT ON COLUMN "mod_base"."articles"."sales_code" IS 'Sales code used for commercial identification';



CREATE SEQUENCE IF NOT EXISTS "mod_base"."articles_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_base"."articles_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."bom_articles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "parent_article_id" "uuid" NOT NULL,
    "component_article_id" "uuid" NOT NULL,
    "quantity" integer DEFAULT 1 NOT NULL,
    "position" integer,
    "note" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((COALESCE("note", ''::"text") || ' '::"text") || COALESCE(("quantity")::"text", ''::"text")) || ' '::"text") || COALESCE(("position")::"text", ''::"text")))) STORED,
    CONSTRAINT "bom_articles_position_check" CHECK ((("position" IS NULL) OR ("position" >= 0))),
    CONSTRAINT "bom_articles_quantity_check" CHECK (("quantity" > 0))
);


ALTER TABLE "mod_base"."bom_articles" OWNER TO "postgres";


COMMENT ON TABLE "mod_base"."bom_articles" IS 'Bill of Materials (BOM) relationships linking finished products to their required components';



COMMENT ON COLUMN "mod_base"."bom_articles"."parent_article_id" IS 'ID of the finished product (e.g., heat exchanger)';



COMMENT ON COLUMN "mod_base"."bom_articles"."component_article_id" IS 'ID of the required component (e.g., plate, gasket, model)';



COMMENT ON COLUMN "mod_base"."bom_articles"."quantity" IS 'Number of that component needed for the finished product';



COMMENT ON COLUMN "mod_base"."bom_articles"."position" IS 'Order in the manufacturing process (optional)';



COMMENT ON COLUMN "mod_base"."bom_articles"."note" IS 'Additional notes (e.g., side A, 0H channel, etc.)';



CREATE TABLE IF NOT EXISTS "mod_base"."custom_article_attachments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "sales_order_id" "uuid",
    "file_url" "text" NOT NULL,
    "file_name" "text" NOT NULL,
    "file_size" bigint NOT NULL,
    "file_type" "text" NOT NULL,
    "article_id" "uuid",
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((COALESCE("file_name", ''::"text") || ' '::"text") || COALESCE("file_type", ''::"text")))) STORED,
    "internal_sales_order_id" "uuid",
    CONSTRAINT "custom_article_attachments_order_required" CHECK (((("sales_order_id" IS NOT NULL) AND ("internal_sales_order_id" IS NULL)) OR (("sales_order_id" IS NULL) AND ("internal_sales_order_id" IS NOT NULL))))
);


ALTER TABLE "mod_base"."custom_article_attachments" OWNER TO "postgres";


COMMENT ON TABLE "mod_base"."custom_article_attachments" IS 'File attachments for custom articles in sales orders';



COMMENT ON COLUMN "mod_base"."custom_article_attachments"."id" IS 'Primary key for the attachment';



COMMENT ON COLUMN "mod_base"."custom_article_attachments"."sales_order_id" IS 'Sales order ID - Can be NULL for internal sales order attachments. Either sales_order_id or internal_sales_order_id must be set, but not both.';



COMMENT ON COLUMN "mod_base"."custom_article_attachments"."file_url" IS 'URL to the stored file in Supabase storage';



COMMENT ON COLUMN "mod_base"."custom_article_attachments"."file_name" IS 'Original name of the uploaded file';



COMMENT ON COLUMN "mod_base"."custom_article_attachments"."file_size" IS 'Size of the file in bytes';



COMMENT ON COLUMN "mod_base"."custom_article_attachments"."file_type" IS 'MIME type of the file';



COMMENT ON COLUMN "mod_base"."custom_article_attachments"."article_id" IS 'Article ID - Can be NULL for sales order level attachments, or a valid UUID for article-specific attachments';



COMMENT ON COLUMN "mod_base"."custom_article_attachments"."internal_sales_order_id" IS 'Internal sales order ID - Can be set for attachments associated with internal sales orders. When set, sales_order_id should typically be null.';



CREATE TABLE IF NOT EXISTS "mod_base"."customer_addresses" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "customer_id" "uuid" NOT NULL,
    "address_type" "text" DEFAULT 'general'::"text" NOT NULL,
    "is_primary" boolean DEFAULT false NOT NULL,
    "address_line_1" "text" DEFAULT ''::"text" NOT NULL,
    "address_line_2" "text" DEFAULT ''::"text",
    "city" "text" DEFAULT ''::"text" NOT NULL,
    "state" "text" DEFAULT ''::"text",
    "province" "text" DEFAULT ''::"text",
    "zip" "text" DEFAULT ''::"text",
    "country" "text" DEFAULT ''::"text",
    "phone" "text" DEFAULT ''::"text",
    "contact_name" "text" DEFAULT ''::"text",
    "notes" "text" DEFAULT ''::"text",
    "domain_id" "uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[],
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid",
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((((((((((((COALESCE("address_line_1", ''::"text") || ' '::"text") || COALESCE("address_line_2", ''::"text")) || ' '::"text") || COALESCE("city", ''::"text")) || ' '::"text") || COALESCE("state", ''::"text")) || ' '::"text") || COALESCE("province", ''::"text")) || ' '::"text") || COALESCE("country", ''::"text")) || ' '::"text") || COALESCE("contact_name", ''::"text")) || ' '::"text") || COALESCE("notes", ''::"text")))) STORED,
    CONSTRAINT "customer_addresses_address_type_check" CHECK (("address_type" = ANY (ARRAY['billing'::"text", 'shipping'::"text", 'delivery'::"text", 'general'::"text"])))
);


ALTER TABLE "mod_base"."customer_addresses" OWNER TO "postgres";


COMMENT ON TABLE "mod_base"."customer_addresses" IS 'Stores multiple addresses for customers with support for different address types';



COMMENT ON COLUMN "mod_base"."customer_addresses"."address_type" IS 'Type of address: billing, shipping, delivery, or general';



COMMENT ON COLUMN "mod_base"."customer_addresses"."is_primary" IS 'Whether this is the primary address for this type';



COMMENT ON COLUMN "mod_base"."customer_addresses"."address_line_1" IS 'Primary address line';



COMMENT ON COLUMN "mod_base"."customer_addresses"."address_line_2" IS 'Secondary address line (apartment, suite, etc.)';



CREATE TABLE IF NOT EXISTS "mod_base"."customers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "contact_name" "text" DEFAULT ''::"text" NOT NULL,
    "email" "text" DEFAULT ''::"text" NOT NULL,
    "phone" "text" DEFAULT ''::"text" NOT NULL,
    "address" "text" DEFAULT ''::"text" NOT NULL,
    "zip" "text" DEFAULT ''::"text" NOT NULL,
    "city" "text" DEFAULT ''::"text" NOT NULL,
    "province" "text" DEFAULT ''::"text" NOT NULL,
    "state" "text" DEFAULT ''::"text" NOT NULL,
    "country" "text" DEFAULT ''::"text" NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "delivery_address" "text",
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((((((((((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("code", ''::"text")) || ' '::"text") || COALESCE("email", ''::"text")) || ' '::"text") || COALESCE("phone", ''::"text")) || ' '::"text") || COALESCE("contact_name", ''::"text")) || ' '::"text") || COALESCE("address", ''::"text")) || ' '::"text") || COALESCE("city", ''::"text")) || ' '::"text") || COALESCE("country", ''::"text")))) STORED,
    "vat_number" "text" DEFAULT ''::"text" NOT NULL,
    "fiscal_code" "text" DEFAULT ''::"text" NOT NULL,
    "cell" "text" DEFAULT ''::"text" NOT NULL,
    "pec" "text" DEFAULT ''::"text" NOT NULL,
    "payment_terms" "text" DEFAULT ''::"text" NOT NULL,
    "agent" "text" DEFAULT ''::"text" NOT NULL
);


ALTER TABLE "mod_base"."customers" OWNER TO "postgres";


COMMENT ON COLUMN "mod_base"."customers"."vat_number" IS 'Customer VAT number';



COMMENT ON COLUMN "mod_base"."customers"."fiscal_code" IS 'Customer fiscal code (Codice Fiscale)';



COMMENT ON COLUMN "mod_base"."customers"."cell" IS 'Customer mobile phone number';



COMMENT ON COLUMN "mod_base"."customers"."pec" IS 'Customer certified email (PEC)';



COMMENT ON COLUMN "mod_base"."customers"."payment_terms" IS 'Customer payment terms (Condizioni di pagamento)';



COMMENT ON COLUMN "mod_base"."customers"."agent" IS 'Assigned sales agent';



CREATE SEQUENCE IF NOT EXISTS "mod_base"."customers_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_base"."customers_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."departments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_base"."departments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."employees" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "last_name" "text" DEFAULT ''::"text" NOT NULL,
    "phone" "text" DEFAULT ''::"text" NOT NULL,
    "badge" "text" DEFAULT ''::"text" NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_base"."employees" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."employees_departments" (
    "employee_id" "uuid" NOT NULL,
    "department_id" "uuid" NOT NULL,
    "role" "text" NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "employees_departments_role_check" CHECK (("role" = ANY (ARRAY['manager'::"text", 'worker'::"text"])))
);


ALTER TABLE "mod_base"."employees_departments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."internal_sales_order_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "sales_order_id" "uuid" NOT NULL,
    "article_id" "uuid" NOT NULL,
    "quantity_ordered" numeric(12,4) NOT NULL,
    "quantity_allocated" numeric(12,4) DEFAULT 0 NOT NULL,
    "quantity_delivered" numeric(12,4) DEFAULT 0 NOT NULL,
    "unit_price" numeric(12,4) DEFAULT 0 NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "is_recipe" boolean DEFAULT false,
    "parent_sales_order_item_id" "uuid",
    "custom_instructions" "text",
    "production_date" "date",
    "is_manufactured" boolean DEFAULT false NOT NULL,
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("description", ''::"text")))) STORED
);


ALTER TABLE "mod_base"."internal_sales_order_items" OWNER TO "postgres";


COMMENT ON TABLE "mod_base"."internal_sales_order_items" IS 'Internal sales order items table - similar to sales_order_items but specifically for internal sales order items. All authenticated users have full access.';



COMMENT ON COLUMN "mod_base"."internal_sales_order_items"."sales_order_id" IS 'References internal_sales_orders.id - renamed from sales_order_id for consistency with trigger functions';



COMMENT ON COLUMN "mod_base"."internal_sales_order_items"."parent_sales_order_item_id" IS 'Self-referencing foreign key for hierarchical items';



CREATE OR REPLACE VIEW "mod_base"."internal_sales_order_items_stats" WITH ("security_invoker"='on') AS
 SELECT 'Internal Sales Order Items'::"text" AS "table_name",
    "mod_base"."count_total_records"('internal_sales_order_items'::"text") AS "total_records",
    "mod_base"."count_active_records"('internal_sales_order_items'::"text") AS "active_records",
    ("mod_base"."count_total_records"('internal_sales_order_items'::"text") - "mod_base"."count_active_records"('internal_sales_order_items'::"text")) AS "deleted_records";


ALTER VIEW "mod_base"."internal_sales_order_items_stats" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."internal_sales_orders" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "customer_id" "uuid",
    "sales_order_number" "text" DEFAULT ''::"text" NOT NULL,
    "order_date" "date" NOT NULL,
    "requested_delivery_date" "date",
    "expected_delivery_date" "date",
    "status" "text",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "production_start_date" "date",
    "is_production_complete" boolean DEFAULT false,
    "total_cost" numeric(15,2) DEFAULT 0.00,
    "is_archived" boolean DEFAULT false NOT NULL,
    "is_internal" boolean DEFAULT true NOT NULL,
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("description", ''::"text")))) STORED,
    CONSTRAINT "internal_sales_orders_customer_or_internal_check" CHECK (((("customer_id" IS NOT NULL) AND ("is_internal" = false)) OR (("customer_id" IS NULL) AND ("is_internal" = true)))),
    CONSTRAINT "internal_sales_orders_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'active'::"text", 'processing'::"text", 'ready_for_packing'::"text", 'ready_for_delivery'::"text", 'completed'::"text", 'paused'::"text", 'canceled'::"text"])))
);


ALTER TABLE "mod_base"."internal_sales_orders" OWNER TO "postgres";


COMMENT ON TABLE "mod_base"."internal_sales_orders" IS 'Internal sales orders table - similar to sales_orders but specifically for internal orders. All authenticated users have full access.';



COMMENT ON COLUMN "mod_base"."internal_sales_orders"."customer_id" IS 'Customer ID for external orders, NULL for internal orders';



COMMENT ON COLUMN "mod_base"."internal_sales_orders"."is_internal" IS 'Always true for internal sales orders';



CREATE SEQUENCE IF NOT EXISTS "mod_base"."internal_sales_orders_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_base"."internal_sales_orders_code_seq" OWNER TO "postgres";


CREATE OR REPLACE VIEW "mod_base"."internal_sales_orders_stats" WITH ("security_invoker"='on') AS
 SELECT 'Internal Sales Orders'::"text" AS "table_name",
    "mod_base"."count_total_records"('internal_sales_orders'::"text") AS "total_records",
    "mod_base"."count_active_records"('internal_sales_orders'::"text") AS "active_records",
    ("mod_base"."count_total_records"('internal_sales_orders'::"text") - "mod_base"."count_active_records"('internal_sales_orders'::"text")) AS "deleted_records";


ALTER VIEW "mod_base"."internal_sales_orders_stats" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "mod_base"."notifications_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_base"."notifications_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."profiles" (
    "id" "uuid" NOT NULL,
    "fcm_token" "text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_base"."profiles" OWNER TO "postgres";


COMMENT ON TABLE "mod_base"."profiles" IS 'Stores user profile information, extending auth.users, including push notification tokens.';



COMMENT ON COLUMN "mod_base"."profiles"."id" IS 'User ID, references auth.users.id.';



COMMENT ON COLUMN "mod_base"."profiles"."fcm_token" IS 'Firebase Cloud Messaging (FCM) registration token for push notifications.';



COMMENT ON COLUMN "mod_base"."profiles"."created_at" IS 'Timestamp of creation.';



COMMENT ON COLUMN "mod_base"."profiles"."updated_at" IS 'Timestamp of last update.';



COMMENT ON COLUMN "mod_base"."profiles"."created_by" IS 'User who created the record.';



COMMENT ON COLUMN "mod_base"."profiles"."updated_by" IS 'User who last updated the record.';



CREATE SEQUENCE IF NOT EXISTS "mod_base"."pulses_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_base"."pulses_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."purchase_order_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "purchase_order_id" "uuid" NOT NULL,
    "article_id" "uuid" NOT NULL,
    "quantity_ordered" numeric(12,4) NOT NULL,
    "quantity_received" numeric(12,4) DEFAULT 0 NOT NULL,
    "unit_price" numeric(12,4) DEFAULT 0 NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "quantity_defect" integer DEFAULT 0 NOT NULL,
    "is_completed" boolean DEFAULT false NOT NULL,
    "is_quantity_moved" boolean DEFAULT false,
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("code", ''::"text")) || ' '::"text") || COALESCE("description", ''::"text")))) STORED,
    CONSTRAINT "purchase_order_items_quantity_defect_check" CHECK (("quantity_defect" >= 0))
);


ALTER TABLE "mod_base"."purchase_order_items" OWNER TO "postgres";


COMMENT ON COLUMN "mod_base"."purchase_order_items"."quantity_defect" IS 'Number of defective items received';



COMMENT ON COLUMN "mod_base"."purchase_order_items"."is_completed" IS 'Indicates if the item has received enough quantity';



CREATE SEQUENCE IF NOT EXISTS "mod_base"."purchase_order_items_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_base"."purchase_order_items_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."purchase_orders" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "supplier_id" "uuid" NOT NULL,
    "purchase_order_number" "text" DEFAULT ''::"text" NOT NULL,
    "order_date" "date" NOT NULL,
    "expected_delivery_date" "date",
    "status" "text",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("code", ''::"text")) || ' '::"text") || COALESCE("purchase_order_number", ''::"text")) || ' '::"text") || COALESCE("status", ''::"text")) || ' '::"text") || COALESCE("description", ''::"text")))) STORED,
    CONSTRAINT "purchase_orders_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'processing'::"text", 'completed'::"text", 'canceled'::"text"])))
);


ALTER TABLE "mod_base"."purchase_orders" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."quality_control" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "article_id" "uuid",
    "status" "text" NOT NULL,
    "notes" "text" DEFAULT ''::"text" NOT NULL,
    "quantity_checked" integer DEFAULT 0 NOT NULL,
    "quantity_passed" integer DEFAULT 0 NOT NULL,
    "quantity_failed" integer DEFAULT 0 NOT NULL,
    "domain_id" "uuid",
    "shared_with" "text"[],
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "work_order_id" "uuid",
    "quality_control_type_id" "uuid",
    "planned_date" timestamp with time zone,
    "started_date" timestamp with time zone,
    "completed_date" timestamp with time zone,
    "inspector_id" "uuid",
    "reference_type" "text",
    "reference_id" "uuid",
    "batch_number" "text",
    "inspection_level" "text",
    "sample_size" integer,
    "acceptance_number" integer DEFAULT 0,
    "rejection_number" integer DEFAULT 0,
    "temperature" numeric(5,2),
    "humidity" numeric(5,2),
    "measuring_equipment" "text"[],
    "test_conditions" "jsonb" DEFAULT '{}'::"jsonb",
    "visual_inspection_result" "text",
    "corrective_actions" "text",
    "preventive_actions" "text",
    "review_notes" "text",
    "reviewed_by" "uuid",
    "reviewed_at" timestamp with time zone,
    "conformity_documents" "jsonb" DEFAULT '{}'::"jsonb",
    "certificate_numbers" "text"[],
    "certificate_expiry_dates" "date"[],
    "return_required" boolean DEFAULT false,
    "return_reason" "text",
    "return_quantity" integer DEFAULT 0,
    "purchase_order_item_id" "uuid",
    "work_steps_id" "uuid",
    "receipt_id" "uuid",
    "receipt_item_id" "uuid",
    "shipment_id" "uuid",
    "article_type" "text",
    CONSTRAINT "quality_control_inspection_level_check" CHECK (("inspection_level" = ANY (ARRAY['NORMAL'::"text", 'TIGHTENED'::"text", 'REDUCED'::"text"]))),
    CONSTRAINT "quality_control_reference_type_check" CHECK (("reference_type" = ANY (ARRAY['PURCHASE_ORDER'::"text", 'WORK_ORDER'::"text", 'SALES_ORDER'::"text", 'RECEIPT'::"text"]))),
    CONSTRAINT "quality_control_sample_size_check" CHECK (("sample_size" > 0)),
    CONSTRAINT "quality_control_status_check" CHECK (("status" = ANY (ARRAY['PLANNED'::"text", 'IN_PROGRESS'::"text", 'PASSED'::"text", 'FAILED'::"text", 'CANCELLED'::"text"]))),
    CONSTRAINT "quantity_check" CHECK ((("quantity_checked" >= 0) AND ("quantity_passed" >= 0) AND ("quantity_failed" >= 0) AND ("quantity_checked" = ("quantity_passed" + "quantity_failed"))))
);


ALTER TABLE "mod_base"."quality_control" OWNER TO "postgres";


COMMENT ON TABLE "mod_base"."quality_control" IS 'Main quality control inspection records';



COMMENT ON COLUMN "mod_base"."quality_control"."work_order_id" IS 'Reference to the work order that produced the articles being quality checked';



COMMENT ON COLUMN "mod_base"."quality_control"."quality_control_type_id" IS 'Reference to the standardized QC procedure/type being performed';



COMMENT ON COLUMN "mod_base"."quality_control"."planned_date" IS 'When this QC session was planned to be performed';



COMMENT ON COLUMN "mod_base"."quality_control"."started_date" IS 'When the QC inspection actually started';



COMMENT ON COLUMN "mod_base"."quality_control"."completed_date" IS 'When the QC inspection was completed';



COMMENT ON COLUMN "mod_base"."quality_control"."inspector_id" IS 'User assigned to perform this quality control inspection';



COMMENT ON COLUMN "mod_base"."quality_control"."purchase_order_item_id" IS 'Optional foreign key to purchase_order_items table. This links QC records to specific purchase order items for incoming material inspection. NULL for other QC types (work orders, sales orders, etc.).';



COMMENT ON COLUMN "mod_base"."quality_control"."work_steps_id" IS 'Reference to the specific work step this quality control is associated with. Allows linking QC records to work steps based on work_cycle_id.';



COMMENT ON COLUMN "mod_base"."quality_control"."receipt_id" IS 'Reference to the receipt (mod_wms.receipts) that contains the articles being quality checked. Used for tracking QC related to warehouse receiving operations.';



COMMENT ON COLUMN "mod_base"."quality_control"."receipt_item_id" IS 'Reference to the specific receipt item (mod_wms.receipt_items) being quality checked. This allows tracking QC at the individual item level within a receipt.';



COMMENT ON COLUMN "mod_base"."quality_control"."shipment_id" IS 'Reference to the shipment this quality control check is associated with';



COMMENT ON COLUMN "mod_base"."quality_control"."article_type" IS 'Article type that this QC record applies to (e.g., ''heat_exchanger_plate'', ''gasket'', ''frame''). This can be derived from the article_id but is stored directly for query performance.';



COMMENT ON CONSTRAINT "quality_control_reference_type_check" ON "mod_base"."quality_control" IS 'Constraint ensuring reference_type is one of: PURCHASE_ORDER, WORK_ORDER, SALES_ORDER, or RECEIPT. RECEIPT type is used for warehouse receiving quality control operations.';



CREATE TABLE IF NOT EXISTS "mod_base"."suppliers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "contact_name" "text" DEFAULT ''::"text" NOT NULL,
    "email" "text" DEFAULT ''::"text" NOT NULL,
    "phone" "text" DEFAULT ''::"text" NOT NULL,
    "address" "text" DEFAULT ''::"text" NOT NULL,
    "zip" "text" DEFAULT ''::"text" NOT NULL,
    "city" "text" DEFAULT ''::"text" NOT NULL,
    "province" "text" DEFAULT ''::"text" NOT NULL,
    "state" "text" DEFAULT ''::"text" NOT NULL,
    "country" "text" DEFAULT ''::"text" NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "vat_cde" "text" DEFAULT ''::"text" NOT NULL,
    "sdi_code" "text" DEFAULT ''::"text" NOT NULL,
    "pec_email" "text" DEFAULT ''::"text" NOT NULL,
    "is_default" boolean DEFAULT false NOT NULL,
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((((((((((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("code", ''::"text")) || ' '::"text") || COALESCE("email", ''::"text")) || ' '::"text") || COALESCE("phone", ''::"text")) || ' '::"text") || COALESCE("contact_name", ''::"text")) || ' '::"text") || COALESCE("address", ''::"text")) || ' '::"text") || COALESCE("city", ''::"text")) || ' '::"text") || COALESCE("country", ''::"text")))) STORED,
    "payment_terms" "text" DEFAULT ''::"text" NOT NULL
);


ALTER TABLE "mod_base"."suppliers" OWNER TO "postgres";


COMMENT ON COLUMN "mod_base"."suppliers"."vat_cde" IS 'VAT code for the supplier';



COMMENT ON COLUMN "mod_base"."suppliers"."sdi_code" IS 'SDI code for electronic invoicing';



COMMENT ON COLUMN "mod_base"."suppliers"."pec_email" IS 'PEC certified email for official communications';



COMMENT ON COLUMN "mod_base"."suppliers"."payment_terms" IS 'Supplier payment terms (Condizioni di pagamento)';



CREATE TABLE IF NOT EXISTS "mod_quality_control"."quality_control_checklist_results" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "quality_control_id" "uuid",
    "checklist_item_id" "text",
    "result" boolean,
    "notes" "text",
    "inspector_id" "uuid",
    "completed_at" timestamp with time zone DEFAULT "now"(),
    "shared_with" "text"[] DEFAULT ARRAY[]::"text"[],
    "is_deleted" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_quality_control"."quality_control_checklist_results" OWNER TO "postgres";


COMMENT ON TABLE "mod_quality_control"."quality_control_checklist_results" IS 'Results of quality control checklist items';



CREATE TABLE IF NOT EXISTS "mod_quality_control"."quality_control_defects" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "quality_control_id" "uuid",
    "defect_type_id" "uuid",
    "quantity" integer,
    "severity" "public"."defect_severity_type" NOT NULL,
    "description" "text",
    "images" "text"[],
    "corrective_action" "text",
    "inspector_notes" "text",
    "shared_with" "text"[] DEFAULT ARRAY[]::"text"[],
    "is_deleted" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "quality_control_defects_quantity_check" CHECK (("quantity" >= 0))
);


ALTER TABLE "mod_quality_control"."quality_control_defects" OWNER TO "postgres";


COMMENT ON TABLE "mod_quality_control"."quality_control_defects" IS 'Defects found during quality control inspections';



CREATE TABLE IF NOT EXISTS "mod_quality_control"."supplier_returns" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "quality_control_id" "uuid",
    "purchase_order_id" "uuid",
    "supplier_id" "uuid",
    "article_id" "uuid",
    "return_number" "text" NOT NULL,
    "return_date" "date" NOT NULL,
    "return_reason" "text" NOT NULL,
    "return_quantity" integer NOT NULL,
    "return_status" "public"."return_status_type" DEFAULT 'PENDING'::"public"."return_status_type",
    "conformity_issues" "text"[],
    "missing_certificates" "text"[],
    "certificate_expiry_issues" "text"[],
    "unit_cost" numeric(10,2),
    "total_cost" numeric(10,2),
    "credit_amount" numeric(10,2),
    "credit_issued_date" "date",
    "shipping_method" "text",
    "tracking_number" "text",
    "shipping_date" "date",
    "expected_return_date" "date",
    "supplier_contact" "text",
    "communication_notes" "text",
    "follow_up_required" boolean DEFAULT false,
    "follow_up_date" "date",
    "shared_with" "text"[] DEFAULT ARRAY[]::"text"[],
    "is_deleted" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "supplier_returns_return_quantity_check" CHECK (("return_quantity" > 0))
);


ALTER TABLE "mod_quality_control"."supplier_returns" OWNER TO "postgres";


COMMENT ON TABLE "mod_quality_control"."supplier_returns" IS 'Tracking of materials returned to suppliers due to quality issues';



CREATE OR REPLACE VIEW "mod_base"."purchase_order_qc_tracking" WITH ("security_invoker"='on') AS
 SELECT "po"."id" AS "purchase_order_id",
    "po"."code" AS "purchase_order_code",
    "po"."status" AS "purchase_order_status",
    "po"."supplier_id",
    "s"."name" AS "supplier_name",
    "poi"."id" AS "purchase_order_item_id",
    "poi"."name" AS "item_name",
    "poi"."quantity_ordered",
    "poi"."quantity_received",
    "poi"."quantity_defect",
    "poi"."is_completed" AS "item_completed",
    "poi"."is_quantity_moved" AS "item_moved_to_inventory",
    "qc"."id" AS "quality_control_id",
    "qc"."code" AS "qc_code",
    "qc"."status" AS "qc_status",
    "qc"."quantity_checked",
    "qc"."quantity_passed",
    "qc"."quantity_failed",
    "qc"."completed_date" AS "qc_completed_date",
    "qc"."inspector_id",
    "u"."email" AS "inspector_email",
    COALESCE("defect_summary"."defects_found", (0)::bigint) AS "defects_found",
    COALESCE("checklist_summary"."checklist_items_completed", (0)::bigint) AS "checklist_items_completed",
    COALESCE("return_summary"."supplier_returns_created", (0)::bigint) AS "supplier_returns_created",
        CASE
            WHEN ("qc"."id" IS NULL) THEN 'QC_PENDING'::"text"
            WHEN ("qc"."status" = 'PASSED'::"text") THEN 'QC_PASSED'::"text"
            WHEN ("qc"."status" = 'CONDITIONALLY_ACCEPTED'::"text") THEN 'QC_CONDITIONAL'::"text"
            WHEN ("qc"."status" = 'FAILED'::"text") THEN 'QC_FAILED'::"text"
            WHEN ("qc"."status" = 'HOLD'::"text") THEN 'QC_HOLD'::"text"
            WHEN ("qc"."status" = ANY (ARRAY['PLANNED'::"text", 'IN_PROGRESS'::"text"])) THEN 'QC_IN_PROGRESS'::"text"
            ELSE 'QC_UNKNOWN'::"text"
        END AS "overall_status"
   FROM ((((((("mod_base"."purchase_orders" "po"
     JOIN "mod_base"."purchase_order_items" "poi" ON (("po"."id" = "poi"."purchase_order_id")))
     LEFT JOIN "mod_base"."suppliers" "s" ON (("po"."supplier_id" = "s"."id")))
     LEFT JOIN "mod_base"."quality_control" "qc" ON (("poi"."id" = "qc"."purchase_order_item_id")))
     LEFT JOIN "auth"."users" "u" ON (("qc"."inspector_id" = "u"."id")))
     LEFT JOIN ( SELECT "quality_control_defects"."quality_control_id",
            "count"(*) AS "defects_found"
           FROM "mod_quality_control"."quality_control_defects"
          WHERE (NOT "quality_control_defects"."is_deleted")
          GROUP BY "quality_control_defects"."quality_control_id") "defect_summary" ON (("qc"."id" = "defect_summary"."quality_control_id")))
     LEFT JOIN ( SELECT "quality_control_checklist_results"."quality_control_id",
            "count"(*) AS "checklist_items_completed"
           FROM "mod_quality_control"."quality_control_checklist_results"
          WHERE (NOT "quality_control_checklist_results"."is_deleted")
          GROUP BY "quality_control_checklist_results"."quality_control_id") "checklist_summary" ON (("qc"."id" = "checklist_summary"."quality_control_id")))
     LEFT JOIN ( SELECT "supplier_returns"."quality_control_id",
            "count"(*) AS "supplier_returns_created"
           FROM "mod_quality_control"."supplier_returns"
          GROUP BY "supplier_returns"."quality_control_id") "return_summary" ON (("qc"."id" = "return_summary"."quality_control_id")))
  WHERE ((NOT "po"."is_deleted") AND (NOT "poi"."is_deleted"))
  ORDER BY "po"."code", "poi"."name";


ALTER VIEW "mod_base"."purchase_order_qc_tracking" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "mod_base"."purchase_orders_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_base"."purchase_orders_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."quality_control_attachments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "quality_control_id" "uuid" NOT NULL,
    "file_url" "text" NOT NULL,
    "file_name" "text" NOT NULL,
    "file_size" bigint NOT NULL,
    "file_type" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "mod_base"."quality_control_attachments" OWNER TO "postgres";


COMMENT ON TABLE "mod_base"."quality_control_attachments" IS 'File attachments for quality control records';



COMMENT ON COLUMN "mod_base"."quality_control_attachments"."id" IS 'Primary key for the attachment';



COMMENT ON COLUMN "mod_base"."quality_control_attachments"."quality_control_id" IS 'Foreign key reference to the quality control record';



COMMENT ON COLUMN "mod_base"."quality_control_attachments"."file_url" IS 'URL to the stored file in Supabase storage';



COMMENT ON COLUMN "mod_base"."quality_control_attachments"."file_name" IS 'Original name of the uploaded file';



COMMENT ON COLUMN "mod_base"."quality_control_attachments"."file_size" IS 'Size of the file in bytes';



COMMENT ON COLUMN "mod_base"."quality_control_attachments"."file_type" IS 'MIME type of the file';



CREATE TABLE IF NOT EXISTS "mod_base"."quality_control_checklist_results" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "quality_control_id" "uuid" NOT NULL,
    "checklist_item" "text" NOT NULL,
    "result" boolean NOT NULL,
    "notes" "text",
    "domain_id" "uuid" DEFAULT (("auth"."jwt"() ->> 'domain_id'::"text"))::"uuid" NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "updated_by" "uuid" DEFAULT "auth"."uid"()
);


ALTER TABLE "mod_base"."quality_control_checklist_results" OWNER TO "postgres";


COMMENT ON TABLE "mod_base"."quality_control_checklist_results" IS 'Stores individual checklist item results for quality control inspections';



COMMENT ON COLUMN "mod_base"."quality_control_checklist_results"."quality_control_id" IS 'Foreign key reference to the main quality control record';



COMMENT ON COLUMN "mod_base"."quality_control_checklist_results"."checklist_item" IS 'Name of the checklist item (e.g., "Visual Inspection", "Dimensional Check")';



COMMENT ON COLUMN "mod_base"."quality_control_checklist_results"."result" IS 'Pass/fail result: true = PASS, false = FAIL';



COMMENT ON COLUMN "mod_base"."quality_control_checklist_results"."notes" IS 'Optional notes or comments for this checklist item';



CREATE OR REPLACE VIEW "mod_base"."quality_control_checklist_summary" WITH ("security_barrier"='true', "security_invoker"='on') AS
 SELECT "qccr"."id",
    "qccr"."quality_control_id",
    "qccr"."checklist_item",
    "qccr"."result",
    "qccr"."notes",
    "qccr"."created_at",
    "qccr"."created_by",
    "qc"."code" AS "qc_code",
    "qc"."name" AS "qc_name",
    "qc"."status" AS "qc_status",
    "qc"."purchase_order_item_id",
    "a"."name" AS "article_name",
    "a"."code" AS "article_code",
    "poi"."name" AS "item_name",
    "poi"."quantity_ordered",
    "poi"."quantity_received",
    ( SELECT "count"(*) AS "count"
           FROM "mod_base"."quality_control_checklist_results" "qccr2"
          WHERE (("qccr2"."quality_control_id" = "qccr"."quality_control_id") AND ("qccr2"."is_deleted" = false))) AS "total_checklist_items",
    ( SELECT "count"(*) AS "count"
           FROM "mod_base"."quality_control_checklist_results" "qccr2"
          WHERE (("qccr2"."quality_control_id" = "qccr"."quality_control_id") AND ("qccr2"."result" = true) AND ("qccr2"."is_deleted" = false))) AS "passed_items",
    ( SELECT "count"(*) AS "count"
           FROM "mod_base"."quality_control_checklist_results" "qccr2"
          WHERE (("qccr2"."quality_control_id" = "qccr"."quality_control_id") AND ("qccr2"."result" = false) AND ("qccr2"."is_deleted" = false))) AS "failed_items"
   FROM ((("mod_base"."quality_control_checklist_results" "qccr"
     LEFT JOIN "mod_base"."quality_control" "qc" ON (("qccr"."quality_control_id" = "qc"."id")))
     LEFT JOIN "mod_base"."articles" "a" ON (("qc"."article_id" = "a"."id")))
     LEFT JOIN "mod_base"."purchase_order_items" "poi" ON (("qc"."purchase_order_item_id" = "poi"."id")))
  WHERE (("qccr"."is_deleted" = false) AND (("qc"."is_deleted" = false) OR ("qc"."is_deleted" IS NULL)))
  ORDER BY "qccr"."created_at";


ALTER VIEW "mod_base"."quality_control_checklist_summary" OWNER TO "postgres";


CREATE OR REPLACE VIEW "mod_base"."quality_control_summary" AS
SELECT
    NULL::"uuid" AS "id",
    NULL::"text" AS "code",
    NULL::"text" AS "name",
    NULL::"text" AS "status",
    NULL::"text" AS "reference_type",
    NULL::"uuid" AS "reference_id",
    NULL::"uuid" AS "inspector_id",
    NULL::integer AS "quantity_checked",
    NULL::integer AS "quantity_passed",
    NULL::integer AS "quantity_failed",
    NULL::bigint AS "defect_count",
    NULL::bigint AS "measurement_count",
    NULL::bigint AS "checklist_count",
    NULL::timestamp with time zone AS "created_at",
    NULL::timestamp with time zone AS "completed_date",
    NULL::character varying(255) AS "inspector_email",
    NULL::"text" AS "inspector_name",
    NULL::"uuid" AS "purchase_order_item_id",
    NULL::"text" AS "purchase_order_code",
    NULL::"uuid" AS "supplier_id",
    NULL::"text" AS "item_name",
    NULL::numeric(12,4) AS "quantity_ordered",
    NULL::numeric(12,4) AS "quantity_received",
    NULL::integer AS "quantity_defect",
    NULL::"text" AS "supplier_name",
    NULL::"text" AS "qc_type";


ALTER VIEW "mod_base"."quality_control_summary" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."quality_control_types" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "article_type" "text" DEFAULT ''::"text",
    "is_required" boolean DEFAULT false,
    "is_active" boolean DEFAULT true,
    "test_specifications" "jsonb" DEFAULT '{}'::"jsonb",
    "acceptance_criteria" "jsonb" DEFAULT '{}'::"jsonb",
    "checklist_items" "text"[] DEFAULT ARRAY[]::"text"[],
    "timing" "text" DEFAULT 'final'::"text",
    "estimated_duration" interval DEFAULT '00:30:00'::interval,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid",
    "shared_with" "text"[] DEFAULT ARRAY[]::"text"[],
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid",
    "work_cycle_id" "uuid",
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("description", ''::"text")))) STORED,
    "category_id" "uuid"
);


ALTER TABLE "mod_base"."quality_control_types" OWNER TO "postgres";


COMMENT ON TABLE "mod_base"."quality_control_types" IS 'Quality control types define standardized QC procedures. Types with work_cycle_id link to specific manufacturing/receiving processes. category_id can be used to filter QC types by article category.';



COMMENT ON COLUMN "mod_base"."quality_control_types"."article_type" IS 'Article type that this QC type applies to (e.g., ''heat_exchanger_plate'', ''gasket'', ''frame''). NULL means it applies to all article types.';



COMMENT ON COLUMN "mod_base"."quality_control_types"."work_cycle_id" IS 'Reference to work_cycle to filter QC types by manufacturing process step';



COMMENT ON COLUMN "mod_base"."quality_control_types"."category_id" IS 'Reference to the article category (mod_base.article_categories) that this quality control type applies to. NULL means it applies to all categories.';



CREATE TABLE IF NOT EXISTS "mod_base"."quality_control_types_duplicate" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "article_type" "text" DEFAULT ''::"text",
    "is_required" boolean DEFAULT false,
    "is_active" boolean DEFAULT true,
    "test_specifications" "jsonb" DEFAULT '{}'::"jsonb",
    "acceptance_criteria" "jsonb" DEFAULT '{}'::"jsonb",
    "checklist_items" "text"[] DEFAULT ARRAY[]::"text"[],
    "timing" "text" DEFAULT 'final'::"text",
    "estimated_duration" interval DEFAULT '00:30:00'::interval,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid",
    "shared_with" "text"[] DEFAULT ARRAY[]::"text"[],
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid",
    "work_cycle_id" "uuid",
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("description", ''::"text")))) STORED,
    "category_id" "uuid"
);


ALTER TABLE "mod_base"."quality_control_types_duplicate" OWNER TO "postgres";


COMMENT ON TABLE "mod_base"."quality_control_types_duplicate" IS 'This is a duplicate of quality_control_types';



COMMENT ON COLUMN "mod_base"."quality_control_types_duplicate"."article_type" IS 'Article type that this QC type applies to (e.g., ''heat_exchanger_plate'', ''gasket'', ''frame''). NULL means it applies to all article types.';



COMMENT ON COLUMN "mod_base"."quality_control_types_duplicate"."work_cycle_id" IS 'Reference to work_cycle to filter QC types by manufacturing process step';



COMMENT ON COLUMN "mod_base"."quality_control_types_duplicate"."category_id" IS 'Reference to the article category (mod_base.article_categories) that this quality control type applies to. NULL means it applies to all categories.';



CREATE TABLE IF NOT EXISTS "mod_base"."report_template" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "report_name" "text" DEFAULT '255'::"text",
    "template_json_value" json,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "report_type" integer,
    "archive_type" integer,
    "created_by" "uuid",
    "updated_by" "uuid",
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "domain_id" "uuid",
    "shared_with" "text"[] NOT NULL
);


ALTER TABLE "mod_base"."report_template" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."sales_order_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "sales_order_id" "uuid" NOT NULL,
    "article_id" "uuid" NOT NULL,
    "quantity_ordered" numeric(12,4) NOT NULL,
    "quantity_allocated" numeric(12,4) DEFAULT 0 NOT NULL,
    "quantity_delivered" numeric(12,4) DEFAULT 0 NOT NULL,
    "unit_price" numeric(12,4) DEFAULT 0 NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "is_recipe" boolean DEFAULT false,
    "parent_sales_order_item_id" "uuid",
    "custom_instructions" "text",
    "production_date" "date",
    "is_manufactured" boolean DEFAULT false NOT NULL,
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("code", ''::"text")) || ' '::"text") || COALESCE("description", ''::"text")))) STORED,
    "serial_number" "text",
    "has_shipment" boolean DEFAULT false NOT NULL,
    "is_shipped" boolean DEFAULT false NOT NULL,
    "discount_1" numeric(5,2) DEFAULT 0,
    "discount_2" numeric(5,2) DEFAULT 0,
    "note" "text"
);


ALTER TABLE "mod_base"."sales_order_items" OWNER TO "postgres";


COMMENT ON COLUMN "mod_base"."sales_order_items"."is_recipe" IS 'Indicates if this item is a recipe component of a finished product';



COMMENT ON COLUMN "mod_base"."sales_order_items"."parent_sales_order_item_id" IS 'Links recipe components to their parent finished product item';



COMMENT ON COLUMN "mod_base"."sales_order_items"."custom_instructions" IS 'Custom instructions for the sales order item';



COMMENT ON COLUMN "mod_base"."sales_order_items"."production_date" IS 'Date when the item was produced';



COMMENT ON COLUMN "mod_base"."sales_order_items"."is_manufactured" IS 'Indicates whether all work orders for this sales order item have been completed (manufactured)';



COMMENT ON COLUMN "mod_base"."sales_order_items"."serial_number" IS 'Comma-separated serial numbers for manufactured items. Format: PREFIX[YY][incremental_nr]. 
Example: "SP25000001" for single item, "SP25000001,SP25000002" for quantity_ordered = 2.
Only populated for items in specific categories (Serbatoi, Scambiatori di calore SRS, Preparators, Coibentazioni, Bollitori) 
or articles with type = "heat_exchanger".';



COMMENT ON COLUMN "mod_base"."sales_order_items"."has_shipment" IS 'Indicates whether this sales order item has been associated with a shipment';



COMMENT ON COLUMN "mod_base"."sales_order_items"."is_shipped" IS 'Indicates whether this sales order item has been shipped (delivered)';



COMMENT ON COLUMN "mod_base"."sales_order_items"."discount_1" IS 'First discount percentage (0-100). Applied to the original unit price.';



COMMENT ON COLUMN "mod_base"."sales_order_items"."discount_2" IS 'Second discount percentage (0-100). Applied sequentially to the price after discount_1 is applied.';



COMMENT ON COLUMN "mod_base"."sales_order_items"."note" IS 'Optional note field for sales order items. Allows users to add specific notes or instructions for each item.';



CREATE SEQUENCE IF NOT EXISTS "mod_base"."sales_order_items_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_base"."sales_order_items_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."sales_orders" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "customer_id" "uuid",
    "sales_order_number" "text" DEFAULT ''::"text" NOT NULL,
    "order_date" "date" NOT NULL,
    "requested_delivery_date" "date",
    "expected_delivery_date" "date",
    "status" "text",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "production_start_date" "date",
    "is_production_complete" boolean DEFAULT false,
    "total_cost" numeric(15,2) DEFAULT 0.00,
    "is_archived" boolean DEFAULT false NOT NULL,
    "is_internal" boolean DEFAULT false NOT NULL,
    "order_ref" "text",
    "customer_order_ref" "text",
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((((((((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("code", ''::"text")) || ' '::"text") || COALESCE("sales_order_number", ''::"text")) || ' '::"text") || COALESCE("status", ''::"text")) || ' '::"text") || COALESCE("description", ''::"text")) || ' '::"text") || COALESCE("order_ref", ''::"text")) || ' '::"text") || COALESCE("customer_order_ref", ''::"text")))) STORED,
    "in_production" boolean DEFAULT false NOT NULL,
    "docs_ready" boolean DEFAULT false NOT NULL,
    CONSTRAINT "sales_orders_customer_or_internal_check" CHECK (((("customer_id" IS NOT NULL) AND ("is_internal" = false)) OR (("customer_id" IS NULL) AND ("is_internal" = true)))),
    CONSTRAINT "sales_orders_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'active'::"text", 'processing'::"text", 'ready_for_packing'::"text", 'ready_for_delivery'::"text", 'completed'::"text", 'paused'::"text", 'canceled'::"text"])))
);


ALTER TABLE "mod_base"."sales_orders" OWNER TO "postgres";


COMMENT ON TABLE "mod_base"."sales_orders" IS 'Stores sales order information. All authenticated users have full access for now.';



COMMENT ON COLUMN "mod_base"."sales_orders"."customer_id" IS 'Customer ID for external orders, NULL for internal orders';



COMMENT ON COLUMN "mod_base"."sales_orders"."production_start_date" IS 'The date when production for this sales order should start';



COMMENT ON COLUMN "mod_base"."sales_orders"."is_production_complete" IS 'Indicates if production is complete for this sales order';



COMMENT ON COLUMN "mod_base"."sales_orders"."total_cost" IS 'Total cost of the sales order including all items and discounts';



COMMENT ON COLUMN "mod_base"."sales_orders"."is_archived" IS 'Whether this sales order is archived and hidden from default views';



COMMENT ON COLUMN "mod_base"."sales_orders"."is_internal" IS 'Indicates if this is an internal order (no customer required)';



COMMENT ON COLUMN "mod_base"."sales_orders"."order_ref" IS 'Internal order reference number';



COMMENT ON COLUMN "mod_base"."sales_orders"."customer_order_ref" IS 'Customer provided order reference number';



COMMENT ON COLUMN "mod_base"."sales_orders"."in_production" IS 'Indicates if the sales order is in production';



COMMENT ON COLUMN "mod_base"."sales_orders"."docs_ready" IS 'Indicates if documents are ready for the sales order';



CREATE SEQUENCE IF NOT EXISTS "mod_base"."sales_orders_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_base"."sales_orders_code_seq" OWNER TO "postgres";


CREATE OR REPLACE VIEW "mod_base"."sales_orders_stats" AS
 SELECT 'Sales Orders'::"text" AS "table_name",
    "mod_base"."count_total_records"('sales_orders'::"text") AS "total_records",
    "mod_base"."count_active_records"('sales_orders'::"text") AS "active_records",
    ("mod_base"."count_total_records"('sales_orders'::"text") - "mod_base"."count_active_records"('sales_orders'::"text")) AS "deleted_records";


ALTER VIEW "mod_base"."sales_orders_stats" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."serial_number_counters" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "category_id" "uuid" NOT NULL,
    "year" integer NOT NULL,
    "last_incremental_number" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "serial_number_counters_incremental_check" CHECK (("last_incremental_number" >= 0)),
    CONSTRAINT "serial_number_counters_year_check" CHECK ((("year" >= 2000) AND ("year" <= 9999)))
);


ALTER TABLE "mod_base"."serial_number_counters" OWNER TO "postgres";


COMMENT ON TABLE "mod_base"."serial_number_counters" IS 'Tracks the last incremental serial number used for each article category per year. Counters reset to 1 each new year.';



COMMENT ON COLUMN "mod_base"."serial_number_counters"."category_id" IS 'Reference to the article category that requires serial numbers';



COMMENT ON COLUMN "mod_base"."serial_number_counters"."year" IS 'The year for which this counter is valid (e.g., 2025)';



COMMENT ON COLUMN "mod_base"."serial_number_counters"."last_incremental_number" IS 'The last incremental number used for this category in this year. Next serial number will be this + 1.';



CREATE SEQUENCE IF NOT EXISTS "mod_base"."suppliers_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_base"."suppliers_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_base"."units_of_measure" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "symbol" "text" DEFAULT ''::"text" NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_base"."units_of_measure" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_datalayer"."fields" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "field_name" "text" DEFAULT ''::"text" NOT NULL,
    "label" "text" DEFAULT ''::"text" NOT NULL,
    "label_key" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "description_key" "text" DEFAULT ''::"text" NOT NULL,
    "icon" "text" DEFAULT ''::"text" NOT NULL,
    "sort_order" integer DEFAULT 0 NOT NULL,
    "data_type" "text" NOT NULL,
    "is_nullable" boolean,
    "input_type" "text" DEFAULT 'string'::"text" NOT NULL,
    "input_placeholder" "text" DEFAULT ''::"text" NOT NULL,
    "input_placeholder_key" "text" DEFAULT ''::"text" NOT NULL,
    "input_options" "jsonb" DEFAULT '[]'::"jsonb",
    "input_props" "jsonb" DEFAULT '{}'::"jsonb",
    "input_class" "text" DEFAULT ''::"text",
    "input_col" integer DEFAULT 6,
    "schema_name" "text" NOT NULL,
    "table_name" "text" NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "is_primary_key" boolean DEFAULT false NOT NULL,
    "is_foreign_key" boolean DEFAULT false NOT NULL,
    "references_schema" "text",
    "references_table" "text",
    "references_field" "text",
    "show_in_card" boolean DEFAULT false NOT NULL,
    "show_in_form" boolean DEFAULT false NOT NULL,
    "show_in_editor" boolean DEFAULT false NOT NULL,
    "show_in_quickview" boolean DEFAULT false NOT NULL,
    "show_in_select" boolean DEFAULT false NOT NULL,
    "show_in_grid" boolean DEFAULT false NOT NULL,
    "show_in_list" boolean DEFAULT false NOT NULL,
    "show_in_filter" boolean DEFAULT false NOT NULL,
    "show_in_kanban" boolean DEFAULT false NOT NULL,
    "show_in_calendar" boolean DEFAULT false NOT NULL,
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("field_name", ''::"text")) || ' '::"text") || COALESCE("label", ''::"text")) || ' '::"text") || COALESCE("description", ''::"text")))) STORED,
    CONSTRAINT "fields_input_type_check" CHECK (("input_type" = ANY (ARRAY['string'::"text", 'number'::"text", 'singleChoice'::"text"])))
);


ALTER TABLE "mod_datalayer"."fields" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_datalayer"."main_menu" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "title" "text" DEFAULT ''::"text" NOT NULL,
    "title_key" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "description_key" "text" DEFAULT ''::"text" NOT NULL,
    "icon" "text" DEFAULT ''::"text" NOT NULL,
    "separator" boolean DEFAULT false NOT NULL,
    "expanded" boolean DEFAULT false NOT NULL,
    "color" "text" DEFAULT ''::"text" NOT NULL,
    "sort_order" integer DEFAULT 0 NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("code", ''::"text")) || ' '::"text") || COALESCE("title", ''::"text")) || ' '::"text") || COALESCE("description", ''::"text")))) STORED
);


ALTER TABLE "mod_datalayer"."main_menu" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_datalayer"."modules" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "schema_name" "text" DEFAULT ''::"text" NOT NULL,
    "title" "text" DEFAULT ''::"text" NOT NULL,
    "title_key" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "description_key" "text" DEFAULT ''::"text" NOT NULL,
    "icon" "text" DEFAULT ''::"text" NOT NULL,
    "sort_order" integer DEFAULT 0 NOT NULL,
    "public_folder" "text" DEFAULT ''::"text" NOT NULL,
    "code_folder" "text" DEFAULT ''::"text" NOT NULL,
    "enabled" boolean DEFAULT true,
    "public" boolean DEFAULT false,
    "owner_domain_id" "uuid",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("schema_name", ''::"text")) || ' '::"text") || COALESCE("title", ''::"text")) || ' '::"text") || COALESCE("description", ''::"text")))) STORED
);


ALTER TABLE "mod_datalayer"."modules" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_datalayer"."page_categories" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "title" "text" DEFAULT ''::"text" NOT NULL,
    "titlekey" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "descriptionkey" "text" DEFAULT ''::"text" NOT NULL,
    "icon" "text" DEFAULT ''::"text" NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_datalayer"."page_categories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_datalayer"."pages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "path" "text" DEFAULT ''::"text" NOT NULL,
    "title" "text" DEFAULT ''::"text" NOT NULL,
    "titlekey" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "descriptionkey" "text" DEFAULT ''::"text" NOT NULL,
    "icon" "text" DEFAULT ''::"text" NOT NULL,
    "is_module_home" boolean DEFAULT false,
    "module_id" "uuid" NOT NULL,
    "page_category_id" "uuid",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "main_menu_id" "uuid",
    "is_visible" boolean DEFAULT true NOT NULL,
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("title", ''::"text")) || ' '::"text") || COALESCE("description", ''::"text")) || ' '::"text") || COALESCE("path", ''::"text")))) STORED
);


ALTER TABLE "mod_datalayer"."pages" OWNER TO "postgres";


COMMENT ON COLUMN "mod_datalayer"."pages"."is_visible" IS 'Controls whether the page is visible in menu drawer. Default: true';



CREATE TABLE IF NOT EXISTS "mod_datalayer"."pages_departments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "page_id" "uuid",
    "department_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid",
    "user_id" "uuid",
    "is_deleted" boolean DEFAULT false NOT NULL
);


ALTER TABLE "mod_datalayer"."pages_departments" OWNER TO "postgres";


COMMENT ON TABLE "mod_datalayer"."pages_departments" IS 'Junction table linking pages to departments for access control';



COMMENT ON COLUMN "mod_datalayer"."pages_departments"."page_id" IS 'Reference to the page';



COMMENT ON COLUMN "mod_datalayer"."pages_departments"."department_id" IS 'Reference to the department';



COMMENT ON COLUMN "mod_datalayer"."pages_departments"."created_at" IS 'When the page-department assignment was created';



COMMENT ON COLUMN "mod_datalayer"."pages_departments"."updated_at" IS 'When the page-department assignment was last updated';



COMMENT ON COLUMN "mod_datalayer"."pages_departments"."is_deleted" IS 'Soft delete flag - when true, the record is considered deleted';



CREATE TABLE IF NOT EXISTS "mod_datalayer"."pages_menu_departments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "page_id" "uuid",
    "department_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid",
    "user_id" "uuid"
);


ALTER TABLE "mod_datalayer"."pages_menu_departments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_datalayer"."tables" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "table_name" "text" DEFAULT ''::"text" NOT NULL,
    "title" "text" DEFAULT ''::"text" NOT NULL,
    "title_key" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "description_key" "text" DEFAULT ''::"text" NOT NULL,
    "icon" "text" DEFAULT ''::"text" NOT NULL,
    "is_active" boolean DEFAULT true,
    "sort_order" integer DEFAULT 0 NOT NULL,
    "schema_name" "text" NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "realtime" boolean DEFAULT false NOT NULL,
    "gen_components" boolean DEFAULT false NOT NULL,
    "gen_pages" boolean DEFAULT false NOT NULL,
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("table_name", ''::"text")) || ' '::"text") || COALESCE("title", ''::"text")) || ' '::"text") || COALESCE("description", ''::"text")))) STORED
);


ALTER TABLE "mod_datalayer"."tables" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "mod_datalayer"."user_profiles_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_datalayer"."user_profiles_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_manufacturing"."coil_consumption" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "coil_id" "uuid" NOT NULL,
    "production_plan_id" "uuid" NOT NULL,
    "work_order_id" "uuid",
    "consumed_weight_kg" numeric(12,4) DEFAULT 0 NOT NULL,
    "consumed_length_m" numeric(12,4) DEFAULT 0 NOT NULL,
    "plates_produced" integer DEFAULT 0 NOT NULL,
    "waste_weight_kg" numeric(12,4) DEFAULT 0 NOT NULL,
    "consumption_date" timestamp without time zone DEFAULT "now"() NOT NULL,
    "operator_id" "uuid",
    "quality_grade" "text" DEFAULT 'A'::"text",
    "defect_notes" "text" DEFAULT ''::"text",
    "domain_id" "uuid",
    "shared_with" "text"[] DEFAULT ARRAY[]::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "coil_consumption_consumed_length_m_check" CHECK (("consumed_length_m" >= (0)::numeric)),
    CONSTRAINT "coil_consumption_consumed_weight_kg_check" CHECK (("consumed_weight_kg" >= (0)::numeric)),
    CONSTRAINT "coil_consumption_plates_produced_check" CHECK (("plates_produced" >= 0)),
    CONSTRAINT "coil_consumption_quality_grade_check" CHECK (("quality_grade" = ANY (ARRAY['A'::"text", 'B'::"text", 'C'::"text", 'Scrap'::"text"]))),
    CONSTRAINT "coil_consumption_waste_weight_kg_check" CHECK (("waste_weight_kg" >= (0)::numeric))
);


ALTER TABLE "mod_manufacturing"."coil_consumption" OWNER TO "postgres";


COMMENT ON TABLE "mod_manufacturing"."coil_consumption" IS 'Tracking of actual coil consumption during production';



CREATE TABLE IF NOT EXISTS "mod_manufacturing"."coil_production_plans" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "coil_id" "uuid" NOT NULL,
    "plate_template_id" "uuid" NOT NULL,
    "work_order_id" "uuid",
    "planned_quantity" integer DEFAULT 0 NOT NULL,
    "committed_quantity" integer DEFAULT 0 NOT NULL,
    "produced_quantity" integer DEFAULT 0 NOT NULL,
    "planned_start_date" timestamp without time zone,
    "planned_end_date" timestamp without time zone,
    "actual_start_date" timestamp without time zone,
    "actual_end_date" timestamp without time zone,
    "status" "text" DEFAULT 'planned'::"text" NOT NULL,
    "priority" integer DEFAULT 3,
    "quality_notes" "text" DEFAULT ''::"text",
    "batch_code" "text" DEFAULT ''::"text",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid",
    "shared_with" "text"[] DEFAULT ARRAY[]::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "coil_production_plans_committed_quantity_check" CHECK (("committed_quantity" >= 0)),
    CONSTRAINT "coil_production_plans_planned_quantity_check" CHECK (("planned_quantity" > 0)),
    CONSTRAINT "coil_production_plans_priority_check" CHECK ((("priority" >= 1) AND ("priority" <= 5))),
    CONSTRAINT "coil_production_plans_produced_quantity_check" CHECK (("produced_quantity" >= 0)),
    CONSTRAINT "coil_production_plans_status_check" CHECK (("status" = ANY (ARRAY['planned'::"text", 'in_progress'::"text", 'completed'::"text", 'cancelled'::"text"])))
);


ALTER TABLE "mod_manufacturing"."coil_production_plans" OWNER TO "postgres";


COMMENT ON TABLE "mod_manufacturing"."coil_production_plans" IS 'Production planning for converting coils into plates';



COMMENT ON COLUMN "mod_manufacturing"."coil_production_plans"."batch_code" IS 'QR code format: Year letter + 4 digits (A=2025, B=2026, etc.)';



CREATE TABLE IF NOT EXISTS "mod_manufacturing"."coils" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "coil_number" "text" DEFAULT ''::"text" NOT NULL,
    "material_type" "text" DEFAULT ''::"text" NOT NULL,
    "thickness" numeric(10,4) DEFAULT 0 NOT NULL,
    "width" numeric(10,4) DEFAULT 0 NOT NULL,
    "weight_kg" numeric(12,4) DEFAULT 0 NOT NULL,
    "length_m" numeric(12,4) DEFAULT 0,
    "batch_id" "uuid",
    "casting_number" "text" DEFAULT ''::"text",
    "supplier_id" "uuid",
    "purchase_date" "date",
    "status" "text" DEFAULT 'received'::"text" NOT NULL,
    "location_id" "uuid",
    "quality_grade" "text" DEFAULT 'A'::"text",
    "certification_document" "text" DEFAULT ''::"text",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid",
    "shared_with" "text"[] DEFAULT ARRAY[]::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "coils_quality_grade_check" CHECK (("quality_grade" = ANY (ARRAY['A'::"text", 'B'::"text", 'C'::"text"]))),
    CONSTRAINT "coils_status_check" CHECK (("status" = ANY (ARRAY['received'::"text", 'in_production'::"text", 'consumed'::"text", 'scrapped'::"text"]))),
    CONSTRAINT "coils_weight_kg_check" CHECK (("weight_kg" >= (0)::numeric))
);


ALTER TABLE "mod_manufacturing"."coils" OWNER TO "postgres";


COMMENT ON TABLE "mod_manufacturing"."coils" IS 'Metal coils inventory for stamping operations';



COMMENT ON COLUMN "mod_manufacturing"."coils"."weight_kg" IS 'Weight in kilograms - system warns if < 50kg';



CREATE TABLE IF NOT EXISTS "mod_manufacturing"."departments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_manufacturing"."departments" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "mod_manufacturing"."departments_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_manufacturing"."departments_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_manufacturing"."locations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "department_id" "uuid",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_manufacturing"."locations" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "mod_manufacturing"."notifications_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_manufacturing"."notifications_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_manufacturing"."plate_templates" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "template_number" "text" DEFAULT ''::"text" NOT NULL,
    "plate_type" "text" DEFAULT ''::"text" NOT NULL,
    "dimensions_length" numeric(10,4) DEFAULT 0 NOT NULL,
    "dimensions_width" numeric(10,4) DEFAULT 0 NOT NULL,
    "material_thickness" numeric(10,4) DEFAULT 0 NOT NULL,
    "weight_per_plate" numeric(10,4) DEFAULT 0 NOT NULL,
    "plates_per_coil_meter" numeric(10,4) DEFAULT 0 NOT NULL,
    "waste_factor" numeric(5,4) DEFAULT 0.05 NOT NULL,
    "setup_time_minutes" integer DEFAULT 30,
    "cycle_time_seconds" integer DEFAULT 60,
    "compatible_materials" "text"[] DEFAULT ARRAY[]::"text"[] NOT NULL,
    "min_coil_thickness" numeric(10,4) DEFAULT 0,
    "max_coil_thickness" numeric(10,4) DEFAULT 0,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid",
    "shared_with" "text"[] DEFAULT ARRAY[]::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_manufacturing"."plate_templates" OWNER TO "postgres";


COMMENT ON TABLE "mod_manufacturing"."plate_templates" IS 'Templates defining specifications for different plate types';



CREATE TABLE IF NOT EXISTS "mod_manufacturing"."production_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "work_order_id" "uuid" NOT NULL,
    "work_step_id" "uuid" NOT NULL,
    "operation_number" integer NOT NULL,
    "status" "text",
    "produced_quantity" integer,
    "rejected_quantity" integer,
    "estimated_duration" interval,
    "actual_duration" interval,
    "started_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "completed_at" timestamp without time zone,
    "operator_id" "uuid" NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "production_logs_produced_quantity_check" CHECK (("produced_quantity" >= 0)),
    CONSTRAINT "production_logs_rejected_quantity_check" CHECK (("rejected_quantity" >= 0)),
    CONSTRAINT "production_logs_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'in_progress'::"text", 'completed'::"text", 'failed'::"text"])))
);


ALTER TABLE "mod_manufacturing"."production_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_manufacturing"."recipes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "finished_product_id" "uuid" NOT NULL,
    "source_article_id" "uuid" NOT NULL,
    "destination_article_id" "uuid",
    "sequence_number" integer NOT NULL,
    "instructions" "text" DEFAULT ''::"text" NOT NULL,
    "estimated_duration" interval,
    "source_article_qty" numeric NOT NULL,
    "destination_article_qty" numeric,
    "source_article_uom" "text",
    "destination_article_uom" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"(),
    "updated_by" "uuid" DEFAULT "auth"."uid"(),
    "domain_id" "uuid",
    "shared_with" "text"[],
    "is_deleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "recipes_destination_article_qty_check" CHECK (("destination_article_qty" > (0)::numeric)),
    CONSTRAINT "recipes_sequence_number_check" CHECK (("sequence_number" > 0)),
    CONSTRAINT "recipes_source_article_qty_check" CHECK (("source_article_qty" > (0)::numeric))
);


ALTER TABLE "mod_manufacturing"."recipes" OWNER TO "postgres";


COMMENT ON TABLE "mod_manufacturing"."recipes" IS 'Stores manufacturing recipes defining how source articles are transformed into finished products';



COMMENT ON COLUMN "mod_manufacturing"."recipes"."finished_product_id" IS 'The final product article ID that will be produced';



COMMENT ON COLUMN "mod_manufacturing"."recipes"."source_article_id" IS 'The source/input article ID needed for this manufacturing step';



COMMENT ON COLUMN "mod_manufacturing"."recipes"."destination_article_id" IS 'The intermediate/output article ID produced in this step';



COMMENT ON COLUMN "mod_manufacturing"."recipes"."sequence_number" IS 'The order in which manufacturing steps should be processed (starts from 1)';



COMMENT ON COLUMN "mod_manufacturing"."recipes"."instructions" IS 'Manufacturing instructions for this step';



COMMENT ON COLUMN "mod_manufacturing"."recipes"."estimated_duration" IS 'Estimated time needed for this manufacturing step';



COMMENT ON COLUMN "mod_manufacturing"."recipes"."source_article_qty" IS 'The quantity of source article needed';



COMMENT ON COLUMN "mod_manufacturing"."recipes"."destination_article_qty" IS 'The quantity of destination article produced';



COMMENT ON COLUMN "mod_manufacturing"."recipes"."source_article_uom" IS 'Optional unit of measure for the source article quantity';



COMMENT ON COLUMN "mod_manufacturing"."recipes"."destination_article_uom" IS 'Optional unit of measure for the destination article quantity';



CREATE TABLE IF NOT EXISTS "mod_manufacturing"."scheduled_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "sales_order_item_id" "uuid" NOT NULL,
    "sales_order_id" "uuid" NOT NULL,
    "article_id" "uuid" NOT NULL,
    "scheduled_date" "date" NOT NULL,
    "status" "text" DEFAULT 'scheduled'::"text" NOT NULL,
    "domain_id" "uuid",
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "scheduled_items_status_check" CHECK (("status" = ANY (ARRAY['scheduled'::"text", 'in_progress'::"text", 'completed'::"text", 'canceled'::"text"])))
);


ALTER TABLE "mod_manufacturing"."scheduled_items" OWNER TO "postgres";


COMMENT ON TABLE "mod_manufacturing"."scheduled_items" IS 'Tracks which sales order items are scheduled for production';



COMMENT ON COLUMN "mod_manufacturing"."scheduled_items"."sales_order_item_id" IS 'Reference to the specific sales order item';



COMMENT ON COLUMN "mod_manufacturing"."scheduled_items"."sales_order_id" IS 'Reference to the sales order';



COMMENT ON COLUMN "mod_manufacturing"."scheduled_items"."article_id" IS 'Reference to the article being produced';



COMMENT ON COLUMN "mod_manufacturing"."scheduled_items"."scheduled_date" IS 'Date when this item was scheduled for production';



COMMENT ON COLUMN "mod_manufacturing"."scheduled_items"."status" IS 'Current status of the scheduled item';



CREATE TABLE IF NOT EXISTS "mod_manufacturing"."work_cycle_categories" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "work_flow_id" "uuid" NOT NULL,
    "work_cycle_id" "uuid" NOT NULL,
    "from_article_category_id" "uuid",
    "to_article_category_id" "uuid",
    "location_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "mod_manufacturing"."work_cycle_categories" OWNER TO "postgres";


COMMENT ON TABLE "mod_manufacturing"."work_cycle_categories" IS 'Maps work cycles to their input/output article categories and locations within workflows';



COMMENT ON COLUMN "mod_manufacturing"."work_cycle_categories"."from_article_category_id" IS 'Input article category for this work cycle';



COMMENT ON COLUMN "mod_manufacturing"."work_cycle_categories"."to_article_category_id" IS 'Output article category for this work cycle';



COMMENT ON COLUMN "mod_manufacturing"."work_cycle_categories"."location_id" IS 'Warehouse location where this work cycle occurs';



CREATE TABLE IF NOT EXISTS "mod_manufacturing"."work_cycles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "sort_order" integer NOT NULL,
    "estimated_time" interval,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "type" "text",
    "sub_type" "text",
    "department_id" "uuid",
    "required_for_all" boolean DEFAULT false NOT NULL,
    CONSTRAINT "work_cycles_sort_order_check" CHECK (("sort_order" > 0)),
    CONSTRAINT "work_cycles_sub_type_check" CHECK (("sub_type" = ANY (ARRAY['production'::"text", 'assembly'::"text", 'disassembly'::"text", 'maintenance'::"text", 'quality_control'::"text"]))),
    CONSTRAINT "work_cycles_type_check" CHECK (("type" = ANY (ARRAY['manufacturing'::"text", 'maintenance'::"text", 'quality_control'::"text"])))
);


ALTER TABLE "mod_manufacturing"."work_cycles" OWNER TO "postgres";


COMMENT ON TABLE "mod_manufacturing"."work_cycles" IS 'Work cycles define manufacturing and operational processes. TAGLIO_LASER and PRESSA_IDRAULICA are specific cycles for plate material production in the Produzione piastre workflow.';



COMMENT ON COLUMN "mod_manufacturing"."work_cycles"."required_for_all" IS 'Indicates whether this work cycle is required for all work orders in the manufacturing process';



CREATE TABLE IF NOT EXISTS "mod_manufacturing"."work_flows" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "mod_manufacturing"."work_flows" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_manufacturing"."work_flows_work_cycles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "work_flow_id" "uuid" NOT NULL,
    "work_cycle_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "mod_manufacturing"."work_flows_work_cycles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_manufacturing"."work_order_attachments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "work_order_id" "uuid" NOT NULL,
    "file_url" "text" NOT NULL,
    "file_name" "text" NOT NULL,
    "file_size" bigint NOT NULL,
    "file_type" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "mod_manufacturing"."work_order_attachments" OWNER TO "postgres";


COMMENT ON TABLE "mod_manufacturing"."work_order_attachments" IS 'File attachments for work order records';



COMMENT ON COLUMN "mod_manufacturing"."work_order_attachments"."id" IS 'Primary key for the attachment';



COMMENT ON COLUMN "mod_manufacturing"."work_order_attachments"."work_order_id" IS 'Foreign key reference to the work order record';



COMMENT ON COLUMN "mod_manufacturing"."work_order_attachments"."file_url" IS 'URL to the stored file in Supabase storage';



COMMENT ON COLUMN "mod_manufacturing"."work_order_attachments"."file_name" IS 'Original name of the uploaded file';



COMMENT ON COLUMN "mod_manufacturing"."work_order_attachments"."file_size" IS 'Size of the file in bytes';



COMMENT ON COLUMN "mod_manufacturing"."work_order_attachments"."file_type" IS 'MIME type of the file';



CREATE TABLE IF NOT EXISTS "mod_manufacturing"."work_order_quality_summary" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "work_order_id" "uuid" NOT NULL,
    "passed_count" integer DEFAULT 0 NOT NULL,
    "failed_count" integer DEFAULT 0 NOT NULL,
    "total_count" integer DEFAULT 0 NOT NULL,
    "overall_status" "text" DEFAULT 'PENDING'::"text" NOT NULL,
    "inspector_notes" "text" DEFAULT ''::"text",
    "inspector_id" "uuid",
    "completed_at" timestamp with time zone,
    "domain_id" "uuid",
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "non_negative_counts" CHECK ((("passed_count" >= 0) AND ("failed_count" >= 0) AND ("total_count" >= 0))),
    CONSTRAINT "work_order_quality_summary_overall_status_check" CHECK (("overall_status" = ANY (ARRAY['PENDING'::"text", 'IN_PROGRESS'::"text", 'PASSED'::"text", 'FAILED'::"text", 'PARTIAL'::"text"])))
);


ALTER TABLE "mod_manufacturing"."work_order_quality_summary" OWNER TO "postgres";


COMMENT ON TABLE "mod_manufacturing"."work_order_quality_summary" IS 'Quality summary for work orders tracking overall production quality results. Counts are flexible and do not require mathematical relationships.';



COMMENT ON COLUMN "mod_manufacturing"."work_order_quality_summary"."work_order_id" IS 'Reference to the work order this quality summary belongs to';



COMMENT ON COLUMN "mod_manufacturing"."work_order_quality_summary"."passed_count" IS 'Number of units that passed quality control';



COMMENT ON COLUMN "mod_manufacturing"."work_order_quality_summary"."failed_count" IS 'Number of units that failed quality control';



COMMENT ON COLUMN "mod_manufacturing"."work_order_quality_summary"."total_count" IS 'Total number of units inspected (must equal passed_count + failed_count)';



COMMENT ON COLUMN "mod_manufacturing"."work_order_quality_summary"."overall_status" IS 'Overall quality status: PENDING, IN_PROGRESS, PASSED, FAILED, or PARTIAL';



COMMENT ON COLUMN "mod_manufacturing"."work_order_quality_summary"."inspector_notes" IS 'Notes from the quality inspector';



COMMENT ON COLUMN "mod_manufacturing"."work_order_quality_summary"."inspector_id" IS 'ID of the inspector who completed the quality summary';



COMMENT ON COLUMN "mod_manufacturing"."work_order_quality_summary"."completed_at" IS 'Timestamp when quality summary was completed';



CREATE TABLE IF NOT EXISTS "mod_manufacturing"."work_orders" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "article_id" "uuid" NOT NULL,
    "quantity" integer,
    "responsible_id" "uuid",
    "status" "text",
    "priority" integer DEFAULT 1,
    "notes" "text" DEFAULT ''::"text" NOT NULL,
    "scheduled_start" timestamp without time zone,
    "scheduled_end" timestamp without time zone,
    "actual_start" timestamp without time zone,
    "actual_end" timestamp without time zone,
    "work_cycle_id" "uuid",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "sales_order_id" "uuid",
    "task_id" "uuid",
    "sort_number" integer,
    "article_unloaded" boolean DEFAULT false NOT NULL,
    "article_loaded" boolean DEFAULT false NOT NULL,
    "internal_sales_order_id" "uuid",
    "warehouse_id" "uuid",
    "location_id" "uuid",
    "is_print" boolean DEFAULT false NOT NULL,
    "is_archived" boolean DEFAULT false NOT NULL,
    "need_unload" boolean DEFAULT true NOT NULL,
    CONSTRAINT "work_orders_quantity_check" CHECK (("quantity" > 0)),
    CONSTRAINT "work_orders_single_sales_order_check" CHECK (((("sales_order_id" IS NOT NULL) AND ("internal_sales_order_id" IS NULL)) OR (("sales_order_id" IS NULL) AND ("internal_sales_order_id" IS NOT NULL)) OR (("sales_order_id" IS NULL) AND ("internal_sales_order_id" IS NULL)))),
    CONSTRAINT "work_orders_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'in_progress'::"text", 'completed'::"text", 'canceled'::"text", 'paused'::"text"])))
);


ALTER TABLE "mod_manufacturing"."work_orders" OWNER TO "postgres";


COMMENT ON COLUMN "mod_manufacturing"."work_orders"."sales_order_id" IS 'Reference to the associated sales order';



COMMENT ON COLUMN "mod_manufacturing"."work_orders"."article_unloaded" IS 'Indicates whether the article has been unloaded from the work order';



COMMENT ON COLUMN "mod_manufacturing"."work_orders"."article_loaded" IS 'Indicates whether the article has been loaded for the work order';



COMMENT ON COLUMN "mod_manufacturing"."work_orders"."internal_sales_order_id" IS 'References internal_sales_orders table - mutually exclusive with sales_order_id';



COMMENT ON COLUMN "mod_manufacturing"."work_orders"."warehouse_id" IS 'Reference to the warehouse where this work order is associated. Links to mod_wms.warehouses table.';



COMMENT ON COLUMN "mod_manufacturing"."work_orders"."location_id" IS 'Reference to the specific location within a warehouse where this work order is associated. Links to mod_wms.locations table.';



COMMENT ON COLUMN "mod_manufacturing"."work_orders"."is_print" IS 'Indicates whether the work order has been printed';



COMMENT ON COLUMN "mod_manufacturing"."work_orders"."is_archived" IS 'Indicates whether the work order has been archived';



COMMENT ON COLUMN "mod_manufacturing"."work_orders"."need_unload" IS 'Indicates whether the work order needs to be unloaded. Default is TRUE.';



CREATE SEQUENCE IF NOT EXISTS "mod_manufacturing"."work_orders_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_manufacturing"."work_orders_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_manufacturing"."work_steps" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "type" "text" DEFAULT 'processing'::"text" NOT NULL,
    "sort_order" integer NOT NULL,
    "estimated_time" interval,
    "workstation_id" "uuid",
    "work_cycle_id" "uuid" NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "work_order_id" "uuid",
    "is_checked" boolean DEFAULT false NOT NULL,
    CONSTRAINT "work_steps_sort_order_check" CHECK (("sort_order" > 0)),
    CONSTRAINT "work_steps_type_check" CHECK (("type" = ANY (ARRAY['transport'::"text", 'processing'::"text", 'inspection'::"text", 'assembly'::"text", 'packaging'::"text", 'storage'::"text"])))
);


ALTER TABLE "mod_manufacturing"."work_steps" OWNER TO "postgres";


COMMENT ON COLUMN "mod_manufacturing"."work_steps"."workstation_id" IS 'Workstation where this work step is performed. Can be NULL if workstation is not yet assigned or not required.';



COMMENT ON COLUMN "mod_manufacturing"."work_steps"."work_order_id" IS 'Reference to the associated work order';



COMMENT ON COLUMN "mod_manufacturing"."work_steps"."is_checked" IS 'Indicates whether this work step has been checked/completed. Defaults to false.';



CREATE TABLE IF NOT EXISTS "mod_manufacturing"."workstations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "station_type" "text" NOT NULL,
    "operation_type" "text" NOT NULL,
    "max_capacity" integer DEFAULT 1,
    "location_id" "uuid",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "operation_type_check" CHECK (("operation_type" = ANY (ARRAY['manual'::"text", 'automatic'::"text", 'hybrid'::"text"]))),
    CONSTRAINT "station_type_check" CHECK (("station_type" = ANY (ARRAY['forklift'::"text", 'job shop'::"text", 'machine'::"text", 'hybrid'::"text"]))),
    CONSTRAINT "workstations_max_capacity_check" CHECK (("max_capacity" > 0)),
    CONSTRAINT "workstations_station_type_check" CHECK (("station_type" = ANY (ARRAY['forklift'::"text", 'job shop'::"text", 'machine'::"text", 'hybrid'::"text"])))
);


ALTER TABLE "mod_manufacturing"."workstations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_manufacturing"."workstations_duplicate" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "station_type" "text" NOT NULL,
    "operation_type" "text" NOT NULL,
    "max_capacity" integer DEFAULT 1,
    "location_id" "uuid",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "operation_type_check" CHECK (("operation_type" = ANY (ARRAY['manual'::"text", 'automatic'::"text", 'hybrid'::"text"]))),
    CONSTRAINT "station_type_check" CHECK (("station_type" = ANY (ARRAY['forklift'::"text", 'job shop'::"text", 'machine'::"text", 'hybrid'::"text"]))),
    CONSTRAINT "workstations_max_capacity_check" CHECK (("max_capacity" > 0)),
    CONSTRAINT "workstations_station_type_check" CHECK (("station_type" = ANY (ARRAY['forklift'::"text", 'job shop'::"text", 'machine'::"text", 'hybrid'::"text"])))
);


ALTER TABLE "mod_manufacturing"."workstations_duplicate" OWNER TO "postgres";


COMMENT ON TABLE "mod_manufacturing"."workstations_duplicate" IS 'This is a duplicate of workstations';



CREATE TABLE IF NOT EXISTS "mod_pulse"."department_notification_configs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "department_id" "uuid" NOT NULL,
    "notification_type" "text" NOT NULL,
    "is_enabled" boolean DEFAULT true NOT NULL,
    "domain_id" "uuid",
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "department_notification_configs_notification_type_check" CHECK (("notification_type" = ANY (ARRAY['new_pulse'::"text", 'update_pulse'::"text", 'new_message'::"text", 'sla_warning'::"text", 'warehouse_operation'::"text", 'low_stock_alert'::"text", 'new_sales_order'::"text", 'work_order_finished'::"text", 'inventory_received'::"text", 'quality_check_failed'::"text", 'maintenance_due'::"text"])))
);


ALTER TABLE "mod_pulse"."department_notification_configs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_pulse"."notifications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "user_id" "uuid",
    "pulse_id" "uuid",
    "type" "text",
    "is_read" boolean DEFAULT false,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "department_id" "uuid",
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("description", ''::"text")) || ' '::"text") || COALESCE("code", ''::"text")) || ' '::"text") || COALESCE("type", ''::"text")))) STORED,
    CONSTRAINT "notifications_type_check" CHECK (("type" = ANY (ARRAY['new_pulse'::"text", 'update_pulse'::"text", 'new_message'::"text", 'sla_warning'::"text", 'new_mentioned'::"text"])))
);


ALTER TABLE "mod_pulse"."notifications" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "mod_pulse"."notifications_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_pulse"."notifications_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_pulse"."pulse_chat" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "pulse_id" "uuid" NOT NULL,
    "message" "text" DEFAULT ''::"text" NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "message_type" "text" DEFAULT 'text'::"text",
    "reply_to_id" "uuid",
    "is_edited" boolean DEFAULT false,
    "edit_history" "jsonb" DEFAULT '[]'::"jsonb",
    "read_by" "text"[] DEFAULT '{}'::"text"[],
    "delivered_to" "text"[] DEFAULT '{}'::"text"[],
    "mentions" "text"[] DEFAULT '{}'::"text"[],
    "reactions" "jsonb" DEFAULT '{}'::"jsonb",
    CONSTRAINT "pulse_chat_message_type_check" CHECK (("message_type" = ANY (ARRAY['text'::"text", 'image'::"text", 'file'::"text", 'system'::"text", 'notification'::"text"])))
);


ALTER TABLE "mod_pulse"."pulse_chat" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_pulse"."pulse_chat_files" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "message_id" "uuid" NOT NULL,
    "file_url" "text" NOT NULL,
    "file_name" "text" NOT NULL,
    "file_size" integer DEFAULT 0 NOT NULL,
    "file_type" "text" NOT NULL,
    "thumbnail_url" "text" DEFAULT ''::"text" NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "domain_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_pulse"."pulse_chat_files" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_pulse"."pulse_checklists" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "pulse_id" "uuid" NOT NULL,
    "is_completed" boolean DEFAULT false,
    "completed_at" timestamp with time zone,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_pulse"."pulse_checklists" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_pulse"."pulse_comments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "pulse_id" "uuid" NOT NULL,
    "comment" "text" DEFAULT ''::"text" NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_pulse"."pulse_comments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_pulse"."pulse_conversation_participants" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "pulse_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" "text" DEFAULT 'member'::"text" NOT NULL,
    "is_muted" boolean DEFAULT false NOT NULL,
    "last_read_message_id" "uuid",
    "last_read_at" timestamp with time zone,
    "notification_level" "text" DEFAULT 'all'::"text" NOT NULL,
    "joined_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "domain_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "pulse_conversation_participants_notification_level_check" CHECK (("notification_level" = ANY (ARRAY['all'::"text", 'mentions'::"text", 'none'::"text"]))),
    CONSTRAINT "pulse_conversation_participants_role_check" CHECK (("role" = ANY (ARRAY['admin'::"text", 'member'::"text", 'guest'::"text"])))
);


ALTER TABLE "mod_pulse"."pulse_conversation_participants" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_pulse"."pulse_progress" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "pulse_id" "uuid" NOT NULL,
    "new_status" "text",
    "new_priority" "text",
    "new_assigned_to" "uuid",
    "new_sla_id" "uuid",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("description", ''::"text")) || ' '::"text") || COALESCE("code", ''::"text")) || ' '::"text") || COALESCE("new_status", ''::"text")) || ' '::"text") || COALESCE("new_priority", ''::"text")))) STORED,
    CONSTRAINT "pulse_progress_new_priority_check" CHECK (("new_priority" = ANY (ARRAY['low'::"text", 'medium'::"text", 'high'::"text", 'urgent'::"text"]))),
    CONSTRAINT "pulse_progress_new_status_check" CHECK (("new_status" = ANY (ARRAY['open'::"text", 'in_progress'::"text", 'resolved'::"text", 'closed'::"text", 'on_hold'::"text"])))
);


ALTER TABLE "mod_pulse"."pulse_progress" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_pulse"."pulse_slas" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "response_time" interval NOT NULL,
    "resolution_time" interval NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("description", ''::"text")) || ' '::"text") || COALESCE("code", ''::"text")))) STORED
);


ALTER TABLE "mod_pulse"."pulse_slas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_pulse"."pulses" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "type" "text" DEFAULT 'task'::"text",
    "status" "text" DEFAULT 'open'::"text",
    "priority" "text" DEFAULT 'medium'::"text",
    "assigned_to" "uuid",
    "sla_id" "uuid",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "conversation_type" "text",
    "department_id" "uuid",
    "last_message_at" timestamp with time zone DEFAULT "now"(),
    "last_message_preview" "text" DEFAULT ''::"text",
    "last_message_sender_id" "uuid",
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((((((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("description", ''::"text")) || ' '::"text") || COALESCE("code", ''::"text")) || ' '::"text") || COALESCE("type", ''::"text")) || ' '::"text") || COALESCE("status", ''::"text")) || ' '::"text") || COALESCE("priority", ''::"text")))) STORED,
    CONSTRAINT "pulses_conversation_type_check" CHECK (("conversation_type" = ANY (ARRAY['department'::"text", 'direct_message'::"text", 'group'::"text", 'task'::"text", 'issue'::"text"]))),
    CONSTRAINT "pulses_priority_check" CHECK (("priority" = ANY (ARRAY['low'::"text", 'medium'::"text", 'high'::"text", 'urgent'::"text"]))),
    CONSTRAINT "pulses_status_check" CHECK (("status" = ANY (ARRAY['open'::"text", 'in_progress'::"text", 'resolved'::"text", 'closed'::"text", 'on_hold'::"text"]))),
    CONSTRAINT "pulses_type_check" CHECK (("type" = ANY (ARRAY['task'::"text", 'issue'::"text", 'incident'::"text", 'risk'::"text", 'change_request'::"text", 'production'::"text", 'stock_movement'::"text"])))
);


ALTER TABLE "mod_pulse"."pulses" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "mod_pulse"."pulses_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_pulse"."pulses_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_pulse"."tasks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "pulse_id" "uuid",
    "assigned_id" "uuid",
    "status" "text" DEFAULT 'pending'::"text",
    "priority" "text" DEFAULT 'medium'::"text",
    "due_date" timestamp with time zone,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "assigned_department_id" "uuid",
    "status_history" "jsonb" DEFAULT '[]'::"jsonb",
    "fts" "tsvector" GENERATED ALWAYS AS ("to_tsvector"('"english"'::"regconfig", ((((((((COALESCE("name", ''::"text") || ' '::"text") || COALESCE("description", ''::"text")) || ' '::"text") || COALESCE("code", ''::"text")) || ' '::"text") || COALESCE("status", ''::"text")) || ' '::"text") || COALESCE("priority", ''::"text")))) STORED,
    CONSTRAINT "tasks_assignment_check" CHECK ((("assigned_id" IS NOT NULL) OR ("assigned_department_id" IS NOT NULL) OR ("domain_id" IS NULL))),
    CONSTRAINT "tasks_priority_check" CHECK (("priority" = ANY (ARRAY['low'::"text", 'medium'::"text", 'high'::"text", 'urgent'::"text"]))),
    CONSTRAINT "tasks_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'in_progress'::"text", 'completed'::"text", 'blocked'::"text"])))
);


ALTER TABLE "mod_pulse"."tasks" OWNER TO "postgres";


COMMENT ON COLUMN "mod_pulse"."tasks"."assigned_department_id" IS 'Reference to the department this task is assigned to';



COMMENT ON COLUMN "mod_pulse"."tasks"."status_history" IS 'History of status changes with timestamps and users';



COMMENT ON CONSTRAINT "tasks_assignment_check" ON "mod_pulse"."tasks" IS 'Ensures a task is assigned to either a user, a department, or has no domain';



CREATE SEQUENCE IF NOT EXISTS "mod_pulse"."tasks_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_pulse"."tasks_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_quality_control"."conformity_documents" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "quality_control_id" "uuid",
    "supplier_id" "uuid",
    "article_id" "uuid",
    "document_type" "text" NOT NULL,
    "document_number" "text" NOT NULL,
    "document_date" "date",
    "expiry_date" "date",
    "issuing_authority" "text",
    "file_path" "text",
    "file_name" "text",
    "file_size" integer,
    "is_verified" boolean DEFAULT false,
    "verified_by" "uuid",
    "verified_at" timestamp with time zone,
    "verification_notes" "text",
    "shared_with" "text"[] DEFAULT ARRAY[]::"text"[],
    "is_deleted" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "conformity_documents_document_type_check" CHECK (("document_type" = ANY (ARRAY['MILL_TEST_CERTIFICATE'::"text", 'MATERIAL_TEST_REPORT'::"text", 'CERTIFICATE_OF_CONFORMITY'::"text", 'CERTIFICATE_OF_ANALYSIS'::"text", 'THIRD_PARTY_INSPECTION'::"text", 'ASME_CERTIFICATE'::"text", 'PED_CERTIFICATE'::"text", 'ISO_CERTIFICATE'::"text", 'OTHER'::"text"])))
);


ALTER TABLE "mod_quality_control"."conformity_documents" OWNER TO "postgres";


COMMENT ON TABLE "mod_quality_control"."conformity_documents" IS 'Storage and tracking of material conformity certificates and documents';



CREATE TABLE IF NOT EXISTS "mod_quality_control"."defect_types" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "category" "text" NOT NULL,
    "is_active" boolean DEFAULT true,
    "shared_with" "text"[] DEFAULT ARRAY[]::"text"[],
    "is_deleted" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_quality_control"."defect_types" OWNER TO "postgres";


COMMENT ON TABLE "mod_quality_control"."defect_types" IS 'Catalog of possible defect types';



CREATE TABLE IF NOT EXISTS "mod_quality_control"."measurement_parameters" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "unit" "text",
    "decimal_places" integer DEFAULT 2,
    "is_active" boolean DEFAULT true,
    "shared_with" "text"[] DEFAULT ARRAY[]::"text"[],
    "is_deleted" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_quality_control"."measurement_parameters" OWNER TO "postgres";


COMMENT ON TABLE "mod_quality_control"."measurement_parameters" IS 'Catalog of measurable parameters';



CREATE TABLE IF NOT EXISTS "mod_quality_control"."quality_control_measurements" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "quality_control_id" "uuid",
    "parameter_id" "uuid",
    "expected_value" numeric,
    "actual_value" numeric,
    "tolerance_min" numeric,
    "tolerance_max" numeric,
    "unit" "text",
    "is_within_spec" boolean,
    "measurement_tool" "text",
    "inspector_notes" "text",
    "measured_at" timestamp with time zone DEFAULT "now"(),
    "shared_with" "text"[] DEFAULT ARRAY[]::"text"[],
    "is_deleted" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_quality_control"."quality_control_measurements" OWNER TO "postgres";


COMMENT ON TABLE "mod_quality_control"."quality_control_measurements" IS 'Measurements taken during quality control inspections';



CREATE OR REPLACE VIEW "mod_quality_control"."supplier_returns_summary" AS
 SELECT "sr"."id",
    "sr"."return_number",
    "sr"."return_date",
    "sr"."return_status",
    "sr"."return_quantity",
    "sr"."total_cost",
    "sr"."credit_amount",
    "s"."name" AS "supplier_name",
    "a"."name" AS "article_name",
    "qc"."code" AS "qc_code",
    "sr"."created_at",
    "sr"."updated_at"
   FROM ((("mod_quality_control"."supplier_returns" "sr"
     LEFT JOIN "mod_base"."suppliers" "s" ON (("sr"."supplier_id" = "s"."id")))
     LEFT JOIN "mod_base"."articles" "a" ON (("sr"."article_id" = "a"."id")))
     LEFT JOIN "mod_base"."quality_control" "qc" ON (("sr"."quality_control_id" = "qc"."id")))
  WHERE (NOT "sr"."is_deleted");


ALTER VIEW "mod_quality_control"."supplier_returns_summary" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_wms"."batches" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "batch_number" "text" DEFAULT ''::"text" NOT NULL,
    "production_date" "date",
    "expiration_date" "date",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_wms"."batches" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_wms"."box_contents" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "shipment_box_id" "uuid" NOT NULL,
    "shipment_item_id" "uuid" NOT NULL,
    "quantity_packed" integer DEFAULT 0 NOT NULL,
    "notes" "text",
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "box_contents_quantity_positive" CHECK (("quantity_packed" > 0))
);


ALTER TABLE "mod_wms"."box_contents" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_wms"."box_types" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "dimensions_length" integer,
    "dimensions_width" integer,
    "dimensions_height" integer,
    "max_weight" numeric(10,2),
    "description" "text",
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_wms"."box_types" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_wms"."carton_contents" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "shipment_carton_id" "uuid" NOT NULL,
    "shipment_item_id" "uuid" NOT NULL,
    "quantity_packed" integer DEFAULT 0 NOT NULL,
    "notes" "text",
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "carton_contents_quantity_positive" CHECK (("quantity_packed" > 0))
);


ALTER TABLE "mod_wms"."carton_contents" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_wms"."carton_types" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "dimensions_length" integer,
    "dimensions_width" integer,
    "dimensions_height" integer,
    "max_weight" numeric(10,2),
    "description" "text",
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_wms"."carton_types" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_wms"."locations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "type" "text",
    "capacity" integer DEFAULT 0,
    "is_active" boolean DEFAULT true NOT NULL,
    "warehouse_id" "uuid" NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "locations_type_check" CHECK (("type" = ANY (ARRAY['aisle'::"text", 'rack'::"text", 'bin'::"text", 'bulk'::"text"])))
);


ALTER TABLE "mod_wms"."locations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_wms"."stock_movements" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "article_id" "uuid" NOT NULL,
    "batch_id" "uuid",
    "from_location_id" "uuid",
    "to_location_id" "uuid",
    "quantity_moved" numeric(12,4) NOT NULL,
    "movement_date" timestamp with time zone DEFAULT "now"() NOT NULL,
    "reason" "text" DEFAULT ''::"text" NOT NULL,
    "reference_doc_type" "text" DEFAULT ''::"text" NOT NULL,
    "reference_doc_id" "uuid",
    "type" "text",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "unit_of_measure_id" "uuid",
    "receipt_item_id" "uuid",
    "work_order_id" "uuid",
    "sales_order_id" "uuid",
    "internal_sales_order_id" "uuid",
    "origin_article_id" "uuid",
    "original_receipt_item_id" "uuid",
    CONSTRAINT "stock_movements_type_check" CHECK (("type" = ANY (ARRAY['inbound'::"text", 'outbound'::"text", 'relocation'::"text", 'adjustment'::"text", 'allocation'::"text", 'allocation_release'::"text", 'loading'::"text", 'unloading'::"text", 'manual_loading'::"text", 'transport'::"text"])))
);


ALTER TABLE "mod_wms"."stock_movements" OWNER TO "postgres";


COMMENT ON TABLE "mod_wms"."stock_movements" IS 'Stock movements transaction log. This table records all inventory transactions but does NOT automatically update the inventory table. Inventory updates must be managed manually through application logic.';



COMMENT ON COLUMN "mod_wms"."stock_movements"."unit_of_measure_id" IS 'Unit of measure for the quantity moved in this stock movement';



COMMENT ON COLUMN "mod_wms"."stock_movements"."receipt_item_id" IS 'Foreign key reference to the receipt item that this stock movement is processing. NULL for movements not related to receipt items.';



COMMENT ON COLUMN "mod_wms"."stock_movements"."work_order_id" IS 'Foreign key reference to the work order that this stock movement is related to. NULL for movements not related to work orders.';



COMMENT ON COLUMN "mod_wms"."stock_movements"."sales_order_id" IS 'Foreign key reference to the sales order that this stock movement is related to. NULL for movements not related to sales orders.';



COMMENT ON COLUMN "mod_wms"."stock_movements"."internal_sales_order_id" IS 'Foreign key reference to the internal sales order that this stock movement is related to. NULL for movements not related to internal sales orders. A stock movement should have either sales_order_id OR internal_sales_order_id, matching the work order it is associated with.';



COMMENT ON COLUMN "mod_wms"."stock_movements"."origin_article_id" IS 'Foreign key reference to the original article that was intended to be moved. This field is used when a similar/alternative article is actually moved instead of the originally planned article. NULL when the movement uses the originally planned article.';



COMMENT ON COLUMN "mod_wms"."stock_movements"."original_receipt_item_id" IS 'Foreign key reference to the original receipt item that this stock originated from. Automatically populated by trigger: if receipt_item_id is provided, it is copied here; otherwise, the trigger traces back through stock_movements to find the original inbound movement with a receipt_item_id. NULL when stock origin cannot be traced to a receipt.';



CREATE OR REPLACE VIEW "mod_wms"."current_inventory" WITH ("security_invoker"='on') AS
 SELECT "sm"."article_id",
    "a"."name" AS "article_name",
    COALESCE("sm"."to_location_id", "sm"."from_location_id") AS "location_id",
    "l"."name" AS "location_name",
    "sm"."batch_id",
    "b"."batch_number",
    "sum"(
        CASE
            WHEN ("sm"."type" = 'inbound'::"text") THEN "sm"."quantity_moved"
            WHEN ("sm"."type" = 'adjustment'::"text") THEN "sm"."quantity_moved"
            WHEN (("sm"."type" = 'relocation'::"text") AND ("sm"."to_location_id" = COALESCE("sm"."to_location_id", "sm"."from_location_id"))) THEN "sm"."quantity_moved"
            WHEN (("sm"."type" = 'relocation'::"text") AND ("sm"."from_location_id" = COALESCE("sm"."to_location_id", "sm"."from_location_id"))) THEN (- "sm"."quantity_moved")
            WHEN ("sm"."type" = 'outbound'::"text") THEN (- "sm"."quantity_moved")
            ELSE (0)::numeric
        END) AS "quantity",
    0 AS "allocated_qty",
    "max"("sm"."movement_date") AS "last_movement_date",
    "min"("sm"."created_at") AS "created_at",
    "max"("sm"."updated_at") AS "updated_at"
   FROM ((("mod_wms"."stock_movements" "sm"
     JOIN "mod_base"."articles" "a" ON (("sm"."article_id" = "a"."id")))
     LEFT JOIN "mod_wms"."locations" "l" ON ((COALESCE("sm"."to_location_id", "sm"."from_location_id") = "l"."id")))
     LEFT JOIN "mod_wms"."batches" "b" ON (("sm"."batch_id" = "b"."id")))
  WHERE ("a"."is_deleted" = false)
  GROUP BY "sm"."article_id", "a"."name", COALESCE("sm"."to_location_id", "sm"."from_location_id"), "l"."name", "sm"."batch_id", "b"."batch_number"
 HAVING ("sum"(
        CASE
            WHEN ("sm"."type" = 'inbound'::"text") THEN "sm"."quantity_moved"
            WHEN ("sm"."type" = 'adjustment'::"text") THEN "sm"."quantity_moved"
            WHEN (("sm"."type" = 'relocation'::"text") AND ("sm"."to_location_id" = COALESCE("sm"."to_location_id", "sm"."from_location_id"))) THEN "sm"."quantity_moved"
            WHEN (("sm"."type" = 'relocation'::"text") AND ("sm"."from_location_id" = COALESCE("sm"."to_location_id", "sm"."from_location_id"))) THEN (- "sm"."quantity_moved")
            WHEN ("sm"."type" = 'outbound'::"text") THEN (- "sm"."quantity_moved")
            ELSE (0)::numeric
        END) > (0)::numeric);


ALTER VIEW "mod_wms"."current_inventory" OWNER TO "postgres";


COMMENT ON VIEW "mod_wms"."current_inventory" IS 'Calculates current inventory from stock movements. This replaces the trigger-based approach for better reliability and eliminates data synchronization issues.';



CREATE TABLE IF NOT EXISTS "mod_wms"."inventory" (
    "article_id" "uuid" NOT NULL,
    "location_id" "uuid" NOT NULL,
    "batch_id" "uuid",
    "quantity" numeric(12,4) DEFAULT 0 NOT NULL,
    "allocated_qty" numeric(12,4) DEFAULT 0 NOT NULL,
    "domain_id" "uuid",
    "shared_with" "text"[],
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid",
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    CONSTRAINT "inventory_check" CHECK ((("allocated_qty" >= (0)::numeric) AND ("allocated_qty" <= "quantity"))),
    CONSTRAINT "inventory_quantity_check" CHECK (("quantity" >= (0)::numeric))
);


ALTER TABLE "mod_wms"."inventory" OWNER TO "postgres";


COMMENT ON TABLE "mod_wms"."inventory" IS 'Current inventory levels. Supports multiple batches per article+location combination. 
Each record represents inventory for a specific article, location, and batch combination.
When batch_id is NULL, it represents non-batched inventory for that article+location.';



COMMENT ON COLUMN "mod_wms"."inventory"."batch_id" IS 'Optional batch reference. NULL indicates non-batched inventory. When specified, must be unique per article+location combination.';



COMMENT ON COLUMN "mod_wms"."inventory"."quantity" IS 'Current available quantity at this location. Updated by stock movement triggers.';



COMMENT ON COLUMN "mod_wms"."inventory"."allocated_qty" IS 'Quantity reserved/allocated for orders but not yet shipped. Must be <= quantity.';



CREATE TABLE IF NOT EXISTS "mod_wms"."inventory_backup" (
    "article_id" "uuid" NOT NULL,
    "location_id" "uuid" NOT NULL,
    "batch_id" "uuid" NOT NULL,
    "quantity" numeric(12,4) DEFAULT 0 NOT NULL,
    "allocated_qty" numeric(12,4) DEFAULT 0 NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_wms"."inventory_backup" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_wms"."inventory_limits" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "location_id" "uuid" NOT NULL,
    "article_id" "uuid" NOT NULL,
    "min_stock" integer,
    "max_stock" integer,
    "reorder_point" integer,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "inventory_limits_max_stock_check" CHECK (("max_stock" >= 0)),
    CONSTRAINT "inventory_limits_min_stock_check" CHECK (("min_stock" >= 0)),
    CONSTRAINT "inventory_limits_reorder_point_check" CHECK (("reorder_point" >= 0))
);


ALTER TABLE "mod_wms"."inventory_limits" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "mod_wms"."notifications_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_wms"."notifications_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_wms"."pallet_contents" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "shipment_pallet_id" "uuid" NOT NULL,
    "shipment_item_id" "uuid" NOT NULL,
    "quantity_packed" integer DEFAULT 0 NOT NULL,
    "notes" "text",
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "pallet_contents_quantity_positive" CHECK (("quantity_packed" > 0))
);


ALTER TABLE "mod_wms"."pallet_contents" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_wms"."pallet_types" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "dimensions_length" integer,
    "dimensions_width" integer,
    "dimensions_height" integer,
    "max_weight" numeric(10,2),
    "description" "text",
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_wms"."pallet_types" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "mod_wms"."pulses_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_wms"."pulses_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_wms"."receipt_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "receipt_id" "uuid" NOT NULL,
    "article_id" "uuid" NOT NULL,
    "quantity_ordered" numeric(12,4) NOT NULL,
    "quantity_received" numeric(12,4) DEFAULT 0 NOT NULL,
    "location_id" "uuid" NOT NULL,
    "batch_id" "uuid",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "qc_notes" "text" DEFAULT ''::"text",
    "qc_status" "text" DEFAULT 'PENDING'::"text",
    "qc_inspector_id" "uuid",
    "qc_completed_at" timestamp with time zone,
    "is_moved" boolean DEFAULT false NOT NULL,
    "moved_date" timestamp with time zone,
    "quantity_damaged" numeric(12,4) DEFAULT 0 NOT NULL,
    CONSTRAINT "receipt_items_qc_status_check" CHECK (("qc_status" = ANY (ARRAY['PENDING'::"text", 'IN_PROGRESS'::"text", 'PASSED'::"text", 'FAILED'::"text", 'REJECTED'::"text", 'ACCEPTED'::"text"])))
);


ALTER TABLE "mod_wms"."receipt_items" OWNER TO "postgres";


COMMENT ON COLUMN "mod_wms"."receipt_items"."qc_notes" IS 'Quality control inspection notes and findings';



COMMENT ON COLUMN "mod_wms"."receipt_items"."qc_status" IS 'Quality control status for the received item';



COMMENT ON COLUMN "mod_wms"."receipt_items"."qc_inspector_id" IS 'User who performed the quality control inspection';



COMMENT ON COLUMN "mod_wms"."receipt_items"."qc_completed_at" IS 'Timestamp when quality control was completed';



COMMENT ON COLUMN "mod_wms"."receipt_items"."is_moved" IS 'Indicates whether the receipt item has been moved to inventory. Defaults to FALSE.';



COMMENT ON COLUMN "mod_wms"."receipt_items"."moved_date" IS 'Timestamp when the receipt item was moved to inventory. NULL if not yet moved.';



COMMENT ON COLUMN "mod_wms"."receipt_items"."quantity_damaged" IS 'Quantity of items that were damaged during receipt. Defaults to 0.';



CREATE TABLE IF NOT EXISTS "mod_wms"."receipts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "warehouse_id" "uuid" NOT NULL,
    "purchase_order_id" "uuid",
    "receipt_number" "text" NOT NULL,
    "receipt_date" "date" NOT NULL,
    "expected_delivery_date" "date",
    "status" "text",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "transport_document_number" "text" DEFAULT ''::"text",
    "invoice_number" "text" DEFAULT ''::"text",
    "supplier_order_number" "text" DEFAULT ''::"text",
    "supplier_id" "uuid",
    CONSTRAINT "receipts_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'processing'::"text", 'in_transit'::"text", 'received'::"text", 'delivered'::"text", 'completed'::"text", 'failed'::"text"])))
);


ALTER TABLE "mod_wms"."receipts" OWNER TO "postgres";


COMMENT ON TABLE "mod_wms"."receipts" IS 'Migration 20251125184612: Created receipt for all other articles';



COMMENT ON COLUMN "mod_wms"."receipts"."transport_document_number" IS 'Transport document number from the supplier';



COMMENT ON COLUMN "mod_wms"."receipts"."invoice_number" IS 'Invoice number from the supplier';



COMMENT ON COLUMN "mod_wms"."receipts"."supplier_order_number" IS 'The supplier''s order number for reference and tracking';



COMMENT ON COLUMN "mod_wms"."receipts"."supplier_id" IS 'Direct reference to supplier for quick access, auto-populated from purchase order';



CREATE SEQUENCE IF NOT EXISTS "mod_wms"."receipts_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_wms"."receipts_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_wms"."shipment_attachments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "shipment_id" "uuid" NOT NULL,
    "file_path" "text" NOT NULL,
    "file_name" "text" NOT NULL,
    "file_size" bigint NOT NULL,
    "file_type" "text" NOT NULL,
    "attachment_type" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    CONSTRAINT "shipment_attachments_attachment_type_check" CHECK (("attachment_type" = ANY (ARRAY['document'::"text", 'photo'::"text"])))
);


ALTER TABLE "mod_wms"."shipment_attachments" OWNER TO "postgres";


COMMENT ON TABLE "mod_wms"."shipment_attachments" IS 'File attachments (documents and photos) for shipments';



COMMENT ON COLUMN "mod_wms"."shipment_attachments"."id" IS 'Primary key for the attachment';



COMMENT ON COLUMN "mod_wms"."shipment_attachments"."shipment_id" IS 'Foreign key reference to the shipment';



COMMENT ON COLUMN "mod_wms"."shipment_attachments"."file_path" IS 'Path to the stored file in Supabase storage';



COMMENT ON COLUMN "mod_wms"."shipment_attachments"."file_name" IS 'Original name of the uploaded file';



COMMENT ON COLUMN "mod_wms"."shipment_attachments"."file_size" IS 'Size of the file in bytes';



COMMENT ON COLUMN "mod_wms"."shipment_attachments"."file_type" IS 'MIME type of the file';



COMMENT ON COLUMN "mod_wms"."shipment_attachments"."attachment_type" IS 'Type of attachment: document or photo';



CREATE TABLE IF NOT EXISTS "mod_wms"."shipment_boxes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "shipment_pallet_id" "uuid",
    "box_type_id" "uuid" NOT NULL,
    "box_number" integer NOT NULL,
    "total_weight" numeric(10,2),
    "notes" "text",
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "shipment_id" "uuid",
    CONSTRAINT "shipment_boxes_parent_check" CHECK (((("shipment_pallet_id" IS NOT NULL) AND ("shipment_id" IS NULL)) OR (("shipment_pallet_id" IS NULL) AND ("shipment_id" IS NOT NULL))))
);


ALTER TABLE "mod_wms"."shipment_boxes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_wms"."shipment_cartons" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "shipment_pallet_id" "uuid" NOT NULL,
    "carton_type_id" "uuid" NOT NULL,
    "carton_number" integer NOT NULL,
    "total_weight" numeric(10,2),
    "notes" "text",
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_wms"."shipment_cartons" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_wms"."shipment_item_addresses" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "shipment_item_id" "uuid" NOT NULL,
    "address_type" character varying(50) DEFAULT 'delivery'::character varying NOT NULL,
    "address" "text" NOT NULL,
    "city" "text" NOT NULL,
    "state" "text" NOT NULL,
    "zip" "text",
    "country" "text",
    "province" "text",
    "is_primary" boolean DEFAULT false NOT NULL,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid",
    "domain_id" "uuid" NOT NULL,
    "shared_with" "jsonb" DEFAULT '[]'::"jsonb",
    "is_deleted" boolean DEFAULT false,
    CONSTRAINT "check_address_completeness" CHECK ((("address" IS NOT NULL) AND ("city" IS NOT NULL) AND ("state" IS NOT NULL))),
    CONSTRAINT "check_address_type" CHECK ((("address_type")::"text" = ANY (ARRAY[('delivery'::character varying)::"text", ('billing'::character varying)::"text", ('pickup'::character varying)::"text", ('return'::character varying)::"text", ('custom'::character varying)::"text"])))
);


ALTER TABLE "mod_wms"."shipment_item_addresses" OWNER TO "postgres";


COMMENT ON TABLE "mod_wms"."shipment_item_addresses" IS 'Stores individual addresses for shipment items, supporting multiple address types and better normalization';



COMMENT ON COLUMN "mod_wms"."shipment_item_addresses"."address_type" IS 'Type of address: delivery, billing, pickup, return, or custom';



COMMENT ON COLUMN "mod_wms"."shipment_item_addresses"."is_primary" IS 'Indicates if this is the primary address for this type (only one primary per item per type)';



COMMENT ON COLUMN "mod_wms"."shipment_item_addresses"."notes" IS 'Additional notes or instructions for this address';



COMMENT ON COLUMN "mod_wms"."shipment_item_addresses"."domain_id" IS 'Domain ID for multi-tenant support and RLS policies';



COMMENT ON COLUMN "mod_wms"."shipment_item_addresses"."shared_with" IS 'JSON array of user IDs this address is shared with';



COMMENT ON COLUMN "mod_wms"."shipment_item_addresses"."is_deleted" IS 'Soft delete flag for data retention';



CREATE TABLE IF NOT EXISTS "mod_wms"."shipment_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "shipment_id" "uuid" NOT NULL,
    "article_id" "uuid" NOT NULL,
    "quantity_shipped" numeric(12,4) DEFAULT 0 NOT NULL,
    "location_id" "uuid",
    "batch_id" "uuid",
    "total_weight" numeric(10,2),
    "total_volume" numeric(10,2),
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "inventory_id" "uuid"
);


ALTER TABLE "mod_wms"."shipment_items" OWNER TO "postgres";


COMMENT ON COLUMN "mod_wms"."shipment_items"."location_id" IS 'Location ID where the item is shipped from. Can be NULL for items not yet manufactured or without inventory in Area Spedizioni.';



COMMENT ON COLUMN "mod_wms"."shipment_items"."inventory_id" IS 'Reference to the specific inventory record being shipped';



CREATE TABLE IF NOT EXISTS "mod_wms"."shipment_pallets" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "shipment_id" "uuid" NOT NULL,
    "pallet_type_id" "uuid" NOT NULL,
    "pallet_number" integer NOT NULL,
    "total_weight" numeric(10,2),
    "notes" "text",
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_wms"."shipment_pallets" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_wms"."shipment_sales_orders" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "shipment_id" "uuid" NOT NULL,
    "sales_order_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "updated_by" "uuid",
    "domain_id" "uuid"
);


ALTER TABLE "mod_wms"."shipment_sales_orders" OWNER TO "postgres";


COMMENT ON TABLE "mod_wms"."shipment_sales_orders" IS 'Junction table linking shipments to multiple sales orders. RLS policies allow all authenticated users to view, insert, update, and delete records.';



COMMENT ON COLUMN "mod_wms"."shipment_sales_orders"."shipment_id" IS 'Reference to the shipment';



COMMENT ON COLUMN "mod_wms"."shipment_sales_orders"."sales_order_id" IS 'Reference to the sales order';



CREATE TABLE IF NOT EXISTS "mod_wms"."shipment_standalone_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "shipment_id" "uuid" NOT NULL,
    "shipment_item_id" "uuid" NOT NULL,
    "quantity_packed" integer DEFAULT 0 NOT NULL,
    "notes" "text",
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "shipment_standalone_items_quantity_positive" CHECK (("quantity_packed" > 0))
);


ALTER TABLE "mod_wms"."shipment_standalone_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_wms"."shipments" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "warehouse_id" "uuid",
    "sales_order_id" "uuid",
    "shipment_number" "text" DEFAULT ''::"text" NOT NULL,
    "shipment_date" "date" NOT NULL,
    "expected_delivery_date" "date",
    "status" "text",
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "tracking_url" "text" DEFAULT ''::"text" NOT NULL,
    "tracking_no" "text" DEFAULT ''::"text" NOT NULL,
    "invoice_address" "text" DEFAULT ''::"text" NOT NULL,
    "invoice_city" "text" DEFAULT ''::"text" NOT NULL,
    "invoice_state" "text" DEFAULT ''::"text" NOT NULL,
    "invoice_zip" "text" DEFAULT ''::"text" NOT NULL,
    "invoice_country" "text" DEFAULT ''::"text" NOT NULL,
    "invoice_province" "text" DEFAULT ''::"text" NOT NULL,
    "goods_ready" boolean DEFAULT false NOT NULL,
    "docs_ready" boolean DEFAULT false NOT NULL,
    "is_archived" boolean DEFAULT false NOT NULL,
    "notes" "text" DEFAULT ''::"text",
    CONSTRAINT "shipments_status_check" CHECK ((("status" IS NULL) OR ("status" = ANY (ARRAY['pending'::"text", 'processing'::"text", 'loaded'::"text"]))))
);


ALTER TABLE "mod_wms"."shipments" OWNER TO "postgres";


COMMENT ON COLUMN "mod_wms"."shipments"."warehouse_id" IS 'Warehouse ID for this shipment. Can be NULL when shipping items that are not yet manufactured or don''t have inventory.';



COMMENT ON COLUMN "mod_wms"."shipments"."status" IS 'Simplified shipment status workflow (3 statuses only):

1. pending (orange icon)
   - Initial state, awaiting processing
   - Shipment created but goods/documents not ready yet

2. processing (blue icon)
   - Ready for shipment
   - Automatically triggered when goods_ready=true AND docs_ready=true
   - Goods are prepared and documents are complete

3. loaded (green icon)
   - Goods loaded on transport vehicle
   - Manually triggered via "Mark as Loaded" button
   - Final state - shipment is complete

Workflow triggers:
- pending → processing: Automatic when both goods_ready AND docs_ready become true
- processing → loaded: Manual via "Mark as Loaded" button in Quick Actions';



COMMENT ON COLUMN "mod_wms"."shipments"."tracking_url" IS 'URL for tracking the shipment';



COMMENT ON COLUMN "mod_wms"."shipments"."tracking_no" IS 'Tracking number for the shipment';



COMMENT ON COLUMN "mod_wms"."shipments"."invoice_address" IS 'Billing/invoice address for the customer';



COMMENT ON COLUMN "mod_wms"."shipments"."invoice_city" IS 'City for billing/invoice address';



COMMENT ON COLUMN "mod_wms"."shipments"."invoice_state" IS 'State for billing/invoice address';



COMMENT ON COLUMN "mod_wms"."shipments"."invoice_zip" IS 'ZIP code for billing/invoice address';



COMMENT ON COLUMN "mod_wms"."shipments"."invoice_country" IS 'Country for billing/invoice address';



COMMENT ON COLUMN "mod_wms"."shipments"."invoice_province" IS 'Province for billing/invoice address';



COMMENT ON COLUMN "mod_wms"."shipments"."goods_ready" IS 'Indicates if goods are ready for shipment';



COMMENT ON COLUMN "mod_wms"."shipments"."docs_ready" IS 'Indicates if documents are ready for shipment';



COMMENT ON COLUMN "mod_wms"."shipments"."is_archived" IS 'Whether this shipment is archived and hidden from default views';



COMMENT ON COLUMN "mod_wms"."shipments"."notes" IS 'Additional notes or comments for the shipment';



CREATE SEQUENCE IF NOT EXISTS "mod_wms"."shipments_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "mod_wms"."shipments_code_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "mod_wms"."warehouses" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "description" "text" DEFAULT ''::"text" NOT NULL,
    "code" "text" DEFAULT ''::"text" NOT NULL,
    "address" "text" DEFAULT ''::"text" NOT NULL,
    "zip" "text" DEFAULT ''::"text" NOT NULL,
    "city" "text" DEFAULT ''::"text" NOT NULL,
    "province" "text" DEFAULT ''::"text" NOT NULL,
    "state" "text" DEFAULT ''::"text" NOT NULL,
    "country" "text" DEFAULT ''::"text" NOT NULL,
    "avatar_url" "text" DEFAULT ''::"text" NOT NULL,
    "barcode" "text" DEFAULT "regexp_replace"(("gen_random_uuid"())::"text", '-'::"text", ''::"text", 'g'::"text") NOT NULL,
    "domain_id" "uuid" DEFAULT 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::"uuid" NOT NULL,
    "shared_with" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "mod_wms"."warehouses" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."batches_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."batches_code_seq" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."customers_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."customers_code_seq" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."departments_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."departments_code_seq" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."employees_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."employees_code_seq" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."locations_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."locations_code_seq" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."notifications_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."notifications_code_seq" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."pulses_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."pulses_code_seq" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."receipt_items_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."receipt_items_code_seq" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."receipts_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."receipts_code_seq" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."user_profiles_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."user_profiles_code_seq" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."work_cycles_code_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."work_cycles_code_seq" OWNER TO "postgres";


ALTER TABLE ONLY "mod_admin"."domain_modules"
    ADD CONSTRAINT "domain_modules_domain_id_module_id_key" UNIQUE ("domain_id", "module_id");



ALTER TABLE ONLY "mod_admin"."domain_modules"
    ADD CONSTRAINT "domain_modules_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_admin"."domain_users"
    ADD CONSTRAINT "domain_users_pkey" PRIMARY KEY ("user_id", "domain_id");



ALTER TABLE ONLY "mod_admin"."domains"
    ADD CONSTRAINT "domains_key_key" UNIQUE ("key");



ALTER TABLE ONLY "mod_admin"."domains"
    ADD CONSTRAINT "domains_name_key" UNIQUE ("name");



ALTER TABLE ONLY "mod_admin"."domains"
    ADD CONSTRAINT "domains_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_admin"."user_profiles"
    ADD CONSTRAINT "user_profiles_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_admin"."user_profiles"
    ADD CONSTRAINT "user_profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."announcements"
    ADD CONSTRAINT "announcements_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_base"."announcements"
    ADD CONSTRAINT "announcements_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."article_categories"
    ADD CONSTRAINT "article_categories_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_base"."article_categories"
    ADD CONSTRAINT "article_categories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."articles"
    ADD CONSTRAINT "articles_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_base"."articles"
    ADD CONSTRAINT "articles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."articles"
    ADD CONSTRAINT "articles_sku_key" UNIQUE ("sku");



ALTER TABLE ONLY "mod_base"."bom_articles"
    ADD CONSTRAINT "bom_articles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."bom_articles"
    ADD CONSTRAINT "bom_articles_unique_relationship" UNIQUE ("parent_article_id", "component_article_id");



ALTER TABLE ONLY "mod_base"."custom_article_attachments"
    ADD CONSTRAINT "custom_article_attachments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."customer_addresses"
    ADD CONSTRAINT "customer_addresses_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."customers"
    ADD CONSTRAINT "customers_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_base"."customers"
    ADD CONSTRAINT "customers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."departments"
    ADD CONSTRAINT "departments_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_base"."departments"
    ADD CONSTRAINT "departments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."employees"
    ADD CONSTRAINT "employees_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_base"."employees_departments"
    ADD CONSTRAINT "employees_departments_pkey" PRIMARY KEY ("employee_id", "department_id");



ALTER TABLE ONLY "mod_base"."employees"
    ADD CONSTRAINT "employees_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."internal_sales_order_items"
    ADD CONSTRAINT "internal_sales_order_items_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_base"."internal_sales_order_items"
    ADD CONSTRAINT "internal_sales_order_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."internal_sales_orders"
    ADD CONSTRAINT "internal_sales_orders_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_base"."internal_sales_orders"
    ADD CONSTRAINT "internal_sales_orders_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."internal_sales_orders"
    ADD CONSTRAINT "internal_sales_orders_sales_order_number_key" UNIQUE ("sales_order_number");



ALTER TABLE ONLY "mod_base"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."purchase_order_items"
    ADD CONSTRAINT "purchase_order_items_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_base"."purchase_order_items"
    ADD CONSTRAINT "purchase_order_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."purchase_orders"
    ADD CONSTRAINT "purchase_orders_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_base"."purchase_orders"
    ADD CONSTRAINT "purchase_orders_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."purchase_orders"
    ADD CONSTRAINT "purchase_orders_purchase_order_number_key" UNIQUE ("purchase_order_number");



ALTER TABLE ONLY "mod_base"."quality_control_attachments"
    ADD CONSTRAINT "quality_control_attachments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."quality_control_checklist_results"
    ADD CONSTRAINT "quality_control_checklist_results_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."quality_control"
    ADD CONSTRAINT "quality_control_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."quality_control_types"
    ADD CONSTRAINT "quality_control_types_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_base"."quality_control_types_duplicate"
    ADD CONSTRAINT "quality_control_types_duplicate_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_base"."quality_control_types_duplicate"
    ADD CONSTRAINT "quality_control_types_duplicate_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."quality_control_types"
    ADD CONSTRAINT "quality_control_types_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."report_template"
    ADD CONSTRAINT "report_template_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."sales_order_items"
    ADD CONSTRAINT "sales_order_items_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_base"."sales_order_items"
    ADD CONSTRAINT "sales_order_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."sales_orders"
    ADD CONSTRAINT "sales_orders_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_base"."sales_orders"
    ADD CONSTRAINT "sales_orders_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."sales_orders"
    ADD CONSTRAINT "sales_orders_sales_order_number_key" UNIQUE ("sales_order_number");



ALTER TABLE ONLY "mod_base"."serial_number_counters"
    ADD CONSTRAINT "serial_number_counters_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."serial_number_counters"
    ADD CONSTRAINT "serial_number_counters_unique_category_year" UNIQUE ("category_id", "year");



ALTER TABLE ONLY "mod_base"."suppliers"
    ADD CONSTRAINT "suppliers_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_base"."suppliers"
    ADD CONSTRAINT "suppliers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_base"."quality_control_checklist_results"
    ADD CONSTRAINT "uk_quality_control_checklist_results_unique_item" UNIQUE ("quality_control_id", "checklist_item", "domain_id");



ALTER TABLE ONLY "mod_base"."units_of_measure"
    ADD CONSTRAINT "units_of_measure_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_base"."units_of_measure"
    ADD CONSTRAINT "units_of_measure_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_datalayer"."fields"
    ADD CONSTRAINT "fields_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_datalayer"."fields"
    ADD CONSTRAINT "fields_schema_name_table_name_field_name_key" UNIQUE ("schema_name", "table_name", "field_name");



ALTER TABLE ONLY "mod_datalayer"."main_menu"
    ADD CONSTRAINT "main_menu_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_datalayer"."modules"
    ADD CONSTRAINT "modules_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_datalayer"."modules"
    ADD CONSTRAINT "modules_schema_name_key" UNIQUE ("schema_name");



ALTER TABLE ONLY "mod_datalayer"."page_categories"
    ADD CONSTRAINT "page_categories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_datalayer"."pages_departments"
    ADD CONSTRAINT "pages_departments_page_id_department_id_key" UNIQUE ("page_id", "department_id");



ALTER TABLE ONLY "mod_datalayer"."pages_departments"
    ADD CONSTRAINT "pages_departments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_datalayer"."pages_menu_departments"
    ADD CONSTRAINT "pages_menu_departments_page_id_department_id_key" UNIQUE ("page_id", "department_id");



ALTER TABLE ONLY "mod_datalayer"."pages_menu_departments"
    ADD CONSTRAINT "pages_menu_departments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_datalayer"."pages"
    ADD CONSTRAINT "pages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_datalayer"."tables"
    ADD CONSTRAINT "tables_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_datalayer"."tables"
    ADD CONSTRAINT "tables_schema_name_table_name_key" UNIQUE ("schema_name", "table_name");



ALTER TABLE ONLY "mod_datalayer"."pages"
    ADD CONSTRAINT "unique_module_page" UNIQUE ("module_id", "name");



ALTER TABLE ONLY "mod_manufacturing"."coil_consumption"
    ADD CONSTRAINT "coil_consumption_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."coil_production_plans"
    ADD CONSTRAINT "coil_production_plans_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_manufacturing"."coil_production_plans"
    ADD CONSTRAINT "coil_production_plans_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."coils"
    ADD CONSTRAINT "coils_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_manufacturing"."coils"
    ADD CONSTRAINT "coils_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."departments"
    ADD CONSTRAINT "departments_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_manufacturing"."departments"
    ADD CONSTRAINT "departments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."locations"
    ADD CONSTRAINT "locations_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_manufacturing"."locations"
    ADD CONSTRAINT "locations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."plate_templates"
    ADD CONSTRAINT "plate_templates_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_manufacturing"."plate_templates"
    ADD CONSTRAINT "plate_templates_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."production_logs"
    ADD CONSTRAINT "production_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."recipes"
    ADD CONSTRAINT "recipes_finished_product_id_sequence_number_key" UNIQUE ("finished_product_id", "sequence_number");



ALTER TABLE ONLY "mod_manufacturing"."recipes"
    ADD CONSTRAINT "recipes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."scheduled_items"
    ADD CONSTRAINT "scheduled_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."scheduled_items"
    ADD CONSTRAINT "unique_scheduled_item" UNIQUE ("sales_order_item_id", "sales_order_id", "article_id");



ALTER TABLE ONLY "mod_manufacturing"."work_cycle_categories"
    ADD CONSTRAINT "unique_work_cycle_category_relation" UNIQUE ("work_flow_id", "work_cycle_id", "from_article_category_id", "to_article_category_id", "location_id");



ALTER TABLE ONLY "mod_manufacturing"."work_order_quality_summary"
    ADD CONSTRAINT "unique_work_order_quality_summary" UNIQUE ("work_order_id");



ALTER TABLE ONLY "mod_manufacturing"."work_cycle_categories"
    ADD CONSTRAINT "work_cycle_categories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."work_cycles"
    ADD CONSTRAINT "work_cycles_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_manufacturing"."work_cycles"
    ADD CONSTRAINT "work_cycles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."work_flows"
    ADD CONSTRAINT "work_flows_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."work_flows_work_cycles"
    ADD CONSTRAINT "work_flows_work_cycles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."work_flows_work_cycles"
    ADD CONSTRAINT "work_flows_work_cycles_work_flow_id_work_cycle_id_key" UNIQUE ("work_flow_id", "work_cycle_id");



ALTER TABLE ONLY "mod_manufacturing"."work_order_attachments"
    ADD CONSTRAINT "work_order_attachments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."work_order_quality_summary"
    ADD CONSTRAINT "work_order_quality_summary_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."work_orders"
    ADD CONSTRAINT "work_orders_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_manufacturing"."work_orders"
    ADD CONSTRAINT "work_orders_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."work_orders"
    ADD CONSTRAINT "work_orders_task_id_key" UNIQUE ("task_id");



ALTER TABLE ONLY "mod_manufacturing"."work_steps"
    ADD CONSTRAINT "work_steps_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_manufacturing"."work_steps"
    ADD CONSTRAINT "work_steps_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."workstations"
    ADD CONSTRAINT "workstations_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_manufacturing"."workstations_duplicate"
    ADD CONSTRAINT "workstations_duplicate_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_manufacturing"."workstations_duplicate"
    ADD CONSTRAINT "workstations_duplicate_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_manufacturing"."workstations"
    ADD CONSTRAINT "workstations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_pulse"."department_notification_configs"
    ADD CONSTRAINT "department_notification_confi_department_id_notification_ty_key" UNIQUE ("department_id", "notification_type", "is_deleted");



ALTER TABLE ONLY "mod_pulse"."department_notification_configs"
    ADD CONSTRAINT "department_notification_configs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_pulse"."notifications"
    ADD CONSTRAINT "notifications_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_pulse"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_pulse"."pulse_chat_files"
    ADD CONSTRAINT "pulse_chat_files_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_pulse"."pulse_chat"
    ADD CONSTRAINT "pulse_chat_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_pulse"."pulse_checklists"
    ADD CONSTRAINT "pulse_checklists_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_pulse"."pulse_checklists"
    ADD CONSTRAINT "pulse_checklists_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_pulse"."pulse_comments"
    ADD CONSTRAINT "pulse_comments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_pulse"."pulse_conversation_participants"
    ADD CONSTRAINT "pulse_conversation_participants_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_pulse"."pulse_progress"
    ADD CONSTRAINT "pulse_progress_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_pulse"."pulse_progress"
    ADD CONSTRAINT "pulse_progress_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_pulse"."pulse_slas"
    ADD CONSTRAINT "pulse_slas_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_pulse"."pulse_slas"
    ADD CONSTRAINT "pulse_slas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_pulse"."pulses"
    ADD CONSTRAINT "pulses_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_pulse"."pulses"
    ADD CONSTRAINT "pulses_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_pulse"."tasks"
    ADD CONSTRAINT "tasks_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_pulse"."tasks"
    ADD CONSTRAINT "tasks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_quality_control"."conformity_documents"
    ADD CONSTRAINT "conformity_documents_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_quality_control"."defect_types"
    ADD CONSTRAINT "defect_types_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_quality_control"."measurement_parameters"
    ADD CONSTRAINT "measurement_parameters_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_quality_control"."quality_control_checklist_results"
    ADD CONSTRAINT "quality_control_checklist_results_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_quality_control"."quality_control_defects"
    ADD CONSTRAINT "quality_control_defects_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_quality_control"."quality_control_measurements"
    ADD CONSTRAINT "quality_control_measurements_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_quality_control"."supplier_returns"
    ADD CONSTRAINT "supplier_returns_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_quality_control"."defect_types"
    ADD CONSTRAINT "unique_defect_code" UNIQUE ("code");



ALTER TABLE ONLY "mod_quality_control"."conformity_documents"
    ADD CONSTRAINT "unique_document_number" UNIQUE ("document_number");



ALTER TABLE ONLY "mod_quality_control"."measurement_parameters"
    ADD CONSTRAINT "unique_parameter_code" UNIQUE ("code");



ALTER TABLE ONLY "mod_quality_control"."supplier_returns"
    ADD CONSTRAINT "unique_return_number" UNIQUE ("return_number");



ALTER TABLE ONLY "mod_wms"."batches"
    ADD CONSTRAINT "batches_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_wms"."batches"
    ADD CONSTRAINT "batches_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."box_contents"
    ADD CONSTRAINT "box_contents_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."box_contents"
    ADD CONSTRAINT "box_contents_unique_item_per_box" UNIQUE ("shipment_box_id", "shipment_item_id");



ALTER TABLE ONLY "mod_wms"."box_types"
    ADD CONSTRAINT "box_types_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."carton_contents"
    ADD CONSTRAINT "carton_contents_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."carton_contents"
    ADD CONSTRAINT "carton_contents_unique_item_per_carton" UNIQUE ("shipment_carton_id", "shipment_item_id");



ALTER TABLE ONLY "mod_wms"."carton_types"
    ADD CONSTRAINT "carton_types_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."inventory"
    ADD CONSTRAINT "inventory_article_id_location_id_batch_id_key" UNIQUE ("article_id", "location_id", "batch_id");



ALTER TABLE ONLY "mod_wms"."inventory_limits"
    ADD CONSTRAINT "inventory_limits_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_wms"."inventory_limits"
    ADD CONSTRAINT "inventory_limits_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."inventory_backup"
    ADD CONSTRAINT "inventory_pkey" PRIMARY KEY ("article_id", "location_id", "batch_id");



ALTER TABLE ONLY "mod_wms"."inventory"
    ADD CONSTRAINT "inventory_pkey_new" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."locations"
    ADD CONSTRAINT "locations_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_wms"."locations"
    ADD CONSTRAINT "locations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."pallet_contents"
    ADD CONSTRAINT "pallet_contents_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."pallet_contents"
    ADD CONSTRAINT "pallet_contents_unique_item_per_pallet" UNIQUE ("shipment_pallet_id", "shipment_item_id");



ALTER TABLE ONLY "mod_wms"."pallet_types"
    ADD CONSTRAINT "pallet_types_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."receipt_items"
    ADD CONSTRAINT "receipt_items_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_wms"."receipt_items"
    ADD CONSTRAINT "receipt_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."receipts"
    ADD CONSTRAINT "receipts_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_wms"."receipts"
    ADD CONSTRAINT "receipts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."shipment_attachments"
    ADD CONSTRAINT "shipment_attachments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."shipment_boxes"
    ADD CONSTRAINT "shipment_boxes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."shipment_cartons"
    ADD CONSTRAINT "shipment_cartons_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."shipment_cartons"
    ADD CONSTRAINT "shipment_cartons_unique_number_per_pallet" UNIQUE ("shipment_pallet_id", "carton_number");



ALTER TABLE ONLY "mod_wms"."shipment_item_addresses"
    ADD CONSTRAINT "shipment_item_addresses_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."shipment_items"
    ADD CONSTRAINT "shipment_items_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_wms"."shipment_items"
    ADD CONSTRAINT "shipment_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."shipment_pallets"
    ADD CONSTRAINT "shipment_pallets_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."shipment_pallets"
    ADD CONSTRAINT "shipment_pallets_unique_number_per_shipment" UNIQUE ("shipment_id", "pallet_number");



ALTER TABLE ONLY "mod_wms"."shipment_sales_orders"
    ADD CONSTRAINT "shipment_sales_orders_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."shipment_sales_orders"
    ADD CONSTRAINT "shipment_sales_orders_shipment_id_sales_order_id_key" UNIQUE ("shipment_id", "sales_order_id");



ALTER TABLE ONLY "mod_wms"."shipment_standalone_items"
    ADD CONSTRAINT "shipment_standalone_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."shipment_standalone_items"
    ADD CONSTRAINT "shipment_standalone_items_unique_item_per_shipment" UNIQUE ("shipment_id", "shipment_item_id");



ALTER TABLE ONLY "mod_wms"."shipments"
    ADD CONSTRAINT "shipments_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_wms"."shipments"
    ADD CONSTRAINT "shipments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."shipments"
    ADD CONSTRAINT "shipments_shipment_number_key" UNIQUE ("shipment_number");



ALTER TABLE ONLY "mod_wms"."stock_movements"
    ADD CONSTRAINT "stock_movements_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_wms"."stock_movements"
    ADD CONSTRAINT "stock_movements_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "mod_wms"."warehouses"
    ADD CONSTRAINT "warehouses_barcode_key" UNIQUE ("barcode");



ALTER TABLE ONLY "mod_wms"."warehouses"
    ADD CONSTRAINT "warehouses_pkey" PRIMARY KEY ("id");



CREATE INDEX "domain_users_user_id_domain_id_idx" ON "mod_admin"."domain_users" USING "btree" ("user_id", "domain_id");



CREATE INDEX "domain_users_user_id_domain_id_idx1" ON "mod_admin"."domain_users" USING "btree" ("user_id", "domain_id");



CREATE INDEX "domains_parent_domain_id_idx" ON "mod_admin"."domains" USING "btree" ("parent_domain_id");



CREATE INDEX "domains_parent_domain_id_idx1" ON "mod_admin"."domains" USING "btree" ("parent_domain_id");



CREATE INDEX "idx_domains_fts" ON "mod_admin"."domains" USING "gin" ("fts");



CREATE INDEX "idx_user_profiles_fts" ON "mod_admin"."user_profiles" USING "gin" ("fts");



CREATE INDEX "idx_articles_fts" ON "mod_base"."articles" USING "gin" ("fts");



CREATE INDEX "idx_articles_heat_exchanger_model" ON "mod_base"."articles" USING "btree" ("heat_exchanger_model");



CREATE INDEX "idx_articles_is_deleted" ON "mod_base"."articles" USING "btree" ("is_deleted");



CREATE INDEX "idx_articles_name" ON "mod_base"."articles" USING "btree" ("name");



CREATE INDEX "idx_articles_parent_article_id" ON "mod_base"."articles" USING "btree" ("parent_article_id");



CREATE INDEX "idx_articles_parent_article_id_not_null" ON "mod_base"."articles" USING "btree" ("parent_article_id") WHERE ("parent_article_id" IS NOT NULL);



CREATE INDEX "idx_articles_type" ON "mod_base"."articles" USING "btree" ("type");



CREATE INDEX "idx_articles_type_is_deleted" ON "mod_base"."articles" USING "btree" ("type", "is_deleted") WHERE ("is_deleted" = false);



CREATE INDEX "idx_articles_type_is_deleted_heat_exchanger_model" ON "mod_base"."articles" USING "btree" ("type", "is_deleted", "heat_exchanger_model") WHERE ("is_deleted" = false);



CREATE INDEX "idx_bom_articles_component_id" ON "mod_base"."bom_articles" USING "btree" ("component_article_id");



CREATE INDEX "idx_bom_articles_fts" ON "mod_base"."bom_articles" USING "gin" ("fts");



CREATE INDEX "idx_bom_articles_parent_id" ON "mod_base"."bom_articles" USING "btree" ("parent_article_id");



CREATE INDEX "idx_bom_articles_position" ON "mod_base"."bom_articles" USING "btree" ("position");



CREATE INDEX "idx_custom_article_attachments_article_id" ON "mod_base"."custom_article_attachments" USING "btree" ("article_id");



CREATE INDEX "idx_custom_article_attachments_fts" ON "mod_base"."custom_article_attachments" USING "gin" ("fts");



CREATE INDEX "idx_custom_article_attachments_internal_sales_order_article" ON "mod_base"."custom_article_attachments" USING "btree" ("internal_sales_order_id", "article_id");



CREATE INDEX "idx_custom_article_attachments_internal_sales_order_id" ON "mod_base"."custom_article_attachments" USING "btree" ("internal_sales_order_id");



CREATE INDEX "idx_custom_article_attachments_internal_sales_order_only" ON "mod_base"."custom_article_attachments" USING "btree" ("internal_sales_order_id") WHERE ("article_id" IS NULL);



CREATE INDEX "idx_custom_article_attachments_internal_sales_order_with_articl" ON "mod_base"."custom_article_attachments" USING "btree" ("internal_sales_order_id", "article_id") WHERE ("article_id" IS NOT NULL);



CREATE INDEX "idx_custom_article_attachments_sales_order_article" ON "mod_base"."custom_article_attachments" USING "btree" ("sales_order_id", "article_id");



CREATE INDEX "idx_custom_article_attachments_sales_order_id" ON "mod_base"."custom_article_attachments" USING "btree" ("sales_order_id");



CREATE INDEX "idx_custom_article_attachments_sales_order_only" ON "mod_base"."custom_article_attachments" USING "btree" ("sales_order_id") WHERE ("article_id" IS NULL);



CREATE INDEX "idx_custom_article_attachments_with_article" ON "mod_base"."custom_article_attachments" USING "btree" ("sales_order_id", "article_id") WHERE ("article_id" IS NOT NULL);



CREATE INDEX "idx_customer_addresses_address_type" ON "mod_base"."customer_addresses" USING "btree" ("address_type");



CREATE INDEX "idx_customer_addresses_customer_id" ON "mod_base"."customer_addresses" USING "btree" ("customer_id");



CREATE INDEX "idx_customer_addresses_domain_id" ON "mod_base"."customer_addresses" USING "btree" ("domain_id");



CREATE INDEX "idx_customer_addresses_fts" ON "mod_base"."customer_addresses" USING "gin" ("fts");



CREATE INDEX "idx_customer_addresses_is_primary" ON "mod_base"."customer_addresses" USING "btree" ("is_primary");



CREATE INDEX "idx_customers_fts" ON "mod_base"."customers" USING "gin" ("fts");



CREATE INDEX "idx_internal_sales_order_items_fts" ON "mod_base"."internal_sales_order_items" USING "gin" ("fts");



CREATE INDEX "idx_internal_sales_order_items_is_manufactured" ON "mod_base"."internal_sales_order_items" USING "btree" ("is_manufactured");



CREATE INDEX "idx_internal_sales_order_items_parent_item" ON "mod_base"."internal_sales_order_items" USING "btree" ("parent_sales_order_item_id");



CREATE INDEX "idx_internal_sales_order_items_production_date" ON "mod_base"."internal_sales_order_items" USING "btree" ("sales_order_id", "production_date") WHERE (("production_date" IS NOT NULL) AND ("is_deleted" = false));



CREATE INDEX "idx_internal_sales_orders_archived_deleted" ON "mod_base"."internal_sales_orders" USING "btree" ("is_archived", "is_deleted");



CREATE INDEX "idx_internal_sales_orders_fts" ON "mod_base"."internal_sales_orders" USING "gin" ("fts");



CREATE INDEX "idx_internal_sales_orders_internal_archived" ON "mod_base"."internal_sales_orders" USING "btree" ("is_internal", "is_archived");



CREATE INDEX "idx_internal_sales_orders_is_archived" ON "mod_base"."internal_sales_orders" USING "btree" ("is_archived");



CREATE INDEX "idx_internal_sales_orders_is_internal" ON "mod_base"."internal_sales_orders" USING "btree" ("is_internal");



CREATE INDEX "idx_internal_sales_orders_total_cost" ON "mod_base"."internal_sales_orders" USING "btree" ("total_cost");



CREATE INDEX "idx_purchase_order_items_fts" ON "mod_base"."purchase_order_items" USING "gin" ("fts");



CREATE INDEX "idx_purchase_orders_fts" ON "mod_base"."purchase_orders" USING "gin" ("fts");



CREATE INDEX "idx_qc_inspector" ON "mod_base"."quality_control" USING "btree" ("inspector_id");



CREATE INDEX "idx_qc_reference" ON "mod_base"."quality_control" USING "btree" ("reference_type", "reference_id");



CREATE INDEX "idx_qc_status" ON "mod_base"."quality_control" USING "btree" ("status");



CREATE INDEX "idx_qc_types_article_type" ON "mod_base"."quality_control_types" USING "btree" ("article_type");



CREATE INDEX "idx_qc_types_is_active" ON "mod_base"."quality_control_types" USING "btree" ("is_active");



CREATE INDEX "idx_qc_types_is_required" ON "mod_base"."quality_control_types" USING "btree" ("is_required");



CREATE INDEX "idx_qc_types_timing" ON "mod_base"."quality_control_types" USING "btree" ("timing");



CREATE INDEX "idx_quality_control_article_type" ON "mod_base"."quality_control" USING "btree" ("article_type") WHERE ("article_type" IS NOT NULL);



CREATE INDEX "idx_quality_control_attachments_quality_control_id" ON "mod_base"."quality_control_attachments" USING "btree" ("quality_control_id");



CREATE INDEX "idx_quality_control_checklist_results_created_at" ON "mod_base"."quality_control_checklist_results" USING "btree" ("created_at");



CREATE INDEX "idx_quality_control_checklist_results_domain_id" ON "mod_base"."quality_control_checklist_results" USING "btree" ("domain_id");



CREATE INDEX "idx_quality_control_checklist_results_quality_control_id" ON "mod_base"."quality_control_checklist_results" USING "btree" ("quality_control_id");



CREATE INDEX "idx_quality_control_checklist_results_result" ON "mod_base"."quality_control_checklist_results" USING "btree" ("result");



CREATE INDEX "idx_quality_control_inspector_id" ON "mod_base"."quality_control" USING "btree" ("inspector_id");



CREATE INDEX "idx_quality_control_purchase_order_item_id" ON "mod_base"."quality_control" USING "btree" ("purchase_order_item_id");



CREATE INDEX "idx_quality_control_receipt_id" ON "mod_base"."quality_control" USING "btree" ("receipt_id") WHERE ("receipt_id" IS NOT NULL);



CREATE INDEX "idx_quality_control_receipt_item_id" ON "mod_base"."quality_control" USING "btree" ("receipt_item_id") WHERE ("receipt_item_id" IS NOT NULL);



CREATE INDEX "idx_quality_control_shipment_id" ON "mod_base"."quality_control" USING "btree" ("shipment_id") WHERE ("shipment_id" IS NOT NULL);



CREATE INDEX "idx_quality_control_type_id" ON "mod_base"."quality_control" USING "btree" ("quality_control_type_id");



CREATE INDEX "idx_quality_control_types_category_id" ON "mod_base"."quality_control_types" USING "btree" ("category_id") WHERE ("category_id" IS NOT NULL);



CREATE INDEX "idx_quality_control_types_fts" ON "mod_base"."quality_control_types" USING "gin" ("fts");



CREATE INDEX "idx_quality_control_types_work_cycle_id" ON "mod_base"."quality_control_types" USING "btree" ("work_cycle_id");



CREATE INDEX "idx_quality_control_work_order_id" ON "mod_base"."quality_control" USING "btree" ("work_order_id");



CREATE INDEX "idx_quality_control_work_steps_id" ON "mod_base"."quality_control" USING "btree" ("work_steps_id");



CREATE INDEX "idx_sales_order_items_fts" ON "mod_base"."sales_order_items" USING "gin" ("fts");



CREATE INDEX "idx_sales_order_items_is_manufactured" ON "mod_base"."sales_order_items" USING "btree" ("is_manufactured");



CREATE INDEX "idx_sales_order_items_parent_item" ON "mod_base"."sales_order_items" USING "btree" ("parent_sales_order_item_id");



CREATE INDEX "idx_sales_order_items_production_date" ON "mod_base"."sales_order_items" USING "btree" ("sales_order_id", "production_date") WHERE (("production_date" IS NOT NULL) AND ("is_deleted" = false));



CREATE INDEX "idx_sales_orders_archived_deleted" ON "mod_base"."sales_orders" USING "btree" ("is_archived", "is_deleted");



CREATE INDEX "idx_sales_orders_customer_order_ref" ON "mod_base"."sales_orders" USING "btree" ("customer_order_ref");



CREATE INDEX "idx_sales_orders_fts" ON "mod_base"."sales_orders" USING "gin" ("fts");



CREATE INDEX "idx_sales_orders_internal_archived" ON "mod_base"."sales_orders" USING "btree" ("is_internal", "is_archived");



CREATE INDEX "idx_sales_orders_is_archived" ON "mod_base"."sales_orders" USING "btree" ("is_archived");



CREATE INDEX "idx_sales_orders_is_internal" ON "mod_base"."sales_orders" USING "btree" ("is_internal");



CREATE INDEX "idx_sales_orders_order_ref" ON "mod_base"."sales_orders" USING "btree" ("order_ref");



CREATE INDEX "idx_sales_orders_total_cost" ON "mod_base"."sales_orders" USING "btree" ("total_cost");



CREATE INDEX "idx_serial_number_counters_category_id" ON "mod_base"."serial_number_counters" USING "btree" ("category_id");



CREATE INDEX "idx_serial_number_counters_category_year" ON "mod_base"."serial_number_counters" USING "btree" ("category_id", "year");



CREATE INDEX "idx_serial_number_counters_year" ON "mod_base"."serial_number_counters" USING "btree" ("year");



CREATE INDEX "idx_suppliers_fts" ON "mod_base"."suppliers" USING "gin" ("fts");



CREATE INDEX "quality_control_types_duplicate_article_type_idx" ON "mod_base"."quality_control_types_duplicate" USING "btree" ("article_type");



CREATE INDEX "quality_control_types_duplicate_category_id_idx" ON "mod_base"."quality_control_types_duplicate" USING "btree" ("category_id") WHERE ("category_id" IS NOT NULL);



CREATE INDEX "quality_control_types_duplicate_fts_idx" ON "mod_base"."quality_control_types_duplicate" USING "gin" ("fts");



CREATE INDEX "quality_control_types_duplicate_is_active_idx" ON "mod_base"."quality_control_types_duplicate" USING "btree" ("is_active");



CREATE INDEX "quality_control_types_duplicate_is_required_idx" ON "mod_base"."quality_control_types_duplicate" USING "btree" ("is_required");



CREATE INDEX "quality_control_types_duplicate_timing_idx" ON "mod_base"."quality_control_types_duplicate" USING "btree" ("timing");



CREATE INDEX "quality_control_types_duplicate_work_cycle_id_idx" ON "mod_base"."quality_control_types_duplicate" USING "btree" ("work_cycle_id");



CREATE INDEX "idx_fields_fts" ON "mod_datalayer"."fields" USING "gin" ("fts");



CREATE INDEX "idx_main_menu_fts" ON "mod_datalayer"."main_menu" USING "gin" ("fts");



CREATE INDEX "idx_modules_fts" ON "mod_datalayer"."modules" USING "gin" ("fts");



CREATE INDEX "idx_pages_departments_composite" ON "mod_datalayer"."pages_departments" USING "btree" ("page_id", "department_id");



CREATE INDEX "idx_pages_departments_department_id" ON "mod_datalayer"."pages_departments" USING "btree" ("department_id");



CREATE INDEX "idx_pages_departments_is_deleted" ON "mod_datalayer"."pages_departments" USING "btree" ("is_deleted") WHERE ("is_deleted" = false);



CREATE INDEX "idx_pages_departments_page_id" ON "mod_datalayer"."pages_departments" USING "btree" ("page_id");



CREATE INDEX "idx_pages_fts" ON "mod_datalayer"."pages" USING "gin" ("fts");



CREATE INDEX "idx_pages_is_visible" ON "mod_datalayer"."pages" USING "btree" ("is_visible");



CREATE INDEX "idx_pages_menu_departments_composite" ON "mod_datalayer"."pages_menu_departments" USING "btree" ("page_id", "department_id");



CREATE INDEX "idx_pages_menu_departments_department_id" ON "mod_datalayer"."pages_menu_departments" USING "btree" ("department_id");



CREATE INDEX "idx_pages_menu_departments_page_id" ON "mod_datalayer"."pages_menu_departments" USING "btree" ("page_id");



CREATE INDEX "idx_tables_fts" ON "mod_datalayer"."tables" USING "gin" ("fts");



CREATE INDEX "idx_coil_consumption_coil_id" ON "mod_manufacturing"."coil_consumption" USING "btree" ("coil_id");



CREATE INDEX "idx_coil_consumption_production_plan_id" ON "mod_manufacturing"."coil_consumption" USING "btree" ("production_plan_id");



CREATE INDEX "idx_coils_location_id" ON "mod_manufacturing"."coils" USING "btree" ("location_id");



CREATE INDEX "idx_coils_material_type" ON "mod_manufacturing"."coils" USING "btree" ("material_type");



CREATE INDEX "idx_coils_status" ON "mod_manufacturing"."coils" USING "btree" ("status");



CREATE INDEX "idx_coils_weight_kg" ON "mod_manufacturing"."coils" USING "btree" ("weight_kg");



CREATE INDEX "idx_plate_templates_material_thickness" ON "mod_manufacturing"."plate_templates" USING "btree" ("material_thickness");



CREATE INDEX "idx_plate_templates_plate_type" ON "mod_manufacturing"."plate_templates" USING "btree" ("plate_type");



CREATE INDEX "idx_production_plans_coil_id" ON "mod_manufacturing"."coil_production_plans" USING "btree" ("coil_id");



CREATE INDEX "idx_production_plans_status" ON "mod_manufacturing"."coil_production_plans" USING "btree" ("status");



CREATE INDEX "idx_production_plans_template_id" ON "mod_manufacturing"."coil_production_plans" USING "btree" ("plate_template_id");



CREATE INDEX "idx_recipes_destination_article" ON "mod_manufacturing"."recipes" USING "btree" ("destination_article_id");



CREATE INDEX "idx_recipes_finished_product" ON "mod_manufacturing"."recipes" USING "btree" ("finished_product_id");



CREATE INDEX "idx_recipes_source_article" ON "mod_manufacturing"."recipes" USING "btree" ("source_article_id");



CREATE INDEX "idx_scheduled_items_article_id" ON "mod_manufacturing"."scheduled_items" USING "btree" ("article_id");



CREATE INDEX "idx_scheduled_items_sales_order_id" ON "mod_manufacturing"."scheduled_items" USING "btree" ("sales_order_id");



CREATE INDEX "idx_scheduled_items_sales_order_item_id" ON "mod_manufacturing"."scheduled_items" USING "btree" ("sales_order_item_id");



CREATE INDEX "idx_scheduled_items_scheduled_date" ON "mod_manufacturing"."scheduled_items" USING "btree" ("scheduled_date");



CREATE INDEX "idx_scheduled_items_status" ON "mod_manufacturing"."scheduled_items" USING "btree" ("status");



CREATE INDEX "idx_wcc_from_category_id" ON "mod_manufacturing"."work_cycle_categories" USING "btree" ("from_article_category_id");



CREATE INDEX "idx_wcc_location_id" ON "mod_manufacturing"."work_cycle_categories" USING "btree" ("location_id");



CREATE INDEX "idx_wcc_to_category_id" ON "mod_manufacturing"."work_cycle_categories" USING "btree" ("to_article_category_id");



CREATE INDEX "idx_wcc_work_cycle_id" ON "mod_manufacturing"."work_cycle_categories" USING "btree" ("work_cycle_id");



CREATE INDEX "idx_wcc_work_flow_id" ON "mod_manufacturing"."work_cycle_categories" USING "btree" ("work_flow_id");



CREATE INDEX "idx_wfwc_work_cycle_id" ON "mod_manufacturing"."work_flows_work_cycles" USING "btree" ("work_cycle_id");



CREATE INDEX "idx_wfwc_work_flow_id" ON "mod_manufacturing"."work_flows_work_cycles" USING "btree" ("work_flow_id");



CREATE INDEX "idx_work_order_attachments_work_order_id" ON "mod_manufacturing"."work_order_attachments" USING "btree" ("work_order_id");



CREATE INDEX "idx_work_order_quality_summary_domain_id" ON "mod_manufacturing"."work_order_quality_summary" USING "btree" ("domain_id");



CREATE INDEX "idx_work_order_quality_summary_inspector_id" ON "mod_manufacturing"."work_order_quality_summary" USING "btree" ("inspector_id");



CREATE INDEX "idx_work_order_quality_summary_overall_status" ON "mod_manufacturing"."work_order_quality_summary" USING "btree" ("overall_status");



CREATE INDEX "idx_work_order_quality_summary_work_order_id" ON "mod_manufacturing"."work_order_quality_summary" USING "btree" ("work_order_id");



CREATE INDEX "idx_work_orders_internal_sales_order_id" ON "mod_manufacturing"."work_orders" USING "btree" ("internal_sales_order_id");



CREATE INDEX "idx_work_orders_location_id" ON "mod_manufacturing"."work_orders" USING "btree" ("location_id");



CREATE INDEX "idx_work_orders_warehouse_id" ON "mod_manufacturing"."work_orders" USING "btree" ("warehouse_id");



CREATE INDEX "idx_work_steps_work_order_id" ON "mod_manufacturing"."work_steps" USING "btree" ("work_order_id");



CREATE INDEX "idx_notifications_fts" ON "mod_pulse"."notifications" USING "gin" ("fts");



CREATE INDEX "idx_pulse_chat_mentions" ON "mod_pulse"."pulse_chat" USING "gin" ("mentions");



CREATE INDEX "idx_pulse_chat_message_type" ON "mod_pulse"."pulse_chat" USING "btree" ("message_type");



CREATE INDEX "idx_pulse_chat_read_by" ON "mod_pulse"."pulse_chat" USING "gin" ("read_by");



CREATE INDEX "idx_pulse_chat_reply_to_id" ON "mod_pulse"."pulse_chat" USING "btree" ("reply_to_id");



CREATE INDEX "idx_pulse_progress_fts" ON "mod_pulse"."pulse_progress" USING "gin" ("fts");



CREATE INDEX "idx_pulse_slas_fts" ON "mod_pulse"."pulse_slas" USING "gin" ("fts");



CREATE INDEX "idx_pulses_conversation_type" ON "mod_pulse"."pulses" USING "btree" ("conversation_type");



CREATE INDEX "idx_pulses_department_id" ON "mod_pulse"."pulses" USING "btree" ("department_id");



CREATE INDEX "idx_pulses_fts" ON "mod_pulse"."pulses" USING "gin" ("fts");



CREATE INDEX "idx_pulses_last_message_at" ON "mod_pulse"."pulses" USING "btree" ("last_message_at" DESC);



CREATE INDEX "idx_tasks_fts" ON "mod_pulse"."tasks" USING "gin" ("fts");



CREATE INDEX "idx_conformity_docs_qc_id" ON "mod_quality_control"."conformity_documents" USING "btree" ("quality_control_id");



CREATE INDEX "idx_conformity_docs_type" ON "mod_quality_control"."conformity_documents" USING "btree" ("document_type");



CREATE INDEX "idx_qc_checklist_qc_id" ON "mod_quality_control"."quality_control_checklist_results" USING "btree" ("quality_control_id");



CREATE INDEX "idx_qc_defects_qc_id" ON "mod_quality_control"."quality_control_defects" USING "btree" ("quality_control_id");



CREATE INDEX "idx_qc_measurements_qc_id" ON "mod_quality_control"."quality_control_measurements" USING "btree" ("quality_control_id");



CREATE INDEX "idx_supplier_returns_qc_id" ON "mod_quality_control"."supplier_returns" USING "btree" ("quality_control_id");



CREATE INDEX "idx_supplier_returns_status" ON "mod_quality_control"."supplier_returns" USING "btree" ("return_status");



CREATE INDEX "idx_supplier_returns_supplier_id" ON "mod_quality_control"."supplier_returns" USING "btree" ("supplier_id");



CREATE INDEX "idx_box_contents_box_id" ON "mod_wms"."box_contents" USING "btree" ("shipment_box_id");



CREATE INDEX "idx_box_contents_domain_id" ON "mod_wms"."box_contents" USING "btree" ("domain_id");



CREATE INDEX "idx_box_contents_item_id" ON "mod_wms"."box_contents" USING "btree" ("shipment_item_id");



CREATE INDEX "idx_box_types_domain_id" ON "mod_wms"."box_types" USING "btree" ("domain_id");



CREATE INDEX "idx_carton_contents_carton_id" ON "mod_wms"."carton_contents" USING "btree" ("shipment_carton_id");



CREATE INDEX "idx_carton_contents_domain_id" ON "mod_wms"."carton_contents" USING "btree" ("domain_id");



CREATE INDEX "idx_carton_contents_item_id" ON "mod_wms"."carton_contents" USING "btree" ("shipment_item_id");



CREATE INDEX "idx_carton_types_domain_id" ON "mod_wms"."carton_types" USING "btree" ("domain_id");



CREATE INDEX "idx_inventory_batch_lookup" ON "mod_wms"."inventory" USING "btree" ("article_id", "location_id", "batch_id") WHERE ("batch_id" IS NOT NULL);



CREATE INDEX "idx_inventory_domain" ON "mod_wms"."inventory" USING "btree" ("domain_id");



CREATE INDEX "idx_inventory_no_batch" ON "mod_wms"."inventory" USING "btree" ("article_id", "location_id") WHERE ("batch_id" IS NULL);



CREATE UNIQUE INDEX "idx_inventory_no_batch_unique" ON "mod_wms"."inventory" USING "btree" ("article_id", "location_id") WHERE ("batch_id" IS NULL);



CREATE INDEX "idx_pallet_contents_domain_id" ON "mod_wms"."pallet_contents" USING "btree" ("domain_id");



CREATE INDEX "idx_pallet_contents_item_id" ON "mod_wms"."pallet_contents" USING "btree" ("shipment_item_id");



CREATE INDEX "idx_pallet_contents_pallet_id" ON "mod_wms"."pallet_contents" USING "btree" ("shipment_pallet_id");



CREATE INDEX "idx_pallet_types_domain_id" ON "mod_wms"."pallet_types" USING "btree" ("domain_id");



CREATE INDEX "idx_receipt_items_is_moved" ON "mod_wms"."receipt_items" USING "btree" ("is_moved") WHERE ("is_moved" = false);



CREATE INDEX "idx_receipt_items_moved_date" ON "mod_wms"."receipt_items" USING "btree" ("moved_date") WHERE ("moved_date" IS NOT NULL);



CREATE INDEX "idx_receipts_invoice_number" ON "mod_wms"."receipts" USING "btree" ("invoice_number");



CREATE INDEX "idx_receipts_supplier_id" ON "mod_wms"."receipts" USING "btree" ("supplier_id");



CREATE INDEX "idx_receipts_supplier_order_number" ON "mod_wms"."receipts" USING "btree" ("supplier_order_number");



CREATE INDEX "idx_receipts_transport_document_number" ON "mod_wms"."receipts" USING "btree" ("transport_document_number");



CREATE INDEX "idx_shipment_attachments_shipment_id" ON "mod_wms"."shipment_attachments" USING "btree" ("shipment_id");



CREATE INDEX "idx_shipment_attachments_type" ON "mod_wms"."shipment_attachments" USING "btree" ("attachment_type");



CREATE INDEX "idx_shipment_boxes_domain_id" ON "mod_wms"."shipment_boxes" USING "btree" ("domain_id");



CREATE INDEX "idx_shipment_boxes_pallet_id" ON "mod_wms"."shipment_boxes" USING "btree" ("shipment_pallet_id");



CREATE INDEX "idx_shipment_boxes_shipment_id" ON "mod_wms"."shipment_boxes" USING "btree" ("shipment_id") WHERE ("shipment_id" IS NOT NULL);



CREATE INDEX "idx_shipment_cartons_domain_id" ON "mod_wms"."shipment_cartons" USING "btree" ("domain_id");



CREATE INDEX "idx_shipment_cartons_pallet_id" ON "mod_wms"."shipment_cartons" USING "btree" ("shipment_pallet_id");



CREATE INDEX "idx_shipment_item_addresses_address_type" ON "mod_wms"."shipment_item_addresses" USING "btree" ("address_type");



CREATE INDEX "idx_shipment_item_addresses_domain_id" ON "mod_wms"."shipment_item_addresses" USING "btree" ("domain_id");



CREATE INDEX "idx_shipment_item_addresses_is_deleted" ON "mod_wms"."shipment_item_addresses" USING "btree" ("is_deleted");



CREATE INDEX "idx_shipment_item_addresses_location" ON "mod_wms"."shipment_item_addresses" USING "btree" ("city", "state", "country");



CREATE INDEX "idx_shipment_item_addresses_primary" ON "mod_wms"."shipment_item_addresses" USING "btree" ("shipment_item_id", "address_type", "is_primary");



CREATE INDEX "idx_shipment_item_addresses_shipment_item_id" ON "mod_wms"."shipment_item_addresses" USING "btree" ("shipment_item_id");



CREATE INDEX "idx_shipment_pallets_domain_id" ON "mod_wms"."shipment_pallets" USING "btree" ("domain_id");



CREATE INDEX "idx_shipment_pallets_shipment_id" ON "mod_wms"."shipment_pallets" USING "btree" ("shipment_id");



CREATE INDEX "idx_shipment_sales_orders_domain_id" ON "mod_wms"."shipment_sales_orders" USING "btree" ("domain_id");



CREATE INDEX "idx_shipment_sales_orders_sales_order_id" ON "mod_wms"."shipment_sales_orders" USING "btree" ("sales_order_id");



CREATE INDEX "idx_shipment_sales_orders_shipment_id" ON "mod_wms"."shipment_sales_orders" USING "btree" ("shipment_id");



CREATE INDEX "idx_shipment_standalone_items_domain_id" ON "mod_wms"."shipment_standalone_items" USING "btree" ("domain_id");



CREATE INDEX "idx_shipment_standalone_items_item_id" ON "mod_wms"."shipment_standalone_items" USING "btree" ("shipment_item_id");



CREATE INDEX "idx_shipment_standalone_items_shipment_id" ON "mod_wms"."shipment_standalone_items" USING "btree" ("shipment_id");



CREATE INDEX "idx_shipments_archived_deleted" ON "mod_wms"."shipments" USING "btree" ("is_archived", "is_deleted");



CREATE INDEX "idx_shipments_is_archived" ON "mod_wms"."shipments" USING "btree" ("is_archived");



CREATE INDEX "idx_stock_movements_internal_sales_order_id" ON "mod_wms"."stock_movements" USING "btree" ("internal_sales_order_id") WHERE ("internal_sales_order_id" IS NOT NULL);



CREATE INDEX "idx_stock_movements_origin_article_id" ON "mod_wms"."stock_movements" USING "btree" ("origin_article_id") WHERE ("origin_article_id" IS NOT NULL);



CREATE INDEX "idx_stock_movements_original_receipt_item_id" ON "mod_wms"."stock_movements" USING "btree" ("original_receipt_item_id") WHERE ("original_receipt_item_id" IS NOT NULL);



CREATE INDEX "idx_stock_movements_receipt_item_id" ON "mod_wms"."stock_movements" USING "btree" ("receipt_item_id") WHERE ("receipt_item_id" IS NOT NULL);



CREATE INDEX "idx_stock_movements_sales_order_id" ON "mod_wms"."stock_movements" USING "btree" ("sales_order_id") WHERE ("sales_order_id" IS NOT NULL);



CREATE INDEX "idx_stock_movements_unit_of_measure_id" ON "mod_wms"."stock_movements" USING "btree" ("unit_of_measure_id");



CREATE INDEX "idx_stock_movements_work_order_id" ON "mod_wms"."stock_movements" USING "btree" ("work_order_id") WHERE ("work_order_id" IS NOT NULL);



CREATE UNIQUE INDEX "shipment_boxes_unique_number_per_pallet" ON "mod_wms"."shipment_boxes" USING "btree" ("shipment_pallet_id", "box_number") WHERE ("shipment_pallet_id" IS NOT NULL);



CREATE UNIQUE INDEX "shipment_boxes_unique_number_per_shipment" ON "mod_wms"."shipment_boxes" USING "btree" ("shipment_id", "box_number") WHERE (("shipment_id" IS NOT NULL) AND ("shipment_pallet_id" IS NULL));



CREATE UNIQUE INDEX "uq_receipts_receipt_number_active" ON "mod_wms"."receipts" USING "btree" ("receipt_number") WHERE ("is_deleted" = false);



CREATE OR REPLACE VIEW "mod_base"."quality_control_summary" WITH ("security_invoker"='on') AS
 SELECT "qc"."id",
    "qc"."code",
    "qc"."name",
    "qc"."status",
    "qc"."reference_type",
    "qc"."reference_id",
    "qc"."inspector_id",
    "qc"."quantity_checked",
    "qc"."quantity_passed",
    "qc"."quantity_failed",
    "count"(DISTINCT "qcd"."id") AS "defect_count",
    "count"(DISTINCT "qcm"."id") AS "measurement_count",
    "count"(DISTINCT "qcr"."id") AS "checklist_count",
    "qc"."created_at",
    "qc"."completed_date",
    "u"."email" AS "inspector_email",
    ("u"."raw_user_meta_data" ->> 'full_name'::"text") AS "inspector_name",
    "qc"."purchase_order_item_id",
    "po"."code" AS "purchase_order_code",
    "po"."supplier_id",
    "poi"."name" AS "item_name",
    "poi"."quantity_ordered",
    "poi"."quantity_received",
    "poi"."quantity_defect",
    "s"."name" AS "supplier_name",
        CASE
            WHEN ("qc"."purchase_order_item_id" IS NOT NULL) THEN 'INCOMING_MATERIAL'::"text"
            WHEN ("qc"."reference_type" = 'WORK_ORDER'::"text") THEN 'PRODUCTION'::"text"
            WHEN ("qc"."reference_type" = 'SALES_ORDER'::"text") THEN 'OUTGOING'::"text"
            ELSE 'OTHER'::"text"
        END AS "qc_type"
   FROM ((((((("mod_base"."quality_control" "qc"
     LEFT JOIN "mod_base"."purchase_order_items" "poi" ON (("qc"."purchase_order_item_id" = "poi"."id")))
     LEFT JOIN "mod_base"."purchase_orders" "po" ON (("poi"."purchase_order_id" = "po"."id")))
     LEFT JOIN "mod_base"."suppliers" "s" ON (("po"."supplier_id" = "s"."id")))
     LEFT JOIN "mod_quality_control"."quality_control_defects" "qcd" ON ((("qc"."id" = "qcd"."quality_control_id") AND (NOT "qcd"."is_deleted"))))
     LEFT JOIN "mod_quality_control"."quality_control_measurements" "qcm" ON ((("qc"."id" = "qcm"."quality_control_id") AND (NOT "qcm"."is_deleted"))))
     LEFT JOIN "mod_quality_control"."quality_control_checklist_results" "qcr" ON ((("qc"."id" = "qcr"."quality_control_id") AND (NOT "qcr"."is_deleted"))))
     LEFT JOIN "auth"."users" "u" ON (("qc"."inspector_id" = "u"."id")))
  WHERE (NOT "qc"."is_deleted")
  GROUP BY "qc"."id", "po"."code", "po"."supplier_id", "poi"."name", "poi"."quantity_ordered", "poi"."quantity_received", "poi"."quantity_defect", "s"."name", "u"."email", "u"."raw_user_meta_data";



CREATE OR REPLACE TRIGGER "before_background_image_changes" BEFORE DELETE OR UPDATE OF "background_image_url" ON "mod_admin"."user_profiles" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_background_image"();



CREATE OR REPLACE TRIGGER "before_domains_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_admin"."domains" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_profile_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_admin"."user_profiles" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "domain_modules_insert_audit" BEFORE INSERT ON "mod_admin"."domain_modules" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."handle_domain_modules_audit"();



CREATE OR REPLACE TRIGGER "domain_modules_update_audit" BEFORE UPDATE ON "mod_admin"."domain_modules" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."handle_domain_modules_audit"();



CREATE OR REPLACE TRIGGER "domain_users_insert_audit" BEFORE INSERT ON "mod_admin"."domain_users" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."handle_domain_users_audit"();



CREATE OR REPLACE TRIGGER "domain_users_update_audit" BEFORE UPDATE ON "mod_admin"."domain_users" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."handle_domain_users_audit"();



CREATE OR REPLACE TRIGGER "domains_insert_audit" BEFORE INSERT ON "mod_admin"."domains" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."handle_domains_audit"();



CREATE OR REPLACE TRIGGER "domains_update_audit" BEFORE UPDATE ON "mod_admin"."domains" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."handle_domains_audit"();



CREATE OR REPLACE TRIGGER "set_domains_code" BEFORE INSERT ON "mod_admin"."domains" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_user_profiles_code" BEFORE INSERT ON "mod_admin"."user_profiles" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "user_profiles_insert_audit" BEFORE INSERT ON "mod_admin"."user_profiles" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."handle_userprofile_audit"();



CREATE OR REPLACE TRIGGER "user_profiles_update_audit" BEFORE UPDATE ON "mod_admin"."user_profiles" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."handle_userprofile_audit"();



CREATE OR REPLACE TRIGGER "announcements_insert_audit" BEFORE INSERT ON "mod_base"."announcements" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_announcements_audit"();



CREATE OR REPLACE TRIGGER "announcements_update_audit" BEFORE UPDATE ON "mod_base"."announcements" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_announcements_audit"();



CREATE OR REPLACE TRIGGER "article_categories_insert_audit" BEFORE INSERT ON "mod_base"."article_categories" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_article_categories_audit"();



CREATE OR REPLACE TRIGGER "article_categories_update_audit" BEFORE UPDATE ON "mod_base"."article_categories" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_article_categories_audit"();



CREATE OR REPLACE TRIGGER "articles_insert_audit" BEFORE INSERT ON "mod_base"."articles" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_articles_audit"();



CREATE OR REPLACE TRIGGER "articles_update_audit" BEFORE UPDATE ON "mod_base"."articles" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_articles_audit"();



CREATE OR REPLACE TRIGGER "before_announcements_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_base"."announcements" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_article_categories_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_base"."article_categories" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_articles_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_base"."articles" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_departments_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_base"."departments" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_employees_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_base"."employees" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_internal_sales_order_items_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_base"."internal_sales_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_internal_sales_orders_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_base"."internal_sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_purchase_order_items_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_base"."purchase_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_purchase_orders_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_base"."purchase_orders" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_quality_control_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_base"."quality_control" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_sales_order_items_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_base"."sales_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_sales_orders_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_base"."sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_units_of_measure_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_base"."units_of_measure" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "create_pulse_for_internal_sales_orders" BEFORE INSERT ON "mod_base"."internal_sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."create_pulse_for_record"();



CREATE OR REPLACE TRIGGER "create_pulse_for_purchase_orders" BEFORE INSERT ON "mod_base"."purchase_orders" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."create_pulse_for_record"();



CREATE OR REPLACE TRIGGER "create_pulse_for_sales_orders" BEFORE INSERT ON "mod_base"."sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."create_pulse_for_record"();



CREATE OR REPLACE TRIGGER "customer_addresses_insert_audit" BEFORE INSERT ON "mod_base"."customer_addresses" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_customer_addresses_audit"();



CREATE OR REPLACE TRIGGER "customer_addresses_update_audit" BEFORE UPDATE ON "mod_base"."customer_addresses" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_customer_addresses_audit"();



CREATE OR REPLACE TRIGGER "customers_insert_audit" BEFORE INSERT ON "mod_base"."customers" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_customers_audit"();



CREATE OR REPLACE TRIGGER "customers_update_audit" BEFORE UPDATE ON "mod_base"."customers" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_customers_audit"();



CREATE OR REPLACE TRIGGER "departments_insert_audit" BEFORE INSERT ON "mod_base"."departments" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_departments_audit"();



CREATE OR REPLACE TRIGGER "departments_update_audit" BEFORE UPDATE ON "mod_base"."departments" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_departments_audit"();



CREATE OR REPLACE TRIGGER "employees_departments_insert_audit" BEFORE INSERT ON "mod_base"."employees_departments" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_employees_departments_audit"();



CREATE OR REPLACE TRIGGER "employees_departments_update_audit" BEFORE UPDATE ON "mod_base"."employees_departments" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_employees_departments_audit"();



CREATE OR REPLACE TRIGGER "employees_insert_audit" BEFORE INSERT ON "mod_base"."employees" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_employees_audit"();



CREATE OR REPLACE TRIGGER "employees_update_audit" BEFORE UPDATE ON "mod_base"."employees" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_employees_audit"();



CREATE OR REPLACE TRIGGER "ensure_single_primary_address_trigger" BEFORE INSERT OR UPDATE ON "mod_base"."customer_addresses" FOR EACH ROW EXECUTE FUNCTION "mod_base"."ensure_single_primary_address"();



CREATE OR REPLACE TRIGGER "fill_employee_fields" AFTER INSERT ON "mod_base"."employees" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_new_employee"();



CREATE OR REPLACE TRIGGER "generate_sales_order_number_trigger" BEFORE INSERT ON "mod_base"."sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_sales_order_number_trigger"();



CREATE OR REPLACE TRIGGER "handle_internal_sales_orders_deletion" AFTER DELETE ON "mod_base"."internal_sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_record_deletion"();



CREATE OR REPLACE TRIGGER "handle_purchase_orders_deletion" AFTER DELETE ON "mod_base"."purchase_orders" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_record_deletion"();



CREATE OR REPLACE TRIGGER "handle_sales_orders_deletion" AFTER DELETE ON "mod_base"."sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_record_deletion"();



CREATE OR REPLACE TRIGGER "internal_sales_order_completion_trigger" AFTER UPDATE OF "is_manufactured" ON "mod_base"."internal_sales_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_internal_sales_order_completion_on_manufacturing"();



COMMENT ON TRIGGER "internal_sales_order_completion_trigger" ON "mod_base"."internal_sales_order_items" IS 'Triggers when is_manufactured changes to TRUE and checks if all items in the internal sales order are manufactured. If yes, updates internal sales order status to completed.';



CREATE OR REPLACE TRIGGER "internal_sales_order_insert_trigger" AFTER INSERT ON "mod_base"."internal_sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_base"."direct_alert_new_sales_order"();



CREATE OR REPLACE TRIGGER "internal_sales_order_items_insert_audit" BEFORE INSERT ON "mod_base"."internal_sales_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_sales_order_items_audit"();



CREATE OR REPLACE TRIGGER "internal_sales_order_items_production_date_cleanup_trigger" AFTER UPDATE OF "production_date" ON "mod_base"."internal_sales_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_base"."cleanup_work_orders_on_internal_unschedule"();



COMMENT ON TRIGGER "internal_sales_order_items_production_date_cleanup_trigger" ON "mod_base"."internal_sales_order_items" IS 'Deletes work orders when internal sales order item production date is unscheduled (set to NULL)';



CREATE OR REPLACE TRIGGER "internal_sales_order_items_production_date_notification_trigger" AFTER UPDATE OF "production_date" ON "mod_base"."internal_sales_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_base"."internal_sales_order_items_production_date_notification"();



COMMENT ON TRIGGER "internal_sales_order_items_production_date_notification_trigger" ON "mod_base"."internal_sales_order_items" IS 'Sends notifications when production date changes on internal sales order items.';



CREATE OR REPLACE TRIGGER "internal_sales_order_items_scheduling_notification_for_fabrizio" AFTER UPDATE OF "production_date" ON "mod_base"."internal_sales_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_base"."internal_sales_order_items_scheduling_notification_for_fabrizio"();



COMMENT ON TRIGGER "internal_sales_order_items_scheduling_notification_for_fabrizio" ON "mod_base"."internal_sales_order_items" IS 'Sends notifications to Fabrizio when internal sales order items are scheduled for production.';



CREATE OR REPLACE TRIGGER "internal_sales_order_items_update_audit" BEFORE UPDATE ON "mod_base"."internal_sales_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_sales_order_items_audit"();



CREATE OR REPLACE TRIGGER "internal_sales_order_status_notification_trigger" AFTER UPDATE OF "status" ON "mod_base"."internal_sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_base"."sales_order_status_notification"();



CREATE OR REPLACE TRIGGER "internal_sales_orders_insert_audit" BEFORE INSERT ON "mod_base"."internal_sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_sales_orders_audit"();



CREATE OR REPLACE TRIGGER "internal_sales_orders_update_audit" BEFORE UPDATE ON "mod_base"."internal_sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_sales_orders_audit"();



CREATE OR REPLACE TRIGGER "profiles_audit_trigger" BEFORE INSERT OR UPDATE ON "mod_base"."profiles" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_profiles_audit"();



CREATE OR REPLACE TRIGGER "purchase_order_items_insert_audit" BEFORE INSERT ON "mod_base"."purchase_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_purchase_order_items_audit"();



CREATE OR REPLACE TRIGGER "purchase_order_items_update_audit" BEFORE UPDATE ON "mod_base"."purchase_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_purchase_order_items_audit"();



CREATE OR REPLACE TRIGGER "purchase_orders_insert_audit" BEFORE INSERT ON "mod_base"."purchase_orders" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_purchase_orders_audit"();



CREATE OR REPLACE TRIGGER "purchase_orders_update_audit" BEFORE UPDATE ON "mod_base"."purchase_orders" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_purchase_orders_audit"();



CREATE OR REPLACE TRIGGER "quality_control_failed_trigger" AFTER UPDATE ON "mod_base"."quality_control" FOR EACH ROW EXECUTE FUNCTION "mod_base"."alert_quality_control_failed"();



CREATE OR REPLACE TRIGGER "quality_control_insert_audit" BEFORE INSERT ON "mod_base"."quality_control" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_quality_control_audit"();



CREATE OR REPLACE TRIGGER "quality_control_types_audit" BEFORE INSERT OR UPDATE ON "mod_base"."quality_control_types" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_quality_control_types_audit"();



CREATE OR REPLACE TRIGGER "quality_control_update_audit" BEFORE UPDATE ON "mod_base"."quality_control" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_quality_control_audit"();



CREATE OR REPLACE TRIGGER "sales_order_insert_trigger" AFTER INSERT ON "mod_base"."sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_base"."direct_alert_new_sales_order"();



CREATE OR REPLACE TRIGGER "sales_order_items_insert_audit" BEFORE INSERT ON "mod_base"."sales_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_sales_order_items_audit"();



CREATE OR REPLACE TRIGGER "sales_order_items_production_date_cleanup_trigger" AFTER UPDATE OF "production_date" ON "mod_base"."sales_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_base"."cleanup_work_orders_on_unschedule"();



CREATE OR REPLACE TRIGGER "sales_order_items_production_date_notification_trigger" AFTER UPDATE OF "production_date" ON "mod_base"."sales_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_base"."sales_order_items_production_date_notification"();



CREATE OR REPLACE TRIGGER "sales_order_items_scheduling_notification_for_fabrizio_trigger" AFTER UPDATE OF "production_date" ON "mod_base"."sales_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_base"."sales_order_items_scheduling_notification_for_fabrizio"();



COMMENT ON TRIGGER "sales_order_items_scheduling_notification_for_fabrizio_trigger" ON "mod_base"."sales_order_items" IS 'Sends notifications to Fabrizio when sales order items are scheduled for production.';



CREATE OR REPLACE TRIGGER "sales_order_items_update_audit" BEFORE UPDATE ON "mod_base"."sales_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_sales_order_items_audit"();



CREATE OR REPLACE TRIGGER "sales_order_status_notification_trigger" AFTER UPDATE OF "status" ON "mod_base"."sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_base"."sales_order_status_notification"();



CREATE OR REPLACE TRIGGER "sales_orders_insert_audit" BEFORE INSERT ON "mod_base"."sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_sales_orders_audit"();



CREATE OR REPLACE TRIGGER "sales_orders_update_audit" BEFORE UPDATE ON "mod_base"."sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_sales_orders_audit"();



CREATE OR REPLACE TRIGGER "serial_number_counters_insert_audit" BEFORE INSERT ON "mod_base"."serial_number_counters" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_serial_number_counters_audit"();



CREATE OR REPLACE TRIGGER "serial_number_counters_update_audit" BEFORE UPDATE ON "mod_base"."serial_number_counters" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_serial_number_counters_audit"();



CREATE OR REPLACE TRIGGER "set_article_categories_code" BEFORE INSERT ON "mod_base"."article_categories" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_articles_code" BEFORE INSERT ON "mod_base"."articles" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_customers_code" BEFORE INSERT ON "mod_base"."customers" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_departments_code" BEFORE INSERT ON "mod_base"."departments" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_employees_code" BEFORE INSERT ON "mod_base"."employees" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_internal_sales_order_items_code" BEFORE INSERT ON "mod_base"."internal_sales_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_internal_sales_orders_code" BEFORE INSERT ON "mod_base"."internal_sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_purchase_order_items_code" BEFORE INSERT ON "mod_base"."purchase_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_purchase_orders_code" BEFORE INSERT ON "mod_base"."purchase_orders" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_sales_order_items_code" BEFORE INSERT ON "mod_base"."sales_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_sales_orders_code" BEFORE INSERT ON "mod_base"."sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_suppliers_code" BEFORE INSERT ON "mod_base"."suppliers" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_units_of_measure_code" BEFORE INSERT ON "mod_base"."units_of_measure" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "suppliers_insert_audit" BEFORE INSERT ON "mod_base"."suppliers" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_suppliers_audit"();



CREATE OR REPLACE TRIGGER "suppliers_update_audit" BEFORE UPDATE ON "mod_base"."suppliers" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_suppliers_audit"();



CREATE OR REPLACE TRIGGER "trigger_archive_sales_order_on_status_completed" AFTER UPDATE OF "status" ON "mod_base"."sales_orders" FOR EACH ROW WHEN ((("new"."status" = 'completed'::"text") AND ("old"."status" IS DISTINCT FROM 'completed'::"text"))) EXECUTE FUNCTION "mod_base"."handle_archive_sales_order_on_status_completed"();



COMMENT ON TRIGGER "trigger_archive_sales_order_on_status_completed" ON "mod_base"."sales_orders" IS 'Archives sales order when status changes to completed. Errors are logged but do not prevent the sales order status update from completing.';



CREATE OR REPLACE TRIGGER "trigger_generate_serial_number_for_sales_order_item" AFTER INSERT ON "mod_base"."sales_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_base"."generate_serial_number_for_sales_order_item"();



COMMENT ON TRIGGER "trigger_generate_serial_number_for_sales_order_item" ON "mod_base"."sales_order_items" IS 'Trigger that automatically generates serial numbers for qualifying sales order items after insertion. 
Handles concurrent inserts safely using row-level locking.';



CREATE OR REPLACE TRIGGER "trigger_update_bom_articles_updated_at" BEFORE UPDATE ON "mod_base"."bom_articles" FOR EACH ROW EXECUTE FUNCTION "mod_base"."update_bom_articles_updated_at"();



CREATE OR REPLACE TRIGGER "trigger_update_expected_delivery_date" AFTER INSERT OR UPDATE OF "production_date" ON "mod_base"."sales_order_items" FOR EACH ROW EXECUTE FUNCTION "public"."update_expected_delivery_date"();



COMMENT ON TRIGGER "trigger_update_expected_delivery_date" ON "mod_base"."sales_order_items" IS 'Updates expected_delivery_date in sales_orders when production_date changes in sales_order_items. Only updates if the new production_date is later than the current expected_delivery_date.';



CREATE OR REPLACE TRIGGER "trigger_update_expected_delivery_date_internal" AFTER INSERT OR UPDATE OF "production_date" ON "mod_base"."internal_sales_order_items" FOR EACH ROW EXECUTE FUNCTION "public"."update_expected_delivery_date"();



CREATE OR REPLACE TRIGGER "trigger_update_quality_control_checklist_results_updated_at" BEFORE UPDATE ON "mod_base"."quality_control_checklist_results" FOR EACH ROW EXECUTE FUNCTION "mod_base"."update_quality_control_checklist_results_updated_at"();



CREATE OR REPLACE TRIGGER "trigger_update_sales_order_status_on_all_items_shipped" AFTER UPDATE OF "is_shipped" ON "mod_base"."sales_order_items" FOR EACH ROW WHEN ((("new"."is_shipped" = true) AND (("old"."is_shipped" IS NULL) OR ("old"."is_shipped" = false)))) EXECUTE FUNCTION "mod_base"."handle_update_sales_order_status_on_all_items_shipped"();



COMMENT ON TRIGGER "trigger_update_sales_order_status_on_all_items_shipped" ON "mod_base"."sales_order_items" IS 'Updates sales_order status to completed when all items are shipped. Errors are logged but do not prevent the sales_order_item update from completing.';



CREATE OR REPLACE TRIGGER "units_of_measure_insert_audit" BEFORE INSERT ON "mod_base"."units_of_measure" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_units_of_measure_audit"();



CREATE OR REPLACE TRIGGER "units_of_measure_update_audit" BEFORE UPDATE ON "mod_base"."units_of_measure" FOR EACH ROW EXECUTE FUNCTION "mod_base"."handle_units_of_measure_audit"();



CREATE OR REPLACE TRIGGER "update_pulse_status_for_internal_sales_orders" AFTER UPDATE OF "status" ON "mod_base"."internal_sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."update_pulse_status"();



CREATE OR REPLACE TRIGGER "update_pulse_status_for_purchase_orders" AFTER UPDATE OF "status" ON "mod_base"."purchase_orders" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."update_pulse_status"();



CREATE OR REPLACE TRIGGER "update_pulse_status_for_sales_orders" AFTER UPDATE OF "status" ON "mod_base"."sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."update_pulse_status"();



CREATE OR REPLACE TRIGGER "update_purchase_order_item_completion" BEFORE INSERT OR UPDATE OF "quantity_received" ON "mod_base"."purchase_order_items" FOR EACH ROW EXECUTE FUNCTION "mod_base"."update_purchase_order_item_completion"();



CREATE OR REPLACE TRIGGER "before_fields_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_datalayer"."fields" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_modules_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_datalayer"."modules" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_page_categories_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_datalayer"."page_categories" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_pages_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_datalayer"."pages" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_tables_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_datalayer"."tables" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "fields_insert_audit" BEFORE INSERT ON "mod_datalayer"."fields" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."handle_fields_audit"();



CREATE OR REPLACE TRIGGER "fields_update_audit" BEFORE UPDATE ON "mod_datalayer"."fields" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."handle_fields_audit"();



CREATE OR REPLACE TRIGGER "main_menu_insert_audit" BEFORE INSERT ON "mod_datalayer"."main_menu" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."handle_main_menu_audit"();



CREATE OR REPLACE TRIGGER "main_menu_update_audit" BEFORE UPDATE ON "mod_datalayer"."main_menu" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."handle_main_menu_audit"();



CREATE OR REPLACE TRIGGER "modules_insert_audit" BEFORE INSERT ON "mod_datalayer"."modules" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."handle_modules_audit"();



CREATE OR REPLACE TRIGGER "modules_update_audit" BEFORE UPDATE ON "mod_datalayer"."modules" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."handle_modules_audit"();



CREATE OR REPLACE TRIGGER "page_categories_insert_audit" BEFORE INSERT ON "mod_datalayer"."page_categories" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."handle_page_categories_audit"();



CREATE OR REPLACE TRIGGER "page_categories_update_audit" BEFORE UPDATE ON "mod_datalayer"."page_categories" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."handle_page_categories_audit"();



CREATE OR REPLACE TRIGGER "pages_departments_insert_audit" BEFORE INSERT ON "mod_datalayer"."pages_departments" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."handle_pages_departments_audit"();



CREATE OR REPLACE TRIGGER "pages_departments_update_audit" BEFORE UPDATE ON "mod_datalayer"."pages_departments" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."handle_pages_departments_audit"();



CREATE OR REPLACE TRIGGER "pages_insert_audit" BEFORE INSERT ON "mod_datalayer"."pages" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."handle_pages_audit"();



CREATE OR REPLACE TRIGGER "pages_menu_departments_insert_audit" BEFORE INSERT ON "mod_datalayer"."pages_menu_departments" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."handle_pages_departments_audit"();



CREATE OR REPLACE TRIGGER "pages_menu_departments_update_audit" BEFORE UPDATE ON "mod_datalayer"."pages_menu_departments" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."handle_pages_departments_audit"();



CREATE OR REPLACE TRIGGER "pages_update_audit" BEFORE UPDATE ON "mod_datalayer"."pages" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."handle_pages_audit"();



CREATE OR REPLACE TRIGGER "tables_insert_audit" BEFORE INSERT ON "mod_datalayer"."tables" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."handle_tables_audit"();



CREATE OR REPLACE TRIGGER "tables_update_audit" BEFORE UPDATE ON "mod_datalayer"."tables" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."handle_tables_audit"();



CREATE OR REPLACE TRIGGER "before_departments_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_manufacturing"."departments" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_locations_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_manufacturing"."locations" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_work_cycles_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_manufacturing"."work_cycles" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_work_orders_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_manufacturing"."work_orders" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_work_steps_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_manufacturing"."work_steps" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_workstations_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_manufacturing"."workstations" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "departments_insert_audit" BEFORE INSERT ON "mod_manufacturing"."departments" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_departments_audit"();



CREATE OR REPLACE TRIGGER "departments_update_audit" BEFORE UPDATE ON "mod_manufacturing"."departments" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_departments_audit"();



CREATE OR REPLACE TRIGGER "internal_work_order_manufacturing_trigger" AFTER UPDATE ON "mod_manufacturing"."work_orders" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_internal_work_order_manufacturing_status"();



COMMENT ON TRIGGER "internal_work_order_manufacturing_trigger" ON "mod_manufacturing"."work_orders" IS 'Triggers when work order status changes to completed and marks the corresponding internal sales order item as manufactured if the work order has an internal_sales_order_id';



CREATE OR REPLACE TRIGGER "locations_insert_audit" BEFORE INSERT ON "mod_manufacturing"."locations" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_locations_audit"();



CREATE OR REPLACE TRIGGER "locations_update_audit" BEFORE UPDATE ON "mod_manufacturing"."locations" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_locations_audit"();



CREATE OR REPLACE TRIGGER "production_logs_insert_audit" BEFORE INSERT ON "mod_manufacturing"."production_logs" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_production_logs_audit"();



CREATE OR REPLACE TRIGGER "production_logs_update_audit" BEFORE UPDATE ON "mod_manufacturing"."production_logs" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_production_logs_audit"();



CREATE OR REPLACE TRIGGER "recipes_insert_audit" BEFORE INSERT ON "mod_manufacturing"."recipes" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_recipes_audit"();



CREATE OR REPLACE TRIGGER "recipes_update_audit" BEFORE UPDATE ON "mod_manufacturing"."recipes" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_recipes_audit"();



CREATE OR REPLACE TRIGGER "scheduled_items_insert_audit" BEFORE INSERT ON "mod_manufacturing"."scheduled_items" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_scheduled_items_audit"();



CREATE OR REPLACE TRIGGER "scheduled_items_update_audit" BEFORE UPDATE ON "mod_manufacturing"."scheduled_items" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_scheduled_items_audit"();



CREATE OR REPLACE TRIGGER "set_manufacturing_departments_code" BEFORE INSERT ON "mod_manufacturing"."departments" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_manufacturing_locations_code" BEFORE INSERT ON "mod_manufacturing"."locations" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_mod_manufacturing_recipes_updated_at" BEFORE UPDATE ON "mod_manufacturing"."recipes" FOR EACH ROW EXECUTE FUNCTION "common"."set_updated_at"();



CREATE OR REPLACE TRIGGER "set_work_cycles_code" BEFORE INSERT ON "mod_manufacturing"."work_cycles" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_work_orders_code" BEFORE INSERT ON "mod_manufacturing"."work_orders" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_work_steps_code" BEFORE INSERT ON "mod_manufacturing"."work_steps" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_workstations_code" BEFORE INSERT ON "mod_manufacturing"."workstations" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "trigger_update_article_loaded_for_all_work_orders" AFTER UPDATE OF "article_loaded" ON "mod_manufacturing"."work_orders" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."update_article_loaded_for_all_work_orders"();



COMMENT ON TRIGGER "trigger_update_article_loaded_for_all_work_orders" ON "mod_manufacturing"."work_orders" IS 'Automatically updates article_loaded=TRUE for all work orders with the same sales_order_id and article_id when one work order is loaded. This ensures that all work orders of the same article are marked as loaded after a single loading operation.';



CREATE OR REPLACE TRIGGER "trigger_update_article_unloaded_for_all_work_orders" AFTER UPDATE OF "article_unloaded" ON "mod_manufacturing"."work_orders" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."update_article_unloaded_for_all_work_orders"();



COMMENT ON TRIGGER "trigger_update_article_unloaded_for_all_work_orders" ON "mod_manufacturing"."work_orders" IS 'Automatically updates article_unloaded=TRUE for all work orders with the same sales_order_id and article_id when one work order is unloaded. This ensures that quality control can proceed for all work orders of the same article after a single unloading operation.';



CREATE OR REPLACE TRIGGER "trigger_update_production_date_on_work_order_insert" AFTER INSERT ON "mod_manufacturing"."work_orders" FOR EACH ROW WHEN (("new"."scheduled_start" IS NOT NULL)) EXECUTE FUNCTION "mod_manufacturing"."update_production_date_on_work_order_insert"();



COMMENT ON TRIGGER "trigger_update_production_date_on_work_order_insert" ON "mod_manufacturing"."work_orders" IS 'Updates production_date in order items when a work order is created with scheduled_start date.';



CREATE OR REPLACE TRIGGER "trigger_update_sales_order_in_production_on_work_order_status" AFTER UPDATE OF "status" ON "mod_manufacturing"."work_orders" FOR EACH ROW WHEN ((("old"."status" = 'pending'::"text") AND ("new"."status" = 'in_progress'::"text"))) EXECUTE FUNCTION "mod_manufacturing"."update_sales_order_in_production_on_work_order_status"();



COMMENT ON TRIGGER "trigger_update_sales_order_in_production_on_work_order_status" ON "mod_manufacturing"."work_orders" IS 'Sets in_production = TRUE on the associated sales order when work order status changes from pending to in_progress.';



CREATE OR REPLACE TRIGGER "trigger_update_work_cycle_categories_updated_at" BEFORE UPDATE ON "mod_manufacturing"."work_cycle_categories" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."update_work_cycle_categories_updated_at"();



CREATE OR REPLACE TRIGGER "trigger_update_work_flows_work_cycles_updated_at" BEFORE UPDATE ON "mod_manufacturing"."work_flows_work_cycles" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."update_work_flows_work_cycles_updated_at"();



CREATE OR REPLACE TRIGGER "update_sales_order_status_on_work_order_in_progress_trigger" AFTER UPDATE OF "status" ON "mod_manufacturing"."work_orders" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."update_sales_order_status_on_work_order_in_progress"();



COMMENT ON TRIGGER "update_sales_order_status_on_work_order_in_progress_trigger" ON "mod_manufacturing"."work_orders" IS 'Triggers when work order status changes to "in_progress" and updates the related sales_order or internal_sales_order status to "processing"';



CREATE OR REPLACE TRIGGER "work_cycles_insert_audit" BEFORE INSERT ON "mod_manufacturing"."work_cycles" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_work_cycles_audit"();



CREATE OR REPLACE TRIGGER "work_cycles_update_audit" BEFORE UPDATE ON "mod_manufacturing"."work_cycles" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_work_cycles_audit"();



CREATE OR REPLACE TRIGGER "work_order_manufacturing_trigger" AFTER UPDATE ON "mod_manufacturing"."work_orders" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_work_order_manufacturing_status"();



COMMENT ON TRIGGER "work_order_manufacturing_trigger" ON "mod_manufacturing"."work_orders" IS 'Triggers when work order status changes to completed and marks the corresponding sales order item as manufactured';



CREATE OR REPLACE TRIGGER "work_order_quality_summary_auto_create" AFTER INSERT ON "mod_manufacturing"."work_orders" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."create_work_order_quality_summary"();



CREATE OR REPLACE TRIGGER "work_order_quality_summary_insert_audit" BEFORE INSERT ON "mod_manufacturing"."work_order_quality_summary" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_work_order_quality_summary_audit"();



CREATE OR REPLACE TRIGGER "work_order_quality_summary_update_audit" BEFORE UPDATE ON "mod_manufacturing"."work_order_quality_summary" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_work_order_quality_summary_audit"();



CREATE OR REPLACE TRIGGER "work_order_status_notification_trigger" AFTER UPDATE ON "mod_manufacturing"."work_orders" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_work_order_status_notifications"();



COMMENT ON TRIGGER "work_order_status_notification_trigger" ON "mod_manufacturing"."work_orders" IS 'Triggers individual notifications for each employee in the Administration / Production Scheduling department (UUID: 59333c3d-da35-4b5b-9122-391d327df937) when work order status changes occur (pending→in_progress, in_progress→paused, paused→in_progress, in_progress→completed)';



CREATE OR REPLACE TRIGGER "work_orders_insert_audit" BEFORE INSERT ON "mod_manufacturing"."work_orders" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_work_orders_audit"();



CREATE OR REPLACE TRIGGER "work_orders_update_audit" BEFORE UPDATE ON "mod_manufacturing"."work_orders" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_work_orders_audit"();



CREATE OR REPLACE TRIGGER "work_steps_insert_audit" BEFORE INSERT ON "mod_manufacturing"."work_steps" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_work_steps_audit"();



CREATE OR REPLACE TRIGGER "work_steps_update_audit" BEFORE UPDATE ON "mod_manufacturing"."work_steps" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_work_steps_audit"();



CREATE OR REPLACE TRIGGER "workstations_insert_audit" BEFORE INSERT ON "mod_manufacturing"."workstations" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_workstations_audit"();



CREATE OR REPLACE TRIGGER "workstations_update_audit" BEFORE UPDATE ON "mod_manufacturing"."workstations" FOR EACH ROW EXECUTE FUNCTION "mod_manufacturing"."handle_workstations_audit"();



CREATE OR REPLACE TRIGGER "before_chat_attachment_delete" BEFORE DELETE ON "mod_pulse"."pulse_chat_files" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."delete_old_chat_attachment"();



CREATE OR REPLACE TRIGGER "before_notifications_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_pulse"."notifications" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_pulse_chat_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_pulse"."pulse_chat" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_pulse_checklists_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_pulse"."pulse_checklists" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_pulse_comments_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_pulse"."pulse_comments" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_pulse_progress_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_pulse"."pulse_progress" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_pulse_sla_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_pulse"."pulse_slas" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_pulses_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_pulse"."pulses" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_tasks_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_pulse"."tasks" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "department_notification_configs_insert_audit" BEFORE INSERT ON "mod_pulse"."department_notification_configs" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_department_notification_configs_audit"();



CREATE OR REPLACE TRIGGER "department_notification_configs_update_audit" BEFORE UPDATE ON "mod_pulse"."department_notification_configs" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_department_notification_configs_audit"();



CREATE OR REPLACE TRIGGER "notifications_insert_audit" BEFORE INSERT ON "mod_pulse"."notifications" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_notifications_audit"();



CREATE OR REPLACE TRIGGER "notifications_update_audit" BEFORE UPDATE ON "mod_pulse"."notifications" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_notifications_audit"();



CREATE OR REPLACE TRIGGER "pulse_chat_files_insert_audit" BEFORE INSERT ON "mod_pulse"."pulse_chat_files" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_pulse_chat_files_audit"();



CREATE OR REPLACE TRIGGER "pulse_chat_files_update_audit" BEFORE UPDATE ON "mod_pulse"."pulse_chat_files" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_pulse_chat_files_audit"();



CREATE OR REPLACE TRIGGER "pulse_chat_insert_audit" BEFORE INSERT ON "mod_pulse"."pulse_chat" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_pulse_chat_audit"();



CREATE OR REPLACE TRIGGER "pulse_chat_update_audit" BEFORE UPDATE ON "mod_pulse"."pulse_chat" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_pulse_chat_audit"();



CREATE OR REPLACE TRIGGER "pulse_checklists_insert_audit" BEFORE INSERT ON "mod_pulse"."pulse_checklists" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_pulse_checklists_audit"();



CREATE OR REPLACE TRIGGER "pulse_checklists_update_audit" BEFORE UPDATE ON "mod_pulse"."pulse_checklists" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_pulse_checklists_audit"();



CREATE OR REPLACE TRIGGER "pulse_comments_insert_audit" BEFORE INSERT ON "mod_pulse"."pulse_comments" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_pulse_comments_audit"();



CREATE OR REPLACE TRIGGER "pulse_comments_update_audit" BEFORE UPDATE ON "mod_pulse"."pulse_comments" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_pulse_comments_audit"();



CREATE OR REPLACE TRIGGER "pulse_conversation_participants_insert_audit" BEFORE INSERT ON "mod_pulse"."pulse_conversation_participants" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_pulse_conversation_participants_audit"();



CREATE OR REPLACE TRIGGER "pulse_conversation_participants_update_audit" BEFORE UPDATE ON "mod_pulse"."pulse_conversation_participants" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_pulse_conversation_participants_audit"();



CREATE OR REPLACE TRIGGER "pulse_progress_insert_audit" BEFORE INSERT ON "mod_pulse"."pulse_progress" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_pulse_progress_audit"();



CREATE OR REPLACE TRIGGER "pulse_progress_update_audit" BEFORE UPDATE ON "mod_pulse"."pulse_progress" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_pulse_progress_audit"();



CREATE OR REPLACE TRIGGER "pulse_sla_insert_audit" BEFORE INSERT ON "mod_pulse"."pulse_slas" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_pulse_sla_audit"();



CREATE OR REPLACE TRIGGER "pulse_sla_update_audit" BEFORE UPDATE ON "mod_pulse"."pulse_slas" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_pulse_sla_audit"();



CREATE OR REPLACE TRIGGER "pulses_insert_audit" BEFORE INSERT ON "mod_pulse"."pulses" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_pulses_audit"();



CREATE OR REPLACE TRIGGER "pulses_update_audit" BEFORE UPDATE ON "mod_pulse"."pulses" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_pulses_audit"();



CREATE OR REPLACE TRIGGER "set_notifications_code" BEFORE INSERT ON "mod_pulse"."notifications" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_pulse_checklists_code" BEFORE INSERT ON "mod_pulse"."pulse_checklists" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_pulse_progress_code" BEFORE INSERT ON "mod_pulse"."pulse_progress" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_pulse_slas_code" BEFORE INSERT ON "mod_pulse"."pulse_slas" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_pulses_code" BEFORE INSERT ON "mod_pulse"."pulses" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_tasks_code" BEFORE INSERT ON "mod_pulse"."tasks" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "tasks_insert_audit" BEFORE INSERT ON "mod_pulse"."tasks" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_tasks_audit"();



CREATE OR REPLACE TRIGGER "tasks_insert_trigger" AFTER INSERT ON "mod_pulse"."tasks" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_new_task_notifications"();



CREATE OR REPLACE TRIGGER "tasks_update_audit" BEFORE UPDATE ON "mod_pulse"."tasks" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_tasks_audit"();



CREATE OR REPLACE TRIGGER "tasks_update_trigger" AFTER UPDATE ON "mod_pulse"."tasks" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_task_assignment_updates"();



CREATE OR REPLACE TRIGGER "trigger_fcm_notifications" AFTER INSERT ON "mod_pulse"."notifications" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://hffdufdierbghwcnjswt.supabase.co/functions/v1/push', 'POST', '{"Content-type":"application/json"}', '{}', '1000');



CREATE OR REPLACE TRIGGER "batches_insert_audit" BEFORE INSERT ON "mod_wms"."batches" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_batches_audit"();



CREATE OR REPLACE TRIGGER "batches_update_audit" BEFORE UPDATE ON "mod_wms"."batches" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_batches_audit"();



CREATE OR REPLACE TRIGGER "before_batches_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_wms"."batches" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_inventory_limits_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_wms"."inventory_limits" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_locations_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_wms"."locations" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_receipt_items_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_wms"."receipt_items" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_receipts_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_wms"."receipts" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_shipment_items_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_wms"."shipment_items" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_shipments_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_wms"."shipments" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_stock_movements_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_wms"."stock_movements" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "before_warehouses_changes" BEFORE DELETE OR UPDATE OF "avatar_url" ON "mod_wms"."warehouses" FOR EACH ROW EXECUTE FUNCTION "mod_admin"."delete_old_avatar"();



CREATE OR REPLACE TRIGGER "create_pulse_for_receipts" BEFORE INSERT ON "mod_wms"."receipts" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."create_pulse_for_record"();



CREATE OR REPLACE TRIGGER "create_pulse_for_shipments" BEFORE INSERT ON "mod_wms"."shipments" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."create_pulse_for_record"();



CREATE OR REPLACE TRIGGER "handle_receipts_deletion" AFTER DELETE ON "mod_wms"."receipts" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_record_deletion"();



CREATE OR REPLACE TRIGGER "handle_shipments_deletion" AFTER DELETE ON "mod_wms"."shipments" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."handle_record_deletion"();



CREATE OR REPLACE TRIGGER "inventory_insert_audit" BEFORE INSERT ON "mod_wms"."inventory" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_inventory_audit"();



CREATE OR REPLACE TRIGGER "inventory_insert_audit" BEFORE INSERT ON "mod_wms"."inventory_backup" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_inventory_audit"();



CREATE OR REPLACE TRIGGER "inventory_limits_insert_audit" BEFORE INSERT ON "mod_wms"."inventory_limits" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_inventory_limits_audit"();



CREATE OR REPLACE TRIGGER "inventory_limits_update_audit" BEFORE UPDATE ON "mod_wms"."inventory_limits" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_inventory_limits_audit"();



CREATE OR REPLACE TRIGGER "inventory_update_audit" BEFORE UPDATE ON "mod_wms"."inventory" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_inventory_audit"();



CREATE OR REPLACE TRIGGER "inventory_update_audit" BEFORE UPDATE ON "mod_wms"."inventory_backup" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_inventory_audit"();



CREATE OR REPLACE TRIGGER "locations_insert_audit" BEFORE INSERT ON "mod_wms"."locations" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_locations_audit"();



CREATE OR REPLACE TRIGGER "locations_update_audit" BEFORE UPDATE ON "mod_wms"."locations" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_locations_audit"();



CREATE OR REPLACE TRIGGER "receipt_items_insert_audit" BEFORE INSERT ON "mod_wms"."receipt_items" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_receipt_items_audit"();



CREATE OR REPLACE TRIGGER "receipt_items_notification_for_serena_trigger" AFTER INSERT ON "mod_wms"."receipt_items" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."receipt_items_notification_for_serena"();



COMMENT ON TRIGGER "receipt_items_notification_for_serena_trigger" ON "mod_wms"."receipt_items" IS 'Sends notifications to Serena (UUID: 0d26df09-2cf1-4b69-89ca-668db5201153) when receipt items have quantity discrepancies or damaged items.';



CREATE OR REPLACE TRIGGER "receipt_items_update_audit" BEFORE UPDATE ON "mod_wms"."receipt_items" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_receipt_items_audit"();



CREATE OR REPLACE TRIGGER "receipts_insert_audit" BEFORE INSERT ON "mod_wms"."receipts" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_receipts_audit"();



CREATE OR REPLACE TRIGGER "receipts_update_audit" BEFORE UPDATE ON "mod_wms"."receipts" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_receipts_audit"();



CREATE OR REPLACE TRIGGER "set_batches_code" BEFORE INSERT ON "mod_wms"."batches" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_inventory_limits_code" BEFORE INSERT ON "mod_wms"."inventory_limits" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_receipt_items_code" BEFORE INSERT ON "mod_wms"."receipt_items" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_receipts_code" BEFORE INSERT ON "mod_wms"."receipts" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_shipment_items_code" BEFORE INSERT ON "mod_wms"."shipment_items" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_shipments_code" BEFORE INSERT ON "mod_wms"."shipments" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_warehouses_code" BEFORE INSERT ON "mod_wms"."warehouses" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "set_wms_locations_code" BEFORE INSERT ON "mod_wms"."locations" FOR EACH ROW EXECUTE FUNCTION "mod_datalayer"."generate_table_code"();



CREATE OR REPLACE TRIGGER "shipment_items_insert_audit" BEFORE INSERT ON "mod_wms"."shipment_items" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_shipment_items_audit"();



CREATE OR REPLACE TRIGGER "shipment_items_update_audit" BEFORE UPDATE ON "mod_wms"."shipment_items" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_shipment_items_audit"();



CREATE OR REPLACE TRIGGER "shipments_insert_audit" BEFORE INSERT ON "mod_wms"."shipments" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_shipments_audit"();



CREATE OR REPLACE TRIGGER "shipments_update_audit" BEFORE UPDATE ON "mod_wms"."shipments" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_shipments_audit"();



CREATE OR REPLACE TRIGGER "stock_movements_insert_audit" BEFORE INSERT ON "mod_wms"."stock_movements" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_stock_movements_audit"();



CREATE OR REPLACE TRIGGER "stock_movements_update_audit" BEFORE UPDATE ON "mod_wms"."stock_movements" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_stock_movements_audit"();



CREATE OR REPLACE TRIGGER "trg_set_receipt_number_on_insert" BEFORE INSERT ON "mod_wms"."receipts" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."set_receipt_number_on_insert"();



CREATE OR REPLACE TRIGGER "trigger_create_quality_control_for_shipment" AFTER INSERT ON "mod_wms"."shipments" FOR EACH ROW EXECUTE FUNCTION "mod_base"."create_quality_control_for_shipment"();



COMMENT ON TRIGGER "trigger_create_quality_control_for_shipment" ON "mod_wms"."shipments" IS 'Trigger that automatically creates quality control records for shipping verification when a new shipment is inserted.';



CREATE OR REPLACE TRIGGER "trigger_handle_inbound_stock_movement" AFTER INSERT ON "mod_wms"."stock_movements" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_inbound_stock_movement"();



COMMENT ON TRIGGER "trigger_handle_inbound_stock_movement" ON "mod_wms"."stock_movements" IS 'Trigger that calls handle_inbound_stock_movement() function after inserting stock movement records. Marks receipt items as moved and creates inventory records for inbound movements.';



CREATE OR REPLACE TRIGGER "trigger_handle_loading_stock_movement" AFTER INSERT ON "mod_wms"."stock_movements" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_loading_stock_movement"();



COMMENT ON TRIGGER "trigger_handle_loading_stock_movement" ON "mod_wms"."stock_movements" IS 'Trigger that calls handle_loading_stock_movement() function after inserting stock movement records. Updates inventory for loading movements with source-to-destination transfer logic and flexible batch handling.';



CREATE OR REPLACE TRIGGER "trigger_handle_original_receipt_item_id" BEFORE INSERT ON "mod_wms"."stock_movements" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_original_receipt_item_id"();



COMMENT ON TRIGGER "trigger_handle_original_receipt_item_id" ON "mod_wms"."stock_movements" IS 'Trigger that automatically populates original_receipt_item_id before inserting stock movement records. Maintains receipt lineage even after multiple relocations or movements.';



CREATE OR REPLACE TRIGGER "trigger_handle_outbound_unloading_stock_movement" AFTER INSERT ON "mod_wms"."stock_movements" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_outbound_unloading_stock_movement"();



COMMENT ON TRIGGER "trigger_handle_outbound_unloading_stock_movement" ON "mod_wms"."stock_movements" IS 'Trigger that calls handle_outbound_unloading_stock_movement() function after inserting stock movement records. For outbound movements: deducts inventory quantities from source. For unloading movements: transfers inventory from source to destination location. Missing or insufficient inventory logs warnings but does not prevent stock movement creation.';



CREATE OR REPLACE TRIGGER "trigger_handle_relocation_stock_movement" AFTER INSERT ON "mod_wms"."stock_movements" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_relocation_stock_movement"();



COMMENT ON TRIGGER "trigger_handle_relocation_stock_movement" ON "mod_wms"."stock_movements" IS 'Trigger that calls handle_relocation_stock_movement() function after inserting stock movement records. Manages inventory relocation between locations.';



CREATE OR REPLACE TRIGGER "trigger_handle_transport_stock_movement" AFTER INSERT ON "mod_wms"."stock_movements" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_transport_stock_movement"();



COMMENT ON TRIGGER "trigger_handle_transport_stock_movement" ON "mod_wms"."stock_movements" IS 'Trigger that calls handle_transport_stock_movement() function after inserting stock movement records. Updates inventory for transport movements with source-to-destination transfer logic and flexible batch handling.';



CREATE OR REPLACE TRIGGER "trigger_receipt_items_inbound_on_insert" AFTER INSERT ON "mod_wms"."receipt_items" FOR EACH ROW WHEN ((("new"."is_moved" = true) AND ("new"."moved_date" IS NULL))) EXECUTE FUNCTION "mod_wms"."handle_receipt_items_inbound_on_insert"();



COMMENT ON TRIGGER "trigger_receipt_items_inbound_on_insert" ON "mod_wms"."receipt_items" IS 'Logs inbound stock movement for newly inserted receipt_items that are marked moved but have no moved_date yet.';



CREATE OR REPLACE TRIGGER "trigger_shipment_item_addresses_updated_at" BEFORE UPDATE ON "mod_wms"."shipment_item_addresses" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."update_shipment_item_addresses_updated_at"();



CREATE OR REPLACE TRIGGER "trigger_shipments_outbound_on_status_change" AFTER UPDATE OF "status" ON "mod_wms"."shipments" FOR EACH ROW WHEN ((("new"."status" = 'loaded'::"text") AND ("old"."status" IS DISTINCT FROM 'loaded'::"text"))) EXECUTE FUNCTION "mod_wms"."handle_shipments_outbound_on_status_change"();



COMMENT ON TRIGGER "trigger_shipments_outbound_on_status_change" ON "mod_wms"."shipments" IS 'Logs outbound stock movements for all shipment items when shipment status changes to loaded. Skips items without location_id (non-manufactured items). Errors are logged but do not prevent the shipment status update from completing.';



CREATE OR REPLACE TRIGGER "trigger_update_receipt_supplier" BEFORE INSERT OR UPDATE ON "mod_wms"."receipts" FOR EACH ROW EXECUTE FUNCTION "public"."update_receipt_supplier_from_po"();



CREATE OR REPLACE TRIGGER "trigger_update_sales_order_items_has_shipment" AFTER INSERT ON "mod_wms"."shipments" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."update_sales_order_items_has_shipment"();



COMMENT ON TRIGGER "trigger_update_sales_order_items_has_shipment" ON "mod_wms"."shipments" IS 'Trigger that updates has_shipment flag on sales_order_items when a new shipment is created. Errors are logged but do not prevent shipment creation.';



CREATE OR REPLACE TRIGGER "trigger_update_sales_order_items_has_shipment_on_item_insert" AFTER INSERT ON "mod_wms"."shipment_items" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."update_sales_order_items_has_shipment"();



COMMENT ON TRIGGER "trigger_update_sales_order_items_has_shipment_on_item_insert" ON "mod_wms"."shipment_items" IS 'Trigger that updates has_shipment flag on sales_order_items when shipment_items are added. This ensures has_shipment is updated even if items are added after shipment creation. Errors are logged but do not prevent shipment_item creation.';



CREATE OR REPLACE TRIGGER "trigger_update_sales_order_items_is_shipped_on_loaded" AFTER UPDATE OF "status" ON "mod_wms"."shipments" FOR EACH ROW WHEN ((("new"."status" = 'loaded'::"text") AND ("old"."status" IS DISTINCT FROM 'loaded'::"text"))) EXECUTE FUNCTION "mod_wms"."handle_update_sales_order_items_is_shipped_on_loaded"();



COMMENT ON TRIGGER "trigger_update_sales_order_items_is_shipped_on_loaded" ON "mod_wms"."shipments" IS 'Updates is_shipped flag on sales_order_items when shipment status changes to loaded. Errors are logged but do not prevent the shipment status update from completing.';



CREATE OR REPLACE TRIGGER "trigger_update_shipment_sales_orders_updated_at" BEFORE UPDATE ON "mod_wms"."shipment_sales_orders" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."update_shipment_sales_orders_updated_at"();



CREATE OR REPLACE TRIGGER "update_pulse_status_for_receipts" AFTER UPDATE OF "status" ON "mod_wms"."receipts" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."update_pulse_status"();



CREATE OR REPLACE TRIGGER "update_pulse_status_for_shipments" AFTER UPDATE OF "status" ON "mod_wms"."shipments" FOR EACH ROW EXECUTE FUNCTION "mod_pulse"."update_pulse_status"();



CREATE OR REPLACE TRIGGER "update_shipment_attachments_updated_at" BEFORE UPDATE ON "mod_wms"."shipment_attachments" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."update_shipment_attachments_updated_at"();



CREATE OR REPLACE TRIGGER "warehouses_insert_audit" BEFORE INSERT ON "mod_wms"."warehouses" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_warehouses_audit"();



CREATE OR REPLACE TRIGGER "warehouses_update_audit" BEFORE UPDATE ON "mod_wms"."warehouses" FOR EACH ROW EXECUTE FUNCTION "mod_wms"."handle_warehouses_audit"();



ALTER TABLE ONLY "mod_admin"."domain_modules"
    ADD CONSTRAINT "domain_modules_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_admin"."domain_modules"
    ADD CONSTRAINT "domain_modules_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_admin"."domain_modules"
    ADD CONSTRAINT "domain_modules_module_id_fkey" FOREIGN KEY ("module_id") REFERENCES "mod_datalayer"."modules"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_admin"."domain_modules"
    ADD CONSTRAINT "domain_modules_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_admin"."domain_users"
    ADD CONSTRAINT "domain_users_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_admin"."domain_users"
    ADD CONSTRAINT "domain_users_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_admin"."domain_users"
    ADD CONSTRAINT "domain_users_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_admin"."domain_users"
    ADD CONSTRAINT "domain_users_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_admin"."domains"
    ADD CONSTRAINT "domains_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_admin"."domains"
    ADD CONSTRAINT "domains_parent_domain_id_fkey" FOREIGN KEY ("parent_domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_admin"."domains"
    ADD CONSTRAINT "domains_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_admin"."user_profiles"
    ADD CONSTRAINT "user_profiles_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_admin"."user_profiles"
    ADD CONSTRAINT "user_profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_admin"."user_profiles"
    ADD CONSTRAINT "user_profiles_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."announcements"
    ADD CONSTRAINT "announcements_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."announcements"
    ADD CONSTRAINT "announcements_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."announcements"
    ADD CONSTRAINT "announcements_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."article_categories"
    ADD CONSTRAINT "article_categories_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."article_categories"
    ADD CONSTRAINT "article_categories_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."article_categories"
    ADD CONSTRAINT "article_categories_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."articles"
    ADD CONSTRAINT "articles_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "mod_base"."article_categories"("id");



ALTER TABLE ONLY "mod_base"."articles"
    ADD CONSTRAINT "articles_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."articles"
    ADD CONSTRAINT "articles_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."articles"
    ADD CONSTRAINT "articles_parent_article_id_fkey" FOREIGN KEY ("parent_article_id") REFERENCES "mod_base"."articles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."articles"
    ADD CONSTRAINT "articles_unit_of_measure_id_fkey" FOREIGN KEY ("unit_of_measure_id") REFERENCES "mod_base"."units_of_measure"("id");



ALTER TABLE ONLY "mod_base"."articles"
    ADD CONSTRAINT "articles_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."custom_article_attachments"
    ADD CONSTRAINT "custom_article_attachments_article_id_fkey" FOREIGN KEY ("article_id") REFERENCES "mod_base"."articles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."custom_article_attachments"
    ADD CONSTRAINT "custom_article_attachments_internal_sales_order_id_fkey" FOREIGN KEY ("internal_sales_order_id") REFERENCES "mod_base"."internal_sales_orders"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."custom_article_attachments"
    ADD CONSTRAINT "custom_article_attachments_sales_order_id_fkey" FOREIGN KEY ("sales_order_id") REFERENCES "mod_base"."sales_orders"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."customer_addresses"
    ADD CONSTRAINT "customer_addresses_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."customer_addresses"
    ADD CONSTRAINT "customer_addresses_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "mod_base"."customers"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."customer_addresses"
    ADD CONSTRAINT "customer_addresses_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."customer_addresses"
    ADD CONSTRAINT "customer_addresses_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."customers"
    ADD CONSTRAINT "customers_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."customers"
    ADD CONSTRAINT "customers_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."customers"
    ADD CONSTRAINT "customers_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."departments"
    ADD CONSTRAINT "departments_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."departments"
    ADD CONSTRAINT "departments_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."departments"
    ADD CONSTRAINT "departments_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."employees"
    ADD CONSTRAINT "employees_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."employees_departments"
    ADD CONSTRAINT "employees_departments_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."employees_departments"
    ADD CONSTRAINT "employees_departments_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "mod_base"."departments"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."employees_departments"
    ADD CONSTRAINT "employees_departments_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."employees_departments"
    ADD CONSTRAINT "employees_departments_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "mod_base"."employees"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."employees_departments"
    ADD CONSTRAINT "employees_departments_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."employees"
    ADD CONSTRAINT "employees_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."employees"
    ADD CONSTRAINT "employees_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."employees"
    ADD CONSTRAINT "employees_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."bom_articles"
    ADD CONSTRAINT "fk_bom_articles_component_article" FOREIGN KEY ("component_article_id") REFERENCES "mod_base"."articles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."bom_articles"
    ADD CONSTRAINT "fk_bom_articles_parent_article" FOREIGN KEY ("parent_article_id") REFERENCES "mod_base"."articles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."quality_control_checklist_results"
    ADD CONSTRAINT "fk_quality_control_checklist_results_quality_control" FOREIGN KEY ("quality_control_id") REFERENCES "mod_base"."quality_control"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."quality_control"
    ADD CONSTRAINT "fk_quality_control_purchase_order_item" FOREIGN KEY ("purchase_order_item_id") REFERENCES "mod_base"."purchase_order_items"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."internal_sales_order_items"
    ADD CONSTRAINT "internal_sales_order_items_article_id_fkey" FOREIGN KEY ("article_id") REFERENCES "mod_base"."articles"("id");



ALTER TABLE ONLY "mod_base"."internal_sales_order_items"
    ADD CONSTRAINT "internal_sales_order_items_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."internal_sales_order_items"
    ADD CONSTRAINT "internal_sales_order_items_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."internal_sales_order_items"
    ADD CONSTRAINT "internal_sales_order_items_internal_sales_order_id_fkey" FOREIGN KEY ("sales_order_id") REFERENCES "mod_base"."internal_sales_orders"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."internal_sales_order_items"
    ADD CONSTRAINT "internal_sales_order_items_parent_sales_order_item_id_fkey" FOREIGN KEY ("parent_sales_order_item_id") REFERENCES "mod_base"."internal_sales_order_items"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."internal_sales_order_items"
    ADD CONSTRAINT "internal_sales_order_items_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."internal_sales_orders"
    ADD CONSTRAINT "internal_sales_orders_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."internal_sales_orders"
    ADD CONSTRAINT "internal_sales_orders_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "mod_base"."customers"("id");



ALTER TABLE ONLY "mod_base"."internal_sales_orders"
    ADD CONSTRAINT "internal_sales_orders_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."internal_sales_orders"
    ADD CONSTRAINT "internal_sales_orders_id_fkey" FOREIGN KEY ("id") REFERENCES "mod_pulse"."pulses"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."internal_sales_orders"
    ADD CONSTRAINT "internal_sales_orders_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."profiles"
    ADD CONSTRAINT "profiles_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."profiles"
    ADD CONSTRAINT "profiles_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."purchase_order_items"
    ADD CONSTRAINT "purchase_order_items_article_id_fkey" FOREIGN KEY ("article_id") REFERENCES "mod_base"."articles"("id");



ALTER TABLE ONLY "mod_base"."purchase_order_items"
    ADD CONSTRAINT "purchase_order_items_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."purchase_order_items"
    ADD CONSTRAINT "purchase_order_items_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."purchase_order_items"
    ADD CONSTRAINT "purchase_order_items_purchase_order_id_fkey" FOREIGN KEY ("purchase_order_id") REFERENCES "mod_base"."purchase_orders"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."purchase_order_items"
    ADD CONSTRAINT "purchase_order_items_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."purchase_orders"
    ADD CONSTRAINT "purchase_orders_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."purchase_orders"
    ADD CONSTRAINT "purchase_orders_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."purchase_orders"
    ADD CONSTRAINT "purchase_orders_id_fkey" FOREIGN KEY ("id") REFERENCES "mod_pulse"."pulses"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."purchase_orders"
    ADD CONSTRAINT "purchase_orders_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "mod_base"."suppliers"("id");



ALTER TABLE ONLY "mod_base"."purchase_orders"
    ADD CONSTRAINT "purchase_orders_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."quality_control"
    ADD CONSTRAINT "quality_control_article_id_fkey" FOREIGN KEY ("article_id") REFERENCES "mod_base"."articles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."quality_control_attachments"
    ADD CONSTRAINT "quality_control_attachments_quality_control_id_fkey" FOREIGN KEY ("quality_control_id") REFERENCES "mod_base"."quality_control"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."quality_control"
    ADD CONSTRAINT "quality_control_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."quality_control"
    ADD CONSTRAINT "quality_control_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."quality_control"
    ADD CONSTRAINT "quality_control_inspector_id_fkey" FOREIGN KEY ("inspector_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."quality_control"
    ADD CONSTRAINT "quality_control_quality_control_type_id_fkey" FOREIGN KEY ("quality_control_type_id") REFERENCES "mod_base"."quality_control_types"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."quality_control"
    ADD CONSTRAINT "quality_control_receipt_id_fkey" FOREIGN KEY ("receipt_id") REFERENCES "mod_wms"."receipts"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."quality_control"
    ADD CONSTRAINT "quality_control_receipt_item_id_fkey" FOREIGN KEY ("receipt_item_id") REFERENCES "mod_wms"."receipt_items"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."quality_control"
    ADD CONSTRAINT "quality_control_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."quality_control"
    ADD CONSTRAINT "quality_control_shipment_id_fkey" FOREIGN KEY ("shipment_id") REFERENCES "mod_wms"."shipments"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."quality_control_types"
    ADD CONSTRAINT "quality_control_types_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "mod_base"."article_categories"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."quality_control_types"
    ADD CONSTRAINT "quality_control_types_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."quality_control_types"
    ADD CONSTRAINT "quality_control_types_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."quality_control_types_duplicate"
    ADD CONSTRAINT "quality_control_types_duplicate_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "mod_base"."article_categories"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."quality_control_types_duplicate"
    ADD CONSTRAINT "quality_control_types_duplicate_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."quality_control_types_duplicate"
    ADD CONSTRAINT "quality_control_types_duplicate_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."quality_control_types_duplicate"
    ADD CONSTRAINT "quality_control_types_duplicate_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."quality_control_types_duplicate"
    ADD CONSTRAINT "quality_control_types_duplicate_work_cycle_id_fkey" FOREIGN KEY ("work_cycle_id") REFERENCES "mod_manufacturing"."work_cycles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."quality_control_types"
    ADD CONSTRAINT "quality_control_types_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."quality_control_types"
    ADD CONSTRAINT "quality_control_types_work_cycle_id_fkey" FOREIGN KEY ("work_cycle_id") REFERENCES "mod_manufacturing"."work_cycles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."quality_control"
    ADD CONSTRAINT "quality_control_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."quality_control"
    ADD CONSTRAINT "quality_control_work_order_id_fkey" FOREIGN KEY ("work_order_id") REFERENCES "mod_manufacturing"."work_orders"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."quality_control"
    ADD CONSTRAINT "quality_control_work_steps_id_fkey" FOREIGN KEY ("work_steps_id") REFERENCES "mod_manufacturing"."work_steps"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."report_template"
    ADD CONSTRAINT "report_template_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."report_template"
    ADD CONSTRAINT "report_template_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."sales_order_items"
    ADD CONSTRAINT "sales_order_items_article_id_fkey" FOREIGN KEY ("article_id") REFERENCES "mod_base"."articles"("id");



ALTER TABLE ONLY "mod_base"."sales_order_items"
    ADD CONSTRAINT "sales_order_items_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."sales_order_items"
    ADD CONSTRAINT "sales_order_items_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."sales_order_items"
    ADD CONSTRAINT "sales_order_items_parent_sales_order_item_id_fkey" FOREIGN KEY ("parent_sales_order_item_id") REFERENCES "mod_base"."sales_order_items"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."sales_order_items"
    ADD CONSTRAINT "sales_order_items_sales_order_id_fkey" FOREIGN KEY ("sales_order_id") REFERENCES "mod_base"."sales_orders"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."sales_order_items"
    ADD CONSTRAINT "sales_order_items_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."sales_orders"
    ADD CONSTRAINT "sales_orders_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."sales_orders"
    ADD CONSTRAINT "sales_orders_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "mod_base"."customers"("id");



ALTER TABLE ONLY "mod_base"."sales_orders"
    ADD CONSTRAINT "sales_orders_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."sales_orders"
    ADD CONSTRAINT "sales_orders_id_fkey" FOREIGN KEY ("id") REFERENCES "mod_pulse"."pulses"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."sales_orders"
    ADD CONSTRAINT "sales_orders_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."serial_number_counters"
    ADD CONSTRAINT "serial_number_counters_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "mod_base"."article_categories"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_base"."serial_number_counters"
    ADD CONSTRAINT "serial_number_counters_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."serial_number_counters"
    ADD CONSTRAINT "serial_number_counters_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."suppliers"
    ADD CONSTRAINT "suppliers_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."suppliers"
    ADD CONSTRAINT "suppliers_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."suppliers"
    ADD CONSTRAINT "suppliers_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."units_of_measure"
    ADD CONSTRAINT "units_of_measure_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_base"."units_of_measure"
    ADD CONSTRAINT "units_of_measure_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_base"."units_of_measure"
    ADD CONSTRAINT "units_of_measure_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."fields"
    ADD CONSTRAINT "fields_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."fields"
    ADD CONSTRAINT "fields_schema_name_fkey" FOREIGN KEY ("schema_name") REFERENCES "mod_datalayer"."modules"("schema_name") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_datalayer"."fields"
    ADD CONSTRAINT "fields_schema_name_table_name_fkey" FOREIGN KEY ("schema_name", "table_name") REFERENCES "mod_datalayer"."tables"("schema_name", "table_name") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_datalayer"."fields"
    ADD CONSTRAINT "fields_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."fields"
    ADD CONSTRAINT "fk_references" FOREIGN KEY ("references_schema", "references_table") REFERENCES "mod_datalayer"."tables"("schema_name", "table_name") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_datalayer"."main_menu"
    ADD CONSTRAINT "main_menu_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."main_menu"
    ADD CONSTRAINT "main_menu_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."modules"
    ADD CONSTRAINT "modules_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."modules"
    ADD CONSTRAINT "modules_owner_domain_id_fkey" FOREIGN KEY ("owner_domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_datalayer"."modules"
    ADD CONSTRAINT "modules_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."page_categories"
    ADD CONSTRAINT "page_categories_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."page_categories"
    ADD CONSTRAINT "page_categories_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."pages"
    ADD CONSTRAINT "pages_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."pages_departments"
    ADD CONSTRAINT "pages_departments_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."pages_departments"
    ADD CONSTRAINT "pages_departments_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "mod_base"."departments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_datalayer"."pages_departments"
    ADD CONSTRAINT "pages_departments_page_id_fkey" FOREIGN KEY ("page_id") REFERENCES "mod_datalayer"."pages"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_datalayer"."pages_departments"
    ADD CONSTRAINT "pages_departments_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."pages_departments"
    ADD CONSTRAINT "pages_departments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."pages"
    ADD CONSTRAINT "pages_main_menu_id_fkey" FOREIGN KEY ("main_menu_id") REFERENCES "mod_datalayer"."main_menu"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_datalayer"."pages_menu_departments"
    ADD CONSTRAINT "pages_menu_departments_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."pages_menu_departments"
    ADD CONSTRAINT "pages_menu_departments_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "mod_base"."departments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_datalayer"."pages_menu_departments"
    ADD CONSTRAINT "pages_menu_departments_page_id_fkey" FOREIGN KEY ("page_id") REFERENCES "mod_datalayer"."pages"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_datalayer"."pages_menu_departments"
    ADD CONSTRAINT "pages_menu_departments_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."pages_menu_departments"
    ADD CONSTRAINT "pages_menu_departments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."pages"
    ADD CONSTRAINT "pages_module_id_fkey" FOREIGN KEY ("module_id") REFERENCES "mod_datalayer"."modules"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_datalayer"."pages"
    ADD CONSTRAINT "pages_page_category_id_fkey" FOREIGN KEY ("page_category_id") REFERENCES "mod_datalayer"."page_categories"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_datalayer"."pages"
    ADD CONSTRAINT "pages_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."tables"
    ADD CONSTRAINT "tables_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_datalayer"."tables"
    ADD CONSTRAINT "tables_schema_name_fkey" FOREIGN KEY ("schema_name") REFERENCES "mod_datalayer"."modules"("schema_name") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_datalayer"."tables"
    ADD CONSTRAINT "tables_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."coil_consumption"
    ADD CONSTRAINT "coil_consumption_coil_id_fkey" FOREIGN KEY ("coil_id") REFERENCES "mod_manufacturing"."coils"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."coil_consumption"
    ADD CONSTRAINT "coil_consumption_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."coil_consumption"
    ADD CONSTRAINT "coil_consumption_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."coil_consumption"
    ADD CONSTRAINT "coil_consumption_operator_id_fkey" FOREIGN KEY ("operator_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."coil_consumption"
    ADD CONSTRAINT "coil_consumption_production_plan_id_fkey" FOREIGN KEY ("production_plan_id") REFERENCES "mod_manufacturing"."coil_production_plans"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."coil_consumption"
    ADD CONSTRAINT "coil_consumption_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."coil_consumption"
    ADD CONSTRAINT "coil_consumption_work_order_id_fkey" FOREIGN KEY ("work_order_id") REFERENCES "mod_manufacturing"."work_orders"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."coil_production_plans"
    ADD CONSTRAINT "coil_production_plans_coil_id_fkey" FOREIGN KEY ("coil_id") REFERENCES "mod_manufacturing"."coils"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."coil_production_plans"
    ADD CONSTRAINT "coil_production_plans_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."coil_production_plans"
    ADD CONSTRAINT "coil_production_plans_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."coil_production_plans"
    ADD CONSTRAINT "coil_production_plans_plate_template_id_fkey" FOREIGN KEY ("plate_template_id") REFERENCES "mod_manufacturing"."plate_templates"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."coil_production_plans"
    ADD CONSTRAINT "coil_production_plans_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."coil_production_plans"
    ADD CONSTRAINT "coil_production_plans_work_order_id_fkey" FOREIGN KEY ("work_order_id") REFERENCES "mod_manufacturing"."work_orders"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."coils"
    ADD CONSTRAINT "coils_batch_id_fkey" FOREIGN KEY ("batch_id") REFERENCES "mod_wms"."batches"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."coils"
    ADD CONSTRAINT "coils_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."coils"
    ADD CONSTRAINT "coils_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."coils"
    ADD CONSTRAINT "coils_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "mod_wms"."locations"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."coils"
    ADD CONSTRAINT "coils_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "mod_base"."suppliers"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."coils"
    ADD CONSTRAINT "coils_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."departments"
    ADD CONSTRAINT "departments_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."departments"
    ADD CONSTRAINT "departments_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."departments"
    ADD CONSTRAINT "departments_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."locations"
    ADD CONSTRAINT "locations_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."locations"
    ADD CONSTRAINT "locations_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "mod_manufacturing"."departments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."locations"
    ADD CONSTRAINT "locations_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."locations"
    ADD CONSTRAINT "locations_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."plate_templates"
    ADD CONSTRAINT "plate_templates_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."plate_templates"
    ADD CONSTRAINT "plate_templates_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."plate_templates"
    ADD CONSTRAINT "plate_templates_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."production_logs"
    ADD CONSTRAINT "production_logs_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."production_logs"
    ADD CONSTRAINT "production_logs_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."production_logs"
    ADD CONSTRAINT "production_logs_operator_id_fkey" FOREIGN KEY ("operator_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."production_logs"
    ADD CONSTRAINT "production_logs_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."production_logs"
    ADD CONSTRAINT "production_logs_work_order_id_fkey" FOREIGN KEY ("work_order_id") REFERENCES "mod_manufacturing"."work_orders"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."production_logs"
    ADD CONSTRAINT "production_logs_work_step_id_fkey" FOREIGN KEY ("work_step_id") REFERENCES "mod_manufacturing"."work_steps"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."recipes"
    ADD CONSTRAINT "recipes_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."recipes"
    ADD CONSTRAINT "recipes_destination_article_id_fkey" FOREIGN KEY ("destination_article_id") REFERENCES "mod_base"."articles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."recipes"
    ADD CONSTRAINT "recipes_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."recipes"
    ADD CONSTRAINT "recipes_finished_product_id_fkey" FOREIGN KEY ("finished_product_id") REFERENCES "mod_base"."articles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."recipes"
    ADD CONSTRAINT "recipes_source_article_id_fkey" FOREIGN KEY ("source_article_id") REFERENCES "mod_base"."articles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."recipes"
    ADD CONSTRAINT "recipes_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."scheduled_items"
    ADD CONSTRAINT "scheduled_items_article_id_fkey" FOREIGN KEY ("article_id") REFERENCES "mod_base"."articles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."scheduled_items"
    ADD CONSTRAINT "scheduled_items_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."scheduled_items"
    ADD CONSTRAINT "scheduled_items_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."scheduled_items"
    ADD CONSTRAINT "scheduled_items_sales_order_id_fkey" FOREIGN KEY ("sales_order_id") REFERENCES "mod_base"."sales_orders"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."scheduled_items"
    ADD CONSTRAINT "scheduled_items_sales_order_item_id_fkey" FOREIGN KEY ("sales_order_item_id") REFERENCES "mod_base"."sales_order_items"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."scheduled_items"
    ADD CONSTRAINT "scheduled_items_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_cycle_categories"
    ADD CONSTRAINT "work_cycle_categories_from_article_category_id_fkey" FOREIGN KEY ("from_article_category_id") REFERENCES "mod_base"."article_categories"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_cycle_categories"
    ADD CONSTRAINT "work_cycle_categories_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "mod_wms"."locations"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_cycle_categories"
    ADD CONSTRAINT "work_cycle_categories_to_article_category_id_fkey" FOREIGN KEY ("to_article_category_id") REFERENCES "mod_base"."article_categories"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_cycle_categories"
    ADD CONSTRAINT "work_cycle_categories_work_cycle_id_fkey" FOREIGN KEY ("work_cycle_id") REFERENCES "mod_manufacturing"."work_cycles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."work_cycle_categories"
    ADD CONSTRAINT "work_cycle_categories_work_flow_id_fkey" FOREIGN KEY ("work_flow_id") REFERENCES "mod_manufacturing"."work_flows"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."work_cycles"
    ADD CONSTRAINT "work_cycles_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "mod_base"."departments"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_cycles"
    ADD CONSTRAINT "work_cycles_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_flows_work_cycles"
    ADD CONSTRAINT "work_flows_work_cycles_work_cycle_id_fkey" FOREIGN KEY ("work_cycle_id") REFERENCES "mod_manufacturing"."work_cycles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."work_flows_work_cycles"
    ADD CONSTRAINT "work_flows_work_cycles_work_flow_id_fkey" FOREIGN KEY ("work_flow_id") REFERENCES "mod_manufacturing"."work_flows"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."work_order_attachments"
    ADD CONSTRAINT "work_order_attachments_work_order_id_fkey" FOREIGN KEY ("work_order_id") REFERENCES "mod_manufacturing"."work_orders"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."work_order_quality_summary"
    ADD CONSTRAINT "work_order_quality_summary_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_order_quality_summary"
    ADD CONSTRAINT "work_order_quality_summary_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_order_quality_summary"
    ADD CONSTRAINT "work_order_quality_summary_inspector_id_fkey" FOREIGN KEY ("inspector_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_order_quality_summary"
    ADD CONSTRAINT "work_order_quality_summary_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_order_quality_summary"
    ADD CONSTRAINT "work_order_quality_summary_work_order_id_fkey" FOREIGN KEY ("work_order_id") REFERENCES "mod_manufacturing"."work_orders"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."work_orders"
    ADD CONSTRAINT "work_orders_article_id_fkey" FOREIGN KEY ("article_id") REFERENCES "mod_base"."articles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."work_orders"
    ADD CONSTRAINT "work_orders_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."work_orders"
    ADD CONSTRAINT "work_orders_current_work_cycle_id_fkey" FOREIGN KEY ("work_cycle_id") REFERENCES "mod_manufacturing"."work_cycles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_orders"
    ADD CONSTRAINT "work_orders_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_orders"
    ADD CONSTRAINT "work_orders_internal_sales_order_id_fkey" FOREIGN KEY ("internal_sales_order_id") REFERENCES "mod_base"."internal_sales_orders"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_orders"
    ADD CONSTRAINT "work_orders_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "mod_wms"."locations"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_orders"
    ADD CONSTRAINT "work_orders_responsible_id_fkey" FOREIGN KEY ("responsible_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_orders"
    ADD CONSTRAINT "work_orders_sales_order_id_fkey" FOREIGN KEY ("sales_order_id") REFERENCES "mod_base"."sales_orders"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_orders"
    ADD CONSTRAINT "work_orders_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "mod_pulse"."tasks"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."work_orders"
    ADD CONSTRAINT "work_orders_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."work_orders"
    ADD CONSTRAINT "work_orders_warehouse_id_fkey" FOREIGN KEY ("warehouse_id") REFERENCES "mod_wms"."warehouses"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_steps"
    ADD CONSTRAINT "work_steps_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."work_steps"
    ADD CONSTRAINT "work_steps_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_steps"
    ADD CONSTRAINT "work_steps_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."work_steps"
    ADD CONSTRAINT "work_steps_work_cycle_id_fkey" FOREIGN KEY ("work_cycle_id") REFERENCES "mod_manufacturing"."work_cycles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."work_steps"
    ADD CONSTRAINT "work_steps_work_order_id_fkey" FOREIGN KEY ("work_order_id") REFERENCES "mod_manufacturing"."work_orders"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."work_steps"
    ADD CONSTRAINT "work_steps_workstation_id_fkey" FOREIGN KEY ("workstation_id") REFERENCES "mod_manufacturing"."workstations"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."workstations"
    ADD CONSTRAINT "workstations_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."workstations"
    ADD CONSTRAINT "workstations_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."workstations_duplicate"
    ADD CONSTRAINT "workstations_duplicate_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."workstations_duplicate"
    ADD CONSTRAINT "workstations_duplicate_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_manufacturing"."workstations_duplicate"
    ADD CONSTRAINT "workstations_duplicate_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "mod_manufacturing"."locations"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."workstations_duplicate"
    ADD CONSTRAINT "workstations_duplicate_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_manufacturing"."workstations"
    ADD CONSTRAINT "workstations_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "mod_manufacturing"."locations"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_manufacturing"."workstations"
    ADD CONSTRAINT "workstations_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."department_notification_configs"
    ADD CONSTRAINT "department_notification_configs_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."department_notification_configs"
    ADD CONSTRAINT "department_notification_configs_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "mod_base"."departments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_pulse"."department_notification_configs"
    ADD CONSTRAINT "department_notification_configs_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."department_notification_configs"
    ADD CONSTRAINT "department_notification_configs_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."notifications"
    ADD CONSTRAINT "notifications_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."notifications"
    ADD CONSTRAINT "notifications_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "mod_base"."departments"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."notifications"
    ADD CONSTRAINT "notifications_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."notifications"
    ADD CONSTRAINT "notifications_pulse_id_fkey" FOREIGN KEY ("pulse_id") REFERENCES "mod_pulse"."pulses"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_pulse"."notifications"
    ADD CONSTRAINT "notifications_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."notifications"
    ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_pulse"."pulse_chat"
    ADD CONSTRAINT "pulse_chat_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."pulse_chat"
    ADD CONSTRAINT "pulse_chat_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."pulse_chat_files"
    ADD CONSTRAINT "pulse_chat_files_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."pulse_chat_files"
    ADD CONSTRAINT "pulse_chat_files_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."pulse_chat_files"
    ADD CONSTRAINT "pulse_chat_files_message_id_fkey" FOREIGN KEY ("message_id") REFERENCES "mod_pulse"."pulse_chat"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_pulse"."pulse_chat_files"
    ADD CONSTRAINT "pulse_chat_files_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."pulse_chat"
    ADD CONSTRAINT "pulse_chat_pulse_id_fkey" FOREIGN KEY ("pulse_id") REFERENCES "mod_pulse"."pulses"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_pulse"."pulse_chat"
    ADD CONSTRAINT "pulse_chat_reply_to_id_fkey" FOREIGN KEY ("reply_to_id") REFERENCES "mod_pulse"."pulse_chat"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."pulse_chat"
    ADD CONSTRAINT "pulse_chat_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."pulse_checklists"
    ADD CONSTRAINT "pulse_checklists_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."pulse_checklists"
    ADD CONSTRAINT "pulse_checklists_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."pulse_checklists"
    ADD CONSTRAINT "pulse_checklists_pulse_id_fkey" FOREIGN KEY ("pulse_id") REFERENCES "mod_pulse"."pulses"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_pulse"."pulse_checklists"
    ADD CONSTRAINT "pulse_checklists_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."pulse_comments"
    ADD CONSTRAINT "pulse_comments_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."pulse_comments"
    ADD CONSTRAINT "pulse_comments_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."pulse_comments"
    ADD CONSTRAINT "pulse_comments_pulse_id_fkey" FOREIGN KEY ("pulse_id") REFERENCES "mod_pulse"."pulses"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_pulse"."pulse_comments"
    ADD CONSTRAINT "pulse_comments_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."pulse_conversation_participants"
    ADD CONSTRAINT "pulse_conversation_participants_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."pulse_conversation_participants"
    ADD CONSTRAINT "pulse_conversation_participants_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."pulse_conversation_participants"
    ADD CONSTRAINT "pulse_conversation_participants_last_read_message_id_fkey" FOREIGN KEY ("last_read_message_id") REFERENCES "mod_pulse"."pulse_chat"("id");



ALTER TABLE ONLY "mod_pulse"."pulse_conversation_participants"
    ADD CONSTRAINT "pulse_conversation_participants_pulse_id_fkey" FOREIGN KEY ("pulse_id") REFERENCES "mod_pulse"."pulses"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_pulse"."pulse_conversation_participants"
    ADD CONSTRAINT "pulse_conversation_participants_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."pulse_conversation_participants"
    ADD CONSTRAINT "pulse_conversation_participants_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_pulse"."pulse_progress"
    ADD CONSTRAINT "pulse_progress_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."pulse_progress"
    ADD CONSTRAINT "pulse_progress_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."pulse_progress"
    ADD CONSTRAINT "pulse_progress_new_assigned_to_fkey" FOREIGN KEY ("new_assigned_to") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."pulse_progress"
    ADD CONSTRAINT "pulse_progress_new_sla_id_fkey" FOREIGN KEY ("new_sla_id") REFERENCES "mod_pulse"."pulse_slas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."pulse_progress"
    ADD CONSTRAINT "pulse_progress_pulse_id_fkey" FOREIGN KEY ("pulse_id") REFERENCES "mod_pulse"."pulses"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_pulse"."pulse_progress"
    ADD CONSTRAINT "pulse_progress_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."pulse_slas"
    ADD CONSTRAINT "pulse_slas_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."pulse_slas"
    ADD CONSTRAINT "pulse_slas_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."pulse_slas"
    ADD CONSTRAINT "pulse_slas_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."pulses"
    ADD CONSTRAINT "pulses_assigned_to_fkey" FOREIGN KEY ("assigned_to") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."pulses"
    ADD CONSTRAINT "pulses_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."pulses"
    ADD CONSTRAINT "pulses_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "mod_base"."departments"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."pulses"
    ADD CONSTRAINT "pulses_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."pulses"
    ADD CONSTRAINT "pulses_last_message_sender_id_fkey" FOREIGN KEY ("last_message_sender_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."pulses"
    ADD CONSTRAINT "pulses_sla_id_fkey" FOREIGN KEY ("sla_id") REFERENCES "mod_pulse"."pulse_slas"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."pulses"
    ADD CONSTRAINT "pulses_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."tasks"
    ADD CONSTRAINT "tasks_assigned_department_id_fkey" FOREIGN KEY ("assigned_department_id") REFERENCES "mod_base"."departments"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."tasks"
    ADD CONSTRAINT "tasks_assigned_to_fkey" FOREIGN KEY ("assigned_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."tasks"
    ADD CONSTRAINT "tasks_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_pulse"."tasks"
    ADD CONSTRAINT "tasks_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_pulse"."tasks"
    ADD CONSTRAINT "tasks_pulse_id_fkey" FOREIGN KEY ("pulse_id") REFERENCES "mod_pulse"."pulses"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_pulse"."tasks"
    ADD CONSTRAINT "tasks_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_quality_control"."conformity_documents"
    ADD CONSTRAINT "conformity_documents_article_id_fkey" FOREIGN KEY ("article_id") REFERENCES "mod_base"."articles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_quality_control"."conformity_documents"
    ADD CONSTRAINT "conformity_documents_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_quality_control"."conformity_documents"
    ADD CONSTRAINT "conformity_documents_quality_control_id_fkey" FOREIGN KEY ("quality_control_id") REFERENCES "mod_base"."quality_control"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_quality_control"."conformity_documents"
    ADD CONSTRAINT "conformity_documents_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "mod_base"."suppliers"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_quality_control"."conformity_documents"
    ADD CONSTRAINT "conformity_documents_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_quality_control"."conformity_documents"
    ADD CONSTRAINT "conformity_documents_verified_by_fkey" FOREIGN KEY ("verified_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_quality_control"."defect_types"
    ADD CONSTRAINT "defect_types_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_quality_control"."defect_types"
    ADD CONSTRAINT "defect_types_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_quality_control"."measurement_parameters"
    ADD CONSTRAINT "measurement_parameters_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_quality_control"."measurement_parameters"
    ADD CONSTRAINT "measurement_parameters_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_quality_control"."quality_control_checklist_results"
    ADD CONSTRAINT "quality_control_checklist_results_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_quality_control"."quality_control_checklist_results"
    ADD CONSTRAINT "quality_control_checklist_results_inspector_id_fkey" FOREIGN KEY ("inspector_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_quality_control"."quality_control_checklist_results"
    ADD CONSTRAINT "quality_control_checklist_results_quality_control_id_fkey" FOREIGN KEY ("quality_control_id") REFERENCES "mod_base"."quality_control"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_quality_control"."quality_control_checklist_results"
    ADD CONSTRAINT "quality_control_checklist_results_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_quality_control"."quality_control_defects"
    ADD CONSTRAINT "quality_control_defects_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_quality_control"."quality_control_defects"
    ADD CONSTRAINT "quality_control_defects_defect_type_id_fkey" FOREIGN KEY ("defect_type_id") REFERENCES "mod_quality_control"."defect_types"("id");



ALTER TABLE ONLY "mod_quality_control"."quality_control_defects"
    ADD CONSTRAINT "quality_control_defects_quality_control_id_fkey" FOREIGN KEY ("quality_control_id") REFERENCES "mod_base"."quality_control"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_quality_control"."quality_control_defects"
    ADD CONSTRAINT "quality_control_defects_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_quality_control"."quality_control_measurements"
    ADD CONSTRAINT "quality_control_measurements_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_quality_control"."quality_control_measurements"
    ADD CONSTRAINT "quality_control_measurements_parameter_id_fkey" FOREIGN KEY ("parameter_id") REFERENCES "mod_quality_control"."measurement_parameters"("id");



ALTER TABLE ONLY "mod_quality_control"."quality_control_measurements"
    ADD CONSTRAINT "quality_control_measurements_quality_control_id_fkey" FOREIGN KEY ("quality_control_id") REFERENCES "mod_base"."quality_control"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_quality_control"."quality_control_measurements"
    ADD CONSTRAINT "quality_control_measurements_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_quality_control"."supplier_returns"
    ADD CONSTRAINT "supplier_returns_article_id_fkey" FOREIGN KEY ("article_id") REFERENCES "mod_base"."articles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_quality_control"."supplier_returns"
    ADD CONSTRAINT "supplier_returns_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_quality_control"."supplier_returns"
    ADD CONSTRAINT "supplier_returns_purchase_order_id_fkey" FOREIGN KEY ("purchase_order_id") REFERENCES "mod_base"."purchase_orders"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_quality_control"."supplier_returns"
    ADD CONSTRAINT "supplier_returns_quality_control_id_fkey" FOREIGN KEY ("quality_control_id") REFERENCES "mod_base"."quality_control"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_quality_control"."supplier_returns"
    ADD CONSTRAINT "supplier_returns_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "mod_base"."suppliers"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_quality_control"."supplier_returns"
    ADD CONSTRAINT "supplier_returns_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."batches"
    ADD CONSTRAINT "batches_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."batches"
    ADD CONSTRAINT "batches_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."batches"
    ADD CONSTRAINT "batches_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."box_contents"
    ADD CONSTRAINT "box_contents_box_id_fkey" FOREIGN KEY ("shipment_box_id") REFERENCES "mod_wms"."shipment_boxes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."box_contents"
    ADD CONSTRAINT "box_contents_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."box_contents"
    ADD CONSTRAINT "box_contents_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."box_contents"
    ADD CONSTRAINT "box_contents_item_id_fkey" FOREIGN KEY ("shipment_item_id") REFERENCES "mod_wms"."shipment_items"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."box_contents"
    ADD CONSTRAINT "box_contents_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."box_types"
    ADD CONSTRAINT "box_types_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."box_types"
    ADD CONSTRAINT "box_types_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."box_types"
    ADD CONSTRAINT "box_types_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."carton_contents"
    ADD CONSTRAINT "carton_contents_carton_id_fkey" FOREIGN KEY ("shipment_carton_id") REFERENCES "mod_wms"."shipment_cartons"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."carton_contents"
    ADD CONSTRAINT "carton_contents_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."carton_contents"
    ADD CONSTRAINT "carton_contents_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."carton_contents"
    ADD CONSTRAINT "carton_contents_item_id_fkey" FOREIGN KEY ("shipment_item_id") REFERENCES "mod_wms"."shipment_items"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."carton_contents"
    ADD CONSTRAINT "carton_contents_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."carton_types"
    ADD CONSTRAINT "carton_types_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."carton_types"
    ADD CONSTRAINT "carton_types_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."carton_types"
    ADD CONSTRAINT "carton_types_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."shipment_item_addresses"
    ADD CONSTRAINT "fk_shipment_item_addresses_domain" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."shipment_item_addresses"
    ADD CONSTRAINT "fk_shipment_item_addresses_shipment_item" FOREIGN KEY ("shipment_item_id") REFERENCES "mod_wms"."shipment_items"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."inventory_backup"
    ADD CONSTRAINT "inventory_article_id_fkey" FOREIGN KEY ("article_id") REFERENCES "mod_base"."articles"("id");



ALTER TABLE ONLY "mod_wms"."inventory"
    ADD CONSTRAINT "inventory_article_id_fkey1" FOREIGN KEY ("article_id") REFERENCES "mod_base"."articles"("id");



ALTER TABLE ONLY "mod_wms"."inventory_backup"
    ADD CONSTRAINT "inventory_batch_id_fkey" FOREIGN KEY ("batch_id") REFERENCES "mod_wms"."batches"("id");



ALTER TABLE ONLY "mod_wms"."inventory"
    ADD CONSTRAINT "inventory_batch_id_fkey1" FOREIGN KEY ("batch_id") REFERENCES "mod_wms"."batches"("id");



ALTER TABLE ONLY "mod_wms"."inventory_backup"
    ADD CONSTRAINT "inventory_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."inventory"
    ADD CONSTRAINT "inventory_created_by_fkey1" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."inventory_backup"
    ADD CONSTRAINT "inventory_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."inventory"
    ADD CONSTRAINT "inventory_domain_id_fkey1" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."inventory_limits"
    ADD CONSTRAINT "inventory_limits_article_id_fkey" FOREIGN KEY ("article_id") REFERENCES "mod_base"."articles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."inventory_limits"
    ADD CONSTRAINT "inventory_limits_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."inventory_limits"
    ADD CONSTRAINT "inventory_limits_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."inventory_limits"
    ADD CONSTRAINT "inventory_limits_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "mod_wms"."locations"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."inventory_limits"
    ADD CONSTRAINT "inventory_limits_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."inventory_backup"
    ADD CONSTRAINT "inventory_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "mod_wms"."locations"("id");



ALTER TABLE ONLY "mod_wms"."inventory"
    ADD CONSTRAINT "inventory_location_id_fkey1" FOREIGN KEY ("location_id") REFERENCES "mod_wms"."locations"("id");



ALTER TABLE ONLY "mod_wms"."inventory_backup"
    ADD CONSTRAINT "inventory_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."inventory"
    ADD CONSTRAINT "inventory_updated_by_fkey1" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."locations"
    ADD CONSTRAINT "locations_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."locations"
    ADD CONSTRAINT "locations_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."locations"
    ADD CONSTRAINT "locations_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."locations"
    ADD CONSTRAINT "locations_warehouse_id_fkey" FOREIGN KEY ("warehouse_id") REFERENCES "mod_wms"."warehouses"("id");



ALTER TABLE ONLY "mod_wms"."pallet_contents"
    ADD CONSTRAINT "pallet_contents_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."pallet_contents"
    ADD CONSTRAINT "pallet_contents_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."pallet_contents"
    ADD CONSTRAINT "pallet_contents_item_id_fkey" FOREIGN KEY ("shipment_item_id") REFERENCES "mod_wms"."shipment_items"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."pallet_contents"
    ADD CONSTRAINT "pallet_contents_pallet_id_fkey" FOREIGN KEY ("shipment_pallet_id") REFERENCES "mod_wms"."shipment_pallets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."pallet_contents"
    ADD CONSTRAINT "pallet_contents_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."pallet_types"
    ADD CONSTRAINT "pallet_types_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."pallet_types"
    ADD CONSTRAINT "pallet_types_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."pallet_types"
    ADD CONSTRAINT "pallet_types_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."receipt_items"
    ADD CONSTRAINT "receipt_items_article_id_fkey" FOREIGN KEY ("article_id") REFERENCES "mod_base"."articles"("id");



ALTER TABLE ONLY "mod_wms"."receipt_items"
    ADD CONSTRAINT "receipt_items_batch_id_fkey" FOREIGN KEY ("batch_id") REFERENCES "mod_wms"."batches"("id");



ALTER TABLE ONLY "mod_wms"."receipt_items"
    ADD CONSTRAINT "receipt_items_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."receipt_items"
    ADD CONSTRAINT "receipt_items_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."receipt_items"
    ADD CONSTRAINT "receipt_items_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "mod_wms"."locations"("id");



ALTER TABLE ONLY "mod_wms"."receipt_items"
    ADD CONSTRAINT "receipt_items_qc_inspector_id_fkey" FOREIGN KEY ("qc_inspector_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."receipt_items"
    ADD CONSTRAINT "receipt_items_receipt_id_fkey" FOREIGN KEY ("receipt_id") REFERENCES "mod_wms"."receipts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."receipt_items"
    ADD CONSTRAINT "receipt_items_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."receipts"
    ADD CONSTRAINT "receipts_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."receipts"
    ADD CONSTRAINT "receipts_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."receipts"
    ADD CONSTRAINT "receipts_id_fkey" FOREIGN KEY ("id") REFERENCES "mod_pulse"."pulses"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."receipts"
    ADD CONSTRAINT "receipts_purchase_order_id_fkey" FOREIGN KEY ("purchase_order_id") REFERENCES "mod_base"."purchase_orders"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."receipts"
    ADD CONSTRAINT "receipts_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "mod_base"."suppliers"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."receipts"
    ADD CONSTRAINT "receipts_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."receipts"
    ADD CONSTRAINT "receipts_warehouse_id_fkey" FOREIGN KEY ("warehouse_id") REFERENCES "mod_wms"."warehouses"("id");



ALTER TABLE ONLY "mod_wms"."shipment_attachments"
    ADD CONSTRAINT "shipment_attachments_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."shipment_attachments"
    ADD CONSTRAINT "shipment_attachments_shipment_id_fkey" FOREIGN KEY ("shipment_id") REFERENCES "mod_wms"."shipments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."shipment_boxes"
    ADD CONSTRAINT "shipment_boxes_box_type_id_fkey" FOREIGN KEY ("box_type_id") REFERENCES "mod_wms"."box_types"("id");



ALTER TABLE ONLY "mod_wms"."shipment_boxes"
    ADD CONSTRAINT "shipment_boxes_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."shipment_boxes"
    ADD CONSTRAINT "shipment_boxes_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."shipment_boxes"
    ADD CONSTRAINT "shipment_boxes_pallet_id_fkey" FOREIGN KEY ("shipment_pallet_id") REFERENCES "mod_wms"."shipment_pallets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."shipment_boxes"
    ADD CONSTRAINT "shipment_boxes_shipment_id_fkey" FOREIGN KEY ("shipment_id") REFERENCES "mod_wms"."shipments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."shipment_boxes"
    ADD CONSTRAINT "shipment_boxes_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."shipment_cartons"
    ADD CONSTRAINT "shipment_cartons_carton_type_id_fkey" FOREIGN KEY ("carton_type_id") REFERENCES "mod_wms"."carton_types"("id");



ALTER TABLE ONLY "mod_wms"."shipment_cartons"
    ADD CONSTRAINT "shipment_cartons_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."shipment_cartons"
    ADD CONSTRAINT "shipment_cartons_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."shipment_cartons"
    ADD CONSTRAINT "shipment_cartons_pallet_id_fkey" FOREIGN KEY ("shipment_pallet_id") REFERENCES "mod_wms"."shipment_pallets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."shipment_cartons"
    ADD CONSTRAINT "shipment_cartons_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."shipment_items"
    ADD CONSTRAINT "shipment_items_article_id_fkey" FOREIGN KEY ("article_id") REFERENCES "mod_base"."articles"("id");



ALTER TABLE ONLY "mod_wms"."shipment_items"
    ADD CONSTRAINT "shipment_items_batch_id_fkey" FOREIGN KEY ("batch_id") REFERENCES "mod_wms"."batches"("id");



ALTER TABLE ONLY "mod_wms"."shipment_items"
    ADD CONSTRAINT "shipment_items_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."shipment_items"
    ADD CONSTRAINT "shipment_items_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."shipment_items"
    ADD CONSTRAINT "shipment_items_inventory_id_fkey" FOREIGN KEY ("inventory_id") REFERENCES "mod_wms"."inventory"("id");



ALTER TABLE ONLY "mod_wms"."shipment_items"
    ADD CONSTRAINT "shipment_items_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "mod_wms"."locations"("id");



ALTER TABLE ONLY "mod_wms"."shipment_items"
    ADD CONSTRAINT "shipment_items_shipment_id_fkey" FOREIGN KEY ("shipment_id") REFERENCES "mod_wms"."shipments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."shipment_items"
    ADD CONSTRAINT "shipment_items_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."shipment_pallets"
    ADD CONSTRAINT "shipment_pallets_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."shipment_pallets"
    ADD CONSTRAINT "shipment_pallets_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."shipment_pallets"
    ADD CONSTRAINT "shipment_pallets_pallet_type_id_fkey" FOREIGN KEY ("pallet_type_id") REFERENCES "mod_wms"."pallet_types"("id");



ALTER TABLE ONLY "mod_wms"."shipment_pallets"
    ADD CONSTRAINT "shipment_pallets_shipment_id_fkey" FOREIGN KEY ("shipment_id") REFERENCES "mod_wms"."shipments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."shipment_pallets"
    ADD CONSTRAINT "shipment_pallets_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."shipment_sales_orders"
    ADD CONSTRAINT "shipment_sales_orders_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."shipment_sales_orders"
    ADD CONSTRAINT "shipment_sales_orders_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."shipment_sales_orders"
    ADD CONSTRAINT "shipment_sales_orders_sales_order_id_fkey" FOREIGN KEY ("sales_order_id") REFERENCES "mod_base"."sales_orders"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."shipment_sales_orders"
    ADD CONSTRAINT "shipment_sales_orders_shipment_id_fkey" FOREIGN KEY ("shipment_id") REFERENCES "mod_wms"."shipments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."shipment_sales_orders"
    ADD CONSTRAINT "shipment_sales_orders_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."shipment_standalone_items"
    ADD CONSTRAINT "shipment_standalone_items_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."shipment_standalone_items"
    ADD CONSTRAINT "shipment_standalone_items_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."shipment_standalone_items"
    ADD CONSTRAINT "shipment_standalone_items_item_id_fkey" FOREIGN KEY ("shipment_item_id") REFERENCES "mod_wms"."shipment_items"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."shipment_standalone_items"
    ADD CONSTRAINT "shipment_standalone_items_shipment_id_fkey" FOREIGN KEY ("shipment_id") REFERENCES "mod_wms"."shipments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."shipment_standalone_items"
    ADD CONSTRAINT "shipment_standalone_items_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."shipments"
    ADD CONSTRAINT "shipments_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."shipments"
    ADD CONSTRAINT "shipments_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."shipments"
    ADD CONSTRAINT "shipments_id_fkey" FOREIGN KEY ("id") REFERENCES "mod_pulse"."pulses"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "mod_wms"."shipments"
    ADD CONSTRAINT "shipments_sales_order_id_fkey" FOREIGN KEY ("sales_order_id") REFERENCES "mod_base"."sales_orders"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."shipments"
    ADD CONSTRAINT "shipments_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."shipments"
    ADD CONSTRAINT "shipments_warehouse_id_fkey" FOREIGN KEY ("warehouse_id") REFERENCES "mod_wms"."warehouses"("id");



ALTER TABLE ONLY "mod_wms"."stock_movements"
    ADD CONSTRAINT "stock_movements_article_id_fkey" FOREIGN KEY ("article_id") REFERENCES "mod_base"."articles"("id");



ALTER TABLE ONLY "mod_wms"."stock_movements"
    ADD CONSTRAINT "stock_movements_batch_id_fkey" FOREIGN KEY ("batch_id") REFERENCES "mod_wms"."batches"("id");



ALTER TABLE ONLY "mod_wms"."stock_movements"
    ADD CONSTRAINT "stock_movements_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."stock_movements"
    ADD CONSTRAINT "stock_movements_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."stock_movements"
    ADD CONSTRAINT "stock_movements_from_location_id_fkey" FOREIGN KEY ("from_location_id") REFERENCES "mod_wms"."locations"("id");



ALTER TABLE ONLY "mod_wms"."stock_movements"
    ADD CONSTRAINT "stock_movements_internal_sales_order_id_fkey" FOREIGN KEY ("internal_sales_order_id") REFERENCES "mod_base"."internal_sales_orders"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."stock_movements"
    ADD CONSTRAINT "stock_movements_origin_article_id_fkey" FOREIGN KEY ("origin_article_id") REFERENCES "mod_base"."articles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."stock_movements"
    ADD CONSTRAINT "stock_movements_original_receipt_item_id_fkey" FOREIGN KEY ("original_receipt_item_id") REFERENCES "mod_wms"."receipt_items"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."stock_movements"
    ADD CONSTRAINT "stock_movements_receipt_item_id_fkey" FOREIGN KEY ("receipt_item_id") REFERENCES "mod_wms"."receipt_items"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."stock_movements"
    ADD CONSTRAINT "stock_movements_sales_order_id_fkey" FOREIGN KEY ("sales_order_id") REFERENCES "mod_base"."sales_orders"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."stock_movements"
    ADD CONSTRAINT "stock_movements_to_location_id_fkey" FOREIGN KEY ("to_location_id") REFERENCES "mod_wms"."locations"("id");



ALTER TABLE ONLY "mod_wms"."stock_movements"
    ADD CONSTRAINT "stock_movements_unit_of_measure_id_fkey" FOREIGN KEY ("unit_of_measure_id") REFERENCES "mod_base"."units_of_measure"("id");



ALTER TABLE ONLY "mod_wms"."stock_movements"
    ADD CONSTRAINT "stock_movements_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."stock_movements"
    ADD CONSTRAINT "stock_movements_work_order_id_fkey" FOREIGN KEY ("work_order_id") REFERENCES "mod_manufacturing"."work_orders"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."warehouses"
    ADD CONSTRAINT "warehouses_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "mod_wms"."warehouses"
    ADD CONSTRAINT "warehouses_domain_id_fkey" FOREIGN KEY ("domain_id") REFERENCES "mod_admin"."domains"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "mod_wms"."warehouses"
    ADD CONSTRAINT "warehouses_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



CREATE POLICY "Admins can delete from domain_users" ON "mod_admin"."domain_users" FOR DELETE USING (("public"."get_my_claim_text"('role'::"text") = ANY (ARRAY['admin'::"text", 'superAdmin'::"text"])));



CREATE POLICY "Admins can delete from domains" ON "mod_admin"."domains" FOR DELETE USING (("public"."get_my_claim_text"('role'::"text") = ANY (ARRAY['admin'::"text", 'superAdmin'::"text"])));



CREATE POLICY "Admins can insert into domain_users" ON "mod_admin"."domain_users" FOR INSERT WITH CHECK (("public"."get_my_claim_text"('role'::"text") = ANY (ARRAY['admin'::"text", 'superAdmin'::"text"])));



CREATE POLICY "Admins can insert into domains" ON "mod_admin"."domains" FOR INSERT WITH CHECK (("public"."get_my_claim_text"('role'::"text") = ANY (ARRAY['admin'::"text", 'superAdmin'::"text"])));



CREATE POLICY "Admins can update domain_users" ON "mod_admin"."domain_users" FOR UPDATE USING (("public"."get_my_claim_text"('role'::"text") = ANY (ARRAY['admin'::"text", 'superAdmin'::"text"])));



CREATE POLICY "Admins can update domains" ON "mod_admin"."domains" FOR UPDATE USING (("public"."get_my_claim_text"('role'::"text") = ANY (ARRAY['admin'::"text", 'superAdmin'::"text"])));



CREATE POLICY "Any authenticated user can read" ON "mod_admin"."domain_modules" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Any authenticated user can read domain_users" ON "mod_admin"."domain_users" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Any authenticated user can read domains" ON "mod_admin"."domains" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert user profiles" ON "mod_admin"."user_profiles" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Authenticated users can select user profiles" ON "mod_admin"."user_profiles" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Authenticated users can update user profiles" ON "mod_admin"."user_profiles" FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);



CREATE POLICY "Public 'user_profiles' are viewable by everyone." ON "mod_admin"."user_profiles" FOR SELECT USING (true);



ALTER TABLE "mod_admin"."domain_modules" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_admin"."domain_users" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_admin"."domains" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "superAdmin can delete" ON "mod_admin"."domain_modules" FOR DELETE USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can insert into" ON "mod_admin"."domain_modules" FOR INSERT WITH CHECK (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can update" ON "mod_admin"."domain_modules" FOR UPDATE USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



ALTER TABLE "mod_admin"."user_profiles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_base"."announcements" USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_base"."article_categories" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_base"."customer_addresses" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_base"."customers" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_base"."departments" USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_base"."employees" USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_base"."employees_departments" USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_base"."purchase_order_items" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_base"."purchase_orders" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_base"."report_template" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_base"."suppliers" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_base"."units_of_measure" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_base"."announcements" USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_base"."article_categories" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_base"."customer_addresses" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_base"."customers" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_base"."departments" USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_base"."employees" USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_base"."employees_departments" USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_base"."purchase_order_items" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_base"."purchase_orders" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_base"."report_template" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_base"."suppliers" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_base"."units_of_measure" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Authenticated users can delete all sales_order_items" ON "mod_base"."sales_order_items" FOR DELETE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can delete custom article attachments" ON "mod_base"."custom_article_attachments" FOR DELETE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Authenticated users can delete data" ON "mod_base"."bom_articles" FOR DELETE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can delete data" ON "mod_base"."report_template" FOR DELETE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can delete quality control" ON "mod_base"."quality_control" FOR DELETE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can delete quality control attachments" ON "mod_base"."quality_control_attachments" FOR DELETE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Authenticated users can delete quality control types" ON "mod_base"."quality_control_types" FOR DELETE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert all sales_order_items" ON "mod_base"."sales_order_items" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert custom article attachments" ON "mod_base"."custom_article_attachments" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Authenticated users can insert data" ON "mod_base"."announcements" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_base"."article_categories" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_base"."articles" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_base"."bom_articles" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_base"."departments" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_base"."employees" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_base"."employees_departments" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_base"."purchase_order_items" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_base"."purchase_orders" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_base"."report_template" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_base"."serial_number_counters" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_base"."suppliers" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_base"."units_of_measure" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert quality control" ON "mod_base"."quality_control" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert quality control attachments" ON "mod_base"."quality_control_attachments" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Authenticated users can insert quality control types" ON "mod_base"."quality_control_types" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can select all articles" ON "mod_base"."articles" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can select all quality control" ON "mod_base"."quality_control" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can select all quality control types" ON "mod_base"."quality_control_types" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can select all sales_order_items" ON "mod_base"."sales_order_items" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can select data" ON "mod_base"."bom_articles" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can select data" ON "mod_base"."serial_number_counters" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update all sales_order_items" ON "mod_base"."sales_order_items" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL)) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update custom article attachments" ON "mod_base"."custom_article_attachments" FOR UPDATE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Authenticated users can update data" ON "mod_base"."announcements" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_base"."article_categories" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_base"."articles" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_base"."bom_articles" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_base"."departments" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_base"."employees" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_base"."employees_departments" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_base"."purchase_order_items" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_base"."purchase_orders" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_base"."report_template" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_base"."serial_number_counters" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_base"."suppliers" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_base"."units_of_measure" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update quality control" ON "mod_base"."quality_control" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update quality control attachments" ON "mod_base"."quality_control_attachments" FOR UPDATE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Authenticated users can update quality control types" ON "mod_base"."quality_control_types" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can view custom article attachments" ON "mod_base"."custom_article_attachments" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Authenticated users can view quality control attachments" ON "mod_base"."quality_control_attachments" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_base"."announcements" USING ((COALESCE("public"."get_my_claim_text"('role'::"text"), ''::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_base"."article_categories" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_base"."customer_addresses" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_base"."customers" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_base"."departments" USING ((COALESCE("public"."get_my_claim_text"('role'::"text"), ''::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_base"."employees" USING ((COALESCE("public"."get_my_claim_text"('role'::"text"), ''::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_base"."employees_departments" USING ((COALESCE("public"."get_my_claim_text"('role'::"text"), ''::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_base"."purchase_order_items" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_base"."purchase_orders" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_base"."report_template" FOR SELECT USING ((COALESCE("public"."get_my_claim_text"('role'::"text"), ''::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_base"."suppliers" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_base"."units_of_measure" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "Users can access checklist results in their domain" ON "mod_base"."quality_control_checklist_results" USING (("domain_id" = (("auth"."jwt"() ->> 'domain_id'::"text"))::"uuid"));



CREATE POLICY "Users can delete their own domain data" ON "mod_base"."customer_addresses" FOR DELETE USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can insert addresses in their domain" ON "mod_base"."customer_addresses" FOR INSERT WITH CHECK (((( SELECT "auth"."uid"() AS "uid") IS NOT NULL) AND (("domain_id" IN ( SELECT "domain_users"."domain_id"
   FROM "mod_admin"."domain_users"
  WHERE ("domain_users"."user_id" = "auth"."uid"()))) OR ("public"."get_my_claim_text"('role'::"text") = ANY (ARRAY['admin'::"text", 'superAdmin'::"text"])) OR ("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR ('*'::"text" = ANY ("shared_with")))));



CREATE POLICY "Users can insert customers in their domain" ON "mod_base"."customers" FOR INSERT WITH CHECK (((( SELECT "auth"."uid"() AS "uid") IS NOT NULL) AND (("domain_id" IN ( SELECT "domain_users"."domain_id"
   FROM "mod_admin"."domain_users"
  WHERE ("domain_users"."user_id" = "auth"."uid"()))) OR ("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR ('*'::"text" = ANY ("shared_with")))));



CREATE POLICY "Users can manage their own profile" ON "mod_base"."profiles" USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Users can see their own department assignments" ON "mod_base"."employees_departments" USING (("employee_id" = "auth"."uid"()));



CREATE POLICY "Users can see their own domain data" ON "mod_base"."announcements" USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_base"."article_categories" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_base"."customer_addresses" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_base"."customers" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_base"."departments" USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_base"."purchase_order_items" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_base"."purchase_orders" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_base"."report_template" USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_base"."suppliers" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_base"."units_of_measure" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own employee data" ON "mod_base"."employees" USING (("id" = "auth"."uid"()));



CREATE POLICY "Users can update addresses in their domain" ON "mod_base"."customer_addresses" FOR UPDATE USING (((( SELECT "auth"."uid"() AS "uid") IS NOT NULL) AND (("domain_id" IN ( SELECT "domain_users"."domain_id"
   FROM "mod_admin"."domain_users"
  WHERE ("domain_users"."user_id" = "auth"."uid"()))) OR ("public"."get_my_claim_text"('role'::"text") = ANY (ARRAY['admin'::"text", 'superAdmin'::"text"])) OR ("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR ('*'::"text" = ANY ("shared_with")))));



CREATE POLICY "Users can update customers in their domain" ON "mod_base"."customers" FOR UPDATE USING (((( SELECT "auth"."uid"() AS "uid") IS NOT NULL) AND (("domain_id" IN ( SELECT "domain_users"."domain_id"
   FROM "mod_admin"."domain_users"
  WHERE ("domain_users"."user_id" = "auth"."uid"()))) OR ("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR ('*'::"text" = ANY ("shared_with")))));



CREATE POLICY "Users can view customers in their domain" ON "mod_base"."customers" FOR SELECT USING (((( SELECT "auth"."uid"() AS "uid") IS NOT NULL) AND (("domain_id" IN ( SELECT "domain_users"."domain_id"
   FROM "mod_admin"."domain_users"
  WHERE ("domain_users"."user_id" = "auth"."uid"()))) OR ("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR ('*'::"text" = ANY ("shared_with")) OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "allow_delete_internal_sales_order_items" ON "mod_base"."internal_sales_order_items" FOR DELETE TO "authenticated" USING (true);



CREATE POLICY "allow_delete_internal_sales_orders" ON "mod_base"."internal_sales_orders" FOR DELETE TO "authenticated" USING (true);



CREATE POLICY "allow_delete_sales_orders" ON "mod_base"."sales_orders" FOR DELETE TO "authenticated" USING (true);



CREATE POLICY "allow_insert_internal_sales_order_items" ON "mod_base"."internal_sales_order_items" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "allow_insert_internal_sales_orders" ON "mod_base"."internal_sales_orders" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "allow_insert_sales_orders" ON "mod_base"."sales_orders" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "allow_select_internal_sales_order_items" ON "mod_base"."internal_sales_order_items" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "allow_select_internal_sales_orders" ON "mod_base"."internal_sales_orders" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "allow_select_sales_orders" ON "mod_base"."sales_orders" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "allow_update_internal_sales_order_items" ON "mod_base"."internal_sales_order_items" FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);



CREATE POLICY "allow_update_internal_sales_orders" ON "mod_base"."internal_sales_orders" FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);



CREATE POLICY "allow_update_sales_orders" ON "mod_base"."sales_orders" FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);



ALTER TABLE "mod_base"."announcements" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."article_categories" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."articles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."bom_articles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."custom_article_attachments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."customer_addresses" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."customers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."departments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."employees" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."employees_departments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."internal_sales_order_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."internal_sales_orders" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."purchase_order_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."purchase_orders" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."quality_control" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."quality_control_attachments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."quality_control_checklist_results" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."quality_control_types" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."quality_control_types_duplicate" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."report_template" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."sales_order_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."sales_orders" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."serial_number_counters" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."suppliers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_base"."units_of_measure" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Allow authenticated users to delete pages_menu_departments" ON "mod_datalayer"."pages_menu_departments" FOR DELETE TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated users to insert pages_menu_departments" ON "mod_datalayer"."pages_menu_departments" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Allow authenticated users to select pages_menu_departments" ON "mod_datalayer"."pages_menu_departments" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated users to update pages_menu_departments" ON "mod_datalayer"."pages_menu_departments" FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);



CREATE POLICY "Any authenticated user can read" ON "mod_datalayer"."fields" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Any authenticated user can read" ON "mod_datalayer"."main_menu" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Any authenticated user can read" ON "mod_datalayer"."modules" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Any authenticated user can read" ON "mod_datalayer"."page_categories" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Any authenticated user can read" ON "mod_datalayer"."pages" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Any authenticated user can read" ON "mod_datalayer"."tables" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can manage page assignments" ON "mod_datalayer"."pages_departments" TO "authenticated" USING (true) WITH CHECK (true);



CREATE POLICY "SuperAdmins can manage all data" ON "mod_datalayer"."pages_departments" USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "Users can see page assignments for their departments" ON "mod_datalayer"."pages_departments" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "mod_base"."employees_departments" "ed"
  WHERE (("ed"."employee_id" = "auth"."uid"()) AND ("ed"."department_id" = "pages_departments"."department_id") AND ("ed"."is_deleted" = false)))));



CREATE POLICY "Users can see their own domain data" ON "mod_datalayer"."pages_departments" FOR SELECT USING ((("is_deleted" = false) AND (EXISTS ( SELECT 1
   FROM "mod_base"."departments" "d"
  WHERE (("d"."id" = "pages_departments"."department_id") AND (("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "d"."domain_id"))))));



ALTER TABLE "mod_datalayer"."fields" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_datalayer"."main_menu" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_datalayer"."modules" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_datalayer"."page_categories" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_datalayer"."pages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_datalayer"."pages_departments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_datalayer"."pages_menu_departments" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "superAdmin can delete" ON "mod_datalayer"."fields" FOR DELETE USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can delete" ON "mod_datalayer"."main_menu" FOR DELETE USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can delete" ON "mod_datalayer"."modules" FOR DELETE USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can delete" ON "mod_datalayer"."page_categories" FOR DELETE USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can delete" ON "mod_datalayer"."pages" FOR DELETE USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can delete" ON "mod_datalayer"."tables" FOR DELETE USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can insert into" ON "mod_datalayer"."fields" FOR INSERT WITH CHECK (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can insert into" ON "mod_datalayer"."main_menu" FOR INSERT WITH CHECK (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can insert into" ON "mod_datalayer"."modules" FOR INSERT WITH CHECK (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can insert into" ON "mod_datalayer"."page_categories" FOR INSERT WITH CHECK (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can insert into" ON "mod_datalayer"."pages" FOR INSERT WITH CHECK (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can insert into" ON "mod_datalayer"."tables" FOR INSERT WITH CHECK (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can update" ON "mod_datalayer"."fields" FOR UPDATE USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can update" ON "mod_datalayer"."main_menu" FOR UPDATE USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can update" ON "mod_datalayer"."modules" FOR UPDATE USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can update" ON "mod_datalayer"."page_categories" FOR UPDATE USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can update" ON "mod_datalayer"."pages" FOR UPDATE USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "superAdmin can update" ON "mod_datalayer"."tables" FOR UPDATE USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



ALTER TABLE "mod_datalayer"."tables" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Administrators can see domain work cycles" ON "mod_manufacturing"."work_cycles" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid")) AND ("is_deleted" = false)));



CREATE POLICY "Administrators can see domain work orders" ON "mod_manufacturing"."work_orders" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid")) AND ("is_deleted" = false)));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_manufacturing"."departments" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_manufacturing"."locations" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_manufacturing"."production_logs" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_manufacturing"."recipes" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_manufacturing"."scheduled_items" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'administrator'::"text") AND (("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id")));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_manufacturing"."work_order_quality_summary" FOR SELECT USING (
CASE
    WHEN ("public"."get_my_claim_text"('user_role'::"text") = 'SuperAdmin'::"text") THEN true
    WHEN ("public"."get_my_claim_text"('user_role'::"text") = 'Admin'::"text") THEN (("domain_id" = ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid") OR ("domain_id" IN ( SELECT "domains"."id"
       FROM "mod_admin"."domains"
      WHERE ("domains"."parent_domain_id" = ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))))
    ELSE ("domain_id" = ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid")
END);



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_manufacturing"."work_steps" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_manufacturing"."workstations" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_manufacturing"."departments" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_manufacturing"."locations" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_manufacturing"."production_logs" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_manufacturing"."recipes" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_manufacturing"."scheduled_items" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'superadmin'::"text") OR ("domain_id" = ANY (("public"."get_my_claim_text"('shared_domains'::"text"))::"uuid"[]))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_manufacturing"."work_order_quality_summary" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = ANY (("shared_with")::"uuid"[])));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_manufacturing"."work_steps" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_manufacturing"."workstations" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Authenticated users can delete data" ON "mod_manufacturing"."recipes" FOR DELETE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can delete data" ON "mod_manufacturing"."work_order_quality_summary" FOR UPDATE TO "authenticated" USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id")) WITH CHECK (("is_deleted" = true));



CREATE POLICY "Authenticated users can delete work order attachments" ON "mod_manufacturing"."work_order_attachments" FOR DELETE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Authenticated users can insert data" ON "mod_manufacturing"."departments" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_manufacturing"."locations" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_manufacturing"."production_logs" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_manufacturing"."recipes" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_manufacturing"."scheduled_items" FOR INSERT WITH CHECK ((("auth"."role"() = 'authenticated'::"text") AND (("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id")));



CREATE POLICY "Authenticated users can insert data" ON "mod_manufacturing"."work_cycles" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_manufacturing"."work_order_quality_summary" FOR INSERT TO "authenticated" WITH CHECK ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Authenticated users can insert data" ON "mod_manufacturing"."work_orders" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_manufacturing"."work_steps" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_manufacturing"."workstations" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert work cycles" ON "mod_manufacturing"."work_cycles" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert work order attachments" ON "mod_manufacturing"."work_order_attachments" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Authenticated users can insert work orders" ON "mod_manufacturing"."work_orders" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can see domain work orders" ON "mod_manufacturing"."work_orders" FOR SELECT USING ((("auth"."uid"() IS NOT NULL) AND (("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") AND ("is_deleted" = false)));



CREATE POLICY "Authenticated users can update data" ON "mod_manufacturing"."departments" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_manufacturing"."locations" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_manufacturing"."production_logs" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_manufacturing"."recipes" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_manufacturing"."scheduled_items" FOR UPDATE USING ((("auth"."role"() = 'authenticated'::"text") AND (("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id")));



CREATE POLICY "Authenticated users can update data" ON "mod_manufacturing"."work_cycles" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_manufacturing"."work_order_quality_summary" FOR UPDATE TO "authenticated" USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id")) WITH CHECK ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Authenticated users can update data" ON "mod_manufacturing"."work_orders" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_manufacturing"."work_steps" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_manufacturing"."workstations" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update work cycles" ON "mod_manufacturing"."work_cycles" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update work order attachments" ON "mod_manufacturing"."work_order_attachments" FOR UPDATE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Authenticated users can update work orders" ON "mod_manufacturing"."work_orders" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can view work order attachments" ON "mod_manufacturing"."work_order_attachments" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Enable delete for authenticated users" ON "mod_manufacturing"."work_cycle_categories" FOR DELETE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Enable delete for authenticated users" ON "mod_manufacturing"."work_flows_work_cycles" FOR DELETE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Enable insert for authenticated users" ON "mod_manufacturing"."work_cycle_categories" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Enable insert for authenticated users" ON "mod_manufacturing"."work_flows" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Enable insert for authenticated users" ON "mod_manufacturing"."work_flows_work_cycles" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Enable read access for authenticated users" ON "mod_manufacturing"."work_cycle_categories" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Enable read access for authenticated users" ON "mod_manufacturing"."work_flows" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Enable read access for authenticated users" ON "mod_manufacturing"."work_flows_work_cycles" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Enable update for authenticated users" ON "mod_manufacturing"."work_cycle_categories" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Enable update for authenticated users" ON "mod_manufacturing"."work_flows" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Enable update for authenticated users" ON "mod_manufacturing"."work_flows_work_cycles" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "SuperAdmins can see all data" ON "mod_manufacturing"."departments" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_manufacturing"."locations" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_manufacturing"."production_logs" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_manufacturing"."recipes" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_manufacturing"."scheduled_items" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superadmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_manufacturing"."work_order_quality_summary" FOR SELECT USING (("public"."get_my_claim_text"('user_role'::"text") = 'SuperAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_manufacturing"."work_steps" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_manufacturing"."workstations" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all work cycles" ON "mod_manufacturing"."work_cycles" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text") AND ("is_deleted" = false)));



CREATE POLICY "SuperAdmins can see all work orders" ON "mod_manufacturing"."work_orders" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text") AND ("is_deleted" = false)));



CREATE POLICY "Users can insert coil consumption in their domain" ON "mod_manufacturing"."coil_consumption" FOR INSERT WITH CHECK (("domain_id" = (( SELECT (("auth"."jwt"() -> 'app_metadata'::"text") ->> 'domain_id'::"text")))::"uuid"));



CREATE POLICY "Users can insert coils in their domain" ON "mod_manufacturing"."coils" FOR INSERT WITH CHECK (("domain_id" = (( SELECT (("auth"."jwt"() -> 'app_metadata'::"text") ->> 'domain_id'::"text")))::"uuid"));



CREATE POLICY "Users can insert plate templates in their domain" ON "mod_manufacturing"."plate_templates" FOR INSERT WITH CHECK (("domain_id" = (( SELECT (("auth"."jwt"() -> 'app_metadata'::"text") ->> 'domain_id'::"text")))::"uuid"));



CREATE POLICY "Users can insert production plans in their domain" ON "mod_manufacturing"."coil_production_plans" FOR INSERT WITH CHECK (("domain_id" = (( SELECT (("auth"."jwt"() -> 'app_metadata'::"text") ->> 'domain_id'::"text")))::"uuid"));



CREATE POLICY "Users can see active work cycles" ON "mod_manufacturing"."work_cycles" FOR SELECT USING (("is_deleted" = false));



CREATE POLICY "Users can see department shared work cycles" ON "mod_manufacturing"."work_cycles" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND ("is_deleted" = false))));



CREATE POLICY "Users can see their own domain coil consumption" ON "mod_manufacturing"."coil_consumption" FOR SELECT USING (("domain_id" = (( SELECT (("auth"."jwt"() -> 'app_metadata'::"text") ->> 'domain_id'::"text")))::"uuid"));



CREATE POLICY "Users can see their own domain coils" ON "mod_manufacturing"."coils" FOR SELECT USING (("domain_id" = (( SELECT (("auth"."jwt"() -> 'app_metadata'::"text") ->> 'domain_id'::"text")))::"uuid"));



CREATE POLICY "Users can see their own domain data" ON "mod_manufacturing"."departments" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_manufacturing"."locations" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_manufacturing"."production_logs" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_manufacturing"."recipes" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_manufacturing"."scheduled_items" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_manufacturing"."work_order_quality_summary" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_manufacturing"."work_steps" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_manufacturing"."workstations" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain plate templates" ON "mod_manufacturing"."plate_templates" FOR SELECT USING (("domain_id" = (( SELECT (("auth"."jwt"() -> 'app_metadata'::"text") ->> 'domain_id'::"text")))::"uuid"));



CREATE POLICY "Users can see their own domain production plans" ON "mod_manufacturing"."coil_production_plans" FOR SELECT USING (("domain_id" = (( SELECT (("auth"."jwt"() -> 'app_metadata'::"text") ->> 'domain_id'::"text")))::"uuid"));



CREATE POLICY "Users can update coil consumption in their domain" ON "mod_manufacturing"."coil_consumption" FOR UPDATE USING (("domain_id" = (( SELECT (("auth"."jwt"() -> 'app_metadata'::"text") ->> 'domain_id'::"text")))::"uuid"));



CREATE POLICY "Users can update coils in their domain" ON "mod_manufacturing"."coils" FOR UPDATE USING (("domain_id" = (( SELECT (("auth"."jwt"() -> 'app_metadata'::"text") ->> 'domain_id'::"text")))::"uuid"));



CREATE POLICY "Users can update plate templates in their domain" ON "mod_manufacturing"."plate_templates" FOR UPDATE USING (("domain_id" = (( SELECT (("auth"."jwt"() -> 'app_metadata'::"text") ->> 'domain_id'::"text")))::"uuid"));



CREATE POLICY "Users can update production plans in their domain" ON "mod_manufacturing"."coil_production_plans" FOR UPDATE USING (("domain_id" = (( SELECT (("auth"."jwt"() -> 'app_metadata'::"text") ->> 'domain_id'::"text")))::"uuid"));



ALTER TABLE "mod_manufacturing"."coil_consumption" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."coil_production_plans" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."coils" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."departments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."locations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."plate_templates" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."production_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."recipes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."scheduled_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."work_cycle_categories" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."work_cycles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."work_flows" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."work_flows_work_cycles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."work_order_attachments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."work_order_quality_summary" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."work_orders" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."work_steps" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."workstations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_manufacturing"."workstations_duplicate" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Administrators can see domain notifications" ON "mod_pulse"."notifications" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid")) AND ("is_deleted" = false)));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_pulse"."department_notification_configs" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_pulse"."pulse_chat" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_pulse"."pulse_chat_files" USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_pulse"."pulse_checklists" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_pulse"."pulse_comments" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_pulse"."pulse_conversation_participants" USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_pulse"."pulse_progress" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_pulse"."pulse_slas" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_pulse"."pulses" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_pulse"."tasks" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_pulse"."pulse_chat" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_pulse"."pulse_checklists" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_pulse"."pulse_comments" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_pulse"."pulse_progress" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_pulse"."pulse_slas" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_pulse"."pulses" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_pulse"."tasks" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Authenticated users can delete data" ON "mod_pulse"."department_notification_configs" FOR DELETE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_pulse"."department_notification_configs" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_pulse"."notifications" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_pulse"."pulse_chat" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_pulse"."pulse_chat_files" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_pulse"."pulse_checklists" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_pulse"."pulse_comments" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_pulse"."pulse_conversation_participants" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_pulse"."pulse_progress" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_pulse"."pulse_slas" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_pulse"."pulses" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_pulse"."tasks" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_pulse"."department_notification_configs" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_pulse"."notifications" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_pulse"."pulse_chat" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_pulse"."pulse_chat_files" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_pulse"."pulse_checklists" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_pulse"."pulse_comments" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_pulse"."pulse_conversation_participants" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_pulse"."pulse_progress" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_pulse"."pulse_slas" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_pulse"."pulses" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_pulse"."tasks" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "SuperAdmins can see all data" ON "mod_pulse"."department_notification_configs" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_pulse"."pulse_chat" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_pulse"."pulse_chat_files" USING ((COALESCE("public"."get_my_claim_text"('role'::"text"), ''::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_pulse"."pulse_checklists" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_pulse"."pulse_comments" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_pulse"."pulse_conversation_participants" USING ((COALESCE("public"."get_my_claim_text"('role'::"text"), ''::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_pulse"."pulse_progress" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_pulse"."pulse_slas" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_pulse"."pulses" FOR SELECT USING ((COALESCE("public"."get_my_claim_text"('role'::"text"), ''::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_pulse"."tasks" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all notifications" ON "mod_pulse"."notifications" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text") AND ("is_deleted" = false)));



CREATE POLICY "Users can see department shared notifications" ON "mod_pulse"."notifications" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND ("is_deleted" = false))));



CREATE POLICY "Users can see notifications where they are mentioned" ON "mod_pulse"."notifications" FOR SELECT USING (false);



CREATE POLICY "Users can see their own domain data" ON "mod_pulse"."department_notification_configs" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_pulse"."pulse_chat" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_pulse"."pulse_chat_files" USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_pulse"."pulse_checklists" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_pulse"."pulse_comments" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_pulse"."pulse_conversation_participants" USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_pulse"."pulse_progress" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_pulse"."pulse_slas" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_pulse"."pulses" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_pulse"."tasks" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own notifications" ON "mod_pulse"."notifications" FOR SELECT USING ((("user_id" = "auth"."uid"()) AND ("is_deleted" = false)));



ALTER TABLE "mod_pulse"."department_notification_configs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_pulse"."notifications" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_pulse"."pulse_chat" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_pulse"."pulse_chat_files" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_pulse"."pulse_checklists" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_pulse"."pulse_comments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_pulse"."pulse_conversation_participants" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_pulse"."pulse_progress" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_pulse"."pulse_slas" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_pulse"."pulses" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_pulse"."tasks" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Authenticated users can insert" ON "mod_quality_control"."conformity_documents" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert" ON "mod_quality_control"."defect_types" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert" ON "mod_quality_control"."measurement_parameters" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert" ON "mod_quality_control"."quality_control_checklist_results" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert" ON "mod_quality_control"."quality_control_defects" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert" ON "mod_quality_control"."quality_control_measurements" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert" ON "mod_quality_control"."supplier_returns" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can see data" ON "mod_quality_control"."conformity_documents" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can see data" ON "mod_quality_control"."defect_types" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can see data" ON "mod_quality_control"."measurement_parameters" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can see data" ON "mod_quality_control"."quality_control_checklist_results" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can see data" ON "mod_quality_control"."quality_control_defects" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can see data" ON "mod_quality_control"."quality_control_measurements" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can see data" ON "mod_quality_control"."supplier_returns" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can update data" ON "mod_quality_control"."conformity_documents" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can update data" ON "mod_quality_control"."defect_types" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can update data" ON "mod_quality_control"."measurement_parameters" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can update data" ON "mod_quality_control"."quality_control_checklist_results" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can update data" ON "mod_quality_control"."quality_control_defects" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can update data" ON "mod_quality_control"."quality_control_measurements" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can update data" ON "mod_quality_control"."supplier_returns" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



ALTER TABLE "mod_quality_control"."conformity_documents" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_quality_control"."defect_types" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_quality_control"."measurement_parameters" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_quality_control"."quality_control_checklist_results" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_quality_control"."quality_control_defects" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_quality_control"."quality_control_measurements" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_quality_control"."supplier_returns" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_wms"."inventory_backup" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_wms"."inventory_limits" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_wms"."receipt_items" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_wms"."shipment_items" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can see their domain and subdomain data" ON "mod_wms"."shipments" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can view box contents in their domain and subdom" ON "mod_wms"."box_contents" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can view box types in their domain and subdomain" ON "mod_wms"."box_types" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can view carton contents in their domain and sub" ON "mod_wms"."carton_contents" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can view carton types in their domain and subdom" ON "mod_wms"."carton_types" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can view pallet contents in their domain and sub" ON "mod_wms"."pallet_contents" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can view pallet types in their domain and subdom" ON "mod_wms"."pallet_types" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can view shipment boxes in their domain and subd" ON "mod_wms"."shipment_boxes" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can view shipment cartons in their domain and su" ON "mod_wms"."shipment_cartons" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can view shipment pallets in their domain and su" ON "mod_wms"."shipment_pallets" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Administrators can view shipment standalone items in their doma" ON "mod_wms"."shipment_standalone_items" FOR SELECT USING ((("public"."get_my_claim_text"('role'::"text") = 'admin'::"text") AND ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id") OR "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow authenticated users" ON "mod_wms"."shipment_item_addresses" TO "authenticated" USING (("domain_id" IN ( SELECT "domain_users"."domain_id"
   FROM "mod_admin"."domain_users"
  WHERE ("domain_users"."user_id" = "auth"."uid"())))) WITH CHECK (("domain_id" IN ( SELECT "domain_users"."domain_id"
   FROM "mod_admin"."domain_users"
  WHERE ("domain_users"."user_id" = "auth"."uid"()))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_wms"."inventory_backup" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_wms"."inventory_limits" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_wms"."receipt_items" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_wms"."shipment_items" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow shared data access for specific subdomains" ON "mod_wms"."shipments" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text") = ANY ("shared_with")) OR (('*'::"text" = ANY ("shared_with")) AND "mod_admin"."is_subdomain"("domain_id", ("public"."get_my_claim_text"('domain_id'::"text"))::"uuid"))));



CREATE POLICY "Allow users to create addresses in their domain" ON "mod_wms"."shipment_item_addresses" FOR INSERT TO "authenticated" WITH CHECK (("domain_id" IN ( SELECT "domain_users"."domain_id"
   FROM "mod_admin"."domain_users"
  WHERE ("domain_users"."user_id" = "auth"."uid"()))));



CREATE POLICY "Allow users to delete addresses in their domain" ON "mod_wms"."shipment_item_addresses" FOR DELETE TO "authenticated" USING (("domain_id" IN ( SELECT "domain_users"."domain_id"
   FROM "mod_admin"."domain_users"
  WHERE ("domain_users"."user_id" = "auth"."uid"()))));



CREATE POLICY "Allow users to update addresses in their domain" ON "mod_wms"."shipment_item_addresses" FOR UPDATE TO "authenticated" USING (("domain_id" IN ( SELECT "domain_users"."domain_id"
   FROM "mod_admin"."domain_users"
  WHERE ("domain_users"."user_id" = "auth"."uid"())))) WITH CHECK (("domain_id" IN ( SELECT "domain_users"."domain_id"
   FROM "mod_admin"."domain_users"
  WHERE ("domain_users"."user_id" = "auth"."uid"()))));



CREATE POLICY "Allow users to view addresses in their domain" ON "mod_wms"."shipment_item_addresses" FOR SELECT TO "authenticated" USING (("domain_id" IN ( SELECT "domain_users"."domain_id"
   FROM "mod_admin"."domain_users"
  WHERE ("domain_users"."user_id" = "auth"."uid"()))));



CREATE POLICY "Authenticated users can delete batches" ON "mod_wms"."batches" FOR DELETE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can delete box contents" ON "mod_wms"."box_contents" FOR DELETE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can delete box types" ON "mod_wms"."box_types" FOR DELETE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can delete carton contents" ON "mod_wms"."carton_contents" FOR DELETE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can delete carton types" ON "mod_wms"."carton_types" FOR DELETE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can delete pallet contents" ON "mod_wms"."pallet_contents" FOR DELETE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can delete pallet types" ON "mod_wms"."pallet_types" FOR DELETE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can delete receipts" ON "mod_wms"."receipts" FOR DELETE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can delete shipment attachments" ON "mod_wms"."shipment_attachments" FOR DELETE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Authenticated users can delete shipment boxes" ON "mod_wms"."shipment_boxes" FOR DELETE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can delete shipment cartons" ON "mod_wms"."shipment_cartons" FOR DELETE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can delete shipment pallets" ON "mod_wms"."shipment_pallets" FOR DELETE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can delete shipment sales orders" ON "mod_wms"."shipment_sales_orders" FOR DELETE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can delete shipment standalone items" ON "mod_wms"."shipment_standalone_items" FOR DELETE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can delete stock movements" ON "mod_wms"."stock_movements" FOR DELETE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert batches" ON "mod_wms"."batches" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert box contents" ON "mod_wms"."box_contents" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert box types" ON "mod_wms"."box_types" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert carton contents" ON "mod_wms"."carton_contents" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert carton types" ON "mod_wms"."carton_types" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_wms"."inventory" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_wms"."inventory_backup" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_wms"."inventory_limits" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_wms"."locations" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_wms"."receipt_items" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_wms"."shipment_items" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_wms"."shipments" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert data" ON "mod_wms"."warehouses" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert pallet contents" ON "mod_wms"."pallet_contents" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert pallet types" ON "mod_wms"."pallet_types" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert receipts" ON "mod_wms"."receipts" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can insert shipment attachments" ON "mod_wms"."shipment_attachments" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Authenticated users can insert shipment boxes" ON "mod_wms"."shipment_boxes" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert shipment cartons" ON "mod_wms"."shipment_cartons" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert shipment pallets" ON "mod_wms"."shipment_pallets" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert shipment sales orders" ON "mod_wms"."shipment_sales_orders" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert shipment standalone items" ON "mod_wms"."shipment_standalone_items" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert stock movements" ON "mod_wms"."stock_movements" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can select all batches" ON "mod_wms"."batches" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can select all inventory" ON "mod_wms"."inventory" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can select all locations" ON "mod_wms"."locations" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can select all receipts" ON "mod_wms"."receipts" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can select all stock movements" ON "mod_wms"."stock_movements" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can select all warehouses" ON "mod_wms"."warehouses" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update batches" ON "mod_wms"."batches" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update box contents" ON "mod_wms"."box_contents" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can update box types" ON "mod_wms"."box_types" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can update carton contents" ON "mod_wms"."carton_contents" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can update carton types" ON "mod_wms"."carton_types" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_wms"."inventory" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_wms"."inventory_backup" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_wms"."inventory_limits" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_wms"."locations" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_wms"."receipt_items" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_wms"."shipment_items" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_wms"."shipments" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update data" ON "mod_wms"."warehouses" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update pallet contents" ON "mod_wms"."pallet_contents" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can update pallet types" ON "mod_wms"."pallet_types" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can update receipts" ON "mod_wms"."receipts" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can update shipment attachments" ON "mod_wms"."shipment_attachments" FOR UPDATE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Authenticated users can update shipment boxes" ON "mod_wms"."shipment_boxes" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can update shipment cartons" ON "mod_wms"."shipment_cartons" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can update shipment pallets" ON "mod_wms"."shipment_pallets" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can update shipment sales orders" ON "mod_wms"."shipment_sales_orders" FOR UPDATE USING (("auth"."uid"() IS NOT NULL)) WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can update shipment standalone items" ON "mod_wms"."shipment_standalone_items" FOR UPDATE USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can update stock movements" ON "mod_wms"."stock_movements" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL));



CREATE POLICY "Authenticated users can view shipment attachments" ON "mod_wms"."shipment_attachments" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Authenticated users can view shipment sales orders" ON "mod_wms"."shipment_sales_orders" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "SuperAdmins can see all data" ON "mod_wms"."inventory_backup" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_wms"."inventory_limits" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_wms"."receipt_items" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_wms"."shipment_items" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can see all data" ON "mod_wms"."shipments" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can view all box contents" ON "mod_wms"."box_contents" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can view all box types" ON "mod_wms"."box_types" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can view all carton contents" ON "mod_wms"."carton_contents" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can view all carton types" ON "mod_wms"."carton_types" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can view all pallet contents" ON "mod_wms"."pallet_contents" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can view all pallet types" ON "mod_wms"."pallet_types" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can view all shipment boxes" ON "mod_wms"."shipment_boxes" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can view all shipment cartons" ON "mod_wms"."shipment_cartons" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can view all shipment pallets" ON "mod_wms"."shipment_pallets" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "SuperAdmins can view all shipment standalone items" ON "mod_wms"."shipment_standalone_items" FOR SELECT USING (("public"."get_my_claim_text"('role'::"text") = 'superAdmin'::"text"));



CREATE POLICY "Users can see their own domain data" ON "mod_wms"."inventory_backup" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_wms"."inventory_limits" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_wms"."receipt_items" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_wms"."shipment_items" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can see their own domain data" ON "mod_wms"."shipments" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can view box contents in their domain" ON "mod_wms"."box_contents" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can view box types in their domain" ON "mod_wms"."box_types" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can view carton contents in their domain" ON "mod_wms"."carton_contents" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can view carton types in their domain" ON "mod_wms"."carton_types" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can view pallet contents in their domain" ON "mod_wms"."pallet_contents" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can view pallet types in their domain" ON "mod_wms"."pallet_types" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can view shipment boxes in their domain" ON "mod_wms"."shipment_boxes" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can view shipment cartons in their domain" ON "mod_wms"."shipment_cartons" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can view shipment pallets in their domain" ON "mod_wms"."shipment_pallets" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



CREATE POLICY "Users can view shipment standalone items in their domain" ON "mod_wms"."shipment_standalone_items" FOR SELECT USING ((("public"."get_my_claim_text"('domain_id'::"text"))::"uuid" = "domain_id"));



ALTER TABLE "mod_wms"."batches" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."box_contents" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."box_types" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."carton_contents" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."carton_types" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."inventory" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."inventory_backup" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."inventory_limits" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."locations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."pallet_contents" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."pallet_types" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."receipt_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."receipts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."shipment_attachments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."shipment_boxes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."shipment_cartons" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."shipment_item_addresses" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."shipment_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."shipment_pallets" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."shipment_sales_orders" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."shipment_standalone_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."shipments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."stock_movements" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "mod_wms"."warehouses" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";






ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "mod_base"."sales_orders";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "mod_pulse"."notifications";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "mod_pulse"."pulse_chat";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "mod_pulse"."pulse_conversation_participants";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "mod_pulse"."pulses";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "mod_wms"."batches";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "mod_wms"."inventory_backup";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "mod_wms"."shipments";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "mod_wms"."stock_movements";



GRANT USAGE ON SCHEMA "mod_admin" TO "anon";
GRANT USAGE ON SCHEMA "mod_admin" TO "authenticated";
GRANT USAGE ON SCHEMA "mod_admin" TO "service_role";



GRANT USAGE ON SCHEMA "mod_base" TO "anon";
GRANT USAGE ON SCHEMA "mod_base" TO "authenticated";
GRANT USAGE ON SCHEMA "mod_base" TO "service_role";



GRANT USAGE ON SCHEMA "mod_crm" TO "anon";
GRANT USAGE ON SCHEMA "mod_crm" TO "authenticated";
GRANT USAGE ON SCHEMA "mod_crm" TO "service_role";



GRANT USAGE ON SCHEMA "mod_datalayer" TO "anon";
GRANT USAGE ON SCHEMA "mod_datalayer" TO "authenticated";
GRANT USAGE ON SCHEMA "mod_datalayer" TO "service_role";



GRANT USAGE ON SCHEMA "mod_home" TO "anon";
GRANT USAGE ON SCHEMA "mod_home" TO "authenticated";
GRANT USAGE ON SCHEMA "mod_home" TO "service_role";



GRANT USAGE ON SCHEMA "mod_hr" TO "anon";
GRANT USAGE ON SCHEMA "mod_hr" TO "authenticated";
GRANT USAGE ON SCHEMA "mod_hr" TO "service_role";



GRANT USAGE ON SCHEMA "mod_manufacturing" TO "anon";
GRANT USAGE ON SCHEMA "mod_manufacturing" TO "authenticated";
GRANT USAGE ON SCHEMA "mod_manufacturing" TO "service_role";



GRANT USAGE ON SCHEMA "mod_pulse" TO "anon";
GRANT USAGE ON SCHEMA "mod_pulse" TO "authenticated";
GRANT USAGE ON SCHEMA "mod_pulse" TO "service_role";



GRANT USAGE ON SCHEMA "mod_wms" TO "anon";
GRANT USAGE ON SCHEMA "mod_wms" TO "authenticated";
GRANT USAGE ON SCHEMA "mod_wms" TO "service_role";






GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;





































































































































































SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;






SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;










































SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;






GRANT ALL ON FUNCTION "mod_admin"."delete_avatar"("avatar_url" "text", OUT "status" integer, OUT "content" "text") TO "anon";
GRANT ALL ON FUNCTION "mod_admin"."delete_avatar"("avatar_url" "text", OUT "status" integer, OUT "content" "text") TO "authenticated";
GRANT ALL ON FUNCTION "mod_admin"."delete_avatar"("avatar_url" "text", OUT "status" integer, OUT "content" "text") TO "service_role";



GRANT ALL ON FUNCTION "mod_admin"."delete_background_image"("background_image_url" "text", OUT "status" integer, OUT "content" "text") TO "anon";
GRANT ALL ON FUNCTION "mod_admin"."delete_background_image"("background_image_url" "text", OUT "status" integer, OUT "content" "text") TO "authenticated";
GRANT ALL ON FUNCTION "mod_admin"."delete_background_image"("background_image_url" "text", OUT "status" integer, OUT "content" "text") TO "service_role";



GRANT ALL ON FUNCTION "mod_admin"."delete_old_avatar"() TO "anon";
GRANT ALL ON FUNCTION "mod_admin"."delete_old_avatar"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_admin"."delete_old_avatar"() TO "service_role";



GRANT ALL ON FUNCTION "mod_admin"."delete_old_background_image"() TO "anon";
GRANT ALL ON FUNCTION "mod_admin"."delete_old_background_image"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_admin"."delete_old_background_image"() TO "service_role";



GRANT ALL ON FUNCTION "mod_admin"."delete_old_profile"() TO "anon";
GRANT ALL ON FUNCTION "mod_admin"."delete_old_profile"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_admin"."delete_old_profile"() TO "service_role";



GRANT ALL ON FUNCTION "mod_admin"."delete_storage_object"("bucket" "text", "object" "text", OUT "status" integer, OUT "content" "text") TO "anon";
GRANT ALL ON FUNCTION "mod_admin"."delete_storage_object"("bucket" "text", "object" "text", OUT "status" integer, OUT "content" "text") TO "authenticated";
GRANT ALL ON FUNCTION "mod_admin"."delete_storage_object"("bucket" "text", "object" "text", OUT "status" integer, OUT "content" "text") TO "service_role";



GRANT ALL ON FUNCTION "mod_admin"."handle_domain_modules_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_admin"."handle_domain_modules_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_admin"."handle_domain_modules_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_admin"."handle_domain_users_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_admin"."handle_domain_users_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_admin"."handle_domain_users_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_admin"."handle_domains_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_admin"."handle_domains_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_admin"."handle_domains_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_admin"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "mod_admin"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_admin"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "mod_admin"."handle_user_deletion"() TO "anon";
GRANT ALL ON FUNCTION "mod_admin"."handle_user_deletion"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_admin"."handle_user_deletion"() TO "service_role";



GRANT ALL ON FUNCTION "mod_admin"."handle_userprofile_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_admin"."handle_userprofile_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_admin"."handle_userprofile_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_admin"."is_subdomain"("child" "uuid", "parent" "uuid") TO "anon";
GRANT ALL ON FUNCTION "mod_admin"."is_subdomain"("child" "uuid", "parent" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "mod_admin"."is_subdomain"("child" "uuid", "parent" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."alert_quality_control_failed"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."alert_quality_control_failed"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."alert_quality_control_failed"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."calculate_qc_status"("p_quantity_checked" integer, "p_quantity_passed" integer, "p_quantity_failed" integer, "p_acceptance_number" integer, "p_rejection_number" integer) TO "anon";
GRANT ALL ON FUNCTION "mod_base"."calculate_qc_status"("p_quantity_checked" integer, "p_quantity_passed" integer, "p_quantity_failed" integer, "p_acceptance_number" integer, "p_rejection_number" integer) TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."calculate_qc_status"("p_quantity_checked" integer, "p_quantity_passed" integer, "p_quantity_failed" integer, "p_acceptance_number" integer, "p_rejection_number" integer) TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."cleanup_work_orders_on_internal_unschedule"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."cleanup_work_orders_on_internal_unschedule"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."cleanup_work_orders_on_internal_unschedule"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."cleanup_work_orders_on_unschedule"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."cleanup_work_orders_on_unschedule"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."cleanup_work_orders_on_unschedule"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."count_active_records"("table_name" "text", "schema_name" "text") TO "anon";
GRANT ALL ON FUNCTION "mod_base"."count_active_records"("table_name" "text", "schema_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."count_active_records"("table_name" "text", "schema_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."count_total_records"("table_name" "text", "schema_name" "text") TO "anon";
GRANT ALL ON FUNCTION "mod_base"."count_total_records"("table_name" "text", "schema_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."count_total_records"("table_name" "text", "schema_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."create_quality_control_for_shipment"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."create_quality_control_for_shipment"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."create_quality_control_for_shipment"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."direct_alert_new_sales_order"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."direct_alert_new_sales_order"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."direct_alert_new_sales_order"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."ensure_single_primary_address"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."ensure_single_primary_address"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."ensure_single_primary_address"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."generate_serial_number_for_sales_order_item"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."generate_serial_number_for_sales_order_item"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."generate_serial_number_for_sales_order_item"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."get_checklist_results_summary"("qc_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "mod_base"."get_checklist_results_summary"("qc_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."get_checklist_results_summary"("qc_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_announcements_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_announcements_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_announcements_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_archive_sales_order_on_status_completed"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_archive_sales_order_on_status_completed"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_archive_sales_order_on_status_completed"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_article_categories_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_article_categories_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_article_categories_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_articles_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_articles_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_articles_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_customer_addresses_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_customer_addresses_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_customer_addresses_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_customers_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_customers_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_customers_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_departments_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_departments_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_departments_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_employees_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_employees_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_employees_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_employees_departments_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_employees_departments_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_employees_departments_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_internal_sales_order_completion_on_manufacturing"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_internal_sales_order_completion_on_manufacturing"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_internal_sales_order_completion_on_manufacturing"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_new_employee"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_new_employee"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_new_employee"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_profiles_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_profiles_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_profiles_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_purchase_order_items_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_purchase_order_items_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_purchase_order_items_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_purchase_orders_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_purchase_orders_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_purchase_orders_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_quality_control_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_quality_control_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_quality_control_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_quality_control_types_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_quality_control_types_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_quality_control_types_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_sales_order_completion_on_manufacturing"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_sales_order_completion_on_manufacturing"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_sales_order_completion_on_manufacturing"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_sales_order_items_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_sales_order_items_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_sales_order_items_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_sales_orders_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_sales_orders_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_sales_orders_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_serial_number_counters_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_serial_number_counters_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_serial_number_counters_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_suppliers_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_suppliers_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_suppliers_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_units_of_measure_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_units_of_measure_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_units_of_measure_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."handle_update_sales_order_status_on_all_items_shipped"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."handle_update_sales_order_status_on_all_items_shipped"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."handle_update_sales_order_status_on_all_items_shipped"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."internal_sales_order_items_production_date_notification"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."internal_sales_order_items_production_date_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."internal_sales_order_items_production_date_notification"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."internal_sales_order_items_scheduling_notification_for_fabrizio"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."internal_sales_order_items_scheduling_notification_for_fabrizio"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."internal_sales_order_items_scheduling_notification_for_fabrizio"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."process_heat_exchanger_boms"("bom_data_array" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "mod_base"."process_heat_exchanger_boms"("bom_data_array" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."process_heat_exchanger_boms"("bom_data_array" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."sales_order_items_production_date_notification"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."sales_order_items_production_date_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."sales_order_items_production_date_notification"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."sales_order_items_scheduling_notification_for_fabrizio"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."sales_order_items_scheduling_notification_for_fabrizio"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."sales_order_items_scheduling_notification_for_fabrizio"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."sales_order_status_notification"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."sales_order_status_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."sales_order_status_notification"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."send_notification_to_department_members"("p_title" "text", "p_text" "text", "p_department_id" "uuid", "p_created_by" "uuid") TO "anon";
GRANT ALL ON FUNCTION "mod_base"."send_notification_to_department_members"("p_title" "text", "p_text" "text", "p_department_id" "uuid", "p_created_by" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."send_notification_to_department_members"("p_title" "text", "p_text" "text", "p_department_id" "uuid", "p_created_by" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."send_notification_to_user"("p_title" "text", "p_text" "text", "p_user_id" "uuid", "p_created_by" "uuid") TO "anon";
GRANT ALL ON FUNCTION "mod_base"."send_notification_to_user"("p_title" "text", "p_text" "text", "p_user_id" "uuid", "p_created_by" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."send_notification_to_user"("p_title" "text", "p_text" "text", "p_user_id" "uuid", "p_created_by" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."update_bom_articles_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."update_bom_articles_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."update_bom_articles_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."update_purchase_order_item_completion"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."update_purchase_order_item_completion"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."update_purchase_order_item_completion"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."update_quality_control_checklist_results_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."update_quality_control_checklist_results_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."update_quality_control_checklist_results_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "mod_base"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "mod_base"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_base"."update_updated_at_column"() TO "service_role";



GRANT ALL ON FUNCTION "mod_datalayer"."generate_code_format"("table_name" "text", "table_prefix" "text") TO "anon";
GRANT ALL ON FUNCTION "mod_datalayer"."generate_code_format"("table_name" "text", "table_prefix" "text") TO "authenticated";
GRANT ALL ON FUNCTION "mod_datalayer"."generate_code_format"("table_name" "text", "table_prefix" "text") TO "service_role";



GRANT ALL ON FUNCTION "mod_datalayer"."generate_sales_order_code"() TO "anon";
GRANT ALL ON FUNCTION "mod_datalayer"."generate_sales_order_code"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_datalayer"."generate_sales_order_code"() TO "service_role";



GRANT ALL ON FUNCTION "mod_datalayer"."generate_sales_order_number"() TO "anon";
GRANT ALL ON FUNCTION "mod_datalayer"."generate_sales_order_number"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_datalayer"."generate_sales_order_number"() TO "service_role";



GRANT ALL ON FUNCTION "mod_datalayer"."generate_sales_order_number_trigger"() TO "anon";
GRANT ALL ON FUNCTION "mod_datalayer"."generate_sales_order_number_trigger"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_datalayer"."generate_sales_order_number_trigger"() TO "service_role";



GRANT ALL ON FUNCTION "mod_datalayer"."generate_table_code"() TO "anon";
GRANT ALL ON FUNCTION "mod_datalayer"."generate_table_code"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_datalayer"."generate_table_code"() TO "service_role";



GRANT ALL ON FUNCTION "mod_datalayer"."handle_fields_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_datalayer"."handle_fields_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_datalayer"."handle_fields_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_datalayer"."handle_main_menu_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_datalayer"."handle_main_menu_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_datalayer"."handle_main_menu_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_datalayer"."handle_modules_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_datalayer"."handle_modules_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_datalayer"."handle_modules_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_datalayer"."handle_page_categories_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_datalayer"."handle_page_categories_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_datalayer"."handle_page_categories_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_datalayer"."handle_pages_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_datalayer"."handle_pages_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_datalayer"."handle_pages_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_datalayer"."handle_pages_departments_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_datalayer"."handle_pages_departments_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_datalayer"."handle_pages_departments_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_datalayer"."handle_tables_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_datalayer"."handle_tables_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_datalayer"."handle_tables_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_datalayer"."populate_sort_orders"() TO "anon";
GRANT ALL ON FUNCTION "mod_datalayer"."populate_sort_orders"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_datalayer"."populate_sort_orders"() TO "service_role";



GRANT ALL ON FUNCTION "mod_datalayer"."sync_fields"() TO "anon";
GRANT ALL ON FUNCTION "mod_datalayer"."sync_fields"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_datalayer"."sync_fields"() TO "service_role";



GRANT ALL ON FUNCTION "mod_datalayer"."sync_modules"() TO "anon";
GRANT ALL ON FUNCTION "mod_datalayer"."sync_modules"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_datalayer"."sync_modules"() TO "service_role";



GRANT ALL ON FUNCTION "mod_datalayer"."sync_tables"() TO "anon";
GRANT ALL ON FUNCTION "mod_datalayer"."sync_tables"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_datalayer"."sync_tables"() TO "service_role";



GRANT ALL ON FUNCTION "mod_datalayer"."update_fields_input_options"() TO "anon";
GRANT ALL ON FUNCTION "mod_datalayer"."update_fields_input_options"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_datalayer"."update_fields_input_options"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."check_coil_weight_warning"("coil_weight" numeric) TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."check_coil_weight_warning"("coil_weight" numeric) TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."check_coil_weight_warning"("coil_weight" numeric) TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."create_work_order_quality_summary"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."create_work_order_quality_summary"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."create_work_order_quality_summary"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."create_work_orders_for_scheduling"("p_order_item_id" "uuid", "p_scheduled_date" timestamp without time zone, "p_order_type" "text", "p_article_product_type" "text", "p_user_id" "uuid", "p_domain_id" "uuid", "p_article_id" "uuid", "p_article_name" "text", "p_quantity_ordered" integer, "p_assigned_to" "uuid", "p_assigned_department_id" "uuid", "p_priority" integer, "p_expected_end_date" timestamp without time zone) TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."create_work_orders_for_scheduling"("p_order_item_id" "uuid", "p_scheduled_date" timestamp without time zone, "p_order_type" "text", "p_article_product_type" "text", "p_user_id" "uuid", "p_domain_id" "uuid", "p_article_id" "uuid", "p_article_name" "text", "p_quantity_ordered" integer, "p_assigned_to" "uuid", "p_assigned_department_id" "uuid", "p_priority" integer, "p_expected_end_date" timestamp without time zone) TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."create_work_orders_for_scheduling"("p_order_item_id" "uuid", "p_scheduled_date" timestamp without time zone, "p_order_type" "text", "p_article_product_type" "text", "p_user_id" "uuid", "p_domain_id" "uuid", "p_article_id" "uuid", "p_article_name" "text", "p_quantity_ordered" integer, "p_assigned_to" "uuid", "p_assigned_department_id" "uuid", "p_priority" integer, "p_expected_end_date" timestamp without time zone) TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."generate_batch_code"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."generate_batch_code"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."generate_batch_code"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."handle_departments_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_departments_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_departments_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."handle_internal_work_order_manufacturing_status"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_internal_work_order_manufacturing_status"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_internal_work_order_manufacturing_status"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."handle_locations_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_locations_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_locations_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."handle_new_table_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_new_table_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_new_table_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."handle_production_logs_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_production_logs_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_production_logs_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."handle_recipes_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_recipes_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_recipes_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."handle_scheduled_items_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_scheduled_items_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_scheduled_items_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_cycles_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_cycles_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_cycles_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_order_manufacturing_status"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_order_manufacturing_status"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_order_manufacturing_status"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_order_quality_summary_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_order_quality_summary_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_order_quality_summary_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_order_status_notifications"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_order_status_notifications"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_order_status_notifications"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_orders_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_orders_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_orders_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_steps_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_steps_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_work_steps_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."handle_workstations_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_workstations_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."handle_workstations_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."update_article_loaded_for_all_work_orders"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."update_article_loaded_for_all_work_orders"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."update_article_loaded_for_all_work_orders"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."update_article_unloaded_for_all_work_orders"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."update_article_unloaded_for_all_work_orders"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."update_article_unloaded_for_all_work_orders"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."update_production_date_on_work_order_insert"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."update_production_date_on_work_order_insert"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."update_production_date_on_work_order_insert"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."update_sales_order_in_production_on_work_order_status"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."update_sales_order_in_production_on_work_order_status"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."update_sales_order_in_production_on_work_order_status"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."update_sales_order_status_on_work_order_in_progress"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."update_sales_order_status_on_work_order_in_progress"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."update_sales_order_status_on_work_order_in_progress"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."update_work_cycle_categories_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."update_work_cycle_categories_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."update_work_cycle_categories_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "mod_manufacturing"."update_work_flows_work_cycles_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "mod_manufacturing"."update_work_flows_work_cycles_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_manufacturing"."update_work_flows_work_cycles_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."create_pulse_for_record"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."create_pulse_for_record"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."create_pulse_for_record"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."delete_chat_attachment"("file_url" "text", OUT "status" integer, OUT "content" "text") TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."delete_chat_attachment"("file_url" "text", OUT "status" integer, OUT "content" "text") TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."delete_chat_attachment"("file_url" "text", OUT "status" integer, OUT "content" "text") TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."delete_old_chat_attachment"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."delete_old_chat_attachment"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."delete_old_chat_attachment"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."get_user_notifications"("p_limit" integer, "p_offset" integer, "p_is_read" boolean) TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."get_user_notifications"("p_limit" integer, "p_offset" integer, "p_is_read" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."get_user_notifications"("p_limit" integer, "p_offset" integer, "p_is_read" boolean) TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."handle_department_notification_configs_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."handle_department_notification_configs_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."handle_department_notification_configs_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."handle_new_task_notifications"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."handle_new_task_notifications"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."handle_new_task_notifications"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."handle_notifications_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."handle_notifications_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."handle_notifications_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_chat_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_chat_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_chat_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_chat_files_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_chat_files_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_chat_files_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_checklists_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_checklists_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_checklists_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_comments_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_comments_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_comments_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_conversation_participants_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_conversation_participants_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_conversation_participants_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_progress_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_progress_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_progress_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_sla_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_sla_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."handle_pulse_sla_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."handle_pulses_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."handle_pulses_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."handle_pulses_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."handle_record_deletion"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."handle_record_deletion"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."handle_record_deletion"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."handle_task_assignment_updates"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."handle_task_assignment_updates"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."handle_task_assignment_updates"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."handle_tasks_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."handle_tasks_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."handle_tasks_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."mark_all_notifications_as_read"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."mark_all_notifications_as_read"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."mark_all_notifications_as_read"() TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."mark_notification_as_read"("p_notification_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."mark_notification_as_read"("p_notification_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."mark_notification_as_read"("p_notification_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "mod_pulse"."update_pulse_status"() TO "anon";
GRANT ALL ON FUNCTION "mod_pulse"."update_pulse_status"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_pulse"."update_pulse_status"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."calculate_total_available_stock"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."calculate_total_available_stock"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."calculate_total_available_stock"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."copy_shipment_address_to_item"("p_shipment_item_id" "uuid", "p_address_type" character varying) TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."copy_shipment_address_to_item"("p_shipment_item_id" "uuid", "p_address_type" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."copy_shipment_address_to_item"("p_shipment_item_id" "uuid", "p_address_type" character varying) TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."count_low_stock_items"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."count_low_stock_items"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."count_low_stock_items"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."count_out_of_stock_items"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."count_out_of_stock_items"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."count_out_of_stock_items"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."debug_relocation_movement"("p_article_id" "uuid", "p_from_location_id" "uuid", "p_to_location_id" "uuid", "p_batch_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."debug_relocation_movement"("p_article_id" "uuid", "p_from_location_id" "uuid", "p_to_location_id" "uuid", "p_batch_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."debug_relocation_movement"("p_article_id" "uuid", "p_from_location_id" "uuid", "p_to_location_id" "uuid", "p_batch_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."delete_item_address"("p_address_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."delete_item_address"("p_address_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."delete_item_address"("p_address_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."generate_unique_receipt_number"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."generate_unique_receipt_number"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."generate_unique_receipt_number"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."get_historical_inventory_stats"("target_date" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."get_historical_inventory_stats"("target_date" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."get_historical_inventory_stats"("target_date" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."get_item_all_addresses"("p_shipment_item_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."get_item_all_addresses"("p_shipment_item_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."get_item_all_addresses"("p_shipment_item_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."get_item_primary_address"("p_shipment_item_id" "uuid", "p_address_type" character varying) TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."get_item_primary_address"("p_shipment_item_id" "uuid", "p_address_type" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."get_item_primary_address"("p_shipment_item_id" "uuid", "p_address_type" character varying) TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_article_components_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_article_components_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_article_components_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_batches_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_batches_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_batches_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_inbound_stock_movement"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_inbound_stock_movement"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_inbound_stock_movement"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_inventory_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_inventory_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_inventory_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_inventory_limits_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_inventory_limits_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_inventory_limits_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_loading_stock_movement"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_loading_stock_movement"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_loading_stock_movement"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_locations_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_locations_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_locations_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_original_receipt_item_id"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_original_receipt_item_id"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_original_receipt_item_id"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_outbound_unloading_stock_movement"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_outbound_unloading_stock_movement"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_outbound_unloading_stock_movement"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_receipt_items_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_receipt_items_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_receipt_items_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_receipt_items_inbound_on_insert"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_receipt_items_inbound_on_insert"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_receipt_items_inbound_on_insert"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_receipts_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_receipts_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_receipts_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_relocation_stock_movement"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_relocation_stock_movement"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_relocation_stock_movement"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_shipment_items_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_shipment_items_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_shipment_items_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_shipments_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_shipments_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_shipments_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_shipments_outbound_on_status_change"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_shipments_outbound_on_status_change"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_shipments_outbound_on_status_change"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_stock_movements_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_stock_movements_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_stock_movements_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_transport_stock_movement"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_transport_stock_movement"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_transport_stock_movement"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_update_sales_order_items_is_shipped_on_loaded"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_update_sales_order_items_is_shipped_on_loaded"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_update_sales_order_items_is_shipped_on_loaded"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."handle_warehouses_audit"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."handle_warehouses_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."handle_warehouses_audit"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."receipt_items_notification_for_serena"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."receipt_items_notification_for_serena"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."receipt_items_notification_for_serena"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."set_receipt_number_on_insert"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."set_receipt_number_on_insert"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."set_receipt_number_on_insert"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."update_sales_order_items_has_shipment"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."update_sales_order_items_has_shipment"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."update_sales_order_items_has_shipment"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."update_shipment_attachments_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."update_shipment_attachments_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."update_shipment_attachments_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."update_shipment_item_addresses_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."update_shipment_item_addresses_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."update_shipment_item_addresses_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."update_shipment_sales_orders_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."update_shipment_sales_orders_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."update_shipment_sales_orders_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "mod_wms"."upsert_item_address"("p_shipment_item_id" "uuid", "p_address_type" character varying, "p_address" "text", "p_city" "text", "p_state" "text", "p_zip" "text", "p_country" "text", "p_province" "text", "p_is_primary" boolean, "p_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "mod_wms"."upsert_item_address"("p_shipment_item_id" "uuid", "p_address_type" character varying, "p_address" "text", "p_city" "text", "p_state" "text", "p_zip" "text", "p_country" "text", "p_province" "text", "p_is_primary" boolean, "p_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "mod_wms"."upsert_item_address"("p_shipment_item_id" "uuid", "p_address_type" character varying, "p_address" "text", "p_city" "text", "p_state" "text", "p_zip" "text", "p_country" "text", "p_province" "text", "p_is_primary" boolean, "p_notes" "text") TO "service_role";












GRANT ALL ON FUNCTION "public"."add_article_related_search_results"("search_query" "text", "limit_count" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."add_article_related_search_results"("search_query" "text", "limit_count" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."add_article_related_search_results"("search_query" "text", "limit_count" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."check_user_sales_orders_access"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_user_sales_orders_access"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_user_sales_orders_access"() TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_claim"("uid" "uuid", "claim" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_claim"("uid" "uuid", "claim" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_claim"("uid" "uuid", "claim" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_unique_receipt_number"() TO "anon";
GRANT ALL ON FUNCTION "public"."generate_unique_receipt_number"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_unique_receipt_number"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_active_departments"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_active_departments"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_active_departments"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_claim"("uid" "uuid", "claim" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_claim"("uid" "uuid", "claim" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_claim"("uid" "uuid", "claim" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_claims"("uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_claims"("uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_claims"("uid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_employees_with_details"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_employees_with_details"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_employees_with_details"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_jwt_claim_domain_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_jwt_claim_domain_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_jwt_claim_domain_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_claim"("claim" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_claim"("claim" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_claim"("claim" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_claim_text"("claim" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_claim_text"("claim" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_claim_text"("claim" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_claims"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_claims"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_claims"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_search_suggestions"("search_query" "text", "limit_count" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_search_suggestions"("search_query" "text", "limit_count" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_search_suggestions"("search_query" "text", "limit_count" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_notifications"("p_limit" integer, "p_offset" integer, "p_is_read" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_notifications"("p_limit" integer, "p_offset" integer, "p_is_read" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_notifications"("p_limit" integer, "p_offset" integer, "p_is_read" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_page_access"("user_department_ids" "uuid"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_page_access"("user_department_ids" "uuid"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_page_access"("user_department_ids" "uuid"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."global_search"("search_query" "text", "limit_count" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."global_search"("search_query" "text", "limit_count" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."global_search"("search_query" "text", "limit_count" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."is_claims_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_claims_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_claims_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."mark_all_notifications_as_read"() TO "anon";
GRANT ALL ON FUNCTION "public"."mark_all_notifications_as_read"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."mark_all_notifications_as_read"() TO "service_role";



GRANT ALL ON FUNCTION "public"."mark_notification_as_read"("p_notification_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."mark_notification_as_read"("p_notification_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."mark_notification_as_read"("p_notification_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."my_set_config"("key" "text", "value" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."my_set_config"("key" "text", "value" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."my_set_config"("key" "text", "value" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."safe_alter_enum_type"("p_type_name" "text", "p_new_values" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."safe_alter_enum_type"("p_type_name" "text", "p_new_values" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."safe_alter_enum_type"("p_type_name" "text", "p_new_values" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."search_menu_items"("search_query" "text", "domain_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."search_menu_items"("search_query" "text", "domain_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_menu_items"("search_query" "text", "domain_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."set_claim"("uid" "uuid", "claim" "text", "value" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."set_claim"("uid" "uuid", "claim" "text", "value" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_claim"("uid" "uuid", "claim" "text", "value" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."simple_global_search"("search_query" "text", "limit_count" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."simple_global_search"("search_query" "text", "limit_count" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."simple_global_search"("search_query" "text", "limit_count" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."simple_menu_search"("search_query" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."simple_menu_search"("search_query" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."simple_menu_search"("search_query" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."test_search_functions"() TO "anon";
GRANT ALL ON FUNCTION "public"."test_search_functions"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."test_search_functions"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_expected_delivery_date"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_expected_delivery_date"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_expected_delivery_date"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_receipt_supplier_from_po"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_receipt_supplier_from_po"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_receipt_supplier_from_po"() TO "service_role";



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



GRANT ALL ON SEQUENCE "app_auth"."employees_code_seq" TO "supabase_auth_admin";
GRANT ALL ON SEQUENCE "app_auth"."employees_code_seq" TO "dashboard_user";



GRANT ALL ON SEQUENCE "app_auth"."user_profiles_code_seq" TO "supabase_auth_admin";
GRANT ALL ON SEQUENCE "app_auth"."user_profiles_code_seq" TO "dashboard_user";









GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_admin"."domain_modules" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_admin"."domain_modules" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_admin"."domain_modules" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_admin"."domain_users" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_admin"."domain_users" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_admin"."domain_users" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_admin"."domains" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_admin"."domains" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_admin"."domains" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_admin"."user_profiles" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_admin"."user_profiles" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_admin"."user_profiles" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_admin"."user_domain_info_view" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_admin"."user_domain_info_view" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_admin"."user_domain_info_view" TO "service_role";



GRANT ALL ON SEQUENCE "mod_admin"."user_profiles_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_admin"."user_profiles_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_admin"."user_profiles_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."announcements" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."announcements" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."announcements" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."article_categories" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."article_categories" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."article_categories" TO "service_role";



GRANT ALL ON SEQUENCE "mod_base"."article_categories_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_base"."article_categories_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_base"."article_categories_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."articles" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."articles" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."articles" TO "service_role";



GRANT ALL ON SEQUENCE "mod_base"."articles_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_base"."articles_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_base"."articles_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."bom_articles" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."bom_articles" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."bom_articles" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."custom_article_attachments" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."custom_article_attachments" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."custom_article_attachments" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."customer_addresses" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."customer_addresses" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."customer_addresses" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."customers" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."customers" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."customers" TO "service_role";



GRANT ALL ON SEQUENCE "mod_base"."customers_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_base"."customers_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_base"."customers_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."departments" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."departments" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."departments" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."employees" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."employees" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."employees" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."employees_departments" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."employees_departments" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."employees_departments" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."internal_sales_order_items" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."internal_sales_order_items" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."internal_sales_order_items" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."internal_sales_order_items_stats" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."internal_sales_order_items_stats" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."internal_sales_order_items_stats" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."internal_sales_orders" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."internal_sales_orders" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."internal_sales_orders" TO "service_role";



GRANT ALL ON SEQUENCE "mod_base"."internal_sales_orders_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_base"."internal_sales_orders_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_base"."internal_sales_orders_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."internal_sales_orders_stats" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."internal_sales_orders_stats" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."internal_sales_orders_stats" TO "service_role";



GRANT ALL ON SEQUENCE "mod_base"."notifications_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_base"."notifications_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_base"."notifications_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."profiles" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."profiles" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."profiles" TO "service_role";



GRANT ALL ON SEQUENCE "mod_base"."pulses_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_base"."pulses_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_base"."pulses_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."purchase_order_items" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."purchase_order_items" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."purchase_order_items" TO "service_role";



GRANT ALL ON SEQUENCE "mod_base"."purchase_order_items_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_base"."purchase_order_items_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_base"."purchase_order_items_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."purchase_orders" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."purchase_orders" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."purchase_orders" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."suppliers" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."suppliers" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."suppliers" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."purchase_order_qc_tracking" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."purchase_order_qc_tracking" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."purchase_order_qc_tracking" TO "service_role";



GRANT ALL ON SEQUENCE "mod_base"."purchase_orders_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_base"."purchase_orders_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_base"."purchase_orders_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_attachments" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_attachments" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_attachments" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_checklist_results" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_checklist_results" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_checklist_results" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_checklist_summary" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_checklist_summary" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_checklist_summary" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_summary" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_summary" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_summary" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_types" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_types" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_types" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_types_duplicate" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_types_duplicate" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."quality_control_types_duplicate" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."report_template" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."report_template" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."report_template" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."sales_order_items" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."sales_order_items" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."sales_order_items" TO "service_role";



GRANT ALL ON SEQUENCE "mod_base"."sales_order_items_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_base"."sales_order_items_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_base"."sales_order_items_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."sales_orders" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."sales_orders" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."sales_orders" TO "service_role";



GRANT ALL ON SEQUENCE "mod_base"."sales_orders_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_base"."sales_orders_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_base"."sales_orders_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."sales_orders_stats" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."sales_orders_stats" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."sales_orders_stats" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."serial_number_counters" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."serial_number_counters" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."serial_number_counters" TO "service_role";



GRANT ALL ON SEQUENCE "mod_base"."suppliers_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_base"."suppliers_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_base"."suppliers_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."units_of_measure" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."units_of_measure" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_base"."units_of_measure" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."fields" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."fields" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."fields" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."main_menu" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."main_menu" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."main_menu" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."modules" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."modules" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."modules" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."page_categories" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."page_categories" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."page_categories" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."pages" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."pages" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."pages" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."pages_departments" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."pages_departments" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."pages_departments" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."pages_menu_departments" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."pages_menu_departments" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."pages_menu_departments" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."tables" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."tables" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_datalayer"."tables" TO "service_role";



GRANT ALL ON SEQUENCE "mod_datalayer"."user_profiles_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_datalayer"."user_profiles_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_datalayer"."user_profiles_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."coil_consumption" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."coil_consumption" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."coil_consumption" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."coil_production_plans" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."coil_production_plans" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."coil_production_plans" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."coils" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."coils" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."coils" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."departments" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."departments" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."departments" TO "service_role";



GRANT ALL ON SEQUENCE "mod_manufacturing"."departments_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_manufacturing"."departments_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_manufacturing"."departments_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."locations" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."locations" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."locations" TO "service_role";



GRANT ALL ON SEQUENCE "mod_manufacturing"."notifications_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_manufacturing"."notifications_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_manufacturing"."notifications_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."plate_templates" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."plate_templates" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."plate_templates" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."production_logs" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."production_logs" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."production_logs" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."recipes" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."recipes" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."recipes" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."scheduled_items" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."scheduled_items" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."scheduled_items" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_cycle_categories" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_cycle_categories" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_cycle_categories" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_cycles" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_cycles" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_cycles" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_flows" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_flows" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_flows" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_flows_work_cycles" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_flows_work_cycles" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_flows_work_cycles" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_order_attachments" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_order_attachments" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_order_attachments" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_order_quality_summary" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_order_quality_summary" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_order_quality_summary" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_orders" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_orders" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_orders" TO "service_role";



GRANT ALL ON SEQUENCE "mod_manufacturing"."work_orders_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_manufacturing"."work_orders_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_manufacturing"."work_orders_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_steps" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_steps" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."work_steps" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."workstations" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."workstations" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."workstations" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."workstations_duplicate" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."workstations_duplicate" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_manufacturing"."workstations_duplicate" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."department_notification_configs" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."department_notification_configs" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."department_notification_configs" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."notifications" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."notifications" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."notifications" TO "service_role";



GRANT ALL ON SEQUENCE "mod_pulse"."notifications_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_pulse"."notifications_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_pulse"."notifications_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_chat" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_chat" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_chat" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_chat_files" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_chat_files" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_chat_files" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_checklists" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_checklists" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_checklists" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_comments" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_comments" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_comments" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_conversation_participants" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_conversation_participants" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_conversation_participants" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_progress" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_progress" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_progress" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_slas" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_slas" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulse_slas" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulses" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulses" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."pulses" TO "service_role";



GRANT ALL ON SEQUENCE "mod_pulse"."pulses_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_pulse"."pulses_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_pulse"."pulses_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."tasks" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."tasks" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_pulse"."tasks" TO "service_role";



GRANT ALL ON SEQUENCE "mod_pulse"."tasks_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_pulse"."tasks_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_pulse"."tasks_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."batches" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."batches" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."batches" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."box_contents" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."box_contents" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."box_contents" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."box_types" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."box_types" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."box_types" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."carton_contents" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."carton_contents" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."carton_contents" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."carton_types" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."carton_types" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."carton_types" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."locations" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."locations" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."locations" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."stock_movements" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."stock_movements" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."stock_movements" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."current_inventory" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."current_inventory" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."current_inventory" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."inventory" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."inventory" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."inventory" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."inventory_backup" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."inventory_backup" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."inventory_backup" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."inventory_limits" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."inventory_limits" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."inventory_limits" TO "service_role";



GRANT ALL ON SEQUENCE "mod_wms"."notifications_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_wms"."notifications_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_wms"."notifications_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."pallet_contents" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."pallet_contents" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."pallet_contents" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."pallet_types" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."pallet_types" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."pallet_types" TO "service_role";



GRANT ALL ON SEQUENCE "mod_wms"."pulses_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_wms"."pulses_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_wms"."pulses_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."receipt_items" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."receipt_items" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."receipt_items" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."receipts" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."receipts" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."receipts" TO "service_role";



GRANT ALL ON SEQUENCE "mod_wms"."receipts_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_wms"."receipts_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_wms"."receipts_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_attachments" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_attachments" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_attachments" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_boxes" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_boxes" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_boxes" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_cartons" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_cartons" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_cartons" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_item_addresses" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_item_addresses" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_item_addresses" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_items" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_items" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_items" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_pallets" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_pallets" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_pallets" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_sales_orders" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_sales_orders" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_sales_orders" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_standalone_items" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_standalone_items" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipment_standalone_items" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipments" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipments" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."shipments" TO "service_role";



GRANT ALL ON SEQUENCE "mod_wms"."shipments_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "mod_wms"."shipments_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "mod_wms"."shipments_code_seq" TO "service_role";



GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."warehouses" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."warehouses" TO "authenticated";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE "mod_wms"."warehouses" TO "service_role";












GRANT ALL ON SEQUENCE "public"."batches_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."batches_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."batches_code_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."customers_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."customers_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."customers_code_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."departments_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."departments_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."departments_code_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."employees_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."employees_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."employees_code_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."locations_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."locations_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."locations_code_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."notifications_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."notifications_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."notifications_code_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."pulses_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."pulses_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."pulses_code_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."receipt_items_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."receipt_items_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."receipt_items_code_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."receipts_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."receipts_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."receipts_code_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."user_profiles_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."user_profiles_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."user_profiles_code_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."work_cycles_code_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."work_cycles_code_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."work_cycles_code_seq" TO "service_role";



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_admin" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_admin" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_admin" GRANT ALL ON SEQUENCES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_admin" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_admin" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_admin" GRANT ALL ON FUNCTIONS TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_admin" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_admin" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_admin" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_base" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_base" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_base" GRANT ALL ON SEQUENCES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_base" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_base" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_base" GRANT ALL ON FUNCTIONS TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_base" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_base" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_base" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_crm" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_crm" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_crm" GRANT ALL ON SEQUENCES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_crm" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_crm" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_crm" GRANT ALL ON FUNCTIONS TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_crm" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_crm" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_crm" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_datalayer" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_datalayer" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_datalayer" GRANT ALL ON SEQUENCES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_datalayer" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_datalayer" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_datalayer" GRANT ALL ON FUNCTIONS TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_datalayer" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_datalayer" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_datalayer" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_home" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_home" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_home" GRANT ALL ON SEQUENCES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_home" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_home" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_home" GRANT ALL ON FUNCTIONS TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_home" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_home" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_home" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_hr" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_hr" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_hr" GRANT ALL ON SEQUENCES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_hr" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_hr" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_hr" GRANT ALL ON FUNCTIONS TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_hr" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_hr" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_hr" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_manufacturing" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_manufacturing" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_manufacturing" GRANT ALL ON SEQUENCES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_manufacturing" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_manufacturing" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_manufacturing" GRANT ALL ON FUNCTIONS TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_manufacturing" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_manufacturing" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_manufacturing" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_pulse" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_pulse" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_pulse" GRANT ALL ON SEQUENCES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_pulse" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_pulse" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_pulse" GRANT ALL ON FUNCTIONS TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_pulse" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_pulse" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_pulse" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_wms" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_wms" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_wms" GRANT ALL ON SEQUENCES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_wms" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_wms" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_wms" GRANT ALL ON FUNCTIONS TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_wms" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_wms" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "mod_wms" GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";
































  create policy "Allow anonymous user creation"
  on "auth"."users"
  as permissive
  for insert
  to public
with check (true);



  create policy "Users can view their own data"
  on "auth"."users"
  as permissive
  for select
  to public
using ((auth.uid() = id));


CREATE TRIGGER before_delete_user BEFORE DELETE ON auth.users FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_profile();

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION mod_admin.handle_new_user();

CREATE TRIGGER on_auth_user_deleted BEFORE DELETE ON auth.users FOR EACH ROW EXECUTE FUNCTION mod_admin.handle_user_deletion();


  create policy "Anyone can upload a background image."
  on "storage"."objects"
  as permissive
  for insert
  to public
with check ((bucket_id = 'background_images'::text));



  create policy "Anyone can upload an avatar."
  on "storage"."objects"
  as permissive
  for insert
  to public
with check ((bucket_id = 'avatars'::text));



  create policy "Authenticated users can upload chat attachments"
  on "storage"."objects"
  as permissive
  for insert
  to public
with check (((bucket_id = 'chat_attachments'::text) AND (auth.role() = 'authenticated'::text)));



  create policy "Authenticated users can upload chat attachments."
  on "storage"."objects"
  as permissive
  for insert
  to public
with check (((bucket_id = 'chat_attachments'::text) AND (auth.role() = 'authenticated'::text)));



  create policy "Authenticated users can upload custom article attachments"
  on "storage"."objects"
  as permissive
  for insert
  to public
with check (((bucket_id = 'custom_article_attachments'::text) AND (auth.role() = 'authenticated'::text)));



  create policy "Authenticated users can upload quality control attachments"
  on "storage"."objects"
  as permissive
  for insert
  to public
with check (((bucket_id = 'quality_control_attachment'::text) AND (auth.role() = 'authenticated'::text)));



  create policy "Authenticated users can upload work order attachments"
  on "storage"."objects"
  as permissive
  for insert
  to public
with check (((bucket_id = 'work_order_attachments'::text) AND (auth.role() = 'authenticated'::text)));



  create policy "Avatar images are publicly accessible."
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'avatars'::text));



  create policy "Background images are publicly accessible."
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'background_images'::text));



  create policy "Chat attachments are publicly accessible"
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'chat_attachments'::text));



  create policy "Chat attachments are publicly accessible."
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'chat_attachments'::text));



  create policy "Only authenticated users can view custom article attachments"
  on "storage"."objects"
  as permissive
  for select
  to public
using (((bucket_id = 'custom_article_attachments'::text) AND (auth.role() = 'authenticated'::text)));



  create policy "Only authenticated users can view quality control attachments"
  on "storage"."objects"
  as permissive
  for select
  to public
using (((bucket_id = 'quality_control_attachment'::text) AND (auth.role() = 'authenticated'::text)));



  create policy "Only authenticated users can view work order attachments"
  on "storage"."objects"
  as permissive
  for select
  to public
using (((bucket_id = 'work_order_attachments'::text) AND (auth.role() = 'authenticated'::text)));



  create policy "Users can delete their own chat attachments"
  on "storage"."objects"
  as permissive
  for delete
  to public
using (((bucket_id = 'chat_attachments'::text) AND (auth.uid() = owner)));



  create policy "Users can delete their own chat attachments."
  on "storage"."objects"
  as permissive
  for delete
  to public
using (((bucket_id = 'chat_attachments'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));



  create policy "Users can delete their own custom article attachments"
  on "storage"."objects"
  as permissive
  for delete
  to public
using (((bucket_id = 'custom_article_attachments'::text) AND (auth.uid() = owner)));



  create policy "Users can delete their own quality control attachments"
  on "storage"."objects"
  as permissive
  for delete
  to public
using (((bucket_id = 'quality_control_attachment'::text) AND (auth.uid() = owner)));



  create policy "Users can delete their own work order attachments"
  on "storage"."objects"
  as permissive
  for delete
  to public
using (((bucket_id = 'work_order_attachments'::text) AND (auth.uid() = owner)));



  create policy "Users can update their own chat attachments"
  on "storage"."objects"
  as permissive
  for update
  to public
using (((bucket_id = 'chat_attachments'::text) AND (auth.uid() = owner)));



  create policy "Users can update their own chat attachments."
  on "storage"."objects"
  as permissive
  for update
  to public
using (((bucket_id = 'chat_attachments'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));



  create policy "Users can update their own custom article attachments"
  on "storage"."objects"
  as permissive
  for update
  to public
using (((bucket_id = 'custom_article_attachments'::text) AND (auth.uid() = owner)));



  create policy "Users can update their own quality control attachments"
  on "storage"."objects"
  as permissive
  for update
  to public
using (((bucket_id = 'quality_control_attachment'::text) AND (auth.uid() = owner)));



  create policy "Users can update their own work order attachments"
  on "storage"."objects"
  as permissive
  for update
  to public
using (((bucket_id = 'work_order_attachments'::text) AND (auth.uid() = owner)));



