/**
 * CQL file used to initialize the database in prod environment.
 */

CREATE KEYSPACE IF NOT EXISTS tsorage
    WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }
     AND DURABLE_WRITES = true;

CREATE KEYSPACE IF NOT EXISTS tsorage_ts
    WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }
     AND DURABLE_WRITES = true;

CREATE TYPE IF NOT EXISTS tsorage_ts.tdouble ( value double );
CREATE TYPE IF NOT EXISTS tsorage.tdouble ( value double );
CREATE TYPE IF NOT EXISTS tsorage.date_tdouble ( datetime timestamp, value frozen<tsorage.tdouble> );

CREATE TYPE IF NOT EXISTS tsorage_ts.pos2d ( longitude double, latitude double );
CREATE TYPE IF NOT EXISTS tsorage.pos2d ( longitude double, latitude double );
CREATE TYPE IF NOT EXISTS tsorage.date_pos2d ( datetime timestamp, value frozen<tsorage.pos2d> );

CREATE TYPE IF NOT EXISTS tsorage_ts.ttext ( value text );
CREATE TYPE IF NOT EXISTS tsorage.ttext ( value text );
CREATE TYPE IF NOT EXISTS tsorage.date_ttext ( datetime timestamp, value frozen<tsorage.ttext> );

CREATE TYPE IF NOT EXISTS tsorage_ts.tlong ( value bigint );
CREATE TYPE IF NOT EXISTS tsorage.tlong ( value bigint );
CREATE TYPE IF NOT EXISTS tsorage.date_tlong ( datetime timestamp, value frozen<tsorage.tlong> );

CREATE TYPE IF NOT EXISTS tsorage_ts.tbool ( value boolean );
CREATE TYPE IF NOT EXISTS tsorage.tbool ( value boolean );
CREATE TYPE IF NOT EXISTS tsorage.date_tbool ( datetime timestamp, value frozen<tsorage.tbool> );

CREATE TYPE IF NOT EXISTS tsorage_ts.tbinary ( value blob );
CREATE TYPE IF NOT EXISTS tsorage.tbinary ( value blob );
CREATE TYPE IF NOT EXISTS tsorage.date_tbinary ( datetime timestamp, value frozen<tsorage.tbinary> );

CREATE TABLE IF NOT EXISTS tsorage.observations
(
    metric             text,
    tagset             frozen<map<text, text>>,
    shard              text,
    interval           text, -- raw, 1m, 1h, 1d
    aggregator         text, -- raw, first, last, sum, min, max, count, (no mean => replace by sum / count),  (no delta => replace with last - first)
    datetime           timestamp,

    value_tdouble      tsorage.tdouble,
    value_date_tdouble tsorage.date_tdouble,

    value_pos2d        tsorage.pos2d,
    value_date_pos2d   tsorage.date_pos2d,

    value_ttext        tsorage.ttext,
    value_date_ttext   tsorage.date_ttext,

    value_tlong        tsorage.tlong,
    value_date_tlong   tsorage.date_tlong,

    value_tbool        tsorage.tbool,
    value_date_tbool   tsorage.date_tbool,

    value_tbinary      tsorage.tbinary,
    value_date_tbinary tsorage.date_tbinary,

    PRIMARY KEY ((metric, tagset, shard, interval, aggregator), datetime)
) WITH CLUSTERING ORDER BY (datetime DESC);

CREATE TABLE IF NOT EXISTS tsorage_ts.observations
(
    metric        text,
    tagset        frozen<map<text, text>>,
    shard         text,
    datetime      timestamp,

    value_tdouble tsorage_ts.tdouble,

    value_pos2d   tsorage_ts.pos2d,

    value_ttext   tsorage_ts.ttext,

    value_tlong   tsorage_ts.tlong,

    value_tbool   tsorage_ts.tbool,

    value_tbinary tsorage_ts.tbinary,

    PRIMARY KEY ((metric, tagset, shard), datetime)
) WITH CLUSTERING ORDER BY (datetime DESC);


/**
 * The static tagsets associated with a metric.
 */
CREATE TABLE IF NOT EXISTS tsorage.static_tagset (
                                                     metric text,
                                                     tagname text,
                                                     tagvalue text,
                                                     PRIMARY KEY (metric, tagname, tagvalue)
) WITH CLUSTERING ORDER BY (tagname ASC, tagvalue ASC);

/**
  * The reverse tagset table, for storing the metrics associated with a static tagset.
 */
CREATE MATERIALIZED VIEW IF NOT EXISTS tsorage.reverse_static_tagset AS
SELECT metric, tagname, tagvalue
FROM tsorage.static_tagset
WHERE tagname IS NOT NULL AND tagvalue IS NOT NULL
PRIMARY KEY (tagname, tagvalue, metric)
WITH CLUSTERING ORDER BY (tagvalue ASC);

/**
 * The dynamic tagsets associated with a metric.
 */
CREATE TABLE IF NOT EXISTS tsorage.dynamic_tagset(
                                                     metric text,
                                                     tagset frozen<map<text, text>>,
                                                     PRIMARY KEY (metric, tagset)
) WITH CLUSTERING ORDER BY (tagset ASC);

CREATE TABLE IF NOT EXISTS tsorage.reverse_dynamic_tagset(
                                                             tagname text,
                                                             tagvalue text,
                                                             metric text,
                                                             tagset frozen<map<text, text>>,
                                                             PRIMARY KEY (tagname, tagvalue, metric, tagset)
) WITH CLUSTERING ORDER BY (tagvalue ASC, metric ASC, tagset ASC);

CREATE TABLE IF NOT EXISTS tsorage.sharded_dynamic_tagset
(
    metric   text,
    shard    text,
    tagset frozen<map<text, text>>,
    PRIMARY KEY ((metric, shard), tagset)
) WITH CLUSTERING ORDER BY (tagset ASC);

CREATE TABLE IF NOT EXISTS tsorage.reverse_sharded_dynamic_tagset(
                                                                     shard text,
                                                                     tagname text,
                                                                     tagvalue text,
                                                                     metric text,
                                                                     tagset frozen<map<text, text>>,
                                                                     PRIMARY KEY ( (shard, tagname), tagvalue, metric, tagset)
) WITH CLUSTERING ORDER BY (tagvalue ASC, metric ASC);