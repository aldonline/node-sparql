(function() {
  var assert, s, sparql, x;
  require('coffee-script');
  sparql = require('../lib/sparql');
  assert = require('assert');
  x = exports;
  s = new sparql.Client('http://localhost:8896/sparql');
  console.log(sparql.generate_set_sparql('G', null, 'P', 'S', true));
  x.test_prefixes = function() {
    var ap, empty_prefix_map, prefix_map, prefixed_query, unprefixed_query;
    prefixed_query = ' prefix foo: <urn:foo> select * where {?s ?p ?o}';
    unprefixed_query = 'select * where {?s ?p ?o}';
    assert.equal(sparql.does_query_have_prefixes(prefixed_query), true);
    assert.equal(sparql.does_query_have_prefixes(unprefixed_query), false);
    prefix_map = {
      bar: 'urn:bar'
    };
    empty_prefix_map = {};
    ap = sparql.ensure_prefixes;
    assert.equal(ap(prefixed_query, prefix_map), prefixed_query);
    assert.equal(ap(prefixed_query, empty_prefix_map), prefixed_query);
    assert.notEqual(ap(unprefixed_query, prefix_map), unprefixed_query);
    return assert.equal(ap(unprefixed_query, empty_prefix_map), unprefixed_query);
  };
  x.test_query_returns_results = function() {
    return s.query('select * where {?s ?p ?o} limit 10', function(err, res) {
      var _ref;
      assert.ok(res != null, 'result must be defined');
      assert.ok(((_ref = res.results) != null ? _ref.bindings : void 0) != null, 'and be a proper SPARQL results JSON object');
      return assert.equal(res.results.bindings.length, 10, 'and contain 10 bindings');
    });
  };
  x.test_cell = function() {
    var o1, p1, s1;
    s1 = 'http://www.openlinksw.com/virtrdf-data-formats#default-iid';
    p1 = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type';
    o1 = 'http://www.openlinksw.com/schemas/virtrdf#QuadMapFormat';
    return s.cell("select * where { <" + s1 + "> <" + p1 + "> ?v }", function(err, res) {
      assert.ok(res != null, 'one() result must be defined');
      assert.equal(res.type, 'uri', 'and its type must be URI');
      return assert.equal(res.value, o1);
    });
  };
  x.test_row = function() {
    return s.row('select * where {?s ?p ?o} limit 10', function(err, res) {
      assert.ok(res != null, 'result must be defined');
      assert.ok(res.s != null, 'and contain variable s');
      assert.ok(res.p != null, 'and contain variable p');
      assert.ok(res.o != null, 'and contain variable o');
      assert.equal(res.s.type, 'uri', 'subject must be of type URI');
      return assert.equal(res.p.type, 'uri', 'predicate must be of type URI');
    });
  };
  x.test_col = function() {
    return s.col('select distinct ?s where {?s ?p ?o} limit 10', function(err, res) {
      assert.ok(res != null, 'result must be defined');
      assert.equal(res.length, 10);
      return assert.equal(res[2].type, 'uri');
    });
  };
  x.test_set = function() {
    var _g, _p, _s;
    _g = '<urn:test:graph>';
    _s = '<urn:test:s1>';
    _p = '<urn:test:p1>';
    return s.set(_g, _s, _p, 1, false, function(err, res) {
      assert.ok(res != null, 'result must be defined');
      return s.cell("select ?v from " + _g + " where { " + _s + " " + _p + " ?v }", function(err, res) {
        assert.equal(res.value, '1');
        return s.set(_g, _s, _p, null, false, function(err, res) {
          assert.ok(res != null, 'result must be defined');
          return s.cell("select ?v from " + _g + " where { " + _s + " " + _p + " ?v }", function(err, res) {
            assert.equal(res, null);
            return s.set(_g, _s, _p, [1, 2, 3], false, function(err, res) {
              assert.ok(res != null, 'result must be defined');
              return s.col("select ?v from " + _g + " where { " + _s + " " + _p + " ?v }", function(err, res) {
                assert.equal(res.length, 3);
                return s.set(_g, _s, _p, [], false, function(err, res) {
                  assert.ok(res != null, 'result must be defined');
                  return s.col("select ?v from " + _g + " where { " + _s + " " + _p + " ?v }", function(err, res) {
                    return assert.equal(res.length, 0);
                  });
                });
              });
            });
          });
        });
      });
    });
  };
  /*
  sparql
  modify <urn:test:graph> delete { <urn:test:s1> <urn:test:p1> ?x } insert { <urn:test:s1> <urn:test:p1> 1 } where { optional{ <urn:test:s1> <urn:test:p1> ?x } }
  ;


  */
}).call(this);
