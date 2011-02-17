request = require 'request'
querystring = require 'querystring'

get_one_key = (obj) ->
  for k of obj
    return k

class SPARQLHTTPClient
  constructor: ( @url ) ->
    @prefix_map = {}
  query : ( query, cb ) ->
    opts =
      uri: @url
      headers:
        'content-type':'application/x-www-form-urlencoded'
      body: querystring.stringify (query:query, format:'application/json')
      encoding: 'utf8'
    request.post opts, (err, res, body) ->
      if res.statusCode is 200
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


exports.SPARQLHTTPClient = SPARQLHTTPClient
exports.cli = (url) -> new SPARQLHTTPClient url