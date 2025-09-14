-- Extends table methods

function table.each(list, fn)
  if #list == 0 then return end
  for i, v in ipairs(list) do fn(v, i) end
end

function table.reverseEach(list, fn)
  if #list == 0 then return end
  for i=#list, 1, -1 do fn(list[i], i) end
end

function table.map(list, fn)
  t = {}
  for i, v in ipairs(list) do t[i] = fn(v) end
  return t
end

function table.reverseMap(list, fn)
  t = {}
  for i=#list, 1, -1 do t[i] = fn(list[i], i) end
  return t
end

function table.filter(list, fn)
  t = {}
  for i, v in ipairs(list) do if fn(v) then table.insert(t, v) end end
  return t
end

function table.keys(t)
  t2 = {}
  for k, _v in pairs(t) do table.insert(t2, k) end
  return t2
end

function table.values(t)
  t2 = {}
  for _k, v in pairs(t) do table.insert(t2, v) end
  return t2
end
