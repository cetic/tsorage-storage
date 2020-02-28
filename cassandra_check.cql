/**
 * CQL file used to check the database's schema.
 * This file is useful as the tables are created with "IF NOT EXISTS".
 */

SELECT metric, tagset, shard, interval, aggregator, datetime, value_date_pos2d, value_date_tdouble, value_date_tlong,
  value_date_ttext, value_pos2d, value_tdouble, value_tlong, value_ttext FROM tsorage.observations;

SELECT metric, tagset, shard, datetime, value_date_pos2d, value_date_tdouble, value_date_tlong, value_date_ttext,
  value_pos2d, value_tdouble, value_tlong, value_ttext FROM tsorage_ts.observations;

SELECT metric, tagname, tagvalue FROM tsorage.static_tagset;

SELECT tagname, tagvalue, metric FROM tsorage.reverse_static_tagset;

SELECT metric, tagset FROM tsorage.dynamic_tagset;

SELECT tagname, tagvalue, metric, tagset FROM tsorage.reverse_dynamic_tagset;

SELECT metric, shard, tagset FROM tsorage.sharded_dynamic_tagset;

SELECT shard, tagname, tagvalue, metric, tagset FROM tsorage.reverse_sharded_dynamic_tagset;
