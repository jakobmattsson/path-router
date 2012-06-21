extractParams = (pageParts, pathParts) ->
  pageParts.reduce (memo, pagePart, index) ->
    if memo && pagePart.slice(0, 1) == ":"
      memo[pagePart.slice(1)] = pathParts[index]
    else if pathParts[index] != pagePart then return null
    memo
  , {}

findMatches = (functions, path) ->
  pathParts = path.split '/'
  Object.keys(functions).map((page) ->
    pageParts = page.split '/'
    if pageParts.length == pathParts.length
      params = extractParams pageParts, pathParts
      return { page: page, params: params } if params
    null
  ).filter (e) -> e


exports.create = () ->
  functions = {}

  trigger = (path, done) ->
    matches = findMatches functions, path
    done ?= ->

    paramCounts = matches.map (m) -> Object.keys(m.params).length
    minParams = Math.min(paramCounts...)
    matches = matches.filter (m) -> Object.keys(m.params).length == minParams

    if matches.length == 0
      done 'no matches'
    else if matches.length > 1
      done 'more than one match'
    else
      functions[matches[0].page] matches[0].params, done

  register = (path, callback) ->
    functions[path] = callback

  { trigger: trigger, register: register }
