A First Level Header
====================

Getting Started
--------------------

### Install

npm install sparql

### Use

    sparql = require 'sparql'
    sparql_client = new sparql.SPARQLHTTPClient 'http://dbpedia.org/sparql'
    sparql_client.query 'select * where { ?s ?p ?o } limit 100', (err, res) ->
      console.log res

If you find that too verbose, you can create a simple client via the 'cli()' factory method

    sparql_client = require('sparql').cli 'http://dbpedia.org/sparql'
    sparql_client.query 'select * where {?s ?p ?o }', (err, res) ->
      console.log res

In both cases, the result of calling the query() function will be a raw object containing an object conforming to the SPARQL-JSON[1] results format. 

API
--------------------

### query

Low level function. Returns the complete SPARQL-JSON[1] results object.

    sparql_client.query 'select * where {?s ?p ?o} limit 10', (err, res) ->
      console.log row.s for row in res.results.bindings

### rows

Convenience method to get to the rows directly. Builds on top of sparql.query, like most of the
other query methods.

    sparql_client.query 'select * where {?s ?p ?o} limit 10', (err, res) ->
      console.log row.s for row in res

### row

Convenience method that only returns the first row in the result set

    sparql_client.query 'select * where {?s ?p ?o} limit 10', (err, res) ->
      console.log res.s

### col

Convenience method that returns an array of with the first value of each row

    sparql_client.col 'select distinct ?name where {?s foaf:name ?name} limit 10', (err, res) ->
      console.log( rdf_value.value ) for rdf_value in res


What's with the rdf_value.value part?
Read the SPARQL-JSON[1] results format specification page.

[1] http://www.w3.org/TR/rdf-sparql-json-res/


