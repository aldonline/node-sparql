### Using

    sparql = require 'sparql'
    s = new sparql.SPARQLHTTPClient 'http://dbpedia.org/sparql'
    s.query 'select * where { ?s ?p ?o }', (err, res) ->
      console.log res

