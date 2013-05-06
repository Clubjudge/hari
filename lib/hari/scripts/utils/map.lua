function _h.map(array, func)
  local new_array = {}

  for i,v in ipairs(array) do
    new_array[i] = func(v)
  end

  return new_array
end
