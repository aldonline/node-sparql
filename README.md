### Using

    sparql = require 'sparql'
    s = new sparql.SPARQLHTTPClient 'http://dbpedia.org/sparql'
    s.query 'select * where { ?s ?p ?o }', (err, res) ->
      console.log res

If you find that too verbose

    require('sparql').cli('http://dbpedia.org/sparql').query 'select * where {?s ?p ?o }', (err, res) ->
      console.log res
