drop trigger if exists "trigger_update_expected_delivery_date_internal" on "mod_base"."internal_sales_order_items";

drop trigger if exists "trigger_update_expected_delivery_date" on "mod_base"."sales_order_items";

drop trigger if exists "trigger_update_receipt_supplier" on "mod_wms"."receipts";

drop policy "superAdmin can delete" on "mod_admin"."domain_modules";

drop policy "superAdmin can insert into" on "mod_admin"."domain_modules";

drop policy "superAdmin can update" on "mod_admin"."domain_modules";

drop policy "Admins can delete from domain_users" on "mod_admin"."domain_users";

drop policy "Admins can insert into domain_users" on "mod_admin"."domain_users";

drop policy "Admins can update domain_users" on "mod_admin"."domain_users";

drop policy "Admins can delete from domains" on "mod_admin"."domains";

drop policy "Admins can insert into domains" on "mod_admin"."domains";

drop policy "Admins can update domains" on "mod_admin"."domains";

drop policy "Administrators can see their domain and subdomain data" on "mod_base"."announcements";

drop policy "Allow shared data access for specific subdomains" on "mod_base"."announcements";

drop policy "SuperAdmins can see all data" on "mod_base"."announcements";

drop policy "Users can see their own domain data" on "mod_base"."announcements";

drop policy "Administrators can see their domain and subdomain data" on "mod_base"."article_categories";

drop policy "Allow shared data access for specific subdomains" on "mod_base"."article_categories";

drop policy "SuperAdmins can see all data" on "mod_base"."article_categories";

drop policy "Users can see their own domain data" on "mod_base"."article_categories";

drop policy "Administrators can see their domain and subdomain data" on "mod_base"."customer_addresses";

drop policy "Allow shared data access for specific subdomains" on "mod_base"."customer_addresses";

drop policy "SuperAdmins can see all data" on "mod_base"."customer_addresses";

drop policy "Users can delete their own domain data" on "mod_base"."customer_addresses";

drop policy "Users can insert addresses in their domain" on "mod_base"."customer_addresses";

drop policy "Users can see their own domain data" on "mod_base"."customer_addresses";

drop policy "Users can update addresses in their domain" on "mod_base"."customer_addresses";

drop policy "Administrators can see their domain and subdomain data" on "mod_base"."customers";

drop policy "Allow shared data access for specific subdomains" on "mod_base"."customers";

drop policy "SuperAdmins can see all data" on "mod_base"."customers";

drop policy "Users can insert customers in their domain" on "mod_base"."customers";

drop policy "Users can see their own domain data" on "mod_base"."customers";

drop policy "Users can update customers in their domain" on "mod_base"."customers";

drop policy "Users can view customers in their domain" on "mod_base"."customers";

drop policy "Administrators can see their domain and subdomain data" on "mod_base"."departments";

drop policy "Allow shared data access for specific subdomains" on "mod_base"."departments";

drop policy "SuperAdmins can see all data" on "mod_base"."departments";

drop policy "Users can see their own domain data" on "mod_base"."departments";

drop policy "Administrators can see their domain and subdomain data" on "mod_base"."employees";

drop policy "Allow shared data access for specific subdomains" on "mod_base"."employees";

drop policy "SuperAdmins can see all data" on "mod_base"."employees";

drop policy "Administrators can see their domain and subdomain data" on "mod_base"."employees_departments";

drop policy "Allow shared data access for specific subdomains" on "mod_base"."employees_departments";

drop policy "SuperAdmins can see all data" on "mod_base"."employees_departments";

drop policy "Administrators can see their domain and subdomain data" on "mod_base"."purchase_order_items";

drop policy "Allow shared data access for specific subdomains" on "mod_base"."purchase_order_items";

drop policy "SuperAdmins can see all data" on "mod_base"."purchase_order_items";

drop policy "Users can see their own domain data" on "mod_base"."purchase_order_items";

drop policy "Administrators can see their domain and subdomain data" on "mod_base"."purchase_orders";

drop policy "Allow shared data access for specific subdomains" on "mod_base"."purchase_orders";

drop policy "SuperAdmins can see all data" on "mod_base"."purchase_orders";

drop policy "Users can see their own domain data" on "mod_base"."purchase_orders";

drop policy "Administrators can see their domain and subdomain data" on "mod_base"."report_template";

drop policy "Allow shared data access for specific subdomains" on "mod_base"."report_template";

drop policy "SuperAdmins can see all data" on "mod_base"."report_template";

drop policy "Users can see their own domain data" on "mod_base"."report_template";

drop policy "Administrators can see their domain and subdomain data" on "mod_base"."suppliers";

drop policy "Allow shared data access for specific subdomains" on "mod_base"."suppliers";

drop policy "SuperAdmins can see all data" on "mod_base"."suppliers";

drop policy "Users can see their own domain data" on "mod_base"."suppliers";

drop policy "Administrators can see their domain and subdomain data" on "mod_base"."units_of_measure";

drop policy "Allow shared data access for specific subdomains" on "mod_base"."units_of_measure";

drop policy "SuperAdmins can see all data" on "mod_base"."units_of_measure";

drop policy "Users can see their own domain data" on "mod_base"."units_of_measure";

drop policy "superAdmin can delete" on "mod_datalayer"."fields";

drop policy "superAdmin can insert into" on "mod_datalayer"."fields";

drop policy "superAdmin can update" on "mod_datalayer"."fields";

drop policy "superAdmin can delete" on "mod_datalayer"."main_menu";

drop policy "superAdmin can insert into" on "mod_datalayer"."main_menu";

drop policy "superAdmin can update" on "mod_datalayer"."main_menu";

drop policy "superAdmin can delete" on "mod_datalayer"."modules";

drop policy "superAdmin can insert into" on "mod_datalayer"."modules";

drop policy "superAdmin can update" on "mod_datalayer"."modules";

drop policy "superAdmin can delete" on "mod_datalayer"."page_categories";

drop policy "superAdmin can insert into" on "mod_datalayer"."page_categories";

drop policy "superAdmin can update" on "mod_datalayer"."page_categories";

drop policy "superAdmin can delete" on "mod_datalayer"."pages";

drop policy "superAdmin can insert into" on "mod_datalayer"."pages";

drop policy "superAdmin can update" on "mod_datalayer"."pages";

drop policy "SuperAdmins can manage all data" on "mod_datalayer"."pages_departments";

drop policy "Users can see their own domain data" on "mod_datalayer"."pages_departments";

drop policy "superAdmin can delete" on "mod_datalayer"."tables";

drop policy "superAdmin can insert into" on "mod_datalayer"."tables";

drop policy "superAdmin can update" on "mod_datalayer"."tables";

drop policy "Administrators can see their domain and subdomain data" on "mod_manufacturing"."departments";

drop policy "Allow shared data access for specific subdomains" on "mod_manufacturing"."departments";

drop policy "SuperAdmins can see all data" on "mod_manufacturing"."departments";

drop policy "Users can see their own domain data" on "mod_manufacturing"."departments";

drop policy "Administrators can see their domain and subdomain data" on "mod_manufacturing"."locations";

drop policy "Allow shared data access for specific subdomains" on "mod_manufacturing"."locations";

drop policy "SuperAdmins can see all data" on "mod_manufacturing"."locations";

drop policy "Users can see their own domain data" on "mod_manufacturing"."locations";

drop policy "Administrators can see their domain and subdomain data" on "mod_manufacturing"."production_logs";

drop policy "Allow shared data access for specific subdomains" on "mod_manufacturing"."production_logs";

drop policy "SuperAdmins can see all data" on "mod_manufacturing"."production_logs";

drop policy "Users can see their own domain data" on "mod_manufacturing"."production_logs";

drop policy "Administrators can see their domain and subdomain data" on "mod_manufacturing"."recipes";

drop policy "Allow shared data access for specific subdomains" on "mod_manufacturing"."recipes";

drop policy "SuperAdmins can see all data" on "mod_manufacturing"."recipes";

drop policy "Users can see their own domain data" on "mod_manufacturing"."recipes";

drop policy "Administrators can see their domain and subdomain data" on "mod_manufacturing"."scheduled_items";

drop policy "Allow shared data access for specific subdomains" on "mod_manufacturing"."scheduled_items";

drop policy "Authenticated users can insert data" on "mod_manufacturing"."scheduled_items";

drop policy "Authenticated users can update data" on "mod_manufacturing"."scheduled_items";

drop policy "SuperAdmins can see all data" on "mod_manufacturing"."scheduled_items";

drop policy "Users can see their own domain data" on "mod_manufacturing"."scheduled_items";

drop policy "Administrators can see domain work cycles" on "mod_manufacturing"."work_cycles";

drop policy "SuperAdmins can see all work cycles" on "mod_manufacturing"."work_cycles";

drop policy "Users can see department shared work cycles" on "mod_manufacturing"."work_cycles";

drop policy "Administrators can see their domain and subdomain data" on "mod_manufacturing"."work_order_quality_summary";

drop policy "Allow shared data access for specific subdomains" on "mod_manufacturing"."work_order_quality_summary";

drop policy "Authenticated users can delete data" on "mod_manufacturing"."work_order_quality_summary";

drop policy "Authenticated users can insert data" on "mod_manufacturing"."work_order_quality_summary";

drop policy "Authenticated users can update data" on "mod_manufacturing"."work_order_quality_summary";

drop policy "SuperAdmins can see all data" on "mod_manufacturing"."work_order_quality_summary";

drop policy "Users can see their own domain data" on "mod_manufacturing"."work_order_quality_summary";

drop policy "Administrators can see domain work orders" on "mod_manufacturing"."work_orders";

drop policy "Authenticated users can see domain work orders" on "mod_manufacturing"."work_orders";

drop policy "SuperAdmins can see all work orders" on "mod_manufacturing"."work_orders";

drop policy "Administrators can see their domain and subdomain data" on "mod_manufacturing"."work_steps";

drop policy "Allow shared data access for specific subdomains" on "mod_manufacturing"."work_steps";

drop policy "SuperAdmins can see all data" on "mod_manufacturing"."work_steps";

drop policy "Users can see their own domain data" on "mod_manufacturing"."work_steps";

drop policy "Administrators can see their domain and subdomain data" on "mod_manufacturing"."workstations";

drop policy "Allow shared data access for specific subdomains" on "mod_manufacturing"."workstations";

drop policy "SuperAdmins can see all data" on "mod_manufacturing"."workstations";

drop policy "Users can see their own domain data" on "mod_manufacturing"."workstations";

drop policy "Administrators can see their domain and subdomain data" on "mod_pulse"."department_notification_configs";

drop policy "SuperAdmins can see all data" on "mod_pulse"."department_notification_configs";

drop policy "Users can see their own domain data" on "mod_pulse"."department_notification_configs";

drop policy "Administrators can see domain notifications" on "mod_pulse"."notifications";

drop policy "SuperAdmins can see all notifications" on "mod_pulse"."notifications";

drop policy "Users can see department shared notifications" on "mod_pulse"."notifications";

drop policy "Administrators can see their domain and subdomain data" on "mod_pulse"."pulse_chat";

drop policy "Allow shared data access for specific subdomains" on "mod_pulse"."pulse_chat";

drop policy "SuperAdmins can see all data" on "mod_pulse"."pulse_chat";

drop policy "Users can see their own domain data" on "mod_pulse"."pulse_chat";

drop policy "Administrators can see their domain and subdomain data" on "mod_pulse"."pulse_chat_files";

drop policy "SuperAdmins can see all data" on "mod_pulse"."pulse_chat_files";

drop policy "Users can see their own domain data" on "mod_pulse"."pulse_chat_files";

drop policy "Administrators can see their domain and subdomain data" on "mod_pulse"."pulse_checklists";

drop policy "Allow shared data access for specific subdomains" on "mod_pulse"."pulse_checklists";

drop policy "SuperAdmins can see all data" on "mod_pulse"."pulse_checklists";

drop policy "Users can see their own domain data" on "mod_pulse"."pulse_checklists";

drop policy "Administrators can see their domain and subdomain data" on "mod_pulse"."pulse_comments";

drop policy "Allow shared data access for specific subdomains" on "mod_pulse"."pulse_comments";

drop policy "SuperAdmins can see all data" on "mod_pulse"."pulse_comments";

drop policy "Users can see their own domain data" on "mod_pulse"."pulse_comments";

drop policy "Administrators can see their domain and subdomain data" on "mod_pulse"."pulse_conversation_participants";

drop policy "SuperAdmins can see all data" on "mod_pulse"."pulse_conversation_participants";

drop policy "Users can see their own domain data" on "mod_pulse"."pulse_conversation_participants";

drop policy "Administrators can see their domain and subdomain data" on "mod_pulse"."pulse_progress";

drop policy "Allow shared data access for specific subdomains" on "mod_pulse"."pulse_progress";

drop policy "SuperAdmins can see all data" on "mod_pulse"."pulse_progress";

drop policy "Users can see their own domain data" on "mod_pulse"."pulse_progress";

drop policy "Administrators can see their domain and subdomain data" on "mod_pulse"."pulse_slas";

drop policy "Allow shared data access for specific subdomains" on "mod_pulse"."pulse_slas";

drop policy "SuperAdmins can see all data" on "mod_pulse"."pulse_slas";

drop policy "Users can see their own domain data" on "mod_pulse"."pulse_slas";

drop policy "Administrators can see their domain and subdomain data" on "mod_pulse"."pulses";

drop policy "Allow shared data access for specific subdomains" on "mod_pulse"."pulses";

drop policy "SuperAdmins can see all data" on "mod_pulse"."pulses";

drop policy "Users can see their own domain data" on "mod_pulse"."pulses";

drop policy "Administrators can see their domain and subdomain data" on "mod_pulse"."tasks";

drop policy "Allow shared data access for specific subdomains" on "mod_pulse"."tasks";

drop policy "SuperAdmins can see all data" on "mod_pulse"."tasks";

drop policy "Users can see their own domain data" on "mod_pulse"."tasks";

drop policy "Administrators can view box contents in their domain and subdom" on "mod_wms"."box_contents";

drop policy "SuperAdmins can view all box contents" on "mod_wms"."box_contents";

drop policy "Users can view box contents in their domain" on "mod_wms"."box_contents";

drop policy "Administrators can view box types in their domain and subdomain" on "mod_wms"."box_types";

drop policy "SuperAdmins can view all box types" on "mod_wms"."box_types";

drop policy "Users can view box types in their domain" on "mod_wms"."box_types";

drop policy "Administrators can view carton contents in their domain and sub" on "mod_wms"."carton_contents";

drop policy "SuperAdmins can view all carton contents" on "mod_wms"."carton_contents";

drop policy "Users can view carton contents in their domain" on "mod_wms"."carton_contents";

drop policy "Administrators can view carton types in their domain and subdom" on "mod_wms"."carton_types";

drop policy "SuperAdmins can view all carton types" on "mod_wms"."carton_types";

drop policy "Users can view carton types in their domain" on "mod_wms"."carton_types";

drop policy "Administrators can see their domain and subdomain data" on "mod_wms"."inventory_backup";

drop policy "Allow shared data access for specific subdomains" on "mod_wms"."inventory_backup";

drop policy "SuperAdmins can see all data" on "mod_wms"."inventory_backup";

drop policy "Users can see their own domain data" on "mod_wms"."inventory_backup";

drop policy "Administrators can see their domain and subdomain data" on "mod_wms"."inventory_limits";

drop policy "Allow shared data access for specific subdomains" on "mod_wms"."inventory_limits";

drop policy "SuperAdmins can see all data" on "mod_wms"."inventory_limits";

drop policy "Users can see their own domain data" on "mod_wms"."inventory_limits";

drop policy "Administrators can view pallet contents in their domain and sub" on "mod_wms"."pallet_contents";

drop policy "SuperAdmins can view all pallet contents" on "mod_wms"."pallet_contents";

drop policy "Users can view pallet contents in their domain" on "mod_wms"."pallet_contents";

drop policy "Administrators can view pallet types in their domain and subdom" on "mod_wms"."pallet_types";

drop policy "SuperAdmins can view all pallet types" on "mod_wms"."pallet_types";

drop policy "Users can view pallet types in their domain" on "mod_wms"."pallet_types";

drop policy "Administrators can see their domain and subdomain data" on "mod_wms"."receipt_items";

drop policy "Allow shared data access for specific subdomains" on "mod_wms"."receipt_items";

drop policy "SuperAdmins can see all data" on "mod_wms"."receipt_items";

drop policy "Users can see their own domain data" on "mod_wms"."receipt_items";

drop policy "Administrators can view shipment boxes in their domain and subd" on "mod_wms"."shipment_boxes";

drop policy "SuperAdmins can view all shipment boxes" on "mod_wms"."shipment_boxes";

drop policy "Users can view shipment boxes in their domain" on "mod_wms"."shipment_boxes";

drop policy "Administrators can view shipment cartons in their domain and su" on "mod_wms"."shipment_cartons";

drop policy "SuperAdmins can view all shipment cartons" on "mod_wms"."shipment_cartons";

drop policy "Users can view shipment cartons in their domain" on "mod_wms"."shipment_cartons";

drop policy "Administrators can see their domain and subdomain data" on "mod_wms"."shipment_items";

drop policy "Allow shared data access for specific subdomains" on "mod_wms"."shipment_items";

drop policy "SuperAdmins can see all data" on "mod_wms"."shipment_items";

drop policy "Users can see their own domain data" on "mod_wms"."shipment_items";

drop policy "Administrators can view shipment pallets in their domain and su" on "mod_wms"."shipment_pallets";

drop policy "SuperAdmins can view all shipment pallets" on "mod_wms"."shipment_pallets";

drop policy "Users can view shipment pallets in their domain" on "mod_wms"."shipment_pallets";

drop policy "Administrators can view shipment standalone items in their doma" on "mod_wms"."shipment_standalone_items";

drop policy "SuperAdmins can view all shipment standalone items" on "mod_wms"."shipment_standalone_items";

drop policy "Users can view shipment standalone items in their domain" on "mod_wms"."shipment_standalone_items";

drop policy "Administrators can see their domain and subdomain data" on "mod_wms"."shipments";

drop policy "Allow shared data access for specific subdomains" on "mod_wms"."shipments";

drop policy "SuperAdmins can see all data" on "mod_wms"."shipments";

drop policy "Users can see their own domain data" on "mod_wms"."shipments";

drop view if exists "mod_base"."purchase_order_qc_tracking";

drop view if exists "mod_base"."quality_control_summary";

drop view if exists "mod_quality_control"."supplier_returns_summary";

alter table "mod_base"."announcements" drop column "testing";

alter table "mod_base"."article_categories" add column "testing" text;

alter table "mod_quality_control"."quality_control_defects" alter column "severity" set data type public.defect_severity_type using "severity"::text::public.defect_severity_type;

alter table "mod_quality_control"."supplier_returns" alter column "return_status" set default 'PENDING'::public.return_status_type;

alter table "mod_quality_control"."supplier_returns" alter column "return_status" set data type public.return_status_type using "return_status"::text::public.return_status_type;

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



  create policy "SuperAdmins can see all data"
  on "mod_base"."employees"
  as permissive
  for all
  to public
using ((COALESCE(public.get_my_claim_text('role'::text), ''::text) = 'superAdmin'::text));



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



  create policy "SuperAdmins can see all data"
  on "mod_base"."employees_departments"
  as permissive
  for all
  to public
using ((COALESCE(public.get_my_claim_text('role'::text), ''::text) = 'superAdmin'::text));



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



  create policy "SuperAdmins can manage all data"
  on "mod_datalayer"."pages_departments"
  as permissive
  for all
  to public
using ((public.get_my_claim_text('role'::text) = 'superAdmin'::text));



  create policy "Users can see their own domain data"
  on "mod_datalayer"."pages_departments"
  as permissive
  for select
  to public
using (((is_deleted = false) AND (EXISTS ( SELECT 1
   FROM mod_base.departments d
  WHERE ((d.id = pages_departments.department_id) AND ((public.get_my_claim_text('domain_id'::text))::uuid = d.domain_id))))));



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



  create policy "Administrators can see domain work cycles"
  on "mod_manufacturing"."work_cycles"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid)) AND (is_deleted = false)));



  create policy "SuperAdmins can see all work cycles"
  on "mod_manufacturing"."work_cycles"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'superAdmin'::text) AND (is_deleted = false)));



  create policy "Users can see department shared work cycles"
  on "mod_manufacturing"."work_cycles"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('domain_id'::text) = ANY (shared_with)) OR (('*'::text = ANY (shared_with)) AND (is_deleted = false))));



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



  create policy "Authenticated users can see domain work orders"
  on "mod_manufacturing"."work_orders"
  as permissive
  for select
  to public
using (((auth.uid() IS NOT NULL) AND ((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) AND (is_deleted = false)));



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



  create policy "Administrators can view box contents in their domain and subdom"
  on "mod_wms"."box_contents"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



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



  create policy "Administrators can view pallet contents in their domain and sub"
  on "mod_wms"."pallet_contents"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



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



  create policy "Administrators can view shipment boxes in their domain and subd"
  on "mod_wms"."shipment_boxes"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



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



  create policy "Administrators can view shipment standalone items in their doma"
  on "mod_wms"."shipment_standalone_items"
  as permissive
  for select
  to public
using (((public.get_my_claim_text('role'::text) = 'admin'::text) AND (((public.get_my_claim_text('domain_id'::text))::uuid = domain_id) OR mod_admin.is_subdomain(domain_id, (public.get_my_claim_text('domain_id'::text))::uuid))));



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


CREATE TRIGGER trigger_update_expected_delivery_date_internal AFTER INSERT OR UPDATE OF production_date ON mod_base.internal_sales_order_items FOR EACH ROW EXECUTE FUNCTION public.update_expected_delivery_date();

CREATE TRIGGER trigger_update_expected_delivery_date AFTER INSERT OR UPDATE OF production_date ON mod_base.sales_order_items FOR EACH ROW EXECUTE FUNCTION public.update_expected_delivery_date();

CREATE TRIGGER trigger_update_receipt_supplier BEFORE INSERT OR UPDATE ON mod_wms.receipts FOR EACH ROW EXECUTE FUNCTION public.update_receipt_supplier_from_po();


