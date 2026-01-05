drop view if exists "mod_base"."quality_control_checklist_summary";

drop view if exists "mod_quality_control"."supplier_returns_summary";

drop view if exists "mod_wms"."current_inventory";

alter table "mod_base"."articles" drop column "testing";

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



