create extension if not exists "http" with schema "extensions";

create extension if not exists "pgjwt" with schema "extensions";

create schema if not exists "app_auth";

create schema if not exists "common";

create schema if not exists "mod_admin";

create schema if not exists "mod_base";

create schema if not exists "mod_crm";

create schema if not exists "mod_datalayer";

create schema if not exists "mod_home";

create schema if not exists "mod_hr";

create schema if not exists "mod_manufacturing";

create schema if not exists "mod_pulse";

create schema if not exists "mod_quality_control";

create schema if not exists "mod_wms";

create type "public"."defect_severity_type" as enum ('MINOR', 'MAJOR', 'CRITICAL');

create type "public"."qc_status_type" as enum ('PLANNED', 'IN_PROGRESS', 'PASSED', 'FAILED', 'HOLD', 'PENDING_REVIEW', 'CONDITIONALLY_ACCEPTED', 'REJECTED');

create type "public"."return_status_type" as enum ('PENDING', 'APPROVED', 'REJECTED', 'IN_TRANSIT', 'RECEIVED_BY_SUPPLIER', 'CREDIT_ISSUED', 'REPLACEMENT_SENT', 'CLOSED');

create sequence "app_auth"."employees_code_seq";

create sequence "app_auth"."user_profiles_code_seq";

create sequence "mod_admin"."user_profiles_code_seq";

create sequence "mod_base"."article_categories_code_seq";

create sequence "mod_base"."articles_code_seq";

create sequence "mod_base"."customers_code_seq";

create sequence "mod_base"."internal_sales_orders_code_seq";

create sequence "mod_base"."notifications_code_seq";

create sequence "mod_base"."pulses_code_seq";

create sequence "mod_base"."purchase_order_items_code_seq";

create sequence "mod_base"."purchase_orders_code_seq";

create sequence "mod_base"."sales_order_items_code_seq";

create sequence "mod_base"."sales_orders_code_seq";

create sequence "mod_base"."suppliers_code_seq";

create sequence "mod_datalayer"."user_profiles_code_seq";

create sequence "mod_manufacturing"."departments_code_seq";

create sequence "mod_manufacturing"."notifications_code_seq";

create sequence "mod_manufacturing"."work_orders_code_seq";

create sequence "mod_pulse"."notifications_code_seq";

create sequence "mod_pulse"."pulses_code_seq";

create sequence "mod_pulse"."tasks_code_seq";

create sequence "mod_wms"."inventory_limits_code_seq";

create sequence "mod_wms"."notifications_code_seq";

create sequence "mod_wms"."pulses_code_seq";

create sequence "mod_wms"."receipts_code_seq";

create sequence "mod_wms"."shipments_code_seq";

create sequence "public"."batches_code_seq";

create sequence "public"."customers_code_seq";

create sequence "public"."departments_code_seq";

create sequence "public"."employees_code_seq";

create sequence "public"."locations_code_seq";

create sequence "public"."notifications_code_seq";

create sequence "public"."pulses_code_seq";

create sequence "public"."receipt_items_code_seq";

create sequence "public"."receipts_code_seq";

create sequence "public"."user_profiles_code_seq";

create sequence "public"."work_cycles_code_seq";


  create table "mod_admin"."domain_modules" (
    "id" uuid not null default gen_random_uuid(),
    "domain_id" uuid not null,
    "module_id" uuid not null,
    "is_enabled" boolean not null default true,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_admin"."domain_modules" enable row level security;


  create table "mod_admin"."domain_users" (
    "user_id" uuid not null,
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "role" text not null,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_admin"."domain_users" enable row level security;


  create table "mod_admin"."domains" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "key" text not null,
    "description" text,
    "modules" text not null,
    "productName" text not null,
    "productDescription" text not null,
    "folder" text not null,
    "sort" integer not null default 0,
    "deployable" boolean default false,
    "deployUrl" text,
    "parent_domain_id" uuid,
    "avatar_url" text,
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((((((COALESCE(name, ''::text) || ' '::text) || COALESCE(key, ''::text)) || ' '::text) || COALESCE(description, ''::text)) || ' '::text) || COALESCE("productName", ''::text)) || ' '::text) || COALESCE("productDescription", ''::text)))) stored
      );


alter table "mod_admin"."domains" enable row level security;


  create table "mod_admin"."user_profiles" (
    "id" uuid not null default gen_random_uuid(),
    "firstName" text default '-'::text,
    "lastName" text default '-'::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "phone" text not null default ''::text,
    "mobile" text not null default ''::text,
    "company" text not null default ''::text,
    "contact" text not null default ''::text,
    "enabled" boolean default false,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "background_image_url" text not null default ''::text,
    "address" text default ''::text,
    "city" text default ''::text,
    "province" text default ''::text,
    "zip_code" text default ''::text,
    "country" text default ''::text,
    "button_color" text not null default 'primary'::text,
    "theme_mode" text not null default 'auto'::text,
    "custom_primary_color" text,
    "custom_secondary_color" text,
    "custom_tertiary_color" text,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((((((((COALESCE("firstName", ''::text) || ' '::text) || COALESCE("lastName", ''::text)) || ' '::text) || COALESCE(phone, ''::text)) || ' '::text) || COALESCE(mobile, ''::text)) || ' '::text) || COALESCE(company, ''::text)) || ' '::text) || COALESCE(description, ''::text)))) stored,
    "sidebar_right_open" boolean not null default true
      );


alter table "mod_admin"."user_profiles" enable row level security;


  create table "mod_base"."announcements" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "title" text not null default ''::text,
    "content" text not null default ''::text,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid,
    "shared_with" text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_base"."announcements" enable row level security;


  create table "mod_base"."article_categories" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "color" text default '#808080'::text
      );


alter table "mod_base"."article_categories" enable row level security;


  create table "mod_base"."articles" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "sku" text not null,
    "category_id" uuid,
    "article_type" text,
    "unit_of_measure_id" uuid,
    "current_weight" numeric(12,4) default 0,
    "current_length" numeric(12,4) default 0,
    "width" numeric(12,4) default 0,
    "height" numeric(12,4) default 0,
    "cost" numeric(12,4) default 0,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "load_weight" numeric(12,4) default NULL::numeric,
    "allocated_weight" numeric(12,4) default NULL::numeric,
    "load_length" numeric(12,4) default NULL::numeric,
    "committed_length" numeric(12,4) default NULL::numeric,
    "transaction_type" text default 'internal'::text,
    "type" character varying(50),
    "parent_article_id" uuid,
    "heat_exchanger_model" character varying(50),
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((((((COALESCE(name, ''::text) || ' '::text) || COALESCE(code, ''::text)) || ' '::text) || COALESCE(description, ''::text)) || ' '::text) || COALESCE(sku, ''::text)) || ' '::text) || COALESCE(article_type, ''::text)))) stored,
    "material_name" text default ''::text,
    "tech_code" text default ''::text,
    "sales_code" text default ''::text,
    "min_stock" integer,
    "max_stock" integer
      );


alter table "mod_base"."articles" enable row level security;


  create table "mod_base"."bom_articles" (
    "id" uuid not null default gen_random_uuid(),
    "parent_article_id" uuid not null,
    "component_article_id" uuid not null,
    "quantity" integer not null default 1,
    "position" integer,
    "note" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((COALESCE(note, ''::text) || ' '::text) || COALESCE((quantity)::text, ''::text)) || ' '::text) || COALESCE(("position")::text, ''::text)))) stored
      );


alter table "mod_base"."bom_articles" enable row level security;


  create table "mod_base"."custom_article_attachments" (
    "id" uuid not null default gen_random_uuid(),
    "sales_order_id" uuid,
    "file_url" text not null,
    "file_name" text not null,
    "file_size" bigint not null,
    "file_type" text not null,
    "article_id" uuid,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((COALESCE(file_name, ''::text) || ' '::text) || COALESCE(file_type, ''::text)))) stored,
    "internal_sales_order_id" uuid
      );


alter table "mod_base"."custom_article_attachments" enable row level security;


  create table "mod_base"."customer_addresses" (
    "id" uuid not null default gen_random_uuid(),
    "customer_id" uuid not null,
    "address_type" text not null default 'general'::text,
    "is_primary" boolean not null default false,
    "address_line_1" text not null default ''::text,
    "address_line_2" text default ''::text,
    "city" text not null default ''::text,
    "state" text default ''::text,
    "province" text default ''::text,
    "zip" text default ''::text,
    "country" text default ''::text,
    "phone" text default ''::text,
    "contact_name" text default ''::text,
    "notes" text default ''::text,
    "domain_id" uuid not null,
    "shared_with" text[] default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((((((((((((COALESCE(address_line_1, ''::text) || ' '::text) || COALESCE(address_line_2, ''::text)) || ' '::text) || COALESCE(city, ''::text)) || ' '::text) || COALESCE(state, ''::text)) || ' '::text) || COALESCE(province, ''::text)) || ' '::text) || COALESCE(country, ''::text)) || ' '::text) || COALESCE(contact_name, ''::text)) || ' '::text) || COALESCE(notes, ''::text)))) stored
      );


alter table "mod_base"."customer_addresses" enable row level security;


  create table "mod_base"."customers" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "contact_name" text not null default ''::text,
    "email" text not null default ''::text,
    "phone" text not null default ''::text,
    "address" text not null default ''::text,
    "zip" text not null default ''::text,
    "city" text not null default ''::text,
    "province" text not null default ''::text,
    "state" text not null default ''::text,
    "country" text not null default ''::text,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "delivery_address" text,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((((((((((((COALESCE(name, ''::text) || ' '::text) || COALESCE(code, ''::text)) || ' '::text) || COALESCE(email, ''::text)) || ' '::text) || COALESCE(phone, ''::text)) || ' '::text) || COALESCE(contact_name, ''::text)) || ' '::text) || COALESCE(address, ''::text)) || ' '::text) || COALESCE(city, ''::text)) || ' '::text) || COALESCE(country, ''::text)))) stored,
    "vat_number" text not null default ''::text,
    "fiscal_code" text not null default ''::text,
    "cell" text not null default ''::text,
    "pec" text not null default ''::text,
    "payment_terms" text not null default ''::text,
    "agent" text not null default ''::text
      );


alter table "mod_base"."customers" enable row level security;


  create table "mod_base"."departments" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_base"."departments" enable row level security;


  create table "mod_base"."employees" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "last_name" text not null default ''::text,
    "phone" text not null default ''::text,
    "badge" text not null default ''::text,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_base"."employees" enable row level security;


  create table "mod_base"."employees_departments" (
    "employee_id" uuid not null,
    "department_id" uuid not null,
    "role" text not null,
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_base"."employees_departments" enable row level security;


  create table "mod_base"."internal_sales_order_items" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "sales_order_id" uuid not null,
    "article_id" uuid not null,
    "quantity_ordered" numeric(12,4) not null,
    "quantity_allocated" numeric(12,4) not null default 0,
    "quantity_delivered" numeric(12,4) not null default 0,
    "unit_price" numeric(12,4) not null default 0,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "is_recipe" boolean default false,
    "parent_sales_order_item_id" uuid,
    "custom_instructions" text,
    "production_date" date,
    "is_manufactured" boolean not null default false,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((COALESCE(name, ''::text) || ' '::text) || COALESCE(description, ''::text)))) stored
      );


alter table "mod_base"."internal_sales_order_items" enable row level security;


  create table "mod_base"."internal_sales_orders" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "customer_id" uuid,
    "sales_order_number" text not null default ''::text,
    "order_date" date not null,
    "requested_delivery_date" date,
    "expected_delivery_date" date,
    "status" text,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "production_start_date" date,
    "is_production_complete" boolean default false,
    "total_cost" numeric(15,2) default 0.00,
    "is_archived" boolean not null default false,
    "is_internal" boolean not null default true,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((COALESCE(name, ''::text) || ' '::text) || COALESCE(description, ''::text)))) stored
      );


alter table "mod_base"."internal_sales_orders" enable row level security;


  create table "mod_base"."profiles" (
    "id" uuid not null,
    "fcm_token" text,
    "created_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "updated_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_base"."profiles" enable row level security;


  create table "mod_base"."purchase_order_items" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "purchase_order_id" uuid not null,
    "article_id" uuid not null,
    "quantity_ordered" numeric(12,4) not null,
    "quantity_received" numeric(12,4) not null default 0,
    "unit_price" numeric(12,4) not null default 0,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "quantity_defect" integer not null default 0,
    "is_completed" boolean not null default false,
    "is_quantity_moved" boolean default false,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((COALESCE(name, ''::text) || ' '::text) || COALESCE(code, ''::text)) || ' '::text) || COALESCE(description, ''::text)))) stored
      );


alter table "mod_base"."purchase_order_items" enable row level security;


  create table "mod_base"."purchase_orders" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "supplier_id" uuid not null,
    "purchase_order_number" text not null default ''::text,
    "order_date" date not null,
    "expected_delivery_date" date,
    "status" text,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((((((COALESCE(name, ''::text) || ' '::text) || COALESCE(code, ''::text)) || ' '::text) || COALESCE(purchase_order_number, ''::text)) || ' '::text) || COALESCE(status, ''::text)) || ' '::text) || COALESCE(description, ''::text)))) stored
      );


alter table "mod_base"."purchase_orders" enable row level security;


  create table "mod_base"."quality_control" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "avatar_url" text not null default ''::text,
    "article_id" uuid,
    "status" text not null,
    "notes" text not null default ''::text,
    "quantity_checked" integer not null default 0,
    "quantity_passed" integer not null default 0,
    "quantity_failed" integer not null default 0,
    "domain_id" uuid,
    "shared_with" text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "work_order_id" uuid,
    "quality_control_type_id" uuid,
    "planned_date" timestamp with time zone,
    "started_date" timestamp with time zone,
    "completed_date" timestamp with time zone,
    "inspector_id" uuid,
    "reference_type" text,
    "reference_id" uuid,
    "batch_number" text,
    "inspection_level" text,
    "sample_size" integer,
    "acceptance_number" integer default 0,
    "rejection_number" integer default 0,
    "temperature" numeric(5,2),
    "humidity" numeric(5,2),
    "measuring_equipment" text[],
    "test_conditions" jsonb default '{}'::jsonb,
    "visual_inspection_result" text,
    "corrective_actions" text,
    "preventive_actions" text,
    "review_notes" text,
    "reviewed_by" uuid,
    "reviewed_at" timestamp with time zone,
    "conformity_documents" jsonb default '{}'::jsonb,
    "certificate_numbers" text[],
    "certificate_expiry_dates" date[],
    "return_required" boolean default false,
    "return_reason" text,
    "return_quantity" integer default 0,
    "purchase_order_item_id" uuid,
    "work_steps_id" uuid,
    "receipt_id" uuid,
    "receipt_item_id" uuid,
    "shipment_id" uuid,
    "article_type" text
      );


alter table "mod_base"."quality_control" enable row level security;


  create table "mod_base"."quality_control_attachments" (
    "id" uuid not null default gen_random_uuid(),
    "quality_control_id" uuid not null,
    "file_url" text not null,
    "file_name" text not null,
    "file_size" bigint not null,
    "file_type" text not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "mod_base"."quality_control_attachments" enable row level security;


  create table "mod_base"."quality_control_checklist_results" (
    "id" uuid not null default gen_random_uuid(),
    "quality_control_id" uuid not null,
    "checklist_item" text not null,
    "result" boolean not null,
    "notes" text,
    "domain_id" uuid not null default ((auth.jwt() ->> 'domain_id'::text))::uuid,
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "created_by" uuid default auth.uid(),
    "updated_at" timestamp with time zone default now(),
    "updated_by" uuid default auth.uid()
      );


alter table "mod_base"."quality_control_checklist_results" enable row level security;


  create table "mod_base"."quality_control_types" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "article_type" text default ''::text,
    "is_required" boolean default false,
    "is_active" boolean default true,
    "test_specifications" jsonb default '{}'::jsonb,
    "acceptance_criteria" jsonb default '{}'::jsonb,
    "checklist_items" text[] default ARRAY[]::text[],
    "timing" text default 'final'::text,
    "estimated_duration" interval default '00:30:00'::interval,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid,
    "shared_with" text[] default ARRAY[]::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "work_cycle_id" uuid,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((COALESCE(name, ''::text) || ' '::text) || COALESCE(description, ''::text)))) stored,
    "category_id" uuid
      );


alter table "mod_base"."quality_control_types" enable row level security;


  create table "mod_base"."quality_control_types_duplicate" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "article_type" text default ''::text,
    "is_required" boolean default false,
    "is_active" boolean default true,
    "test_specifications" jsonb default '{}'::jsonb,
    "acceptance_criteria" jsonb default '{}'::jsonb,
    "checklist_items" text[] default ARRAY[]::text[],
    "timing" text default 'final'::text,
    "estimated_duration" interval default '00:30:00'::interval,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid,
    "shared_with" text[] default ARRAY[]::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "work_cycle_id" uuid,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((COALESCE(name, ''::text) || ' '::text) || COALESCE(description, ''::text)))) stored,
    "category_id" uuid
      );


alter table "mod_base"."quality_control_types_duplicate" enable row level security;


  create table "mod_base"."report_template" (
    "id" uuid not null default gen_random_uuid(),
    "report_name" text default '255'::text,
    "template_json_value" json,
    "created_at" timestamp with time zone not null default now(),
    "report_type" integer,
    "archive_type" integer,
    "created_by" uuid,
    "updated_by" uuid,
    "updated_at" timestamp without time zone default now(),
    "domain_id" uuid,
    "shared_with" text[] not null
      );


alter table "mod_base"."report_template" enable row level security;


  create table "mod_base"."sales_order_items" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "sales_order_id" uuid not null,
    "article_id" uuid not null,
    "quantity_ordered" numeric(12,4) not null,
    "quantity_allocated" numeric(12,4) not null default 0,
    "quantity_delivered" numeric(12,4) not null default 0,
    "unit_price" numeric(12,4) not null default 0,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "is_recipe" boolean default false,
    "parent_sales_order_item_id" uuid,
    "custom_instructions" text,
    "production_date" date,
    "is_manufactured" boolean not null default false,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((COALESCE(name, ''::text) || ' '::text) || COALESCE(code, ''::text)) || ' '::text) || COALESCE(description, ''::text)))) stored,
    "serial_number" text,
    "has_shipment" boolean not null default false,
    "is_shipped" boolean not null default false,
    "discount_1" numeric(5,2) default 0,
    "discount_2" numeric(5,2) default 0,
    "note" text
      );


alter table "mod_base"."sales_order_items" enable row level security;


  create table "mod_base"."sales_orders" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "customer_id" uuid,
    "sales_order_number" text not null default ''::text,
    "order_date" date not null,
    "requested_delivery_date" date,
    "expected_delivery_date" date,
    "status" text,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "production_start_date" date,
    "is_production_complete" boolean default false,
    "total_cost" numeric(15,2) default 0.00,
    "is_archived" boolean not null default false,
    "is_internal" boolean not null default false,
    "order_ref" text,
    "customer_order_ref" text,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((((((((((COALESCE(name, ''::text) || ' '::text) || COALESCE(code, ''::text)) || ' '::text) || COALESCE(sales_order_number, ''::text)) || ' '::text) || COALESCE(status, ''::text)) || ' '::text) || COALESCE(description, ''::text)) || ' '::text) || COALESCE(order_ref, ''::text)) || ' '::text) || COALESCE(customer_order_ref, ''::text)))) stored,
    "in_production" boolean not null default false,
    "docs_ready" boolean not null default false
      );


alter table "mod_base"."sales_orders" enable row level security;


  create table "mod_base"."serial_number_counters" (
    "id" uuid not null default gen_random_uuid(),
    "category_id" uuid not null,
    "year" integer not null,
    "last_incremental_number" integer not null default 0,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_base"."serial_number_counters" enable row level security;


  create table "mod_base"."suppliers" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "contact_name" text not null default ''::text,
    "email" text not null default ''::text,
    "phone" text not null default ''::text,
    "address" text not null default ''::text,
    "zip" text not null default ''::text,
    "city" text not null default ''::text,
    "province" text not null default ''::text,
    "state" text not null default ''::text,
    "country" text not null default ''::text,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "vat_cde" text not null default ''::text,
    "sdi_code" text not null default ''::text,
    "pec_email" text not null default ''::text,
    "is_default" boolean not null default false,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((((((((((((COALESCE(name, ''::text) || ' '::text) || COALESCE(code, ''::text)) || ' '::text) || COALESCE(email, ''::text)) || ' '::text) || COALESCE(phone, ''::text)) || ' '::text) || COALESCE(contact_name, ''::text)) || ' '::text) || COALESCE(address, ''::text)) || ' '::text) || COALESCE(city, ''::text)) || ' '::text) || COALESCE(country, ''::text)))) stored,
    "payment_terms" text not null default ''::text
      );


alter table "mod_base"."suppliers" enable row level security;


  create table "mod_base"."units_of_measure" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "symbol" text not null default ''::text,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_base"."units_of_measure" enable row level security;


  create table "mod_datalayer"."fields" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "field_name" text not null default ''::text,
    "label" text not null default ''::text,
    "label_key" text not null default ''::text,
    "description" text not null default ''::text,
    "description_key" text not null default ''::text,
    "icon" text not null default ''::text,
    "sort_order" integer not null default 0,
    "data_type" text not null,
    "is_nullable" boolean,
    "input_type" text not null default 'string'::text,
    "input_placeholder" text not null default ''::text,
    "input_placeholder_key" text not null default ''::text,
    "input_options" jsonb default '[]'::jsonb,
    "input_props" jsonb default '{}'::jsonb,
    "input_class" text default ''::text,
    "input_col" integer default 6,
    "schema_name" text not null,
    "table_name" text not null,
    "avatar_url" text not null default ''::text,
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "is_primary_key" boolean not null default false,
    "is_foreign_key" boolean not null default false,
    "references_schema" text,
    "references_table" text,
    "references_field" text,
    "show_in_card" boolean not null default false,
    "show_in_form" boolean not null default false,
    "show_in_editor" boolean not null default false,
    "show_in_quickview" boolean not null default false,
    "show_in_select" boolean not null default false,
    "show_in_grid" boolean not null default false,
    "show_in_list" boolean not null default false,
    "show_in_filter" boolean not null default false,
    "show_in_kanban" boolean not null default false,
    "show_in_calendar" boolean not null default false,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((((COALESCE(name, ''::text) || ' '::text) || COALESCE(field_name, ''::text)) || ' '::text) || COALESCE(label, ''::text)) || ' '::text) || COALESCE(description, ''::text)))) stored
      );


alter table "mod_datalayer"."fields" enable row level security;


  create table "mod_datalayer"."main_menu" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "code" text not null default ''::text,
    "title" text not null default ''::text,
    "title_key" text not null default ''::text,
    "description" text not null default ''::text,
    "description_key" text not null default ''::text,
    "icon" text not null default ''::text,
    "separator" boolean not null default false,
    "expanded" boolean not null default false,
    "color" text not null default ''::text,
    "sort_order" integer not null default 0,
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((((COALESCE(name, ''::text) || ' '::text) || COALESCE(code, ''::text)) || ' '::text) || COALESCE(title, ''::text)) || ' '::text) || COALESCE(description, ''::text)))) stored
      );


alter table "mod_datalayer"."main_menu" enable row level security;


  create table "mod_datalayer"."modules" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "schema_name" text not null default ''::text,
    "title" text not null default ''::text,
    "title_key" text not null default ''::text,
    "description" text not null default ''::text,
    "description_key" text not null default ''::text,
    "icon" text not null default ''::text,
    "sort_order" integer not null default 0,
    "public_folder" text not null default ''::text,
    "code_folder" text not null default ''::text,
    "enabled" boolean default true,
    "public" boolean default false,
    "owner_domain_id" uuid,
    "avatar_url" text not null default ''::text,
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((((COALESCE(name, ''::text) || ' '::text) || COALESCE(schema_name, ''::text)) || ' '::text) || COALESCE(title, ''::text)) || ' '::text) || COALESCE(description, ''::text)))) stored
      );


alter table "mod_datalayer"."modules" enable row level security;


  create table "mod_datalayer"."page_categories" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "title" text not null default ''::text,
    "titlekey" text not null default ''::text,
    "description" text not null default ''::text,
    "descriptionkey" text not null default ''::text,
    "icon" text not null default ''::text,
    "avatar_url" text not null default ''::text,
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_datalayer"."page_categories" enable row level security;


  create table "mod_datalayer"."pages" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "path" text not null default ''::text,
    "title" text not null default ''::text,
    "titlekey" text not null default ''::text,
    "description" text not null default ''::text,
    "descriptionkey" text not null default ''::text,
    "icon" text not null default ''::text,
    "is_module_home" boolean default false,
    "module_id" uuid not null,
    "page_category_id" uuid,
    "avatar_url" text not null default ''::text,
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "main_menu_id" uuid,
    "is_visible" boolean not null default true,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((((COALESCE(name, ''::text) || ' '::text) || COALESCE(title, ''::text)) || ' '::text) || COALESCE(description, ''::text)) || ' '::text) || COALESCE(path, ''::text)))) stored
      );


alter table "mod_datalayer"."pages" enable row level security;


  create table "mod_datalayer"."pages_departments" (
    "id" uuid not null default gen_random_uuid(),
    "page_id" uuid,
    "department_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "user_id" uuid,
    "is_deleted" boolean not null default false
      );


alter table "mod_datalayer"."pages_departments" enable row level security;


  create table "mod_datalayer"."pages_menu_departments" (
    "id" uuid not null default gen_random_uuid(),
    "page_id" uuid,
    "department_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "user_id" uuid
      );


alter table "mod_datalayer"."pages_menu_departments" enable row level security;


  create table "mod_datalayer"."tables" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "table_name" text not null default ''::text,
    "title" text not null default ''::text,
    "title_key" text not null default ''::text,
    "description" text not null default ''::text,
    "description_key" text not null default ''::text,
    "icon" text not null default ''::text,
    "is_active" boolean default true,
    "sort_order" integer not null default 0,
    "schema_name" text not null,
    "avatar_url" text not null default ''::text,
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "realtime" boolean not null default false,
    "gen_components" boolean not null default false,
    "gen_pages" boolean not null default false,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((((COALESCE(name, ''::text) || ' '::text) || COALESCE(table_name, ''::text)) || ' '::text) || COALESCE(title, ''::text)) || ' '::text) || COALESCE(description, ''::text)))) stored
      );


alter table "mod_datalayer"."tables" enable row level security;


  create table "mod_manufacturing"."coil_consumption" (
    "id" uuid not null default gen_random_uuid(),
    "coil_id" uuid not null,
    "production_plan_id" uuid not null,
    "work_order_id" uuid,
    "consumed_weight_kg" numeric(12,4) not null default 0,
    "consumed_length_m" numeric(12,4) not null default 0,
    "plates_produced" integer not null default 0,
    "waste_weight_kg" numeric(12,4) not null default 0,
    "consumption_date" timestamp without time zone not null default now(),
    "operator_id" uuid,
    "quality_grade" text default 'A'::text,
    "defect_notes" text default ''::text,
    "domain_id" uuid,
    "shared_with" text[] not null default ARRAY[]::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_manufacturing"."coil_consumption" enable row level security;


  create table "mod_manufacturing"."coil_production_plans" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "coil_id" uuid not null,
    "plate_template_id" uuid not null,
    "work_order_id" uuid,
    "planned_quantity" integer not null default 0,
    "committed_quantity" integer not null default 0,
    "produced_quantity" integer not null default 0,
    "planned_start_date" timestamp without time zone,
    "planned_end_date" timestamp without time zone,
    "actual_start_date" timestamp without time zone,
    "actual_end_date" timestamp without time zone,
    "status" text not null default 'planned'::text,
    "priority" integer default 3,
    "quality_notes" text default ''::text,
    "batch_code" text default ''::text,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid,
    "shared_with" text[] not null default ARRAY[]::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_manufacturing"."coil_production_plans" enable row level security;


  create table "mod_manufacturing"."coils" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "coil_number" text not null default ''::text,
    "material_type" text not null default ''::text,
    "thickness" numeric(10,4) not null default 0,
    "width" numeric(10,4) not null default 0,
    "weight_kg" numeric(12,4) not null default 0,
    "length_m" numeric(12,4) default 0,
    "batch_id" uuid,
    "casting_number" text default ''::text,
    "supplier_id" uuid,
    "purchase_date" date,
    "status" text not null default 'received'::text,
    "location_id" uuid,
    "quality_grade" text default 'A'::text,
    "certification_document" text default ''::text,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid,
    "shared_with" text[] not null default ARRAY[]::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_manufacturing"."coils" enable row level security;


  create table "mod_manufacturing"."departments" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_manufacturing"."departments" enable row level security;


  create table "mod_manufacturing"."locations" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "department_id" uuid,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_manufacturing"."locations" enable row level security;


  create table "mod_manufacturing"."plate_templates" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "template_number" text not null default ''::text,
    "plate_type" text not null default ''::text,
    "dimensions_length" numeric(10,4) not null default 0,
    "dimensions_width" numeric(10,4) not null default 0,
    "material_thickness" numeric(10,4) not null default 0,
    "weight_per_plate" numeric(10,4) not null default 0,
    "plates_per_coil_meter" numeric(10,4) not null default 0,
    "waste_factor" numeric(5,4) not null default 0.05,
    "setup_time_minutes" integer default 30,
    "cycle_time_seconds" integer default 60,
    "compatible_materials" text[] not null default ARRAY[]::text[],
    "min_coil_thickness" numeric(10,4) default 0,
    "max_coil_thickness" numeric(10,4) default 0,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid,
    "shared_with" text[] not null default ARRAY[]::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_manufacturing"."plate_templates" enable row level security;


  create table "mod_manufacturing"."production_logs" (
    "id" uuid not null default gen_random_uuid(),
    "work_order_id" uuid not null,
    "work_step_id" uuid not null,
    "operation_number" integer not null,
    "status" text,
    "produced_quantity" integer,
    "rejected_quantity" integer,
    "estimated_duration" interval,
    "actual_duration" interval,
    "started_at" timestamp without time zone not null default now(),
    "completed_at" timestamp without time zone,
    "operator_id" uuid not null,
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_manufacturing"."production_logs" enable row level security;


  create table "mod_manufacturing"."recipes" (
    "id" uuid not null default gen_random_uuid(),
    "finished_product_id" uuid not null,
    "source_article_id" uuid not null,
    "destination_article_id" uuid,
    "sequence_number" integer not null,
    "instructions" text not null default ''::text,
    "estimated_duration" interval,
    "source_article_qty" numeric not null,
    "destination_article_qty" numeric,
    "source_article_uom" text,
    "destination_article_uom" text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid default auth.uid(),
    "updated_by" uuid default auth.uid(),
    "domain_id" uuid,
    "shared_with" text[],
    "is_deleted" boolean not null default false
      );


alter table "mod_manufacturing"."recipes" enable row level security;


  create table "mod_manufacturing"."scheduled_items" (
    "id" uuid not null default gen_random_uuid(),
    "sales_order_item_id" uuid not null,
    "sales_order_id" uuid not null,
    "article_id" uuid not null,
    "scheduled_date" date not null,
    "status" text not null default 'scheduled'::text,
    "domain_id" uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_manufacturing"."scheduled_items" enable row level security;


  create table "mod_manufacturing"."work_cycle_categories" (
    "id" uuid not null default gen_random_uuid(),
    "work_flow_id" uuid not null,
    "work_cycle_id" uuid not null,
    "from_article_category_id" uuid,
    "to_article_category_id" uuid,
    "location_id" uuid,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "mod_manufacturing"."work_cycle_categories" enable row level security;


  create table "mod_manufacturing"."work_cycles" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "sort_order" integer not null,
    "estimated_time" interval,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "type" text,
    "sub_type" text,
    "department_id" uuid,
    "required_for_all" boolean not null default false
      );


alter table "mod_manufacturing"."work_cycles" enable row level security;


  create table "mod_manufacturing"."work_flows" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "mod_manufacturing"."work_flows" enable row level security;


  create table "mod_manufacturing"."work_flows_work_cycles" (
    "id" uuid not null default gen_random_uuid(),
    "work_flow_id" uuid not null,
    "work_cycle_id" uuid not null,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "mod_manufacturing"."work_flows_work_cycles" enable row level security;


  create table "mod_manufacturing"."work_order_attachments" (
    "id" uuid not null default gen_random_uuid(),
    "work_order_id" uuid not null,
    "file_url" text not null,
    "file_name" text not null,
    "file_size" bigint not null,
    "file_type" text not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "mod_manufacturing"."work_order_attachments" enable row level security;


  create table "mod_manufacturing"."work_order_quality_summary" (
    "id" uuid not null default gen_random_uuid(),
    "work_order_id" uuid not null,
    "passed_count" integer not null default 0,
    "failed_count" integer not null default 0,
    "total_count" integer not null default 0,
    "overall_status" text not null default 'PENDING'::text,
    "inspector_notes" text default ''::text,
    "inspector_id" uuid,
    "completed_at" timestamp with time zone,
    "domain_id" uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_manufacturing"."work_order_quality_summary" enable row level security;


  create table "mod_manufacturing"."work_orders" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "article_id" uuid not null,
    "quantity" integer,
    "responsible_id" uuid,
    "status" text,
    "priority" integer default 1,
    "notes" text not null default ''::text,
    "scheduled_start" timestamp without time zone,
    "scheduled_end" timestamp without time zone,
    "actual_start" timestamp without time zone,
    "actual_end" timestamp without time zone,
    "work_cycle_id" uuid,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "sales_order_id" uuid,
    "task_id" uuid,
    "sort_number" integer,
    "article_unloaded" boolean not null default false,
    "article_loaded" boolean not null default false,
    "internal_sales_order_id" uuid,
    "warehouse_id" uuid,
    "location_id" uuid,
    "is_print" boolean not null default false,
    "is_archived" boolean not null default false,
    "need_unload" boolean not null default true,
    "started_by" uuid,
    "paused_by" uuid,
    "completed_by" uuid,
    "started_at" timestamp with time zone,
    "paused_at" timestamp with time zone,
    "completed_at" timestamp with time zone
      );


alter table "mod_manufacturing"."work_orders" enable row level security;


  create table "mod_manufacturing"."work_steps" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "type" text not null default 'processing'::text,
    "sort_order" integer not null,
    "estimated_time" interval,
    "workstation_id" uuid,
    "work_cycle_id" uuid not null,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "work_order_id" uuid,
    "is_checked" boolean not null default false
      );


alter table "mod_manufacturing"."work_steps" enable row level security;


  create table "mod_manufacturing"."workstations" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "station_type" text not null,
    "operation_type" text not null,
    "max_capacity" integer default 1,
    "location_id" uuid,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_manufacturing"."workstations" enable row level security;


  create table "mod_manufacturing"."workstations_duplicate" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "station_type" text not null,
    "operation_type" text not null,
    "max_capacity" integer default 1,
    "location_id" uuid,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_manufacturing"."workstations_duplicate" enable row level security;


  create table "mod_pulse"."department_notification_configs" (
    "id" uuid not null default gen_random_uuid(),
    "department_id" uuid not null,
    "notification_type" text not null,
    "is_enabled" boolean not null default true,
    "domain_id" uuid,
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_pulse"."department_notification_configs" enable row level security;


  create table "mod_pulse"."notifications" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "user_id" uuid,
    "pulse_id" uuid,
    "type" text,
    "is_read" boolean default false,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "department_id" uuid,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((((COALESCE(name, ''::text) || ' '::text) || COALESCE(description, ''::text)) || ' '::text) || COALESCE(code, ''::text)) || ' '::text) || COALESCE(type, ''::text)))) stored
      );


alter table "mod_pulse"."notifications" enable row level security;


  create table "mod_pulse"."pulse_chat" (
    "id" uuid not null default gen_random_uuid(),
    "pulse_id" uuid not null,
    "message" text not null default ''::text,
    "avatar_url" text not null default ''::text,
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "message_type" text default 'text'::text,
    "reply_to_id" uuid,
    "is_edited" boolean default false,
    "edit_history" jsonb default '[]'::jsonb,
    "read_by" text[] default '{}'::text[],
    "delivered_to" text[] default '{}'::text[],
    "mentions" text[] default '{}'::text[],
    "reactions" jsonb default '{}'::jsonb
      );


alter table "mod_pulse"."pulse_chat" enable row level security;


  create table "mod_pulse"."pulse_chat_files" (
    "id" uuid not null default gen_random_uuid(),
    "message_id" uuid not null,
    "file_url" text not null,
    "file_name" text not null,
    "file_size" integer not null default 0,
    "file_type" text not null,
    "thumbnail_url" text not null default ''::text,
    "is_deleted" boolean not null default false,
    "domain_id" uuid,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_pulse"."pulse_chat_files" enable row level security;


  create table "mod_pulse"."pulse_checklists" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "pulse_id" uuid not null,
    "is_completed" boolean default false,
    "completed_at" timestamp with time zone,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_pulse"."pulse_checklists" enable row level security;


  create table "mod_pulse"."pulse_comments" (
    "id" uuid not null default gen_random_uuid(),
    "pulse_id" uuid not null,
    "comment" text not null default ''::text,
    "avatar_url" text not null default ''::text,
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_pulse"."pulse_comments" enable row level security;


  create table "mod_pulse"."pulse_conversation_participants" (
    "id" uuid not null default gen_random_uuid(),
    "pulse_id" uuid not null,
    "user_id" uuid not null,
    "role" text not null default 'member'::text,
    "is_muted" boolean not null default false,
    "last_read_message_id" uuid,
    "last_read_at" timestamp with time zone,
    "notification_level" text not null default 'all'::text,
    "joined_at" timestamp with time zone not null default now(),
    "is_active" boolean not null default true,
    "domain_id" uuid,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_pulse"."pulse_conversation_participants" enable row level security;


  create table "mod_pulse"."pulse_progress" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "pulse_id" uuid not null,
    "new_status" text,
    "new_priority" text,
    "new_assigned_to" uuid,
    "new_sla_id" uuid,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((((((COALESCE(name, ''::text) || ' '::text) || COALESCE(description, ''::text)) || ' '::text) || COALESCE(code, ''::text)) || ' '::text) || COALESCE(new_status, ''::text)) || ' '::text) || COALESCE(new_priority, ''::text)))) stored
      );


alter table "mod_pulse"."pulse_progress" enable row level security;


  create table "mod_pulse"."pulse_slas" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "response_time" interval not null,
    "resolution_time" interval not null,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((COALESCE(name, ''::text) || ' '::text) || COALESCE(description, ''::text)) || ' '::text) || COALESCE(code, ''::text)))) stored
      );


alter table "mod_pulse"."pulse_slas" enable row level security;


  create table "mod_pulse"."pulses" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "type" text default 'task'::text,
    "status" text default 'open'::text,
    "priority" text default 'medium'::text,
    "assigned_to" uuid,
    "sla_id" uuid,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "conversation_type" text,
    "department_id" uuid,
    "last_message_at" timestamp with time zone default now(),
    "last_message_preview" text default ''::text,
    "last_message_sender_id" uuid,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((((((((COALESCE(name, ''::text) || ' '::text) || COALESCE(description, ''::text)) || ' '::text) || COALESCE(code, ''::text)) || ' '::text) || COALESCE(type, ''::text)) || ' '::text) || COALESCE(status, ''::text)) || ' '::text) || COALESCE(priority, ''::text)))) stored
      );


alter table "mod_pulse"."pulses" enable row level security;


  create table "mod_pulse"."tasks" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "pulse_id" uuid,
    "assigned_id" uuid,
    "status" text default 'pending'::text,
    "priority" text default 'medium'::text,
    "due_date" timestamp with time zone,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "assigned_department_id" uuid,
    "status_history" jsonb default '[]'::jsonb,
    "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((((((COALESCE(name, ''::text) || ' '::text) || COALESCE(description, ''::text)) || ' '::text) || COALESCE(code, ''::text)) || ' '::text) || COALESCE(status, ''::text)) || ' '::text) || COALESCE(priority, ''::text)))) stored
      );


alter table "mod_pulse"."tasks" enable row level security;


  create table "mod_quality_control"."conformity_documents" (
    "id" uuid not null default gen_random_uuid(),
    "quality_control_id" uuid,
    "supplier_id" uuid,
    "article_id" uuid,
    "document_type" text not null,
    "document_number" text not null,
    "document_date" date,
    "expiry_date" date,
    "issuing_authority" text,
    "file_path" text,
    "file_name" text,
    "file_size" integer,
    "is_verified" boolean default false,
    "verified_by" uuid,
    "verified_at" timestamp with time zone,
    "verification_notes" text,
    "shared_with" text[] default ARRAY[]::text[],
    "is_deleted" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_quality_control"."conformity_documents" enable row level security;


  create table "mod_quality_control"."defect_types" (
    "id" uuid not null default gen_random_uuid(),
    "code" text not null,
    "name" text not null,
    "description" text,
    "category" text not null,
    "is_active" boolean default true,
    "shared_with" text[] default ARRAY[]::text[],
    "is_deleted" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_quality_control"."defect_types" enable row level security;


  create table "mod_quality_control"."measurement_parameters" (
    "id" uuid not null default gen_random_uuid(),
    "code" text not null,
    "name" text not null,
    "description" text,
    "unit" text,
    "decimal_places" integer default 2,
    "is_active" boolean default true,
    "shared_with" text[] default ARRAY[]::text[],
    "is_deleted" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_quality_control"."measurement_parameters" enable row level security;


  create table "mod_quality_control"."quality_control_checklist_results" (
    "id" uuid not null default gen_random_uuid(),
    "quality_control_id" uuid,
    "checklist_item_id" text,
    "result" boolean,
    "notes" text,
    "inspector_id" uuid,
    "completed_at" timestamp with time zone default now(),
    "shared_with" text[] default ARRAY[]::text[],
    "is_deleted" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_quality_control"."quality_control_checklist_results" enable row level security;


  create table "mod_quality_control"."quality_control_defects" (
    "id" uuid not null default gen_random_uuid(),
    "quality_control_id" uuid,
    "defect_type_id" uuid,
    "quantity" integer,
    "severity" public.defect_severity_type not null,
    "description" text,
    "images" text[],
    "corrective_action" text,
    "inspector_notes" text,
    "shared_with" text[] default ARRAY[]::text[],
    "is_deleted" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_quality_control"."quality_control_defects" enable row level security;


  create table "mod_quality_control"."quality_control_measurements" (
    "id" uuid not null default gen_random_uuid(),
    "quality_control_id" uuid,
    "parameter_id" uuid,
    "expected_value" numeric,
    "actual_value" numeric,
    "tolerance_min" numeric,
    "tolerance_max" numeric,
    "unit" text,
    "is_within_spec" boolean,
    "measurement_tool" text,
    "inspector_notes" text,
    "measured_at" timestamp with time zone default now(),
    "shared_with" text[] default ARRAY[]::text[],
    "is_deleted" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_quality_control"."quality_control_measurements" enable row level security;


  create table "mod_quality_control"."supplier_returns" (
    "id" uuid not null default gen_random_uuid(),
    "quality_control_id" uuid,
    "purchase_order_id" uuid,
    "supplier_id" uuid,
    "article_id" uuid,
    "return_number" text not null,
    "return_date" date not null,
    "return_reason" text not null,
    "return_quantity" integer not null,
    "return_status" public.return_status_type default 'PENDING'::public.return_status_type,
    "conformity_issues" text[],
    "missing_certificates" text[],
    "certificate_expiry_issues" text[],
    "unit_cost" numeric(10,2),
    "total_cost" numeric(10,2),
    "credit_amount" numeric(10,2),
    "credit_issued_date" date,
    "shipping_method" text,
    "tracking_number" text,
    "shipping_date" date,
    "expected_return_date" date,
    "supplier_contact" text,
    "communication_notes" text,
    "follow_up_required" boolean default false,
    "follow_up_date" date,
    "shared_with" text[] default ARRAY[]::text[],
    "is_deleted" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_quality_control"."supplier_returns" enable row level security;


  create table "mod_wms"."batches" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "batch_number" text not null default ''::text,
    "production_date" date,
    "expiration_date" date,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_wms"."batches" enable row level security;


  create table "mod_wms"."box_contents" (
    "id" uuid not null default gen_random_uuid(),
    "shipment_box_id" uuid not null,
    "shipment_item_id" uuid not null,
    "quantity_packed" integer not null default 0,
    "notes" text,
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_wms"."box_contents" enable row level security;


  create table "mod_wms"."box_types" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "dimensions_length" integer,
    "dimensions_width" integer,
    "dimensions_height" integer,
    "max_weight" numeric(10,2),
    "description" text,
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_wms"."box_types" enable row level security;


  create table "mod_wms"."carton_contents" (
    "id" uuid not null default gen_random_uuid(),
    "shipment_carton_id" uuid not null,
    "shipment_item_id" uuid not null,
    "quantity_packed" integer not null default 0,
    "notes" text,
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_wms"."carton_contents" enable row level security;


  create table "mod_wms"."carton_types" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "dimensions_length" integer,
    "dimensions_width" integer,
    "dimensions_height" integer,
    "max_weight" numeric(10,2),
    "description" text,
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_wms"."carton_types" enable row level security;


  create table "mod_wms"."inventory" (
    "article_id" uuid not null,
    "location_id" uuid not null,
    "batch_id" uuid,
    "quantity" numeric(12,4) not null default 0,
    "allocated_qty" numeric(12,4) not null default 0,
    "domain_id" uuid,
    "shared_with" text[],
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "id" uuid not null default gen_random_uuid()
      );


alter table "mod_wms"."inventory" enable row level security;


  create table "mod_wms"."inventory_backup" (
    "article_id" uuid not null,
    "location_id" uuid not null,
    "batch_id" uuid not null,
    "quantity" numeric(12,4) not null default 0,
    "allocated_qty" numeric(12,4) not null default 0,
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_wms"."inventory_backup" enable row level security;


  create table "mod_wms"."inventory_limits" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "location_id" uuid not null,
    "article_id" uuid not null,
    "min_stock" integer,
    "max_stock" integer,
    "reorder_point" integer,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_wms"."inventory_limits" enable row level security;


  create table "mod_wms"."locations" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "type" text,
    "capacity" integer default 0,
    "is_active" boolean not null default true,
    "warehouse_id" uuid not null,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_wms"."locations" enable row level security;


  create table "mod_wms"."pallet_contents" (
    "id" uuid not null default gen_random_uuid(),
    "shipment_pallet_id" uuid not null,
    "shipment_item_id" uuid not null,
    "quantity_packed" integer not null default 0,
    "notes" text,
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_wms"."pallet_contents" enable row level security;


  create table "mod_wms"."pallet_types" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "dimensions_length" integer,
    "dimensions_width" integer,
    "dimensions_height" integer,
    "max_weight" numeric(10,2),
    "description" text,
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_wms"."pallet_types" enable row level security;


  create table "mod_wms"."receipt_items" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "receipt_id" uuid not null,
    "article_id" uuid not null,
    "quantity_ordered" numeric(12,4) not null,
    "quantity_received" numeric(12,4) not null default 0,
    "location_id" uuid not null,
    "batch_id" uuid,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "qc_notes" text default ''::text,
    "qc_status" text default 'PENDING'::text,
    "qc_inspector_id" uuid,
    "qc_completed_at" timestamp with time zone,
    "is_moved" boolean not null default false,
    "moved_date" timestamp with time zone,
    "quantity_damaged" numeric(12,4) not null default 0
      );


alter table "mod_wms"."receipt_items" enable row level security;


  create table "mod_wms"."receipts" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "warehouse_id" uuid not null,
    "purchase_order_id" uuid,
    "receipt_number" text not null,
    "receipt_date" date not null,
    "expected_delivery_date" date,
    "status" text,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "transport_document_number" text default ''::text,
    "invoice_number" text default ''::text,
    "supplier_order_number" text default ''::text,
    "supplier_id" uuid
      );


alter table "mod_wms"."receipts" enable row level security;


  create table "mod_wms"."shipment_attachments" (
    "id" uuid not null default gen_random_uuid(),
    "shipment_id" uuid not null,
    "file_path" text not null,
    "file_name" text not null,
    "file_size" bigint not null,
    "file_type" text not null,
    "attachment_type" text not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid
      );


alter table "mod_wms"."shipment_attachments" enable row level security;


  create table "mod_wms"."shipment_boxes" (
    "id" uuid not null default gen_random_uuid(),
    "shipment_pallet_id" uuid,
    "box_type_id" uuid not null,
    "box_number" integer not null,
    "total_weight" numeric(10,2),
    "notes" text,
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "shipment_id" uuid
      );


alter table "mod_wms"."shipment_boxes" enable row level security;


  create table "mod_wms"."shipment_cartons" (
    "id" uuid not null default gen_random_uuid(),
    "shipment_pallet_id" uuid not null,
    "carton_type_id" uuid not null,
    "carton_number" integer not null,
    "total_weight" numeric(10,2),
    "notes" text,
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_wms"."shipment_cartons" enable row level security;


  create table "mod_wms"."shipment_item_addresses" (
    "id" uuid not null default gen_random_uuid(),
    "shipment_item_id" uuid not null,
    "address_type" character varying(50) not null default 'delivery'::character varying,
    "address" text not null,
    "city" text not null,
    "state" text not null,
    "zip" text,
    "country" text,
    "province" text,
    "is_primary" boolean not null default false,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "domain_id" uuid not null,
    "shared_with" jsonb default '[]'::jsonb,
    "is_deleted" boolean default false
      );


alter table "mod_wms"."shipment_item_addresses" enable row level security;


  create table "mod_wms"."shipment_items" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "shipment_id" uuid not null,
    "article_id" uuid not null,
    "quantity_shipped" numeric(12,4) not null default 0,
    "location_id" uuid,
    "batch_id" uuid,
    "total_weight" numeric(10,2),
    "total_volume" numeric(10,2),
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "inventory_id" uuid
      );


alter table "mod_wms"."shipment_items" enable row level security;


  create table "mod_wms"."shipment_pallets" (
    "id" uuid not null default gen_random_uuid(),
    "shipment_id" uuid not null,
    "pallet_type_id" uuid not null,
    "pallet_number" integer not null,
    "total_weight" numeric(10,2),
    "notes" text,
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_wms"."shipment_pallets" enable row level security;


  create table "mod_wms"."shipment_sales_orders" (
    "id" uuid not null default gen_random_uuid(),
    "shipment_id" uuid not null,
    "sales_order_id" uuid not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "domain_id" uuid
      );


alter table "mod_wms"."shipment_sales_orders" enable row level security;


  create table "mod_wms"."shipment_standalone_items" (
    "id" uuid not null default gen_random_uuid(),
    "shipment_id" uuid not null,
    "shipment_item_id" uuid not null,
    "quantity_packed" integer not null default 0,
    "notes" text,
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_wms"."shipment_standalone_items" enable row level security;


  create table "mod_wms"."shipments" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "warehouse_id" uuid,
    "sales_order_id" uuid,
    "shipment_number" text not null default ''::text,
    "shipment_date" date not null,
    "expected_delivery_date" date,
    "status" text,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "tracking_url" text not null default ''::text,
    "tracking_no" text not null default ''::text,
    "invoice_address" text not null default ''::text,
    "invoice_city" text not null default ''::text,
    "invoice_state" text not null default ''::text,
    "invoice_zip" text not null default ''::text,
    "invoice_country" text not null default ''::text,
    "invoice_province" text not null default ''::text,
    "goods_ready" boolean not null default false,
    "docs_ready" boolean not null default false,
    "is_archived" boolean not null default false,
    "notes" text default ''::text
      );


alter table "mod_wms"."shipments" enable row level security;


  create table "mod_wms"."stock_movements" (
    "id" uuid not null default gen_random_uuid(),
    "article_id" uuid not null,
    "batch_id" uuid,
    "from_location_id" uuid,
    "to_location_id" uuid,
    "quantity_moved" numeric(12,4) not null,
    "movement_date" timestamp with time zone not null default now(),
    "reason" text not null default ''::text,
    "reference_doc_type" text not null default ''::text,
    "reference_doc_id" uuid,
    "type" text,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid,
    "unit_of_measure_id" uuid,
    "receipt_item_id" uuid,
    "work_order_id" uuid,
    "sales_order_id" uuid,
    "internal_sales_order_id" uuid,
    "origin_article_id" uuid,
    "original_receipt_item_id" uuid
      );


alter table "mod_wms"."stock_movements" enable row level security;


  create table "mod_wms"."warehouses" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null default ''::text,
    "description" text not null default ''::text,
    "code" text not null default ''::text,
    "address" text not null default ''::text,
    "zip" text not null default ''::text,
    "city" text not null default ''::text,
    "province" text not null default ''::text,
    "state" text not null default ''::text,
    "country" text not null default ''::text,
    "avatar_url" text not null default ''::text,
    "barcode" text not null default regexp_replace((gen_random_uuid())::text, '-'::text, ''::text, 'g'::text),
    "domain_id" uuid not null default 'cf1763e8-832e-4a04-8ee6-d95acaf21372'::uuid,
    "shared_with" text[] not null default '{}'::text[],
    "is_deleted" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "updated_by" uuid
      );


alter table "mod_wms"."warehouses" enable row level security;

CREATE UNIQUE INDEX domain_modules_domain_id_module_id_key ON mod_admin.domain_modules USING btree (domain_id, module_id);

CREATE UNIQUE INDEX domain_modules_pkey ON mod_admin.domain_modules USING btree (id);

CREATE UNIQUE INDEX domain_users_pkey ON mod_admin.domain_users USING btree (user_id, domain_id);

CREATE INDEX domain_users_user_id_domain_id_idx ON mod_admin.domain_users USING btree (user_id, domain_id);

CREATE INDEX domain_users_user_id_domain_id_idx1 ON mod_admin.domain_users USING btree (user_id, domain_id);

CREATE UNIQUE INDEX domains_key_key ON mod_admin.domains USING btree (key);

CREATE UNIQUE INDEX domains_name_key ON mod_admin.domains USING btree (name);

CREATE INDEX domains_parent_domain_id_idx ON mod_admin.domains USING btree (parent_domain_id);

CREATE INDEX domains_parent_domain_id_idx1 ON mod_admin.domains USING btree (parent_domain_id);

CREATE UNIQUE INDEX domains_pkey ON mod_admin.domains USING btree (id);

CREATE INDEX idx_domains_fts ON mod_admin.domains USING gin (fts);

CREATE INDEX idx_user_profiles_fts ON mod_admin.user_profiles USING gin (fts);

CREATE UNIQUE INDEX user_profiles_barcode_key ON mod_admin.user_profiles USING btree (barcode);

CREATE UNIQUE INDEX user_profiles_pkey ON mod_admin.user_profiles USING btree (id);

CREATE UNIQUE INDEX announcements_barcode_key ON mod_base.announcements USING btree (barcode);

CREATE UNIQUE INDEX announcements_pkey ON mod_base.announcements USING btree (id);

CREATE UNIQUE INDEX article_categories_barcode_key ON mod_base.article_categories USING btree (barcode);

CREATE UNIQUE INDEX article_categories_pkey ON mod_base.article_categories USING btree (id);

CREATE UNIQUE INDEX articles_barcode_key ON mod_base.articles USING btree (barcode);

CREATE UNIQUE INDEX articles_pkey ON mod_base.articles USING btree (id);

CREATE UNIQUE INDEX articles_sku_key ON mod_base.articles USING btree (sku);

CREATE UNIQUE INDEX bom_articles_pkey ON mod_base.bom_articles USING btree (id);

CREATE UNIQUE INDEX bom_articles_unique_relationship ON mod_base.bom_articles USING btree (parent_article_id, component_article_id);

CREATE UNIQUE INDEX custom_article_attachments_pkey ON mod_base.custom_article_attachments USING btree (id);

CREATE UNIQUE INDEX customer_addresses_pkey ON mod_base.customer_addresses USING btree (id);

CREATE UNIQUE INDEX customers_barcode_key ON mod_base.customers USING btree (barcode);

CREATE UNIQUE INDEX customers_pkey ON mod_base.customers USING btree (id);

CREATE UNIQUE INDEX departments_barcode_key ON mod_base.departments USING btree (barcode);

CREATE UNIQUE INDEX departments_pkey ON mod_base.departments USING btree (id);

CREATE UNIQUE INDEX employees_barcode_key ON mod_base.employees USING btree (barcode);

CREATE UNIQUE INDEX employees_departments_pkey ON mod_base.employees_departments USING btree (employee_id, department_id);

CREATE UNIQUE INDEX employees_pkey ON mod_base.employees USING btree (id);

CREATE INDEX idx_articles_fts ON mod_base.articles USING gin (fts);

CREATE INDEX idx_articles_heat_exchanger_model ON mod_base.articles USING btree (heat_exchanger_model);

CREATE INDEX idx_articles_is_deleted ON mod_base.articles USING btree (is_deleted);

CREATE INDEX idx_articles_name ON mod_base.articles USING btree (name);

CREATE INDEX idx_articles_parent_article_id ON mod_base.articles USING btree (parent_article_id);

CREATE INDEX idx_articles_parent_article_id_not_null ON mod_base.articles USING btree (parent_article_id) WHERE (parent_article_id IS NOT NULL);

CREATE INDEX idx_articles_type ON mod_base.articles USING btree (type);

CREATE INDEX idx_articles_type_is_deleted ON mod_base.articles USING btree (type, is_deleted) WHERE (is_deleted = false);

CREATE INDEX idx_articles_type_is_deleted_heat_exchanger_model ON mod_base.articles USING btree (type, is_deleted, heat_exchanger_model) WHERE (is_deleted = false);

CREATE INDEX idx_bom_articles_component_id ON mod_base.bom_articles USING btree (component_article_id);

CREATE INDEX idx_bom_articles_fts ON mod_base.bom_articles USING gin (fts);

CREATE INDEX idx_bom_articles_parent_id ON mod_base.bom_articles USING btree (parent_article_id);

CREATE INDEX idx_bom_articles_position ON mod_base.bom_articles USING btree ("position");

CREATE INDEX idx_custom_article_attachments_article_id ON mod_base.custom_article_attachments USING btree (article_id);

CREATE INDEX idx_custom_article_attachments_fts ON mod_base.custom_article_attachments USING gin (fts);

CREATE INDEX idx_custom_article_attachments_internal_sales_order_article ON mod_base.custom_article_attachments USING btree (internal_sales_order_id, article_id);

CREATE INDEX idx_custom_article_attachments_internal_sales_order_id ON mod_base.custom_article_attachments USING btree (internal_sales_order_id);

CREATE INDEX idx_custom_article_attachments_internal_sales_order_only ON mod_base.custom_article_attachments USING btree (internal_sales_order_id) WHERE (article_id IS NULL);

CREATE INDEX idx_custom_article_attachments_internal_sales_order_with_articl ON mod_base.custom_article_attachments USING btree (internal_sales_order_id, article_id) WHERE (article_id IS NOT NULL);

CREATE INDEX idx_custom_article_attachments_sales_order_article ON mod_base.custom_article_attachments USING btree (sales_order_id, article_id);

CREATE INDEX idx_custom_article_attachments_sales_order_id ON mod_base.custom_article_attachments USING btree (sales_order_id);

CREATE INDEX idx_custom_article_attachments_sales_order_only ON mod_base.custom_article_attachments USING btree (sales_order_id) WHERE (article_id IS NULL);

CREATE INDEX idx_custom_article_attachments_with_article ON mod_base.custom_article_attachments USING btree (sales_order_id, article_id) WHERE (article_id IS NOT NULL);

CREATE INDEX idx_customer_addresses_address_type ON mod_base.customer_addresses USING btree (address_type);

CREATE INDEX idx_customer_addresses_customer_id ON mod_base.customer_addresses USING btree (customer_id);

CREATE INDEX idx_customer_addresses_domain_id ON mod_base.customer_addresses USING btree (domain_id);

CREATE INDEX idx_customer_addresses_fts ON mod_base.customer_addresses USING gin (fts);

CREATE INDEX idx_customer_addresses_is_primary ON mod_base.customer_addresses USING btree (is_primary);

CREATE INDEX idx_customers_fts ON mod_base.customers USING gin (fts);

CREATE INDEX idx_internal_sales_order_items_fts ON mod_base.internal_sales_order_items USING gin (fts);

CREATE INDEX idx_internal_sales_order_items_is_manufactured ON mod_base.internal_sales_order_items USING btree (is_manufactured);

CREATE INDEX idx_internal_sales_order_items_parent_item ON mod_base.internal_sales_order_items USING btree (parent_sales_order_item_id);

CREATE INDEX idx_internal_sales_order_items_production_date ON mod_base.internal_sales_order_items USING btree (sales_order_id, production_date) WHERE ((production_date IS NOT NULL) AND (is_deleted = false));

CREATE INDEX idx_internal_sales_orders_archived_deleted ON mod_base.internal_sales_orders USING btree (is_archived, is_deleted);

CREATE INDEX idx_internal_sales_orders_fts ON mod_base.internal_sales_orders USING gin (fts);

CREATE INDEX idx_internal_sales_orders_internal_archived ON mod_base.internal_sales_orders USING btree (is_internal, is_archived);

CREATE INDEX idx_internal_sales_orders_is_archived ON mod_base.internal_sales_orders USING btree (is_archived);

CREATE INDEX idx_internal_sales_orders_is_internal ON mod_base.internal_sales_orders USING btree (is_internal);

CREATE INDEX idx_internal_sales_orders_total_cost ON mod_base.internal_sales_orders USING btree (total_cost);

CREATE INDEX idx_purchase_order_items_fts ON mod_base.purchase_order_items USING gin (fts);

CREATE INDEX idx_purchase_orders_fts ON mod_base.purchase_orders USING gin (fts);

CREATE INDEX idx_qc_inspector ON mod_base.quality_control USING btree (inspector_id);

CREATE INDEX idx_qc_reference ON mod_base.quality_control USING btree (reference_type, reference_id);

CREATE INDEX idx_qc_status ON mod_base.quality_control USING btree (status);

CREATE INDEX idx_qc_types_article_type ON mod_base.quality_control_types USING btree (article_type);

CREATE INDEX idx_qc_types_is_active ON mod_base.quality_control_types USING btree (is_active);

CREATE INDEX idx_qc_types_is_required ON mod_base.quality_control_types USING btree (is_required);

CREATE INDEX idx_qc_types_timing ON mod_base.quality_control_types USING btree (timing);

CREATE INDEX idx_quality_control_article_type ON mod_base.quality_control USING btree (article_type) WHERE (article_type IS NOT NULL);

CREATE INDEX idx_quality_control_attachments_quality_control_id ON mod_base.quality_control_attachments USING btree (quality_control_id);

CREATE INDEX idx_quality_control_checklist_results_created_at ON mod_base.quality_control_checklist_results USING btree (created_at);

CREATE INDEX idx_quality_control_checklist_results_domain_id ON mod_base.quality_control_checklist_results USING btree (domain_id);

CREATE INDEX idx_quality_control_checklist_results_quality_control_id ON mod_base.quality_control_checklist_results USING btree (quality_control_id);

CREATE INDEX idx_quality_control_checklist_results_result ON mod_base.quality_control_checklist_results USING btree (result);

CREATE INDEX idx_quality_control_inspector_id ON mod_base.quality_control USING btree (inspector_id);

CREATE INDEX idx_quality_control_purchase_order_item_id ON mod_base.quality_control USING btree (purchase_order_item_id);

CREATE INDEX idx_quality_control_receipt_id ON mod_base.quality_control USING btree (receipt_id) WHERE (receipt_id IS NOT NULL);

CREATE INDEX idx_quality_control_receipt_item_id ON mod_base.quality_control USING btree (receipt_item_id) WHERE (receipt_item_id IS NOT NULL);

CREATE INDEX idx_quality_control_shipment_id ON mod_base.quality_control USING btree (shipment_id) WHERE (shipment_id IS NOT NULL);

CREATE INDEX idx_quality_control_type_id ON mod_base.quality_control USING btree (quality_control_type_id);

CREATE INDEX idx_quality_control_types_category_id ON mod_base.quality_control_types USING btree (category_id) WHERE (category_id IS NOT NULL);

CREATE INDEX idx_quality_control_types_fts ON mod_base.quality_control_types USING gin (fts);

CREATE INDEX idx_quality_control_types_work_cycle_id ON mod_base.quality_control_types USING btree (work_cycle_id);

CREATE INDEX idx_quality_control_work_order_id ON mod_base.quality_control USING btree (work_order_id);

CREATE INDEX idx_quality_control_work_steps_id ON mod_base.quality_control USING btree (work_steps_id);

CREATE INDEX idx_sales_order_items_fts ON mod_base.sales_order_items USING gin (fts);

CREATE INDEX idx_sales_order_items_is_manufactured ON mod_base.sales_order_items USING btree (is_manufactured);

CREATE INDEX idx_sales_order_items_parent_item ON mod_base.sales_order_items USING btree (parent_sales_order_item_id);

CREATE INDEX idx_sales_order_items_production_date ON mod_base.sales_order_items USING btree (sales_order_id, production_date) WHERE ((production_date IS NOT NULL) AND (is_deleted = false));

CREATE INDEX idx_sales_orders_archived_deleted ON mod_base.sales_orders USING btree (is_archived, is_deleted);

CREATE INDEX idx_sales_orders_customer_order_ref ON mod_base.sales_orders USING btree (customer_order_ref);

CREATE INDEX idx_sales_orders_fts ON mod_base.sales_orders USING gin (fts);

CREATE INDEX idx_sales_orders_internal_archived ON mod_base.sales_orders USING btree (is_internal, is_archived);

CREATE INDEX idx_sales_orders_is_archived ON mod_base.sales_orders USING btree (is_archived);

CREATE INDEX idx_sales_orders_is_internal ON mod_base.sales_orders USING btree (is_internal);

CREATE INDEX idx_sales_orders_order_ref ON mod_base.sales_orders USING btree (order_ref);

CREATE INDEX idx_sales_orders_total_cost ON mod_base.sales_orders USING btree (total_cost);

CREATE INDEX idx_serial_number_counters_category_id ON mod_base.serial_number_counters USING btree (category_id);

CREATE INDEX idx_serial_number_counters_category_year ON mod_base.serial_number_counters USING btree (category_id, year);

CREATE INDEX idx_serial_number_counters_year ON mod_base.serial_number_counters USING btree (year);

CREATE INDEX idx_suppliers_fts ON mod_base.suppliers USING gin (fts);

CREATE UNIQUE INDEX internal_sales_order_items_barcode_key ON mod_base.internal_sales_order_items USING btree (barcode);

CREATE UNIQUE INDEX internal_sales_order_items_pkey ON mod_base.internal_sales_order_items USING btree (id);

CREATE UNIQUE INDEX internal_sales_orders_barcode_key ON mod_base.internal_sales_orders USING btree (barcode);

CREATE UNIQUE INDEX internal_sales_orders_pkey ON mod_base.internal_sales_orders USING btree (id);

CREATE UNIQUE INDEX internal_sales_orders_sales_order_number_key ON mod_base.internal_sales_orders USING btree (sales_order_number);

CREATE UNIQUE INDEX profiles_pkey ON mod_base.profiles USING btree (id);

CREATE UNIQUE INDEX purchase_order_items_barcode_key ON mod_base.purchase_order_items USING btree (barcode);

CREATE UNIQUE INDEX purchase_order_items_pkey ON mod_base.purchase_order_items USING btree (id);

CREATE UNIQUE INDEX purchase_orders_barcode_key ON mod_base.purchase_orders USING btree (barcode);

CREATE UNIQUE INDEX purchase_orders_pkey ON mod_base.purchase_orders USING btree (id);

CREATE UNIQUE INDEX purchase_orders_purchase_order_number_key ON mod_base.purchase_orders USING btree (purchase_order_number);

CREATE UNIQUE INDEX quality_control_attachments_pkey ON mod_base.quality_control_attachments USING btree (id);

CREATE UNIQUE INDEX quality_control_checklist_results_pkey ON mod_base.quality_control_checklist_results USING btree (id);

CREATE UNIQUE INDEX quality_control_pkey ON mod_base.quality_control USING btree (id);

CREATE UNIQUE INDEX quality_control_types_barcode_key ON mod_base.quality_control_types USING btree (barcode);

CREATE INDEX quality_control_types_duplicate_article_type_idx ON mod_base.quality_control_types_duplicate USING btree (article_type);

CREATE UNIQUE INDEX quality_control_types_duplicate_barcode_key ON mod_base.quality_control_types_duplicate USING btree (barcode);

CREATE INDEX quality_control_types_duplicate_category_id_idx ON mod_base.quality_control_types_duplicate USING btree (category_id) WHERE (category_id IS NOT NULL);

CREATE INDEX quality_control_types_duplicate_fts_idx ON mod_base.quality_control_types_duplicate USING gin (fts);

CREATE INDEX quality_control_types_duplicate_is_active_idx ON mod_base.quality_control_types_duplicate USING btree (is_active);

CREATE INDEX quality_control_types_duplicate_is_required_idx ON mod_base.quality_control_types_duplicate USING btree (is_required);

CREATE UNIQUE INDEX quality_control_types_duplicate_pkey ON mod_base.quality_control_types_duplicate USING btree (id);

CREATE INDEX quality_control_types_duplicate_timing_idx ON mod_base.quality_control_types_duplicate USING btree (timing);

CREATE INDEX quality_control_types_duplicate_work_cycle_id_idx ON mod_base.quality_control_types_duplicate USING btree (work_cycle_id);

CREATE UNIQUE INDEX quality_control_types_pkey ON mod_base.quality_control_types USING btree (id);

CREATE UNIQUE INDEX report_template_pkey ON mod_base.report_template USING btree (id);

CREATE UNIQUE INDEX sales_order_items_barcode_key ON mod_base.sales_order_items USING btree (barcode);

CREATE UNIQUE INDEX sales_order_items_pkey ON mod_base.sales_order_items USING btree (id);

CREATE UNIQUE INDEX sales_orders_barcode_key ON mod_base.sales_orders USING btree (barcode);

CREATE UNIQUE INDEX sales_orders_pkey ON mod_base.sales_orders USING btree (id);

CREATE UNIQUE INDEX sales_orders_sales_order_number_key ON mod_base.sales_orders USING btree (sales_order_number);

CREATE UNIQUE INDEX serial_number_counters_pkey ON mod_base.serial_number_counters USING btree (id);

CREATE UNIQUE INDEX serial_number_counters_unique_category_year ON mod_base.serial_number_counters USING btree (category_id, year);

CREATE UNIQUE INDEX suppliers_barcode_key ON mod_base.suppliers USING btree (barcode);

CREATE UNIQUE INDEX suppliers_pkey ON mod_base.suppliers USING btree (id);

CREATE UNIQUE INDEX uk_quality_control_checklist_results_unique_item ON mod_base.quality_control_checklist_results USING btree (quality_control_id, checklist_item, domain_id);

CREATE UNIQUE INDEX units_of_measure_barcode_key ON mod_base.units_of_measure USING btree (barcode);

CREATE UNIQUE INDEX units_of_measure_pkey ON mod_base.units_of_measure USING btree (id);

CREATE UNIQUE INDEX fields_pkey ON mod_datalayer.fields USING btree (id);

CREATE UNIQUE INDEX fields_schema_name_table_name_field_name_key ON mod_datalayer.fields USING btree (schema_name, table_name, field_name);

CREATE INDEX idx_fields_fts ON mod_datalayer.fields USING gin (fts);

CREATE INDEX idx_main_menu_fts ON mod_datalayer.main_menu USING gin (fts);

CREATE INDEX idx_modules_fts ON mod_datalayer.modules USING gin (fts);

CREATE INDEX idx_pages_departments_composite ON mod_datalayer.pages_departments USING btree (page_id, department_id);

CREATE INDEX idx_pages_departments_department_id ON mod_datalayer.pages_departments USING btree (department_id);

CREATE INDEX idx_pages_departments_is_deleted ON mod_datalayer.pages_departments USING btree (is_deleted) WHERE (is_deleted = false);

CREATE INDEX idx_pages_departments_page_id ON mod_datalayer.pages_departments USING btree (page_id);

CREATE INDEX idx_pages_fts ON mod_datalayer.pages USING gin (fts);

CREATE INDEX idx_pages_is_visible ON mod_datalayer.pages USING btree (is_visible);

CREATE INDEX idx_pages_menu_departments_composite ON mod_datalayer.pages_menu_departments USING btree (page_id, department_id);

CREATE INDEX idx_pages_menu_departments_department_id ON mod_datalayer.pages_menu_departments USING btree (department_id);

CREATE INDEX idx_pages_menu_departments_page_id ON mod_datalayer.pages_menu_departments USING btree (page_id);

CREATE INDEX idx_tables_fts ON mod_datalayer.tables USING gin (fts);

CREATE UNIQUE INDEX main_menu_pkey ON mod_datalayer.main_menu USING btree (id);

CREATE UNIQUE INDEX modules_pkey ON mod_datalayer.modules USING btree (id);

CREATE UNIQUE INDEX modules_schema_name_key ON mod_datalayer.modules USING btree (schema_name);

CREATE UNIQUE INDEX page_categories_pkey ON mod_datalayer.page_categories USING btree (id);

CREATE UNIQUE INDEX pages_departments_page_id_department_id_key ON mod_datalayer.pages_departments USING btree (page_id, department_id);

CREATE UNIQUE INDEX pages_departments_pkey ON mod_datalayer.pages_departments USING btree (id);

CREATE UNIQUE INDEX pages_menu_departments_page_id_department_id_key ON mod_datalayer.pages_menu_departments USING btree (page_id, department_id);

CREATE UNIQUE INDEX pages_menu_departments_pkey ON mod_datalayer.pages_menu_departments USING btree (id);

CREATE UNIQUE INDEX pages_pkey ON mod_datalayer.pages USING btree (id);

CREATE UNIQUE INDEX tables_pkey ON mod_datalayer.tables USING btree (id);

CREATE UNIQUE INDEX tables_schema_name_table_name_key ON mod_datalayer.tables USING btree (schema_name, table_name);

CREATE UNIQUE INDEX unique_module_page ON mod_datalayer.pages USING btree (module_id, name);

CREATE UNIQUE INDEX coil_consumption_pkey ON mod_manufacturing.coil_consumption USING btree (id);

CREATE UNIQUE INDEX coil_production_plans_barcode_key ON mod_manufacturing.coil_production_plans USING btree (barcode);

CREATE UNIQUE INDEX coil_production_plans_pkey ON mod_manufacturing.coil_production_plans USING btree (id);

CREATE UNIQUE INDEX coils_barcode_key ON mod_manufacturing.coils USING btree (barcode);

CREATE UNIQUE INDEX coils_pkey ON mod_manufacturing.coils USING btree (id);

CREATE UNIQUE INDEX departments_barcode_key ON mod_manufacturing.departments USING btree (barcode);

CREATE UNIQUE INDEX departments_pkey ON mod_manufacturing.departments USING btree (id);

CREATE INDEX idx_coil_consumption_coil_id ON mod_manufacturing.coil_consumption USING btree (coil_id);

CREATE INDEX idx_coil_consumption_production_plan_id ON mod_manufacturing.coil_consumption USING btree (production_plan_id);

CREATE INDEX idx_coils_location_id ON mod_manufacturing.coils USING btree (location_id);

CREATE INDEX idx_coils_material_type ON mod_manufacturing.coils USING btree (material_type);

CREATE INDEX idx_coils_status ON mod_manufacturing.coils USING btree (status);

CREATE INDEX idx_coils_weight_kg ON mod_manufacturing.coils USING btree (weight_kg);

CREATE INDEX idx_plate_templates_material_thickness ON mod_manufacturing.plate_templates USING btree (material_thickness);

CREATE INDEX idx_plate_templates_plate_type ON mod_manufacturing.plate_templates USING btree (plate_type);

CREATE INDEX idx_production_plans_coil_id ON mod_manufacturing.coil_production_plans USING btree (coil_id);

CREATE INDEX idx_production_plans_status ON mod_manufacturing.coil_production_plans USING btree (status);

CREATE INDEX idx_production_plans_template_id ON mod_manufacturing.coil_production_plans USING btree (plate_template_id);

CREATE INDEX idx_recipes_destination_article ON mod_manufacturing.recipes USING btree (destination_article_id);

CREATE INDEX idx_recipes_finished_product ON mod_manufacturing.recipes USING btree (finished_product_id);

CREATE INDEX idx_recipes_source_article ON mod_manufacturing.recipes USING btree (source_article_id);

CREATE INDEX idx_scheduled_items_article_id ON mod_manufacturing.scheduled_items USING btree (article_id);

CREATE INDEX idx_scheduled_items_sales_order_id ON mod_manufacturing.scheduled_items USING btree (sales_order_id);

CREATE INDEX idx_scheduled_items_sales_order_item_id ON mod_manufacturing.scheduled_items USING btree (sales_order_item_id);

CREATE INDEX idx_scheduled_items_scheduled_date ON mod_manufacturing.scheduled_items USING btree (scheduled_date);

CREATE INDEX idx_scheduled_items_status ON mod_manufacturing.scheduled_items USING btree (status);

CREATE INDEX idx_wcc_from_category_id ON mod_manufacturing.work_cycle_categories USING btree (from_article_category_id);

CREATE INDEX idx_wcc_location_id ON mod_manufacturing.work_cycle_categories USING btree (location_id);

CREATE INDEX idx_wcc_to_category_id ON mod_manufacturing.work_cycle_categories USING btree (to_article_category_id);

CREATE INDEX idx_wcc_work_cycle_id ON mod_manufacturing.work_cycle_categories USING btree (work_cycle_id);

CREATE INDEX idx_wcc_work_flow_id ON mod_manufacturing.work_cycle_categories USING btree (work_flow_id);

CREATE INDEX idx_wfwc_work_cycle_id ON mod_manufacturing.work_flows_work_cycles USING btree (work_cycle_id);

CREATE INDEX idx_wfwc_work_flow_id ON mod_manufacturing.work_flows_work_cycles USING btree (work_flow_id);

CREATE INDEX idx_work_order_attachments_work_order_id ON mod_manufacturing.work_order_attachments USING btree (work_order_id);

CREATE INDEX idx_work_order_quality_summary_domain_id ON mod_manufacturing.work_order_quality_summary USING btree (domain_id);

CREATE INDEX idx_work_order_quality_summary_inspector_id ON mod_manufacturing.work_order_quality_summary USING btree (inspector_id);

CREATE INDEX idx_work_order_quality_summary_overall_status ON mod_manufacturing.work_order_quality_summary USING btree (overall_status);

CREATE INDEX idx_work_order_quality_summary_work_order_id ON mod_manufacturing.work_order_quality_summary USING btree (work_order_id);

CREATE INDEX idx_work_orders_completed_at ON mod_manufacturing.work_orders USING btree (completed_at);

CREATE INDEX idx_work_orders_completed_by ON mod_manufacturing.work_orders USING btree (completed_by);

CREATE INDEX idx_work_orders_internal_sales_order_id ON mod_manufacturing.work_orders USING btree (internal_sales_order_id);

CREATE INDEX idx_work_orders_location_id ON mod_manufacturing.work_orders USING btree (location_id);

CREATE INDEX idx_work_orders_paused_at ON mod_manufacturing.work_orders USING btree (paused_at);

CREATE INDEX idx_work_orders_paused_by ON mod_manufacturing.work_orders USING btree (paused_by);

CREATE INDEX idx_work_orders_started_at ON mod_manufacturing.work_orders USING btree (started_at);

CREATE INDEX idx_work_orders_started_by ON mod_manufacturing.work_orders USING btree (started_by);

CREATE INDEX idx_work_orders_warehouse_id ON mod_manufacturing.work_orders USING btree (warehouse_id);

CREATE INDEX idx_work_steps_work_order_id ON mod_manufacturing.work_steps USING btree (work_order_id);

CREATE UNIQUE INDEX locations_barcode_key ON mod_manufacturing.locations USING btree (barcode);

CREATE UNIQUE INDEX locations_pkey ON mod_manufacturing.locations USING btree (id);

CREATE UNIQUE INDEX plate_templates_barcode_key ON mod_manufacturing.plate_templates USING btree (barcode);

CREATE UNIQUE INDEX plate_templates_pkey ON mod_manufacturing.plate_templates USING btree (id);

CREATE UNIQUE INDEX production_logs_pkey ON mod_manufacturing.production_logs USING btree (id);

CREATE UNIQUE INDEX recipes_finished_product_id_sequence_number_key ON mod_manufacturing.recipes USING btree (finished_product_id, sequence_number);

CREATE UNIQUE INDEX recipes_pkey ON mod_manufacturing.recipes USING btree (id);

CREATE UNIQUE INDEX scheduled_items_pkey ON mod_manufacturing.scheduled_items USING btree (id);

CREATE UNIQUE INDEX unique_scheduled_item ON mod_manufacturing.scheduled_items USING btree (sales_order_item_id, sales_order_id, article_id);

CREATE UNIQUE INDEX unique_work_cycle_category_relation ON mod_manufacturing.work_cycle_categories USING btree (work_flow_id, work_cycle_id, from_article_category_id, to_article_category_id, location_id);

CREATE UNIQUE INDEX unique_work_order_quality_summary ON mod_manufacturing.work_order_quality_summary USING btree (work_order_id);

CREATE UNIQUE INDEX work_cycle_categories_pkey ON mod_manufacturing.work_cycle_categories USING btree (id);

CREATE UNIQUE INDEX work_cycles_barcode_key ON mod_manufacturing.work_cycles USING btree (barcode);

CREATE UNIQUE INDEX work_cycles_pkey ON mod_manufacturing.work_cycles USING btree (id);

CREATE UNIQUE INDEX work_flows_pkey ON mod_manufacturing.work_flows USING btree (id);

CREATE UNIQUE INDEX work_flows_work_cycles_pkey ON mod_manufacturing.work_flows_work_cycles USING btree (id);

CREATE UNIQUE INDEX work_flows_work_cycles_work_flow_id_work_cycle_id_key ON mod_manufacturing.work_flows_work_cycles USING btree (work_flow_id, work_cycle_id);

CREATE UNIQUE INDEX work_order_attachments_pkey ON mod_manufacturing.work_order_attachments USING btree (id);

CREATE UNIQUE INDEX work_order_quality_summary_pkey ON mod_manufacturing.work_order_quality_summary USING btree (id);

CREATE UNIQUE INDEX work_orders_barcode_key ON mod_manufacturing.work_orders USING btree (barcode);

CREATE UNIQUE INDEX work_orders_pkey ON mod_manufacturing.work_orders USING btree (id);

CREATE UNIQUE INDEX work_orders_task_id_key ON mod_manufacturing.work_orders USING btree (task_id);

CREATE UNIQUE INDEX work_steps_barcode_key ON mod_manufacturing.work_steps USING btree (barcode);

CREATE UNIQUE INDEX work_steps_pkey ON mod_manufacturing.work_steps USING btree (id);

CREATE UNIQUE INDEX workstations_barcode_key ON mod_manufacturing.workstations USING btree (barcode);

CREATE UNIQUE INDEX workstations_duplicate_barcode_key ON mod_manufacturing.workstations_duplicate USING btree (barcode);

CREATE UNIQUE INDEX workstations_duplicate_pkey ON mod_manufacturing.workstations_duplicate USING btree (id);

CREATE UNIQUE INDEX workstations_pkey ON mod_manufacturing.workstations USING btree (id);

CREATE UNIQUE INDEX department_notification_confi_department_id_notification_ty_key ON mod_pulse.department_notification_configs USING btree (department_id, notification_type, is_deleted);

CREATE UNIQUE INDEX department_notification_configs_pkey ON mod_pulse.department_notification_configs USING btree (id);

CREATE INDEX idx_notifications_fts ON mod_pulse.notifications USING gin (fts);

CREATE INDEX idx_pulse_chat_mentions ON mod_pulse.pulse_chat USING gin (mentions);

CREATE INDEX idx_pulse_chat_message_type ON mod_pulse.pulse_chat USING btree (message_type);

CREATE INDEX idx_pulse_chat_read_by ON mod_pulse.pulse_chat USING gin (read_by);

CREATE INDEX idx_pulse_chat_reply_to_id ON mod_pulse.pulse_chat USING btree (reply_to_id);

CREATE INDEX idx_pulse_progress_fts ON mod_pulse.pulse_progress USING gin (fts);

CREATE INDEX idx_pulse_slas_fts ON mod_pulse.pulse_slas USING gin (fts);

CREATE INDEX idx_pulses_conversation_type ON mod_pulse.pulses USING btree (conversation_type);

CREATE INDEX idx_pulses_department_id ON mod_pulse.pulses USING btree (department_id);

CREATE INDEX idx_pulses_fts ON mod_pulse.pulses USING gin (fts);

CREATE INDEX idx_pulses_last_message_at ON mod_pulse.pulses USING btree (last_message_at DESC);

CREATE INDEX idx_tasks_fts ON mod_pulse.tasks USING gin (fts);

CREATE UNIQUE INDEX notifications_barcode_key ON mod_pulse.notifications USING btree (barcode);

CREATE UNIQUE INDEX notifications_pkey ON mod_pulse.notifications USING btree (id);

CREATE UNIQUE INDEX pulse_chat_files_pkey ON mod_pulse.pulse_chat_files USING btree (id);

CREATE UNIQUE INDEX pulse_chat_pkey ON mod_pulse.pulse_chat USING btree (id);

CREATE UNIQUE INDEX pulse_checklists_barcode_key ON mod_pulse.pulse_checklists USING btree (barcode);

CREATE UNIQUE INDEX pulse_checklists_pkey ON mod_pulse.pulse_checklists USING btree (id);

CREATE UNIQUE INDEX pulse_comments_pkey ON mod_pulse.pulse_comments USING btree (id);

CREATE UNIQUE INDEX pulse_conversation_participants_pkey ON mod_pulse.pulse_conversation_participants USING btree (id);

CREATE UNIQUE INDEX pulse_progress_barcode_key ON mod_pulse.pulse_progress USING btree (barcode);

CREATE UNIQUE INDEX pulse_progress_pkey ON mod_pulse.pulse_progress USING btree (id);

CREATE UNIQUE INDEX pulse_slas_barcode_key ON mod_pulse.pulse_slas USING btree (barcode);

CREATE UNIQUE INDEX pulse_slas_pkey ON mod_pulse.pulse_slas USING btree (id);

CREATE UNIQUE INDEX pulses_barcode_key ON mod_pulse.pulses USING btree (barcode);

CREATE UNIQUE INDEX pulses_pkey ON mod_pulse.pulses USING btree (id);

CREATE UNIQUE INDEX tasks_barcode_key ON mod_pulse.tasks USING btree (barcode);

CREATE UNIQUE INDEX tasks_pkey ON mod_pulse.tasks USING btree (id);

CREATE UNIQUE INDEX conformity_documents_pkey ON mod_quality_control.conformity_documents USING btree (id);

CREATE UNIQUE INDEX defect_types_pkey ON mod_quality_control.defect_types USING btree (id);

CREATE INDEX idx_conformity_docs_qc_id ON mod_quality_control.conformity_documents USING btree (quality_control_id);

CREATE INDEX idx_conformity_docs_type ON mod_quality_control.conformity_documents USING btree (document_type);

CREATE INDEX idx_qc_checklist_qc_id ON mod_quality_control.quality_control_checklist_results USING btree (quality_control_id);

CREATE INDEX idx_qc_defects_qc_id ON mod_quality_control.quality_control_defects USING btree (quality_control_id);

CREATE INDEX idx_qc_measurements_qc_id ON mod_quality_control.quality_control_measurements USING btree (quality_control_id);

CREATE INDEX idx_supplier_returns_qc_id ON mod_quality_control.supplier_returns USING btree (quality_control_id);

CREATE INDEX idx_supplier_returns_status ON mod_quality_control.supplier_returns USING btree (return_status);

CREATE INDEX idx_supplier_returns_supplier_id ON mod_quality_control.supplier_returns USING btree (supplier_id);

CREATE UNIQUE INDEX measurement_parameters_pkey ON mod_quality_control.measurement_parameters USING btree (id);

CREATE UNIQUE INDEX quality_control_checklist_results_pkey ON mod_quality_control.quality_control_checklist_results USING btree (id);

CREATE UNIQUE INDEX quality_control_defects_pkey ON mod_quality_control.quality_control_defects USING btree (id);

CREATE UNIQUE INDEX quality_control_measurements_pkey ON mod_quality_control.quality_control_measurements USING btree (id);

CREATE UNIQUE INDEX supplier_returns_pkey ON mod_quality_control.supplier_returns USING btree (id);

CREATE UNIQUE INDEX unique_defect_code ON mod_quality_control.defect_types USING btree (code);

CREATE UNIQUE INDEX unique_document_number ON mod_quality_control.conformity_documents USING btree (document_number);

CREATE UNIQUE INDEX unique_parameter_code ON mod_quality_control.measurement_parameters USING btree (code);

CREATE UNIQUE INDEX unique_return_number ON mod_quality_control.supplier_returns USING btree (return_number);

CREATE UNIQUE INDEX batches_barcode_key ON mod_wms.batches USING btree (barcode);

CREATE UNIQUE INDEX batches_pkey ON mod_wms.batches USING btree (id);

CREATE UNIQUE INDEX box_contents_pkey ON mod_wms.box_contents USING btree (id);

CREATE UNIQUE INDEX box_contents_unique_item_per_box ON mod_wms.box_contents USING btree (shipment_box_id, shipment_item_id);

CREATE UNIQUE INDEX box_types_pkey ON mod_wms.box_types USING btree (id);

CREATE UNIQUE INDEX carton_contents_pkey ON mod_wms.carton_contents USING btree (id);

CREATE UNIQUE INDEX carton_contents_unique_item_per_carton ON mod_wms.carton_contents USING btree (shipment_carton_id, shipment_item_id);

CREATE UNIQUE INDEX carton_types_pkey ON mod_wms.carton_types USING btree (id);

CREATE INDEX idx_box_contents_box_id ON mod_wms.box_contents USING btree (shipment_box_id);

CREATE INDEX idx_box_contents_domain_id ON mod_wms.box_contents USING btree (domain_id);

CREATE INDEX idx_box_contents_item_id ON mod_wms.box_contents USING btree (shipment_item_id);

CREATE INDEX idx_box_types_domain_id ON mod_wms.box_types USING btree (domain_id);

CREATE INDEX idx_carton_contents_carton_id ON mod_wms.carton_contents USING btree (shipment_carton_id);

CREATE INDEX idx_carton_contents_domain_id ON mod_wms.carton_contents USING btree (domain_id);

CREATE INDEX idx_carton_contents_item_id ON mod_wms.carton_contents USING btree (shipment_item_id);

CREATE INDEX idx_carton_types_domain_id ON mod_wms.carton_types USING btree (domain_id);

CREATE INDEX idx_inventory_batch_lookup ON mod_wms.inventory USING btree (article_id, location_id, batch_id) WHERE (batch_id IS NOT NULL);

CREATE INDEX idx_inventory_domain ON mod_wms.inventory USING btree (domain_id);

CREATE INDEX idx_inventory_no_batch ON mod_wms.inventory USING btree (article_id, location_id) WHERE (batch_id IS NULL);

CREATE UNIQUE INDEX idx_inventory_no_batch_unique ON mod_wms.inventory USING btree (article_id, location_id) WHERE (batch_id IS NULL);

CREATE INDEX idx_pallet_contents_domain_id ON mod_wms.pallet_contents USING btree (domain_id);

CREATE INDEX idx_pallet_contents_item_id ON mod_wms.pallet_contents USING btree (shipment_item_id);

CREATE INDEX idx_pallet_contents_pallet_id ON mod_wms.pallet_contents USING btree (shipment_pallet_id);

CREATE INDEX idx_pallet_types_domain_id ON mod_wms.pallet_types USING btree (domain_id);

CREATE INDEX idx_receipt_items_is_moved ON mod_wms.receipt_items USING btree (is_moved) WHERE (is_moved = false);

CREATE INDEX idx_receipt_items_moved_date ON mod_wms.receipt_items USING btree (moved_date) WHERE (moved_date IS NOT NULL);

CREATE INDEX idx_receipts_invoice_number ON mod_wms.receipts USING btree (invoice_number);

CREATE INDEX idx_receipts_supplier_id ON mod_wms.receipts USING btree (supplier_id);

CREATE INDEX idx_receipts_supplier_order_number ON mod_wms.receipts USING btree (supplier_order_number);

CREATE INDEX idx_receipts_transport_document_number ON mod_wms.receipts USING btree (transport_document_number);

CREATE INDEX idx_shipment_attachments_shipment_id ON mod_wms.shipment_attachments USING btree (shipment_id);

CREATE INDEX idx_shipment_attachments_type ON mod_wms.shipment_attachments USING btree (attachment_type);

CREATE INDEX idx_shipment_boxes_domain_id ON mod_wms.shipment_boxes USING btree (domain_id);

CREATE INDEX idx_shipment_boxes_pallet_id ON mod_wms.shipment_boxes USING btree (shipment_pallet_id);

CREATE INDEX idx_shipment_boxes_shipment_id ON mod_wms.shipment_boxes USING btree (shipment_id) WHERE (shipment_id IS NOT NULL);

CREATE INDEX idx_shipment_cartons_domain_id ON mod_wms.shipment_cartons USING btree (domain_id);

CREATE INDEX idx_shipment_cartons_pallet_id ON mod_wms.shipment_cartons USING btree (shipment_pallet_id);

CREATE INDEX idx_shipment_item_addresses_address_type ON mod_wms.shipment_item_addresses USING btree (address_type);

CREATE INDEX idx_shipment_item_addresses_domain_id ON mod_wms.shipment_item_addresses USING btree (domain_id);

CREATE INDEX idx_shipment_item_addresses_is_deleted ON mod_wms.shipment_item_addresses USING btree (is_deleted);

CREATE INDEX idx_shipment_item_addresses_location ON mod_wms.shipment_item_addresses USING btree (city, state, country);

CREATE INDEX idx_shipment_item_addresses_primary ON mod_wms.shipment_item_addresses USING btree (shipment_item_id, address_type, is_primary);

CREATE INDEX idx_shipment_item_addresses_shipment_item_id ON mod_wms.shipment_item_addresses USING btree (shipment_item_id);

CREATE INDEX idx_shipment_pallets_domain_id ON mod_wms.shipment_pallets USING btree (domain_id);

CREATE INDEX idx_shipment_pallets_shipment_id ON mod_wms.shipment_pallets USING btree (shipment_id);

CREATE INDEX idx_shipment_sales_orders_domain_id ON mod_wms.shipment_sales_orders USING btree (domain_id);

CREATE INDEX idx_shipment_sales_orders_sales_order_id ON mod_wms.shipment_sales_orders USING btree (sales_order_id);

CREATE INDEX idx_shipment_sales_orders_shipment_id ON mod_wms.shipment_sales_orders USING btree (shipment_id);

CREATE INDEX idx_shipment_standalone_items_domain_id ON mod_wms.shipment_standalone_items USING btree (domain_id);

CREATE INDEX idx_shipment_standalone_items_item_id ON mod_wms.shipment_standalone_items USING btree (shipment_item_id);

CREATE INDEX idx_shipment_standalone_items_shipment_id ON mod_wms.shipment_standalone_items USING btree (shipment_id);

CREATE INDEX idx_shipments_archived_deleted ON mod_wms.shipments USING btree (is_archived, is_deleted);

CREATE INDEX idx_shipments_is_archived ON mod_wms.shipments USING btree (is_archived);

CREATE INDEX idx_stock_movements_internal_sales_order_id ON mod_wms.stock_movements USING btree (internal_sales_order_id) WHERE (internal_sales_order_id IS NOT NULL);

CREATE INDEX idx_stock_movements_origin_article_id ON mod_wms.stock_movements USING btree (origin_article_id) WHERE (origin_article_id IS NOT NULL);

CREATE INDEX idx_stock_movements_original_receipt_item_id ON mod_wms.stock_movements USING btree (original_receipt_item_id) WHERE (original_receipt_item_id IS NOT NULL);

CREATE INDEX idx_stock_movements_receipt_item_id ON mod_wms.stock_movements USING btree (receipt_item_id) WHERE (receipt_item_id IS NOT NULL);

CREATE INDEX idx_stock_movements_sales_order_id ON mod_wms.stock_movements USING btree (sales_order_id) WHERE (sales_order_id IS NOT NULL);

CREATE INDEX idx_stock_movements_unit_of_measure_id ON mod_wms.stock_movements USING btree (unit_of_measure_id);

CREATE INDEX idx_stock_movements_work_order_id ON mod_wms.stock_movements USING btree (work_order_id) WHERE (work_order_id IS NOT NULL);

CREATE UNIQUE INDEX inventory_article_id_location_id_batch_id_key ON mod_wms.inventory USING btree (article_id, location_id, batch_id);

CREATE UNIQUE INDEX inventory_limits_barcode_key ON mod_wms.inventory_limits USING btree (barcode);

CREATE UNIQUE INDEX inventory_limits_pkey ON mod_wms.inventory_limits USING btree (id);

CREATE UNIQUE INDEX inventory_pkey ON mod_wms.inventory_backup USING btree (article_id, location_id, batch_id);

CREATE UNIQUE INDEX inventory_pkey_new ON mod_wms.inventory USING btree (id);

CREATE UNIQUE INDEX locations_barcode_key ON mod_wms.locations USING btree (barcode);

CREATE UNIQUE INDEX locations_pkey ON mod_wms.locations USING btree (id);

CREATE UNIQUE INDEX pallet_contents_pkey ON mod_wms.pallet_contents USING btree (id);

CREATE UNIQUE INDEX pallet_contents_unique_item_per_pallet ON mod_wms.pallet_contents USING btree (shipment_pallet_id, shipment_item_id);

CREATE UNIQUE INDEX pallet_types_pkey ON mod_wms.pallet_types USING btree (id);

CREATE UNIQUE INDEX receipt_items_barcode_key ON mod_wms.receipt_items USING btree (barcode);

CREATE UNIQUE INDEX receipt_items_pkey ON mod_wms.receipt_items USING btree (id);

CREATE UNIQUE INDEX receipts_barcode_key ON mod_wms.receipts USING btree (barcode);

CREATE UNIQUE INDEX receipts_pkey ON mod_wms.receipts USING btree (id);

CREATE UNIQUE INDEX shipment_attachments_pkey ON mod_wms.shipment_attachments USING btree (id);

CREATE UNIQUE INDEX shipment_boxes_pkey ON mod_wms.shipment_boxes USING btree (id);

CREATE UNIQUE INDEX shipment_boxes_unique_number_per_pallet ON mod_wms.shipment_boxes USING btree (shipment_pallet_id, box_number) WHERE (shipment_pallet_id IS NOT NULL);

CREATE UNIQUE INDEX shipment_boxes_unique_number_per_shipment ON mod_wms.shipment_boxes USING btree (shipment_id, box_number) WHERE ((shipment_id IS NOT NULL) AND (shipment_pallet_id IS NULL));

CREATE UNIQUE INDEX shipment_cartons_pkey ON mod_wms.shipment_cartons USING btree (id);

CREATE UNIQUE INDEX shipment_cartons_unique_number_per_pallet ON mod_wms.shipment_cartons USING btree (shipment_pallet_id, carton_number);

CREATE UNIQUE INDEX shipment_item_addresses_pkey ON mod_wms.shipment_item_addresses USING btree (id);

CREATE UNIQUE INDEX shipment_items_barcode_key ON mod_wms.shipment_items USING btree (barcode);

CREATE UNIQUE INDEX shipment_items_pkey ON mod_wms.shipment_items USING btree (id);

CREATE UNIQUE INDEX shipment_pallets_pkey ON mod_wms.shipment_pallets USING btree (id);

CREATE UNIQUE INDEX shipment_pallets_unique_number_per_shipment ON mod_wms.shipment_pallets USING btree (shipment_id, pallet_number);

CREATE UNIQUE INDEX shipment_sales_orders_pkey ON mod_wms.shipment_sales_orders USING btree (id);

CREATE UNIQUE INDEX shipment_sales_orders_shipment_id_sales_order_id_key ON mod_wms.shipment_sales_orders USING btree (shipment_id, sales_order_id);

CREATE UNIQUE INDEX shipment_standalone_items_pkey ON mod_wms.shipment_standalone_items USING btree (id);

CREATE UNIQUE INDEX shipment_standalone_items_unique_item_per_shipment ON mod_wms.shipment_standalone_items USING btree (shipment_id, shipment_item_id);

CREATE UNIQUE INDEX shipments_barcode_key ON mod_wms.shipments USING btree (barcode);

CREATE UNIQUE INDEX shipments_pkey ON mod_wms.shipments USING btree (id);

CREATE UNIQUE INDEX shipments_shipment_number_key ON mod_wms.shipments USING btree (shipment_number);

CREATE UNIQUE INDEX stock_movements_barcode_key ON mod_wms.stock_movements USING btree (barcode);

CREATE UNIQUE INDEX stock_movements_pkey ON mod_wms.stock_movements USING btree (id);

CREATE UNIQUE INDEX uq_receipts_receipt_number_active ON mod_wms.receipts USING btree (receipt_number) WHERE (is_deleted = false);

CREATE UNIQUE INDEX warehouses_barcode_key ON mod_wms.warehouses USING btree (barcode);

CREATE UNIQUE INDEX warehouses_pkey ON mod_wms.warehouses USING btree (id);

alter table "mod_admin"."domain_modules" add constraint "domain_modules_pkey" PRIMARY KEY using index "domain_modules_pkey";

alter table "mod_admin"."domain_users" add constraint "domain_users_pkey" PRIMARY KEY using index "domain_users_pkey";

alter table "mod_admin"."domains" add constraint "domains_pkey" PRIMARY KEY using index "domains_pkey";

alter table "mod_admin"."user_profiles" add constraint "user_profiles_pkey" PRIMARY KEY using index "user_profiles_pkey";

alter table "mod_base"."announcements" add constraint "announcements_pkey" PRIMARY KEY using index "announcements_pkey";

alter table "mod_base"."article_categories" add constraint "article_categories_pkey" PRIMARY KEY using index "article_categories_pkey";

alter table "mod_base"."articles" add constraint "articles_pkey" PRIMARY KEY using index "articles_pkey";

alter table "mod_base"."bom_articles" add constraint "bom_articles_pkey" PRIMARY KEY using index "bom_articles_pkey";

alter table "mod_base"."custom_article_attachments" add constraint "custom_article_attachments_pkey" PRIMARY KEY using index "custom_article_attachments_pkey";

alter table "mod_base"."customer_addresses" add constraint "customer_addresses_pkey" PRIMARY KEY using index "customer_addresses_pkey";

alter table "mod_base"."customers" add constraint "customers_pkey" PRIMARY KEY using index "customers_pkey";

alter table "mod_base"."departments" add constraint "departments_pkey" PRIMARY KEY using index "departments_pkey";

alter table "mod_base"."employees" add constraint "employees_pkey" PRIMARY KEY using index "employees_pkey";

alter table "mod_base"."employees_departments" add constraint "employees_departments_pkey" PRIMARY KEY using index "employees_departments_pkey";

alter table "mod_base"."internal_sales_order_items" add constraint "internal_sales_order_items_pkey" PRIMARY KEY using index "internal_sales_order_items_pkey";

alter table "mod_base"."internal_sales_orders" add constraint "internal_sales_orders_pkey" PRIMARY KEY using index "internal_sales_orders_pkey";

alter table "mod_base"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "mod_base"."purchase_order_items" add constraint "purchase_order_items_pkey" PRIMARY KEY using index "purchase_order_items_pkey";

alter table "mod_base"."purchase_orders" add constraint "purchase_orders_pkey" PRIMARY KEY using index "purchase_orders_pkey";

alter table "mod_base"."quality_control" add constraint "quality_control_pkey" PRIMARY KEY using index "quality_control_pkey";

alter table "mod_base"."quality_control_attachments" add constraint "quality_control_attachments_pkey" PRIMARY KEY using index "quality_control_attachments_pkey";

alter table "mod_base"."quality_control_checklist_results" add constraint "quality_control_checklist_results_pkey" PRIMARY KEY using index "quality_control_checklist_results_pkey";

alter table "mod_base"."quality_control_types" add constraint "quality_control_types_pkey" PRIMARY KEY using index "quality_control_types_pkey";

alter table "mod_base"."quality_control_types_duplicate" add constraint "quality_control_types_duplicate_pkey" PRIMARY KEY using index "quality_control_types_duplicate_pkey";

alter table "mod_base"."report_template" add constraint "report_template_pkey" PRIMARY KEY using index "report_template_pkey";

alter table "mod_base"."sales_order_items" add constraint "sales_order_items_pkey" PRIMARY KEY using index "sales_order_items_pkey";

alter table "mod_base"."sales_orders" add constraint "sales_orders_pkey" PRIMARY KEY using index "sales_orders_pkey";

alter table "mod_base"."serial_number_counters" add constraint "serial_number_counters_pkey" PRIMARY KEY using index "serial_number_counters_pkey";

alter table "mod_base"."suppliers" add constraint "suppliers_pkey" PRIMARY KEY using index "suppliers_pkey";

alter table "mod_base"."units_of_measure" add constraint "units_of_measure_pkey" PRIMARY KEY using index "units_of_measure_pkey";

alter table "mod_datalayer"."fields" add constraint "fields_pkey" PRIMARY KEY using index "fields_pkey";

alter table "mod_datalayer"."main_menu" add constraint "main_menu_pkey" PRIMARY KEY using index "main_menu_pkey";

alter table "mod_datalayer"."modules" add constraint "modules_pkey" PRIMARY KEY using index "modules_pkey";

alter table "mod_datalayer"."page_categories" add constraint "page_categories_pkey" PRIMARY KEY using index "page_categories_pkey";

alter table "mod_datalayer"."pages" add constraint "pages_pkey" PRIMARY KEY using index "pages_pkey";

alter table "mod_datalayer"."pages_departments" add constraint "pages_departments_pkey" PRIMARY KEY using index "pages_departments_pkey";

alter table "mod_datalayer"."pages_menu_departments" add constraint "pages_menu_departments_pkey" PRIMARY KEY using index "pages_menu_departments_pkey";

alter table "mod_datalayer"."tables" add constraint "tables_pkey" PRIMARY KEY using index "tables_pkey";

alter table "mod_manufacturing"."coil_consumption" add constraint "coil_consumption_pkey" PRIMARY KEY using index "coil_consumption_pkey";

alter table "mod_manufacturing"."coil_production_plans" add constraint "coil_production_plans_pkey" PRIMARY KEY using index "coil_production_plans_pkey";

alter table "mod_manufacturing"."coils" add constraint "coils_pkey" PRIMARY KEY using index "coils_pkey";

alter table "mod_manufacturing"."departments" add constraint "departments_pkey" PRIMARY KEY using index "departments_pkey";

alter table "mod_manufacturing"."locations" add constraint "locations_pkey" PRIMARY KEY using index "locations_pkey";

alter table "mod_manufacturing"."plate_templates" add constraint "plate_templates_pkey" PRIMARY KEY using index "plate_templates_pkey";

alter table "mod_manufacturing"."production_logs" add constraint "production_logs_pkey" PRIMARY KEY using index "production_logs_pkey";

alter table "mod_manufacturing"."recipes" add constraint "recipes_pkey" PRIMARY KEY using index "recipes_pkey";

alter table "mod_manufacturing"."scheduled_items" add constraint "scheduled_items_pkey" PRIMARY KEY using index "scheduled_items_pkey";

alter table "mod_manufacturing"."work_cycle_categories" add constraint "work_cycle_categories_pkey" PRIMARY KEY using index "work_cycle_categories_pkey";

alter table "mod_manufacturing"."work_cycles" add constraint "work_cycles_pkey" PRIMARY KEY using index "work_cycles_pkey";

alter table "mod_manufacturing"."work_flows" add constraint "work_flows_pkey" PRIMARY KEY using index "work_flows_pkey";

alter table "mod_manufacturing"."work_flows_work_cycles" add constraint "work_flows_work_cycles_pkey" PRIMARY KEY using index "work_flows_work_cycles_pkey";

alter table "mod_manufacturing"."work_order_attachments" add constraint "work_order_attachments_pkey" PRIMARY KEY using index "work_order_attachments_pkey";

alter table "mod_manufacturing"."work_order_quality_summary" add constraint "work_order_quality_summary_pkey" PRIMARY KEY using index "work_order_quality_summary_pkey";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_pkey" PRIMARY KEY using index "work_orders_pkey";

alter table "mod_manufacturing"."work_steps" add constraint "work_steps_pkey" PRIMARY KEY using index "work_steps_pkey";

alter table "mod_manufacturing"."workstations" add constraint "workstations_pkey" PRIMARY KEY using index "workstations_pkey";

alter table "mod_manufacturing"."workstations_duplicate" add constraint "workstations_duplicate_pkey" PRIMARY KEY using index "workstations_duplicate_pkey";

alter table "mod_pulse"."department_notification_configs" add constraint "department_notification_configs_pkey" PRIMARY KEY using index "department_notification_configs_pkey";

alter table "mod_pulse"."notifications" add constraint "notifications_pkey" PRIMARY KEY using index "notifications_pkey";

alter table "mod_pulse"."pulse_chat" add constraint "pulse_chat_pkey" PRIMARY KEY using index "pulse_chat_pkey";

alter table "mod_pulse"."pulse_chat_files" add constraint "pulse_chat_files_pkey" PRIMARY KEY using index "pulse_chat_files_pkey";

alter table "mod_pulse"."pulse_checklists" add constraint "pulse_checklists_pkey" PRIMARY KEY using index "pulse_checklists_pkey";

alter table "mod_pulse"."pulse_comments" add constraint "pulse_comments_pkey" PRIMARY KEY using index "pulse_comments_pkey";

alter table "mod_pulse"."pulse_conversation_participants" add constraint "pulse_conversation_participants_pkey" PRIMARY KEY using index "pulse_conversation_participants_pkey";

alter table "mod_pulse"."pulse_progress" add constraint "pulse_progress_pkey" PRIMARY KEY using index "pulse_progress_pkey";

alter table "mod_pulse"."pulse_slas" add constraint "pulse_slas_pkey" PRIMARY KEY using index "pulse_slas_pkey";

alter table "mod_pulse"."pulses" add constraint "pulses_pkey" PRIMARY KEY using index "pulses_pkey";

alter table "mod_pulse"."tasks" add constraint "tasks_pkey" PRIMARY KEY using index "tasks_pkey";

alter table "mod_quality_control"."conformity_documents" add constraint "conformity_documents_pkey" PRIMARY KEY using index "conformity_documents_pkey";

alter table "mod_quality_control"."defect_types" add constraint "defect_types_pkey" PRIMARY KEY using index "defect_types_pkey";

alter table "mod_quality_control"."measurement_parameters" add constraint "measurement_parameters_pkey" PRIMARY KEY using index "measurement_parameters_pkey";

alter table "mod_quality_control"."quality_control_checklist_results" add constraint "quality_control_checklist_results_pkey" PRIMARY KEY using index "quality_control_checklist_results_pkey";

alter table "mod_quality_control"."quality_control_defects" add constraint "quality_control_defects_pkey" PRIMARY KEY using index "quality_control_defects_pkey";

alter table "mod_quality_control"."quality_control_measurements" add constraint "quality_control_measurements_pkey" PRIMARY KEY using index "quality_control_measurements_pkey";

alter table "mod_quality_control"."supplier_returns" add constraint "supplier_returns_pkey" PRIMARY KEY using index "supplier_returns_pkey";

alter table "mod_wms"."batches" add constraint "batches_pkey" PRIMARY KEY using index "batches_pkey";

alter table "mod_wms"."box_contents" add constraint "box_contents_pkey" PRIMARY KEY using index "box_contents_pkey";

alter table "mod_wms"."box_types" add constraint "box_types_pkey" PRIMARY KEY using index "box_types_pkey";

alter table "mod_wms"."carton_contents" add constraint "carton_contents_pkey" PRIMARY KEY using index "carton_contents_pkey";

alter table "mod_wms"."carton_types" add constraint "carton_types_pkey" PRIMARY KEY using index "carton_types_pkey";

alter table "mod_wms"."inventory" add constraint "inventory_pkey_new" PRIMARY KEY using index "inventory_pkey_new";

alter table "mod_wms"."inventory_backup" add constraint "inventory_pkey" PRIMARY KEY using index "inventory_pkey";

alter table "mod_wms"."inventory_limits" add constraint "inventory_limits_pkey" PRIMARY KEY using index "inventory_limits_pkey";

alter table "mod_wms"."locations" add constraint "locations_pkey" PRIMARY KEY using index "locations_pkey";

alter table "mod_wms"."pallet_contents" add constraint "pallet_contents_pkey" PRIMARY KEY using index "pallet_contents_pkey";

alter table "mod_wms"."pallet_types" add constraint "pallet_types_pkey" PRIMARY KEY using index "pallet_types_pkey";

alter table "mod_wms"."receipt_items" add constraint "receipt_items_pkey" PRIMARY KEY using index "receipt_items_pkey";

alter table "mod_wms"."receipts" add constraint "receipts_pkey" PRIMARY KEY using index "receipts_pkey";

alter table "mod_wms"."shipment_attachments" add constraint "shipment_attachments_pkey" PRIMARY KEY using index "shipment_attachments_pkey";

alter table "mod_wms"."shipment_boxes" add constraint "shipment_boxes_pkey" PRIMARY KEY using index "shipment_boxes_pkey";

alter table "mod_wms"."shipment_cartons" add constraint "shipment_cartons_pkey" PRIMARY KEY using index "shipment_cartons_pkey";

alter table "mod_wms"."shipment_item_addresses" add constraint "shipment_item_addresses_pkey" PRIMARY KEY using index "shipment_item_addresses_pkey";

alter table "mod_wms"."shipment_items" add constraint "shipment_items_pkey" PRIMARY KEY using index "shipment_items_pkey";

alter table "mod_wms"."shipment_pallets" add constraint "shipment_pallets_pkey" PRIMARY KEY using index "shipment_pallets_pkey";

alter table "mod_wms"."shipment_sales_orders" add constraint "shipment_sales_orders_pkey" PRIMARY KEY using index "shipment_sales_orders_pkey";

alter table "mod_wms"."shipment_standalone_items" add constraint "shipment_standalone_items_pkey" PRIMARY KEY using index "shipment_standalone_items_pkey";

alter table "mod_wms"."shipments" add constraint "shipments_pkey" PRIMARY KEY using index "shipments_pkey";

alter table "mod_wms"."stock_movements" add constraint "stock_movements_pkey" PRIMARY KEY using index "stock_movements_pkey";

alter table "mod_wms"."warehouses" add constraint "warehouses_pkey" PRIMARY KEY using index "warehouses_pkey";

alter table "mod_admin"."domain_modules" add constraint "domain_modules_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_admin"."domain_modules" validate constraint "domain_modules_created_by_fkey";

alter table "mod_admin"."domain_modules" add constraint "domain_modules_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE CASCADE not valid;

alter table "mod_admin"."domain_modules" validate constraint "domain_modules_domain_id_fkey";

alter table "mod_admin"."domain_modules" add constraint "domain_modules_domain_id_module_id_key" UNIQUE using index "domain_modules_domain_id_module_id_key";

alter table "mod_admin"."domain_modules" add constraint "domain_modules_module_id_fkey" FOREIGN KEY (module_id) REFERENCES mod_datalayer.modules(id) ON DELETE CASCADE not valid;

alter table "mod_admin"."domain_modules" validate constraint "domain_modules_module_id_fkey";

alter table "mod_admin"."domain_modules" add constraint "domain_modules_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_admin"."domain_modules" validate constraint "domain_modules_updated_by_fkey";

alter table "mod_admin"."domain_users" add constraint "domain_users_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_admin"."domain_users" validate constraint "domain_users_created_by_fkey";

alter table "mod_admin"."domain_users" add constraint "domain_users_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_admin"."domain_users" validate constraint "domain_users_domain_id_fkey";

alter table "mod_admin"."domain_users" add constraint "domain_users_role_check" CHECK ((role = ANY (ARRAY['superAdmin'::text, 'admin'::text, 'user'::text, 'guest'::text]))) not valid;

alter table "mod_admin"."domain_users" validate constraint "domain_users_role_check";

alter table "mod_admin"."domain_users" add constraint "domain_users_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_admin"."domain_users" validate constraint "domain_users_updated_by_fkey";

alter table "mod_admin"."domain_users" add constraint "domain_users_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_admin"."domain_users" validate constraint "domain_users_user_id_fkey";

alter table "mod_admin"."domains" add constraint "domains_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_admin"."domains" validate constraint "domains_created_by_fkey";

alter table "mod_admin"."domains" add constraint "domains_key_key" UNIQUE using index "domains_key_key";

alter table "mod_admin"."domains" add constraint "domains_name_key" UNIQUE using index "domains_name_key";

alter table "mod_admin"."domains" add constraint "domains_parent_domain_id_fkey" FOREIGN KEY (parent_domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_admin"."domains" validate constraint "domains_parent_domain_id_fkey";

alter table "mod_admin"."domains" add constraint "domains_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_admin"."domains" validate constraint "domains_updated_by_fkey";

alter table "mod_admin"."user_profiles" add constraint "button_color_check" CHECK ((button_color = ANY (ARRAY['primary'::text, 'secondary'::text, 'tertiary'::text]))) not valid;

alter table "mod_admin"."user_profiles" validate constraint "button_color_check";

alter table "mod_admin"."user_profiles" add constraint "custom_primary_color_hex_check" CHECK (((custom_primary_color IS NULL) OR (custom_primary_color ~ '^#[0-9A-Fa-f]{6}$'::text))) not valid;

alter table "mod_admin"."user_profiles" validate constraint "custom_primary_color_hex_check";

alter table "mod_admin"."user_profiles" add constraint "custom_secondary_color_hex_check" CHECK (((custom_secondary_color IS NULL) OR (custom_secondary_color ~ '^#[0-9A-Fa-f]{6}$'::text))) not valid;

alter table "mod_admin"."user_profiles" validate constraint "custom_secondary_color_hex_check";

alter table "mod_admin"."user_profiles" add constraint "custom_tertiary_color_hex_check" CHECK (((custom_tertiary_color IS NULL) OR (custom_tertiary_color ~ '^#[0-9A-Fa-f]{6}$'::text))) not valid;

alter table "mod_admin"."user_profiles" validate constraint "custom_tertiary_color_hex_check";

alter table "mod_admin"."user_profiles" add constraint "firstName_length" CHECK ((char_length("firstName") >= 1)) not valid;

alter table "mod_admin"."user_profiles" validate constraint "firstName_length";

alter table "mod_admin"."user_profiles" add constraint "lastName_length" CHECK ((char_length("lastName") >= 1)) not valid;

alter table "mod_admin"."user_profiles" validate constraint "lastName_length";

alter table "mod_admin"."user_profiles" add constraint "theme_mode_check" CHECK ((theme_mode = ANY (ARRAY['light'::text, 'dark'::text, 'auto'::text]))) not valid;

alter table "mod_admin"."user_profiles" validate constraint "theme_mode_check";

alter table "mod_admin"."user_profiles" add constraint "user_profiles_barcode_key" UNIQUE using index "user_profiles_barcode_key";

alter table "mod_admin"."user_profiles" add constraint "user_profiles_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_admin"."user_profiles" validate constraint "user_profiles_created_by_fkey";

alter table "mod_admin"."user_profiles" add constraint "user_profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "mod_admin"."user_profiles" validate constraint "user_profiles_id_fkey";

alter table "mod_admin"."user_profiles" add constraint "user_profiles_name_check" CHECK ((((char_length("firstName") >= 1) OR ("firstName" IS NULL)) AND ((char_length("lastName") >= 1) OR ("lastName" IS NULL)))) not valid;

alter table "mod_admin"."user_profiles" validate constraint "user_profiles_name_check";

alter table "mod_admin"."user_profiles" add constraint "user_profiles_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_admin"."user_profiles" validate constraint "user_profiles_updated_by_fkey";

alter table "mod_base"."announcements" add constraint "announcements_barcode_key" UNIQUE using index "announcements_barcode_key";

alter table "mod_base"."announcements" add constraint "announcements_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."announcements" validate constraint "announcements_created_by_fkey";

alter table "mod_base"."announcements" add constraint "announcements_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."announcements" validate constraint "announcements_domain_id_fkey";

alter table "mod_base"."announcements" add constraint "announcements_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."announcements" validate constraint "announcements_updated_by_fkey";

alter table "mod_base"."article_categories" add constraint "article_categories_barcode_key" UNIQUE using index "article_categories_barcode_key";

alter table "mod_base"."article_categories" add constraint "article_categories_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."article_categories" validate constraint "article_categories_created_by_fkey";

alter table "mod_base"."article_categories" add constraint "article_categories_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."article_categories" validate constraint "article_categories_domain_id_fkey";

alter table "mod_base"."article_categories" add constraint "article_categories_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."article_categories" validate constraint "article_categories_updated_by_fkey";

alter table "mod_base"."articles" add constraint "articles_article_type_check" CHECK ((article_type = ANY (ARRAY['raw_material'::text, 'semi_finished'::text, 'finished_product'::text]))) not valid;

alter table "mod_base"."articles" validate constraint "articles_article_type_check";

alter table "mod_base"."articles" add constraint "articles_barcode_key" UNIQUE using index "articles_barcode_key";

alter table "mod_base"."articles" add constraint "articles_category_id_fkey" FOREIGN KEY (category_id) REFERENCES mod_base.article_categories(id) not valid;

alter table "mod_base"."articles" validate constraint "articles_category_id_fkey";

alter table "mod_base"."articles" add constraint "articles_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."articles" validate constraint "articles_created_by_fkey";

alter table "mod_base"."articles" add constraint "articles_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."articles" validate constraint "articles_domain_id_fkey";

alter table "mod_base"."articles" add constraint "articles_max_stock_check" CHECK ((max_stock >= 0)) not valid;

alter table "mod_base"."articles" validate constraint "articles_max_stock_check";

alter table "mod_base"."articles" add constraint "articles_min_stock_check" CHECK ((min_stock >= 0)) not valid;

alter table "mod_base"."articles" validate constraint "articles_min_stock_check";

alter table "mod_base"."articles" add constraint "articles_parent_article_id_fkey" FOREIGN KEY (parent_article_id) REFERENCES mod_base.articles(id) ON DELETE SET NULL not valid;

alter table "mod_base"."articles" validate constraint "articles_parent_article_id_fkey";

alter table "mod_base"."articles" add constraint "articles_sku_key" UNIQUE using index "articles_sku_key";

alter table "mod_base"."articles" add constraint "articles_transaction_type_check" CHECK ((transaction_type = ANY (ARRAY['purchase'::text, 'sale'::text, 'internal'::text]))) not valid;

alter table "mod_base"."articles" validate constraint "articles_transaction_type_check";

alter table "mod_base"."articles" add constraint "articles_type_check" CHECK ((((type)::text = ANY (ARRAY[('heat_exchanger'::character varying)::text, ('pump'::character varying)::text, ('dirt_separator'::character varying)::text, ('brazed'::character varying)::text, ('transport'::character varying)::text, ('custom'::character varying)::text, ('plate_material'::character varying)::text, ('gasket_material'::character varying)::text, ('manifold_material'::character varying)::text, ('frame_material'::character varying)::text, ('heat_exchanger_model'::character varying)::text, ('pump_series'::character varying)::text, ('pump_model'::character varying)::text, ('component_article'::character varying)::text, ('other'::character varying)::text])) OR (type IS NULL))) not valid;

alter table "mod_base"."articles" validate constraint "articles_type_check";

alter table "mod_base"."articles" add constraint "articles_unit_of_measure_id_fkey" FOREIGN KEY (unit_of_measure_id) REFERENCES mod_base.units_of_measure(id) not valid;

alter table "mod_base"."articles" validate constraint "articles_unit_of_measure_id_fkey";

alter table "mod_base"."articles" add constraint "articles_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."articles" validate constraint "articles_updated_by_fkey";

alter table "mod_base"."bom_articles" add constraint "bom_articles_position_check" CHECK ((("position" IS NULL) OR ("position" >= 0))) not valid;

alter table "mod_base"."bom_articles" validate constraint "bom_articles_position_check";

alter table "mod_base"."bom_articles" add constraint "bom_articles_quantity_check" CHECK ((quantity > 0)) not valid;

alter table "mod_base"."bom_articles" validate constraint "bom_articles_quantity_check";

alter table "mod_base"."bom_articles" add constraint "bom_articles_unique_relationship" UNIQUE using index "bom_articles_unique_relationship";

alter table "mod_base"."bom_articles" add constraint "fk_bom_articles_component_article" FOREIGN KEY (component_article_id) REFERENCES mod_base.articles(id) ON DELETE CASCADE not valid;

alter table "mod_base"."bom_articles" validate constraint "fk_bom_articles_component_article";

alter table "mod_base"."bom_articles" add constraint "fk_bom_articles_parent_article" FOREIGN KEY (parent_article_id) REFERENCES mod_base.articles(id) ON DELETE CASCADE not valid;

alter table "mod_base"."bom_articles" validate constraint "fk_bom_articles_parent_article";

alter table "mod_base"."custom_article_attachments" add constraint "custom_article_attachments_article_id_fkey" FOREIGN KEY (article_id) REFERENCES mod_base.articles(id) ON DELETE CASCADE not valid;

alter table "mod_base"."custom_article_attachments" validate constraint "custom_article_attachments_article_id_fkey";

alter table "mod_base"."custom_article_attachments" add constraint "custom_article_attachments_internal_sales_order_id_fkey" FOREIGN KEY (internal_sales_order_id) REFERENCES mod_base.internal_sales_orders(id) ON DELETE CASCADE not valid;

alter table "mod_base"."custom_article_attachments" validate constraint "custom_article_attachments_internal_sales_order_id_fkey";

alter table "mod_base"."custom_article_attachments" add constraint "custom_article_attachments_order_required" CHECK ((((sales_order_id IS NOT NULL) AND (internal_sales_order_id IS NULL)) OR ((sales_order_id IS NULL) AND (internal_sales_order_id IS NOT NULL)))) not valid;

alter table "mod_base"."custom_article_attachments" validate constraint "custom_article_attachments_order_required";

alter table "mod_base"."custom_article_attachments" add constraint "custom_article_attachments_sales_order_id_fkey" FOREIGN KEY (sales_order_id) REFERENCES mod_base.sales_orders(id) ON DELETE CASCADE not valid;

alter table "mod_base"."custom_article_attachments" validate constraint "custom_article_attachments_sales_order_id_fkey";

alter table "mod_base"."customer_addresses" add constraint "customer_addresses_address_type_check" CHECK ((address_type = ANY (ARRAY['billing'::text, 'shipping'::text, 'delivery'::text, 'general'::text]))) not valid;

alter table "mod_base"."customer_addresses" validate constraint "customer_addresses_address_type_check";

alter table "mod_base"."customer_addresses" add constraint "customer_addresses_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."customer_addresses" validate constraint "customer_addresses_created_by_fkey";

alter table "mod_base"."customer_addresses" add constraint "customer_addresses_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES mod_base.customers(id) ON DELETE CASCADE not valid;

alter table "mod_base"."customer_addresses" validate constraint "customer_addresses_customer_id_fkey";

alter table "mod_base"."customer_addresses" add constraint "customer_addresses_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE CASCADE not valid;

alter table "mod_base"."customer_addresses" validate constraint "customer_addresses_domain_id_fkey";

alter table "mod_base"."customer_addresses" add constraint "customer_addresses_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."customer_addresses" validate constraint "customer_addresses_updated_by_fkey";

alter table "mod_base"."customers" add constraint "customers_barcode_key" UNIQUE using index "customers_barcode_key";

alter table "mod_base"."customers" add constraint "customers_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."customers" validate constraint "customers_created_by_fkey";

alter table "mod_base"."customers" add constraint "customers_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."customers" validate constraint "customers_domain_id_fkey";

alter table "mod_base"."customers" add constraint "customers_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."customers" validate constraint "customers_updated_by_fkey";

alter table "mod_base"."departments" add constraint "departments_barcode_key" UNIQUE using index "departments_barcode_key";

alter table "mod_base"."departments" add constraint "departments_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."departments" validate constraint "departments_created_by_fkey";

alter table "mod_base"."departments" add constraint "departments_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."departments" validate constraint "departments_domain_id_fkey";

alter table "mod_base"."departments" add constraint "departments_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."departments" validate constraint "departments_updated_by_fkey";

alter table "mod_base"."employees" add constraint "employees_barcode_key" UNIQUE using index "employees_barcode_key";

alter table "mod_base"."employees" add constraint "employees_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."employees" validate constraint "employees_created_by_fkey";

alter table "mod_base"."employees" add constraint "employees_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."employees" validate constraint "employees_domain_id_fkey";

alter table "mod_base"."employees" add constraint "employees_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "mod_base"."employees" validate constraint "employees_id_fkey";

alter table "mod_base"."employees" add constraint "employees_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."employees" validate constraint "employees_updated_by_fkey";

alter table "mod_base"."employees_departments" add constraint "employees_departments_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."employees_departments" validate constraint "employees_departments_created_by_fkey";

alter table "mod_base"."employees_departments" add constraint "employees_departments_department_id_fkey" FOREIGN KEY (department_id) REFERENCES mod_base.departments(id) ON DELETE SET NULL not valid;

alter table "mod_base"."employees_departments" validate constraint "employees_departments_department_id_fkey";

alter table "mod_base"."employees_departments" add constraint "employees_departments_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."employees_departments" validate constraint "employees_departments_domain_id_fkey";

alter table "mod_base"."employees_departments" add constraint "employees_departments_employee_id_fkey" FOREIGN KEY (employee_id) REFERENCES mod_base.employees(id) ON DELETE SET NULL not valid;

alter table "mod_base"."employees_departments" validate constraint "employees_departments_employee_id_fkey";

alter table "mod_base"."employees_departments" add constraint "employees_departments_role_check" CHECK ((role = ANY (ARRAY['manager'::text, 'worker'::text]))) not valid;

alter table "mod_base"."employees_departments" validate constraint "employees_departments_role_check";

alter table "mod_base"."employees_departments" add constraint "employees_departments_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."employees_departments" validate constraint "employees_departments_updated_by_fkey";

alter table "mod_base"."internal_sales_order_items" add constraint "internal_sales_order_items_article_id_fkey" FOREIGN KEY (article_id) REFERENCES mod_base.articles(id) not valid;

alter table "mod_base"."internal_sales_order_items" validate constraint "internal_sales_order_items_article_id_fkey";

alter table "mod_base"."internal_sales_order_items" add constraint "internal_sales_order_items_barcode_key" UNIQUE using index "internal_sales_order_items_barcode_key";

alter table "mod_base"."internal_sales_order_items" add constraint "internal_sales_order_items_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."internal_sales_order_items" validate constraint "internal_sales_order_items_created_by_fkey";

alter table "mod_base"."internal_sales_order_items" add constraint "internal_sales_order_items_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."internal_sales_order_items" validate constraint "internal_sales_order_items_domain_id_fkey";

alter table "mod_base"."internal_sales_order_items" add constraint "internal_sales_order_items_internal_sales_order_id_fkey" FOREIGN KEY (sales_order_id) REFERENCES mod_base.internal_sales_orders(id) ON DELETE CASCADE not valid;

alter table "mod_base"."internal_sales_order_items" validate constraint "internal_sales_order_items_internal_sales_order_id_fkey";

alter table "mod_base"."internal_sales_order_items" add constraint "internal_sales_order_items_parent_sales_order_item_id_fkey" FOREIGN KEY (parent_sales_order_item_id) REFERENCES mod_base.internal_sales_order_items(id) ON DELETE CASCADE not valid;

alter table "mod_base"."internal_sales_order_items" validate constraint "internal_sales_order_items_parent_sales_order_item_id_fkey";

alter table "mod_base"."internal_sales_order_items" add constraint "internal_sales_order_items_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."internal_sales_order_items" validate constraint "internal_sales_order_items_updated_by_fkey";

alter table "mod_base"."internal_sales_orders" add constraint "internal_sales_orders_barcode_key" UNIQUE using index "internal_sales_orders_barcode_key";

alter table "mod_base"."internal_sales_orders" add constraint "internal_sales_orders_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."internal_sales_orders" validate constraint "internal_sales_orders_created_by_fkey";

alter table "mod_base"."internal_sales_orders" add constraint "internal_sales_orders_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES mod_base.customers(id) not valid;

alter table "mod_base"."internal_sales_orders" validate constraint "internal_sales_orders_customer_id_fkey";

alter table "mod_base"."internal_sales_orders" add constraint "internal_sales_orders_customer_or_internal_check" CHECK ((((customer_id IS NOT NULL) AND (is_internal = false)) OR ((customer_id IS NULL) AND (is_internal = true)))) not valid;

alter table "mod_base"."internal_sales_orders" validate constraint "internal_sales_orders_customer_or_internal_check";

alter table "mod_base"."internal_sales_orders" add constraint "internal_sales_orders_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."internal_sales_orders" validate constraint "internal_sales_orders_domain_id_fkey";

alter table "mod_base"."internal_sales_orders" add constraint "internal_sales_orders_id_fkey" FOREIGN KEY (id) REFERENCES mod_pulse.pulses(id) ON DELETE CASCADE not valid;

alter table "mod_base"."internal_sales_orders" validate constraint "internal_sales_orders_id_fkey";

alter table "mod_base"."internal_sales_orders" add constraint "internal_sales_orders_sales_order_number_key" UNIQUE using index "internal_sales_orders_sales_order_number_key";

alter table "mod_base"."internal_sales_orders" add constraint "internal_sales_orders_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'active'::text, 'processing'::text, 'ready_for_packing'::text, 'ready_for_delivery'::text, 'completed'::text, 'paused'::text, 'canceled'::text]))) not valid;

alter table "mod_base"."internal_sales_orders" validate constraint "internal_sales_orders_status_check";

alter table "mod_base"."internal_sales_orders" add constraint "internal_sales_orders_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."internal_sales_orders" validate constraint "internal_sales_orders_updated_by_fkey";

alter table "mod_base"."profiles" add constraint "profiles_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."profiles" validate constraint "profiles_created_by_fkey";

alter table "mod_base"."profiles" add constraint "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "mod_base"."profiles" validate constraint "profiles_id_fkey";

alter table "mod_base"."profiles" add constraint "profiles_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."profiles" validate constraint "profiles_updated_by_fkey";

alter table "mod_base"."purchase_order_items" add constraint "purchase_order_items_article_id_fkey" FOREIGN KEY (article_id) REFERENCES mod_base.articles(id) not valid;

alter table "mod_base"."purchase_order_items" validate constraint "purchase_order_items_article_id_fkey";

alter table "mod_base"."purchase_order_items" add constraint "purchase_order_items_barcode_key" UNIQUE using index "purchase_order_items_barcode_key";

alter table "mod_base"."purchase_order_items" add constraint "purchase_order_items_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."purchase_order_items" validate constraint "purchase_order_items_created_by_fkey";

alter table "mod_base"."purchase_order_items" add constraint "purchase_order_items_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."purchase_order_items" validate constraint "purchase_order_items_domain_id_fkey";

alter table "mod_base"."purchase_order_items" add constraint "purchase_order_items_purchase_order_id_fkey" FOREIGN KEY (purchase_order_id) REFERENCES mod_base.purchase_orders(id) ON DELETE CASCADE not valid;

alter table "mod_base"."purchase_order_items" validate constraint "purchase_order_items_purchase_order_id_fkey";

alter table "mod_base"."purchase_order_items" add constraint "purchase_order_items_quantity_defect_check" CHECK ((quantity_defect >= 0)) not valid;

alter table "mod_base"."purchase_order_items" validate constraint "purchase_order_items_quantity_defect_check";

alter table "mod_base"."purchase_order_items" add constraint "purchase_order_items_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."purchase_order_items" validate constraint "purchase_order_items_updated_by_fkey";

alter table "mod_base"."purchase_orders" add constraint "purchase_orders_barcode_key" UNIQUE using index "purchase_orders_barcode_key";

alter table "mod_base"."purchase_orders" add constraint "purchase_orders_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."purchase_orders" validate constraint "purchase_orders_created_by_fkey";

alter table "mod_base"."purchase_orders" add constraint "purchase_orders_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."purchase_orders" validate constraint "purchase_orders_domain_id_fkey";

alter table "mod_base"."purchase_orders" add constraint "purchase_orders_id_fkey" FOREIGN KEY (id) REFERENCES mod_pulse.pulses(id) ON DELETE CASCADE not valid;

alter table "mod_base"."purchase_orders" validate constraint "purchase_orders_id_fkey";

alter table "mod_base"."purchase_orders" add constraint "purchase_orders_purchase_order_number_key" UNIQUE using index "purchase_orders_purchase_order_number_key";

alter table "mod_base"."purchase_orders" add constraint "purchase_orders_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'processing'::text, 'completed'::text, 'canceled'::text]))) not valid;

alter table "mod_base"."purchase_orders" validate constraint "purchase_orders_status_check";

alter table "mod_base"."purchase_orders" add constraint "purchase_orders_supplier_id_fkey" FOREIGN KEY (supplier_id) REFERENCES mod_base.suppliers(id) not valid;

alter table "mod_base"."purchase_orders" validate constraint "purchase_orders_supplier_id_fkey";

alter table "mod_base"."purchase_orders" add constraint "purchase_orders_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."purchase_orders" validate constraint "purchase_orders_updated_by_fkey";

alter table "mod_base"."quality_control" add constraint "fk_quality_control_purchase_order_item" FOREIGN KEY (purchase_order_item_id) REFERENCES mod_base.purchase_order_items(id) ON DELETE SET NULL not valid;

alter table "mod_base"."quality_control" validate constraint "fk_quality_control_purchase_order_item";

alter table "mod_base"."quality_control" add constraint "quality_control_article_id_fkey" FOREIGN KEY (article_id) REFERENCES mod_base.articles(id) ON DELETE SET NULL not valid;

alter table "mod_base"."quality_control" validate constraint "quality_control_article_id_fkey";

alter table "mod_base"."quality_control" add constraint "quality_control_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."quality_control" validate constraint "quality_control_created_by_fkey";

alter table "mod_base"."quality_control" add constraint "quality_control_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."quality_control" validate constraint "quality_control_domain_id_fkey";

alter table "mod_base"."quality_control" add constraint "quality_control_inspection_level_check" CHECK ((inspection_level = ANY (ARRAY['NORMAL'::text, 'TIGHTENED'::text, 'REDUCED'::text]))) not valid;

alter table "mod_base"."quality_control" validate constraint "quality_control_inspection_level_check";

alter table "mod_base"."quality_control" add constraint "quality_control_inspector_id_fkey" FOREIGN KEY (inspector_id) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_base"."quality_control" validate constraint "quality_control_inspector_id_fkey";

alter table "mod_base"."quality_control" add constraint "quality_control_quality_control_type_id_fkey" FOREIGN KEY (quality_control_type_id) REFERENCES mod_base.quality_control_types(id) ON DELETE SET NULL not valid;

alter table "mod_base"."quality_control" validate constraint "quality_control_quality_control_type_id_fkey";

alter table "mod_base"."quality_control" add constraint "quality_control_receipt_id_fkey" FOREIGN KEY (receipt_id) REFERENCES mod_wms.receipts(id) ON DELETE SET NULL not valid;

alter table "mod_base"."quality_control" validate constraint "quality_control_receipt_id_fkey";

alter table "mod_base"."quality_control" add constraint "quality_control_receipt_item_id_fkey" FOREIGN KEY (receipt_item_id) REFERENCES mod_wms.receipt_items(id) ON DELETE SET NULL not valid;

alter table "mod_base"."quality_control" validate constraint "quality_control_receipt_item_id_fkey";

alter table "mod_base"."quality_control" add constraint "quality_control_reference_type_check" CHECK ((reference_type = ANY (ARRAY['PURCHASE_ORDER'::text, 'WORK_ORDER'::text, 'SALES_ORDER'::text, 'RECEIPT'::text]))) not valid;

alter table "mod_base"."quality_control" validate constraint "quality_control_reference_type_check";

alter table "mod_base"."quality_control" add constraint "quality_control_reviewed_by_fkey" FOREIGN KEY (reviewed_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."quality_control" validate constraint "quality_control_reviewed_by_fkey";

alter table "mod_base"."quality_control" add constraint "quality_control_sample_size_check" CHECK ((sample_size > 0)) not valid;

alter table "mod_base"."quality_control" validate constraint "quality_control_sample_size_check";

alter table "mod_base"."quality_control" add constraint "quality_control_shipment_id_fkey" FOREIGN KEY (shipment_id) REFERENCES mod_wms.shipments(id) ON DELETE SET NULL not valid;

alter table "mod_base"."quality_control" validate constraint "quality_control_shipment_id_fkey";

alter table "mod_base"."quality_control" add constraint "quality_control_status_check" CHECK ((status = ANY (ARRAY['PLANNED'::text, 'IN_PROGRESS'::text, 'PASSED'::text, 'FAILED'::text, 'CANCELLED'::text]))) not valid;

alter table "mod_base"."quality_control" validate constraint "quality_control_status_check";

alter table "mod_base"."quality_control" add constraint "quality_control_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."quality_control" validate constraint "quality_control_updated_by_fkey";

alter table "mod_base"."quality_control" add constraint "quality_control_work_order_id_fkey" FOREIGN KEY (work_order_id) REFERENCES mod_manufacturing.work_orders(id) ON DELETE SET NULL not valid;

alter table "mod_base"."quality_control" validate constraint "quality_control_work_order_id_fkey";

alter table "mod_base"."quality_control" add constraint "quality_control_work_steps_id_fkey" FOREIGN KEY (work_steps_id) REFERENCES mod_manufacturing.work_steps(id) ON DELETE SET NULL not valid;

alter table "mod_base"."quality_control" validate constraint "quality_control_work_steps_id_fkey";

alter table "mod_base"."quality_control" add constraint "quantity_check" CHECK (((quantity_checked >= 0) AND (quantity_passed >= 0) AND (quantity_failed >= 0) AND (quantity_checked = (quantity_passed + quantity_failed)))) not valid;

alter table "mod_base"."quality_control" validate constraint "quantity_check";

alter table "mod_base"."quality_control_attachments" add constraint "quality_control_attachments_quality_control_id_fkey" FOREIGN KEY (quality_control_id) REFERENCES mod_base.quality_control(id) ON DELETE CASCADE not valid;

alter table "mod_base"."quality_control_attachments" validate constraint "quality_control_attachments_quality_control_id_fkey";

alter table "mod_base"."quality_control_checklist_results" add constraint "fk_quality_control_checklist_results_quality_control" FOREIGN KEY (quality_control_id) REFERENCES mod_base.quality_control(id) ON DELETE CASCADE not valid;

alter table "mod_base"."quality_control_checklist_results" validate constraint "fk_quality_control_checklist_results_quality_control";

alter table "mod_base"."quality_control_checklist_results" add constraint "uk_quality_control_checklist_results_unique_item" UNIQUE using index "uk_quality_control_checklist_results_unique_item";

alter table "mod_base"."quality_control_types" add constraint "quality_control_types_barcode_key" UNIQUE using index "quality_control_types_barcode_key";

alter table "mod_base"."quality_control_types" add constraint "quality_control_types_category_id_fkey" FOREIGN KEY (category_id) REFERENCES mod_base.article_categories(id) ON DELETE SET NULL not valid;

alter table "mod_base"."quality_control_types" validate constraint "quality_control_types_category_id_fkey";

alter table "mod_base"."quality_control_types" add constraint "quality_control_types_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."quality_control_types" validate constraint "quality_control_types_created_by_fkey";

alter table "mod_base"."quality_control_types" add constraint "quality_control_types_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."quality_control_types" validate constraint "quality_control_types_domain_id_fkey";

alter table "mod_base"."quality_control_types" add constraint "quality_control_types_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."quality_control_types" validate constraint "quality_control_types_updated_by_fkey";

alter table "mod_base"."quality_control_types" add constraint "quality_control_types_work_cycle_id_fkey" FOREIGN KEY (work_cycle_id) REFERENCES mod_manufacturing.work_cycles(id) ON DELETE SET NULL not valid;

alter table "mod_base"."quality_control_types" validate constraint "quality_control_types_work_cycle_id_fkey";

alter table "mod_base"."quality_control_types_duplicate" add constraint "quality_control_types_duplicate_barcode_key" UNIQUE using index "quality_control_types_duplicate_barcode_key";

alter table "mod_base"."quality_control_types_duplicate" add constraint "quality_control_types_duplicate_category_id_fkey" FOREIGN KEY (category_id) REFERENCES mod_base.article_categories(id) ON DELETE SET NULL not valid;

alter table "mod_base"."quality_control_types_duplicate" validate constraint "quality_control_types_duplicate_category_id_fkey";

alter table "mod_base"."quality_control_types_duplicate" add constraint "quality_control_types_duplicate_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."quality_control_types_duplicate" validate constraint "quality_control_types_duplicate_created_by_fkey";

alter table "mod_base"."quality_control_types_duplicate" add constraint "quality_control_types_duplicate_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."quality_control_types_duplicate" validate constraint "quality_control_types_duplicate_domain_id_fkey";

alter table "mod_base"."quality_control_types_duplicate" add constraint "quality_control_types_duplicate_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."quality_control_types_duplicate" validate constraint "quality_control_types_duplicate_updated_by_fkey";

alter table "mod_base"."quality_control_types_duplicate" add constraint "quality_control_types_duplicate_work_cycle_id_fkey" FOREIGN KEY (work_cycle_id) REFERENCES mod_manufacturing.work_cycles(id) ON DELETE SET NULL not valid;

alter table "mod_base"."quality_control_types_duplicate" validate constraint "quality_control_types_duplicate_work_cycle_id_fkey";

alter table "mod_base"."report_template" add constraint "report_template_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."report_template" validate constraint "report_template_created_by_fkey";

alter table "mod_base"."report_template" add constraint "report_template_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."report_template" validate constraint "report_template_updated_by_fkey";

alter table "mod_base"."sales_order_items" add constraint "sales_order_items_article_id_fkey" FOREIGN KEY (article_id) REFERENCES mod_base.articles(id) not valid;

alter table "mod_base"."sales_order_items" validate constraint "sales_order_items_article_id_fkey";

alter table "mod_base"."sales_order_items" add constraint "sales_order_items_barcode_key" UNIQUE using index "sales_order_items_barcode_key";

alter table "mod_base"."sales_order_items" add constraint "sales_order_items_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."sales_order_items" validate constraint "sales_order_items_created_by_fkey";

alter table "mod_base"."sales_order_items" add constraint "sales_order_items_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."sales_order_items" validate constraint "sales_order_items_domain_id_fkey";

alter table "mod_base"."sales_order_items" add constraint "sales_order_items_parent_sales_order_item_id_fkey" FOREIGN KEY (parent_sales_order_item_id) REFERENCES mod_base.sales_order_items(id) ON DELETE CASCADE not valid;

alter table "mod_base"."sales_order_items" validate constraint "sales_order_items_parent_sales_order_item_id_fkey";

alter table "mod_base"."sales_order_items" add constraint "sales_order_items_sales_order_id_fkey" FOREIGN KEY (sales_order_id) REFERENCES mod_base.sales_orders(id) ON DELETE CASCADE not valid;

alter table "mod_base"."sales_order_items" validate constraint "sales_order_items_sales_order_id_fkey";

alter table "mod_base"."sales_order_items" add constraint "sales_order_items_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."sales_order_items" validate constraint "sales_order_items_updated_by_fkey";

alter table "mod_base"."sales_orders" add constraint "sales_orders_barcode_key" UNIQUE using index "sales_orders_barcode_key";

alter table "mod_base"."sales_orders" add constraint "sales_orders_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."sales_orders" validate constraint "sales_orders_created_by_fkey";

alter table "mod_base"."sales_orders" add constraint "sales_orders_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES mod_base.customers(id) not valid;

alter table "mod_base"."sales_orders" validate constraint "sales_orders_customer_id_fkey";

alter table "mod_base"."sales_orders" add constraint "sales_orders_customer_or_internal_check" CHECK ((((customer_id IS NOT NULL) AND (is_internal = false)) OR ((customer_id IS NULL) AND (is_internal = true)))) not valid;

alter table "mod_base"."sales_orders" validate constraint "sales_orders_customer_or_internal_check";

alter table "mod_base"."sales_orders" add constraint "sales_orders_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."sales_orders" validate constraint "sales_orders_domain_id_fkey";

alter table "mod_base"."sales_orders" add constraint "sales_orders_id_fkey" FOREIGN KEY (id) REFERENCES mod_pulse.pulses(id) ON DELETE CASCADE not valid;

alter table "mod_base"."sales_orders" validate constraint "sales_orders_id_fkey";

alter table "mod_base"."sales_orders" add constraint "sales_orders_sales_order_number_key" UNIQUE using index "sales_orders_sales_order_number_key";

alter table "mod_base"."sales_orders" add constraint "sales_orders_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'active'::text, 'processing'::text, 'ready_for_packing'::text, 'ready_for_delivery'::text, 'completed'::text, 'paused'::text, 'canceled'::text]))) not valid;

alter table "mod_base"."sales_orders" validate constraint "sales_orders_status_check";

alter table "mod_base"."sales_orders" add constraint "sales_orders_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."sales_orders" validate constraint "sales_orders_updated_by_fkey";

alter table "mod_base"."serial_number_counters" add constraint "serial_number_counters_category_id_fkey" FOREIGN KEY (category_id) REFERENCES mod_base.article_categories(id) ON DELETE CASCADE not valid;

alter table "mod_base"."serial_number_counters" validate constraint "serial_number_counters_category_id_fkey";

alter table "mod_base"."serial_number_counters" add constraint "serial_number_counters_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_base"."serial_number_counters" validate constraint "serial_number_counters_created_by_fkey";

alter table "mod_base"."serial_number_counters" add constraint "serial_number_counters_incremental_check" CHECK ((last_incremental_number >= 0)) not valid;

alter table "mod_base"."serial_number_counters" validate constraint "serial_number_counters_incremental_check";

alter table "mod_base"."serial_number_counters" add constraint "serial_number_counters_unique_category_year" UNIQUE using index "serial_number_counters_unique_category_year";

alter table "mod_base"."serial_number_counters" add constraint "serial_number_counters_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_base"."serial_number_counters" validate constraint "serial_number_counters_updated_by_fkey";

alter table "mod_base"."serial_number_counters" add constraint "serial_number_counters_year_check" CHECK (((year >= 2000) AND (year <= 9999))) not valid;

alter table "mod_base"."serial_number_counters" validate constraint "serial_number_counters_year_check";

alter table "mod_base"."suppliers" add constraint "suppliers_barcode_key" UNIQUE using index "suppliers_barcode_key";

alter table "mod_base"."suppliers" add constraint "suppliers_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."suppliers" validate constraint "suppliers_created_by_fkey";

alter table "mod_base"."suppliers" add constraint "suppliers_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."suppliers" validate constraint "suppliers_domain_id_fkey";

alter table "mod_base"."suppliers" add constraint "suppliers_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."suppliers" validate constraint "suppliers_updated_by_fkey";

alter table "mod_base"."units_of_measure" add constraint "units_of_measure_barcode_key" UNIQUE using index "units_of_measure_barcode_key";

alter table "mod_base"."units_of_measure" add constraint "units_of_measure_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."units_of_measure" validate constraint "units_of_measure_created_by_fkey";

alter table "mod_base"."units_of_measure" add constraint "units_of_measure_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_base"."units_of_measure" validate constraint "units_of_measure_domain_id_fkey";

alter table "mod_base"."units_of_measure" add constraint "units_of_measure_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_base"."units_of_measure" validate constraint "units_of_measure_updated_by_fkey";

alter table "mod_datalayer"."fields" add constraint "fields_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."fields" validate constraint "fields_created_by_fkey";

alter table "mod_datalayer"."fields" add constraint "fields_input_type_check" CHECK ((input_type = ANY (ARRAY['string'::text, 'number'::text, 'singleChoice'::text]))) not valid;

alter table "mod_datalayer"."fields" validate constraint "fields_input_type_check";

alter table "mod_datalayer"."fields" add constraint "fields_schema_name_fkey" FOREIGN KEY (schema_name) REFERENCES mod_datalayer.modules(schema_name) ON DELETE CASCADE not valid;

alter table "mod_datalayer"."fields" validate constraint "fields_schema_name_fkey";

alter table "mod_datalayer"."fields" add constraint "fields_schema_name_table_name_field_name_key" UNIQUE using index "fields_schema_name_table_name_field_name_key";

alter table "mod_datalayer"."fields" add constraint "fields_schema_name_table_name_fkey" FOREIGN KEY (schema_name, table_name) REFERENCES mod_datalayer.tables(schema_name, table_name) ON DELETE CASCADE not valid;

alter table "mod_datalayer"."fields" validate constraint "fields_schema_name_table_name_fkey";

alter table "mod_datalayer"."fields" add constraint "fields_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."fields" validate constraint "fields_updated_by_fkey";

alter table "mod_datalayer"."fields" add constraint "fk_references" FOREIGN KEY (references_schema, references_table) REFERENCES mod_datalayer.tables(schema_name, table_name) ON DELETE SET NULL not valid;

alter table "mod_datalayer"."fields" validate constraint "fk_references";

alter table "mod_datalayer"."main_menu" add constraint "main_menu_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."main_menu" validate constraint "main_menu_created_by_fkey";

alter table "mod_datalayer"."main_menu" add constraint "main_menu_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."main_menu" validate constraint "main_menu_updated_by_fkey";

alter table "mod_datalayer"."modules" add constraint "modules_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."modules" validate constraint "modules_created_by_fkey";

alter table "mod_datalayer"."modules" add constraint "modules_owner_domain_id_fkey" FOREIGN KEY (owner_domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_datalayer"."modules" validate constraint "modules_owner_domain_id_fkey";

alter table "mod_datalayer"."modules" add constraint "modules_schema_name_key" UNIQUE using index "modules_schema_name_key";

alter table "mod_datalayer"."modules" add constraint "modules_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."modules" validate constraint "modules_updated_by_fkey";

alter table "mod_datalayer"."page_categories" add constraint "page_categories_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."page_categories" validate constraint "page_categories_created_by_fkey";

alter table "mod_datalayer"."page_categories" add constraint "page_categories_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."page_categories" validate constraint "page_categories_updated_by_fkey";

alter table "mod_datalayer"."pages" add constraint "pages_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."pages" validate constraint "pages_created_by_fkey";

alter table "mod_datalayer"."pages" add constraint "pages_main_menu_id_fkey" FOREIGN KEY (main_menu_id) REFERENCES mod_datalayer.main_menu(id) ON DELETE SET NULL not valid;

alter table "mod_datalayer"."pages" validate constraint "pages_main_menu_id_fkey";

alter table "mod_datalayer"."pages" add constraint "pages_module_id_fkey" FOREIGN KEY (module_id) REFERENCES mod_datalayer.modules(id) ON DELETE SET NULL not valid;

alter table "mod_datalayer"."pages" validate constraint "pages_module_id_fkey";

alter table "mod_datalayer"."pages" add constraint "pages_page_category_id_fkey" FOREIGN KEY (page_category_id) REFERENCES mod_datalayer.page_categories(id) ON DELETE SET NULL not valid;

alter table "mod_datalayer"."pages" validate constraint "pages_page_category_id_fkey";

alter table "mod_datalayer"."pages" add constraint "pages_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."pages" validate constraint "pages_updated_by_fkey";

alter table "mod_datalayer"."pages" add constraint "unique_module_page" UNIQUE using index "unique_module_page";

alter table "mod_datalayer"."pages_departments" add constraint "pages_departments_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."pages_departments" validate constraint "pages_departments_created_by_fkey";

alter table "mod_datalayer"."pages_departments" add constraint "pages_departments_department_id_fkey" FOREIGN KEY (department_id) REFERENCES mod_base.departments(id) ON DELETE CASCADE not valid;

alter table "mod_datalayer"."pages_departments" validate constraint "pages_departments_department_id_fkey";

alter table "mod_datalayer"."pages_departments" add constraint "pages_departments_page_id_department_id_key" UNIQUE using index "pages_departments_page_id_department_id_key";

alter table "mod_datalayer"."pages_departments" add constraint "pages_departments_page_id_fkey" FOREIGN KEY (page_id) REFERENCES mod_datalayer.pages(id) ON DELETE CASCADE not valid;

alter table "mod_datalayer"."pages_departments" validate constraint "pages_departments_page_id_fkey";

alter table "mod_datalayer"."pages_departments" add constraint "pages_departments_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."pages_departments" validate constraint "pages_departments_updated_by_fkey";

alter table "mod_datalayer"."pages_departments" add constraint "pages_departments_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."pages_departments" validate constraint "pages_departments_user_id_fkey";

alter table "mod_datalayer"."pages_menu_departments" add constraint "pages_menu_departments_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."pages_menu_departments" validate constraint "pages_menu_departments_created_by_fkey";

alter table "mod_datalayer"."pages_menu_departments" add constraint "pages_menu_departments_department_id_fkey" FOREIGN KEY (department_id) REFERENCES mod_base.departments(id) ON DELETE CASCADE not valid;

alter table "mod_datalayer"."pages_menu_departments" validate constraint "pages_menu_departments_department_id_fkey";

alter table "mod_datalayer"."pages_menu_departments" add constraint "pages_menu_departments_page_id_department_id_key" UNIQUE using index "pages_menu_departments_page_id_department_id_key";

alter table "mod_datalayer"."pages_menu_departments" add constraint "pages_menu_departments_page_id_fkey" FOREIGN KEY (page_id) REFERENCES mod_datalayer.pages(id) ON DELETE CASCADE not valid;

alter table "mod_datalayer"."pages_menu_departments" validate constraint "pages_menu_departments_page_id_fkey";

alter table "mod_datalayer"."pages_menu_departments" add constraint "pages_menu_departments_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."pages_menu_departments" validate constraint "pages_menu_departments_updated_by_fkey";

alter table "mod_datalayer"."pages_menu_departments" add constraint "pages_menu_departments_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."pages_menu_departments" validate constraint "pages_menu_departments_user_id_fkey";

alter table "mod_datalayer"."tables" add constraint "tables_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."tables" validate constraint "tables_created_by_fkey";

alter table "mod_datalayer"."tables" add constraint "tables_schema_name_fkey" FOREIGN KEY (schema_name) REFERENCES mod_datalayer.modules(schema_name) ON DELETE CASCADE not valid;

alter table "mod_datalayer"."tables" validate constraint "tables_schema_name_fkey";

alter table "mod_datalayer"."tables" add constraint "tables_schema_name_table_name_key" UNIQUE using index "tables_schema_name_table_name_key";

alter table "mod_datalayer"."tables" add constraint "tables_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_datalayer"."tables" validate constraint "tables_updated_by_fkey";

alter table "mod_manufacturing"."coil_consumption" add constraint "coil_consumption_coil_id_fkey" FOREIGN KEY (coil_id) REFERENCES mod_manufacturing.coils(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."coil_consumption" validate constraint "coil_consumption_coil_id_fkey";

alter table "mod_manufacturing"."coil_consumption" add constraint "coil_consumption_consumed_length_m_check" CHECK ((consumed_length_m >= (0)::numeric)) not valid;

alter table "mod_manufacturing"."coil_consumption" validate constraint "coil_consumption_consumed_length_m_check";

alter table "mod_manufacturing"."coil_consumption" add constraint "coil_consumption_consumed_weight_kg_check" CHECK ((consumed_weight_kg >= (0)::numeric)) not valid;

alter table "mod_manufacturing"."coil_consumption" validate constraint "coil_consumption_consumed_weight_kg_check";

alter table "mod_manufacturing"."coil_consumption" add constraint "coil_consumption_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."coil_consumption" validate constraint "coil_consumption_created_by_fkey";

alter table "mod_manufacturing"."coil_consumption" add constraint "coil_consumption_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."coil_consumption" validate constraint "coil_consumption_domain_id_fkey";

alter table "mod_manufacturing"."coil_consumption" add constraint "coil_consumption_operator_id_fkey" FOREIGN KEY (operator_id) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."coil_consumption" validate constraint "coil_consumption_operator_id_fkey";

alter table "mod_manufacturing"."coil_consumption" add constraint "coil_consumption_plates_produced_check" CHECK ((plates_produced >= 0)) not valid;

alter table "mod_manufacturing"."coil_consumption" validate constraint "coil_consumption_plates_produced_check";

alter table "mod_manufacturing"."coil_consumption" add constraint "coil_consumption_production_plan_id_fkey" FOREIGN KEY (production_plan_id) REFERENCES mod_manufacturing.coil_production_plans(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."coil_consumption" validate constraint "coil_consumption_production_plan_id_fkey";

alter table "mod_manufacturing"."coil_consumption" add constraint "coil_consumption_quality_grade_check" CHECK ((quality_grade = ANY (ARRAY['A'::text, 'B'::text, 'C'::text, 'Scrap'::text]))) not valid;

alter table "mod_manufacturing"."coil_consumption" validate constraint "coil_consumption_quality_grade_check";

alter table "mod_manufacturing"."coil_consumption" add constraint "coil_consumption_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."coil_consumption" validate constraint "coil_consumption_updated_by_fkey";

alter table "mod_manufacturing"."coil_consumption" add constraint "coil_consumption_waste_weight_kg_check" CHECK ((waste_weight_kg >= (0)::numeric)) not valid;

alter table "mod_manufacturing"."coil_consumption" validate constraint "coil_consumption_waste_weight_kg_check";

alter table "mod_manufacturing"."coil_consumption" add constraint "coil_consumption_work_order_id_fkey" FOREIGN KEY (work_order_id) REFERENCES mod_manufacturing.work_orders(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."coil_consumption" validate constraint "coil_consumption_work_order_id_fkey";

alter table "mod_manufacturing"."coil_production_plans" add constraint "coil_production_plans_barcode_key" UNIQUE using index "coil_production_plans_barcode_key";

alter table "mod_manufacturing"."coil_production_plans" add constraint "coil_production_plans_coil_id_fkey" FOREIGN KEY (coil_id) REFERENCES mod_manufacturing.coils(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."coil_production_plans" validate constraint "coil_production_plans_coil_id_fkey";

alter table "mod_manufacturing"."coil_production_plans" add constraint "coil_production_plans_committed_quantity_check" CHECK ((committed_quantity >= 0)) not valid;

alter table "mod_manufacturing"."coil_production_plans" validate constraint "coil_production_plans_committed_quantity_check";

alter table "mod_manufacturing"."coil_production_plans" add constraint "coil_production_plans_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."coil_production_plans" validate constraint "coil_production_plans_created_by_fkey";

alter table "mod_manufacturing"."coil_production_plans" add constraint "coil_production_plans_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."coil_production_plans" validate constraint "coil_production_plans_domain_id_fkey";

alter table "mod_manufacturing"."coil_production_plans" add constraint "coil_production_plans_planned_quantity_check" CHECK ((planned_quantity > 0)) not valid;

alter table "mod_manufacturing"."coil_production_plans" validate constraint "coil_production_plans_planned_quantity_check";

alter table "mod_manufacturing"."coil_production_plans" add constraint "coil_production_plans_plate_template_id_fkey" FOREIGN KEY (plate_template_id) REFERENCES mod_manufacturing.plate_templates(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."coil_production_plans" validate constraint "coil_production_plans_plate_template_id_fkey";

alter table "mod_manufacturing"."coil_production_plans" add constraint "coil_production_plans_priority_check" CHECK (((priority >= 1) AND (priority <= 5))) not valid;

alter table "mod_manufacturing"."coil_production_plans" validate constraint "coil_production_plans_priority_check";

alter table "mod_manufacturing"."coil_production_plans" add constraint "coil_production_plans_produced_quantity_check" CHECK ((produced_quantity >= 0)) not valid;

alter table "mod_manufacturing"."coil_production_plans" validate constraint "coil_production_plans_produced_quantity_check";

alter table "mod_manufacturing"."coil_production_plans" add constraint "coil_production_plans_status_check" CHECK ((status = ANY (ARRAY['planned'::text, 'in_progress'::text, 'completed'::text, 'cancelled'::text]))) not valid;

alter table "mod_manufacturing"."coil_production_plans" validate constraint "coil_production_plans_status_check";

alter table "mod_manufacturing"."coil_production_plans" add constraint "coil_production_plans_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."coil_production_plans" validate constraint "coil_production_plans_updated_by_fkey";

alter table "mod_manufacturing"."coil_production_plans" add constraint "coil_production_plans_work_order_id_fkey" FOREIGN KEY (work_order_id) REFERENCES mod_manufacturing.work_orders(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."coil_production_plans" validate constraint "coil_production_plans_work_order_id_fkey";

alter table "mod_manufacturing"."coils" add constraint "coils_barcode_key" UNIQUE using index "coils_barcode_key";

alter table "mod_manufacturing"."coils" add constraint "coils_batch_id_fkey" FOREIGN KEY (batch_id) REFERENCES mod_wms.batches(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."coils" validate constraint "coils_batch_id_fkey";

alter table "mod_manufacturing"."coils" add constraint "coils_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."coils" validate constraint "coils_created_by_fkey";

alter table "mod_manufacturing"."coils" add constraint "coils_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."coils" validate constraint "coils_domain_id_fkey";

alter table "mod_manufacturing"."coils" add constraint "coils_location_id_fkey" FOREIGN KEY (location_id) REFERENCES mod_wms.locations(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."coils" validate constraint "coils_location_id_fkey";

alter table "mod_manufacturing"."coils" add constraint "coils_quality_grade_check" CHECK ((quality_grade = ANY (ARRAY['A'::text, 'B'::text, 'C'::text]))) not valid;

alter table "mod_manufacturing"."coils" validate constraint "coils_quality_grade_check";

alter table "mod_manufacturing"."coils" add constraint "coils_status_check" CHECK ((status = ANY (ARRAY['received'::text, 'in_production'::text, 'consumed'::text, 'scrapped'::text]))) not valid;

alter table "mod_manufacturing"."coils" validate constraint "coils_status_check";

alter table "mod_manufacturing"."coils" add constraint "coils_supplier_id_fkey" FOREIGN KEY (supplier_id) REFERENCES mod_base.suppliers(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."coils" validate constraint "coils_supplier_id_fkey";

alter table "mod_manufacturing"."coils" add constraint "coils_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."coils" validate constraint "coils_updated_by_fkey";

alter table "mod_manufacturing"."coils" add constraint "coils_weight_kg_check" CHECK ((weight_kg >= (0)::numeric)) not valid;

alter table "mod_manufacturing"."coils" validate constraint "coils_weight_kg_check";

alter table "mod_manufacturing"."departments" add constraint "departments_barcode_key" UNIQUE using index "departments_barcode_key";

alter table "mod_manufacturing"."departments" add constraint "departments_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."departments" validate constraint "departments_created_by_fkey";

alter table "mod_manufacturing"."departments" add constraint "departments_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."departments" validate constraint "departments_domain_id_fkey";

alter table "mod_manufacturing"."departments" add constraint "departments_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."departments" validate constraint "departments_updated_by_fkey";

alter table "mod_manufacturing"."locations" add constraint "locations_barcode_key" UNIQUE using index "locations_barcode_key";

alter table "mod_manufacturing"."locations" add constraint "locations_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."locations" validate constraint "locations_created_by_fkey";

alter table "mod_manufacturing"."locations" add constraint "locations_department_id_fkey" FOREIGN KEY (department_id) REFERENCES mod_manufacturing.departments(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."locations" validate constraint "locations_department_id_fkey";

alter table "mod_manufacturing"."locations" add constraint "locations_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."locations" validate constraint "locations_domain_id_fkey";

alter table "mod_manufacturing"."locations" add constraint "locations_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."locations" validate constraint "locations_updated_by_fkey";

alter table "mod_manufacturing"."plate_templates" add constraint "plate_templates_barcode_key" UNIQUE using index "plate_templates_barcode_key";

alter table "mod_manufacturing"."plate_templates" add constraint "plate_templates_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."plate_templates" validate constraint "plate_templates_created_by_fkey";

alter table "mod_manufacturing"."plate_templates" add constraint "plate_templates_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."plate_templates" validate constraint "plate_templates_domain_id_fkey";

alter table "mod_manufacturing"."plate_templates" add constraint "plate_templates_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."plate_templates" validate constraint "plate_templates_updated_by_fkey";

alter table "mod_manufacturing"."production_logs" add constraint "production_logs_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."production_logs" validate constraint "production_logs_created_by_fkey";

alter table "mod_manufacturing"."production_logs" add constraint "production_logs_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."production_logs" validate constraint "production_logs_domain_id_fkey";

alter table "mod_manufacturing"."production_logs" add constraint "production_logs_operator_id_fkey" FOREIGN KEY (operator_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."production_logs" validate constraint "production_logs_operator_id_fkey";

alter table "mod_manufacturing"."production_logs" add constraint "production_logs_produced_quantity_check" CHECK ((produced_quantity >= 0)) not valid;

alter table "mod_manufacturing"."production_logs" validate constraint "production_logs_produced_quantity_check";

alter table "mod_manufacturing"."production_logs" add constraint "production_logs_rejected_quantity_check" CHECK ((rejected_quantity >= 0)) not valid;

alter table "mod_manufacturing"."production_logs" validate constraint "production_logs_rejected_quantity_check";

alter table "mod_manufacturing"."production_logs" add constraint "production_logs_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'in_progress'::text, 'completed'::text, 'failed'::text]))) not valid;

alter table "mod_manufacturing"."production_logs" validate constraint "production_logs_status_check";

alter table "mod_manufacturing"."production_logs" add constraint "production_logs_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."production_logs" validate constraint "production_logs_updated_by_fkey";

alter table "mod_manufacturing"."production_logs" add constraint "production_logs_work_order_id_fkey" FOREIGN KEY (work_order_id) REFERENCES mod_manufacturing.work_orders(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."production_logs" validate constraint "production_logs_work_order_id_fkey";

alter table "mod_manufacturing"."production_logs" add constraint "production_logs_work_step_id_fkey" FOREIGN KEY (work_step_id) REFERENCES mod_manufacturing.work_steps(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."production_logs" validate constraint "production_logs_work_step_id_fkey";

alter table "mod_manufacturing"."recipes" add constraint "recipes_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."recipes" validate constraint "recipes_created_by_fkey";

alter table "mod_manufacturing"."recipes" add constraint "recipes_destination_article_id_fkey" FOREIGN KEY (destination_article_id) REFERENCES mod_base.articles(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."recipes" validate constraint "recipes_destination_article_id_fkey";

alter table "mod_manufacturing"."recipes" add constraint "recipes_destination_article_qty_check" CHECK ((destination_article_qty > (0)::numeric)) not valid;

alter table "mod_manufacturing"."recipes" validate constraint "recipes_destination_article_qty_check";

alter table "mod_manufacturing"."recipes" add constraint "recipes_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."recipes" validate constraint "recipes_domain_id_fkey";

alter table "mod_manufacturing"."recipes" add constraint "recipes_finished_product_id_fkey" FOREIGN KEY (finished_product_id) REFERENCES mod_base.articles(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."recipes" validate constraint "recipes_finished_product_id_fkey";

alter table "mod_manufacturing"."recipes" add constraint "recipes_finished_product_id_sequence_number_key" UNIQUE using index "recipes_finished_product_id_sequence_number_key";

alter table "mod_manufacturing"."recipes" add constraint "recipes_sequence_number_check" CHECK ((sequence_number > 0)) not valid;

alter table "mod_manufacturing"."recipes" validate constraint "recipes_sequence_number_check";

alter table "mod_manufacturing"."recipes" add constraint "recipes_source_article_id_fkey" FOREIGN KEY (source_article_id) REFERENCES mod_base.articles(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."recipes" validate constraint "recipes_source_article_id_fkey";

alter table "mod_manufacturing"."recipes" add constraint "recipes_source_article_qty_check" CHECK ((source_article_qty > (0)::numeric)) not valid;

alter table "mod_manufacturing"."recipes" validate constraint "recipes_source_article_qty_check";

alter table "mod_manufacturing"."recipes" add constraint "recipes_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."recipes" validate constraint "recipes_updated_by_fkey";

alter table "mod_manufacturing"."scheduled_items" add constraint "scheduled_items_article_id_fkey" FOREIGN KEY (article_id) REFERENCES mod_base.articles(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."scheduled_items" validate constraint "scheduled_items_article_id_fkey";

alter table "mod_manufacturing"."scheduled_items" add constraint "scheduled_items_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."scheduled_items" validate constraint "scheduled_items_created_by_fkey";

alter table "mod_manufacturing"."scheduled_items" add constraint "scheduled_items_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."scheduled_items" validate constraint "scheduled_items_domain_id_fkey";

alter table "mod_manufacturing"."scheduled_items" add constraint "scheduled_items_sales_order_id_fkey" FOREIGN KEY (sales_order_id) REFERENCES mod_base.sales_orders(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."scheduled_items" validate constraint "scheduled_items_sales_order_id_fkey";

alter table "mod_manufacturing"."scheduled_items" add constraint "scheduled_items_sales_order_item_id_fkey" FOREIGN KEY (sales_order_item_id) REFERENCES mod_base.sales_order_items(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."scheduled_items" validate constraint "scheduled_items_sales_order_item_id_fkey";

alter table "mod_manufacturing"."scheduled_items" add constraint "scheduled_items_status_check" CHECK ((status = ANY (ARRAY['scheduled'::text, 'in_progress'::text, 'completed'::text, 'canceled'::text]))) not valid;

alter table "mod_manufacturing"."scheduled_items" validate constraint "scheduled_items_status_check";

alter table "mod_manufacturing"."scheduled_items" add constraint "scheduled_items_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."scheduled_items" validate constraint "scheduled_items_updated_by_fkey";

alter table "mod_manufacturing"."scheduled_items" add constraint "unique_scheduled_item" UNIQUE using index "unique_scheduled_item";

alter table "mod_manufacturing"."work_cycle_categories" add constraint "unique_work_cycle_category_relation" UNIQUE using index "unique_work_cycle_category_relation";

alter table "mod_manufacturing"."work_cycle_categories" add constraint "work_cycle_categories_from_article_category_id_fkey" FOREIGN KEY (from_article_category_id) REFERENCES mod_base.article_categories(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_cycle_categories" validate constraint "work_cycle_categories_from_article_category_id_fkey";

alter table "mod_manufacturing"."work_cycle_categories" add constraint "work_cycle_categories_location_id_fkey" FOREIGN KEY (location_id) REFERENCES mod_wms.locations(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_cycle_categories" validate constraint "work_cycle_categories_location_id_fkey";

alter table "mod_manufacturing"."work_cycle_categories" add constraint "work_cycle_categories_to_article_category_id_fkey" FOREIGN KEY (to_article_category_id) REFERENCES mod_base.article_categories(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_cycle_categories" validate constraint "work_cycle_categories_to_article_category_id_fkey";

alter table "mod_manufacturing"."work_cycle_categories" add constraint "work_cycle_categories_work_cycle_id_fkey" FOREIGN KEY (work_cycle_id) REFERENCES mod_manufacturing.work_cycles(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."work_cycle_categories" validate constraint "work_cycle_categories_work_cycle_id_fkey";

alter table "mod_manufacturing"."work_cycle_categories" add constraint "work_cycle_categories_work_flow_id_fkey" FOREIGN KEY (work_flow_id) REFERENCES mod_manufacturing.work_flows(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."work_cycle_categories" validate constraint "work_cycle_categories_work_flow_id_fkey";

alter table "mod_manufacturing"."work_cycles" add constraint "work_cycles_barcode_key" UNIQUE using index "work_cycles_barcode_key";

alter table "mod_manufacturing"."work_cycles" add constraint "work_cycles_department_id_fkey" FOREIGN KEY (department_id) REFERENCES mod_base.departments(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_cycles" validate constraint "work_cycles_department_id_fkey";

alter table "mod_manufacturing"."work_cycles" add constraint "work_cycles_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_cycles" validate constraint "work_cycles_domain_id_fkey";

alter table "mod_manufacturing"."work_cycles" add constraint "work_cycles_sort_order_check" CHECK ((sort_order > 0)) not valid;

alter table "mod_manufacturing"."work_cycles" validate constraint "work_cycles_sort_order_check";

alter table "mod_manufacturing"."work_cycles" add constraint "work_cycles_sub_type_check" CHECK ((sub_type = ANY (ARRAY['production'::text, 'assembly'::text, 'disassembly'::text, 'maintenance'::text, 'quality_control'::text]))) not valid;

alter table "mod_manufacturing"."work_cycles" validate constraint "work_cycles_sub_type_check";

alter table "mod_manufacturing"."work_cycles" add constraint "work_cycles_type_check" CHECK ((type = ANY (ARRAY['manufacturing'::text, 'maintenance'::text, 'quality_control'::text]))) not valid;

alter table "mod_manufacturing"."work_cycles" validate constraint "work_cycles_type_check";

alter table "mod_manufacturing"."work_flows_work_cycles" add constraint "work_flows_work_cycles_work_cycle_id_fkey" FOREIGN KEY (work_cycle_id) REFERENCES mod_manufacturing.work_cycles(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."work_flows_work_cycles" validate constraint "work_flows_work_cycles_work_cycle_id_fkey";

alter table "mod_manufacturing"."work_flows_work_cycles" add constraint "work_flows_work_cycles_work_flow_id_fkey" FOREIGN KEY (work_flow_id) REFERENCES mod_manufacturing.work_flows(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."work_flows_work_cycles" validate constraint "work_flows_work_cycles_work_flow_id_fkey";

alter table "mod_manufacturing"."work_flows_work_cycles" add constraint "work_flows_work_cycles_work_flow_id_work_cycle_id_key" UNIQUE using index "work_flows_work_cycles_work_flow_id_work_cycle_id_key";

alter table "mod_manufacturing"."work_order_attachments" add constraint "work_order_attachments_work_order_id_fkey" FOREIGN KEY (work_order_id) REFERENCES mod_manufacturing.work_orders(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."work_order_attachments" validate constraint "work_order_attachments_work_order_id_fkey";

alter table "mod_manufacturing"."work_order_quality_summary" add constraint "non_negative_counts" CHECK (((passed_count >= 0) AND (failed_count >= 0) AND (total_count >= 0))) not valid;

alter table "mod_manufacturing"."work_order_quality_summary" validate constraint "non_negative_counts";

alter table "mod_manufacturing"."work_order_quality_summary" add constraint "unique_work_order_quality_summary" UNIQUE using index "unique_work_order_quality_summary";

alter table "mod_manufacturing"."work_order_quality_summary" add constraint "work_order_quality_summary_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_order_quality_summary" validate constraint "work_order_quality_summary_created_by_fkey";

alter table "mod_manufacturing"."work_order_quality_summary" add constraint "work_order_quality_summary_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_order_quality_summary" validate constraint "work_order_quality_summary_domain_id_fkey";

alter table "mod_manufacturing"."work_order_quality_summary" add constraint "work_order_quality_summary_inspector_id_fkey" FOREIGN KEY (inspector_id) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_order_quality_summary" validate constraint "work_order_quality_summary_inspector_id_fkey";

alter table "mod_manufacturing"."work_order_quality_summary" add constraint "work_order_quality_summary_overall_status_check" CHECK ((overall_status = ANY (ARRAY['PENDING'::text, 'IN_PROGRESS'::text, 'PASSED'::text, 'FAILED'::text, 'PARTIAL'::text]))) not valid;

alter table "mod_manufacturing"."work_order_quality_summary" validate constraint "work_order_quality_summary_overall_status_check";

alter table "mod_manufacturing"."work_order_quality_summary" add constraint "work_order_quality_summary_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_order_quality_summary" validate constraint "work_order_quality_summary_updated_by_fkey";

alter table "mod_manufacturing"."work_order_quality_summary" add constraint "work_order_quality_summary_work_order_id_fkey" FOREIGN KEY (work_order_id) REFERENCES mod_manufacturing.work_orders(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."work_order_quality_summary" validate constraint "work_order_quality_summary_work_order_id_fkey";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_article_id_fkey" FOREIGN KEY (article_id) REFERENCES mod_base.articles(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."work_orders" validate constraint "work_orders_article_id_fkey";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_barcode_key" UNIQUE using index "work_orders_barcode_key";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_completed_by_fkey" FOREIGN KEY (completed_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_orders" validate constraint "work_orders_completed_by_fkey";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."work_orders" validate constraint "work_orders_created_by_fkey";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_current_work_cycle_id_fkey" FOREIGN KEY (work_cycle_id) REFERENCES mod_manufacturing.work_cycles(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_orders" validate constraint "work_orders_current_work_cycle_id_fkey";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_orders" validate constraint "work_orders_domain_id_fkey";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_internal_sales_order_id_fkey" FOREIGN KEY (internal_sales_order_id) REFERENCES mod_base.internal_sales_orders(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_orders" validate constraint "work_orders_internal_sales_order_id_fkey";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_location_id_fkey" FOREIGN KEY (location_id) REFERENCES mod_wms.locations(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_orders" validate constraint "work_orders_location_id_fkey";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_paused_by_fkey" FOREIGN KEY (paused_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_orders" validate constraint "work_orders_paused_by_fkey";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_quantity_check" CHECK ((quantity > 0)) not valid;

alter table "mod_manufacturing"."work_orders" validate constraint "work_orders_quantity_check";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_responsible_id_fkey" FOREIGN KEY (responsible_id) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_orders" validate constraint "work_orders_responsible_id_fkey";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_sales_order_id_fkey" FOREIGN KEY (sales_order_id) REFERENCES mod_base.sales_orders(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_orders" validate constraint "work_orders_sales_order_id_fkey";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_single_sales_order_check" CHECK ((((sales_order_id IS NOT NULL) AND (internal_sales_order_id IS NULL)) OR ((sales_order_id IS NULL) AND (internal_sales_order_id IS NOT NULL)) OR ((sales_order_id IS NULL) AND (internal_sales_order_id IS NULL)))) not valid;

alter table "mod_manufacturing"."work_orders" validate constraint "work_orders_single_sales_order_check";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_started_by_fkey" FOREIGN KEY (started_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_orders" validate constraint "work_orders_started_by_fkey";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'in_progress'::text, 'completed'::text, 'canceled'::text, 'paused'::text]))) not valid;

alter table "mod_manufacturing"."work_orders" validate constraint "work_orders_status_check";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_task_id_fkey" FOREIGN KEY (task_id) REFERENCES mod_pulse.tasks(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."work_orders" validate constraint "work_orders_task_id_fkey";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_task_id_key" UNIQUE using index "work_orders_task_id_key";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."work_orders" validate constraint "work_orders_updated_by_fkey";

alter table "mod_manufacturing"."work_orders" add constraint "work_orders_warehouse_id_fkey" FOREIGN KEY (warehouse_id) REFERENCES mod_wms.warehouses(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_orders" validate constraint "work_orders_warehouse_id_fkey";

alter table "mod_manufacturing"."work_steps" add constraint "work_steps_barcode_key" UNIQUE using index "work_steps_barcode_key";

alter table "mod_manufacturing"."work_steps" add constraint "work_steps_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."work_steps" validate constraint "work_steps_created_by_fkey";

alter table "mod_manufacturing"."work_steps" add constraint "work_steps_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_steps" validate constraint "work_steps_domain_id_fkey";

alter table "mod_manufacturing"."work_steps" add constraint "work_steps_sort_order_check" CHECK ((sort_order > 0)) not valid;

alter table "mod_manufacturing"."work_steps" validate constraint "work_steps_sort_order_check";

alter table "mod_manufacturing"."work_steps" add constraint "work_steps_type_check" CHECK ((type = ANY (ARRAY['transport'::text, 'processing'::text, 'inspection'::text, 'assembly'::text, 'packaging'::text, 'storage'::text]))) not valid;

alter table "mod_manufacturing"."work_steps" validate constraint "work_steps_type_check";

alter table "mod_manufacturing"."work_steps" add constraint "work_steps_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."work_steps" validate constraint "work_steps_updated_by_fkey";

alter table "mod_manufacturing"."work_steps" add constraint "work_steps_work_cycle_id_fkey" FOREIGN KEY (work_cycle_id) REFERENCES mod_manufacturing.work_cycles(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."work_steps" validate constraint "work_steps_work_cycle_id_fkey";

alter table "mod_manufacturing"."work_steps" add constraint "work_steps_work_order_id_fkey" FOREIGN KEY (work_order_id) REFERENCES mod_manufacturing.work_orders(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."work_steps" validate constraint "work_steps_work_order_id_fkey";

alter table "mod_manufacturing"."work_steps" add constraint "work_steps_workstation_id_fkey" FOREIGN KEY (workstation_id) REFERENCES mod_manufacturing.workstations(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."work_steps" validate constraint "work_steps_workstation_id_fkey";

alter table "mod_manufacturing"."workstations" add constraint "operation_type_check" CHECK ((operation_type = ANY (ARRAY['manual'::text, 'automatic'::text, 'hybrid'::text]))) not valid;

alter table "mod_manufacturing"."workstations" validate constraint "operation_type_check";

alter table "mod_manufacturing"."workstations" add constraint "station_type_check" CHECK ((station_type = ANY (ARRAY['forklift'::text, 'job shop'::text, 'machine'::text, 'hybrid'::text]))) not valid;

alter table "mod_manufacturing"."workstations" validate constraint "station_type_check";

alter table "mod_manufacturing"."workstations" add constraint "workstations_barcode_key" UNIQUE using index "workstations_barcode_key";

alter table "mod_manufacturing"."workstations" add constraint "workstations_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."workstations" validate constraint "workstations_created_by_fkey";

alter table "mod_manufacturing"."workstations" add constraint "workstations_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."workstations" validate constraint "workstations_domain_id_fkey";

alter table "mod_manufacturing"."workstations" add constraint "workstations_location_id_fkey" FOREIGN KEY (location_id) REFERENCES mod_manufacturing.locations(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."workstations" validate constraint "workstations_location_id_fkey";

alter table "mod_manufacturing"."workstations" add constraint "workstations_max_capacity_check" CHECK ((max_capacity > 0)) not valid;

alter table "mod_manufacturing"."workstations" validate constraint "workstations_max_capacity_check";

alter table "mod_manufacturing"."workstations" add constraint "workstations_station_type_check" CHECK ((station_type = ANY (ARRAY['forklift'::text, 'job shop'::text, 'machine'::text, 'hybrid'::text]))) not valid;

alter table "mod_manufacturing"."workstations" validate constraint "workstations_station_type_check";

alter table "mod_manufacturing"."workstations" add constraint "workstations_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."workstations" validate constraint "workstations_updated_by_fkey";

alter table "mod_manufacturing"."workstations_duplicate" add constraint "operation_type_check" CHECK ((operation_type = ANY (ARRAY['manual'::text, 'automatic'::text, 'hybrid'::text]))) not valid;

alter table "mod_manufacturing"."workstations_duplicate" validate constraint "operation_type_check";

alter table "mod_manufacturing"."workstations_duplicate" add constraint "station_type_check" CHECK ((station_type = ANY (ARRAY['forklift'::text, 'job shop'::text, 'machine'::text, 'hybrid'::text]))) not valid;

alter table "mod_manufacturing"."workstations_duplicate" validate constraint "station_type_check";

alter table "mod_manufacturing"."workstations_duplicate" add constraint "workstations_duplicate_barcode_key" UNIQUE using index "workstations_duplicate_barcode_key";

alter table "mod_manufacturing"."workstations_duplicate" add constraint "workstations_duplicate_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."workstations_duplicate" validate constraint "workstations_duplicate_created_by_fkey";

alter table "mod_manufacturing"."workstations_duplicate" add constraint "workstations_duplicate_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_manufacturing"."workstations_duplicate" validate constraint "workstations_duplicate_domain_id_fkey";

alter table "mod_manufacturing"."workstations_duplicate" add constraint "workstations_duplicate_location_id_fkey" FOREIGN KEY (location_id) REFERENCES mod_manufacturing.locations(id) ON DELETE CASCADE not valid;

alter table "mod_manufacturing"."workstations_duplicate" validate constraint "workstations_duplicate_location_id_fkey";

alter table "mod_manufacturing"."workstations_duplicate" add constraint "workstations_duplicate_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_manufacturing"."workstations_duplicate" validate constraint "workstations_duplicate_updated_by_fkey";

alter table "mod_manufacturing"."workstations_duplicate" add constraint "workstations_max_capacity_check" CHECK ((max_capacity > 0)) not valid;

alter table "mod_manufacturing"."workstations_duplicate" validate constraint "workstations_max_capacity_check";

alter table "mod_manufacturing"."workstations_duplicate" add constraint "workstations_station_type_check" CHECK ((station_type = ANY (ARRAY['forklift'::text, 'job shop'::text, 'machine'::text, 'hybrid'::text]))) not valid;

alter table "mod_manufacturing"."workstations_duplicate" validate constraint "workstations_station_type_check";

alter table "mod_pulse"."department_notification_configs" add constraint "department_notification_confi_department_id_notification_ty_key" UNIQUE using index "department_notification_confi_department_id_notification_ty_key";

alter table "mod_pulse"."department_notification_configs" add constraint "department_notification_configs_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."department_notification_configs" validate constraint "department_notification_configs_created_by_fkey";

alter table "mod_pulse"."department_notification_configs" add constraint "department_notification_configs_department_id_fkey" FOREIGN KEY (department_id) REFERENCES mod_base.departments(id) ON DELETE CASCADE not valid;

alter table "mod_pulse"."department_notification_configs" validate constraint "department_notification_configs_department_id_fkey";

alter table "mod_pulse"."department_notification_configs" add constraint "department_notification_configs_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."department_notification_configs" validate constraint "department_notification_configs_domain_id_fkey";

alter table "mod_pulse"."department_notification_configs" add constraint "department_notification_configs_notification_type_check" CHECK ((notification_type = ANY (ARRAY['new_pulse'::text, 'update_pulse'::text, 'new_message'::text, 'sla_warning'::text, 'warehouse_operation'::text, 'low_stock_alert'::text, 'new_sales_order'::text, 'work_order_finished'::text, 'inventory_received'::text, 'quality_check_failed'::text, 'maintenance_due'::text]))) not valid;

alter table "mod_pulse"."department_notification_configs" validate constraint "department_notification_configs_notification_type_check";

alter table "mod_pulse"."department_notification_configs" add constraint "department_notification_configs_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."department_notification_configs" validate constraint "department_notification_configs_updated_by_fkey";

alter table "mod_pulse"."notifications" add constraint "notifications_barcode_key" UNIQUE using index "notifications_barcode_key";

alter table "mod_pulse"."notifications" add constraint "notifications_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."notifications" validate constraint "notifications_created_by_fkey";

alter table "mod_pulse"."notifications" add constraint "notifications_department_id_fkey" FOREIGN KEY (department_id) REFERENCES mod_base.departments(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."notifications" validate constraint "notifications_department_id_fkey";

alter table "mod_pulse"."notifications" add constraint "notifications_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."notifications" validate constraint "notifications_domain_id_fkey";

alter table "mod_pulse"."notifications" add constraint "notifications_pulse_id_fkey" FOREIGN KEY (pulse_id) REFERENCES mod_pulse.pulses(id) ON DELETE CASCADE not valid;

alter table "mod_pulse"."notifications" validate constraint "notifications_pulse_id_fkey";

alter table "mod_pulse"."notifications" add constraint "notifications_type_check" CHECK ((type = ANY (ARRAY['new_pulse'::text, 'update_pulse'::text, 'new_message'::text, 'sla_warning'::text, 'new_mentioned'::text]))) not valid;

alter table "mod_pulse"."notifications" validate constraint "notifications_type_check";

alter table "mod_pulse"."notifications" add constraint "notifications_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."notifications" validate constraint "notifications_updated_by_fkey";

alter table "mod_pulse"."notifications" add constraint "notifications_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "mod_pulse"."notifications" validate constraint "notifications_user_id_fkey";

alter table "mod_pulse"."pulse_chat" add constraint "pulse_chat_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."pulse_chat" validate constraint "pulse_chat_created_by_fkey";

alter table "mod_pulse"."pulse_chat" add constraint "pulse_chat_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."pulse_chat" validate constraint "pulse_chat_domain_id_fkey";

alter table "mod_pulse"."pulse_chat" add constraint "pulse_chat_message_type_check" CHECK ((message_type = ANY (ARRAY['text'::text, 'image'::text, 'file'::text, 'system'::text, 'notification'::text]))) not valid;

alter table "mod_pulse"."pulse_chat" validate constraint "pulse_chat_message_type_check";

alter table "mod_pulse"."pulse_chat" add constraint "pulse_chat_pulse_id_fkey" FOREIGN KEY (pulse_id) REFERENCES mod_pulse.pulses(id) ON DELETE CASCADE not valid;

alter table "mod_pulse"."pulse_chat" validate constraint "pulse_chat_pulse_id_fkey";

alter table "mod_pulse"."pulse_chat" add constraint "pulse_chat_reply_to_id_fkey" FOREIGN KEY (reply_to_id) REFERENCES mod_pulse.pulse_chat(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."pulse_chat" validate constraint "pulse_chat_reply_to_id_fkey";

alter table "mod_pulse"."pulse_chat" add constraint "pulse_chat_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."pulse_chat" validate constraint "pulse_chat_updated_by_fkey";

alter table "mod_pulse"."pulse_chat_files" add constraint "pulse_chat_files_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."pulse_chat_files" validate constraint "pulse_chat_files_created_by_fkey";

alter table "mod_pulse"."pulse_chat_files" add constraint "pulse_chat_files_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."pulse_chat_files" validate constraint "pulse_chat_files_domain_id_fkey";

alter table "mod_pulse"."pulse_chat_files" add constraint "pulse_chat_files_message_id_fkey" FOREIGN KEY (message_id) REFERENCES mod_pulse.pulse_chat(id) ON DELETE CASCADE not valid;

alter table "mod_pulse"."pulse_chat_files" validate constraint "pulse_chat_files_message_id_fkey";

alter table "mod_pulse"."pulse_chat_files" add constraint "pulse_chat_files_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."pulse_chat_files" validate constraint "pulse_chat_files_updated_by_fkey";

alter table "mod_pulse"."pulse_checklists" add constraint "pulse_checklists_barcode_key" UNIQUE using index "pulse_checklists_barcode_key";

alter table "mod_pulse"."pulse_checklists" add constraint "pulse_checklists_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."pulse_checklists" validate constraint "pulse_checklists_created_by_fkey";

alter table "mod_pulse"."pulse_checklists" add constraint "pulse_checklists_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."pulse_checklists" validate constraint "pulse_checklists_domain_id_fkey";

alter table "mod_pulse"."pulse_checklists" add constraint "pulse_checklists_pulse_id_fkey" FOREIGN KEY (pulse_id) REFERENCES mod_pulse.pulses(id) ON DELETE CASCADE not valid;

alter table "mod_pulse"."pulse_checklists" validate constraint "pulse_checklists_pulse_id_fkey";

alter table "mod_pulse"."pulse_checklists" add constraint "pulse_checklists_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."pulse_checklists" validate constraint "pulse_checklists_updated_by_fkey";

alter table "mod_pulse"."pulse_comments" add constraint "pulse_comments_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."pulse_comments" validate constraint "pulse_comments_created_by_fkey";

alter table "mod_pulse"."pulse_comments" add constraint "pulse_comments_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."pulse_comments" validate constraint "pulse_comments_domain_id_fkey";

alter table "mod_pulse"."pulse_comments" add constraint "pulse_comments_pulse_id_fkey" FOREIGN KEY (pulse_id) REFERENCES mod_pulse.pulses(id) ON DELETE CASCADE not valid;

alter table "mod_pulse"."pulse_comments" validate constraint "pulse_comments_pulse_id_fkey";

alter table "mod_pulse"."pulse_comments" add constraint "pulse_comments_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."pulse_comments" validate constraint "pulse_comments_updated_by_fkey";

alter table "mod_pulse"."pulse_conversation_participants" add constraint "pulse_conversation_participants_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."pulse_conversation_participants" validate constraint "pulse_conversation_participants_created_by_fkey";

alter table "mod_pulse"."pulse_conversation_participants" add constraint "pulse_conversation_participants_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."pulse_conversation_participants" validate constraint "pulse_conversation_participants_domain_id_fkey";

alter table "mod_pulse"."pulse_conversation_participants" add constraint "pulse_conversation_participants_last_read_message_id_fkey" FOREIGN KEY (last_read_message_id) REFERENCES mod_pulse.pulse_chat(id) not valid;

alter table "mod_pulse"."pulse_conversation_participants" validate constraint "pulse_conversation_participants_last_read_message_id_fkey";

alter table "mod_pulse"."pulse_conversation_participants" add constraint "pulse_conversation_participants_notification_level_check" CHECK ((notification_level = ANY (ARRAY['all'::text, 'mentions'::text, 'none'::text]))) not valid;

alter table "mod_pulse"."pulse_conversation_participants" validate constraint "pulse_conversation_participants_notification_level_check";

alter table "mod_pulse"."pulse_conversation_participants" add constraint "pulse_conversation_participants_pulse_id_fkey" FOREIGN KEY (pulse_id) REFERENCES mod_pulse.pulses(id) ON DELETE CASCADE not valid;

alter table "mod_pulse"."pulse_conversation_participants" validate constraint "pulse_conversation_participants_pulse_id_fkey";

alter table "mod_pulse"."pulse_conversation_participants" add constraint "pulse_conversation_participants_role_check" CHECK ((role = ANY (ARRAY['admin'::text, 'member'::text, 'guest'::text]))) not valid;

alter table "mod_pulse"."pulse_conversation_participants" validate constraint "pulse_conversation_participants_role_check";

alter table "mod_pulse"."pulse_conversation_participants" add constraint "pulse_conversation_participants_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."pulse_conversation_participants" validate constraint "pulse_conversation_participants_updated_by_fkey";

alter table "mod_pulse"."pulse_conversation_participants" add constraint "pulse_conversation_participants_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "mod_pulse"."pulse_conversation_participants" validate constraint "pulse_conversation_participants_user_id_fkey";

alter table "mod_pulse"."pulse_progress" add constraint "pulse_progress_barcode_key" UNIQUE using index "pulse_progress_barcode_key";

alter table "mod_pulse"."pulse_progress" add constraint "pulse_progress_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."pulse_progress" validate constraint "pulse_progress_created_by_fkey";

alter table "mod_pulse"."pulse_progress" add constraint "pulse_progress_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."pulse_progress" validate constraint "pulse_progress_domain_id_fkey";

alter table "mod_pulse"."pulse_progress" add constraint "pulse_progress_new_assigned_to_fkey" FOREIGN KEY (new_assigned_to) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."pulse_progress" validate constraint "pulse_progress_new_assigned_to_fkey";

alter table "mod_pulse"."pulse_progress" add constraint "pulse_progress_new_priority_check" CHECK ((new_priority = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'urgent'::text]))) not valid;

alter table "mod_pulse"."pulse_progress" validate constraint "pulse_progress_new_priority_check";

alter table "mod_pulse"."pulse_progress" add constraint "pulse_progress_new_sla_id_fkey" FOREIGN KEY (new_sla_id) REFERENCES mod_pulse.pulse_slas(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."pulse_progress" validate constraint "pulse_progress_new_sla_id_fkey";

alter table "mod_pulse"."pulse_progress" add constraint "pulse_progress_new_status_check" CHECK ((new_status = ANY (ARRAY['open'::text, 'in_progress'::text, 'resolved'::text, 'closed'::text, 'on_hold'::text]))) not valid;

alter table "mod_pulse"."pulse_progress" validate constraint "pulse_progress_new_status_check";

alter table "mod_pulse"."pulse_progress" add constraint "pulse_progress_pulse_id_fkey" FOREIGN KEY (pulse_id) REFERENCES mod_pulse.pulses(id) ON DELETE CASCADE not valid;

alter table "mod_pulse"."pulse_progress" validate constraint "pulse_progress_pulse_id_fkey";

alter table "mod_pulse"."pulse_progress" add constraint "pulse_progress_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."pulse_progress" validate constraint "pulse_progress_updated_by_fkey";

alter table "mod_pulse"."pulse_slas" add constraint "pulse_slas_barcode_key" UNIQUE using index "pulse_slas_barcode_key";

alter table "mod_pulse"."pulse_slas" add constraint "pulse_slas_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."pulse_slas" validate constraint "pulse_slas_created_by_fkey";

alter table "mod_pulse"."pulse_slas" add constraint "pulse_slas_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."pulse_slas" validate constraint "pulse_slas_domain_id_fkey";

alter table "mod_pulse"."pulse_slas" add constraint "pulse_slas_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."pulse_slas" validate constraint "pulse_slas_updated_by_fkey";

alter table "mod_pulse"."pulses" add constraint "pulses_assigned_to_fkey" FOREIGN KEY (assigned_to) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."pulses" validate constraint "pulses_assigned_to_fkey";

alter table "mod_pulse"."pulses" add constraint "pulses_barcode_key" UNIQUE using index "pulses_barcode_key";

alter table "mod_pulse"."pulses" add constraint "pulses_conversation_type_check" CHECK ((conversation_type = ANY (ARRAY['department'::text, 'direct_message'::text, 'group'::text, 'task'::text, 'issue'::text]))) not valid;

alter table "mod_pulse"."pulses" validate constraint "pulses_conversation_type_check";

alter table "mod_pulse"."pulses" add constraint "pulses_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."pulses" validate constraint "pulses_created_by_fkey";

alter table "mod_pulse"."pulses" add constraint "pulses_department_id_fkey" FOREIGN KEY (department_id) REFERENCES mod_base.departments(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."pulses" validate constraint "pulses_department_id_fkey";

alter table "mod_pulse"."pulses" add constraint "pulses_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."pulses" validate constraint "pulses_domain_id_fkey";

alter table "mod_pulse"."pulses" add constraint "pulses_last_message_sender_id_fkey" FOREIGN KEY (last_message_sender_id) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."pulses" validate constraint "pulses_last_message_sender_id_fkey";

alter table "mod_pulse"."pulses" add constraint "pulses_priority_check" CHECK ((priority = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'urgent'::text]))) not valid;

alter table "mod_pulse"."pulses" validate constraint "pulses_priority_check";

alter table "mod_pulse"."pulses" add constraint "pulses_sla_id_fkey" FOREIGN KEY (sla_id) REFERENCES mod_pulse.pulse_slas(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."pulses" validate constraint "pulses_sla_id_fkey";

alter table "mod_pulse"."pulses" add constraint "pulses_status_check" CHECK ((status = ANY (ARRAY['open'::text, 'in_progress'::text, 'resolved'::text, 'closed'::text, 'on_hold'::text]))) not valid;

alter table "mod_pulse"."pulses" validate constraint "pulses_status_check";

alter table "mod_pulse"."pulses" add constraint "pulses_type_check" CHECK ((type = ANY (ARRAY['task'::text, 'issue'::text, 'incident'::text, 'risk'::text, 'change_request'::text, 'production'::text, 'stock_movement'::text]))) not valid;

alter table "mod_pulse"."pulses" validate constraint "pulses_type_check";

alter table "mod_pulse"."pulses" add constraint "pulses_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."pulses" validate constraint "pulses_updated_by_fkey";

alter table "mod_pulse"."tasks" add constraint "tasks_assigned_department_id_fkey" FOREIGN KEY (assigned_department_id) REFERENCES mod_base.departments(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."tasks" validate constraint "tasks_assigned_department_id_fkey";

alter table "mod_pulse"."tasks" add constraint "tasks_assigned_to_fkey" FOREIGN KEY (assigned_id) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."tasks" validate constraint "tasks_assigned_to_fkey";

alter table "mod_pulse"."tasks" add constraint "tasks_assignment_check" CHECK (((assigned_id IS NOT NULL) OR (assigned_department_id IS NOT NULL) OR (domain_id IS NULL))) not valid;

alter table "mod_pulse"."tasks" validate constraint "tasks_assignment_check";

alter table "mod_pulse"."tasks" add constraint "tasks_barcode_key" UNIQUE using index "tasks_barcode_key";

alter table "mod_pulse"."tasks" add constraint "tasks_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."tasks" validate constraint "tasks_created_by_fkey";

alter table "mod_pulse"."tasks" add constraint "tasks_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_pulse"."tasks" validate constraint "tasks_domain_id_fkey";

alter table "mod_pulse"."tasks" add constraint "tasks_priority_check" CHECK ((priority = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'urgent'::text]))) not valid;

alter table "mod_pulse"."tasks" validate constraint "tasks_priority_check";

alter table "mod_pulse"."tasks" add constraint "tasks_pulse_id_fkey" FOREIGN KEY (pulse_id) REFERENCES mod_pulse.pulses(id) ON DELETE CASCADE not valid;

alter table "mod_pulse"."tasks" validate constraint "tasks_pulse_id_fkey";

alter table "mod_pulse"."tasks" add constraint "tasks_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'in_progress'::text, 'completed'::text, 'blocked'::text]))) not valid;

alter table "mod_pulse"."tasks" validate constraint "tasks_status_check";

alter table "mod_pulse"."tasks" add constraint "tasks_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_pulse"."tasks" validate constraint "tasks_updated_by_fkey";

alter table "mod_quality_control"."conformity_documents" add constraint "conformity_documents_article_id_fkey" FOREIGN KEY (article_id) REFERENCES mod_base.articles(id) ON DELETE SET NULL not valid;

alter table "mod_quality_control"."conformity_documents" validate constraint "conformity_documents_article_id_fkey";

alter table "mod_quality_control"."conformity_documents" add constraint "conformity_documents_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_quality_control"."conformity_documents" validate constraint "conformity_documents_created_by_fkey";

alter table "mod_quality_control"."conformity_documents" add constraint "conformity_documents_document_type_check" CHECK ((document_type = ANY (ARRAY['MILL_TEST_CERTIFICATE'::text, 'MATERIAL_TEST_REPORT'::text, 'CERTIFICATE_OF_CONFORMITY'::text, 'CERTIFICATE_OF_ANALYSIS'::text, 'THIRD_PARTY_INSPECTION'::text, 'ASME_CERTIFICATE'::text, 'PED_CERTIFICATE'::text, 'ISO_CERTIFICATE'::text, 'OTHER'::text]))) not valid;

alter table "mod_quality_control"."conformity_documents" validate constraint "conformity_documents_document_type_check";

alter table "mod_quality_control"."conformity_documents" add constraint "conformity_documents_quality_control_id_fkey" FOREIGN KEY (quality_control_id) REFERENCES mod_base.quality_control(id) ON DELETE CASCADE not valid;

alter table "mod_quality_control"."conformity_documents" validate constraint "conformity_documents_quality_control_id_fkey";

alter table "mod_quality_control"."conformity_documents" add constraint "conformity_documents_supplier_id_fkey" FOREIGN KEY (supplier_id) REFERENCES mod_base.suppliers(id) ON DELETE SET NULL not valid;

alter table "mod_quality_control"."conformity_documents" validate constraint "conformity_documents_supplier_id_fkey";

alter table "mod_quality_control"."conformity_documents" add constraint "conformity_documents_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_quality_control"."conformity_documents" validate constraint "conformity_documents_updated_by_fkey";

alter table "mod_quality_control"."conformity_documents" add constraint "conformity_documents_verified_by_fkey" FOREIGN KEY (verified_by) REFERENCES auth.users(id) not valid;

alter table "mod_quality_control"."conformity_documents" validate constraint "conformity_documents_verified_by_fkey";

alter table "mod_quality_control"."conformity_documents" add constraint "unique_document_number" UNIQUE using index "unique_document_number";

alter table "mod_quality_control"."defect_types" add constraint "defect_types_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_quality_control"."defect_types" validate constraint "defect_types_created_by_fkey";

alter table "mod_quality_control"."defect_types" add constraint "defect_types_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_quality_control"."defect_types" validate constraint "defect_types_updated_by_fkey";

alter table "mod_quality_control"."defect_types" add constraint "unique_defect_code" UNIQUE using index "unique_defect_code";

alter table "mod_quality_control"."measurement_parameters" add constraint "measurement_parameters_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_quality_control"."measurement_parameters" validate constraint "measurement_parameters_created_by_fkey";

alter table "mod_quality_control"."measurement_parameters" add constraint "measurement_parameters_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_quality_control"."measurement_parameters" validate constraint "measurement_parameters_updated_by_fkey";

alter table "mod_quality_control"."measurement_parameters" add constraint "unique_parameter_code" UNIQUE using index "unique_parameter_code";

alter table "mod_quality_control"."quality_control_checklist_results" add constraint "quality_control_checklist_results_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_quality_control"."quality_control_checklist_results" validate constraint "quality_control_checklist_results_created_by_fkey";

alter table "mod_quality_control"."quality_control_checklist_results" add constraint "quality_control_checklist_results_inspector_id_fkey" FOREIGN KEY (inspector_id) REFERENCES auth.users(id) not valid;

alter table "mod_quality_control"."quality_control_checklist_results" validate constraint "quality_control_checklist_results_inspector_id_fkey";

alter table "mod_quality_control"."quality_control_checklist_results" add constraint "quality_control_checklist_results_quality_control_id_fkey" FOREIGN KEY (quality_control_id) REFERENCES mod_base.quality_control(id) ON DELETE CASCADE not valid;

alter table "mod_quality_control"."quality_control_checklist_results" validate constraint "quality_control_checklist_results_quality_control_id_fkey";

alter table "mod_quality_control"."quality_control_checklist_results" add constraint "quality_control_checklist_results_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_quality_control"."quality_control_checklist_results" validate constraint "quality_control_checklist_results_updated_by_fkey";

alter table "mod_quality_control"."quality_control_defects" add constraint "quality_control_defects_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_quality_control"."quality_control_defects" validate constraint "quality_control_defects_created_by_fkey";

alter table "mod_quality_control"."quality_control_defects" add constraint "quality_control_defects_defect_type_id_fkey" FOREIGN KEY (defect_type_id) REFERENCES mod_quality_control.defect_types(id) not valid;

alter table "mod_quality_control"."quality_control_defects" validate constraint "quality_control_defects_defect_type_id_fkey";

alter table "mod_quality_control"."quality_control_defects" add constraint "quality_control_defects_quality_control_id_fkey" FOREIGN KEY (quality_control_id) REFERENCES mod_base.quality_control(id) ON DELETE CASCADE not valid;

alter table "mod_quality_control"."quality_control_defects" validate constraint "quality_control_defects_quality_control_id_fkey";

alter table "mod_quality_control"."quality_control_defects" add constraint "quality_control_defects_quantity_check" CHECK ((quantity >= 0)) not valid;

alter table "mod_quality_control"."quality_control_defects" validate constraint "quality_control_defects_quantity_check";

alter table "mod_quality_control"."quality_control_defects" add constraint "quality_control_defects_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_quality_control"."quality_control_defects" validate constraint "quality_control_defects_updated_by_fkey";

alter table "mod_quality_control"."quality_control_measurements" add constraint "quality_control_measurements_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_quality_control"."quality_control_measurements" validate constraint "quality_control_measurements_created_by_fkey";

alter table "mod_quality_control"."quality_control_measurements" add constraint "quality_control_measurements_parameter_id_fkey" FOREIGN KEY (parameter_id) REFERENCES mod_quality_control.measurement_parameters(id) not valid;

alter table "mod_quality_control"."quality_control_measurements" validate constraint "quality_control_measurements_parameter_id_fkey";

alter table "mod_quality_control"."quality_control_measurements" add constraint "quality_control_measurements_quality_control_id_fkey" FOREIGN KEY (quality_control_id) REFERENCES mod_base.quality_control(id) ON DELETE CASCADE not valid;

alter table "mod_quality_control"."quality_control_measurements" validate constraint "quality_control_measurements_quality_control_id_fkey";

alter table "mod_quality_control"."quality_control_measurements" add constraint "quality_control_measurements_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_quality_control"."quality_control_measurements" validate constraint "quality_control_measurements_updated_by_fkey";

alter table "mod_quality_control"."supplier_returns" add constraint "supplier_returns_article_id_fkey" FOREIGN KEY (article_id) REFERENCES mod_base.articles(id) ON DELETE SET NULL not valid;

alter table "mod_quality_control"."supplier_returns" validate constraint "supplier_returns_article_id_fkey";

alter table "mod_quality_control"."supplier_returns" add constraint "supplier_returns_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_quality_control"."supplier_returns" validate constraint "supplier_returns_created_by_fkey";

alter table "mod_quality_control"."supplier_returns" add constraint "supplier_returns_purchase_order_id_fkey" FOREIGN KEY (purchase_order_id) REFERENCES mod_base.purchase_orders(id) ON DELETE SET NULL not valid;

alter table "mod_quality_control"."supplier_returns" validate constraint "supplier_returns_purchase_order_id_fkey";

alter table "mod_quality_control"."supplier_returns" add constraint "supplier_returns_quality_control_id_fkey" FOREIGN KEY (quality_control_id) REFERENCES mod_base.quality_control(id) ON DELETE SET NULL not valid;

alter table "mod_quality_control"."supplier_returns" validate constraint "supplier_returns_quality_control_id_fkey";

alter table "mod_quality_control"."supplier_returns" add constraint "supplier_returns_return_quantity_check" CHECK ((return_quantity > 0)) not valid;

alter table "mod_quality_control"."supplier_returns" validate constraint "supplier_returns_return_quantity_check";

alter table "mod_quality_control"."supplier_returns" add constraint "supplier_returns_supplier_id_fkey" FOREIGN KEY (supplier_id) REFERENCES mod_base.suppliers(id) ON DELETE SET NULL not valid;

alter table "mod_quality_control"."supplier_returns" validate constraint "supplier_returns_supplier_id_fkey";

alter table "mod_quality_control"."supplier_returns" add constraint "supplier_returns_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_quality_control"."supplier_returns" validate constraint "supplier_returns_updated_by_fkey";

alter table "mod_quality_control"."supplier_returns" add constraint "unique_return_number" UNIQUE using index "unique_return_number";

alter table "mod_wms"."batches" add constraint "batches_barcode_key" UNIQUE using index "batches_barcode_key";

alter table "mod_wms"."batches" add constraint "batches_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."batches" validate constraint "batches_created_by_fkey";

alter table "mod_wms"."batches" add constraint "batches_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."batches" validate constraint "batches_domain_id_fkey";

alter table "mod_wms"."batches" add constraint "batches_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."batches" validate constraint "batches_updated_by_fkey";

alter table "mod_wms"."box_contents" add constraint "box_contents_box_id_fkey" FOREIGN KEY (shipment_box_id) REFERENCES mod_wms.shipment_boxes(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."box_contents" validate constraint "box_contents_box_id_fkey";

alter table "mod_wms"."box_contents" add constraint "box_contents_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."box_contents" validate constraint "box_contents_created_by_fkey";

alter table "mod_wms"."box_contents" add constraint "box_contents_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."box_contents" validate constraint "box_contents_domain_id_fkey";

alter table "mod_wms"."box_contents" add constraint "box_contents_item_id_fkey" FOREIGN KEY (shipment_item_id) REFERENCES mod_wms.shipment_items(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."box_contents" validate constraint "box_contents_item_id_fkey";

alter table "mod_wms"."box_contents" add constraint "box_contents_quantity_positive" CHECK ((quantity_packed > 0)) not valid;

alter table "mod_wms"."box_contents" validate constraint "box_contents_quantity_positive";

alter table "mod_wms"."box_contents" add constraint "box_contents_unique_item_per_box" UNIQUE using index "box_contents_unique_item_per_box";

alter table "mod_wms"."box_contents" add constraint "box_contents_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."box_contents" validate constraint "box_contents_updated_by_fkey";

alter table "mod_wms"."box_types" add constraint "box_types_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."box_types" validate constraint "box_types_created_by_fkey";

alter table "mod_wms"."box_types" add constraint "box_types_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."box_types" validate constraint "box_types_domain_id_fkey";

alter table "mod_wms"."box_types" add constraint "box_types_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."box_types" validate constraint "box_types_updated_by_fkey";

alter table "mod_wms"."carton_contents" add constraint "carton_contents_carton_id_fkey" FOREIGN KEY (shipment_carton_id) REFERENCES mod_wms.shipment_cartons(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."carton_contents" validate constraint "carton_contents_carton_id_fkey";

alter table "mod_wms"."carton_contents" add constraint "carton_contents_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."carton_contents" validate constraint "carton_contents_created_by_fkey";

alter table "mod_wms"."carton_contents" add constraint "carton_contents_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."carton_contents" validate constraint "carton_contents_domain_id_fkey";

alter table "mod_wms"."carton_contents" add constraint "carton_contents_item_id_fkey" FOREIGN KEY (shipment_item_id) REFERENCES mod_wms.shipment_items(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."carton_contents" validate constraint "carton_contents_item_id_fkey";

alter table "mod_wms"."carton_contents" add constraint "carton_contents_quantity_positive" CHECK ((quantity_packed > 0)) not valid;

alter table "mod_wms"."carton_contents" validate constraint "carton_contents_quantity_positive";

alter table "mod_wms"."carton_contents" add constraint "carton_contents_unique_item_per_carton" UNIQUE using index "carton_contents_unique_item_per_carton";

alter table "mod_wms"."carton_contents" add constraint "carton_contents_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."carton_contents" validate constraint "carton_contents_updated_by_fkey";

alter table "mod_wms"."carton_types" add constraint "carton_types_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."carton_types" validate constraint "carton_types_created_by_fkey";

alter table "mod_wms"."carton_types" add constraint "carton_types_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."carton_types" validate constraint "carton_types_domain_id_fkey";

alter table "mod_wms"."carton_types" add constraint "carton_types_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."carton_types" validate constraint "carton_types_updated_by_fkey";

alter table "mod_wms"."inventory" add constraint "inventory_article_id_fkey1" FOREIGN KEY (article_id) REFERENCES mod_base.articles(id) not valid;

alter table "mod_wms"."inventory" validate constraint "inventory_article_id_fkey1";

alter table "mod_wms"."inventory" add constraint "inventory_article_id_location_id_batch_id_key" UNIQUE using index "inventory_article_id_location_id_batch_id_key";

alter table "mod_wms"."inventory" add constraint "inventory_batch_id_fkey1" FOREIGN KEY (batch_id) REFERENCES mod_wms.batches(id) not valid;

alter table "mod_wms"."inventory" validate constraint "inventory_batch_id_fkey1";

alter table "mod_wms"."inventory" add constraint "inventory_check" CHECK (((allocated_qty >= (0)::numeric) AND (allocated_qty <= quantity))) not valid;

alter table "mod_wms"."inventory" validate constraint "inventory_check";

alter table "mod_wms"."inventory" add constraint "inventory_created_by_fkey1" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."inventory" validate constraint "inventory_created_by_fkey1";

alter table "mod_wms"."inventory" add constraint "inventory_domain_id_fkey1" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."inventory" validate constraint "inventory_domain_id_fkey1";

alter table "mod_wms"."inventory" add constraint "inventory_location_id_fkey1" FOREIGN KEY (location_id) REFERENCES mod_wms.locations(id) not valid;

alter table "mod_wms"."inventory" validate constraint "inventory_location_id_fkey1";

alter table "mod_wms"."inventory" add constraint "inventory_quantity_check" CHECK ((quantity >= (0)::numeric)) not valid;

alter table "mod_wms"."inventory" validate constraint "inventory_quantity_check";

alter table "mod_wms"."inventory" add constraint "inventory_updated_by_fkey1" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."inventory" validate constraint "inventory_updated_by_fkey1";

alter table "mod_wms"."inventory_backup" add constraint "inventory_article_id_fkey" FOREIGN KEY (article_id) REFERENCES mod_base.articles(id) not valid;

alter table "mod_wms"."inventory_backup" validate constraint "inventory_article_id_fkey";

alter table "mod_wms"."inventory_backup" add constraint "inventory_batch_id_fkey" FOREIGN KEY (batch_id) REFERENCES mod_wms.batches(id) not valid;

alter table "mod_wms"."inventory_backup" validate constraint "inventory_batch_id_fkey";

alter table "mod_wms"."inventory_backup" add constraint "inventory_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."inventory_backup" validate constraint "inventory_created_by_fkey";

alter table "mod_wms"."inventory_backup" add constraint "inventory_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."inventory_backup" validate constraint "inventory_domain_id_fkey";

alter table "mod_wms"."inventory_backup" add constraint "inventory_location_id_fkey" FOREIGN KEY (location_id) REFERENCES mod_wms.locations(id) not valid;

alter table "mod_wms"."inventory_backup" validate constraint "inventory_location_id_fkey";

alter table "mod_wms"."inventory_backup" add constraint "inventory_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."inventory_backup" validate constraint "inventory_updated_by_fkey";

alter table "mod_wms"."inventory_limits" add constraint "inventory_limits_article_id_fkey" FOREIGN KEY (article_id) REFERENCES mod_base.articles(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."inventory_limits" validate constraint "inventory_limits_article_id_fkey";

alter table "mod_wms"."inventory_limits" add constraint "inventory_limits_barcode_key" UNIQUE using index "inventory_limits_barcode_key";

alter table "mod_wms"."inventory_limits" add constraint "inventory_limits_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."inventory_limits" validate constraint "inventory_limits_created_by_fkey";

alter table "mod_wms"."inventory_limits" add constraint "inventory_limits_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."inventory_limits" validate constraint "inventory_limits_domain_id_fkey";

alter table "mod_wms"."inventory_limits" add constraint "inventory_limits_location_id_fkey" FOREIGN KEY (location_id) REFERENCES mod_wms.locations(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."inventory_limits" validate constraint "inventory_limits_location_id_fkey";

alter table "mod_wms"."inventory_limits" add constraint "inventory_limits_max_stock_check" CHECK ((max_stock >= 0)) not valid;

alter table "mod_wms"."inventory_limits" validate constraint "inventory_limits_max_stock_check";

alter table "mod_wms"."inventory_limits" add constraint "inventory_limits_min_stock_check" CHECK ((min_stock >= 0)) not valid;

alter table "mod_wms"."inventory_limits" validate constraint "inventory_limits_min_stock_check";

alter table "mod_wms"."inventory_limits" add constraint "inventory_limits_reorder_point_check" CHECK ((reorder_point >= 0)) not valid;

alter table "mod_wms"."inventory_limits" validate constraint "inventory_limits_reorder_point_check";

alter table "mod_wms"."inventory_limits" add constraint "inventory_limits_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."inventory_limits" validate constraint "inventory_limits_updated_by_fkey";

alter table "mod_wms"."locations" add constraint "locations_barcode_key" UNIQUE using index "locations_barcode_key";

alter table "mod_wms"."locations" add constraint "locations_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."locations" validate constraint "locations_created_by_fkey";

alter table "mod_wms"."locations" add constraint "locations_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."locations" validate constraint "locations_domain_id_fkey";

alter table "mod_wms"."locations" add constraint "locations_type_check" CHECK ((type = ANY (ARRAY['aisle'::text, 'rack'::text, 'bin'::text, 'bulk'::text]))) not valid;

alter table "mod_wms"."locations" validate constraint "locations_type_check";

alter table "mod_wms"."locations" add constraint "locations_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."locations" validate constraint "locations_updated_by_fkey";

alter table "mod_wms"."locations" add constraint "locations_warehouse_id_fkey" FOREIGN KEY (warehouse_id) REFERENCES mod_wms.warehouses(id) not valid;

alter table "mod_wms"."locations" validate constraint "locations_warehouse_id_fkey";

alter table "mod_wms"."pallet_contents" add constraint "pallet_contents_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."pallet_contents" validate constraint "pallet_contents_created_by_fkey";

alter table "mod_wms"."pallet_contents" add constraint "pallet_contents_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."pallet_contents" validate constraint "pallet_contents_domain_id_fkey";

alter table "mod_wms"."pallet_contents" add constraint "pallet_contents_item_id_fkey" FOREIGN KEY (shipment_item_id) REFERENCES mod_wms.shipment_items(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."pallet_contents" validate constraint "pallet_contents_item_id_fkey";

alter table "mod_wms"."pallet_contents" add constraint "pallet_contents_pallet_id_fkey" FOREIGN KEY (shipment_pallet_id) REFERENCES mod_wms.shipment_pallets(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."pallet_contents" validate constraint "pallet_contents_pallet_id_fkey";

alter table "mod_wms"."pallet_contents" add constraint "pallet_contents_quantity_positive" CHECK ((quantity_packed > 0)) not valid;

alter table "mod_wms"."pallet_contents" validate constraint "pallet_contents_quantity_positive";

alter table "mod_wms"."pallet_contents" add constraint "pallet_contents_unique_item_per_pallet" UNIQUE using index "pallet_contents_unique_item_per_pallet";

alter table "mod_wms"."pallet_contents" add constraint "pallet_contents_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."pallet_contents" validate constraint "pallet_contents_updated_by_fkey";

alter table "mod_wms"."pallet_types" add constraint "pallet_types_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."pallet_types" validate constraint "pallet_types_created_by_fkey";

alter table "mod_wms"."pallet_types" add constraint "pallet_types_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."pallet_types" validate constraint "pallet_types_domain_id_fkey";

alter table "mod_wms"."pallet_types" add constraint "pallet_types_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."pallet_types" validate constraint "pallet_types_updated_by_fkey";

alter table "mod_wms"."receipt_items" add constraint "receipt_items_article_id_fkey" FOREIGN KEY (article_id) REFERENCES mod_base.articles(id) not valid;

alter table "mod_wms"."receipt_items" validate constraint "receipt_items_article_id_fkey";

alter table "mod_wms"."receipt_items" add constraint "receipt_items_barcode_key" UNIQUE using index "receipt_items_barcode_key";

alter table "mod_wms"."receipt_items" add constraint "receipt_items_batch_id_fkey" FOREIGN KEY (batch_id) REFERENCES mod_wms.batches(id) not valid;

alter table "mod_wms"."receipt_items" validate constraint "receipt_items_batch_id_fkey";

alter table "mod_wms"."receipt_items" add constraint "receipt_items_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."receipt_items" validate constraint "receipt_items_created_by_fkey";

alter table "mod_wms"."receipt_items" add constraint "receipt_items_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."receipt_items" validate constraint "receipt_items_domain_id_fkey";

alter table "mod_wms"."receipt_items" add constraint "receipt_items_location_id_fkey" FOREIGN KEY (location_id) REFERENCES mod_wms.locations(id) not valid;

alter table "mod_wms"."receipt_items" validate constraint "receipt_items_location_id_fkey";

alter table "mod_wms"."receipt_items" add constraint "receipt_items_qc_inspector_id_fkey" FOREIGN KEY (qc_inspector_id) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."receipt_items" validate constraint "receipt_items_qc_inspector_id_fkey";

alter table "mod_wms"."receipt_items" add constraint "receipt_items_qc_status_check" CHECK ((qc_status = ANY (ARRAY['PENDING'::text, 'IN_PROGRESS'::text, 'PASSED'::text, 'FAILED'::text, 'REJECTED'::text, 'ACCEPTED'::text]))) not valid;

alter table "mod_wms"."receipt_items" validate constraint "receipt_items_qc_status_check";

alter table "mod_wms"."receipt_items" add constraint "receipt_items_receipt_id_fkey" FOREIGN KEY (receipt_id) REFERENCES mod_wms.receipts(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."receipt_items" validate constraint "receipt_items_receipt_id_fkey";

alter table "mod_wms"."receipt_items" add constraint "receipt_items_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."receipt_items" validate constraint "receipt_items_updated_by_fkey";

alter table "mod_wms"."receipts" add constraint "receipts_barcode_key" UNIQUE using index "receipts_barcode_key";

alter table "mod_wms"."receipts" add constraint "receipts_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."receipts" validate constraint "receipts_created_by_fkey";

alter table "mod_wms"."receipts" add constraint "receipts_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."receipts" validate constraint "receipts_domain_id_fkey";

alter table "mod_wms"."receipts" add constraint "receipts_id_fkey" FOREIGN KEY (id) REFERENCES mod_pulse.pulses(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."receipts" validate constraint "receipts_id_fkey";

alter table "mod_wms"."receipts" add constraint "receipts_purchase_order_id_fkey" FOREIGN KEY (purchase_order_id) REFERENCES mod_base.purchase_orders(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."receipts" validate constraint "receipts_purchase_order_id_fkey";

alter table "mod_wms"."receipts" add constraint "receipts_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'processing'::text, 'in_transit'::text, 'received'::text, 'delivered'::text, 'failed'::text, 'completed'::text]))) not valid;

alter table "mod_wms"."receipts" validate constraint "receipts_status_check";

alter table "mod_wms"."receipts" add constraint "receipts_supplier_id_fkey" FOREIGN KEY (supplier_id) REFERENCES mod_base.suppliers(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."receipts" validate constraint "receipts_supplier_id_fkey";

alter table "mod_wms"."receipts" add constraint "receipts_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."receipts" validate constraint "receipts_updated_by_fkey";

alter table "mod_wms"."receipts" add constraint "receipts_warehouse_id_fkey" FOREIGN KEY (warehouse_id) REFERENCES mod_wms.warehouses(id) not valid;

alter table "mod_wms"."receipts" validate constraint "receipts_warehouse_id_fkey";

alter table "mod_wms"."shipment_attachments" add constraint "shipment_attachments_attachment_type_check" CHECK ((attachment_type = ANY (ARRAY['document'::text, 'photo'::text]))) not valid;

alter table "mod_wms"."shipment_attachments" validate constraint "shipment_attachments_attachment_type_check";

alter table "mod_wms"."shipment_attachments" add constraint "shipment_attachments_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."shipment_attachments" validate constraint "shipment_attachments_created_by_fkey";

alter table "mod_wms"."shipment_attachments" add constraint "shipment_attachments_shipment_id_fkey" FOREIGN KEY (shipment_id) REFERENCES mod_wms.shipments(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."shipment_attachments" validate constraint "shipment_attachments_shipment_id_fkey";

alter table "mod_wms"."shipment_boxes" add constraint "shipment_boxes_box_type_id_fkey" FOREIGN KEY (box_type_id) REFERENCES mod_wms.box_types(id) not valid;

alter table "mod_wms"."shipment_boxes" validate constraint "shipment_boxes_box_type_id_fkey";

alter table "mod_wms"."shipment_boxes" add constraint "shipment_boxes_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."shipment_boxes" validate constraint "shipment_boxes_created_by_fkey";

alter table "mod_wms"."shipment_boxes" add constraint "shipment_boxes_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."shipment_boxes" validate constraint "shipment_boxes_domain_id_fkey";

alter table "mod_wms"."shipment_boxes" add constraint "shipment_boxes_pallet_id_fkey" FOREIGN KEY (shipment_pallet_id) REFERENCES mod_wms.shipment_pallets(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."shipment_boxes" validate constraint "shipment_boxes_pallet_id_fkey";

alter table "mod_wms"."shipment_boxes" add constraint "shipment_boxes_parent_check" CHECK ((((shipment_pallet_id IS NOT NULL) AND (shipment_id IS NULL)) OR ((shipment_pallet_id IS NULL) AND (shipment_id IS NOT NULL)))) not valid;

alter table "mod_wms"."shipment_boxes" validate constraint "shipment_boxes_parent_check";

alter table "mod_wms"."shipment_boxes" add constraint "shipment_boxes_shipment_id_fkey" FOREIGN KEY (shipment_id) REFERENCES mod_wms.shipments(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."shipment_boxes" validate constraint "shipment_boxes_shipment_id_fkey";

alter table "mod_wms"."shipment_boxes" add constraint "shipment_boxes_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."shipment_boxes" validate constraint "shipment_boxes_updated_by_fkey";

alter table "mod_wms"."shipment_cartons" add constraint "shipment_cartons_carton_type_id_fkey" FOREIGN KEY (carton_type_id) REFERENCES mod_wms.carton_types(id) not valid;

alter table "mod_wms"."shipment_cartons" validate constraint "shipment_cartons_carton_type_id_fkey";

alter table "mod_wms"."shipment_cartons" add constraint "shipment_cartons_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."shipment_cartons" validate constraint "shipment_cartons_created_by_fkey";

alter table "mod_wms"."shipment_cartons" add constraint "shipment_cartons_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."shipment_cartons" validate constraint "shipment_cartons_domain_id_fkey";

alter table "mod_wms"."shipment_cartons" add constraint "shipment_cartons_pallet_id_fkey" FOREIGN KEY (shipment_pallet_id) REFERENCES mod_wms.shipment_pallets(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."shipment_cartons" validate constraint "shipment_cartons_pallet_id_fkey";

alter table "mod_wms"."shipment_cartons" add constraint "shipment_cartons_unique_number_per_pallet" UNIQUE using index "shipment_cartons_unique_number_per_pallet";

alter table "mod_wms"."shipment_cartons" add constraint "shipment_cartons_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."shipment_cartons" validate constraint "shipment_cartons_updated_by_fkey";

alter table "mod_wms"."shipment_item_addresses" add constraint "check_address_completeness" CHECK (((address IS NOT NULL) AND (city IS NOT NULL) AND (state IS NOT NULL))) not valid;

alter table "mod_wms"."shipment_item_addresses" validate constraint "check_address_completeness";

alter table "mod_wms"."shipment_item_addresses" add constraint "check_address_type" CHECK (((address_type)::text = ANY (ARRAY[('delivery'::character varying)::text, ('billing'::character varying)::text, ('pickup'::character varying)::text, ('return'::character varying)::text, ('custom'::character varying)::text]))) not valid;

alter table "mod_wms"."shipment_item_addresses" validate constraint "check_address_type";

alter table "mod_wms"."shipment_item_addresses" add constraint "fk_shipment_item_addresses_domain" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."shipment_item_addresses" validate constraint "fk_shipment_item_addresses_domain";

alter table "mod_wms"."shipment_item_addresses" add constraint "fk_shipment_item_addresses_shipment_item" FOREIGN KEY (shipment_item_id) REFERENCES mod_wms.shipment_items(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."shipment_item_addresses" validate constraint "fk_shipment_item_addresses_shipment_item";

alter table "mod_wms"."shipment_items" add constraint "shipment_items_article_id_fkey" FOREIGN KEY (article_id) REFERENCES mod_base.articles(id) not valid;

alter table "mod_wms"."shipment_items" validate constraint "shipment_items_article_id_fkey";

alter table "mod_wms"."shipment_items" add constraint "shipment_items_barcode_key" UNIQUE using index "shipment_items_barcode_key";

alter table "mod_wms"."shipment_items" add constraint "shipment_items_batch_id_fkey" FOREIGN KEY (batch_id) REFERENCES mod_wms.batches(id) not valid;

alter table "mod_wms"."shipment_items" validate constraint "shipment_items_batch_id_fkey";

alter table "mod_wms"."shipment_items" add constraint "shipment_items_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."shipment_items" validate constraint "shipment_items_created_by_fkey";

alter table "mod_wms"."shipment_items" add constraint "shipment_items_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."shipment_items" validate constraint "shipment_items_domain_id_fkey";

alter table "mod_wms"."shipment_items" add constraint "shipment_items_inventory_id_fkey" FOREIGN KEY (inventory_id) REFERENCES mod_wms.inventory(id) not valid;

alter table "mod_wms"."shipment_items" validate constraint "shipment_items_inventory_id_fkey";

alter table "mod_wms"."shipment_items" add constraint "shipment_items_location_id_fkey" FOREIGN KEY (location_id) REFERENCES mod_wms.locations(id) not valid;

alter table "mod_wms"."shipment_items" validate constraint "shipment_items_location_id_fkey";

alter table "mod_wms"."shipment_items" add constraint "shipment_items_shipment_id_fkey" FOREIGN KEY (shipment_id) REFERENCES mod_wms.shipments(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."shipment_items" validate constraint "shipment_items_shipment_id_fkey";

alter table "mod_wms"."shipment_items" add constraint "shipment_items_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."shipment_items" validate constraint "shipment_items_updated_by_fkey";

alter table "mod_wms"."shipment_pallets" add constraint "shipment_pallets_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."shipment_pallets" validate constraint "shipment_pallets_created_by_fkey";

alter table "mod_wms"."shipment_pallets" add constraint "shipment_pallets_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."shipment_pallets" validate constraint "shipment_pallets_domain_id_fkey";

alter table "mod_wms"."shipment_pallets" add constraint "shipment_pallets_pallet_type_id_fkey" FOREIGN KEY (pallet_type_id) REFERENCES mod_wms.pallet_types(id) not valid;

alter table "mod_wms"."shipment_pallets" validate constraint "shipment_pallets_pallet_type_id_fkey";

alter table "mod_wms"."shipment_pallets" add constraint "shipment_pallets_shipment_id_fkey" FOREIGN KEY (shipment_id) REFERENCES mod_wms.shipments(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."shipment_pallets" validate constraint "shipment_pallets_shipment_id_fkey";

alter table "mod_wms"."shipment_pallets" add constraint "shipment_pallets_unique_number_per_shipment" UNIQUE using index "shipment_pallets_unique_number_per_shipment";

alter table "mod_wms"."shipment_pallets" add constraint "shipment_pallets_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."shipment_pallets" validate constraint "shipment_pallets_updated_by_fkey";

alter table "mod_wms"."shipment_sales_orders" add constraint "shipment_sales_orders_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."shipment_sales_orders" validate constraint "shipment_sales_orders_created_by_fkey";

alter table "mod_wms"."shipment_sales_orders" add constraint "shipment_sales_orders_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."shipment_sales_orders" validate constraint "shipment_sales_orders_domain_id_fkey";

alter table "mod_wms"."shipment_sales_orders" add constraint "shipment_sales_orders_sales_order_id_fkey" FOREIGN KEY (sales_order_id) REFERENCES mod_base.sales_orders(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."shipment_sales_orders" validate constraint "shipment_sales_orders_sales_order_id_fkey";

alter table "mod_wms"."shipment_sales_orders" add constraint "shipment_sales_orders_shipment_id_fkey" FOREIGN KEY (shipment_id) REFERENCES mod_wms.shipments(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."shipment_sales_orders" validate constraint "shipment_sales_orders_shipment_id_fkey";

alter table "mod_wms"."shipment_sales_orders" add constraint "shipment_sales_orders_shipment_id_sales_order_id_key" UNIQUE using index "shipment_sales_orders_shipment_id_sales_order_id_key";

alter table "mod_wms"."shipment_sales_orders" add constraint "shipment_sales_orders_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."shipment_sales_orders" validate constraint "shipment_sales_orders_updated_by_fkey";

alter table "mod_wms"."shipment_standalone_items" add constraint "shipment_standalone_items_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."shipment_standalone_items" validate constraint "shipment_standalone_items_created_by_fkey";

alter table "mod_wms"."shipment_standalone_items" add constraint "shipment_standalone_items_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."shipment_standalone_items" validate constraint "shipment_standalone_items_domain_id_fkey";

alter table "mod_wms"."shipment_standalone_items" add constraint "shipment_standalone_items_item_id_fkey" FOREIGN KEY (shipment_item_id) REFERENCES mod_wms.shipment_items(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."shipment_standalone_items" validate constraint "shipment_standalone_items_item_id_fkey";

alter table "mod_wms"."shipment_standalone_items" add constraint "shipment_standalone_items_quantity_positive" CHECK ((quantity_packed > 0)) not valid;

alter table "mod_wms"."shipment_standalone_items" validate constraint "shipment_standalone_items_quantity_positive";

alter table "mod_wms"."shipment_standalone_items" add constraint "shipment_standalone_items_shipment_id_fkey" FOREIGN KEY (shipment_id) REFERENCES mod_wms.shipments(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."shipment_standalone_items" validate constraint "shipment_standalone_items_shipment_id_fkey";

alter table "mod_wms"."shipment_standalone_items" add constraint "shipment_standalone_items_unique_item_per_shipment" UNIQUE using index "shipment_standalone_items_unique_item_per_shipment";

alter table "mod_wms"."shipment_standalone_items" add constraint "shipment_standalone_items_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."shipment_standalone_items" validate constraint "shipment_standalone_items_updated_by_fkey";

alter table "mod_wms"."shipments" add constraint "shipments_barcode_key" UNIQUE using index "shipments_barcode_key";

alter table "mod_wms"."shipments" add constraint "shipments_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."shipments" validate constraint "shipments_created_by_fkey";

alter table "mod_wms"."shipments" add constraint "shipments_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."shipments" validate constraint "shipments_domain_id_fkey";

alter table "mod_wms"."shipments" add constraint "shipments_id_fkey" FOREIGN KEY (id) REFERENCES mod_pulse.pulses(id) ON DELETE CASCADE not valid;

alter table "mod_wms"."shipments" validate constraint "shipments_id_fkey";

alter table "mod_wms"."shipments" add constraint "shipments_sales_order_id_fkey" FOREIGN KEY (sales_order_id) REFERENCES mod_base.sales_orders(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."shipments" validate constraint "shipments_sales_order_id_fkey";

alter table "mod_wms"."shipments" add constraint "shipments_shipment_number_key" UNIQUE using index "shipments_shipment_number_key";

alter table "mod_wms"."shipments" add constraint "shipments_status_check" CHECK (((status IS NULL) OR (status = ANY (ARRAY['pending'::text, 'processing'::text, 'loaded'::text])))) not valid;

alter table "mod_wms"."shipments" validate constraint "shipments_status_check";

alter table "mod_wms"."shipments" add constraint "shipments_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."shipments" validate constraint "shipments_updated_by_fkey";

alter table "mod_wms"."shipments" add constraint "shipments_warehouse_id_fkey" FOREIGN KEY (warehouse_id) REFERENCES mod_wms.warehouses(id) not valid;

alter table "mod_wms"."shipments" validate constraint "shipments_warehouse_id_fkey";

alter table "mod_wms"."stock_movements" add constraint "stock_movements_article_id_fkey" FOREIGN KEY (article_id) REFERENCES mod_base.articles(id) not valid;

alter table "mod_wms"."stock_movements" validate constraint "stock_movements_article_id_fkey";

alter table "mod_wms"."stock_movements" add constraint "stock_movements_barcode_key" UNIQUE using index "stock_movements_barcode_key";

alter table "mod_wms"."stock_movements" add constraint "stock_movements_batch_id_fkey" FOREIGN KEY (batch_id) REFERENCES mod_wms.batches(id) not valid;

alter table "mod_wms"."stock_movements" validate constraint "stock_movements_batch_id_fkey";

alter table "mod_wms"."stock_movements" add constraint "stock_movements_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."stock_movements" validate constraint "stock_movements_created_by_fkey";

alter table "mod_wms"."stock_movements" add constraint "stock_movements_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."stock_movements" validate constraint "stock_movements_domain_id_fkey";

alter table "mod_wms"."stock_movements" add constraint "stock_movements_from_location_id_fkey" FOREIGN KEY (from_location_id) REFERENCES mod_wms.locations(id) not valid;

alter table "mod_wms"."stock_movements" validate constraint "stock_movements_from_location_id_fkey";

alter table "mod_wms"."stock_movements" add constraint "stock_movements_internal_sales_order_id_fkey" FOREIGN KEY (internal_sales_order_id) REFERENCES mod_base.internal_sales_orders(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."stock_movements" validate constraint "stock_movements_internal_sales_order_id_fkey";

alter table "mod_wms"."stock_movements" add constraint "stock_movements_origin_article_id_fkey" FOREIGN KEY (origin_article_id) REFERENCES mod_base.articles(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."stock_movements" validate constraint "stock_movements_origin_article_id_fkey";

alter table "mod_wms"."stock_movements" add constraint "stock_movements_original_receipt_item_id_fkey" FOREIGN KEY (original_receipt_item_id) REFERENCES mod_wms.receipt_items(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."stock_movements" validate constraint "stock_movements_original_receipt_item_id_fkey";

alter table "mod_wms"."stock_movements" add constraint "stock_movements_receipt_item_id_fkey" FOREIGN KEY (receipt_item_id) REFERENCES mod_wms.receipt_items(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."stock_movements" validate constraint "stock_movements_receipt_item_id_fkey";

alter table "mod_wms"."stock_movements" add constraint "stock_movements_sales_order_id_fkey" FOREIGN KEY (sales_order_id) REFERENCES mod_base.sales_orders(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."stock_movements" validate constraint "stock_movements_sales_order_id_fkey";

alter table "mod_wms"."stock_movements" add constraint "stock_movements_to_location_id_fkey" FOREIGN KEY (to_location_id) REFERENCES mod_wms.locations(id) not valid;

alter table "mod_wms"."stock_movements" validate constraint "stock_movements_to_location_id_fkey";

alter table "mod_wms"."stock_movements" add constraint "stock_movements_type_check" CHECK ((type = ANY (ARRAY['inbound'::text, 'outbound'::text, 'relocation'::text, 'adjustment'::text, 'allocation'::text, 'allocation_release'::text, 'loading'::text, 'unloading'::text, 'manual_loading'::text, 'transport'::text]))) not valid;

alter table "mod_wms"."stock_movements" validate constraint "stock_movements_type_check";

alter table "mod_wms"."stock_movements" add constraint "stock_movements_unit_of_measure_id_fkey" FOREIGN KEY (unit_of_measure_id) REFERENCES mod_base.units_of_measure(id) not valid;

alter table "mod_wms"."stock_movements" validate constraint "stock_movements_unit_of_measure_id_fkey";

alter table "mod_wms"."stock_movements" add constraint "stock_movements_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."stock_movements" validate constraint "stock_movements_updated_by_fkey";

alter table "mod_wms"."stock_movements" add constraint "stock_movements_work_order_id_fkey" FOREIGN KEY (work_order_id) REFERENCES mod_manufacturing.work_orders(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."stock_movements" validate constraint "stock_movements_work_order_id_fkey";

alter table "mod_wms"."warehouses" add constraint "warehouses_barcode_key" UNIQUE using index "warehouses_barcode_key";

alter table "mod_wms"."warehouses" add constraint "warehouses_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."warehouses" validate constraint "warehouses_created_by_fkey";

alter table "mod_wms"."warehouses" add constraint "warehouses_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES mod_admin.domains(id) ON DELETE SET NULL not valid;

alter table "mod_wms"."warehouses" validate constraint "warehouses_domain_id_fkey";

alter table "mod_wms"."warehouses" add constraint "warehouses_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "mod_wms"."warehouses" validate constraint "warehouses_updated_by_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION common.set_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_admin.delete_avatar(avatar_url text, OUT status integer, OUT content text)
 RETURNS record
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  select
      into status, content
           result.status, result.content
      from mod_admin.delete_storage_object('avatars', avatar_url) as result;
end;
$function$
;

CREATE OR REPLACE FUNCTION mod_admin.delete_background_image(background_image_url text, OUT status integer, OUT content text)
 RETURNS record
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  select
      into status, content
           result.status, result.content
      from mod_admin.delete_storage_object('background_images', background_image_url) as result;
end;
$function$
;

CREATE OR REPLACE FUNCTION mod_admin.delete_old_avatar()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_admin.delete_old_background_image()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_admin.delete_old_profile()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  delete from mod_admin.user_profiles where id = old.id;
  return old;
end;
$function$
;

CREATE OR REPLACE FUNCTION mod_admin.delete_storage_object(bucket text, object text, OUT status integer, OUT content text)
 RETURNS record
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_admin.handle_domain_modules_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_admin.handle_domain_users_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_admin.handle_domains_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_admin.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_admin.handle_user_deletion()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_admin.handle_userprofile_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_admin.is_subdomain(child uuid, parent uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
with recursive hierarchy as (
    select id, parent_domain_id from mod_admin.domains where id = child
    union all
    select d.id, d.parent_domain_id 
    from mod_admin.domains d 
    join hierarchy h on d.id = h.parent_domain_id
)
select exists (select 1 from hierarchy where parent_domain_id = parent);
$function$
;

create or replace view "mod_admin"."user_domain_info_view" as  SELECT up."lastName",
    up."firstName",
    u.email,
    u.id AS user_id,
    d.name AS domain_name,
    d.id AS domain_id
   FROM (((mod_admin.user_profiles up
     JOIN auth.users u ON ((up.id = u.id)))
     JOIN mod_admin.domain_users du ON ((du.user_id = u.id)))
     JOIN mod_admin.domains d ON ((du.domain_id = d.id)))
  WHERE ((up.is_deleted = false) AND (d.is_deleted = false));


CREATE OR REPLACE FUNCTION mod_base.alert_quality_control_failed()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.calculate_qc_status(p_quantity_checked integer, p_quantity_passed integer, p_quantity_failed integer, p_acceptance_number integer, p_rejection_number integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.cleanup_work_orders_on_internal_unschedule()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.cleanup_work_orders_on_unschedule()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.count_active_records(table_name text, schema_name text DEFAULT 'mod_base'::text)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.count_total_records(table_name text, schema_name text DEFAULT 'mod_base'::text)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.create_quality_control_for_shipment()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.direct_alert_new_sales_order()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

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

CREATE OR REPLACE FUNCTION mod_base.generate_serial_number_for_sales_order_item()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.get_checklist_results_summary(qc_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_announcements_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_archive_sales_order_on_status_completed()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_article_categories_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_articles_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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

CREATE OR REPLACE FUNCTION mod_base.handle_customers_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_departments_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_employees_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_employees_departments_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_internal_sales_order_completion_on_manufacturing()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_new_employee()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_profiles_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_purchase_order_items_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_purchase_orders_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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

CREATE OR REPLACE FUNCTION mod_base.handle_quality_control_types_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  IF TG_OP = 'INSERT' THEN
    NEW.created_by := COALESCE(NEW.created_by, auth.uid());
  ELSIF TG_OP = 'UPDATE' THEN
    NEW.updated_by := auth.uid();
    NEW.updated_at := now();
  END IF;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_sales_order_completion_on_manufacturing()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_sales_order_items_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_sales_orders_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_serial_number_counters_audit()
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
        NEW.updated_at := NOW();
    END IF;
    
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_suppliers_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_units_of_measure_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.handle_update_sales_order_status_on_all_items_shipped()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.internal_sales_order_items_production_date_notification()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.internal_sales_order_items_scheduling_notification_for_fabrizio()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

create or replace view "mod_base"."internal_sales_order_items_stats" as  SELECT 'Internal Sales Order Items'::text AS table_name,
    mod_base.count_total_records('internal_sales_order_items'::text) AS total_records,
    mod_base.count_active_records('internal_sales_order_items'::text) AS active_records,
    (mod_base.count_total_records('internal_sales_order_items'::text) - mod_base.count_active_records('internal_sales_order_items'::text)) AS deleted_records;


create or replace view "mod_base"."internal_sales_orders_stats" as  SELECT 'Internal Sales Orders'::text AS table_name,
    mod_base.count_total_records('internal_sales_orders'::text) AS total_records,
    mod_base.count_active_records('internal_sales_orders'::text) AS active_records,
    (mod_base.count_total_records('internal_sales_orders'::text) - mod_base.count_active_records('internal_sales_orders'::text)) AS deleted_records;


CREATE OR REPLACE FUNCTION mod_base.process_heat_exchanger_boms(bom_data_array jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

create or replace view "mod_base"."purchase_order_qc_tracking" as  SELECT po.id AS purchase_order_id,
    po.code AS purchase_order_code,
    po.status AS purchase_order_status,
    po.supplier_id,
    s.name AS supplier_name,
    poi.id AS purchase_order_item_id,
    poi.name AS item_name,
    poi.quantity_ordered,
    poi.quantity_received,
    poi.quantity_defect,
    poi.is_completed AS item_completed,
    poi.is_quantity_moved AS item_moved_to_inventory,
    qc.id AS quality_control_id,
    qc.code AS qc_code,
    qc.status AS qc_status,
    qc.quantity_checked,
    qc.quantity_passed,
    qc.quantity_failed,
    qc.completed_date AS qc_completed_date,
    qc.inspector_id,
    u.email AS inspector_email,
    COALESCE(defect_summary.defects_found, (0)::bigint) AS defects_found,
    COALESCE(checklist_summary.checklist_items_completed, (0)::bigint) AS checklist_items_completed,
    COALESCE(return_summary.supplier_returns_created, (0)::bigint) AS supplier_returns_created,
        CASE
            WHEN (qc.id IS NULL) THEN 'QC_PENDING'::text
            WHEN (qc.status = 'PASSED'::text) THEN 'QC_PASSED'::text
            WHEN (qc.status = 'CONDITIONALLY_ACCEPTED'::text) THEN 'QC_CONDITIONAL'::text
            WHEN (qc.status = 'FAILED'::text) THEN 'QC_FAILED'::text
            WHEN (qc.status = 'HOLD'::text) THEN 'QC_HOLD'::text
            WHEN (qc.status = ANY (ARRAY['PLANNED'::text, 'IN_PROGRESS'::text])) THEN 'QC_IN_PROGRESS'::text
            ELSE 'QC_UNKNOWN'::text
        END AS overall_status
   FROM (((((((mod_base.purchase_orders po
     JOIN mod_base.purchase_order_items poi ON ((po.id = poi.purchase_order_id)))
     LEFT JOIN mod_base.suppliers s ON ((po.supplier_id = s.id)))
     LEFT JOIN mod_base.quality_control qc ON ((poi.id = qc.purchase_order_item_id)))
     LEFT JOIN auth.users u ON ((qc.inspector_id = u.id)))
     LEFT JOIN ( SELECT quality_control_defects.quality_control_id,
            count(*) AS defects_found
           FROM mod_quality_control.quality_control_defects
          WHERE (NOT quality_control_defects.is_deleted)
          GROUP BY quality_control_defects.quality_control_id) defect_summary ON ((qc.id = defect_summary.quality_control_id)))
     LEFT JOIN ( SELECT quality_control_checklist_results.quality_control_id,
            count(*) AS checklist_items_completed
           FROM mod_quality_control.quality_control_checklist_results
          WHERE (NOT quality_control_checklist_results.is_deleted)
          GROUP BY quality_control_checklist_results.quality_control_id) checklist_summary ON ((qc.id = checklist_summary.quality_control_id)))
     LEFT JOIN ( SELECT supplier_returns.quality_control_id,
            count(*) AS supplier_returns_created
           FROM mod_quality_control.supplier_returns
          GROUP BY supplier_returns.quality_control_id) return_summary ON ((qc.id = return_summary.quality_control_id)))
  WHERE ((NOT po.is_deleted) AND (NOT poi.is_deleted))
  ORDER BY po.code, poi.name;


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


create or replace view "mod_base"."quality_control_summary" as  SELECT qc.id,
    qc.code,
    qc.name,
    qc.status,
    qc.reference_type,
    qc.reference_id,
    qc.inspector_id,
    qc.quantity_checked,
    qc.quantity_passed,
    qc.quantity_failed,
    count(DISTINCT qcd.id) AS defect_count,
    count(DISTINCT qcm.id) AS measurement_count,
    count(DISTINCT qcr.id) AS checklist_count,
    qc.created_at,
    qc.completed_date,
    u.email AS inspector_email,
    (u.raw_user_meta_data ->> 'full_name'::text) AS inspector_name,
    qc.purchase_order_item_id,
    po.code AS purchase_order_code,
    po.supplier_id,
    poi.name AS item_name,
    poi.quantity_ordered,
    poi.quantity_received,
    poi.quantity_defect,
    s.name AS supplier_name,
        CASE
            WHEN (qc.purchase_order_item_id IS NOT NULL) THEN 'INCOMING_MATERIAL'::text
            WHEN (qc.reference_type = 'WORK_ORDER'::text) THEN 'PRODUCTION'::text
            WHEN (qc.reference_type = 'SALES_ORDER'::text) THEN 'OUTGOING'::text
            ELSE 'OTHER'::text
        END AS qc_type
   FROM (((((((mod_base.quality_control qc
     LEFT JOIN mod_base.purchase_order_items poi ON ((qc.purchase_order_item_id = poi.id)))
     LEFT JOIN mod_base.purchase_orders po ON ((poi.purchase_order_id = po.id)))
     LEFT JOIN mod_base.suppliers s ON ((po.supplier_id = s.id)))
     LEFT JOIN mod_quality_control.quality_control_defects qcd ON (((qc.id = qcd.quality_control_id) AND (NOT qcd.is_deleted))))
     LEFT JOIN mod_quality_control.quality_control_measurements qcm ON (((qc.id = qcm.quality_control_id) AND (NOT qcm.is_deleted))))
     LEFT JOIN mod_quality_control.quality_control_checklist_results qcr ON (((qc.id = qcr.quality_control_id) AND (NOT qcr.is_deleted))))
     LEFT JOIN auth.users u ON ((qc.inspector_id = u.id)))
  WHERE (NOT qc.is_deleted)
  GROUP BY qc.id, po.code, po.supplier_id, poi.name, poi.quantity_ordered, poi.quantity_received, poi.quantity_defect, s.name, u.email, u.raw_user_meta_data;


CREATE OR REPLACE FUNCTION mod_base.sales_order_items_production_date_notification()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.sales_order_items_scheduling_notification_for_fabrizio()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.sales_order_status_notification()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

create or replace view "mod_base"."sales_orders_stats" as  SELECT 'Sales Orders'::text AS table_name,
    mod_base.count_total_records('sales_orders'::text) AS total_records,
    mod_base.count_active_records('sales_orders'::text) AS active_records,
    (mod_base.count_total_records('sales_orders'::text) - mod_base.count_active_records('sales_orders'::text)) AS deleted_records;


CREATE OR REPLACE FUNCTION mod_base.send_notification_to_department_members(p_title text, p_text text, p_department_id uuid, p_created_by uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_base.send_notification_to_user(p_title text, p_text text, p_user_id uuid, p_created_by uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO mod_pulse.notifications (name, description, user_id, created_at, created_by)
    VALUES (p_title, p_text, p_user_id, now(), p_created_by);
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_base.update_bom_articles_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_base.update_purchase_order_item_completion()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Update is_completed based on received quantity
    NEW.is_completed := (NEW.quantity_received >= NEW.quantity_ordered);
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_base.update_quality_control_checklist_results_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = now();
    NEW.updated_by = auth.uid();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_base.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_datalayer.generate_code_format(table_name text, table_prefix text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

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

CREATE OR REPLACE FUNCTION mod_datalayer.handle_fields_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_datalayer.handle_main_menu_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_datalayer.handle_modules_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_datalayer.handle_page_categories_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_datalayer.handle_pages_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_datalayer.handle_pages_departments_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_datalayer.handle_tables_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_datalayer.populate_sort_orders()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_datalayer.sync_fields()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_datalayer.sync_modules()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_datalayer.sync_tables()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_datalayer.update_fields_input_options()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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

CREATE OR REPLACE FUNCTION mod_manufacturing.create_work_order_quality_summary()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.create_work_orders_for_scheduling(p_order_item_id uuid, p_scheduled_date timestamp without time zone, p_order_type text, p_article_product_type text, p_user_id uuid, p_domain_id uuid, p_article_id uuid, p_article_name text, p_quantity_ordered integer, p_assigned_to uuid DEFAULT NULL::uuid, p_assigned_department_id uuid DEFAULT NULL::uuid, p_priority integer DEFAULT 2, p_expected_end_date timestamp without time zone DEFAULT NULL::timestamp without time zone)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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

CREATE OR REPLACE FUNCTION mod_manufacturing.handle_departments_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.handle_internal_work_order_manufacturing_status()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.handle_locations_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.handle_new_table_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.handle_production_logs_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.handle_recipes_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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

CREATE OR REPLACE FUNCTION mod_manufacturing.handle_work_cycles_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Maintain updated_at timestamp on updates only
  IF TG_OP = 'UPDATE' THEN
    NEW.updated_at := now();
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.handle_work_order_manufacturing_status()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.handle_work_order_quality_summary_audit()
 RETURNS trigger
 LANGUAGE plpgsql
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
        
        -- Update completed_at if status changed to a final state
        IF OLD.overall_status != NEW.overall_status AND 
           NEW.overall_status IN ('PASSED', 'FAILED') AND
           NEW.completed_at IS NULL THEN
            NEW.completed_at := now();
        END IF;
    END IF;

    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.handle_work_order_status_notifications()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.handle_work_order_status_tracking()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Only process if status actually changed
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    
    -- Handle status change to 'in_progress' - set started_by and started_at
    -- Always update to track the latest start/resume, even if previously set
    IF NEW.status = 'in_progress' AND (OLD.status IS NULL OR OLD.status != 'in_progress') THEN
      NEW.started_by := auth.uid();
      NEW.started_at := now();
    END IF;
    
    -- Handle status change to 'paused' - set paused_by and paused_at
    -- Always update to track the latest pause, even if previously set
    IF NEW.status = 'paused' AND (OLD.status IS NULL OR OLD.status != 'paused') THEN
      NEW.paused_by := auth.uid();
      NEW.paused_at := now();
    END IF;
    
    -- Handle status change to 'completed' - set completed_by and completed_at
    -- Always update to track the latest completion, even if previously set
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
      NEW.completed_by := auth.uid();
      NEW.completed_at := now();
    END IF;
    
  END IF;
  
  RETURN NEW;
  
EXCEPTION WHEN OTHERS THEN
  -- Log error but don't fail the update - this ensures the status change still happens
  -- even if there's an issue setting the tracking fields
  RAISE WARNING 'Error setting work order status tracking fields: % (work_order_id: %, status: % -> %)', 
               SQLERRM, NEW.id, OLD.status, NEW.status;
  -- Return NEW to allow the update to proceed
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.handle_work_orders_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.handle_work_steps_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.handle_workstations_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.update_article_loaded_for_all_work_orders()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.update_article_unloaded_for_all_work_orders()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.update_production_date_on_work_order_insert()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.update_sales_order_in_production_on_work_order_status()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.update_sales_order_status_on_work_order_in_progress()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.update_work_cycle_categories_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_manufacturing.update_work_flows_work_cycles_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at := now();
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

CREATE OR REPLACE FUNCTION mod_pulse.delete_chat_attachment(file_url text, OUT status integer, OUT content text)
 RETURNS record
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.delete_old_chat_attachment()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.get_user_notifications(p_limit integer DEFAULT 50, p_offset integer DEFAULT 0, p_is_read boolean DEFAULT NULL::boolean)
 RETURNS TABLE(id uuid, name text, description text, code text, type text, is_read boolean, avatar_url text, barcode text, created_at timestamp with time zone, updated_at timestamp with time zone, created_by uuid, updated_by uuid, pulse_id uuid, total_count bigint)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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

CREATE OR REPLACE FUNCTION mod_pulse.handle_new_task_notifications()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.handle_notifications_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.handle_pulse_chat_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.handle_pulse_chat_files_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.handle_pulse_checklists_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.handle_pulse_comments_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.handle_pulse_conversation_participants_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.handle_pulse_progress_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.handle_pulse_sla_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.handle_pulses_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.handle_record_deletion()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Delete the corresponding pulse record
  DELETE FROM mod_pulse.pulses WHERE id = OLD.id;
  RETURN OLD;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.handle_task_assignment_updates()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.handle_tasks_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.mark_all_notifications_as_read()
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.mark_notification_as_read(p_notification_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_pulse.update_pulse_status()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_quality_control.generate_return_number()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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


CREATE OR REPLACE FUNCTION mod_wms.calculate_total_available_stock()
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN COALESCE(
        (SELECT SUM(i.quantity)
         FROM mod_wms.inventory i
         WHERE i.quantity > 0),
        0
    );
END;
$function$
;

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

CREATE OR REPLACE FUNCTION mod_wms.count_low_stock_items()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN (
        SELECT COUNT(DISTINCT i.article_id)
        FROM mod_wms.inventory i
        JOIN mod_wms.inventory_limits il ON il.article_id = i.article_id
        WHERE i.quantity < il.min_stock
    );
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.count_out_of_stock_items()
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN (
        SELECT COUNT(DISTINCT article_id)
        FROM mod_wms.inventory
        WHERE quantity <= 0 OR quantity IS NULL
    );
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


CREATE OR REPLACE FUNCTION mod_wms.debug_relocation_movement(p_article_id uuid, p_from_location_id uuid, p_to_location_id uuid, p_batch_id uuid DEFAULT NULL::uuid)
 RETURNS TABLE(location_name text, batch_number text, current_quantity numeric, movement_type text)
 LANGUAGE plpgsql
AS $function$
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
$function$
;

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

CREATE OR REPLACE FUNCTION mod_wms.get_historical_inventory_stats(target_date timestamp with time zone)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
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

CREATE OR REPLACE FUNCTION mod_wms.handle_archive_shipment_on_status_loaded()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    -- Safety guard: only process when status changes to 'loaded'
    IF NEW.status IS DISTINCT FROM 'loaded' OR OLD.status = 'loaded' THEN
        RETURN NEW;
    END IF;

    -- Wrap the entire update logic in error handling to prevent transaction rollback
    BEGIN
        -- Archive the shipment by setting is_archived = TRUE
        UPDATE mod_wms.shipments
        SET 
            is_archived = TRUE,
            updated_at = NOW()
        WHERE id = NEW.id
          AND is_archived = FALSE; -- Only update if not already archived to avoid unnecessary updates

    EXCEPTION WHEN OTHERS THEN
        -- Log the error but don't abort the transaction
        -- This allows the shipment status update to complete even if archiving fails
        RAISE WARNING 'Error in handle_archive_shipment_on_status_loaded for shipment %: %', NEW.id, SQLERRM;
        -- Return NEW to allow the shipment status update to succeed
    END;

    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_article_components_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_batches_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_inbound_stock_movement()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_inventory_audit()
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
        NEW.updated_at := NOW();
    END IF;

    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_inventory_limits_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_loading_stock_movement()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_locations_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_original_receipt_item_id()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_outbound_unloading_stock_movement()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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

CREATE OR REPLACE FUNCTION mod_wms.handle_receipt_items_inbound_on_insert()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_receipts_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_relocation_stock_movement()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_shipment_items_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_shipments_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_shipments_outbound_on_status_change()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_stock_movements_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_transport_stock_movement()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_update_sales_order_items_is_shipped_on_loaded()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.handle_warehouses_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.inventory_quantity_notification_for_serena_fabrizio()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  notification_name TEXT;
  notification_description TEXT;
  article_name TEXT;
  old_total_quantity NUMERIC(12, 4);
  new_total_quantity NUMERIC(12, 4);
  min_stock_value INTEGER;
  max_stock_value INTEGER;
  should_notify BOOLEAN := FALSE;
  stock_status_message TEXT := '';
BEGIN
  -- Only proceed if quantity actually changed
  IF OLD.quantity IS NOT DISTINCT FROM NEW.quantity THEN
    RETURN NEW;
  END IF;

  -- Wrap entire notification logic in exception handler to prevent errors from blocking inventory updates
  BEGIN
    -- Get article name and stock limits directly from articles table
    SELECT a.name, a.min_stock, a.max_stock 
    INTO article_name, min_stock_value, max_stock_value
    FROM mod_base.articles a
    WHERE a.id = NEW.article_id;

    -- Only proceed if article exists and has stock limits defined
    IF article_name IS NULL OR (min_stock_value IS NULL AND max_stock_value IS NULL) THEN
      RETURN NEW;
    END IF;

    -- Calculate OLD total quantity across ALL locations and batches for this article
    -- We need to simulate what the total was before this update
    SELECT COALESCE(SUM(i.quantity), 0) INTO old_total_quantity
    FROM mod_wms.inventory i
    WHERE i.article_id = NEW.article_id
      AND (i.id != NEW.id OR i.id IS NULL);

    -- Add the old quantity from this record
    old_total_quantity := old_total_quantity + OLD.quantity;

    -- Calculate NEW total quantity across ALL locations and batches for this article
    SELECT COALESCE(SUM(i.quantity), 0) INTO new_total_quantity
    FROM mod_wms.inventory i
    WHERE i.article_id = NEW.article_id;

    -- Check if we need to send notifications based on threshold crossings
    -- Condition 1: Total quantity crossed below min_stock (was >= min, now < min)
    IF min_stock_value IS NOT NULL THEN
      IF old_total_quantity >= min_stock_value AND new_total_quantity < min_stock_value THEN
        should_notify := TRUE;
        stock_status_message := 'Scorta bassa: ' || new_total_quantity::text || ' disponibili (minimo: ' || min_stock_value::text || ')';
      ELSIF old_total_quantity < min_stock_value AND new_total_quantity < min_stock_value THEN
        -- Still below threshold, but check if it got worse
        IF new_total_quantity < old_total_quantity THEN
          should_notify := TRUE;
          stock_status_message := 'Scorta in calo: ' || new_total_quantity::text || ' disponibili (minimo: ' || min_stock_value::text || ')';
        END IF;
      END IF;
    END IF;

    -- Condition 2: Total quantity crossed above max_stock (was <= max, now > max)
    IF max_stock_value IS NOT NULL THEN
      IF old_total_quantity <= max_stock_value AND new_total_quantity > max_stock_value THEN
        should_notify := TRUE;
        IF stock_status_message != '' THEN
          stock_status_message := stock_status_message || ' - Scorta eccessiva: ' || new_total_quantity::text || ' disponibili (massimo: ' || max_stock_value::text || ')';
        ELSE
          stock_status_message := 'Scorta eccessiva: ' || new_total_quantity::text || ' disponibili (massimo: ' || max_stock_value::text || ')';
        END IF;
      ELSIF old_total_quantity > max_stock_value AND new_total_quantity > max_stock_value THEN
        -- Still above threshold, but check if it got worse
        IF new_total_quantity > old_total_quantity THEN
          should_notify := TRUE;
          IF stock_status_message != '' THEN
            stock_status_message := stock_status_message || ' - Scorta in aumento: ' || new_total_quantity::text || ' disponibili (massimo: ' || max_stock_value::text || ')';
          ELSE
            stock_status_message := 'Scorta in aumento: ' || new_total_quantity::text || ' disponibili (massimo: ' || max_stock_value::text || ')';
          END IF;
        END IF;
      END IF;
    END IF;

  -- Only proceed if we need to send notifications
  IF should_notify THEN
    -- Create notification name and description
    notification_name := 'Aggiornamento Inventario: ' || COALESCE(article_name, 'Articolo Sconosciuto');
    notification_description := 'Articolo "' || COALESCE(article_name, 'Articolo Sconosciuto') || 
                              '" - ' || stock_status_message;

    -- Insert notification for FABRIZIO
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
      NEW.updated_by,
      NEW.domain_id,
      NULL -- department_id - can be set later if needed
    );

    -- Insert notification for SERENA
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
      'c128077b-84a5-48b9-ac14-822477d62a87'::uuid, -- SERENA's UUID
      NEW.updated_by,
      NEW.domain_id,
      NULL -- department_id - can be set later if needed
    );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- Log the error without stopping the trigger execution
      -- RAISE WARNING logs to PostgreSQL server logs (viewable in database logs)
      -- This prevents the error from propagating and blocking the inventory update
      RAISE WARNING 'Error in inventory_quantity_notification_for_serena_fabrizio trigger for inventory_id: % - article_id: % - location_id: % - SQLSTATE: % - SQLERRM: %', 
        NEW.id, NEW.article_id, NEW.location_id, SQLSTATE, SQLERRM;
      -- Return NEW to allow the inventory update to proceed even if notification fails
      RETURN NEW;
  END;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION mod_wms.receipt_items_notification_for_serena()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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

CREATE OR REPLACE FUNCTION mod_wms.update_sales_order_items_has_shipment()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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

CREATE OR REPLACE FUNCTION public.check_user_sales_orders_access()
 RETURNS TABLE(user_id uuid, domain_id uuid, role text, jwt_domain_id text, jwt_role text, can_access_sales_orders boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.delete_claim(uid uuid, claim text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN 'error: access denied';
      ELSE        
        update auth.users set raw_app_meta_data = 
          raw_app_meta_data - claim where id = uid;
        return 'OK';
      END IF;
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

CREATE OR REPLACE FUNCTION public.get_active_departments()
 RETURNS TABLE(id uuid, name character varying)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN QUERY
  SELECT d.id, d.name::varchar
  FROM mod_base.departments d
  WHERE NOT d.is_deleted
  ORDER BY d.name;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_claim(uid uuid, claim text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
    DECLARE retval jsonb;
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN '{"error":"access denied"}'::jsonb;
      ELSE
        select coalesce(raw_app_meta_data->claim, null) from auth.users into retval where id = uid::uuid;
        return retval;
      END IF;
    END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_claims(uid uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
    DECLARE retval jsonb;
    BEGIN
      IF NOT is_claims_admin() THEN
          RETURN '{"error":"access denied"}'::jsonb;
      ELSE
        select raw_app_meta_data from auth.users into retval where id = uid::uuid;
        return retval;
      END IF;
    END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_employees_with_details()
 RETURNS TABLE(id uuid, name character varying, last_name character varying, description character varying, email character varying, phone character varying, department_names character varying[])
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_jwt_claim_domain_id()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN get_my_claim('domain_id');
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_my_claim(claim text)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  select 
  	coalesce(nullif(current_setting('request.jwt.claims', true), '')::jsonb -> 'app_metadata' -> claim, null)
$function$
;

CREATE OR REPLACE FUNCTION public.get_my_claim_text(claim text)
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
  SELECT 
    trim(both '\"' from coalesce(nullif(current_setting('request.jwt.claims', true), '')::jsonb -> 'app_metadata' -> claim, null)::text)
$function$
;

CREATE OR REPLACE FUNCTION public.get_my_claims()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  select 
  	coalesce(nullif(current_setting('request.jwt.claims', true), '')::jsonb -> 'app_metadata', '{}'::jsonb)::jsonb
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

CREATE OR REPLACE FUNCTION public.get_user_notifications(p_limit integer DEFAULT 50, p_offset integer DEFAULT 0, p_is_read boolean DEFAULT NULL::boolean)
 RETURNS TABLE(id uuid, name text, description text, code text, type text, is_read boolean, avatar_url text, barcode text, created_at timestamp with time zone, updated_at timestamp with time zone, created_by uuid, updated_by uuid, pulse_id uuid, total_count bigint)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_user_page_access(user_department_ids uuid[])
 RETURNS TABLE(page_id uuid, page_name text, page_path text, page_title text, is_restricted boolean, has_access boolean, is_visible boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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

CREATE OR REPLACE FUNCTION public.is_claims_admin()
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.mark_all_notifications_as_read()
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.mark_notification_as_read(p_notification_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.my_set_config(key text, value text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
  perform set_config(key, value, false);
end;
$function$
;

CREATE OR REPLACE FUNCTION public.safe_alter_enum_type(p_type_name text, p_new_values text[])
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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

CREATE OR REPLACE FUNCTION public.set_claim(uid uuid, claim text, value jsonb)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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

CREATE OR REPLACE FUNCTION public.update_expected_delivery_date()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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

grant delete on table "mod_admin"."domain_modules" to "anon";

grant insert on table "mod_admin"."domain_modules" to "anon";

grant references on table "mod_admin"."domain_modules" to "anon";

grant select on table "mod_admin"."domain_modules" to "anon";

grant trigger on table "mod_admin"."domain_modules" to "anon";

grant truncate on table "mod_admin"."domain_modules" to "anon";

grant update on table "mod_admin"."domain_modules" to "anon";

grant delete on table "mod_admin"."domain_modules" to "authenticated";

grant insert on table "mod_admin"."domain_modules" to "authenticated";

grant references on table "mod_admin"."domain_modules" to "authenticated";

grant select on table "mod_admin"."domain_modules" to "authenticated";

grant trigger on table "mod_admin"."domain_modules" to "authenticated";

grant truncate on table "mod_admin"."domain_modules" to "authenticated";

grant update on table "mod_admin"."domain_modules" to "authenticated";

grant delete on table "mod_admin"."domain_modules" to "service_role";

grant insert on table "mod_admin"."domain_modules" to "service_role";

grant references on table "mod_admin"."domain_modules" to "service_role";

grant select on table "mod_admin"."domain_modules" to "service_role";

grant trigger on table "mod_admin"."domain_modules" to "service_role";

grant truncate on table "mod_admin"."domain_modules" to "service_role";

grant update on table "mod_admin"."domain_modules" to "service_role";

grant delete on table "mod_admin"."domain_users" to "anon";

grant insert on table "mod_admin"."domain_users" to "anon";

grant references on table "mod_admin"."domain_users" to "anon";

grant select on table "mod_admin"."domain_users" to "anon";

grant trigger on table "mod_admin"."domain_users" to "anon";

grant truncate on table "mod_admin"."domain_users" to "anon";

grant update on table "mod_admin"."domain_users" to "anon";

grant delete on table "mod_admin"."domain_users" to "authenticated";

grant insert on table "mod_admin"."domain_users" to "authenticated";

grant references on table "mod_admin"."domain_users" to "authenticated";

grant select on table "mod_admin"."domain_users" to "authenticated";

grant trigger on table "mod_admin"."domain_users" to "authenticated";

grant truncate on table "mod_admin"."domain_users" to "authenticated";

grant update on table "mod_admin"."domain_users" to "authenticated";

grant delete on table "mod_admin"."domain_users" to "service_role";

grant insert on table "mod_admin"."domain_users" to "service_role";

grant references on table "mod_admin"."domain_users" to "service_role";

grant select on table "mod_admin"."domain_users" to "service_role";

grant trigger on table "mod_admin"."domain_users" to "service_role";

grant truncate on table "mod_admin"."domain_users" to "service_role";

grant update on table "mod_admin"."domain_users" to "service_role";

grant delete on table "mod_admin"."domains" to "anon";

grant insert on table "mod_admin"."domains" to "anon";

grant references on table "mod_admin"."domains" to "anon";

grant select on table "mod_admin"."domains" to "anon";

grant trigger on table "mod_admin"."domains" to "anon";

grant truncate on table "mod_admin"."domains" to "anon";

grant update on table "mod_admin"."domains" to "anon";

grant delete on table "mod_admin"."domains" to "authenticated";

grant insert on table "mod_admin"."domains" to "authenticated";

grant references on table "mod_admin"."domains" to "authenticated";

grant select on table "mod_admin"."domains" to "authenticated";

grant trigger on table "mod_admin"."domains" to "authenticated";

grant truncate on table "mod_admin"."domains" to "authenticated";

grant update on table "mod_admin"."domains" to "authenticated";

grant delete on table "mod_admin"."domains" to "service_role";

grant insert on table "mod_admin"."domains" to "service_role";

grant references on table "mod_admin"."domains" to "service_role";

grant select on table "mod_admin"."domains" to "service_role";

grant trigger on table "mod_admin"."domains" to "service_role";

grant truncate on table "mod_admin"."domains" to "service_role";

grant update on table "mod_admin"."domains" to "service_role";

grant delete on table "mod_admin"."user_profiles" to "anon";

grant insert on table "mod_admin"."user_profiles" to "anon";

grant references on table "mod_admin"."user_profiles" to "anon";

grant select on table "mod_admin"."user_profiles" to "anon";

grant trigger on table "mod_admin"."user_profiles" to "anon";

grant truncate on table "mod_admin"."user_profiles" to "anon";

grant update on table "mod_admin"."user_profiles" to "anon";

grant delete on table "mod_admin"."user_profiles" to "authenticated";

grant insert on table "mod_admin"."user_profiles" to "authenticated";

grant references on table "mod_admin"."user_profiles" to "authenticated";

grant select on table "mod_admin"."user_profiles" to "authenticated";

grant trigger on table "mod_admin"."user_profiles" to "authenticated";

grant truncate on table "mod_admin"."user_profiles" to "authenticated";

grant update on table "mod_admin"."user_profiles" to "authenticated";

grant delete on table "mod_admin"."user_profiles" to "service_role";

grant insert on table "mod_admin"."user_profiles" to "service_role";

grant references on table "mod_admin"."user_profiles" to "service_role";

grant select on table "mod_admin"."user_profiles" to "service_role";

grant trigger on table "mod_admin"."user_profiles" to "service_role";

grant truncate on table "mod_admin"."user_profiles" to "service_role";

grant update on table "mod_admin"."user_profiles" to "service_role";

grant delete on table "mod_base"."announcements" to "anon";

grant insert on table "mod_base"."announcements" to "anon";

grant references on table "mod_base"."announcements" to "anon";

grant select on table "mod_base"."announcements" to "anon";

grant trigger on table "mod_base"."announcements" to "anon";

grant truncate on table "mod_base"."announcements" to "anon";

grant update on table "mod_base"."announcements" to "anon";

grant delete on table "mod_base"."announcements" to "authenticated";

grant insert on table "mod_base"."announcements" to "authenticated";

grant references on table "mod_base"."announcements" to "authenticated";

grant select on table "mod_base"."announcements" to "authenticated";

grant trigger on table "mod_base"."announcements" to "authenticated";

grant truncate on table "mod_base"."announcements" to "authenticated";

grant update on table "mod_base"."announcements" to "authenticated";

grant delete on table "mod_base"."announcements" to "service_role";

grant insert on table "mod_base"."announcements" to "service_role";

grant references on table "mod_base"."announcements" to "service_role";

grant select on table "mod_base"."announcements" to "service_role";

grant trigger on table "mod_base"."announcements" to "service_role";

grant truncate on table "mod_base"."announcements" to "service_role";

grant update on table "mod_base"."announcements" to "service_role";

grant delete on table "mod_base"."article_categories" to "anon";

grant insert on table "mod_base"."article_categories" to "anon";

grant references on table "mod_base"."article_categories" to "anon";

grant select on table "mod_base"."article_categories" to "anon";

grant trigger on table "mod_base"."article_categories" to "anon";

grant truncate on table "mod_base"."article_categories" to "anon";

grant update on table "mod_base"."article_categories" to "anon";

grant delete on table "mod_base"."article_categories" to "authenticated";

grant insert on table "mod_base"."article_categories" to "authenticated";

grant references on table "mod_base"."article_categories" to "authenticated";

grant select on table "mod_base"."article_categories" to "authenticated";

grant trigger on table "mod_base"."article_categories" to "authenticated";

grant truncate on table "mod_base"."article_categories" to "authenticated";

grant update on table "mod_base"."article_categories" to "authenticated";

grant delete on table "mod_base"."article_categories" to "service_role";

grant insert on table "mod_base"."article_categories" to "service_role";

grant references on table "mod_base"."article_categories" to "service_role";

grant select on table "mod_base"."article_categories" to "service_role";

grant trigger on table "mod_base"."article_categories" to "service_role";

grant truncate on table "mod_base"."article_categories" to "service_role";

grant update on table "mod_base"."article_categories" to "service_role";

grant delete on table "mod_base"."articles" to "anon";

grant insert on table "mod_base"."articles" to "anon";

grant references on table "mod_base"."articles" to "anon";

grant select on table "mod_base"."articles" to "anon";

grant trigger on table "mod_base"."articles" to "anon";

grant truncate on table "mod_base"."articles" to "anon";

grant update on table "mod_base"."articles" to "anon";

grant delete on table "mod_base"."articles" to "authenticated";

grant insert on table "mod_base"."articles" to "authenticated";

grant references on table "mod_base"."articles" to "authenticated";

grant select on table "mod_base"."articles" to "authenticated";

grant trigger on table "mod_base"."articles" to "authenticated";

grant truncate on table "mod_base"."articles" to "authenticated";

grant update on table "mod_base"."articles" to "authenticated";

grant delete on table "mod_base"."articles" to "service_role";

grant insert on table "mod_base"."articles" to "service_role";

grant references on table "mod_base"."articles" to "service_role";

grant select on table "mod_base"."articles" to "service_role";

grant trigger on table "mod_base"."articles" to "service_role";

grant truncate on table "mod_base"."articles" to "service_role";

grant update on table "mod_base"."articles" to "service_role";

grant delete on table "mod_base"."bom_articles" to "anon";

grant insert on table "mod_base"."bom_articles" to "anon";

grant references on table "mod_base"."bom_articles" to "anon";

grant select on table "mod_base"."bom_articles" to "anon";

grant trigger on table "mod_base"."bom_articles" to "anon";

grant truncate on table "mod_base"."bom_articles" to "anon";

grant update on table "mod_base"."bom_articles" to "anon";

grant delete on table "mod_base"."bom_articles" to "authenticated";

grant insert on table "mod_base"."bom_articles" to "authenticated";

grant references on table "mod_base"."bom_articles" to "authenticated";

grant select on table "mod_base"."bom_articles" to "authenticated";

grant trigger on table "mod_base"."bom_articles" to "authenticated";

grant truncate on table "mod_base"."bom_articles" to "authenticated";

grant update on table "mod_base"."bom_articles" to "authenticated";

grant delete on table "mod_base"."bom_articles" to "service_role";

grant insert on table "mod_base"."bom_articles" to "service_role";

grant references on table "mod_base"."bom_articles" to "service_role";

grant select on table "mod_base"."bom_articles" to "service_role";

grant trigger on table "mod_base"."bom_articles" to "service_role";

grant truncate on table "mod_base"."bom_articles" to "service_role";

grant update on table "mod_base"."bom_articles" to "service_role";

grant delete on table "mod_base"."custom_article_attachments" to "anon";

grant insert on table "mod_base"."custom_article_attachments" to "anon";

grant references on table "mod_base"."custom_article_attachments" to "anon";

grant select on table "mod_base"."custom_article_attachments" to "anon";

grant trigger on table "mod_base"."custom_article_attachments" to "anon";

grant truncate on table "mod_base"."custom_article_attachments" to "anon";

grant update on table "mod_base"."custom_article_attachments" to "anon";

grant delete on table "mod_base"."custom_article_attachments" to "authenticated";

grant insert on table "mod_base"."custom_article_attachments" to "authenticated";

grant references on table "mod_base"."custom_article_attachments" to "authenticated";

grant select on table "mod_base"."custom_article_attachments" to "authenticated";

grant trigger on table "mod_base"."custom_article_attachments" to "authenticated";

grant truncate on table "mod_base"."custom_article_attachments" to "authenticated";

grant update on table "mod_base"."custom_article_attachments" to "authenticated";

grant delete on table "mod_base"."custom_article_attachments" to "service_role";

grant insert on table "mod_base"."custom_article_attachments" to "service_role";

grant references on table "mod_base"."custom_article_attachments" to "service_role";

grant select on table "mod_base"."custom_article_attachments" to "service_role";

grant trigger on table "mod_base"."custom_article_attachments" to "service_role";

grant truncate on table "mod_base"."custom_article_attachments" to "service_role";

grant update on table "mod_base"."custom_article_attachments" to "service_role";

grant delete on table "mod_base"."customer_addresses" to "anon";

grant insert on table "mod_base"."customer_addresses" to "anon";

grant references on table "mod_base"."customer_addresses" to "anon";

grant select on table "mod_base"."customer_addresses" to "anon";

grant trigger on table "mod_base"."customer_addresses" to "anon";

grant truncate on table "mod_base"."customer_addresses" to "anon";

grant update on table "mod_base"."customer_addresses" to "anon";

grant delete on table "mod_base"."customer_addresses" to "authenticated";

grant insert on table "mod_base"."customer_addresses" to "authenticated";

grant references on table "mod_base"."customer_addresses" to "authenticated";

grant select on table "mod_base"."customer_addresses" to "authenticated";

grant trigger on table "mod_base"."customer_addresses" to "authenticated";

grant truncate on table "mod_base"."customer_addresses" to "authenticated";

grant update on table "mod_base"."customer_addresses" to "authenticated";

grant delete on table "mod_base"."customer_addresses" to "service_role";

grant insert on table "mod_base"."customer_addresses" to "service_role";

grant references on table "mod_base"."customer_addresses" to "service_role";

grant select on table "mod_base"."customer_addresses" to "service_role";

grant trigger on table "mod_base"."customer_addresses" to "service_role";

grant truncate on table "mod_base"."customer_addresses" to "service_role";

grant update on table "mod_base"."customer_addresses" to "service_role";

grant delete on table "mod_base"."customers" to "anon";

grant insert on table "mod_base"."customers" to "anon";

grant references on table "mod_base"."customers" to "anon";

grant select on table "mod_base"."customers" to "anon";

grant trigger on table "mod_base"."customers" to "anon";

grant truncate on table "mod_base"."customers" to "anon";

grant update on table "mod_base"."customers" to "anon";

grant delete on table "mod_base"."customers" to "authenticated";

grant insert on table "mod_base"."customers" to "authenticated";

grant references on table "mod_base"."customers" to "authenticated";

grant select on table "mod_base"."customers" to "authenticated";

grant trigger on table "mod_base"."customers" to "authenticated";

grant truncate on table "mod_base"."customers" to "authenticated";

grant update on table "mod_base"."customers" to "authenticated";

grant delete on table "mod_base"."customers" to "service_role";

grant insert on table "mod_base"."customers" to "service_role";

grant references on table "mod_base"."customers" to "service_role";

grant select on table "mod_base"."customers" to "service_role";

grant trigger on table "mod_base"."customers" to "service_role";

grant truncate on table "mod_base"."customers" to "service_role";

grant update on table "mod_base"."customers" to "service_role";

grant delete on table "mod_base"."departments" to "anon";

grant insert on table "mod_base"."departments" to "anon";

grant references on table "mod_base"."departments" to "anon";

grant select on table "mod_base"."departments" to "anon";

grant trigger on table "mod_base"."departments" to "anon";

grant truncate on table "mod_base"."departments" to "anon";

grant update on table "mod_base"."departments" to "anon";

grant delete on table "mod_base"."departments" to "authenticated";

grant insert on table "mod_base"."departments" to "authenticated";

grant references on table "mod_base"."departments" to "authenticated";

grant select on table "mod_base"."departments" to "authenticated";

grant trigger on table "mod_base"."departments" to "authenticated";

grant truncate on table "mod_base"."departments" to "authenticated";

grant update on table "mod_base"."departments" to "authenticated";

grant delete on table "mod_base"."departments" to "service_role";

grant insert on table "mod_base"."departments" to "service_role";

grant references on table "mod_base"."departments" to "service_role";

grant select on table "mod_base"."departments" to "service_role";

grant trigger on table "mod_base"."departments" to "service_role";

grant truncate on table "mod_base"."departments" to "service_role";

grant update on table "mod_base"."departments" to "service_role";

grant delete on table "mod_base"."employees" to "anon";

grant insert on table "mod_base"."employees" to "anon";

grant references on table "mod_base"."employees" to "anon";

grant select on table "mod_base"."employees" to "anon";

grant trigger on table "mod_base"."employees" to "anon";

grant truncate on table "mod_base"."employees" to "anon";

grant update on table "mod_base"."employees" to "anon";

grant delete on table "mod_base"."employees" to "authenticated";

grant insert on table "mod_base"."employees" to "authenticated";

grant references on table "mod_base"."employees" to "authenticated";

grant select on table "mod_base"."employees" to "authenticated";

grant trigger on table "mod_base"."employees" to "authenticated";

grant truncate on table "mod_base"."employees" to "authenticated";

grant update on table "mod_base"."employees" to "authenticated";

grant delete on table "mod_base"."employees" to "service_role";

grant insert on table "mod_base"."employees" to "service_role";

grant references on table "mod_base"."employees" to "service_role";

grant select on table "mod_base"."employees" to "service_role";

grant trigger on table "mod_base"."employees" to "service_role";

grant truncate on table "mod_base"."employees" to "service_role";

grant update on table "mod_base"."employees" to "service_role";

grant delete on table "mod_base"."employees_departments" to "anon";

grant insert on table "mod_base"."employees_departments" to "anon";

grant references on table "mod_base"."employees_departments" to "anon";

grant select on table "mod_base"."employees_departments" to "anon";

grant trigger on table "mod_base"."employees_departments" to "anon";

grant truncate on table "mod_base"."employees_departments" to "anon";

grant update on table "mod_base"."employees_departments" to "anon";

grant delete on table "mod_base"."employees_departments" to "authenticated";

grant insert on table "mod_base"."employees_departments" to "authenticated";

grant references on table "mod_base"."employees_departments" to "authenticated";

grant select on table "mod_base"."employees_departments" to "authenticated";

grant trigger on table "mod_base"."employees_departments" to "authenticated";

grant truncate on table "mod_base"."employees_departments" to "authenticated";

grant update on table "mod_base"."employees_departments" to "authenticated";

grant delete on table "mod_base"."employees_departments" to "service_role";

grant insert on table "mod_base"."employees_departments" to "service_role";

grant references on table "mod_base"."employees_departments" to "service_role";

grant select on table "mod_base"."employees_departments" to "service_role";

grant trigger on table "mod_base"."employees_departments" to "service_role";

grant truncate on table "mod_base"."employees_departments" to "service_role";

grant update on table "mod_base"."employees_departments" to "service_role";

grant delete on table "mod_base"."internal_sales_order_items" to "anon";

grant insert on table "mod_base"."internal_sales_order_items" to "anon";

grant references on table "mod_base"."internal_sales_order_items" to "anon";

grant select on table "mod_base"."internal_sales_order_items" to "anon";

grant trigger on table "mod_base"."internal_sales_order_items" to "anon";

grant truncate on table "mod_base"."internal_sales_order_items" to "anon";

grant update on table "mod_base"."internal_sales_order_items" to "anon";

grant delete on table "mod_base"."internal_sales_order_items" to "authenticated";

grant insert on table "mod_base"."internal_sales_order_items" to "authenticated";

grant references on table "mod_base"."internal_sales_order_items" to "authenticated";

grant select on table "mod_base"."internal_sales_order_items" to "authenticated";

grant trigger on table "mod_base"."internal_sales_order_items" to "authenticated";

grant truncate on table "mod_base"."internal_sales_order_items" to "authenticated";

grant update on table "mod_base"."internal_sales_order_items" to "authenticated";

grant delete on table "mod_base"."internal_sales_order_items" to "service_role";

grant insert on table "mod_base"."internal_sales_order_items" to "service_role";

grant references on table "mod_base"."internal_sales_order_items" to "service_role";

grant select on table "mod_base"."internal_sales_order_items" to "service_role";

grant trigger on table "mod_base"."internal_sales_order_items" to "service_role";

grant truncate on table "mod_base"."internal_sales_order_items" to "service_role";

grant update on table "mod_base"."internal_sales_order_items" to "service_role";

grant delete on table "mod_base"."internal_sales_orders" to "anon";

grant insert on table "mod_base"."internal_sales_orders" to "anon";

grant references on table "mod_base"."internal_sales_orders" to "anon";

grant select on table "mod_base"."internal_sales_orders" to "anon";

grant trigger on table "mod_base"."internal_sales_orders" to "anon";

grant truncate on table "mod_base"."internal_sales_orders" to "anon";

grant update on table "mod_base"."internal_sales_orders" to "anon";

grant delete on table "mod_base"."internal_sales_orders" to "authenticated";

grant insert on table "mod_base"."internal_sales_orders" to "authenticated";

grant references on table "mod_base"."internal_sales_orders" to "authenticated";

grant select on table "mod_base"."internal_sales_orders" to "authenticated";

grant trigger on table "mod_base"."internal_sales_orders" to "authenticated";

grant truncate on table "mod_base"."internal_sales_orders" to "authenticated";

grant update on table "mod_base"."internal_sales_orders" to "authenticated";

grant delete on table "mod_base"."internal_sales_orders" to "service_role";

grant insert on table "mod_base"."internal_sales_orders" to "service_role";

grant references on table "mod_base"."internal_sales_orders" to "service_role";

grant select on table "mod_base"."internal_sales_orders" to "service_role";

grant trigger on table "mod_base"."internal_sales_orders" to "service_role";

grant truncate on table "mod_base"."internal_sales_orders" to "service_role";

grant update on table "mod_base"."internal_sales_orders" to "service_role";

grant delete on table "mod_base"."profiles" to "anon";

grant insert on table "mod_base"."profiles" to "anon";

grant references on table "mod_base"."profiles" to "anon";

grant select on table "mod_base"."profiles" to "anon";

grant trigger on table "mod_base"."profiles" to "anon";

grant truncate on table "mod_base"."profiles" to "anon";

grant update on table "mod_base"."profiles" to "anon";

grant delete on table "mod_base"."profiles" to "authenticated";

grant insert on table "mod_base"."profiles" to "authenticated";

grant references on table "mod_base"."profiles" to "authenticated";

grant select on table "mod_base"."profiles" to "authenticated";

grant trigger on table "mod_base"."profiles" to "authenticated";

grant truncate on table "mod_base"."profiles" to "authenticated";

grant update on table "mod_base"."profiles" to "authenticated";

grant delete on table "mod_base"."profiles" to "service_role";

grant insert on table "mod_base"."profiles" to "service_role";

grant references on table "mod_base"."profiles" to "service_role";

grant select on table "mod_base"."profiles" to "service_role";

grant trigger on table "mod_base"."profiles" to "service_role";

grant truncate on table "mod_base"."profiles" to "service_role";

grant update on table "mod_base"."profiles" to "service_role";

grant delete on table "mod_base"."purchase_order_items" to "anon";

grant insert on table "mod_base"."purchase_order_items" to "anon";

grant references on table "mod_base"."purchase_order_items" to "anon";

grant select on table "mod_base"."purchase_order_items" to "anon";

grant trigger on table "mod_base"."purchase_order_items" to "anon";

grant truncate on table "mod_base"."purchase_order_items" to "anon";

grant update on table "mod_base"."purchase_order_items" to "anon";

grant delete on table "mod_base"."purchase_order_items" to "authenticated";

grant insert on table "mod_base"."purchase_order_items" to "authenticated";

grant references on table "mod_base"."purchase_order_items" to "authenticated";

grant select on table "mod_base"."purchase_order_items" to "authenticated";

grant trigger on table "mod_base"."purchase_order_items" to "authenticated";

grant truncate on table "mod_base"."purchase_order_items" to "authenticated";

grant update on table "mod_base"."purchase_order_items" to "authenticated";

grant delete on table "mod_base"."purchase_order_items" to "service_role";

grant insert on table "mod_base"."purchase_order_items" to "service_role";

grant references on table "mod_base"."purchase_order_items" to "service_role";

grant select on table "mod_base"."purchase_order_items" to "service_role";

grant trigger on table "mod_base"."purchase_order_items" to "service_role";

grant truncate on table "mod_base"."purchase_order_items" to "service_role";

grant update on table "mod_base"."purchase_order_items" to "service_role";

grant delete on table "mod_base"."purchase_orders" to "anon";

grant insert on table "mod_base"."purchase_orders" to "anon";

grant references on table "mod_base"."purchase_orders" to "anon";

grant select on table "mod_base"."purchase_orders" to "anon";

grant trigger on table "mod_base"."purchase_orders" to "anon";

grant truncate on table "mod_base"."purchase_orders" to "anon";

grant update on table "mod_base"."purchase_orders" to "anon";

grant delete on table "mod_base"."purchase_orders" to "authenticated";

grant insert on table "mod_base"."purchase_orders" to "authenticated";

grant references on table "mod_base"."purchase_orders" to "authenticated";

grant select on table "mod_base"."purchase_orders" to "authenticated";

grant trigger on table "mod_base"."purchase_orders" to "authenticated";

grant truncate on table "mod_base"."purchase_orders" to "authenticated";

grant update on table "mod_base"."purchase_orders" to "authenticated";

grant delete on table "mod_base"."purchase_orders" to "service_role";

grant insert on table "mod_base"."purchase_orders" to "service_role";

grant references on table "mod_base"."purchase_orders" to "service_role";

grant select on table "mod_base"."purchase_orders" to "service_role";

grant trigger on table "mod_base"."purchase_orders" to "service_role";

grant truncate on table "mod_base"."purchase_orders" to "service_role";

grant update on table "mod_base"."purchase_orders" to "service_role";

grant delete on table "mod_base"."quality_control" to "anon";

grant insert on table "mod_base"."quality_control" to "anon";

grant references on table "mod_base"."quality_control" to "anon";

grant select on table "mod_base"."quality_control" to "anon";

grant trigger on table "mod_base"."quality_control" to "anon";

grant truncate on table "mod_base"."quality_control" to "anon";

grant update on table "mod_base"."quality_control" to "anon";

grant delete on table "mod_base"."quality_control" to "authenticated";

grant insert on table "mod_base"."quality_control" to "authenticated";

grant references on table "mod_base"."quality_control" to "authenticated";

grant select on table "mod_base"."quality_control" to "authenticated";

grant trigger on table "mod_base"."quality_control" to "authenticated";

grant truncate on table "mod_base"."quality_control" to "authenticated";

grant update on table "mod_base"."quality_control" to "authenticated";

grant delete on table "mod_base"."quality_control" to "service_role";

grant insert on table "mod_base"."quality_control" to "service_role";

grant references on table "mod_base"."quality_control" to "service_role";

grant select on table "mod_base"."quality_control" to "service_role";

grant trigger on table "mod_base"."quality_control" to "service_role";

grant truncate on table "mod_base"."quality_control" to "service_role";

grant update on table "mod_base"."quality_control" to "service_role";

grant delete on table "mod_base"."quality_control_attachments" to "anon";

grant insert on table "mod_base"."quality_control_attachments" to "anon";

grant references on table "mod_base"."quality_control_attachments" to "anon";

grant select on table "mod_base"."quality_control_attachments" to "anon";

grant trigger on table "mod_base"."quality_control_attachments" to "anon";

grant truncate on table "mod_base"."quality_control_attachments" to "anon";

grant update on table "mod_base"."quality_control_attachments" to "anon";

grant delete on table "mod_base"."quality_control_attachments" to "authenticated";

grant insert on table "mod_base"."quality_control_attachments" to "authenticated";

grant references on table "mod_base"."quality_control_attachments" to "authenticated";

grant select on table "mod_base"."quality_control_attachments" to "authenticated";

grant trigger on table "mod_base"."quality_control_attachments" to "authenticated";

grant truncate on table "mod_base"."quality_control_attachments" to "authenticated";

grant update on table "mod_base"."quality_control_attachments" to "authenticated";

grant delete on table "mod_base"."quality_control_attachments" to "service_role";

grant insert on table "mod_base"."quality_control_attachments" to "service_role";

grant references on table "mod_base"."quality_control_attachments" to "service_role";

grant select on table "mod_base"."quality_control_attachments" to "service_role";

grant trigger on table "mod_base"."quality_control_attachments" to "service_role";

grant truncate on table "mod_base"."quality_control_attachments" to "service_role";

grant update on table "mod_base"."quality_control_attachments" to "service_role";

grant delete on table "mod_base"."quality_control_checklist_results" to "anon";

grant insert on table "mod_base"."quality_control_checklist_results" to "anon";

grant references on table "mod_base"."quality_control_checklist_results" to "anon";

grant select on table "mod_base"."quality_control_checklist_results" to "anon";

grant trigger on table "mod_base"."quality_control_checklist_results" to "anon";

grant truncate on table "mod_base"."quality_control_checklist_results" to "anon";

grant update on table "mod_base"."quality_control_checklist_results" to "anon";

grant delete on table "mod_base"."quality_control_checklist_results" to "authenticated";

grant insert on table "mod_base"."quality_control_checklist_results" to "authenticated";

grant references on table "mod_base"."quality_control_checklist_results" to "authenticated";

grant select on table "mod_base"."quality_control_checklist_results" to "authenticated";

grant trigger on table "mod_base"."quality_control_checklist_results" to "authenticated";

grant truncate on table "mod_base"."quality_control_checklist_results" to "authenticated";

grant update on table "mod_base"."quality_control_checklist_results" to "authenticated";

grant delete on table "mod_base"."quality_control_checklist_results" to "service_role";

grant insert on table "mod_base"."quality_control_checklist_results" to "service_role";

grant references on table "mod_base"."quality_control_checklist_results" to "service_role";

grant select on table "mod_base"."quality_control_checklist_results" to "service_role";

grant trigger on table "mod_base"."quality_control_checklist_results" to "service_role";

grant truncate on table "mod_base"."quality_control_checklist_results" to "service_role";

grant update on table "mod_base"."quality_control_checklist_results" to "service_role";

grant delete on table "mod_base"."quality_control_types" to "anon";

grant insert on table "mod_base"."quality_control_types" to "anon";

grant references on table "mod_base"."quality_control_types" to "anon";

grant select on table "mod_base"."quality_control_types" to "anon";

grant trigger on table "mod_base"."quality_control_types" to "anon";

grant truncate on table "mod_base"."quality_control_types" to "anon";

grant update on table "mod_base"."quality_control_types" to "anon";

grant delete on table "mod_base"."quality_control_types" to "authenticated";

grant insert on table "mod_base"."quality_control_types" to "authenticated";

grant references on table "mod_base"."quality_control_types" to "authenticated";

grant select on table "mod_base"."quality_control_types" to "authenticated";

grant trigger on table "mod_base"."quality_control_types" to "authenticated";

grant truncate on table "mod_base"."quality_control_types" to "authenticated";

grant update on table "mod_base"."quality_control_types" to "authenticated";

grant delete on table "mod_base"."quality_control_types" to "service_role";

grant insert on table "mod_base"."quality_control_types" to "service_role";

grant references on table "mod_base"."quality_control_types" to "service_role";

grant select on table "mod_base"."quality_control_types" to "service_role";

grant trigger on table "mod_base"."quality_control_types" to "service_role";

grant truncate on table "mod_base"."quality_control_types" to "service_role";

grant update on table "mod_base"."quality_control_types" to "service_role";

grant delete on table "mod_base"."quality_control_types_duplicate" to "anon";

grant insert on table "mod_base"."quality_control_types_duplicate" to "anon";

grant references on table "mod_base"."quality_control_types_duplicate" to "anon";

grant select on table "mod_base"."quality_control_types_duplicate" to "anon";

grant trigger on table "mod_base"."quality_control_types_duplicate" to "anon";

grant truncate on table "mod_base"."quality_control_types_duplicate" to "anon";

grant update on table "mod_base"."quality_control_types_duplicate" to "anon";

grant delete on table "mod_base"."quality_control_types_duplicate" to "authenticated";

grant insert on table "mod_base"."quality_control_types_duplicate" to "authenticated";

grant references on table "mod_base"."quality_control_types_duplicate" to "authenticated";

grant select on table "mod_base"."quality_control_types_duplicate" to "authenticated";

grant trigger on table "mod_base"."quality_control_types_duplicate" to "authenticated";

grant truncate on table "mod_base"."quality_control_types_duplicate" to "authenticated";

grant update on table "mod_base"."quality_control_types_duplicate" to "authenticated";

grant delete on table "mod_base"."quality_control_types_duplicate" to "service_role";

grant insert on table "mod_base"."quality_control_types_duplicate" to "service_role";

grant references on table "mod_base"."quality_control_types_duplicate" to "service_role";

grant select on table "mod_base"."quality_control_types_duplicate" to "service_role";

grant trigger on table "mod_base"."quality_control_types_duplicate" to "service_role";

grant truncate on table "mod_base"."quality_control_types_duplicate" to "service_role";

grant update on table "mod_base"."quality_control_types_duplicate" to "service_role";

grant delete on table "mod_base"."report_template" to "anon";

grant insert on table "mod_base"."report_template" to "anon";

grant references on table "mod_base"."report_template" to "anon";

grant select on table "mod_base"."report_template" to "anon";

grant trigger on table "mod_base"."report_template" to "anon";

grant truncate on table "mod_base"."report_template" to "anon";

grant update on table "mod_base"."report_template" to "anon";

grant delete on table "mod_base"."report_template" to "authenticated";

grant insert on table "mod_base"."report_template" to "authenticated";

grant references on table "mod_base"."report_template" to "authenticated";

grant select on table "mod_base"."report_template" to "authenticated";

grant trigger on table "mod_base"."report_template" to "authenticated";

grant truncate on table "mod_base"."report_template" to "authenticated";

grant update on table "mod_base"."report_template" to "authenticated";

grant delete on table "mod_base"."report_template" to "service_role";

grant insert on table "mod_base"."report_template" to "service_role";

grant references on table "mod_base"."report_template" to "service_role";

grant select on table "mod_base"."report_template" to "service_role";

grant trigger on table "mod_base"."report_template" to "service_role";

grant truncate on table "mod_base"."report_template" to "service_role";

grant update on table "mod_base"."report_template" to "service_role";

grant delete on table "mod_base"."sales_order_items" to "anon";

grant insert on table "mod_base"."sales_order_items" to "anon";

grant references on table "mod_base"."sales_order_items" to "anon";

grant select on table "mod_base"."sales_order_items" to "anon";

grant trigger on table "mod_base"."sales_order_items" to "anon";

grant truncate on table "mod_base"."sales_order_items" to "anon";

grant update on table "mod_base"."sales_order_items" to "anon";

grant delete on table "mod_base"."sales_order_items" to "authenticated";

grant insert on table "mod_base"."sales_order_items" to "authenticated";

grant references on table "mod_base"."sales_order_items" to "authenticated";

grant select on table "mod_base"."sales_order_items" to "authenticated";

grant trigger on table "mod_base"."sales_order_items" to "authenticated";

grant truncate on table "mod_base"."sales_order_items" to "authenticated";

grant update on table "mod_base"."sales_order_items" to "authenticated";

grant delete on table "mod_base"."sales_order_items" to "service_role";

grant insert on table "mod_base"."sales_order_items" to "service_role";

grant references on table "mod_base"."sales_order_items" to "service_role";

grant select on table "mod_base"."sales_order_items" to "service_role";

grant trigger on table "mod_base"."sales_order_items" to "service_role";

grant truncate on table "mod_base"."sales_order_items" to "service_role";

grant update on table "mod_base"."sales_order_items" to "service_role";

grant delete on table "mod_base"."sales_orders" to "anon";

grant insert on table "mod_base"."sales_orders" to "anon";

grant references on table "mod_base"."sales_orders" to "anon";

grant select on table "mod_base"."sales_orders" to "anon";

grant trigger on table "mod_base"."sales_orders" to "anon";

grant truncate on table "mod_base"."sales_orders" to "anon";

grant update on table "mod_base"."sales_orders" to "anon";

grant delete on table "mod_base"."sales_orders" to "authenticated";

grant insert on table "mod_base"."sales_orders" to "authenticated";

grant references on table "mod_base"."sales_orders" to "authenticated";

grant select on table "mod_base"."sales_orders" to "authenticated";

grant trigger on table "mod_base"."sales_orders" to "authenticated";

grant truncate on table "mod_base"."sales_orders" to "authenticated";

grant update on table "mod_base"."sales_orders" to "authenticated";

grant delete on table "mod_base"."sales_orders" to "service_role";

grant insert on table "mod_base"."sales_orders" to "service_role";

grant references on table "mod_base"."sales_orders" to "service_role";

grant select on table "mod_base"."sales_orders" to "service_role";

grant trigger on table "mod_base"."sales_orders" to "service_role";

grant truncate on table "mod_base"."sales_orders" to "service_role";

grant update on table "mod_base"."sales_orders" to "service_role";

grant delete on table "mod_base"."serial_number_counters" to "anon";

grant insert on table "mod_base"."serial_number_counters" to "anon";

grant references on table "mod_base"."serial_number_counters" to "anon";

grant select on table "mod_base"."serial_number_counters" to "anon";

grant trigger on table "mod_base"."serial_number_counters" to "anon";

grant truncate on table "mod_base"."serial_number_counters" to "anon";

grant update on table "mod_base"."serial_number_counters" to "anon";

grant delete on table "mod_base"."serial_number_counters" to "authenticated";

grant insert on table "mod_base"."serial_number_counters" to "authenticated";

grant references on table "mod_base"."serial_number_counters" to "authenticated";

grant select on table "mod_base"."serial_number_counters" to "authenticated";

grant trigger on table "mod_base"."serial_number_counters" to "authenticated";

grant truncate on table "mod_base"."serial_number_counters" to "authenticated";

grant update on table "mod_base"."serial_number_counters" to "authenticated";

grant delete on table "mod_base"."serial_number_counters" to "service_role";

grant insert on table "mod_base"."serial_number_counters" to "service_role";

grant references on table "mod_base"."serial_number_counters" to "service_role";

grant select on table "mod_base"."serial_number_counters" to "service_role";

grant trigger on table "mod_base"."serial_number_counters" to "service_role";

grant truncate on table "mod_base"."serial_number_counters" to "service_role";

grant update on table "mod_base"."serial_number_counters" to "service_role";

grant delete on table "mod_base"."suppliers" to "anon";

grant insert on table "mod_base"."suppliers" to "anon";

grant references on table "mod_base"."suppliers" to "anon";

grant select on table "mod_base"."suppliers" to "anon";

grant trigger on table "mod_base"."suppliers" to "anon";

grant truncate on table "mod_base"."suppliers" to "anon";

grant update on table "mod_base"."suppliers" to "anon";

grant delete on table "mod_base"."suppliers" to "authenticated";

grant insert on table "mod_base"."suppliers" to "authenticated";

grant references on table "mod_base"."suppliers" to "authenticated";

grant select on table "mod_base"."suppliers" to "authenticated";

grant trigger on table "mod_base"."suppliers" to "authenticated";

grant truncate on table "mod_base"."suppliers" to "authenticated";

grant update on table "mod_base"."suppliers" to "authenticated";

grant delete on table "mod_base"."suppliers" to "service_role";

grant insert on table "mod_base"."suppliers" to "service_role";

grant references on table "mod_base"."suppliers" to "service_role";

grant select on table "mod_base"."suppliers" to "service_role";

grant trigger on table "mod_base"."suppliers" to "service_role";

grant truncate on table "mod_base"."suppliers" to "service_role";

grant update on table "mod_base"."suppliers" to "service_role";

grant delete on table "mod_base"."units_of_measure" to "anon";

grant insert on table "mod_base"."units_of_measure" to "anon";

grant references on table "mod_base"."units_of_measure" to "anon";

grant select on table "mod_base"."units_of_measure" to "anon";

grant trigger on table "mod_base"."units_of_measure" to "anon";

grant truncate on table "mod_base"."units_of_measure" to "anon";

grant update on table "mod_base"."units_of_measure" to "anon";

grant delete on table "mod_base"."units_of_measure" to "authenticated";

grant insert on table "mod_base"."units_of_measure" to "authenticated";

grant references on table "mod_base"."units_of_measure" to "authenticated";

grant select on table "mod_base"."units_of_measure" to "authenticated";

grant trigger on table "mod_base"."units_of_measure" to "authenticated";

grant truncate on table "mod_base"."units_of_measure" to "authenticated";

grant update on table "mod_base"."units_of_measure" to "authenticated";

grant delete on table "mod_base"."units_of_measure" to "service_role";

grant insert on table "mod_base"."units_of_measure" to "service_role";

grant references on table "mod_base"."units_of_measure" to "service_role";

grant select on table "mod_base"."units_of_measure" to "service_role";

grant trigger on table "mod_base"."units_of_measure" to "service_role";

grant truncate on table "mod_base"."units_of_measure" to "service_role";

grant update on table "mod_base"."units_of_measure" to "service_role";

grant delete on table "mod_datalayer"."fields" to "anon";

grant insert on table "mod_datalayer"."fields" to "anon";

grant references on table "mod_datalayer"."fields" to "anon";

grant select on table "mod_datalayer"."fields" to "anon";

grant trigger on table "mod_datalayer"."fields" to "anon";

grant truncate on table "mod_datalayer"."fields" to "anon";

grant update on table "mod_datalayer"."fields" to "anon";

grant delete on table "mod_datalayer"."fields" to "authenticated";

grant insert on table "mod_datalayer"."fields" to "authenticated";

grant references on table "mod_datalayer"."fields" to "authenticated";

grant select on table "mod_datalayer"."fields" to "authenticated";

grant trigger on table "mod_datalayer"."fields" to "authenticated";

grant truncate on table "mod_datalayer"."fields" to "authenticated";

grant update on table "mod_datalayer"."fields" to "authenticated";

grant delete on table "mod_datalayer"."fields" to "service_role";

grant insert on table "mod_datalayer"."fields" to "service_role";

grant references on table "mod_datalayer"."fields" to "service_role";

grant select on table "mod_datalayer"."fields" to "service_role";

grant trigger on table "mod_datalayer"."fields" to "service_role";

grant truncate on table "mod_datalayer"."fields" to "service_role";

grant update on table "mod_datalayer"."fields" to "service_role";

grant delete on table "mod_datalayer"."main_menu" to "anon";

grant insert on table "mod_datalayer"."main_menu" to "anon";

grant references on table "mod_datalayer"."main_menu" to "anon";

grant select on table "mod_datalayer"."main_menu" to "anon";

grant trigger on table "mod_datalayer"."main_menu" to "anon";

grant truncate on table "mod_datalayer"."main_menu" to "anon";

grant update on table "mod_datalayer"."main_menu" to "anon";

grant delete on table "mod_datalayer"."main_menu" to "authenticated";

grant insert on table "mod_datalayer"."main_menu" to "authenticated";

grant references on table "mod_datalayer"."main_menu" to "authenticated";

grant select on table "mod_datalayer"."main_menu" to "authenticated";

grant trigger on table "mod_datalayer"."main_menu" to "authenticated";

grant truncate on table "mod_datalayer"."main_menu" to "authenticated";

grant update on table "mod_datalayer"."main_menu" to "authenticated";

grant delete on table "mod_datalayer"."main_menu" to "service_role";

grant insert on table "mod_datalayer"."main_menu" to "service_role";

grant references on table "mod_datalayer"."main_menu" to "service_role";

grant select on table "mod_datalayer"."main_menu" to "service_role";

grant trigger on table "mod_datalayer"."main_menu" to "service_role";

grant truncate on table "mod_datalayer"."main_menu" to "service_role";

grant update on table "mod_datalayer"."main_menu" to "service_role";

grant delete on table "mod_datalayer"."modules" to "anon";

grant insert on table "mod_datalayer"."modules" to "anon";

grant references on table "mod_datalayer"."modules" to "anon";

grant select on table "mod_datalayer"."modules" to "anon";

grant trigger on table "mod_datalayer"."modules" to "anon";

grant truncate on table "mod_datalayer"."modules" to "anon";

grant update on table "mod_datalayer"."modules" to "anon";

grant delete on table "mod_datalayer"."modules" to "authenticated";

grant insert on table "mod_datalayer"."modules" to "authenticated";

grant references on table "mod_datalayer"."modules" to "authenticated";

grant select on table "mod_datalayer"."modules" to "authenticated";

grant trigger on table "mod_datalayer"."modules" to "authenticated";

grant truncate on table "mod_datalayer"."modules" to "authenticated";

grant update on table "mod_datalayer"."modules" to "authenticated";

grant delete on table "mod_datalayer"."modules" to "service_role";

grant insert on table "mod_datalayer"."modules" to "service_role";

grant references on table "mod_datalayer"."modules" to "service_role";

grant select on table "mod_datalayer"."modules" to "service_role";

grant trigger on table "mod_datalayer"."modules" to "service_role";

grant truncate on table "mod_datalayer"."modules" to "service_role";

grant update on table "mod_datalayer"."modules" to "service_role";

grant delete on table "mod_datalayer"."page_categories" to "anon";

grant insert on table "mod_datalayer"."page_categories" to "anon";

grant references on table "mod_datalayer"."page_categories" to "anon";

grant select on table "mod_datalayer"."page_categories" to "anon";

grant trigger on table "mod_datalayer"."page_categories" to "anon";

grant truncate on table "mod_datalayer"."page_categories" to "anon";

grant update on table "mod_datalayer"."page_categories" to "anon";

grant delete on table "mod_datalayer"."page_categories" to "authenticated";

grant insert on table "mod_datalayer"."page_categories" to "authenticated";

grant references on table "mod_datalayer"."page_categories" to "authenticated";

grant select on table "mod_datalayer"."page_categories" to "authenticated";

grant trigger on table "mod_datalayer"."page_categories" to "authenticated";

grant truncate on table "mod_datalayer"."page_categories" to "authenticated";

grant update on table "mod_datalayer"."page_categories" to "authenticated";

grant delete on table "mod_datalayer"."page_categories" to "service_role";

grant insert on table "mod_datalayer"."page_categories" to "service_role";

grant references on table "mod_datalayer"."page_categories" to "service_role";

grant select on table "mod_datalayer"."page_categories" to "service_role";

grant trigger on table "mod_datalayer"."page_categories" to "service_role";

grant truncate on table "mod_datalayer"."page_categories" to "service_role";

grant update on table "mod_datalayer"."page_categories" to "service_role";

grant delete on table "mod_datalayer"."pages" to "anon";

grant insert on table "mod_datalayer"."pages" to "anon";

grant references on table "mod_datalayer"."pages" to "anon";

grant select on table "mod_datalayer"."pages" to "anon";

grant trigger on table "mod_datalayer"."pages" to "anon";

grant truncate on table "mod_datalayer"."pages" to "anon";

grant update on table "mod_datalayer"."pages" to "anon";

grant delete on table "mod_datalayer"."pages" to "authenticated";

grant insert on table "mod_datalayer"."pages" to "authenticated";

grant references on table "mod_datalayer"."pages" to "authenticated";

grant select on table "mod_datalayer"."pages" to "authenticated";

grant trigger on table "mod_datalayer"."pages" to "authenticated";

grant truncate on table "mod_datalayer"."pages" to "authenticated";

grant update on table "mod_datalayer"."pages" to "authenticated";

grant delete on table "mod_datalayer"."pages" to "service_role";

grant insert on table "mod_datalayer"."pages" to "service_role";

grant references on table "mod_datalayer"."pages" to "service_role";

grant select on table "mod_datalayer"."pages" to "service_role";

grant trigger on table "mod_datalayer"."pages" to "service_role";

grant truncate on table "mod_datalayer"."pages" to "service_role";

grant update on table "mod_datalayer"."pages" to "service_role";

grant delete on table "mod_datalayer"."pages_departments" to "anon";

grant insert on table "mod_datalayer"."pages_departments" to "anon";

grant references on table "mod_datalayer"."pages_departments" to "anon";

grant select on table "mod_datalayer"."pages_departments" to "anon";

grant trigger on table "mod_datalayer"."pages_departments" to "anon";

grant truncate on table "mod_datalayer"."pages_departments" to "anon";

grant update on table "mod_datalayer"."pages_departments" to "anon";

grant delete on table "mod_datalayer"."pages_departments" to "authenticated";

grant insert on table "mod_datalayer"."pages_departments" to "authenticated";

grant references on table "mod_datalayer"."pages_departments" to "authenticated";

grant select on table "mod_datalayer"."pages_departments" to "authenticated";

grant trigger on table "mod_datalayer"."pages_departments" to "authenticated";

grant truncate on table "mod_datalayer"."pages_departments" to "authenticated";

grant update on table "mod_datalayer"."pages_departments" to "authenticated";

grant delete on table "mod_datalayer"."pages_departments" to "service_role";

grant insert on table "mod_datalayer"."pages_departments" to "service_role";

grant references on table "mod_datalayer"."pages_departments" to "service_role";

grant select on table "mod_datalayer"."pages_departments" to "service_role";

grant trigger on table "mod_datalayer"."pages_departments" to "service_role";

grant truncate on table "mod_datalayer"."pages_departments" to "service_role";

grant update on table "mod_datalayer"."pages_departments" to "service_role";

grant delete on table "mod_datalayer"."pages_menu_departments" to "anon";

grant insert on table "mod_datalayer"."pages_menu_departments" to "anon";

grant references on table "mod_datalayer"."pages_menu_departments" to "anon";

grant select on table "mod_datalayer"."pages_menu_departments" to "anon";

grant trigger on table "mod_datalayer"."pages_menu_departments" to "anon";

grant truncate on table "mod_datalayer"."pages_menu_departments" to "anon";

grant update on table "mod_datalayer"."pages_menu_departments" to "anon";

grant delete on table "mod_datalayer"."pages_menu_departments" to "authenticated";

grant insert on table "mod_datalayer"."pages_menu_departments" to "authenticated";

grant references on table "mod_datalayer"."pages_menu_departments" to "authenticated";

grant select on table "mod_datalayer"."pages_menu_departments" to "authenticated";

grant trigger on table "mod_datalayer"."pages_menu_departments" to "authenticated";

grant truncate on table "mod_datalayer"."pages_menu_departments" to "authenticated";

grant update on table "mod_datalayer"."pages_menu_departments" to "authenticated";

grant delete on table "mod_datalayer"."pages_menu_departments" to "service_role";

grant insert on table "mod_datalayer"."pages_menu_departments" to "service_role";

grant references on table "mod_datalayer"."pages_menu_departments" to "service_role";

grant select on table "mod_datalayer"."pages_menu_departments" to "service_role";

grant trigger on table "mod_datalayer"."pages_menu_departments" to "service_role";

grant truncate on table "mod_datalayer"."pages_menu_departments" to "service_role";

grant update on table "mod_datalayer"."pages_menu_departments" to "service_role";

grant delete on table "mod_datalayer"."tables" to "anon";

grant insert on table "mod_datalayer"."tables" to "anon";

grant references on table "mod_datalayer"."tables" to "anon";

grant select on table "mod_datalayer"."tables" to "anon";

grant trigger on table "mod_datalayer"."tables" to "anon";

grant truncate on table "mod_datalayer"."tables" to "anon";

grant update on table "mod_datalayer"."tables" to "anon";

grant delete on table "mod_datalayer"."tables" to "authenticated";

grant insert on table "mod_datalayer"."tables" to "authenticated";

grant references on table "mod_datalayer"."tables" to "authenticated";

grant select on table "mod_datalayer"."tables" to "authenticated";

grant trigger on table "mod_datalayer"."tables" to "authenticated";

grant truncate on table "mod_datalayer"."tables" to "authenticated";

grant update on table "mod_datalayer"."tables" to "authenticated";

grant delete on table "mod_datalayer"."tables" to "service_role";

grant insert on table "mod_datalayer"."tables" to "service_role";

grant references on table "mod_datalayer"."tables" to "service_role";

grant select on table "mod_datalayer"."tables" to "service_role";

grant trigger on table "mod_datalayer"."tables" to "service_role";

grant truncate on table "mod_datalayer"."tables" to "service_role";

grant update on table "mod_datalayer"."tables" to "service_role";

grant delete on table "mod_manufacturing"."coil_consumption" to "anon";

grant insert on table "mod_manufacturing"."coil_consumption" to "anon";

grant references on table "mod_manufacturing"."coil_consumption" to "anon";

grant select on table "mod_manufacturing"."coil_consumption" to "anon";

grant trigger on table "mod_manufacturing"."coil_consumption" to "anon";

grant truncate on table "mod_manufacturing"."coil_consumption" to "anon";

grant update on table "mod_manufacturing"."coil_consumption" to "anon";

grant delete on table "mod_manufacturing"."coil_consumption" to "authenticated";

grant insert on table "mod_manufacturing"."coil_consumption" to "authenticated";

grant references on table "mod_manufacturing"."coil_consumption" to "authenticated";

grant select on table "mod_manufacturing"."coil_consumption" to "authenticated";

grant trigger on table "mod_manufacturing"."coil_consumption" to "authenticated";

grant truncate on table "mod_manufacturing"."coil_consumption" to "authenticated";

grant update on table "mod_manufacturing"."coil_consumption" to "authenticated";

grant delete on table "mod_manufacturing"."coil_consumption" to "service_role";

grant insert on table "mod_manufacturing"."coil_consumption" to "service_role";

grant references on table "mod_manufacturing"."coil_consumption" to "service_role";

grant select on table "mod_manufacturing"."coil_consumption" to "service_role";

grant trigger on table "mod_manufacturing"."coil_consumption" to "service_role";

grant truncate on table "mod_manufacturing"."coil_consumption" to "service_role";

grant update on table "mod_manufacturing"."coil_consumption" to "service_role";

grant delete on table "mod_manufacturing"."coil_production_plans" to "anon";

grant insert on table "mod_manufacturing"."coil_production_plans" to "anon";

grant references on table "mod_manufacturing"."coil_production_plans" to "anon";

grant select on table "mod_manufacturing"."coil_production_plans" to "anon";

grant trigger on table "mod_manufacturing"."coil_production_plans" to "anon";

grant truncate on table "mod_manufacturing"."coil_production_plans" to "anon";

grant update on table "mod_manufacturing"."coil_production_plans" to "anon";

grant delete on table "mod_manufacturing"."coil_production_plans" to "authenticated";

grant insert on table "mod_manufacturing"."coil_production_plans" to "authenticated";

grant references on table "mod_manufacturing"."coil_production_plans" to "authenticated";

grant select on table "mod_manufacturing"."coil_production_plans" to "authenticated";

grant trigger on table "mod_manufacturing"."coil_production_plans" to "authenticated";

grant truncate on table "mod_manufacturing"."coil_production_plans" to "authenticated";

grant update on table "mod_manufacturing"."coil_production_plans" to "authenticated";

grant delete on table "mod_manufacturing"."coil_production_plans" to "service_role";

grant insert on table "mod_manufacturing"."coil_production_plans" to "service_role";

grant references on table "mod_manufacturing"."coil_production_plans" to "service_role";

grant select on table "mod_manufacturing"."coil_production_plans" to "service_role";

grant trigger on table "mod_manufacturing"."coil_production_plans" to "service_role";

grant truncate on table "mod_manufacturing"."coil_production_plans" to "service_role";

grant update on table "mod_manufacturing"."coil_production_plans" to "service_role";

grant delete on table "mod_manufacturing"."coils" to "anon";

grant insert on table "mod_manufacturing"."coils" to "anon";

grant references on table "mod_manufacturing"."coils" to "anon";

grant select on table "mod_manufacturing"."coils" to "anon";

grant trigger on table "mod_manufacturing"."coils" to "anon";

grant truncate on table "mod_manufacturing"."coils" to "anon";

grant update on table "mod_manufacturing"."coils" to "anon";

grant delete on table "mod_manufacturing"."coils" to "authenticated";

grant insert on table "mod_manufacturing"."coils" to "authenticated";

grant references on table "mod_manufacturing"."coils" to "authenticated";

grant select on table "mod_manufacturing"."coils" to "authenticated";

grant trigger on table "mod_manufacturing"."coils" to "authenticated";

grant truncate on table "mod_manufacturing"."coils" to "authenticated";

grant update on table "mod_manufacturing"."coils" to "authenticated";

grant delete on table "mod_manufacturing"."coils" to "service_role";

grant insert on table "mod_manufacturing"."coils" to "service_role";

grant references on table "mod_manufacturing"."coils" to "service_role";

grant select on table "mod_manufacturing"."coils" to "service_role";

grant trigger on table "mod_manufacturing"."coils" to "service_role";

grant truncate on table "mod_manufacturing"."coils" to "service_role";

grant update on table "mod_manufacturing"."coils" to "service_role";

grant delete on table "mod_manufacturing"."departments" to "anon";

grant insert on table "mod_manufacturing"."departments" to "anon";

grant references on table "mod_manufacturing"."departments" to "anon";

grant select on table "mod_manufacturing"."departments" to "anon";

grant trigger on table "mod_manufacturing"."departments" to "anon";

grant truncate on table "mod_manufacturing"."departments" to "anon";

grant update on table "mod_manufacturing"."departments" to "anon";

grant delete on table "mod_manufacturing"."departments" to "authenticated";

grant insert on table "mod_manufacturing"."departments" to "authenticated";

grant references on table "mod_manufacturing"."departments" to "authenticated";

grant select on table "mod_manufacturing"."departments" to "authenticated";

grant trigger on table "mod_manufacturing"."departments" to "authenticated";

grant truncate on table "mod_manufacturing"."departments" to "authenticated";

grant update on table "mod_manufacturing"."departments" to "authenticated";

grant delete on table "mod_manufacturing"."departments" to "service_role";

grant insert on table "mod_manufacturing"."departments" to "service_role";

grant references on table "mod_manufacturing"."departments" to "service_role";

grant select on table "mod_manufacturing"."departments" to "service_role";

grant trigger on table "mod_manufacturing"."departments" to "service_role";

grant truncate on table "mod_manufacturing"."departments" to "service_role";

grant update on table "mod_manufacturing"."departments" to "service_role";

grant delete on table "mod_manufacturing"."locations" to "anon";

grant insert on table "mod_manufacturing"."locations" to "anon";

grant references on table "mod_manufacturing"."locations" to "anon";

grant select on table "mod_manufacturing"."locations" to "anon";

grant trigger on table "mod_manufacturing"."locations" to "anon";

grant truncate on table "mod_manufacturing"."locations" to "anon";

grant update on table "mod_manufacturing"."locations" to "anon";

grant delete on table "mod_manufacturing"."locations" to "authenticated";

grant insert on table "mod_manufacturing"."locations" to "authenticated";

grant references on table "mod_manufacturing"."locations" to "authenticated";

grant select on table "mod_manufacturing"."locations" to "authenticated";

grant trigger on table "mod_manufacturing"."locations" to "authenticated";

grant truncate on table "mod_manufacturing"."locations" to "authenticated";

grant update on table "mod_manufacturing"."locations" to "authenticated";

grant delete on table "mod_manufacturing"."locations" to "service_role";

grant insert on table "mod_manufacturing"."locations" to "service_role";

grant references on table "mod_manufacturing"."locations" to "service_role";

grant select on table "mod_manufacturing"."locations" to "service_role";

grant trigger on table "mod_manufacturing"."locations" to "service_role";

grant truncate on table "mod_manufacturing"."locations" to "service_role";

grant update on table "mod_manufacturing"."locations" to "service_role";

grant delete on table "mod_manufacturing"."plate_templates" to "anon";

grant insert on table "mod_manufacturing"."plate_templates" to "anon";

grant references on table "mod_manufacturing"."plate_templates" to "anon";

grant select on table "mod_manufacturing"."plate_templates" to "anon";

grant trigger on table "mod_manufacturing"."plate_templates" to "anon";

grant truncate on table "mod_manufacturing"."plate_templates" to "anon";

grant update on table "mod_manufacturing"."plate_templates" to "anon";

grant delete on table "mod_manufacturing"."plate_templates" to "authenticated";

grant insert on table "mod_manufacturing"."plate_templates" to "authenticated";

grant references on table "mod_manufacturing"."plate_templates" to "authenticated";

grant select on table "mod_manufacturing"."plate_templates" to "authenticated";

grant trigger on table "mod_manufacturing"."plate_templates" to "authenticated";

grant truncate on table "mod_manufacturing"."plate_templates" to "authenticated";

grant update on table "mod_manufacturing"."plate_templates" to "authenticated";

grant delete on table "mod_manufacturing"."plate_templates" to "service_role";

grant insert on table "mod_manufacturing"."plate_templates" to "service_role";

grant references on table "mod_manufacturing"."plate_templates" to "service_role";

grant select on table "mod_manufacturing"."plate_templates" to "service_role";

grant trigger on table "mod_manufacturing"."plate_templates" to "service_role";

grant truncate on table "mod_manufacturing"."plate_templates" to "service_role";

grant update on table "mod_manufacturing"."plate_templates" to "service_role";

grant delete on table "mod_manufacturing"."production_logs" to "anon";

grant insert on table "mod_manufacturing"."production_logs" to "anon";

grant references on table "mod_manufacturing"."production_logs" to "anon";

grant select on table "mod_manufacturing"."production_logs" to "anon";

grant trigger on table "mod_manufacturing"."production_logs" to "anon";

grant truncate on table "mod_manufacturing"."production_logs" to "anon";

grant update on table "mod_manufacturing"."production_logs" to "anon";

grant delete on table "mod_manufacturing"."production_logs" to "authenticated";

grant insert on table "mod_manufacturing"."production_logs" to "authenticated";

grant references on table "mod_manufacturing"."production_logs" to "authenticated";

grant select on table "mod_manufacturing"."production_logs" to "authenticated";

grant trigger on table "mod_manufacturing"."production_logs" to "authenticated";

grant truncate on table "mod_manufacturing"."production_logs" to "authenticated";

grant update on table "mod_manufacturing"."production_logs" to "authenticated";

grant delete on table "mod_manufacturing"."production_logs" to "service_role";

grant insert on table "mod_manufacturing"."production_logs" to "service_role";

grant references on table "mod_manufacturing"."production_logs" to "service_role";

grant select on table "mod_manufacturing"."production_logs" to "service_role";

grant trigger on table "mod_manufacturing"."production_logs" to "service_role";

grant truncate on table "mod_manufacturing"."production_logs" to "service_role";

grant update on table "mod_manufacturing"."production_logs" to "service_role";

grant delete on table "mod_manufacturing"."recipes" to "anon";

grant insert on table "mod_manufacturing"."recipes" to "anon";

grant references on table "mod_manufacturing"."recipes" to "anon";

grant select on table "mod_manufacturing"."recipes" to "anon";

grant trigger on table "mod_manufacturing"."recipes" to "anon";

grant truncate on table "mod_manufacturing"."recipes" to "anon";

grant update on table "mod_manufacturing"."recipes" to "anon";

grant delete on table "mod_manufacturing"."recipes" to "authenticated";

grant insert on table "mod_manufacturing"."recipes" to "authenticated";

grant references on table "mod_manufacturing"."recipes" to "authenticated";

grant select on table "mod_manufacturing"."recipes" to "authenticated";

grant trigger on table "mod_manufacturing"."recipes" to "authenticated";

grant truncate on table "mod_manufacturing"."recipes" to "authenticated";

grant update on table "mod_manufacturing"."recipes" to "authenticated";

grant delete on table "mod_manufacturing"."recipes" to "service_role";

grant insert on table "mod_manufacturing"."recipes" to "service_role";

grant references on table "mod_manufacturing"."recipes" to "service_role";

grant select on table "mod_manufacturing"."recipes" to "service_role";

grant trigger on table "mod_manufacturing"."recipes" to "service_role";

grant truncate on table "mod_manufacturing"."recipes" to "service_role";

grant update on table "mod_manufacturing"."recipes" to "service_role";

grant delete on table "mod_manufacturing"."scheduled_items" to "anon";

grant insert on table "mod_manufacturing"."scheduled_items" to "anon";

grant references on table "mod_manufacturing"."scheduled_items" to "anon";

grant select on table "mod_manufacturing"."scheduled_items" to "anon";

grant trigger on table "mod_manufacturing"."scheduled_items" to "anon";

grant truncate on table "mod_manufacturing"."scheduled_items" to "anon";

grant update on table "mod_manufacturing"."scheduled_items" to "anon";

grant delete on table "mod_manufacturing"."scheduled_items" to "authenticated";

grant insert on table "mod_manufacturing"."scheduled_items" to "authenticated";

grant references on table "mod_manufacturing"."scheduled_items" to "authenticated";

grant select on table "mod_manufacturing"."scheduled_items" to "authenticated";

grant trigger on table "mod_manufacturing"."scheduled_items" to "authenticated";

grant truncate on table "mod_manufacturing"."scheduled_items" to "authenticated";

grant update on table "mod_manufacturing"."scheduled_items" to "authenticated";

grant delete on table "mod_manufacturing"."scheduled_items" to "service_role";

grant insert on table "mod_manufacturing"."scheduled_items" to "service_role";

grant references on table "mod_manufacturing"."scheduled_items" to "service_role";

grant select on table "mod_manufacturing"."scheduled_items" to "service_role";

grant trigger on table "mod_manufacturing"."scheduled_items" to "service_role";

grant truncate on table "mod_manufacturing"."scheduled_items" to "service_role";

grant update on table "mod_manufacturing"."scheduled_items" to "service_role";

grant delete on table "mod_manufacturing"."work_cycle_categories" to "anon";

grant insert on table "mod_manufacturing"."work_cycle_categories" to "anon";

grant references on table "mod_manufacturing"."work_cycle_categories" to "anon";

grant select on table "mod_manufacturing"."work_cycle_categories" to "anon";

grant trigger on table "mod_manufacturing"."work_cycle_categories" to "anon";

grant truncate on table "mod_manufacturing"."work_cycle_categories" to "anon";

grant update on table "mod_manufacturing"."work_cycle_categories" to "anon";

grant delete on table "mod_manufacturing"."work_cycle_categories" to "authenticated";

grant insert on table "mod_manufacturing"."work_cycle_categories" to "authenticated";

grant references on table "mod_manufacturing"."work_cycle_categories" to "authenticated";

grant select on table "mod_manufacturing"."work_cycle_categories" to "authenticated";

grant trigger on table "mod_manufacturing"."work_cycle_categories" to "authenticated";

grant truncate on table "mod_manufacturing"."work_cycle_categories" to "authenticated";

grant update on table "mod_manufacturing"."work_cycle_categories" to "authenticated";

grant delete on table "mod_manufacturing"."work_cycle_categories" to "service_role";

grant insert on table "mod_manufacturing"."work_cycle_categories" to "service_role";

grant references on table "mod_manufacturing"."work_cycle_categories" to "service_role";

grant select on table "mod_manufacturing"."work_cycle_categories" to "service_role";

grant trigger on table "mod_manufacturing"."work_cycle_categories" to "service_role";

grant truncate on table "mod_manufacturing"."work_cycle_categories" to "service_role";

grant update on table "mod_manufacturing"."work_cycle_categories" to "service_role";

grant delete on table "mod_manufacturing"."work_cycles" to "anon";

grant insert on table "mod_manufacturing"."work_cycles" to "anon";

grant references on table "mod_manufacturing"."work_cycles" to "anon";

grant select on table "mod_manufacturing"."work_cycles" to "anon";

grant trigger on table "mod_manufacturing"."work_cycles" to "anon";

grant truncate on table "mod_manufacturing"."work_cycles" to "anon";

grant update on table "mod_manufacturing"."work_cycles" to "anon";

grant delete on table "mod_manufacturing"."work_cycles" to "authenticated";

grant insert on table "mod_manufacturing"."work_cycles" to "authenticated";

grant references on table "mod_manufacturing"."work_cycles" to "authenticated";

grant select on table "mod_manufacturing"."work_cycles" to "authenticated";

grant trigger on table "mod_manufacturing"."work_cycles" to "authenticated";

grant truncate on table "mod_manufacturing"."work_cycles" to "authenticated";

grant update on table "mod_manufacturing"."work_cycles" to "authenticated";

grant delete on table "mod_manufacturing"."work_cycles" to "service_role";

grant insert on table "mod_manufacturing"."work_cycles" to "service_role";

grant references on table "mod_manufacturing"."work_cycles" to "service_role";

grant select on table "mod_manufacturing"."work_cycles" to "service_role";

grant trigger on table "mod_manufacturing"."work_cycles" to "service_role";

grant truncate on table "mod_manufacturing"."work_cycles" to "service_role";

grant update on table "mod_manufacturing"."work_cycles" to "service_role";

grant delete on table "mod_manufacturing"."work_flows" to "anon";

grant insert on table "mod_manufacturing"."work_flows" to "anon";

grant references on table "mod_manufacturing"."work_flows" to "anon";

grant select on table "mod_manufacturing"."work_flows" to "anon";

grant trigger on table "mod_manufacturing"."work_flows" to "anon";

grant truncate on table "mod_manufacturing"."work_flows" to "anon";

grant update on table "mod_manufacturing"."work_flows" to "anon";

grant delete on table "mod_manufacturing"."work_flows" to "authenticated";

grant insert on table "mod_manufacturing"."work_flows" to "authenticated";

grant references on table "mod_manufacturing"."work_flows" to "authenticated";

grant select on table "mod_manufacturing"."work_flows" to "authenticated";

grant trigger on table "mod_manufacturing"."work_flows" to "authenticated";

grant truncate on table "mod_manufacturing"."work_flows" to "authenticated";

grant update on table "mod_manufacturing"."work_flows" to "authenticated";

grant delete on table "mod_manufacturing"."work_flows" to "service_role";

grant insert on table "mod_manufacturing"."work_flows" to "service_role";

grant references on table "mod_manufacturing"."work_flows" to "service_role";

grant select on table "mod_manufacturing"."work_flows" to "service_role";

grant trigger on table "mod_manufacturing"."work_flows" to "service_role";

grant truncate on table "mod_manufacturing"."work_flows" to "service_role";

grant update on table "mod_manufacturing"."work_flows" to "service_role";

grant delete on table "mod_manufacturing"."work_flows_work_cycles" to "anon";

grant insert on table "mod_manufacturing"."work_flows_work_cycles" to "anon";

grant references on table "mod_manufacturing"."work_flows_work_cycles" to "anon";

grant select on table "mod_manufacturing"."work_flows_work_cycles" to "anon";

grant trigger on table "mod_manufacturing"."work_flows_work_cycles" to "anon";

grant truncate on table "mod_manufacturing"."work_flows_work_cycles" to "anon";

grant update on table "mod_manufacturing"."work_flows_work_cycles" to "anon";

grant delete on table "mod_manufacturing"."work_flows_work_cycles" to "authenticated";

grant insert on table "mod_manufacturing"."work_flows_work_cycles" to "authenticated";

grant references on table "mod_manufacturing"."work_flows_work_cycles" to "authenticated";

grant select on table "mod_manufacturing"."work_flows_work_cycles" to "authenticated";

grant trigger on table "mod_manufacturing"."work_flows_work_cycles" to "authenticated";

grant truncate on table "mod_manufacturing"."work_flows_work_cycles" to "authenticated";

grant update on table "mod_manufacturing"."work_flows_work_cycles" to "authenticated";

grant delete on table "mod_manufacturing"."work_flows_work_cycles" to "service_role";

grant insert on table "mod_manufacturing"."work_flows_work_cycles" to "service_role";

grant references on table "mod_manufacturing"."work_flows_work_cycles" to "service_role";

grant select on table "mod_manufacturing"."work_flows_work_cycles" to "service_role";

grant trigger on table "mod_manufacturing"."work_flows_work_cycles" to "service_role";

grant truncate on table "mod_manufacturing"."work_flows_work_cycles" to "service_role";

grant update on table "mod_manufacturing"."work_flows_work_cycles" to "service_role";

grant delete on table "mod_manufacturing"."work_order_attachments" to "anon";

grant insert on table "mod_manufacturing"."work_order_attachments" to "anon";

grant references on table "mod_manufacturing"."work_order_attachments" to "anon";

grant select on table "mod_manufacturing"."work_order_attachments" to "anon";

grant trigger on table "mod_manufacturing"."work_order_attachments" to "anon";

grant truncate on table "mod_manufacturing"."work_order_attachments" to "anon";

grant update on table "mod_manufacturing"."work_order_attachments" to "anon";

grant delete on table "mod_manufacturing"."work_order_attachments" to "authenticated";

grant insert on table "mod_manufacturing"."work_order_attachments" to "authenticated";

grant references on table "mod_manufacturing"."work_order_attachments" to "authenticated";

grant select on table "mod_manufacturing"."work_order_attachments" to "authenticated";

grant trigger on table "mod_manufacturing"."work_order_attachments" to "authenticated";

grant truncate on table "mod_manufacturing"."work_order_attachments" to "authenticated";

grant update on table "mod_manufacturing"."work_order_attachments" to "authenticated";

grant delete on table "mod_manufacturing"."work_order_attachments" to "service_role";

grant insert on table "mod_manufacturing"."work_order_attachments" to "service_role";

grant references on table "mod_manufacturing"."work_order_attachments" to "service_role";

grant select on table "mod_manufacturing"."work_order_attachments" to "service_role";

grant trigger on table "mod_manufacturing"."work_order_attachments" to "service_role";

grant truncate on table "mod_manufacturing"."work_order_attachments" to "service_role";

grant update on table "mod_manufacturing"."work_order_attachments" to "service_role";

grant delete on table "mod_manufacturing"."work_order_quality_summary" to "anon";

grant insert on table "mod_manufacturing"."work_order_quality_summary" to "anon";

grant references on table "mod_manufacturing"."work_order_quality_summary" to "anon";

grant select on table "mod_manufacturing"."work_order_quality_summary" to "anon";

grant trigger on table "mod_manufacturing"."work_order_quality_summary" to "anon";

grant truncate on table "mod_manufacturing"."work_order_quality_summary" to "anon";

grant update on table "mod_manufacturing"."work_order_quality_summary" to "anon";

grant delete on table "mod_manufacturing"."work_order_quality_summary" to "authenticated";

grant insert on table "mod_manufacturing"."work_order_quality_summary" to "authenticated";

grant references on table "mod_manufacturing"."work_order_quality_summary" to "authenticated";

grant select on table "mod_manufacturing"."work_order_quality_summary" to "authenticated";

grant trigger on table "mod_manufacturing"."work_order_quality_summary" to "authenticated";

grant truncate on table "mod_manufacturing"."work_order_quality_summary" to "authenticated";

grant update on table "mod_manufacturing"."work_order_quality_summary" to "authenticated";

grant delete on table "mod_manufacturing"."work_order_quality_summary" to "service_role";

grant insert on table "mod_manufacturing"."work_order_quality_summary" to "service_role";

grant references on table "mod_manufacturing"."work_order_quality_summary" to "service_role";

grant select on table "mod_manufacturing"."work_order_quality_summary" to "service_role";

grant trigger on table "mod_manufacturing"."work_order_quality_summary" to "service_role";

grant truncate on table "mod_manufacturing"."work_order_quality_summary" to "service_role";

grant update on table "mod_manufacturing"."work_order_quality_summary" to "service_role";

grant delete on table "mod_manufacturing"."work_orders" to "anon";

grant insert on table "mod_manufacturing"."work_orders" to "anon";

grant references on table "mod_manufacturing"."work_orders" to "anon";

grant select on table "mod_manufacturing"."work_orders" to "anon";

grant trigger on table "mod_manufacturing"."work_orders" to "anon";

grant truncate on table "mod_manufacturing"."work_orders" to "anon";

grant update on table "mod_manufacturing"."work_orders" to "anon";

grant delete on table "mod_manufacturing"."work_orders" to "authenticated";

grant insert on table "mod_manufacturing"."work_orders" to "authenticated";

grant references on table "mod_manufacturing"."work_orders" to "authenticated";

grant select on table "mod_manufacturing"."work_orders" to "authenticated";

grant trigger on table "mod_manufacturing"."work_orders" to "authenticated";

grant truncate on table "mod_manufacturing"."work_orders" to "authenticated";

grant update on table "mod_manufacturing"."work_orders" to "authenticated";

grant delete on table "mod_manufacturing"."work_orders" to "service_role";

grant insert on table "mod_manufacturing"."work_orders" to "service_role";

grant references on table "mod_manufacturing"."work_orders" to "service_role";

grant select on table "mod_manufacturing"."work_orders" to "service_role";

grant trigger on table "mod_manufacturing"."work_orders" to "service_role";

grant truncate on table "mod_manufacturing"."work_orders" to "service_role";

grant update on table "mod_manufacturing"."work_orders" to "service_role";

grant delete on table "mod_manufacturing"."work_steps" to "anon";

grant insert on table "mod_manufacturing"."work_steps" to "anon";

grant references on table "mod_manufacturing"."work_steps" to "anon";

grant select on table "mod_manufacturing"."work_steps" to "anon";

grant trigger on table "mod_manufacturing"."work_steps" to "anon";

grant truncate on table "mod_manufacturing"."work_steps" to "anon";

grant update on table "mod_manufacturing"."work_steps" to "anon";

grant delete on table "mod_manufacturing"."work_steps" to "authenticated";

grant insert on table "mod_manufacturing"."work_steps" to "authenticated";

grant references on table "mod_manufacturing"."work_steps" to "authenticated";

grant select on table "mod_manufacturing"."work_steps" to "authenticated";

grant trigger on table "mod_manufacturing"."work_steps" to "authenticated";

grant truncate on table "mod_manufacturing"."work_steps" to "authenticated";

grant update on table "mod_manufacturing"."work_steps" to "authenticated";

grant delete on table "mod_manufacturing"."work_steps" to "service_role";

grant insert on table "mod_manufacturing"."work_steps" to "service_role";

grant references on table "mod_manufacturing"."work_steps" to "service_role";

grant select on table "mod_manufacturing"."work_steps" to "service_role";

grant trigger on table "mod_manufacturing"."work_steps" to "service_role";

grant truncate on table "mod_manufacturing"."work_steps" to "service_role";

grant update on table "mod_manufacturing"."work_steps" to "service_role";

grant delete on table "mod_manufacturing"."workstations" to "anon";

grant insert on table "mod_manufacturing"."workstations" to "anon";

grant references on table "mod_manufacturing"."workstations" to "anon";

grant select on table "mod_manufacturing"."workstations" to "anon";

grant trigger on table "mod_manufacturing"."workstations" to "anon";

grant truncate on table "mod_manufacturing"."workstations" to "anon";

grant update on table "mod_manufacturing"."workstations" to "anon";

grant delete on table "mod_manufacturing"."workstations" to "authenticated";

grant insert on table "mod_manufacturing"."workstations" to "authenticated";

grant references on table "mod_manufacturing"."workstations" to "authenticated";

grant select on table "mod_manufacturing"."workstations" to "authenticated";

grant trigger on table "mod_manufacturing"."workstations" to "authenticated";

grant truncate on table "mod_manufacturing"."workstations" to "authenticated";

grant update on table "mod_manufacturing"."workstations" to "authenticated";

grant delete on table "mod_manufacturing"."workstations" to "service_role";

grant insert on table "mod_manufacturing"."workstations" to "service_role";

grant references on table "mod_manufacturing"."workstations" to "service_role";

grant select on table "mod_manufacturing"."workstations" to "service_role";

grant trigger on table "mod_manufacturing"."workstations" to "service_role";

grant truncate on table "mod_manufacturing"."workstations" to "service_role";

grant update on table "mod_manufacturing"."workstations" to "service_role";

grant delete on table "mod_manufacturing"."workstations_duplicate" to "anon";

grant insert on table "mod_manufacturing"."workstations_duplicate" to "anon";

grant references on table "mod_manufacturing"."workstations_duplicate" to "anon";

grant select on table "mod_manufacturing"."workstations_duplicate" to "anon";

grant trigger on table "mod_manufacturing"."workstations_duplicate" to "anon";

grant truncate on table "mod_manufacturing"."workstations_duplicate" to "anon";

grant update on table "mod_manufacturing"."workstations_duplicate" to "anon";

grant delete on table "mod_manufacturing"."workstations_duplicate" to "authenticated";

grant insert on table "mod_manufacturing"."workstations_duplicate" to "authenticated";

grant references on table "mod_manufacturing"."workstations_duplicate" to "authenticated";

grant select on table "mod_manufacturing"."workstations_duplicate" to "authenticated";

grant trigger on table "mod_manufacturing"."workstations_duplicate" to "authenticated";

grant truncate on table "mod_manufacturing"."workstations_duplicate" to "authenticated";

grant update on table "mod_manufacturing"."workstations_duplicate" to "authenticated";

grant delete on table "mod_manufacturing"."workstations_duplicate" to "service_role";

grant insert on table "mod_manufacturing"."workstations_duplicate" to "service_role";

grant references on table "mod_manufacturing"."workstations_duplicate" to "service_role";

grant select on table "mod_manufacturing"."workstations_duplicate" to "service_role";

grant trigger on table "mod_manufacturing"."workstations_duplicate" to "service_role";

grant truncate on table "mod_manufacturing"."workstations_duplicate" to "service_role";

grant update on table "mod_manufacturing"."workstations_duplicate" to "service_role";

grant delete on table "mod_pulse"."department_notification_configs" to "anon";

grant insert on table "mod_pulse"."department_notification_configs" to "anon";

grant references on table "mod_pulse"."department_notification_configs" to "anon";

grant select on table "mod_pulse"."department_notification_configs" to "anon";

grant trigger on table "mod_pulse"."department_notification_configs" to "anon";

grant truncate on table "mod_pulse"."department_notification_configs" to "anon";

grant update on table "mod_pulse"."department_notification_configs" to "anon";

grant delete on table "mod_pulse"."department_notification_configs" to "authenticated";

grant insert on table "mod_pulse"."department_notification_configs" to "authenticated";

grant references on table "mod_pulse"."department_notification_configs" to "authenticated";

grant select on table "mod_pulse"."department_notification_configs" to "authenticated";

grant trigger on table "mod_pulse"."department_notification_configs" to "authenticated";

grant truncate on table "mod_pulse"."department_notification_configs" to "authenticated";

grant update on table "mod_pulse"."department_notification_configs" to "authenticated";

grant delete on table "mod_pulse"."department_notification_configs" to "service_role";

grant insert on table "mod_pulse"."department_notification_configs" to "service_role";

grant references on table "mod_pulse"."department_notification_configs" to "service_role";

grant select on table "mod_pulse"."department_notification_configs" to "service_role";

grant trigger on table "mod_pulse"."department_notification_configs" to "service_role";

grant truncate on table "mod_pulse"."department_notification_configs" to "service_role";

grant update on table "mod_pulse"."department_notification_configs" to "service_role";

grant delete on table "mod_pulse"."notifications" to "anon";

grant insert on table "mod_pulse"."notifications" to "anon";

grant references on table "mod_pulse"."notifications" to "anon";

grant select on table "mod_pulse"."notifications" to "anon";

grant trigger on table "mod_pulse"."notifications" to "anon";

grant truncate on table "mod_pulse"."notifications" to "anon";

grant update on table "mod_pulse"."notifications" to "anon";

grant delete on table "mod_pulse"."notifications" to "authenticated";

grant insert on table "mod_pulse"."notifications" to "authenticated";

grant references on table "mod_pulse"."notifications" to "authenticated";

grant select on table "mod_pulse"."notifications" to "authenticated";

grant trigger on table "mod_pulse"."notifications" to "authenticated";

grant truncate on table "mod_pulse"."notifications" to "authenticated";

grant update on table "mod_pulse"."notifications" to "authenticated";

grant delete on table "mod_pulse"."notifications" to "service_role";

grant insert on table "mod_pulse"."notifications" to "service_role";

grant references on table "mod_pulse"."notifications" to "service_role";

grant select on table "mod_pulse"."notifications" to "service_role";

grant trigger on table "mod_pulse"."notifications" to "service_role";

grant truncate on table "mod_pulse"."notifications" to "service_role";

grant update on table "mod_pulse"."notifications" to "service_role";

grant delete on table "mod_pulse"."pulse_chat" to "anon";

grant insert on table "mod_pulse"."pulse_chat" to "anon";

grant references on table "mod_pulse"."pulse_chat" to "anon";

grant select on table "mod_pulse"."pulse_chat" to "anon";

grant trigger on table "mod_pulse"."pulse_chat" to "anon";

grant truncate on table "mod_pulse"."pulse_chat" to "anon";

grant update on table "mod_pulse"."pulse_chat" to "anon";

grant delete on table "mod_pulse"."pulse_chat" to "authenticated";

grant insert on table "mod_pulse"."pulse_chat" to "authenticated";

grant references on table "mod_pulse"."pulse_chat" to "authenticated";

grant select on table "mod_pulse"."pulse_chat" to "authenticated";

grant trigger on table "mod_pulse"."pulse_chat" to "authenticated";

grant truncate on table "mod_pulse"."pulse_chat" to "authenticated";

grant update on table "mod_pulse"."pulse_chat" to "authenticated";

grant delete on table "mod_pulse"."pulse_chat" to "service_role";

grant insert on table "mod_pulse"."pulse_chat" to "service_role";

grant references on table "mod_pulse"."pulse_chat" to "service_role";

grant select on table "mod_pulse"."pulse_chat" to "service_role";

grant trigger on table "mod_pulse"."pulse_chat" to "service_role";

grant truncate on table "mod_pulse"."pulse_chat" to "service_role";

grant update on table "mod_pulse"."pulse_chat" to "service_role";

grant delete on table "mod_pulse"."pulse_chat_files" to "anon";

grant insert on table "mod_pulse"."pulse_chat_files" to "anon";

grant references on table "mod_pulse"."pulse_chat_files" to "anon";

grant select on table "mod_pulse"."pulse_chat_files" to "anon";

grant trigger on table "mod_pulse"."pulse_chat_files" to "anon";

grant truncate on table "mod_pulse"."pulse_chat_files" to "anon";

grant update on table "mod_pulse"."pulse_chat_files" to "anon";

grant delete on table "mod_pulse"."pulse_chat_files" to "authenticated";

grant insert on table "mod_pulse"."pulse_chat_files" to "authenticated";

grant references on table "mod_pulse"."pulse_chat_files" to "authenticated";

grant select on table "mod_pulse"."pulse_chat_files" to "authenticated";

grant trigger on table "mod_pulse"."pulse_chat_files" to "authenticated";

grant truncate on table "mod_pulse"."pulse_chat_files" to "authenticated";

grant update on table "mod_pulse"."pulse_chat_files" to "authenticated";

grant delete on table "mod_pulse"."pulse_chat_files" to "service_role";

grant insert on table "mod_pulse"."pulse_chat_files" to "service_role";

grant references on table "mod_pulse"."pulse_chat_files" to "service_role";

grant select on table "mod_pulse"."pulse_chat_files" to "service_role";

grant trigger on table "mod_pulse"."pulse_chat_files" to "service_role";

grant truncate on table "mod_pulse"."pulse_chat_files" to "service_role";

grant update on table "mod_pulse"."pulse_chat_files" to "service_role";

grant delete on table "mod_pulse"."pulse_checklists" to "anon";

grant insert on table "mod_pulse"."pulse_checklists" to "anon";

grant references on table "mod_pulse"."pulse_checklists" to "anon";

grant select on table "mod_pulse"."pulse_checklists" to "anon";

grant trigger on table "mod_pulse"."pulse_checklists" to "anon";

grant truncate on table "mod_pulse"."pulse_checklists" to "anon";

grant update on table "mod_pulse"."pulse_checklists" to "anon";

grant delete on table "mod_pulse"."pulse_checklists" to "authenticated";

grant insert on table "mod_pulse"."pulse_checklists" to "authenticated";

grant references on table "mod_pulse"."pulse_checklists" to "authenticated";

grant select on table "mod_pulse"."pulse_checklists" to "authenticated";

grant trigger on table "mod_pulse"."pulse_checklists" to "authenticated";

grant truncate on table "mod_pulse"."pulse_checklists" to "authenticated";

grant update on table "mod_pulse"."pulse_checklists" to "authenticated";

grant delete on table "mod_pulse"."pulse_checklists" to "service_role";

grant insert on table "mod_pulse"."pulse_checklists" to "service_role";

grant references on table "mod_pulse"."pulse_checklists" to "service_role";

grant select on table "mod_pulse"."pulse_checklists" to "service_role";

grant trigger on table "mod_pulse"."pulse_checklists" to "service_role";

grant truncate on table "mod_pulse"."pulse_checklists" to "service_role";

grant update on table "mod_pulse"."pulse_checklists" to "service_role";

grant delete on table "mod_pulse"."pulse_comments" to "anon";

grant insert on table "mod_pulse"."pulse_comments" to "anon";

grant references on table "mod_pulse"."pulse_comments" to "anon";

grant select on table "mod_pulse"."pulse_comments" to "anon";

grant trigger on table "mod_pulse"."pulse_comments" to "anon";

grant truncate on table "mod_pulse"."pulse_comments" to "anon";

grant update on table "mod_pulse"."pulse_comments" to "anon";

grant delete on table "mod_pulse"."pulse_comments" to "authenticated";

grant insert on table "mod_pulse"."pulse_comments" to "authenticated";

grant references on table "mod_pulse"."pulse_comments" to "authenticated";

grant select on table "mod_pulse"."pulse_comments" to "authenticated";

grant trigger on table "mod_pulse"."pulse_comments" to "authenticated";

grant truncate on table "mod_pulse"."pulse_comments" to "authenticated";

grant update on table "mod_pulse"."pulse_comments" to "authenticated";

grant delete on table "mod_pulse"."pulse_comments" to "service_role";

grant insert on table "mod_pulse"."pulse_comments" to "service_role";

grant references on table "mod_pulse"."pulse_comments" to "service_role";

grant select on table "mod_pulse"."pulse_comments" to "service_role";

grant trigger on table "mod_pulse"."pulse_comments" to "service_role";

grant truncate on table "mod_pulse"."pulse_comments" to "service_role";

grant update on table "mod_pulse"."pulse_comments" to "service_role";

grant delete on table "mod_pulse"."pulse_conversation_participants" to "anon";

grant insert on table "mod_pulse"."pulse_conversation_participants" to "anon";

grant references on table "mod_pulse"."pulse_conversation_participants" to "anon";

grant select on table "mod_pulse"."pulse_conversation_participants" to "anon";

grant trigger on table "mod_pulse"."pulse_conversation_participants" to "anon";

grant truncate on table "mod_pulse"."pulse_conversation_participants" to "anon";

grant update on table "mod_pulse"."pulse_conversation_participants" to "anon";

grant delete on table "mod_pulse"."pulse_conversation_participants" to "authenticated";

grant insert on table "mod_pulse"."pulse_conversation_participants" to "authenticated";

grant references on table "mod_pulse"."pulse_conversation_participants" to "authenticated";

grant select on table "mod_pulse"."pulse_conversation_participants" to "authenticated";

grant trigger on table "mod_pulse"."pulse_conversation_participants" to "authenticated";

grant truncate on table "mod_pulse"."pulse_conversation_participants" to "authenticated";

grant update on table "mod_pulse"."pulse_conversation_participants" to "authenticated";

grant delete on table "mod_pulse"."pulse_conversation_participants" to "service_role";

grant insert on table "mod_pulse"."pulse_conversation_participants" to "service_role";

grant references on table "mod_pulse"."pulse_conversation_participants" to "service_role";

grant select on table "mod_pulse"."pulse_conversation_participants" to "service_role";

grant trigger on table "mod_pulse"."pulse_conversation_participants" to "service_role";

grant truncate on table "mod_pulse"."pulse_conversation_participants" to "service_role";

grant update on table "mod_pulse"."pulse_conversation_participants" to "service_role";

grant delete on table "mod_pulse"."pulse_progress" to "anon";

grant insert on table "mod_pulse"."pulse_progress" to "anon";

grant references on table "mod_pulse"."pulse_progress" to "anon";

grant select on table "mod_pulse"."pulse_progress" to "anon";

grant trigger on table "mod_pulse"."pulse_progress" to "anon";

grant truncate on table "mod_pulse"."pulse_progress" to "anon";

grant update on table "mod_pulse"."pulse_progress" to "anon";

grant delete on table "mod_pulse"."pulse_progress" to "authenticated";

grant insert on table "mod_pulse"."pulse_progress" to "authenticated";

grant references on table "mod_pulse"."pulse_progress" to "authenticated";

grant select on table "mod_pulse"."pulse_progress" to "authenticated";

grant trigger on table "mod_pulse"."pulse_progress" to "authenticated";

grant truncate on table "mod_pulse"."pulse_progress" to "authenticated";

grant update on table "mod_pulse"."pulse_progress" to "authenticated";

grant delete on table "mod_pulse"."pulse_progress" to "service_role";

grant insert on table "mod_pulse"."pulse_progress" to "service_role";

grant references on table "mod_pulse"."pulse_progress" to "service_role";

grant select on table "mod_pulse"."pulse_progress" to "service_role";

grant trigger on table "mod_pulse"."pulse_progress" to "service_role";

grant truncate on table "mod_pulse"."pulse_progress" to "service_role";

grant update on table "mod_pulse"."pulse_progress" to "service_role";

grant delete on table "mod_pulse"."pulse_slas" to "anon";

grant insert on table "mod_pulse"."pulse_slas" to "anon";

grant references on table "mod_pulse"."pulse_slas" to "anon";

grant select on table "mod_pulse"."pulse_slas" to "anon";

grant trigger on table "mod_pulse"."pulse_slas" to "anon";

grant truncate on table "mod_pulse"."pulse_slas" to "anon";

grant update on table "mod_pulse"."pulse_slas" to "anon";

grant delete on table "mod_pulse"."pulse_slas" to "authenticated";

grant insert on table "mod_pulse"."pulse_slas" to "authenticated";

grant references on table "mod_pulse"."pulse_slas" to "authenticated";

grant select on table "mod_pulse"."pulse_slas" to "authenticated";

grant trigger on table "mod_pulse"."pulse_slas" to "authenticated";

grant truncate on table "mod_pulse"."pulse_slas" to "authenticated";

grant update on table "mod_pulse"."pulse_slas" to "authenticated";

grant delete on table "mod_pulse"."pulse_slas" to "service_role";

grant insert on table "mod_pulse"."pulse_slas" to "service_role";

grant references on table "mod_pulse"."pulse_slas" to "service_role";

grant select on table "mod_pulse"."pulse_slas" to "service_role";

grant trigger on table "mod_pulse"."pulse_slas" to "service_role";

grant truncate on table "mod_pulse"."pulse_slas" to "service_role";

grant update on table "mod_pulse"."pulse_slas" to "service_role";

grant delete on table "mod_pulse"."pulses" to "anon";

grant insert on table "mod_pulse"."pulses" to "anon";

grant references on table "mod_pulse"."pulses" to "anon";

grant select on table "mod_pulse"."pulses" to "anon";

grant trigger on table "mod_pulse"."pulses" to "anon";

grant truncate on table "mod_pulse"."pulses" to "anon";

grant update on table "mod_pulse"."pulses" to "anon";

grant delete on table "mod_pulse"."pulses" to "authenticated";

grant insert on table "mod_pulse"."pulses" to "authenticated";

grant references on table "mod_pulse"."pulses" to "authenticated";

grant select on table "mod_pulse"."pulses" to "authenticated";

grant trigger on table "mod_pulse"."pulses" to "authenticated";

grant truncate on table "mod_pulse"."pulses" to "authenticated";

grant update on table "mod_pulse"."pulses" to "authenticated";

grant delete on table "mod_pulse"."pulses" to "service_role";

grant insert on table "mod_pulse"."pulses" to "service_role";

grant references on table "mod_pulse"."pulses" to "service_role";

grant select on table "mod_pulse"."pulses" to "service_role";

grant trigger on table "mod_pulse"."pulses" to "service_role";

grant truncate on table "mod_pulse"."pulses" to "service_role";

grant update on table "mod_pulse"."pulses" to "service_role";

grant delete on table "mod_pulse"."tasks" to "anon";

grant insert on table "mod_pulse"."tasks" to "anon";

grant references on table "mod_pulse"."tasks" to "anon";

grant select on table "mod_pulse"."tasks" to "anon";

grant trigger on table "mod_pulse"."tasks" to "anon";

grant truncate on table "mod_pulse"."tasks" to "anon";

grant update on table "mod_pulse"."tasks" to "anon";

grant delete on table "mod_pulse"."tasks" to "authenticated";

grant insert on table "mod_pulse"."tasks" to "authenticated";

grant references on table "mod_pulse"."tasks" to "authenticated";

grant select on table "mod_pulse"."tasks" to "authenticated";

grant trigger on table "mod_pulse"."tasks" to "authenticated";

grant truncate on table "mod_pulse"."tasks" to "authenticated";

grant update on table "mod_pulse"."tasks" to "authenticated";

grant delete on table "mod_pulse"."tasks" to "service_role";

grant insert on table "mod_pulse"."tasks" to "service_role";

grant references on table "mod_pulse"."tasks" to "service_role";

grant select on table "mod_pulse"."tasks" to "service_role";

grant trigger on table "mod_pulse"."tasks" to "service_role";

grant truncate on table "mod_pulse"."tasks" to "service_role";

grant update on table "mod_pulse"."tasks" to "service_role";

grant delete on table "mod_wms"."batches" to "anon";

grant insert on table "mod_wms"."batches" to "anon";

grant references on table "mod_wms"."batches" to "anon";

grant select on table "mod_wms"."batches" to "anon";

grant trigger on table "mod_wms"."batches" to "anon";

grant truncate on table "mod_wms"."batches" to "anon";

grant update on table "mod_wms"."batches" to "anon";

grant delete on table "mod_wms"."batches" to "authenticated";

grant insert on table "mod_wms"."batches" to "authenticated";

grant references on table "mod_wms"."batches" to "authenticated";

grant select on table "mod_wms"."batches" to "authenticated";

grant trigger on table "mod_wms"."batches" to "authenticated";

grant truncate on table "mod_wms"."batches" to "authenticated";

grant update on table "mod_wms"."batches" to "authenticated";

grant delete on table "mod_wms"."batches" to "service_role";

grant insert on table "mod_wms"."batches" to "service_role";

grant references on table "mod_wms"."batches" to "service_role";

grant select on table "mod_wms"."batches" to "service_role";

grant trigger on table "mod_wms"."batches" to "service_role";

grant truncate on table "mod_wms"."batches" to "service_role";

grant update on table "mod_wms"."batches" to "service_role";

grant delete on table "mod_wms"."box_contents" to "anon";

grant insert on table "mod_wms"."box_contents" to "anon";

grant references on table "mod_wms"."box_contents" to "anon";

grant select on table "mod_wms"."box_contents" to "anon";

grant trigger on table "mod_wms"."box_contents" to "anon";

grant truncate on table "mod_wms"."box_contents" to "anon";

grant update on table "mod_wms"."box_contents" to "anon";

grant delete on table "mod_wms"."box_contents" to "authenticated";

grant insert on table "mod_wms"."box_contents" to "authenticated";

grant references on table "mod_wms"."box_contents" to "authenticated";

grant select on table "mod_wms"."box_contents" to "authenticated";

grant trigger on table "mod_wms"."box_contents" to "authenticated";

grant truncate on table "mod_wms"."box_contents" to "authenticated";

grant update on table "mod_wms"."box_contents" to "authenticated";

grant delete on table "mod_wms"."box_contents" to "service_role";

grant insert on table "mod_wms"."box_contents" to "service_role";

grant references on table "mod_wms"."box_contents" to "service_role";

grant select on table "mod_wms"."box_contents" to "service_role";

grant trigger on table "mod_wms"."box_contents" to "service_role";

grant truncate on table "mod_wms"."box_contents" to "service_role";

grant update on table "mod_wms"."box_contents" to "service_role";

grant delete on table "mod_wms"."box_types" to "anon";

grant insert on table "mod_wms"."box_types" to "anon";

grant references on table "mod_wms"."box_types" to "anon";

grant select on table "mod_wms"."box_types" to "anon";

grant trigger on table "mod_wms"."box_types" to "anon";

grant truncate on table "mod_wms"."box_types" to "anon";

grant update on table "mod_wms"."box_types" to "anon";

grant delete on table "mod_wms"."box_types" to "authenticated";

grant insert on table "mod_wms"."box_types" to "authenticated";

grant references on table "mod_wms"."box_types" to "authenticated";

grant select on table "mod_wms"."box_types" to "authenticated";

grant trigger on table "mod_wms"."box_types" to "authenticated";

grant truncate on table "mod_wms"."box_types" to "authenticated";

grant update on table "mod_wms"."box_types" to "authenticated";

grant delete on table "mod_wms"."box_types" to "service_role";

grant insert on table "mod_wms"."box_types" to "service_role";

grant references on table "mod_wms"."box_types" to "service_role";

grant select on table "mod_wms"."box_types" to "service_role";

grant trigger on table "mod_wms"."box_types" to "service_role";

grant truncate on table "mod_wms"."box_types" to "service_role";

grant update on table "mod_wms"."box_types" to "service_role";

grant delete on table "mod_wms"."carton_contents" to "anon";

grant insert on table "mod_wms"."carton_contents" to "anon";

grant references on table "mod_wms"."carton_contents" to "anon";

grant select on table "mod_wms"."carton_contents" to "anon";

grant trigger on table "mod_wms"."carton_contents" to "anon";

grant truncate on table "mod_wms"."carton_contents" to "anon";

grant update on table "mod_wms"."carton_contents" to "anon";

grant delete on table "mod_wms"."carton_contents" to "authenticated";

grant insert on table "mod_wms"."carton_contents" to "authenticated";

grant references on table "mod_wms"."carton_contents" to "authenticated";

grant select on table "mod_wms"."carton_contents" to "authenticated";

grant trigger on table "mod_wms"."carton_contents" to "authenticated";

grant truncate on table "mod_wms"."carton_contents" to "authenticated";

grant update on table "mod_wms"."carton_contents" to "authenticated";

grant delete on table "mod_wms"."carton_contents" to "service_role";

grant insert on table "mod_wms"."carton_contents" to "service_role";

grant references on table "mod_wms"."carton_contents" to "service_role";

grant select on table "mod_wms"."carton_contents" to "service_role";

grant trigger on table "mod_wms"."carton_contents" to "service_role";

grant truncate on table "mod_wms"."carton_contents" to "service_role";

grant update on table "mod_wms"."carton_contents" to "service_role";

grant delete on table "mod_wms"."carton_types" to "anon";

grant insert on table "mod_wms"."carton_types" to "anon";

grant references on table "mod_wms"."carton_types" to "anon";

grant select on table "mod_wms"."carton_types" to "anon";

grant trigger on table "mod_wms"."carton_types" to "anon";

grant truncate on table "mod_wms"."carton_types" to "anon";

grant update on table "mod_wms"."carton_types" to "anon";

grant delete on table "mod_wms"."carton_types" to "authenticated";

grant insert on table "mod_wms"."carton_types" to "authenticated";

grant references on table "mod_wms"."carton_types" to "authenticated";

grant select on table "mod_wms"."carton_types" to "authenticated";

grant trigger on table "mod_wms"."carton_types" to "authenticated";

grant truncate on table "mod_wms"."carton_types" to "authenticated";

grant update on table "mod_wms"."carton_types" to "authenticated";

grant delete on table "mod_wms"."carton_types" to "service_role";

grant insert on table "mod_wms"."carton_types" to "service_role";

grant references on table "mod_wms"."carton_types" to "service_role";

grant select on table "mod_wms"."carton_types" to "service_role";

grant trigger on table "mod_wms"."carton_types" to "service_role";

grant truncate on table "mod_wms"."carton_types" to "service_role";

grant update on table "mod_wms"."carton_types" to "service_role";

grant delete on table "mod_wms"."inventory" to "anon";

grant insert on table "mod_wms"."inventory" to "anon";

grant references on table "mod_wms"."inventory" to "anon";

grant select on table "mod_wms"."inventory" to "anon";

grant trigger on table "mod_wms"."inventory" to "anon";

grant truncate on table "mod_wms"."inventory" to "anon";

grant update on table "mod_wms"."inventory" to "anon";

grant delete on table "mod_wms"."inventory" to "authenticated";

grant insert on table "mod_wms"."inventory" to "authenticated";

grant references on table "mod_wms"."inventory" to "authenticated";

grant select on table "mod_wms"."inventory" to "authenticated";

grant trigger on table "mod_wms"."inventory" to "authenticated";

grant truncate on table "mod_wms"."inventory" to "authenticated";

grant update on table "mod_wms"."inventory" to "authenticated";

grant delete on table "mod_wms"."inventory" to "service_role";

grant insert on table "mod_wms"."inventory" to "service_role";

grant references on table "mod_wms"."inventory" to "service_role";

grant select on table "mod_wms"."inventory" to "service_role";

grant trigger on table "mod_wms"."inventory" to "service_role";

grant truncate on table "mod_wms"."inventory" to "service_role";

grant update on table "mod_wms"."inventory" to "service_role";

grant delete on table "mod_wms"."inventory_backup" to "anon";

grant insert on table "mod_wms"."inventory_backup" to "anon";

grant references on table "mod_wms"."inventory_backup" to "anon";

grant select on table "mod_wms"."inventory_backup" to "anon";

grant trigger on table "mod_wms"."inventory_backup" to "anon";

grant truncate on table "mod_wms"."inventory_backup" to "anon";

grant update on table "mod_wms"."inventory_backup" to "anon";

grant delete on table "mod_wms"."inventory_backup" to "authenticated";

grant insert on table "mod_wms"."inventory_backup" to "authenticated";

grant references on table "mod_wms"."inventory_backup" to "authenticated";

grant select on table "mod_wms"."inventory_backup" to "authenticated";

grant trigger on table "mod_wms"."inventory_backup" to "authenticated";

grant truncate on table "mod_wms"."inventory_backup" to "authenticated";

grant update on table "mod_wms"."inventory_backup" to "authenticated";

grant delete on table "mod_wms"."inventory_backup" to "service_role";

grant insert on table "mod_wms"."inventory_backup" to "service_role";

grant references on table "mod_wms"."inventory_backup" to "service_role";

grant select on table "mod_wms"."inventory_backup" to "service_role";

grant trigger on table "mod_wms"."inventory_backup" to "service_role";

grant truncate on table "mod_wms"."inventory_backup" to "service_role";

grant update on table "mod_wms"."inventory_backup" to "service_role";

grant delete on table "mod_wms"."inventory_limits" to "anon";

grant insert on table "mod_wms"."inventory_limits" to "anon";

grant references on table "mod_wms"."inventory_limits" to "anon";

grant select on table "mod_wms"."inventory_limits" to "anon";

grant trigger on table "mod_wms"."inventory_limits" to "anon";

grant truncate on table "mod_wms"."inventory_limits" to "anon";

grant update on table "mod_wms"."inventory_limits" to "anon";

grant delete on table "mod_wms"."inventory_limits" to "authenticated";

grant insert on table "mod_wms"."inventory_limits" to "authenticated";

grant references on table "mod_wms"."inventory_limits" to "authenticated";

grant select on table "mod_wms"."inventory_limits" to "authenticated";

grant trigger on table "mod_wms"."inventory_limits" to "authenticated";

grant truncate on table "mod_wms"."inventory_limits" to "authenticated";

grant update on table "mod_wms"."inventory_limits" to "authenticated";

grant delete on table "mod_wms"."inventory_limits" to "service_role";

grant insert on table "mod_wms"."inventory_limits" to "service_role";

grant references on table "mod_wms"."inventory_limits" to "service_role";

grant select on table "mod_wms"."inventory_limits" to "service_role";

grant trigger on table "mod_wms"."inventory_limits" to "service_role";

grant truncate on table "mod_wms"."inventory_limits" to "service_role";

grant update on table "mod_wms"."inventory_limits" to "service_role";

grant delete on table "mod_wms"."locations" to "anon";

grant insert on table "mod_wms"."locations" to "anon";

grant references on table "mod_wms"."locations" to "anon";

grant select on table "mod_wms"."locations" to "anon";

grant trigger on table "mod_wms"."locations" to "anon";

grant truncate on table "mod_wms"."locations" to "anon";

grant update on table "mod_wms"."locations" to "anon";

grant delete on table "mod_wms"."locations" to "authenticated";

grant insert on table "mod_wms"."locations" to "authenticated";

grant references on table "mod_wms"."locations" to "authenticated";

grant select on table "mod_wms"."locations" to "authenticated";

grant trigger on table "mod_wms"."locations" to "authenticated";

grant truncate on table "mod_wms"."locations" to "authenticated";

grant update on table "mod_wms"."locations" to "authenticated";

grant delete on table "mod_wms"."locations" to "service_role";

grant insert on table "mod_wms"."locations" to "service_role";

grant references on table "mod_wms"."locations" to "service_role";

grant select on table "mod_wms"."locations" to "service_role";

grant trigger on table "mod_wms"."locations" to "service_role";

grant truncate on table "mod_wms"."locations" to "service_role";

grant update on table "mod_wms"."locations" to "service_role";

grant delete on table "mod_wms"."pallet_contents" to "anon";

grant insert on table "mod_wms"."pallet_contents" to "anon";

grant references on table "mod_wms"."pallet_contents" to "anon";

grant select on table "mod_wms"."pallet_contents" to "anon";

grant trigger on table "mod_wms"."pallet_contents" to "anon";

grant truncate on table "mod_wms"."pallet_contents" to "anon";

grant update on table "mod_wms"."pallet_contents" to "anon";

grant delete on table "mod_wms"."pallet_contents" to "authenticated";

grant insert on table "mod_wms"."pallet_contents" to "authenticated";

grant references on table "mod_wms"."pallet_contents" to "authenticated";

grant select on table "mod_wms"."pallet_contents" to "authenticated";

grant trigger on table "mod_wms"."pallet_contents" to "authenticated";

grant truncate on table "mod_wms"."pallet_contents" to "authenticated";

grant update on table "mod_wms"."pallet_contents" to "authenticated";

grant delete on table "mod_wms"."pallet_contents" to "service_role";

grant insert on table "mod_wms"."pallet_contents" to "service_role";

grant references on table "mod_wms"."pallet_contents" to "service_role";

grant select on table "mod_wms"."pallet_contents" to "service_role";

grant trigger on table "mod_wms"."pallet_contents" to "service_role";

grant truncate on table "mod_wms"."pallet_contents" to "service_role";

grant update on table "mod_wms"."pallet_contents" to "service_role";

grant delete on table "mod_wms"."pallet_types" to "anon";

grant insert on table "mod_wms"."pallet_types" to "anon";

grant references on table "mod_wms"."pallet_types" to "anon";

grant select on table "mod_wms"."pallet_types" to "anon";

grant trigger on table "mod_wms"."pallet_types" to "anon";

grant truncate on table "mod_wms"."pallet_types" to "anon";

grant update on table "mod_wms"."pallet_types" to "anon";

grant delete on table "mod_wms"."pallet_types" to "authenticated";

grant insert on table "mod_wms"."pallet_types" to "authenticated";

grant references on table "mod_wms"."pallet_types" to "authenticated";

grant select on table "mod_wms"."pallet_types" to "authenticated";

grant trigger on table "mod_wms"."pallet_types" to "authenticated";

grant truncate on table "mod_wms"."pallet_types" to "authenticated";

grant update on table "mod_wms"."pallet_types" to "authenticated";

grant delete on table "mod_wms"."pallet_types" to "service_role";

grant insert on table "mod_wms"."pallet_types" to "service_role";

grant references on table "mod_wms"."pallet_types" to "service_role";

grant select on table "mod_wms"."pallet_types" to "service_role";

grant trigger on table "mod_wms"."pallet_types" to "service_role";

grant truncate on table "mod_wms"."pallet_types" to "service_role";

grant update on table "mod_wms"."pallet_types" to "service_role";

grant delete on table "mod_wms"."receipt_items" to "anon";

grant insert on table "mod_wms"."receipt_items" to "anon";

grant references on table "mod_wms"."receipt_items" to "anon";

grant select on table "mod_wms"."receipt_items" to "anon";

grant trigger on table "mod_wms"."receipt_items" to "anon";

grant truncate on table "mod_wms"."receipt_items" to "anon";

grant update on table "mod_wms"."receipt_items" to "anon";

grant delete on table "mod_wms"."receipt_items" to "authenticated";

grant insert on table "mod_wms"."receipt_items" to "authenticated";

grant references on table "mod_wms"."receipt_items" to "authenticated";

grant select on table "mod_wms"."receipt_items" to "authenticated";

grant trigger on table "mod_wms"."receipt_items" to "authenticated";

grant truncate on table "mod_wms"."receipt_items" to "authenticated";

grant update on table "mod_wms"."receipt_items" to "authenticated";

grant delete on table "mod_wms"."receipt_items" to "service_role";

grant insert on table "mod_wms"."receipt_items" to "service_role";

grant references on table "mod_wms"."receipt_items" to "service_role";

grant select on table "mod_wms"."receipt_items" to "service_role";

grant trigger on table "mod_wms"."receipt_items" to "service_role";

grant truncate on table "mod_wms"."receipt_items" to "service_role";

grant update on table "mod_wms"."receipt_items" to "service_role";

grant delete on table "mod_wms"."receipts" to "anon";

grant insert on table "mod_wms"."receipts" to "anon";

grant references on table "mod_wms"."receipts" to "anon";

grant select on table "mod_wms"."receipts" to "anon";

grant trigger on table "mod_wms"."receipts" to "anon";

grant truncate on table "mod_wms"."receipts" to "anon";

grant update on table "mod_wms"."receipts" to "anon";

grant delete on table "mod_wms"."receipts" to "authenticated";

grant insert on table "mod_wms"."receipts" to "authenticated";

grant references on table "mod_wms"."receipts" to "authenticated";

grant select on table "mod_wms"."receipts" to "authenticated";

grant trigger on table "mod_wms"."receipts" to "authenticated";

grant truncate on table "mod_wms"."receipts" to "authenticated";

grant update on table "mod_wms"."receipts" to "authenticated";

grant delete on table "mod_wms"."receipts" to "service_role";

grant insert on table "mod_wms"."receipts" to "service_role";

grant references on table "mod_wms"."receipts" to "service_role";

grant select on table "mod_wms"."receipts" to "service_role";

grant trigger on table "mod_wms"."receipts" to "service_role";

grant truncate on table "mod_wms"."receipts" to "service_role";

grant update on table "mod_wms"."receipts" to "service_role";

grant delete on table "mod_wms"."shipment_attachments" to "anon";

grant insert on table "mod_wms"."shipment_attachments" to "anon";

grant references on table "mod_wms"."shipment_attachments" to "anon";

grant select on table "mod_wms"."shipment_attachments" to "anon";

grant trigger on table "mod_wms"."shipment_attachments" to "anon";

grant truncate on table "mod_wms"."shipment_attachments" to "anon";

grant update on table "mod_wms"."shipment_attachments" to "anon";

grant delete on table "mod_wms"."shipment_attachments" to "authenticated";

grant insert on table "mod_wms"."shipment_attachments" to "authenticated";

grant references on table "mod_wms"."shipment_attachments" to "authenticated";

grant select on table "mod_wms"."shipment_attachments" to "authenticated";

grant trigger on table "mod_wms"."shipment_attachments" to "authenticated";

grant truncate on table "mod_wms"."shipment_attachments" to "authenticated";

grant update on table "mod_wms"."shipment_attachments" to "authenticated";

grant delete on table "mod_wms"."shipment_attachments" to "service_role";

grant insert on table "mod_wms"."shipment_attachments" to "service_role";

grant references on table "mod_wms"."shipment_attachments" to "service_role";

grant select on table "mod_wms"."shipment_attachments" to "service_role";

grant trigger on table "mod_wms"."shipment_attachments" to "service_role";

grant truncate on table "mod_wms"."shipment_attachments" to "service_role";

grant update on table "mod_wms"."shipment_attachments" to "service_role";

grant delete on table "mod_wms"."shipment_boxes" to "anon";

grant insert on table "mod_wms"."shipment_boxes" to "anon";

grant references on table "mod_wms"."shipment_boxes" to "anon";

grant select on table "mod_wms"."shipment_boxes" to "anon";

grant trigger on table "mod_wms"."shipment_boxes" to "anon";

grant truncate on table "mod_wms"."shipment_boxes" to "anon";

grant update on table "mod_wms"."shipment_boxes" to "anon";

grant delete on table "mod_wms"."shipment_boxes" to "authenticated";

grant insert on table "mod_wms"."shipment_boxes" to "authenticated";

grant references on table "mod_wms"."shipment_boxes" to "authenticated";

grant select on table "mod_wms"."shipment_boxes" to "authenticated";

grant trigger on table "mod_wms"."shipment_boxes" to "authenticated";

grant truncate on table "mod_wms"."shipment_boxes" to "authenticated";

grant update on table "mod_wms"."shipment_boxes" to "authenticated";

grant delete on table "mod_wms"."shipment_boxes" to "service_role";

grant insert on table "mod_wms"."shipment_boxes" to "service_role";

grant references on table "mod_wms"."shipment_boxes" to "service_role";

grant select on table "mod_wms"."shipment_boxes" to "service_role";

grant trigger on table "mod_wms"."shipment_boxes" to "service_role";

grant truncate on table "mod_wms"."shipment_boxes" to "service_role";

grant update on table "mod_wms"."shipment_boxes" to "service_role";

grant delete on table "mod_wms"."shipment_cartons" to "anon";

grant insert on table "mod_wms"."shipment_cartons" to "anon";

grant references on table "mod_wms"."shipment_cartons" to "anon";

grant select on table "mod_wms"."shipment_cartons" to "anon";

grant trigger on table "mod_wms"."shipment_cartons" to "anon";

grant truncate on table "mod_wms"."shipment_cartons" to "anon";

grant update on table "mod_wms"."shipment_cartons" to "anon";

grant delete on table "mod_wms"."shipment_cartons" to "authenticated";

grant insert on table "mod_wms"."shipment_cartons" to "authenticated";

grant references on table "mod_wms"."shipment_cartons" to "authenticated";

grant select on table "mod_wms"."shipment_cartons" to "authenticated";

grant trigger on table "mod_wms"."shipment_cartons" to "authenticated";

grant truncate on table "mod_wms"."shipment_cartons" to "authenticated";

grant update on table "mod_wms"."shipment_cartons" to "authenticated";

grant delete on table "mod_wms"."shipment_cartons" to "service_role";

grant insert on table "mod_wms"."shipment_cartons" to "service_role";

grant references on table "mod_wms"."shipment_cartons" to "service_role";

grant select on table "mod_wms"."shipment_cartons" to "service_role";

grant trigger on table "mod_wms"."shipment_cartons" to "service_role";

grant truncate on table "mod_wms"."shipment_cartons" to "service_role";

grant update on table "mod_wms"."shipment_cartons" to "service_role";

grant delete on table "mod_wms"."shipment_item_addresses" to "anon";

grant insert on table "mod_wms"."shipment_item_addresses" to "anon";

grant references on table "mod_wms"."shipment_item_addresses" to "anon";

grant select on table "mod_wms"."shipment_item_addresses" to "anon";

grant trigger on table "mod_wms"."shipment_item_addresses" to "anon";

grant truncate on table "mod_wms"."shipment_item_addresses" to "anon";

grant update on table "mod_wms"."shipment_item_addresses" to "anon";

grant delete on table "mod_wms"."shipment_item_addresses" to "authenticated";

grant insert on table "mod_wms"."shipment_item_addresses" to "authenticated";

grant references on table "mod_wms"."shipment_item_addresses" to "authenticated";

grant select on table "mod_wms"."shipment_item_addresses" to "authenticated";

grant trigger on table "mod_wms"."shipment_item_addresses" to "authenticated";

grant truncate on table "mod_wms"."shipment_item_addresses" to "authenticated";

grant update on table "mod_wms"."shipment_item_addresses" to "authenticated";

grant delete on table "mod_wms"."shipment_item_addresses" to "service_role";

grant insert on table "mod_wms"."shipment_item_addresses" to "service_role";

grant references on table "mod_wms"."shipment_item_addresses" to "service_role";

grant select on table "mod_wms"."shipment_item_addresses" to "service_role";

grant trigger on table "mod_wms"."shipment_item_addresses" to "service_role";

grant truncate on table "mod_wms"."shipment_item_addresses" to "service_role";

grant update on table "mod_wms"."shipment_item_addresses" to "service_role";

grant delete on table "mod_wms"."shipment_items" to "anon";

grant insert on table "mod_wms"."shipment_items" to "anon";

grant references on table "mod_wms"."shipment_items" to "anon";

grant select on table "mod_wms"."shipment_items" to "anon";

grant trigger on table "mod_wms"."shipment_items" to "anon";

grant truncate on table "mod_wms"."shipment_items" to "anon";

grant update on table "mod_wms"."shipment_items" to "anon";

grant delete on table "mod_wms"."shipment_items" to "authenticated";

grant insert on table "mod_wms"."shipment_items" to "authenticated";

grant references on table "mod_wms"."shipment_items" to "authenticated";

grant select on table "mod_wms"."shipment_items" to "authenticated";

grant trigger on table "mod_wms"."shipment_items" to "authenticated";

grant truncate on table "mod_wms"."shipment_items" to "authenticated";

grant update on table "mod_wms"."shipment_items" to "authenticated";

grant delete on table "mod_wms"."shipment_items" to "service_role";

grant insert on table "mod_wms"."shipment_items" to "service_role";

grant references on table "mod_wms"."shipment_items" to "service_role";

grant select on table "mod_wms"."shipment_items" to "service_role";

grant trigger on table "mod_wms"."shipment_items" to "service_role";

grant truncate on table "mod_wms"."shipment_items" to "service_role";

grant update on table "mod_wms"."shipment_items" to "service_role";

grant delete on table "mod_wms"."shipment_pallets" to "anon";

grant insert on table "mod_wms"."shipment_pallets" to "anon";

grant references on table "mod_wms"."shipment_pallets" to "anon";

grant select on table "mod_wms"."shipment_pallets" to "anon";

grant trigger on table "mod_wms"."shipment_pallets" to "anon";

grant truncate on table "mod_wms"."shipment_pallets" to "anon";

grant update on table "mod_wms"."shipment_pallets" to "anon";

grant delete on table "mod_wms"."shipment_pallets" to "authenticated";

grant insert on table "mod_wms"."shipment_pallets" to "authenticated";

grant references on table "mod_wms"."shipment_pallets" to "authenticated";

grant select on table "mod_wms"."shipment_pallets" to "authenticated";

grant trigger on table "mod_wms"."shipment_pallets" to "authenticated";

grant truncate on table "mod_wms"."shipment_pallets" to "authenticated";

grant update on table "mod_wms"."shipment_pallets" to "authenticated";

grant delete on table "mod_wms"."shipment_pallets" to "service_role";

grant insert on table "mod_wms"."shipment_pallets" to "service_role";

grant references on table "mod_wms"."shipment_pallets" to "service_role";

grant select on table "mod_wms"."shipment_pallets" to "service_role";

grant trigger on table "mod_wms"."shipment_pallets" to "service_role";

grant truncate on table "mod_wms"."shipment_pallets" to "service_role";

grant update on table "mod_wms"."shipment_pallets" to "service_role";

grant delete on table "mod_wms"."shipment_sales_orders" to "anon";

grant insert on table "mod_wms"."shipment_sales_orders" to "anon";

grant references on table "mod_wms"."shipment_sales_orders" to "anon";

grant select on table "mod_wms"."shipment_sales_orders" to "anon";

grant trigger on table "mod_wms"."shipment_sales_orders" to "anon";

grant truncate on table "mod_wms"."shipment_sales_orders" to "anon";

grant update on table "mod_wms"."shipment_sales_orders" to "anon";

grant delete on table "mod_wms"."shipment_sales_orders" to "authenticated";

grant insert on table "mod_wms"."shipment_sales_orders" to "authenticated";

grant references on table "mod_wms"."shipment_sales_orders" to "authenticated";

grant select on table "mod_wms"."shipment_sales_orders" to "authenticated";

grant trigger on table "mod_wms"."shipment_sales_orders" to "authenticated";

grant truncate on table "mod_wms"."shipment_sales_orders" to "authenticated";

grant update on table "mod_wms"."shipment_sales_orders" to "authenticated";

grant delete on table "mod_wms"."shipment_sales_orders" to "service_role";

grant insert on table "mod_wms"."shipment_sales_orders" to "service_role";

grant references on table "mod_wms"."shipment_sales_orders" to "service_role";

grant select on table "mod_wms"."shipment_sales_orders" to "service_role";

grant trigger on table "mod_wms"."shipment_sales_orders" to "service_role";

grant truncate on table "mod_wms"."shipment_sales_orders" to "service_role";

grant update on table "mod_wms"."shipment_sales_orders" to "service_role";

grant delete on table "mod_wms"."shipment_standalone_items" to "anon";

grant insert on table "mod_wms"."shipment_standalone_items" to "anon";

grant references on table "mod_wms"."shipment_standalone_items" to "anon";

grant select on table "mod_wms"."shipment_standalone_items" to "anon";

grant trigger on table "mod_wms"."shipment_standalone_items" to "anon";

grant truncate on table "mod_wms"."shipment_standalone_items" to "anon";

grant update on table "mod_wms"."shipment_standalone_items" to "anon";

grant delete on table "mod_wms"."shipment_standalone_items" to "authenticated";

grant insert on table "mod_wms"."shipment_standalone_items" to "authenticated";

grant references on table "mod_wms"."shipment_standalone_items" to "authenticated";

grant select on table "mod_wms"."shipment_standalone_items" to "authenticated";

grant trigger on table "mod_wms"."shipment_standalone_items" to "authenticated";

grant truncate on table "mod_wms"."shipment_standalone_items" to "authenticated";

grant update on table "mod_wms"."shipment_standalone_items" to "authenticated";

grant delete on table "mod_wms"."shipment_standalone_items" to "service_role";

grant insert on table "mod_wms"."shipment_standalone_items" to "service_role";

grant references on table "mod_wms"."shipment_standalone_items" to "service_role";

grant select on table "mod_wms"."shipment_standalone_items" to "service_role";

grant trigger on table "mod_wms"."shipment_standalone_items" to "service_role";

grant truncate on table "mod_wms"."shipment_standalone_items" to "service_role";

grant update on table "mod_wms"."shipment_standalone_items" to "service_role";

grant delete on table "mod_wms"."shipments" to "anon";

grant insert on table "mod_wms"."shipments" to "anon";

grant references on table "mod_wms"."shipments" to "anon";

grant select on table "mod_wms"."shipments" to "anon";

grant trigger on table "mod_wms"."shipments" to "anon";

grant truncate on table "mod_wms"."shipments" to "anon";

grant update on table "mod_wms"."shipments" to "anon";

grant delete on table "mod_wms"."shipments" to "authenticated";

grant insert on table "mod_wms"."shipments" to "authenticated";

grant references on table "mod_wms"."shipments" to "authenticated";

grant select on table "mod_wms"."shipments" to "authenticated";

grant trigger on table "mod_wms"."shipments" to "authenticated";

grant truncate on table "mod_wms"."shipments" to "authenticated";

grant update on table "mod_wms"."shipments" to "authenticated";

grant delete on table "mod_wms"."shipments" to "service_role";

grant insert on table "mod_wms"."shipments" to "service_role";

grant references on table "mod_wms"."shipments" to "service_role";

grant select on table "mod_wms"."shipments" to "service_role";

grant trigger on table "mod_wms"."shipments" to "service_role";

grant truncate on table "mod_wms"."shipments" to "service_role";

grant update on table "mod_wms"."shipments" to "service_role";

grant delete on table "mod_wms"."stock_movements" to "anon";

grant insert on table "mod_wms"."stock_movements" to "anon";

grant references on table "mod_wms"."stock_movements" to "anon";

grant select on table "mod_wms"."stock_movements" to "anon";

grant trigger on table "mod_wms"."stock_movements" to "anon";

grant truncate on table "mod_wms"."stock_movements" to "anon";

grant update on table "mod_wms"."stock_movements" to "anon";

grant delete on table "mod_wms"."stock_movements" to "authenticated";

grant insert on table "mod_wms"."stock_movements" to "authenticated";

grant references on table "mod_wms"."stock_movements" to "authenticated";

grant select on table "mod_wms"."stock_movements" to "authenticated";

grant trigger on table "mod_wms"."stock_movements" to "authenticated";

grant truncate on table "mod_wms"."stock_movements" to "authenticated";

grant update on table "mod_wms"."stock_movements" to "authenticated";

grant delete on table "mod_wms"."stock_movements" to "service_role";

grant insert on table "mod_wms"."stock_movements" to "service_role";

grant references on table "mod_wms"."stock_movements" to "service_role";

grant select on table "mod_wms"."stock_movements" to "service_role";

grant trigger on table "mod_wms"."stock_movements" to "service_role";

grant truncate on table "mod_wms"."stock_movements" to "service_role";

grant update on table "mod_wms"."stock_movements" to "service_role";

grant delete on table "mod_wms"."warehouses" to "anon";

grant insert on table "mod_wms"."warehouses" to "anon";

grant references on table "mod_wms"."warehouses" to "anon";

grant select on table "mod_wms"."warehouses" to "anon";

grant trigger on table "mod_wms"."warehouses" to "anon";

grant truncate on table "mod_wms"."warehouses" to "anon";

grant update on table "mod_wms"."warehouses" to "anon";

grant delete on table "mod_wms"."warehouses" to "authenticated";

grant insert on table "mod_wms"."warehouses" to "authenticated";

grant references on table "mod_wms"."warehouses" to "authenticated";

grant select on table "mod_wms"."warehouses" to "authenticated";

grant trigger on table "mod_wms"."warehouses" to "authenticated";

grant truncate on table "mod_wms"."warehouses" to "authenticated";

grant update on table "mod_wms"."warehouses" to "authenticated";

grant delete on table "mod_wms"."warehouses" to "service_role";

grant insert on table "mod_wms"."warehouses" to "service_role";

grant references on table "mod_wms"."warehouses" to "service_role";

grant select on table "mod_wms"."warehouses" to "service_role";

grant trigger on table "mod_wms"."warehouses" to "service_role";

grant truncate on table "mod_wms"."warehouses" to "service_role";

grant update on table "mod_wms"."warehouses" to "service_role";


  create policy "Any authenticated user can read"
  on "mod_admin"."domain_modules"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "superAdmin can delete"
  on "mod_admin"."domain_modules"
  as permissive
  for delete
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "superAdmin can insert into"
  on "mod_admin"."domain_modules"
  as permissive
  for insert
  to public
with check ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "superAdmin can update"
  on "mod_admin"."domain_modules"
  as permissive
  for update
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Admins can delete from domain_users"
  on "mod_admin"."domain_users"
  as permissive
  for delete
  to public
using ((public.get_my_claim_text('role'::text) = ANY (ARRAY['admin'::text, 'superAdmin'::text])));



  create policy "Admins can insert into domain_users"
  on "mod_admin"."domain_users"
  as permissive
  for insert
  to public
with check ((public.get_my_claim_text('role'::text) = ANY (ARRAY['admin'::text, 'superAdmin'::text])));



  create policy "Admins can update domain_users"
  on "mod_admin"."domain_users"
  as permissive
  for update
  to public
using ((public.get_my_claim_text('role'::text) = ANY (ARRAY['admin'::text, 'superAdmin'::text])));



  create policy "Any authenticated user can read domain_users"
  on "mod_admin"."domain_users"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Admins can delete from domains"
  on "mod_admin"."domains"
  as permissive
  for delete
  to public
using ((public.get_my_claim_text('role'::text) = ANY (ARRAY['admin'::text, 'superAdmin'::text])));



  create policy "Admins can insert into domains"
  on "mod_admin"."domains"
  as permissive
  for insert
  to public
with check ((public.get_my_claim_text('role'::text) = ANY (ARRAY['admin'::text, 'superAdmin'::text])));



  create policy "Admins can update domains"
  on "mod_admin"."domains"
  as permissive
  for update
  to public
using ((public.get_my_claim_text('role'::text) = ANY (ARRAY['admin'::text, 'superAdmin'::text])));



  create policy "Any authenticated user can read domains"
  on "mod_admin"."domains"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert user profiles"
  on "mod_admin"."user_profiles"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "Authenticated users can select user profiles"
  on "mod_admin"."user_profiles"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Authenticated users can update user profiles"
  on "mod_admin"."user_profiles"
  as permissive
  for update
  to authenticated
using (true)
with check (true);



  create policy "Public 'user_profiles' are viewable by everyone."
  on "mod_admin"."user_profiles"
  as permissive
  for select
  to public
using (true);



  create policy "Administrators can see their domain and subdomain data"
  on "mod_base"."announcements"
  as permissive
  for all
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_base"."announcements"
  as permissive
  for all
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_base"."announcements"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_base"."announcements"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_base"."announcements"
  as permissive
  for all
  to public
using ((COALESCE(public.get_my_claim_text('role'::text), ''::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_base"."announcements"
  as permissive
  for all
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_base"."article_categories"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_base"."article_categories"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_base"."article_categories"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_base"."article_categories"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_base"."article_categories"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_base"."article_categories"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Authenticated users can insert data"
  on "mod_base"."articles"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can select all articles"
  on "mod_base"."articles"
  as permissive
  for select
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_base"."articles"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can delete data"
  on "mod_base"."bom_articles"
  as permissive
  for delete
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can insert data"
  on "mod_base"."bom_articles"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can select data"
  on "mod_base"."bom_articles"
  as permissive
  for select
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_base"."bom_articles"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can delete custom article attachments"
  on "mod_base"."custom_article_attachments"
  as permissive
  for delete
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "Authenticated users can insert custom article attachments"
  on "mod_base"."custom_article_attachments"
  as permissive
  for insert
  to public
with check ((auth.role() = 'authenticated'::text));



  create policy "Authenticated users can update custom article attachments"
  on "mod_base"."custom_article_attachments"
  as permissive
  for update
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "Authenticated users can view custom article attachments"
  on "mod_base"."custom_article_attachments"
  as permissive
  for select
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_base"."customer_addresses"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_base"."customer_addresses"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "SuperAdmins can see all data"
  on "mod_base"."customer_addresses"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can delete their own domain data"
  on "mod_base"."customer_addresses"
  as permissive
  for delete
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Users can insert addresses in their domain"
  on "mod_base"."customer_addresses"
  as permissive
  for insert
  to public
with check (((( SELECT auth.uid() AS uid) IS NOT NULL) AND ((domain_id IN ( SELECT domain_users.domain_id
   FROM mod_admin.domain_users
  WHERE (domain_users.user_id = auth.uid()))) OR (public.get_my_claim_text('role'::text) = ANY (ARRAY['admin'::text, 'superAdmin'::text])) OR (public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR ('*'::text = ANY (shared_with)))));



  create policy "Users can see their own domain data"
  on "mod_base"."customer_addresses"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Users can update addresses in their domain"
  on "mod_base"."customer_addresses"
  as permissive
  for update
  to public
using (((( SELECT auth.uid() AS uid) IS NOT NULL) AND ((domain_id IN ( SELECT domain_users.domain_id
   FROM mod_admin.domain_users
  WHERE (domain_users.user_id = auth.uid()))) OR (public.get_my_claim_text('role'::text) = ANY (ARRAY['admin'::text, 'superAdmin'::text])) OR (public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR ('*'::text = ANY (shared_with)))));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_base"."customers"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_base"."customers"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "SuperAdmins can see all data"
  on "mod_base"."customers"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can insert customers in their domain"
  on "mod_base"."customers"
  as permissive
  for insert
  to public
with check (((( SELECT auth.uid() AS uid) IS NOT NULL) AND ((domain_id IN ( SELECT domain_users.domain_id
   FROM mod_admin.domain_users
  WHERE (domain_users.user_id = auth.uid()))) OR (public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR ('*'::text = ANY (shared_with)))));



  create policy "Users can see their own domain data"
  on "mod_base"."customers"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Users can update customers in their domain"
  on "mod_base"."customers"
  as permissive
  for update
  to public
using (((( SELECT auth.uid() AS uid) IS NOT NULL) AND ((domain_id IN ( SELECT domain_users.domain_id
   FROM mod_admin.domain_users
  WHERE (domain_users.user_id = auth.uid()))) OR (public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR ('*'::text = ANY (shared_with)))));



  create policy "Users can view customers in their domain"
  on "mod_base"."customers"
  as permissive
  for select
  to public
using (((( SELECT auth.uid() AS uid) IS NOT NULL) AND ((domain_id IN ( SELECT domain_users.domain_id
   FROM mod_admin.domain_users
  WHERE (domain_users.user_id = auth.uid()))) OR (public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR ('*'::text = ANY (shared_with)) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_base"."departments"
  as permissive
  for all
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_base"."departments"
  as permissive
  for all
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_base"."departments"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_base"."departments"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_base"."departments"
  as permissive
  for all
  to public
using ((COALESCE(public.get_my_claim_text('role'::text), ''::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_base"."departments"
  as permissive
  for all
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_base"."employees"
  as permissive
  for all
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_base"."employees"
  as permissive
  for all
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can delete data"
  on "mod_base"."employees"
  as permissive
  for delete
  to authenticated
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert data"
  on "mod_base"."employees"
  as permissive
  for insert
  to authenticated
with check ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can read all employee records"
  on "mod_base"."employees"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Authenticated users can update data"
  on "mod_base"."employees"
  as permissive
  for update
  to authenticated
using ((auth.uid() IS NOT NULL))
with check ((auth.uid() IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_base"."employees"
  as permissive
  for all
  to public
using ((COALESCE(public.get_my_claim_text('role'::text), ''::text) = 'superAdmin'::text));



  create policy "Users can see their own employee data"
  on "mod_base"."employees"
  as permissive
  for all
  to public
using ((id = auth.uid()));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_base"."employees_departments"
  as permissive
  for all
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_base"."employees_departments"
  as permissive
  for all
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_base"."employees_departments"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_base"."employees_departments"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_base"."employees_departments"
  as permissive
  for all
  to public
using ((COALESCE(public.get_my_claim_text('role'::text), ''::text) = 'superAdmin'::text));



  create policy "Users can see their own department assignments"
  on "mod_base"."employees_departments"
  as permissive
  for all
  to public
using ((employee_id = auth.uid()));



  create policy "allow_delete_internal_sales_order_items"
  on "mod_base"."internal_sales_order_items"
  as permissive
  for delete
  to authenticated
using (true);



  create policy "allow_insert_internal_sales_order_items"
  on "mod_base"."internal_sales_order_items"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "allow_select_internal_sales_order_items"
  on "mod_base"."internal_sales_order_items"
  as permissive
  for select
  to authenticated
using (true);



  create policy "allow_update_internal_sales_order_items"
  on "mod_base"."internal_sales_order_items"
  as permissive
  for update
  to authenticated
using (true)
with check (true);



  create policy "allow_delete_internal_sales_orders"
  on "mod_base"."internal_sales_orders"
  as permissive
  for delete
  to authenticated
using (true);



  create policy "allow_insert_internal_sales_orders"
  on "mod_base"."internal_sales_orders"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "allow_select_internal_sales_orders"
  on "mod_base"."internal_sales_orders"
  as permissive
  for select
  to authenticated
using (true);



  create policy "allow_update_internal_sales_orders"
  on "mod_base"."internal_sales_orders"
  as permissive
  for update
  to authenticated
using (true)
with check (true);



  create policy "Users can manage their own profile"
  on "mod_base"."profiles"
  as permissive
  for all
  to public
using ((auth.uid() = id))
with check ((auth.uid() = id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_base"."purchase_order_items"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_base"."purchase_order_items"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_base"."purchase_order_items"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_base"."purchase_order_items"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_base"."purchase_order_items"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_base"."purchase_order_items"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_base"."purchase_orders"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_base"."purchase_orders"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_base"."purchase_orders"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_base"."purchase_orders"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_base"."purchase_orders"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_base"."purchase_orders"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Authenticated users can delete quality control"
  on "mod_base"."quality_control"
  as permissive
  for delete
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can insert quality control"
  on "mod_base"."quality_control"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can select all quality control"
  on "mod_base"."quality_control"
  as permissive
  for select
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update quality control"
  on "mod_base"."quality_control"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can delete quality control attachments"
  on "mod_base"."quality_control_attachments"
  as permissive
  for delete
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "Authenticated users can insert quality control attachments"
  on "mod_base"."quality_control_attachments"
  as permissive
  for insert
  to public
with check ((auth.role() = 'authenticated'::text));



  create policy "Authenticated users can update quality control attachments"
  on "mod_base"."quality_control_attachments"
  as permissive
  for update
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "Authenticated users can view quality control attachments"
  on "mod_base"."quality_control_attachments"
  as permissive
  for select
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "Users can access checklist results in their domain"
  on "mod_base"."quality_control_checklist_results"
  as permissive
  for all
  to public
using ((domain_id = ((auth.jwt() ->> 'domain_id'::text))::uuid));



  create policy "Authenticated users can delete quality control types"
  on "mod_base"."quality_control_types"
  as permissive
  for delete
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can insert quality control types"
  on "mod_base"."quality_control_types"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can select all quality control types"
  on "mod_base"."quality_control_types"
  as permissive
  for select
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update quality control types"
  on "mod_base"."quality_control_types"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_base"."report_template"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_base"."report_template"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can delete data"
  on "mod_base"."report_template"
  as permissive
  for delete
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can insert data"
  on "mod_base"."report_template"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_base"."report_template"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_base"."report_template"
  as permissive
  for select
  to public
using ((COALESCE(public.get_my_claim_text('role'::text), ''::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_base"."report_template"
  as permissive
  for all
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Authenticated users can delete all sales_order_items"
  on "mod_base"."sales_order_items"
  as permissive
  for delete
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can insert all sales_order_items"
  on "mod_base"."sales_order_items"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can select all sales_order_items"
  on "mod_base"."sales_order_items"
  as permissive
  for select
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update all sales_order_items"
  on "mod_base"."sales_order_items"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL))
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "allow_delete_sales_orders"
  on "mod_base"."sales_orders"
  as permissive
  for delete
  to authenticated
using (true);



  create policy "allow_insert_sales_orders"
  on "mod_base"."sales_orders"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "allow_select_sales_orders"
  on "mod_base"."sales_orders"
  as permissive
  for select
  to authenticated
using (true);



  create policy "allow_update_sales_orders"
  on "mod_base"."sales_orders"
  as permissive
  for update
  to authenticated
using (true)
with check (true);



  create policy "Authenticated users can insert data"
  on "mod_base"."serial_number_counters"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can select data"
  on "mod_base"."serial_number_counters"
  as permissive
  for select
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_base"."serial_number_counters"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_base"."suppliers"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_base"."suppliers"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_base"."suppliers"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_base"."suppliers"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_base"."suppliers"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_base"."suppliers"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_base"."units_of_measure"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_base"."units_of_measure"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_base"."units_of_measure"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_base"."units_of_measure"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_base"."units_of_measure"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_base"."units_of_measure"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Any authenticated user can read"
  on "mod_datalayer"."fields"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "superAdmin can delete"
  on "mod_datalayer"."fields"
  as permissive
  for delete
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "superAdmin can insert into"
  on "mod_datalayer"."fields"
  as permissive
  for insert
  to public
with check ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "superAdmin can update"
  on "mod_datalayer"."fields"
  as permissive
  for update
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Any authenticated user can read"
  on "mod_datalayer"."main_menu"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "superAdmin can delete"
  on "mod_datalayer"."main_menu"
  as permissive
  for delete
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "superAdmin can insert into"
  on "mod_datalayer"."main_menu"
  as permissive
  for insert
  to public
with check ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "superAdmin can update"
  on "mod_datalayer"."main_menu"
  as permissive
  for update
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Any authenticated user can read"
  on "mod_datalayer"."modules"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "superAdmin can delete"
  on "mod_datalayer"."modules"
  as permissive
  for delete
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "superAdmin can insert into"
  on "mod_datalayer"."modules"
  as permissive
  for insert
  to public
with check ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "superAdmin can update"
  on "mod_datalayer"."modules"
  as permissive
  for update
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Any authenticated user can read"
  on "mod_datalayer"."page_categories"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "superAdmin can delete"
  on "mod_datalayer"."page_categories"
  as permissive
  for delete
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "superAdmin can insert into"
  on "mod_datalayer"."page_categories"
  as permissive
  for insert
  to public
with check ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "superAdmin can update"
  on "mod_datalayer"."page_categories"
  as permissive
  for update
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Any authenticated user can read"
  on "mod_datalayer"."pages"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "superAdmin can delete"
  on "mod_datalayer"."pages"
  as permissive
  for delete
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "superAdmin can insert into"
  on "mod_datalayer"."pages"
  as permissive
  for insert
  to public
with check ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "superAdmin can update"
  on "mod_datalayer"."pages"
  as permissive
  for update
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Authenticated users can manage page assignments"
  on "mod_datalayer"."pages_departments"
  as permissive
  for all
  to authenticated
using (true)
with check (true);



  create policy "SuperAdmins can manage all data"
  on "mod_datalayer"."pages_departments"
  as permissive
  for all
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see page assignments for their departments"
  on "mod_datalayer"."pages_departments"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM mod_base.employees_departments ed
  WHERE ((ed.employee_id = auth.uid()) AND (ed.department_id = pages_departments.department_id) AND (ed.is_deleted = false)))));



  create policy "Users can see their own domain data"
  on "mod_datalayer"."pages_departments"
  as permissive
  for select
  to public
using (((is_deleted = false) AND (EXISTS ( SELECT 1
   FROM mod_base.departments d
  WHERE ((d.id = pages_departments.department_id) AND ((public.get_my_claim_text('domain_id'::text))::uuid = d.domain_id))))));



  create policy "Allow authenticated users to delete pages_menu_departments"
  on "mod_datalayer"."pages_menu_departments"
  as permissive
  for delete
  to authenticated
using (true);



  create policy "Allow authenticated users to insert pages_menu_departments"
  on "mod_datalayer"."pages_menu_departments"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "Allow authenticated users to select pages_menu_departments"
  on "mod_datalayer"."pages_menu_departments"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Allow authenticated users to update pages_menu_departments"
  on "mod_datalayer"."pages_menu_departments"
  as permissive
  for update
  to authenticated
using (true)
with check (true);



  create policy "Any authenticated user can read"
  on "mod_datalayer"."tables"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "superAdmin can delete"
  on "mod_datalayer"."tables"
  as permissive
  for delete
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "superAdmin can insert into"
  on "mod_datalayer"."tables"
  as permissive
  for insert
  to public
with check ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "superAdmin can update"
  on "mod_datalayer"."tables"
  as permissive
  for update
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can insert coil consumption in their domain"
  on "mod_manufacturing"."coil_consumption"
  as permissive
  for insert
  to public
with check ((domain_id = (( SELECT ((auth.jwt() -> 'app_metadata'::text) ->> 'domain_id'::text)))::uuid));



  create policy "Users can see their own domain coil consumption"
  on "mod_manufacturing"."coil_consumption"
  as permissive
  for select
  to public
using ((domain_id = (( SELECT ((auth.jwt() -> 'app_metadata'::text) ->> 'domain_id'::text)))::uuid));



  create policy "Users can update coil consumption in their domain"
  on "mod_manufacturing"."coil_consumption"
  as permissive
  for update
  to public
using ((domain_id = (( SELECT ((auth.jwt() -> 'app_metadata'::text) ->> 'domain_id'::text)))::uuid));



  create policy "Users can insert production plans in their domain"
  on "mod_manufacturing"."coil_production_plans"
  as permissive
  for insert
  to public
with check ((domain_id = (( SELECT ((auth.jwt() -> 'app_metadata'::text) ->> 'domain_id'::text)))::uuid));



  create policy "Users can see their own domain production plans"
  on "mod_manufacturing"."coil_production_plans"
  as permissive
  for select
  to public
using ((domain_id = (( SELECT ((auth.jwt() -> 'app_metadata'::text) ->> 'domain_id'::text)))::uuid));



  create policy "Users can update production plans in their domain"
  on "mod_manufacturing"."coil_production_plans"
  as permissive
  for update
  to public
using ((domain_id = (( SELECT ((auth.jwt() -> 'app_metadata'::text) ->> 'domain_id'::text)))::uuid));



  create policy "Users can insert coils in their domain"
  on "mod_manufacturing"."coils"
  as permissive
  for insert
  to public
with check ((domain_id = (( SELECT ((auth.jwt() -> 'app_metadata'::text) ->> 'domain_id'::text)))::uuid));



  create policy "Users can see their own domain coils"
  on "mod_manufacturing"."coils"
  as permissive
  for select
  to public
using ((domain_id = (( SELECT ((auth.jwt() -> 'app_metadata'::text) ->> 'domain_id'::text)))::uuid));



  create policy "Users can update coils in their domain"
  on "mod_manufacturing"."coils"
  as permissive
  for update
  to public
using ((domain_id = (( SELECT ((auth.jwt() -> 'app_metadata'::text) ->> 'domain_id'::text)))::uuid));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_manufacturing"."departments"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_manufacturing"."departments"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_manufacturing"."departments"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_manufacturing"."departments"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_manufacturing"."departments"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_manufacturing"."departments"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_manufacturing"."locations"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_manufacturing"."locations"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_manufacturing"."locations"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_manufacturing"."locations"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_manufacturing"."locations"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_manufacturing"."locations"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Users can insert plate templates in their domain"
  on "mod_manufacturing"."plate_templates"
  as permissive
  for insert
  to public
with check ((domain_id = (( SELECT ((auth.jwt() -> 'app_metadata'::text) ->> 'domain_id'::text)))::uuid));



  create policy "Users can see their own domain plate templates"
  on "mod_manufacturing"."plate_templates"
  as permissive
  for select
  to public
using ((domain_id = (( SELECT ((auth.jwt() -> 'app_metadata'::text) ->> 'domain_id'::text)))::uuid));



  create policy "Users can update plate templates in their domain"
  on "mod_manufacturing"."plate_templates"
  as permissive
  for update
  to public
using ((domain_id = (( SELECT ((auth.jwt() -> 'app_metadata'::text) ->> 'domain_id'::text)))::uuid));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_manufacturing"."production_logs"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_manufacturing"."production_logs"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_manufacturing"."production_logs"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_manufacturing"."production_logs"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_manufacturing"."production_logs"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_manufacturing"."production_logs"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_manufacturing"."recipes"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_manufacturing"."recipes"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can delete data"
  on "mod_manufacturing"."recipes"
  as permissive
  for delete
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can insert data"
  on "mod_manufacturing"."recipes"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_manufacturing"."recipes"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_manufacturing"."recipes"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_manufacturing"."recipes"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_manufacturing"."scheduled_items"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'administrator'::text) AND ((public.get_my_claim_text('domain_id'::text))::uuid = domain_id)));



  create policy "Allow shared data access for specific subdomains"
  on "mod_manufacturing"."scheduled_items"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'superadmin'::text) OR (domain_id = ANY ((public.get_my_claim_text('shared_domains'::text))::uuid[]))));



  create policy "Authenticated users can insert data"
  on "mod_manufacturing"."scheduled_items"
  as permissive
  for insert
  to public
with check (((auth.role() = 'authenticated'::text) AND ((public.get_my_claim_text('domain_id'::text))::uuid = domain_id)));



  create policy "Authenticated users can update data"
  on "mod_manufacturing"."scheduled_items"
  as permissive
  for update
  to public
using (((auth.role() = 'authenticated'::text) AND ((public.get_my_claim_text('domain_id'::text))::uuid = domain_id)));



  create policy "SuperAdmins can see all data"
  on "mod_manufacturing"."scheduled_items"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superadmin'::text));



  create policy "Users can see their own domain data"
  on "mod_manufacturing"."scheduled_items"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Enable delete for authenticated users"
  on "mod_manufacturing"."work_cycle_categories"
  as permissive
  for delete
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Enable insert for authenticated users"
  on "mod_manufacturing"."work_cycle_categories"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Enable read access for authenticated users"
  on "mod_manufacturing"."work_cycle_categories"
  as permissive
  for select
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "Enable update for authenticated users"
  on "mod_manufacturing"."work_cycle_categories"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Administrators can see domain work cycles"
  on "mod_manufacturing"."work_cycles"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid)) AND (is_deleted = false)));



  create policy "Authenticated users can insert data"
  on "mod_manufacturing"."work_cycles"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can insert work cycles"
  on "mod_manufacturing"."work_cycles"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_manufacturing"."work_cycles"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update work cycles"
  on "mod_manufacturing"."work_cycles"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all work cycles"
  on "mod_manufacturing"."work_cycles"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'superAdmin'::text) AND (is_deleted = false)));



  create policy "Users can see active work cycles"
  on "mod_manufacturing"."work_cycles"
  as permissive
  for select
  to public
using ((is_deleted = false));



  create policy "Users can see department shared work cycles"
  on "mod_manufacturing"."work_cycles"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND (is_deleted = false))));



  create policy "Enable insert for authenticated users"
  on "mod_manufacturing"."work_flows"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Enable read access for authenticated users"
  on "mod_manufacturing"."work_flows"
  as permissive
  for select
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "Enable update for authenticated users"
  on "mod_manufacturing"."work_flows"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Enable delete for authenticated users"
  on "mod_manufacturing"."work_flows_work_cycles"
  as permissive
  for delete
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Enable insert for authenticated users"
  on "mod_manufacturing"."work_flows_work_cycles"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Enable read access for authenticated users"
  on "mod_manufacturing"."work_flows_work_cycles"
  as permissive
  for select
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "Enable update for authenticated users"
  on "mod_manufacturing"."work_flows_work_cycles"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can delete work order attachments"
  on "mod_manufacturing"."work_order_attachments"
  as permissive
  for delete
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "Authenticated users can insert work order attachments"
  on "mod_manufacturing"."work_order_attachments"
  as permissive
  for insert
  to public
with check ((auth.role() = 'authenticated'::text));



  create policy "Authenticated users can update work order attachments"
  on "mod_manufacturing"."work_order_attachments"
  as permissive
  for update
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "Authenticated users can view work order attachments"
  on "mod_manufacturing"."work_order_attachments"
  as permissive
  for select
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_manufacturing"."work_order_quality_summary"
  as permissive
  for select
  to public
using (
CASE
    WHEN (public.get_my_claim_text('user_role'::text) = 'SuperAdmin'::text) THEN true
    WHEN (public.get_my_claim_text('user_role'::text) = 'Admin'::text) THEN ((domain_id = (public.get_my_claim_text('domain_id'::text))::uuid) OR (domain_id IN ( SELECT domains.id
       FROM mod_admin.domains
      WHERE (domains.parent_domain_id = (public.get_my_claim_text('domain_id'::text))::uuid))))
    ELSE (domain_id = (public.get_my_claim_text('domain_id'::text))::uuid)
END);



  create policy "Allow shared data access for specific subdomains"
  on "mod_manufacturing"."work_order_quality_summary"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = ANY ((shared_with)::uuid[])));



  create policy "Authenticated users can delete data"
  on "mod_manufacturing"."work_order_quality_summary"
  as permissive
  for update
  to authenticated
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id))
with check ((is_deleted = true));



  create policy "Authenticated users can insert data"
  on "mod_manufacturing"."work_order_quality_summary"
  as permissive
  for insert
  to authenticated
with check (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Authenticated users can update data"
  on "mod_manufacturing"."work_order_quality_summary"
  as permissive
  for update
  to authenticated
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id))
with check (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "SuperAdmins can see all data"
  on "mod_manufacturing"."work_order_quality_summary"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('user_role'::text) = 'SuperAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_manufacturing"."work_order_quality_summary"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see domain work orders"
  on "mod_manufacturing"."work_orders"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid)) AND (is_deleted = false)));



  create policy "Authenticated users can insert data"
  on "mod_manufacturing"."work_orders"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can insert work orders"
  on "mod_manufacturing"."work_orders"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can see domain work orders"
  on "mod_manufacturing"."work_orders"
  as permissive
  for select
  to public
using (((auth.uid() IS NOT NULL) AND ((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) AND (is_deleted = false)));



  create policy "Authenticated users can update data"
  on "mod_manufacturing"."work_orders"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update work orders"
  on "mod_manufacturing"."work_orders"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all work orders"
  on "mod_manufacturing"."work_orders"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'superAdmin'::text) AND (is_deleted = false)));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_manufacturing"."work_steps"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_manufacturing"."work_steps"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_manufacturing"."work_steps"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_manufacturing"."work_steps"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_manufacturing"."work_steps"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_manufacturing"."work_steps"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_manufacturing"."workstations"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_manufacturing"."workstations"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_manufacturing"."workstations"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_manufacturing"."workstations"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_manufacturing"."workstations"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_manufacturing"."workstations"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_pulse"."department_notification_configs"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can delete data"
  on "mod_pulse"."department_notification_configs"
  as permissive
  for delete
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can insert data"
  on "mod_pulse"."department_notification_configs"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_pulse"."department_notification_configs"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_pulse"."department_notification_configs"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_pulse"."department_notification_configs"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see domain notifications"
  on "mod_pulse"."notifications"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid)) AND (is_deleted = false)));



  create policy "Authenticated users can insert data"
  on "mod_pulse"."notifications"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_pulse"."notifications"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all notifications"
  on "mod_pulse"."notifications"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'superAdmin'::text) AND (is_deleted = false)));



  create policy "Users can see department shared notifications"
  on "mod_pulse"."notifications"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND (is_deleted = false))));



  create policy "Users can see notifications where they are mentioned"
  on "mod_pulse"."notifications"
  as permissive
  for select
  to public
using (false);



  create policy "Users can see their own notifications"
  on "mod_pulse"."notifications"
  as permissive
  for select
  to public
using (((user_id = auth.uid()) AND (is_deleted = false)));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_pulse"."pulse_chat"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_pulse"."pulse_chat"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_pulse"."pulse_chat"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_pulse"."pulse_chat"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_pulse"."pulse_chat"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_pulse"."pulse_chat"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_pulse"."pulse_chat_files"
  as permissive
  for all
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_pulse"."pulse_chat_files"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_pulse"."pulse_chat_files"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_pulse"."pulse_chat_files"
  as permissive
  for all
  to public
using ((COALESCE(public.get_my_claim_text('role'::text), ''::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_pulse"."pulse_chat_files"
  as permissive
  for all
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_pulse"."pulse_checklists"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_pulse"."pulse_checklists"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_pulse"."pulse_checklists"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_pulse"."pulse_checklists"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_pulse"."pulse_checklists"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_pulse"."pulse_checklists"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_pulse"."pulse_comments"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_pulse"."pulse_comments"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_pulse"."pulse_comments"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_pulse"."pulse_comments"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_pulse"."pulse_comments"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_pulse"."pulse_comments"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_pulse"."pulse_conversation_participants"
  as permissive
  for all
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_pulse"."pulse_conversation_participants"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_pulse"."pulse_conversation_participants"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_pulse"."pulse_conversation_participants"
  as permissive
  for all
  to public
using ((COALESCE(public.get_my_claim_text('role'::text), ''::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_pulse"."pulse_conversation_participants"
  as permissive
  for all
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_pulse"."pulse_progress"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_pulse"."pulse_progress"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_pulse"."pulse_progress"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_pulse"."pulse_progress"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_pulse"."pulse_progress"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_pulse"."pulse_progress"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_pulse"."pulse_slas"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_pulse"."pulse_slas"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_pulse"."pulse_slas"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_pulse"."pulse_slas"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_pulse"."pulse_slas"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_pulse"."pulse_slas"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_pulse"."pulses"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_pulse"."pulses"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_pulse"."pulses"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_pulse"."pulses"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_pulse"."pulses"
  as permissive
  for select
  to public
using ((COALESCE(public.get_my_claim_text('role'::text), ''::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_pulse"."pulses"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_pulse"."tasks"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_pulse"."tasks"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_pulse"."tasks"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_pulse"."tasks"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_pulse"."tasks"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_pulse"."tasks"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Authenticated users can insert"
  on "mod_quality_control"."conformity_documents"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Users can see data"
  on "mod_quality_control"."conformity_documents"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Users can update data"
  on "mod_quality_control"."conformity_documents"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert"
  on "mod_quality_control"."defect_types"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Users can see data"
  on "mod_quality_control"."defect_types"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Users can update data"
  on "mod_quality_control"."defect_types"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert"
  on "mod_quality_control"."measurement_parameters"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Users can see data"
  on "mod_quality_control"."measurement_parameters"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Users can update data"
  on "mod_quality_control"."measurement_parameters"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert"
  on "mod_quality_control"."quality_control_checklist_results"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Users can see data"
  on "mod_quality_control"."quality_control_checklist_results"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Users can update data"
  on "mod_quality_control"."quality_control_checklist_results"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert"
  on "mod_quality_control"."quality_control_defects"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Users can see data"
  on "mod_quality_control"."quality_control_defects"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Users can update data"
  on "mod_quality_control"."quality_control_defects"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert"
  on "mod_quality_control"."quality_control_measurements"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Users can see data"
  on "mod_quality_control"."quality_control_measurements"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Users can update data"
  on "mod_quality_control"."quality_control_measurements"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert"
  on "mod_quality_control"."supplier_returns"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Users can see data"
  on "mod_quality_control"."supplier_returns"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Users can update data"
  on "mod_quality_control"."supplier_returns"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can delete batches"
  on "mod_wms"."batches"
  as permissive
  for delete
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can insert batches"
  on "mod_wms"."batches"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can select all batches"
  on "mod_wms"."batches"
  as permissive
  for select
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update batches"
  on "mod_wms"."batches"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Administrators can view box contents in their domain and subdom"
  on "mod_wms"."box_contents"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can delete box contents"
  on "mod_wms"."box_contents"
  as permissive
  for delete
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert box contents"
  on "mod_wms"."box_contents"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can update box contents"
  on "mod_wms"."box_contents"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "SuperAdmins can view all box contents"
  on "mod_wms"."box_contents"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can view box contents in their domain"
  on "mod_wms"."box_contents"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can view box types in their domain and subdomain"
  on "mod_wms"."box_types"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can delete box types"
  on "mod_wms"."box_types"
  as permissive
  for delete
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert box types"
  on "mod_wms"."box_types"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can update box types"
  on "mod_wms"."box_types"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "SuperAdmins can view all box types"
  on "mod_wms"."box_types"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can view box types in their domain"
  on "mod_wms"."box_types"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can view carton contents in their domain and sub"
  on "mod_wms"."carton_contents"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can delete carton contents"
  on "mod_wms"."carton_contents"
  as permissive
  for delete
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert carton contents"
  on "mod_wms"."carton_contents"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can update carton contents"
  on "mod_wms"."carton_contents"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "SuperAdmins can view all carton contents"
  on "mod_wms"."carton_contents"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can view carton contents in their domain"
  on "mod_wms"."carton_contents"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can view carton types in their domain and subdom"
  on "mod_wms"."carton_types"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can delete carton types"
  on "mod_wms"."carton_types"
  as permissive
  for delete
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert carton types"
  on "mod_wms"."carton_types"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can update carton types"
  on "mod_wms"."carton_types"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "SuperAdmins can view all carton types"
  on "mod_wms"."carton_types"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can view carton types in their domain"
  on "mod_wms"."carton_types"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Authenticated users can insert data"
  on "mod_wms"."inventory"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can select all inventory"
  on "mod_wms"."inventory"
  as permissive
  for select
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_wms"."inventory"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_wms"."inventory_backup"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_wms"."inventory_backup"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_wms"."inventory_backup"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_wms"."inventory_backup"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_wms"."inventory_backup"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_wms"."inventory_backup"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_wms"."inventory_limits"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_wms"."inventory_limits"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_wms"."inventory_limits"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_wms"."inventory_limits"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_wms"."inventory_limits"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_wms"."inventory_limits"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Authenticated users can insert data"
  on "mod_wms"."locations"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can select all locations"
  on "mod_wms"."locations"
  as permissive
  for select
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_wms"."locations"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Administrators can view pallet contents in their domain and sub"
  on "mod_wms"."pallet_contents"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can delete pallet contents"
  on "mod_wms"."pallet_contents"
  as permissive
  for delete
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert pallet contents"
  on "mod_wms"."pallet_contents"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can update pallet contents"
  on "mod_wms"."pallet_contents"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "SuperAdmins can view all pallet contents"
  on "mod_wms"."pallet_contents"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can view pallet contents in their domain"
  on "mod_wms"."pallet_contents"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can view pallet types in their domain and subdom"
  on "mod_wms"."pallet_types"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can delete pallet types"
  on "mod_wms"."pallet_types"
  as permissive
  for delete
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert pallet types"
  on "mod_wms"."pallet_types"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can update pallet types"
  on "mod_wms"."pallet_types"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "SuperAdmins can view all pallet types"
  on "mod_wms"."pallet_types"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can view pallet types in their domain"
  on "mod_wms"."pallet_types"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_wms"."receipt_items"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_wms"."receipt_items"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_wms"."receipt_items"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_wms"."receipt_items"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_wms"."receipt_items"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_wms"."receipt_items"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Authenticated users can delete receipts"
  on "mod_wms"."receipts"
  as permissive
  for delete
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can insert receipts"
  on "mod_wms"."receipts"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can select all receipts"
  on "mod_wms"."receipts"
  as permissive
  for select
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update receipts"
  on "mod_wms"."receipts"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can delete shipment attachments"
  on "mod_wms"."shipment_attachments"
  as permissive
  for delete
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "Authenticated users can insert shipment attachments"
  on "mod_wms"."shipment_attachments"
  as permissive
  for insert
  to public
with check ((auth.role() = 'authenticated'::text));



  create policy "Authenticated users can update shipment attachments"
  on "mod_wms"."shipment_attachments"
  as permissive
  for update
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "Authenticated users can view shipment attachments"
  on "mod_wms"."shipment_attachments"
  as permissive
  for select
  to public
using ((auth.role() = 'authenticated'::text));



  create policy "Administrators can view shipment boxes in their domain and subd"
  on "mod_wms"."shipment_boxes"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can delete shipment boxes"
  on "mod_wms"."shipment_boxes"
  as permissive
  for delete
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert shipment boxes"
  on "mod_wms"."shipment_boxes"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can update shipment boxes"
  on "mod_wms"."shipment_boxes"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "SuperAdmins can view all shipment boxes"
  on "mod_wms"."shipment_boxes"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can view shipment boxes in their domain"
  on "mod_wms"."shipment_boxes"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can view shipment cartons in their domain and su"
  on "mod_wms"."shipment_cartons"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can delete shipment cartons"
  on "mod_wms"."shipment_cartons"
  as permissive
  for delete
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert shipment cartons"
  on "mod_wms"."shipment_cartons"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can update shipment cartons"
  on "mod_wms"."shipment_cartons"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "SuperAdmins can view all shipment cartons"
  on "mod_wms"."shipment_cartons"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can view shipment cartons in their domain"
  on "mod_wms"."shipment_cartons"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Allow authenticated users"
  on "mod_wms"."shipment_item_addresses"
  as permissive
  for all
  to authenticated
using ((domain_id IN ( SELECT domain_users.domain_id
   FROM mod_admin.domain_users
  WHERE (domain_users.user_id = auth.uid()))))
with check ((domain_id IN ( SELECT domain_users.domain_id
   FROM mod_admin.domain_users
  WHERE (domain_users.user_id = auth.uid()))));



  create policy "Allow users to create addresses in their domain"
  on "mod_wms"."shipment_item_addresses"
  as permissive
  for insert
  to authenticated
with check ((domain_id IN ( SELECT domain_users.domain_id
   FROM mod_admin.domain_users
  WHERE (domain_users.user_id = auth.uid()))));



  create policy "Allow users to delete addresses in their domain"
  on "mod_wms"."shipment_item_addresses"
  as permissive
  for delete
  to authenticated
using ((domain_id IN ( SELECT domain_users.domain_id
   FROM mod_admin.domain_users
  WHERE (domain_users.user_id = auth.uid()))));



  create policy "Allow users to update addresses in their domain"
  on "mod_wms"."shipment_item_addresses"
  as permissive
  for update
  to authenticated
using ((domain_id IN ( SELECT domain_users.domain_id
   FROM mod_admin.domain_users
  WHERE (domain_users.user_id = auth.uid()))))
with check ((domain_id IN ( SELECT domain_users.domain_id
   FROM mod_admin.domain_users
  WHERE (domain_users.user_id = auth.uid()))));



  create policy "Allow users to view addresses in their domain"
  on "mod_wms"."shipment_item_addresses"
  as permissive
  for select
  to authenticated
using ((domain_id IN ( SELECT domain_users.domain_id
   FROM mod_admin.domain_users
  WHERE (domain_users.user_id = auth.uid()))));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_wms"."shipment_items"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_wms"."shipment_items"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_wms"."shipment_items"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_wms"."shipment_items"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_wms"."shipment_items"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_wms"."shipment_items"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can view shipment pallets in their domain and su"
  on "mod_wms"."shipment_pallets"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can delete shipment pallets"
  on "mod_wms"."shipment_pallets"
  as permissive
  for delete
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert shipment pallets"
  on "mod_wms"."shipment_pallets"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can update shipment pallets"
  on "mod_wms"."shipment_pallets"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "SuperAdmins can view all shipment pallets"
  on "mod_wms"."shipment_pallets"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can view shipment pallets in their domain"
  on "mod_wms"."shipment_pallets"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Authenticated users can delete shipment sales orders"
  on "mod_wms"."shipment_sales_orders"
  as permissive
  for delete
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert shipment sales orders"
  on "mod_wms"."shipment_sales_orders"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can update shipment sales orders"
  on "mod_wms"."shipment_sales_orders"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL))
with check ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can view shipment sales orders"
  on "mod_wms"."shipment_sales_orders"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Administrators can view shipment standalone items in their doma"
  on "mod_wms"."shipment_standalone_items"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can delete shipment standalone items"
  on "mod_wms"."shipment_standalone_items"
  as permissive
  for delete
  to public
using ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can insert shipment standalone items"
  on "mod_wms"."shipment_standalone_items"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "Authenticated users can update shipment standalone items"
  on "mod_wms"."shipment_standalone_items"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "SuperAdmins can view all shipment standalone items"
  on "mod_wms"."shipment_standalone_items"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can view shipment standalone items in their domain"
  on "mod_wms"."shipment_standalone_items"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Administrators can see their domain and subdomain data"
  on "mod_wms"."shipments"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Allow shared data access for specific subdomains"
  on "mod_wms"."shipments"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



  create policy "Authenticated users can insert data"
  on "mod_wms"."shipments"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_wms"."shipments"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "SuperAdmins can see all data"
  on "mod_wms"."shipments"
  as permissive
  for select
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_wms"."shipments"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id));



  create policy "Authenticated users can delete stock movements"
  on "mod_wms"."stock_movements"
  as permissive
  for delete
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can insert stock movements"
  on "mod_wms"."stock_movements"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can select all stock movements"
  on "mod_wms"."stock_movements"
  as permissive
  for select
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update stock movements"
  on "mod_wms"."stock_movements"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can insert data"
  on "mod_wms"."warehouses"
  as permissive
  for insert
  to public
with check ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can select all warehouses"
  on "mod_wms"."warehouses"
  as permissive
  for select
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));



  create policy "Authenticated users can update data"
  on "mod_wms"."warehouses"
  as permissive
  for update
  to public
using ((( SELECT auth.uid() AS uid) IS NOT NULL));


CREATE TRIGGER domain_modules_insert_audit BEFORE INSERT ON mod_admin.domain_modules FOR EACH ROW EXECUTE FUNCTION mod_admin.handle_domain_modules_audit();

CREATE TRIGGER domain_modules_update_audit BEFORE UPDATE ON mod_admin.domain_modules FOR EACH ROW EXECUTE FUNCTION mod_admin.handle_domain_modules_audit();

CREATE TRIGGER domain_users_insert_audit BEFORE INSERT ON mod_admin.domain_users FOR EACH ROW EXECUTE FUNCTION mod_admin.handle_domain_users_audit();

CREATE TRIGGER domain_users_update_audit BEFORE UPDATE ON mod_admin.domain_users FOR EACH ROW EXECUTE FUNCTION mod_admin.handle_domain_users_audit();

CREATE TRIGGER before_domains_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_admin.domains FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER domains_insert_audit BEFORE INSERT ON mod_admin.domains FOR EACH ROW EXECUTE FUNCTION mod_admin.handle_domains_audit();

CREATE TRIGGER domains_update_audit BEFORE UPDATE ON mod_admin.domains FOR EACH ROW EXECUTE FUNCTION mod_admin.handle_domains_audit();

CREATE TRIGGER set_domains_code BEFORE INSERT ON mod_admin.domains FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER before_background_image_changes BEFORE DELETE OR UPDATE OF background_image_url ON mod_admin.user_profiles FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_background_image();

CREATE TRIGGER before_profile_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_admin.user_profiles FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER set_user_profiles_code BEFORE INSERT ON mod_admin.user_profiles FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER user_profiles_insert_audit BEFORE INSERT ON mod_admin.user_profiles FOR EACH ROW EXECUTE FUNCTION mod_admin.handle_userprofile_audit();

CREATE TRIGGER user_profiles_update_audit BEFORE UPDATE ON mod_admin.user_profiles FOR EACH ROW EXECUTE FUNCTION mod_admin.handle_userprofile_audit();

CREATE TRIGGER announcements_insert_audit BEFORE INSERT ON mod_base.announcements FOR EACH ROW EXECUTE FUNCTION mod_base.handle_announcements_audit();

CREATE TRIGGER announcements_update_audit BEFORE UPDATE ON mod_base.announcements FOR EACH ROW EXECUTE FUNCTION mod_base.handle_announcements_audit();

CREATE TRIGGER before_announcements_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_base.announcements FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER article_categories_insert_audit BEFORE INSERT ON mod_base.article_categories FOR EACH ROW EXECUTE FUNCTION mod_base.handle_article_categories_audit();

CREATE TRIGGER article_categories_update_audit BEFORE UPDATE ON mod_base.article_categories FOR EACH ROW EXECUTE FUNCTION mod_base.handle_article_categories_audit();

CREATE TRIGGER before_article_categories_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_base.article_categories FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER set_article_categories_code BEFORE INSERT ON mod_base.article_categories FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER articles_insert_audit BEFORE INSERT ON mod_base.articles FOR EACH ROW EXECUTE FUNCTION mod_base.handle_articles_audit();

CREATE TRIGGER articles_update_audit BEFORE UPDATE ON mod_base.articles FOR EACH ROW EXECUTE FUNCTION mod_base.handle_articles_audit();

CREATE TRIGGER before_articles_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_base.articles FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER set_articles_code BEFORE INSERT ON mod_base.articles FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER trigger_update_bom_articles_updated_at BEFORE UPDATE ON mod_base.bom_articles FOR EACH ROW EXECUTE FUNCTION mod_base.update_bom_articles_updated_at();

CREATE TRIGGER customer_addresses_insert_audit BEFORE INSERT ON mod_base.customer_addresses FOR EACH ROW EXECUTE FUNCTION mod_base.handle_customer_addresses_audit();

CREATE TRIGGER customer_addresses_update_audit BEFORE UPDATE ON mod_base.customer_addresses FOR EACH ROW EXECUTE FUNCTION mod_base.handle_customer_addresses_audit();

CREATE TRIGGER ensure_single_primary_address_trigger BEFORE INSERT OR UPDATE ON mod_base.customer_addresses FOR EACH ROW EXECUTE FUNCTION mod_base.ensure_single_primary_address();

CREATE TRIGGER customers_insert_audit BEFORE INSERT ON mod_base.customers FOR EACH ROW EXECUTE FUNCTION mod_base.handle_customers_audit();

CREATE TRIGGER customers_update_audit BEFORE UPDATE ON mod_base.customers FOR EACH ROW EXECUTE FUNCTION mod_base.handle_customers_audit();

CREATE TRIGGER set_customers_code BEFORE INSERT ON mod_base.customers FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER before_departments_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_base.departments FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER departments_insert_audit BEFORE INSERT ON mod_base.departments FOR EACH ROW EXECUTE FUNCTION mod_base.handle_departments_audit();

CREATE TRIGGER departments_update_audit BEFORE UPDATE ON mod_base.departments FOR EACH ROW EXECUTE FUNCTION mod_base.handle_departments_audit();

CREATE TRIGGER set_departments_code BEFORE INSERT ON mod_base.departments FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER before_employees_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_base.employees FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER employees_insert_audit BEFORE INSERT ON mod_base.employees FOR EACH ROW EXECUTE FUNCTION mod_base.handle_employees_audit();

CREATE TRIGGER employees_update_audit BEFORE UPDATE ON mod_base.employees FOR EACH ROW EXECUTE FUNCTION mod_base.handle_employees_audit();

CREATE TRIGGER fill_employee_fields AFTER INSERT ON mod_base.employees FOR EACH ROW EXECUTE FUNCTION mod_base.handle_new_employee();

CREATE TRIGGER set_employees_code BEFORE INSERT ON mod_base.employees FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER employees_departments_insert_audit BEFORE INSERT ON mod_base.employees_departments FOR EACH ROW EXECUTE FUNCTION mod_base.handle_employees_departments_audit();

CREATE TRIGGER employees_departments_update_audit BEFORE UPDATE ON mod_base.employees_departments FOR EACH ROW EXECUTE FUNCTION mod_base.handle_employees_departments_audit();

CREATE TRIGGER before_internal_sales_order_items_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_base.internal_sales_order_items FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER internal_sales_order_completion_trigger AFTER UPDATE OF is_manufactured ON mod_base.internal_sales_order_items FOR EACH ROW EXECUTE FUNCTION mod_base.handle_internal_sales_order_completion_on_manufacturing();

CREATE TRIGGER internal_sales_order_items_insert_audit BEFORE INSERT ON mod_base.internal_sales_order_items FOR EACH ROW EXECUTE FUNCTION mod_base.handle_sales_order_items_audit();

CREATE TRIGGER internal_sales_order_items_production_date_cleanup_trigger AFTER UPDATE OF production_date ON mod_base.internal_sales_order_items FOR EACH ROW EXECUTE FUNCTION mod_base.cleanup_work_orders_on_internal_unschedule();

CREATE TRIGGER internal_sales_order_items_production_date_notification_trigger AFTER UPDATE OF production_date ON mod_base.internal_sales_order_items FOR EACH ROW EXECUTE FUNCTION mod_base.internal_sales_order_items_production_date_notification();

CREATE TRIGGER internal_sales_order_items_scheduling_notification_for_fabrizio AFTER UPDATE OF production_date ON mod_base.internal_sales_order_items FOR EACH ROW EXECUTE FUNCTION mod_base.internal_sales_order_items_scheduling_notification_for_fabrizio();

CREATE TRIGGER internal_sales_order_items_update_audit BEFORE UPDATE ON mod_base.internal_sales_order_items FOR EACH ROW EXECUTE FUNCTION mod_base.handle_sales_order_items_audit();

CREATE TRIGGER set_internal_sales_order_items_code BEFORE INSERT ON mod_base.internal_sales_order_items FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER trigger_update_expected_delivery_date_internal AFTER INSERT OR UPDATE OF production_date ON mod_base.internal_sales_order_items FOR EACH ROW EXECUTE FUNCTION public.update_expected_delivery_date();

CREATE TRIGGER before_internal_sales_orders_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_base.internal_sales_orders FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER create_pulse_for_internal_sales_orders BEFORE INSERT ON mod_base.internal_sales_orders FOR EACH ROW EXECUTE FUNCTION mod_pulse.create_pulse_for_record();

CREATE TRIGGER handle_internal_sales_orders_deletion AFTER DELETE ON mod_base.internal_sales_orders FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_record_deletion();

CREATE TRIGGER internal_sales_order_insert_trigger AFTER INSERT ON mod_base.internal_sales_orders FOR EACH ROW EXECUTE FUNCTION mod_base.direct_alert_new_sales_order();

CREATE TRIGGER internal_sales_order_status_notification_trigger AFTER UPDATE OF status ON mod_base.internal_sales_orders FOR EACH ROW EXECUTE FUNCTION mod_base.sales_order_status_notification();

CREATE TRIGGER internal_sales_orders_insert_audit BEFORE INSERT ON mod_base.internal_sales_orders FOR EACH ROW EXECUTE FUNCTION mod_base.handle_sales_orders_audit();

CREATE TRIGGER internal_sales_orders_update_audit BEFORE UPDATE ON mod_base.internal_sales_orders FOR EACH ROW EXECUTE FUNCTION mod_base.handle_sales_orders_audit();

CREATE TRIGGER set_internal_sales_orders_code BEFORE INSERT ON mod_base.internal_sales_orders FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER update_pulse_status_for_internal_sales_orders AFTER UPDATE OF status ON mod_base.internal_sales_orders FOR EACH ROW EXECUTE FUNCTION mod_pulse.update_pulse_status();

CREATE TRIGGER profiles_audit_trigger BEFORE INSERT OR UPDATE ON mod_base.profiles FOR EACH ROW EXECUTE FUNCTION mod_base.handle_profiles_audit();

CREATE TRIGGER before_purchase_order_items_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_base.purchase_order_items FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER purchase_order_items_insert_audit BEFORE INSERT ON mod_base.purchase_order_items FOR EACH ROW EXECUTE FUNCTION mod_base.handle_purchase_order_items_audit();

CREATE TRIGGER purchase_order_items_update_audit BEFORE UPDATE ON mod_base.purchase_order_items FOR EACH ROW EXECUTE FUNCTION mod_base.handle_purchase_order_items_audit();

CREATE TRIGGER set_purchase_order_items_code BEFORE INSERT ON mod_base.purchase_order_items FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER update_purchase_order_item_completion BEFORE INSERT OR UPDATE OF quantity_received ON mod_base.purchase_order_items FOR EACH ROW EXECUTE FUNCTION mod_base.update_purchase_order_item_completion();

CREATE TRIGGER before_purchase_orders_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_base.purchase_orders FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER create_pulse_for_purchase_orders BEFORE INSERT ON mod_base.purchase_orders FOR EACH ROW EXECUTE FUNCTION mod_pulse.create_pulse_for_record();

CREATE TRIGGER handle_purchase_orders_deletion AFTER DELETE ON mod_base.purchase_orders FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_record_deletion();

CREATE TRIGGER purchase_orders_insert_audit BEFORE INSERT ON mod_base.purchase_orders FOR EACH ROW EXECUTE FUNCTION mod_base.handle_purchase_orders_audit();

CREATE TRIGGER purchase_orders_update_audit BEFORE UPDATE ON mod_base.purchase_orders FOR EACH ROW EXECUTE FUNCTION mod_base.handle_purchase_orders_audit();

CREATE TRIGGER set_purchase_orders_code BEFORE INSERT ON mod_base.purchase_orders FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER update_pulse_status_for_purchase_orders AFTER UPDATE OF status ON mod_base.purchase_orders FOR EACH ROW EXECUTE FUNCTION mod_pulse.update_pulse_status();

CREATE TRIGGER before_quality_control_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_base.quality_control FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER quality_control_failed_trigger AFTER UPDATE ON mod_base.quality_control FOR EACH ROW EXECUTE FUNCTION mod_base.alert_quality_control_failed();

CREATE TRIGGER quality_control_insert_audit BEFORE INSERT ON mod_base.quality_control FOR EACH ROW EXECUTE FUNCTION mod_base.handle_quality_control_audit();

CREATE TRIGGER quality_control_update_audit BEFORE UPDATE ON mod_base.quality_control FOR EACH ROW EXECUTE FUNCTION mod_base.handle_quality_control_audit();

CREATE TRIGGER trigger_update_quality_control_checklist_results_updated_at BEFORE UPDATE ON mod_base.quality_control_checklist_results FOR EACH ROW EXECUTE FUNCTION mod_base.update_quality_control_checklist_results_updated_at();

CREATE TRIGGER quality_control_types_audit BEFORE INSERT OR UPDATE ON mod_base.quality_control_types FOR EACH ROW EXECUTE FUNCTION mod_base.handle_quality_control_types_audit();

CREATE TRIGGER before_sales_order_items_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_base.sales_order_items FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER sales_order_items_insert_audit BEFORE INSERT ON mod_base.sales_order_items FOR EACH ROW EXECUTE FUNCTION mod_base.handle_sales_order_items_audit();

CREATE TRIGGER sales_order_items_production_date_cleanup_trigger AFTER UPDATE OF production_date ON mod_base.sales_order_items FOR EACH ROW EXECUTE FUNCTION mod_base.cleanup_work_orders_on_unschedule();

CREATE TRIGGER sales_order_items_production_date_notification_trigger AFTER UPDATE OF production_date ON mod_base.sales_order_items FOR EACH ROW EXECUTE FUNCTION mod_base.sales_order_items_production_date_notification();

CREATE TRIGGER sales_order_items_scheduling_notification_for_fabrizio_trigger AFTER UPDATE OF production_date ON mod_base.sales_order_items FOR EACH ROW EXECUTE FUNCTION mod_base.sales_order_items_scheduling_notification_for_fabrizio();

CREATE TRIGGER sales_order_items_update_audit BEFORE UPDATE ON mod_base.sales_order_items FOR EACH ROW EXECUTE FUNCTION mod_base.handle_sales_order_items_audit();

CREATE TRIGGER set_sales_order_items_code BEFORE INSERT ON mod_base.sales_order_items FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER trigger_generate_serial_number_for_sales_order_item AFTER INSERT ON mod_base.sales_order_items FOR EACH ROW EXECUTE FUNCTION mod_base.generate_serial_number_for_sales_order_item();

CREATE TRIGGER trigger_update_expected_delivery_date AFTER INSERT OR UPDATE OF production_date ON mod_base.sales_order_items FOR EACH ROW EXECUTE FUNCTION public.update_expected_delivery_date();

CREATE TRIGGER trigger_update_sales_order_status_on_all_items_shipped AFTER UPDATE OF is_shipped ON mod_base.sales_order_items FOR EACH ROW WHEN (((new.is_shipped = true) AND ((old.is_shipped IS NULL) OR (old.is_shipped = false)))) EXECUTE FUNCTION mod_base.handle_update_sales_order_status_on_all_items_shipped();

CREATE TRIGGER before_sales_orders_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_base.sales_orders FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER create_pulse_for_sales_orders BEFORE INSERT ON mod_base.sales_orders FOR EACH ROW EXECUTE FUNCTION mod_pulse.create_pulse_for_record();

CREATE TRIGGER generate_sales_order_number_trigger BEFORE INSERT ON mod_base.sales_orders FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_sales_order_number_trigger();

CREATE TRIGGER handle_sales_orders_deletion AFTER DELETE ON mod_base.sales_orders FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_record_deletion();

CREATE TRIGGER sales_order_insert_trigger AFTER INSERT ON mod_base.sales_orders FOR EACH ROW EXECUTE FUNCTION mod_base.direct_alert_new_sales_order();

CREATE TRIGGER sales_order_status_notification_trigger AFTER UPDATE OF status ON mod_base.sales_orders FOR EACH ROW EXECUTE FUNCTION mod_base.sales_order_status_notification();

CREATE TRIGGER sales_orders_insert_audit BEFORE INSERT ON mod_base.sales_orders FOR EACH ROW EXECUTE FUNCTION mod_base.handle_sales_orders_audit();

CREATE TRIGGER sales_orders_update_audit BEFORE UPDATE ON mod_base.sales_orders FOR EACH ROW EXECUTE FUNCTION mod_base.handle_sales_orders_audit();

CREATE TRIGGER set_sales_orders_code BEFORE INSERT ON mod_base.sales_orders FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER trigger_archive_sales_order_on_status_completed AFTER UPDATE OF status ON mod_base.sales_orders FOR EACH ROW WHEN (((new.status = 'completed'::text) AND (old.status IS DISTINCT FROM 'completed'::text))) EXECUTE FUNCTION mod_base.handle_archive_sales_order_on_status_completed();

CREATE TRIGGER update_pulse_status_for_sales_orders AFTER UPDATE OF status ON mod_base.sales_orders FOR EACH ROW EXECUTE FUNCTION mod_pulse.update_pulse_status();

CREATE TRIGGER serial_number_counters_insert_audit BEFORE INSERT ON mod_base.serial_number_counters FOR EACH ROW EXECUTE FUNCTION mod_base.handle_serial_number_counters_audit();

CREATE TRIGGER serial_number_counters_update_audit BEFORE UPDATE ON mod_base.serial_number_counters FOR EACH ROW EXECUTE FUNCTION mod_base.handle_serial_number_counters_audit();

CREATE TRIGGER set_suppliers_code BEFORE INSERT ON mod_base.suppliers FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER suppliers_insert_audit BEFORE INSERT ON mod_base.suppliers FOR EACH ROW EXECUTE FUNCTION mod_base.handle_suppliers_audit();

CREATE TRIGGER suppliers_update_audit BEFORE UPDATE ON mod_base.suppliers FOR EACH ROW EXECUTE FUNCTION mod_base.handle_suppliers_audit();

CREATE TRIGGER before_units_of_measure_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_base.units_of_measure FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER set_units_of_measure_code BEFORE INSERT ON mod_base.units_of_measure FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER units_of_measure_insert_audit BEFORE INSERT ON mod_base.units_of_measure FOR EACH ROW EXECUTE FUNCTION mod_base.handle_units_of_measure_audit();

CREATE TRIGGER units_of_measure_update_audit BEFORE UPDATE ON mod_base.units_of_measure FOR EACH ROW EXECUTE FUNCTION mod_base.handle_units_of_measure_audit();

CREATE TRIGGER before_fields_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_datalayer.fields FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER fields_insert_audit BEFORE INSERT ON mod_datalayer.fields FOR EACH ROW EXECUTE FUNCTION mod_datalayer.handle_fields_audit();

CREATE TRIGGER fields_update_audit BEFORE UPDATE ON mod_datalayer.fields FOR EACH ROW EXECUTE FUNCTION mod_datalayer.handle_fields_audit();

CREATE TRIGGER main_menu_insert_audit BEFORE INSERT ON mod_datalayer.main_menu FOR EACH ROW EXECUTE FUNCTION mod_datalayer.handle_main_menu_audit();

CREATE TRIGGER main_menu_update_audit BEFORE UPDATE ON mod_datalayer.main_menu FOR EACH ROW EXECUTE FUNCTION mod_datalayer.handle_main_menu_audit();

CREATE TRIGGER before_modules_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_datalayer.modules FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER modules_insert_audit BEFORE INSERT ON mod_datalayer.modules FOR EACH ROW EXECUTE FUNCTION mod_datalayer.handle_modules_audit();

CREATE TRIGGER modules_update_audit BEFORE UPDATE ON mod_datalayer.modules FOR EACH ROW EXECUTE FUNCTION mod_datalayer.handle_modules_audit();

CREATE TRIGGER before_page_categories_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_datalayer.page_categories FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER page_categories_insert_audit BEFORE INSERT ON mod_datalayer.page_categories FOR EACH ROW EXECUTE FUNCTION mod_datalayer.handle_page_categories_audit();

CREATE TRIGGER page_categories_update_audit BEFORE UPDATE ON mod_datalayer.page_categories FOR EACH ROW EXECUTE FUNCTION mod_datalayer.handle_page_categories_audit();

CREATE TRIGGER before_pages_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_datalayer.pages FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER pages_insert_audit BEFORE INSERT ON mod_datalayer.pages FOR EACH ROW EXECUTE FUNCTION mod_datalayer.handle_pages_audit();

CREATE TRIGGER pages_update_audit BEFORE UPDATE ON mod_datalayer.pages FOR EACH ROW EXECUTE FUNCTION mod_datalayer.handle_pages_audit();

CREATE TRIGGER pages_departments_insert_audit BEFORE INSERT ON mod_datalayer.pages_departments FOR EACH ROW EXECUTE FUNCTION mod_datalayer.handle_pages_departments_audit();

CREATE TRIGGER pages_departments_update_audit BEFORE UPDATE ON mod_datalayer.pages_departments FOR EACH ROW EXECUTE FUNCTION mod_datalayer.handle_pages_departments_audit();

CREATE TRIGGER pages_menu_departments_insert_audit BEFORE INSERT ON mod_datalayer.pages_menu_departments FOR EACH ROW EXECUTE FUNCTION mod_datalayer.handle_pages_departments_audit();

CREATE TRIGGER pages_menu_departments_update_audit BEFORE UPDATE ON mod_datalayer.pages_menu_departments FOR EACH ROW EXECUTE FUNCTION mod_datalayer.handle_pages_departments_audit();

CREATE TRIGGER before_tables_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_datalayer.tables FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER tables_insert_audit BEFORE INSERT ON mod_datalayer.tables FOR EACH ROW EXECUTE FUNCTION mod_datalayer.handle_tables_audit();

CREATE TRIGGER tables_update_audit BEFORE UPDATE ON mod_datalayer.tables FOR EACH ROW EXECUTE FUNCTION mod_datalayer.handle_tables_audit();

CREATE TRIGGER before_departments_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_manufacturing.departments FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER departments_insert_audit BEFORE INSERT ON mod_manufacturing.departments FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_departments_audit();

CREATE TRIGGER departments_update_audit BEFORE UPDATE ON mod_manufacturing.departments FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_departments_audit();

CREATE TRIGGER set_manufacturing_departments_code BEFORE INSERT ON mod_manufacturing.departments FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER before_locations_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_manufacturing.locations FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER locations_insert_audit BEFORE INSERT ON mod_manufacturing.locations FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_locations_audit();

CREATE TRIGGER locations_update_audit BEFORE UPDATE ON mod_manufacturing.locations FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_locations_audit();

CREATE TRIGGER set_manufacturing_locations_code BEFORE INSERT ON mod_manufacturing.locations FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER production_logs_insert_audit BEFORE INSERT ON mod_manufacturing.production_logs FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_production_logs_audit();

CREATE TRIGGER production_logs_update_audit BEFORE UPDATE ON mod_manufacturing.production_logs FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_production_logs_audit();

CREATE TRIGGER recipes_insert_audit BEFORE INSERT ON mod_manufacturing.recipes FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_recipes_audit();

CREATE TRIGGER recipes_update_audit BEFORE UPDATE ON mod_manufacturing.recipes FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_recipes_audit();

CREATE TRIGGER set_mod_manufacturing_recipes_updated_at BEFORE UPDATE ON mod_manufacturing.recipes FOR EACH ROW EXECUTE FUNCTION common.set_updated_at();

CREATE TRIGGER scheduled_items_insert_audit BEFORE INSERT ON mod_manufacturing.scheduled_items FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_scheduled_items_audit();

CREATE TRIGGER scheduled_items_update_audit BEFORE UPDATE ON mod_manufacturing.scheduled_items FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_scheduled_items_audit();

CREATE TRIGGER trigger_update_work_cycle_categories_updated_at BEFORE UPDATE ON mod_manufacturing.work_cycle_categories FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.update_work_cycle_categories_updated_at();

CREATE TRIGGER before_work_cycles_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_manufacturing.work_cycles FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER set_work_cycles_code BEFORE INSERT ON mod_manufacturing.work_cycles FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER work_cycles_insert_audit BEFORE INSERT ON mod_manufacturing.work_cycles FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_work_cycles_audit();

CREATE TRIGGER work_cycles_update_audit BEFORE UPDATE ON mod_manufacturing.work_cycles FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_work_cycles_audit();

CREATE TRIGGER trigger_update_work_flows_work_cycles_updated_at BEFORE UPDATE ON mod_manufacturing.work_flows_work_cycles FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.update_work_flows_work_cycles_updated_at();

CREATE TRIGGER work_order_quality_summary_insert_audit BEFORE INSERT ON mod_manufacturing.work_order_quality_summary FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_work_order_quality_summary_audit();

CREATE TRIGGER work_order_quality_summary_update_audit BEFORE UPDATE ON mod_manufacturing.work_order_quality_summary FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_work_order_quality_summary_audit();

CREATE TRIGGER before_work_orders_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_manufacturing.work_orders FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER internal_work_order_manufacturing_trigger AFTER UPDATE ON mod_manufacturing.work_orders FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_internal_work_order_manufacturing_status();

CREATE TRIGGER set_work_orders_code BEFORE INSERT ON mod_manufacturing.work_orders FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER trigger_update_article_loaded_for_all_work_orders AFTER UPDATE OF article_loaded ON mod_manufacturing.work_orders FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.update_article_loaded_for_all_work_orders();

CREATE TRIGGER trigger_update_article_unloaded_for_all_work_orders AFTER UPDATE OF article_unloaded ON mod_manufacturing.work_orders FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.update_article_unloaded_for_all_work_orders();

CREATE TRIGGER trigger_update_production_date_on_work_order_insert AFTER INSERT ON mod_manufacturing.work_orders FOR EACH ROW WHEN ((new.scheduled_start IS NOT NULL)) EXECUTE FUNCTION mod_manufacturing.update_production_date_on_work_order_insert();

CREATE TRIGGER trigger_update_sales_order_in_production_on_work_order_status AFTER UPDATE OF status ON mod_manufacturing.work_orders FOR EACH ROW WHEN (((old.status = 'pending'::text) AND (new.status = 'in_progress'::text))) EXECUTE FUNCTION mod_manufacturing.update_sales_order_in_production_on_work_order_status();

CREATE TRIGGER trigger_work_order_status_tracking BEFORE UPDATE OF status ON mod_manufacturing.work_orders FOR EACH ROW WHEN ((old.status IS DISTINCT FROM new.status)) EXECUTE FUNCTION mod_manufacturing.handle_work_order_status_tracking();

CREATE TRIGGER update_sales_order_status_on_work_order_in_progress_trigger AFTER UPDATE OF status ON mod_manufacturing.work_orders FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.update_sales_order_status_on_work_order_in_progress();

CREATE TRIGGER work_order_manufacturing_trigger AFTER UPDATE ON mod_manufacturing.work_orders FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_work_order_manufacturing_status();

CREATE TRIGGER work_order_quality_summary_auto_create AFTER INSERT ON mod_manufacturing.work_orders FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.create_work_order_quality_summary();

CREATE TRIGGER work_order_status_notification_trigger AFTER UPDATE ON mod_manufacturing.work_orders FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_work_order_status_notifications();

CREATE TRIGGER work_orders_insert_audit BEFORE INSERT ON mod_manufacturing.work_orders FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_work_orders_audit();

CREATE TRIGGER work_orders_update_audit BEFORE UPDATE ON mod_manufacturing.work_orders FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_work_orders_audit();

CREATE TRIGGER before_work_steps_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_manufacturing.work_steps FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER set_work_steps_code BEFORE INSERT ON mod_manufacturing.work_steps FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER work_steps_insert_audit BEFORE INSERT ON mod_manufacturing.work_steps FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_work_steps_audit();

CREATE TRIGGER work_steps_update_audit BEFORE UPDATE ON mod_manufacturing.work_steps FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_work_steps_audit();

CREATE TRIGGER before_workstations_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_manufacturing.workstations FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER set_workstations_code BEFORE INSERT ON mod_manufacturing.workstations FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER workstations_insert_audit BEFORE INSERT ON mod_manufacturing.workstations FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_workstations_audit();

CREATE TRIGGER workstations_update_audit BEFORE UPDATE ON mod_manufacturing.workstations FOR EACH ROW EXECUTE FUNCTION mod_manufacturing.handle_workstations_audit();

CREATE TRIGGER department_notification_configs_insert_audit BEFORE INSERT ON mod_pulse.department_notification_configs FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_department_notification_configs_audit();

CREATE TRIGGER department_notification_configs_update_audit BEFORE UPDATE ON mod_pulse.department_notification_configs FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_department_notification_configs_audit();

CREATE TRIGGER before_notifications_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_pulse.notifications FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER notifications_insert_audit BEFORE INSERT ON mod_pulse.notifications FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_notifications_audit();

CREATE TRIGGER notifications_update_audit BEFORE UPDATE ON mod_pulse.notifications FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_notifications_audit();

CREATE TRIGGER set_notifications_code BEFORE INSERT ON mod_pulse.notifications FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER trigger_fcm_notifications AFTER INSERT ON mod_pulse.notifications FOR EACH ROW EXECUTE FUNCTION supabase_functions.http_request('https://hffdufdierbghwcnjswt.supabase.co/functions/v1/push', 'POST', '{"Content-type":"application/json"}', '{}', '1000');

CREATE TRIGGER before_pulse_chat_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_pulse.pulse_chat FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER pulse_chat_insert_audit BEFORE INSERT ON mod_pulse.pulse_chat FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_pulse_chat_audit();

CREATE TRIGGER pulse_chat_update_audit BEFORE UPDATE ON mod_pulse.pulse_chat FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_pulse_chat_audit();

CREATE TRIGGER before_chat_attachment_delete BEFORE DELETE ON mod_pulse.pulse_chat_files FOR EACH ROW EXECUTE FUNCTION mod_pulse.delete_old_chat_attachment();

CREATE TRIGGER pulse_chat_files_insert_audit BEFORE INSERT ON mod_pulse.pulse_chat_files FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_pulse_chat_files_audit();

CREATE TRIGGER pulse_chat_files_update_audit BEFORE UPDATE ON mod_pulse.pulse_chat_files FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_pulse_chat_files_audit();

CREATE TRIGGER before_pulse_checklists_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_pulse.pulse_checklists FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER pulse_checklists_insert_audit BEFORE INSERT ON mod_pulse.pulse_checklists FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_pulse_checklists_audit();

CREATE TRIGGER pulse_checklists_update_audit BEFORE UPDATE ON mod_pulse.pulse_checklists FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_pulse_checklists_audit();

CREATE TRIGGER set_pulse_checklists_code BEFORE INSERT ON mod_pulse.pulse_checklists FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER before_pulse_comments_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_pulse.pulse_comments FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER pulse_comments_insert_audit BEFORE INSERT ON mod_pulse.pulse_comments FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_pulse_comments_audit();

CREATE TRIGGER pulse_comments_update_audit BEFORE UPDATE ON mod_pulse.pulse_comments FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_pulse_comments_audit();

CREATE TRIGGER pulse_conversation_participants_insert_audit BEFORE INSERT ON mod_pulse.pulse_conversation_participants FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_pulse_conversation_participants_audit();

CREATE TRIGGER pulse_conversation_participants_update_audit BEFORE UPDATE ON mod_pulse.pulse_conversation_participants FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_pulse_conversation_participants_audit();

CREATE TRIGGER before_pulse_progress_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_pulse.pulse_progress FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER pulse_progress_insert_audit BEFORE INSERT ON mod_pulse.pulse_progress FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_pulse_progress_audit();

CREATE TRIGGER pulse_progress_update_audit BEFORE UPDATE ON mod_pulse.pulse_progress FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_pulse_progress_audit();

CREATE TRIGGER set_pulse_progress_code BEFORE INSERT ON mod_pulse.pulse_progress FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER before_pulse_sla_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_pulse.pulse_slas FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER pulse_sla_insert_audit BEFORE INSERT ON mod_pulse.pulse_slas FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_pulse_sla_audit();

CREATE TRIGGER pulse_sla_update_audit BEFORE UPDATE ON mod_pulse.pulse_slas FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_pulse_sla_audit();

CREATE TRIGGER set_pulse_slas_code BEFORE INSERT ON mod_pulse.pulse_slas FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER before_pulses_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_pulse.pulses FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER pulses_insert_audit BEFORE INSERT ON mod_pulse.pulses FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_pulses_audit();

CREATE TRIGGER pulses_update_audit BEFORE UPDATE ON mod_pulse.pulses FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_pulses_audit();

CREATE TRIGGER set_pulses_code BEFORE INSERT ON mod_pulse.pulses FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER before_tasks_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_pulse.tasks FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER set_tasks_code BEFORE INSERT ON mod_pulse.tasks FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER tasks_insert_audit BEFORE INSERT ON mod_pulse.tasks FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_tasks_audit();

CREATE TRIGGER tasks_insert_trigger AFTER INSERT ON mod_pulse.tasks FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_new_task_notifications();

CREATE TRIGGER tasks_update_audit BEFORE UPDATE ON mod_pulse.tasks FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_tasks_audit();

CREATE TRIGGER tasks_update_trigger AFTER UPDATE ON mod_pulse.tasks FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_task_assignment_updates();

CREATE TRIGGER batches_insert_audit BEFORE INSERT ON mod_wms.batches FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_batches_audit();

CREATE TRIGGER batches_update_audit BEFORE UPDATE ON mod_wms.batches FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_batches_audit();

CREATE TRIGGER before_batches_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_wms.batches FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER set_batches_code BEFORE INSERT ON mod_wms.batches FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER inventory_insert_audit BEFORE INSERT ON mod_wms.inventory FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_inventory_audit();

CREATE TRIGGER inventory_quantity_notification_for_serena_fabrizio_trigger AFTER UPDATE OF quantity ON mod_wms.inventory FOR EACH ROW EXECUTE FUNCTION mod_wms.inventory_quantity_notification_for_serena_fabrizio();

CREATE TRIGGER inventory_update_audit BEFORE UPDATE ON mod_wms.inventory FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_inventory_audit();

CREATE TRIGGER inventory_insert_audit BEFORE INSERT ON mod_wms.inventory_backup FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_inventory_audit();

CREATE TRIGGER inventory_update_audit BEFORE UPDATE ON mod_wms.inventory_backup FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_inventory_audit();

CREATE TRIGGER before_inventory_limits_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_wms.inventory_limits FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER inventory_limits_insert_audit BEFORE INSERT ON mod_wms.inventory_limits FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_inventory_limits_audit();

CREATE TRIGGER inventory_limits_update_audit BEFORE UPDATE ON mod_wms.inventory_limits FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_inventory_limits_audit();

CREATE TRIGGER set_inventory_limits_code BEFORE INSERT ON mod_wms.inventory_limits FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER before_locations_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_wms.locations FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER locations_insert_audit BEFORE INSERT ON mod_wms.locations FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_locations_audit();

CREATE TRIGGER locations_update_audit BEFORE UPDATE ON mod_wms.locations FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_locations_audit();

CREATE TRIGGER set_wms_locations_code BEFORE INSERT ON mod_wms.locations FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER before_receipt_items_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_wms.receipt_items FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER receipt_items_insert_audit BEFORE INSERT ON mod_wms.receipt_items FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_receipt_items_audit();

CREATE TRIGGER receipt_items_notification_for_serena_trigger AFTER INSERT ON mod_wms.receipt_items FOR EACH ROW EXECUTE FUNCTION mod_wms.receipt_items_notification_for_serena();

CREATE TRIGGER receipt_items_update_audit BEFORE UPDATE ON mod_wms.receipt_items FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_receipt_items_audit();

CREATE TRIGGER set_receipt_items_code BEFORE INSERT ON mod_wms.receipt_items FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER trigger_receipt_items_inbound_on_insert AFTER INSERT ON mod_wms.receipt_items FOR EACH ROW WHEN (((new.is_moved = true) AND (new.moved_date IS NULL))) EXECUTE FUNCTION mod_wms.handle_receipt_items_inbound_on_insert();

CREATE TRIGGER before_receipts_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_wms.receipts FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER create_pulse_for_receipts BEFORE INSERT ON mod_wms.receipts FOR EACH ROW EXECUTE FUNCTION mod_pulse.create_pulse_for_record();

CREATE TRIGGER handle_receipts_deletion AFTER DELETE ON mod_wms.receipts FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_record_deletion();

CREATE TRIGGER receipts_insert_audit BEFORE INSERT ON mod_wms.receipts FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_receipts_audit();

CREATE TRIGGER receipts_update_audit BEFORE UPDATE ON mod_wms.receipts FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_receipts_audit();

CREATE TRIGGER set_receipts_code BEFORE INSERT ON mod_wms.receipts FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER trg_set_receipt_number_on_insert BEFORE INSERT ON mod_wms.receipts FOR EACH ROW EXECUTE FUNCTION mod_wms.set_receipt_number_on_insert();

CREATE TRIGGER trigger_update_receipt_supplier BEFORE INSERT OR UPDATE ON mod_wms.receipts FOR EACH ROW EXECUTE FUNCTION public.update_receipt_supplier_from_po();

CREATE TRIGGER update_pulse_status_for_receipts AFTER UPDATE OF status ON mod_wms.receipts FOR EACH ROW EXECUTE FUNCTION mod_pulse.update_pulse_status();

CREATE TRIGGER update_shipment_attachments_updated_at BEFORE UPDATE ON mod_wms.shipment_attachments FOR EACH ROW EXECUTE FUNCTION mod_wms.update_shipment_attachments_updated_at();

CREATE TRIGGER trigger_shipment_item_addresses_updated_at BEFORE UPDATE ON mod_wms.shipment_item_addresses FOR EACH ROW EXECUTE FUNCTION mod_wms.update_shipment_item_addresses_updated_at();

CREATE TRIGGER before_shipment_items_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_wms.shipment_items FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER set_shipment_items_code BEFORE INSERT ON mod_wms.shipment_items FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER shipment_items_insert_audit BEFORE INSERT ON mod_wms.shipment_items FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_shipment_items_audit();

CREATE TRIGGER shipment_items_update_audit BEFORE UPDATE ON mod_wms.shipment_items FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_shipment_items_audit();

CREATE TRIGGER trigger_update_sales_order_items_has_shipment_on_item_insert AFTER INSERT ON mod_wms.shipment_items FOR EACH ROW EXECUTE FUNCTION mod_wms.update_sales_order_items_has_shipment();

CREATE TRIGGER trigger_update_shipment_sales_orders_updated_at BEFORE UPDATE ON mod_wms.shipment_sales_orders FOR EACH ROW EXECUTE FUNCTION mod_wms.update_shipment_sales_orders_updated_at();

CREATE TRIGGER before_shipments_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_wms.shipments FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER create_pulse_for_shipments BEFORE INSERT ON mod_wms.shipments FOR EACH ROW EXECUTE FUNCTION mod_pulse.create_pulse_for_record();

CREATE TRIGGER handle_shipments_deletion AFTER DELETE ON mod_wms.shipments FOR EACH ROW EXECUTE FUNCTION mod_pulse.handle_record_deletion();

CREATE TRIGGER set_shipments_code BEFORE INSERT ON mod_wms.shipments FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER shipments_insert_audit BEFORE INSERT ON mod_wms.shipments FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_shipments_audit();

CREATE TRIGGER shipments_update_audit BEFORE UPDATE ON mod_wms.shipments FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_shipments_audit();

CREATE TRIGGER trigger_archive_shipment_on_status_loaded AFTER UPDATE OF status ON mod_wms.shipments FOR EACH ROW WHEN (((new.status = 'loaded'::text) AND (old.status IS DISTINCT FROM 'loaded'::text))) EXECUTE FUNCTION mod_wms.handle_archive_shipment_on_status_loaded();

CREATE TRIGGER trigger_create_quality_control_for_shipment AFTER INSERT ON mod_wms.shipments FOR EACH ROW EXECUTE FUNCTION mod_base.create_quality_control_for_shipment();

CREATE TRIGGER trigger_shipments_outbound_on_status_change AFTER UPDATE OF status ON mod_wms.shipments FOR EACH ROW WHEN (((new.status = 'loaded'::text) AND (old.status IS DISTINCT FROM 'loaded'::text))) EXECUTE FUNCTION mod_wms.handle_shipments_outbound_on_status_change();

CREATE TRIGGER trigger_update_sales_order_items_has_shipment AFTER INSERT ON mod_wms.shipments FOR EACH ROW EXECUTE FUNCTION mod_wms.update_sales_order_items_has_shipment();

CREATE TRIGGER trigger_update_sales_order_items_is_shipped_on_loaded AFTER UPDATE OF status ON mod_wms.shipments FOR EACH ROW WHEN (((new.status = 'loaded'::text) AND (old.status IS DISTINCT FROM 'loaded'::text))) EXECUTE FUNCTION mod_wms.handle_update_sales_order_items_is_shipped_on_loaded();

CREATE TRIGGER update_pulse_status_for_shipments AFTER UPDATE OF status ON mod_wms.shipments FOR EACH ROW EXECUTE FUNCTION mod_pulse.update_pulse_status();

CREATE TRIGGER before_stock_movements_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_wms.stock_movements FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER stock_movements_insert_audit BEFORE INSERT ON mod_wms.stock_movements FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_stock_movements_audit();

CREATE TRIGGER stock_movements_update_audit BEFORE UPDATE ON mod_wms.stock_movements FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_stock_movements_audit();

CREATE TRIGGER trigger_handle_inbound_stock_movement AFTER INSERT ON mod_wms.stock_movements FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_inbound_stock_movement();

CREATE TRIGGER trigger_handle_loading_stock_movement AFTER INSERT ON mod_wms.stock_movements FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_loading_stock_movement();

CREATE TRIGGER trigger_handle_original_receipt_item_id BEFORE INSERT ON mod_wms.stock_movements FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_original_receipt_item_id();

CREATE TRIGGER trigger_handle_outbound_unloading_stock_movement AFTER INSERT ON mod_wms.stock_movements FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_outbound_unloading_stock_movement();

CREATE TRIGGER trigger_handle_relocation_stock_movement AFTER INSERT ON mod_wms.stock_movements FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_relocation_stock_movement();

CREATE TRIGGER trigger_handle_transport_stock_movement AFTER INSERT ON mod_wms.stock_movements FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_transport_stock_movement();

CREATE TRIGGER before_warehouses_changes BEFORE DELETE OR UPDATE OF avatar_url ON mod_wms.warehouses FOR EACH ROW EXECUTE FUNCTION mod_admin.delete_old_avatar();

CREATE TRIGGER set_warehouses_code BEFORE INSERT ON mod_wms.warehouses FOR EACH ROW EXECUTE FUNCTION mod_datalayer.generate_table_code();

CREATE TRIGGER warehouses_insert_audit BEFORE INSERT ON mod_wms.warehouses FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_warehouses_audit();

CREATE TRIGGER warehouses_update_audit BEFORE UPDATE ON mod_wms.warehouses FOR EACH ROW EXECUTE FUNCTION mod_wms.handle_warehouses_audit();


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



