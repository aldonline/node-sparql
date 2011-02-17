require 'coffee-script'
sparql = require '../lib/sparql'
assert = require 'assert'

x = exports

s = new sparql.SPARQLHTTPClient 'http://localhost:8890/sparql'

x.test_query_returns_results = ->
  s.query 'select * where {?s ?p ?o} limit 10', (err, res) ->
    assert.ok res?, 'result must be defined'
    assert.ok res.results?.bindings?, 'and be a proper SPARQL results JSON object'
    assert.equal res.results.bindings.length, 10, 'and contain 10 bindings'

x.test_cell = ->
  s1 = 'http://www.openlinksw.com/virtrdf-data-formats#default-iid'
  p1 = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
  o1 = 'http://www.openlinksw.com/schemas/virtrdf#QuadMapFormat'
  s.cell "select * where { <#{s1}> <#{p1}> ?v }", (err, res) ->
    assert.ok res?, 'one() result must be defined'
    assert.equal res.type, 'uri', 'and its type must be URI'
    assert.equal res.value, o1

x.test_row = ->
  s.row 'select * where {?s ?p ?o} limit 10', (err, res) ->
    assert.ok res?, 'result must be defined'
    assert.ok res.s?, 'and contain variable s'
    assert.ok res.p?, 'and contain variable p'
    assert.ok res.o?, 'and contain variable o'
    assert.equal res.s.type, 'uri', 'subject must be of type URI'
    assert.equal res.p.type, 'uri', 'predicate must be of type URI'

x.test_col = ->
  s.col 'select distinct ?s where {?s ?p ?o} limit 10', (err, res) ->
    assert.ok res?, 'result must be defined'
    assert.equal res.length, 10
    assert.equal res[2].type, 'uri'