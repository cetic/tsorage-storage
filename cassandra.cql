CREATE  KEYSPACE IF NOT EXISTS tsorage
    WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }
    AND DURABLE_WRITES = true;

CREATE  KEYSPACE IF NOT EXISTS tsorage_ts
    WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }
    AND DURABLE_WRITES = true;

CREATE TYPE tsorage_ts.tdouble ( value double );
CREATE TYPE tsorage.tdouble ( value double );

CREATE TYPE tsorage_ts.tlong ( value bigint );
CREATE TYPE tsorage.tlong ( value bigint );

CREATE TYPE tsorage_ts.date_double ( datetime timestamp, value double );
CREATE TYPE tsorage.date_double ( datetime timestamp, value double );


CREATE TABLE tsorage.observations (
                                      metric_ text,
                                      shard_ text,
                                      interval_ text,    -- raw, 1m, 1h, 1d
                                      aggregator_ text,  -- raw, first, last, sum, min, max, count, (no mean => replace by sum / count),  (no delta => replace with last - first)
                                      datetime_ timestamp,
                                      value_double_ tsorage.tdouble,
                                      value_long_ tsorage.tlong,
                                      value_date_double_ tsorage.date_double,
                                      PRIMARY KEY ((metric_, shard_, interval_, aggregator_), datetime_)
) WITH CLUSTERING ORDER BY (datetime_ DESC);

CREATE TABLE tsorage_ts.observations (
                                         metric_ text,
                                         shard_ text,
                                         datetime_ timestamp,
                                         value_double_ tsorage_ts.tdouble,
                                         value_long_ tsorage_ts.tlong,
                                         value_date_double_ tsorage_ts.date_double,
                                         PRIMARY KEY ((metric_, shard_), datetime_)
) WITH CLUSTERING ORDER BY (datetime_ DESC);


/**
 * The static tagset associated with a metric.
 */
CREATE TABLE tsorage.static_tagset (
    metric text,
    tagname text,
    tagvalue text,
    PRIMARY KEY (metric, tagname)
) WITH CLUSTERING ORDER BY (tagname ASC);

/**
  * The reverse tagset table, for storing the metrics associated with a static tagset.
 */
CREATE MATERIALIZED VIEW tsorage.reverse_static_tagset AS
    SELECT metric, tagname, tagvalue
    FROM tsorage.static_tagset
    WHERE tagname IS NOT NULL AND tagvalue IS NOT NULL
    PRIMARY KEY (tagname, tagvalue, metric)
WITH CLUSTERING ORDER BY (tagvalue ASC);

INSERT INTO "tsorage"."static_tagset" ("metric", "tagname", "tagvalue") VALUES ('my_metric', 'owner', 'mg');
INSERT INTO "tsorage"."static_tagset" ("metric", "tagname", "tagvalue") VALUES ('my_metric', 'quality', 'good');

UPDATE tsorage.static_tagset
SET tagvalue = 'degree celcius'
WHERE metric = 'my_metric' AND tagname = 'unit';

UPDATE tsorage.static_tagset
SET tagvalue = 'cetic'
WHERE metric = 'my_metric' AND tagname = 'owner';

SELECT DISTINCT metric
FROM tsorage.static_tagset;


/**
 * Shard indices for dynamic tagsets
 */

CREATE TABLE tsorage.dynamic_tagset(
    metric text,
    shard text,
    tagname text,
    tagvalue text,
    PRIMARY KEY ((metric), shard, tagname, tagvalue)
) WITH CLUSTERING ORDER BY (shard DESC, tagname ASC, tagvalue ASC);

CREATE MATERIALIZED VIEW tsorage.reverse_dynamic_tagset AS
    SELECT tagname, tagvalue, shard, metric
    FROM tsorage.dynamic_tagset
    WHERE shard IS NOT NULL AND tagname IS NOT NULL AND tagvalue IS NOT NULL AND metric IS NOT NULL
    PRIMARY KEY (( tagname, tagvalue ), shard, metric)
WITH CLUSTERING ORDER BY (shard DESC);


INSERT INTO tsorage.dynamic_tagset (metric, shard, tagname, tagvalue) VALUES ('my_metric', '2019-09', 'owner', 'nsa');
INSERT INTO tsorage.dynamic_tagset (metric, shard, tagname, tagvalue) VALUES ('my_metric', '2019-09', 'quality', 'good');
INSERT INTO tsorage.dynamic_tagset (metric, shard, tagname, tagvalue) VALUES ('my_metric', '2019-09', 'quality', 'not-so-good');
INSERT INTO tsorage.dynamic_tagset (metric, shard, tagname, tagvalue) VALUES ('my_metric 2', '2019-09', 'quality', 'not-so-good');
