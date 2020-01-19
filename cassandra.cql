/**
 * CQL file used to initialize the database in test environment.
 */

CREATE  KEYSPACE IF NOT EXISTS tsorage
    WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }
    AND DURABLE_WRITES = true;

CREATE  KEYSPACE IF NOT EXISTS tsorage_ts
    WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }
    AND DURABLE_WRITES = true;

CREATE TYPE tsorage_ts.tdouble ( value double );
CREATE TYPE tsorage_ts.date_tdouble ( datetime timestamp, value frozen<tsorage_ts.tdouble> );
CREATE TYPE tsorage.tdouble ( value double );
CREATE TYPE tsorage.date_tdouble ( datetime timestamp, value frozen<tsorage.tdouble> );

CREATE TYPE tsorage_ts.pos2d ( longitude double, latitude double );
CREATE TYPE tsorage_ts.date_pos2d ( datetime timestamp, value frozen<tsorage_ts.pos2d> );
CREATE TYPE tsorage.pos2d ( longitude double, latitude double );
CREATE TYPE tsorage.date_pos2d ( datetime timestamp, value frozen<tsorage.pos2d> );

CREATE TYPE tsorage_ts.ttext ( value text );
CREATE TYPE tsorage_ts.date_ttext ( datetime timestamp, value frozen<tsorage_ts.ttext> );
CREATE TYPE tsorage.ttext ( value text );
CREATE TYPE tsorage.date_ttext ( datetime timestamp, value frozen<tsorage.ttext> );

CREATE TYPE tsorage_ts.tlong ( value bigint );
CREATE TYPE tsorage_ts.date_tlong ( datetime timestamp, value frozen<tsorage_ts.tlong> );
CREATE TYPE tsorage.tlong ( value bigint );
CREATE TYPE tsorage.date_tlong ( datetime timestamp, value frozen<tsorage.tlong> );

CREATE TABLE tsorage.observations (
                                      metric text,
                                      tagset frozen<map<text, text>>,
                                      shard text,
                                      interval text,    -- raw, 1m, 1h, 1d
                                      aggregator text,  -- raw, first, last, sum, min, max, count, (no mean => replace by sum / count),  (no delta => replace with last - first)
                                      datetime timestamp,

                                      value_tdouble tsorage.tdouble,
                                      value_date_tdouble tsorage.date_tdouble,

                                      value_pos2d tsorage.pos2d,
                                      value_date_pos2d tsorage.date_pos2d,

                                      value_ttext tsorage.ttext,
                                      value_date_ttext tsorage.date_pos2d,

                                      value_tlong tsorage.tlong,
                                      value_date_tlong tsorage.date_tlong,

                                      PRIMARY KEY ((metric, tagset, shard, interval, aggregator), datetime)
) WITH CLUSTERING ORDER BY (datetime DESC);

CREATE TABLE tsorage_ts.observations (
                                         metric text,
                                         tagset frozen<map<text, text>>,
                                         shard text,
                                         datetime timestamp,

                                         value_tdouble tsorage_ts.tdouble,
                                         value_date_tdouble tsorage_ts.date_tdouble,

                                         value_pos2d tsorage_ts.pos2d,
                                         value_date_pos2d tsorage_ts.date_pos2d,

                                         value_ttext tsorage_ts.ttext,
                                         value_date_ttext tsorage_ts.date_ttext,

                                         value_tlong tsorage_ts.tlong,
                                         value_date_tlong tsorage_ts.date_tlong,

                                         PRIMARY KEY ((metric, tagset, shard), datetime)
) WITH CLUSTERING ORDER BY (datetime DESC);


/**
 * The static tagsets associated with a metric.
 */
CREATE TABLE tsorage.static_tagset (
    metric text,
    tagname text,
    tagvalue text,
    PRIMARY KEY (metric, tagname, tagvalue)
) WITH CLUSTERING ORDER BY (tagname ASC, tagvalue ASC);

/**
  * The reverse tagset table, for storing the metrics associated with a static tagset.
 */
CREATE MATERIALIZED VIEW tsorage.reverse_static_tagset AS
    SELECT metric, tagname, tagvalue
    FROM tsorage.static_tagset
    WHERE tagname IS NOT NULL AND tagvalue IS NOT NULL
    PRIMARY KEY (tagname, tagvalue, metric)
WITH CLUSTERING ORDER BY (tagvalue ASC);

/**
 * The dynamic tagsets associated with a metric.
 */
CREATE TABLE tsorage.dynamic_tagset(
    metric text,
    tagset frozen<map<text, text>>,
    PRIMARY KEY (metric, tagset)
) WITH CLUSTERING ORDER BY (tagset ASC);

CREATE TABLE tsorage.reverse_dynamic_tagset(
    tagname text,
    tagvalue text,
    metric text,
    tagset frozen<map<text, text>>,
    PRIMARY KEY (tagname, tagvalue, metric, tagset)
) WITH CLUSTERING ORDER BY (tagvalue ASC, metric ASC, tagset ASC);

CREATE TABLE tsorage.sharded_dynamic_tagset
(
    metric   text,
    shard    text,
    tagset frozen<map<text, text>>,
    PRIMARY KEY ((metric, shard), tagset)
) WITH CLUSTERING ORDER BY (tagset ASC);

CREATE TABLE tsorage.reverse_sharded_dynamic_tagset(
    shard text,
    tagname text,
    tagvalue text,
    metric text,
    tagset frozen<map<text, text>>,
    PRIMARY KEY ( (shard, tagname), tagvalue, metric, tagset)
) WITH CLUSTERING ORDER BY (tagvalue ASC, metric ASC);