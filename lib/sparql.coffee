request = require 'request'
querystring = require 'querystring'

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

exports.ensure_prefixes = ensure_prefixes
exports.does_query_have_prefixes = does_query_have_prefixes
exports.compose_prefix_string = compose_prefix_string

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
    del = (if inverted then ['?x', p, s] else [s, p, '?x']).join ' '
    if o?
      ins = (if inverted then [o, p, s] else [s, p, o]).join ' '
      q = "modify #{g} delete { #{del} } insert { #{ins} } where { optional{ #{del} } }"
    else
      q = "delete from #{g} { #{del} } where { #{del} } "
    console.log q
    @query q, (err, res) -> cb? err, res

exports.Client = Client