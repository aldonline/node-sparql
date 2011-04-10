request = require 'request'
querystring = require 'querystring'

normalize_v = (v) ->
  return null unless v?
  if v instanceof Array
    if v.length is 0
      return null
    else
      return v
  else
    return [v]

get_one_key = (obj) ->
  for own k of obj
    return k

compose_prefix_string = (prefix_map) ->
  ( "prefix #{k}: <#{v}>" for k, v of prefix_map ).join ' '

does_query_have_prefixes = (query) ->
  # TODO: should be regex
  # for now, simple heuristic. "prefix" must happen within the first 10 chars
  iof = query.toLowerCase().indexOf 'prefix'
  0 < iof < 10

ensure_prefixes = (query, prefix_map) ->
  s = compose_prefix_string prefix_map
  if s.length is 0 or does_query_have_prefixes query then query else s + ' ' + query

generate_set_sparql = ( g, s, p, o, inverted, cb ) ->
  [e, a, v] = if inverted then [o, p, s] else [s, p, o]
  v = normalize_v v
  del = (if inverted then ['?x', a, e] else [e, a, '?x']).join ' '
  if v?
    ins =  ((if inverted then [val, a, e] else [e, a, val]).join ' ' for val in v).join ' . '
    q = "modify #{g} delete { #{del} } insert { #{ins} } where { optional{ #{del} } }"
  else
    q = "delete from #{g} { #{del} } where { #{del} } "

exports.ensure_prefixes = ensure_prefixes
exports.does_query_have_prefixes = does_query_have_prefixes
exports.compose_prefix_string = compose_prefix_string
exports.generate_set_sparql = generate_set_sparql

class Client
  
  constructor: ( @url ) ->
    @prefix_map = {}
  
  query : ( query, cb ) ->
    query = ensure_prefixes query, @prefix_map
    console?.log query if @log_query? # quick n' dirty logging option
    opts =
      uri: @url
      headers:
        'content-type':'application/x-www-form-urlencoded'
      body: querystring.stringify (query:query, format:'application/json')
      encoding: 'utf8'
    request.post opts, (err, res, body) ->
      if res?.statusCode is 200
        cb? null, JSON.parse body
      else
        cb? [err, res, body]
  
  rows : ( query, cb ) ->
    @query query, (err, res) ->
      if err?
        cb err
        return
      if res?
        cb null, res.results.bindings
      else
        cb null, null
  
  cell : ( query, cb ) ->
    @row query, (err, res) ->
      if err?
        cb err
        return
      if res?
        cb null, res[ get_one_key res ]
      else
        cb null, null
  
  row : ( query, cb ) ->
    @query query, (err, res) ->
      if err?
        cb err
        return
      b = res.results.bindings
      if b.length is 0
        cb null, null
      else
        cb null, b[0]
  
  col : ( query, cb ) ->
    @query query, (err, res) ->
      if err?
        cb err
        return
      bs = res.results.bindings
      if bs.length is 0
        cb null, []
      else
        key = get_one_key bs[0]
        cb null, (b[key] for b in bs)
  
  set : ( g, s, p, o, inverted, cb ) ->
    q = generate_set_sparql g, s, p, o, inverted
    @query q, (err, res) -> cb? err, res

exports.Client = Client