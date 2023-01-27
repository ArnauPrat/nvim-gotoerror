

local create_buffer_entry = function ()
return {
  m_current_line = 0,
  m_test = 0
}
end


local find_buffer_entry  = function(buffer_handle)
  if gotoerror.m_buffer_data[buffer_handle] == nil 
    then
      gotoerror.m_buffer_data[buffer_handle] = create_buffer_entry()
    end
    return gotoerror.m_buffer_data[buffer_handle]
end



-- called to go to next error instance 
local next_error_msg = function(buffer_handle)
  local buffer_data = find_buffer_entry(buffer_handle)
  print(buffer_data)
  buffer_data.m_test = buffer_data.m_test + 1
  gotoerror.m_buffer_data[buffer_handle] = buffer_data
  end

  -- called to go to previous error instance
local previous_error_msg = function(buffer_handle)
  local buffer_data = find_buffer_entry(buffer_handle)
  buffer_data.m_test = buffer_data.m_test + 1
  gotoerror.m_buffer_data[buffer_handle] = buffer_data
  end

  -- called to jump to error place
  local jump_to_error = function(buffer)
  end


  -- Global object
  gotoerror = {
    m_buffer_data = {}, 
    next_error_msg      = next_error_msg,
    previous_error_msg  = previous_error_msg,
    jump_to_error       = jump_to_error,

  }

  gotoerror.next_error_msg("test")
  print(vim.inspect(gotoerror))
  gotoerror.previous_error_msg("test")
  print(vim.inspect(gotoerror))

