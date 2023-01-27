


local log = function(msg)
  print('INFO gotoerror: ' .. msg)
end

local create_buffer_entry = function ()
return {
  m_current_line = 0,
  m_test = 0
}
end

-- called to go to next error instance 
local next_error_msg = function()
  log("next message")
  local buffer_handle = vim.api.nvim_get_current_buf()
  local result = -1
  vim.api.nvim_buf_call(buffer_handle, function() 
    result = vim.fn.search('error')
  end)
  end

-- called to go to previous error instance
local previous_error_msg = function()
  log("previous message")
  local buffer_handle = vim.api.nvim_get_current_buf()
  local result = -1
  vim.api.nvim_buf_call(buffer_handle, function() 
    result = vim.fn.search('error', 'b')
  end)
end

-- called to jump to error location 
local jump_to_error = function(buffer)
  log("jump")
  local buffer_handle = vim.api.nvim_get_current_buf()
  local current_line = vim.api.nvim_get_current_line()
  local regexp = "[a-zA-Z:]+:[a-zA-Z0-9:\\._\\-]+[(][0-9]+[)]"
  res = current_line:match(regexp)
  if res == nil
    then
      log("pattern not found")
    else
      for path, line in res:gmatch("([a-zA-Z:]+:[a-zA-Z0-9:\\._\\-]+)[(]([0-9]+)[)]") do
        found_handle = nil
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) then
            local buf_name =  vim.api.nvim_buf_get_name(buf)
            if buf_name == path then
              found_handle = buf
            end
          end
        end
        if found_handle == nil then
          vim.api.nvim_command(':e +' .. line .. " " .. path)
        else
          vim.api.nvim_command(':b ' .. found_handle)
        end
      end
    end
  end


  -- exposed command handler
  local command = function(data)
  if data.args == 'NextMessage'
    then
      next_error_msg()
    else if data.args == 'PreviousMessage'
      then
      previous_error_msg()
    else if data.args == 'Jump'
      then
      jump_to_error()
      end
      end
    end

end

  -- Global object
gotoerror = {
  m_buffer_data = {}, 
  command      = command,
}

-- Registering commands
vim.api.nvim_create_user_command('GotoError', gotoerror.command, { nargs = '*' })
