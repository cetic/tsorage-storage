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
 * The tagset table for storing the static tagset of all metrics.
 */
CREATE TABLE tsorage.tagset (
    metric text,
    tagset map<text, text>,
    PRIMARY KEY (metric)
);

INSERT INTO "tsorage"."tagset" ("metric", "tagset") VALUES ('my_metric', {'owner':'mg', 'quality':'good'});

UPDATE tsorage.tagset
SET tagset['kind'] = 'foo'
WHERE metric = 'my_metric';

/**
  * The reverse tagset table, for storing the metrics associated with a static tagset.
 */
 CREATE TABLE tsorage.reverse_tagset (
     tagname text,
     tagvalue text,
     metrics set<text>,
     PRIMARY KEY ( tagname, tagvalue )
 ) WITH CLUSTERING ORDER BY (tagvalue ASC);

UPDATE tsorage.reverse_tagset
SET metrics = metrics - {'my_metric'}
WHERE tagname = 'owner' and tagvalue = 'mg';

