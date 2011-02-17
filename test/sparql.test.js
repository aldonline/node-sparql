(function() {
  var assert, s, sparql, x;
  require('coffee-script');
  sparql = require('../lib/sparql');
  assert = require('assert');
  x = exports;
  s = new sparql.SPARQLHTTPClient('http://localhost:8890/sparql');
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
}).call(this);
