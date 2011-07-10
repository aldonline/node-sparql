require 'coffee-script'
sparql = require '../lib/sparql'
assert = require 'assert'

x = exports

s = new sparql.Client 'http://localhost:8890/sparql'

x.test_prefixes = ->
  prefixed_query = ' prefix foo: <urn:foo> select * where {?s ?p ?o}'
  unprefixed_query = 'select * where {?s ?p ?o}'
  assert.equal sparql.does_query_have_prefixes(prefixed_query), yes
  assert.equal sparql.does_query_have_prefixes(unprefixed_query), no
  
  prefix_map = bar:'urn:bar'
  empty_prefix_map = {}
  
  ap = sparql.ensure_prefixes
  
  assert.equal ap( prefixed_query, prefix_map ), prefixed_query
  assert.equal ap( prefixed_query, empty_prefix_map ), prefixed_query
  
  assert.notEqual ap( unprefixed_query, prefix_map ), unprefixed_query
  assert.equal ap( unprefixed_query, empty_prefix_map ), unprefixed_query

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

# sparql select * from <urn:test:graph> where { ?s ?p ?o };

x.test_set = ->
  _g = '<urn:test:graph>'
  _s = '<urn:test:s1>'
  _p = '<urn:test:p1>'
  # 1) subject.predicate = 1
  s.set _g, _s, _p, 1, no, (err, res) ->
    assert.ok res?, 'result must be defined'
    
    s.cell "select ?v from #{_g} where { #{_s} #{_p} ?v }", (err, res) ->
      assert.equal res.value, '1'

      # 2) subject.predicate = null
      s.set _g, _s, _p, null, no, (err, res) ->
      assert.ok res?, 'result must be defined'
      
      s.cell "select ?v from #{_g} where { #{_s} #{_p} ?v }", (err, res) ->
          assert.equal res, null, 'failed'
          
          # 3) subject.predicate = [1,2,3]
          s.set _g, _s, _p, [1,2,3], no, (err, res) ->
            assert.ok res?, 'result must be defined'
            s.col "select ?v from #{_g} where { #{_s} #{_p} ?v }", (err, res) ->
              assert.equal res.length, 3
            
              # 4) subject.predicate = [6]
              s.set _g, _s, _p, [], no, (err, res) ->
                assert.ok res?, 'result must be defined'
                s.col "select ?v from #{_g} where { #{_s} #{_p} ?v }", (err, res) ->
                  assert.equal res.length, 0

###
sparql
modify <urn:test:graph> delete { <urn:test:s1> <urn:test:p1> ?x } insert { <urn:test:s1> <urn:test:p1> 1 } where { optional{ <urn:test:s1> <urn:test:p1> ?x } }
;


###



