-- Author: Arnau Prat <arnau.prat@gmail.com>
-- 
--
-- Nvim plugin to jump to compiler error locations. The plugin searches for
-- error lines in the current buffer (presumably, containing the output of a
-- compiler) and let's the user to jump to the location (file ana line) with the
-- compilation error
--
-- Commands
-- 
-- :GotoError NextMessage -> Jumps to the next error message from the current
-- position
-- :GotoError PreviousMessage -> Jumps to the previous error message from the
-- current position
-- :GotoError Jump -> Jumps to the file and line located in the current line


----------------------------------------------------------
-----------------------------------------------------------
----------------------------------------------------------
-- Helper Methods 

-- Prints a log message
local log = function(msg)
  print('INFO gotoerror: ' .. msg)
end

-- Helper method to find the buffer containing the given filename
-- filename: the path of the file to find the nvim buffer of 
-- returns nil if not found
local find_nvim_buffer = function(filename)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local buf_name =  vim.api.nvim_buf_get_name(buf)
      if buf_name == filename then
        return buf
      end
    end
  end
  return nil 
end

-- Helper method to find the tab and win in the tab that contains a given buffer, if any
-- buf: The buffer to find the nvim tabpage and window of. 
-- returns nil, nil if not found
local find_nvim_buffer_tabpage_and_win = function(buf)
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      if vim.api.nvim_win_get_buf(win) == buf
        then
          return tab, win
        end
      end
    end
    return nil, nil 
  end

----------------------------------------------------------
-----------------------------------------------------------
----------------------------------------------------------
-- Command implementations 

-- GotoError NextMessage: called to go to next error instance 
local next_error_msg = function()
  -- log("next message")
  local buffer_handle = vim.api.nvim_get_current_buf()
  local result = -1
  vim.api.nvim_buf_call(buffer_handle, function() 
    result = vim.fn.search('error')
  end)
end

-- GotoError Ncalled to go to previous error instance
local previous_error_msg = function()
  -- log("previous message")
  local buffer_handle = vim.api.nvim_get_current_buf()
  local result = -1
  vim.api.nvim_buf_call(buffer_handle, function() 
    result = vim.fn.search('error', 'b')
  end)
end

-- GotoError Jump: called to jump to error location 
local jump_to_error = function()
  -- log("jump")
  local buffer_handle = vim.api.nvim_get_current_buf()
  local current_line = vim.api.nvim_get_current_line()
  for path, line in current_line:gmatch(gotoerror.regex) do
    buffer_handle = find_nvim_buffer(path)
    if buffer_handle == nil then
      -- buffer handle not found. Open in new tab
      vim.api.nvim_command(':tabe +' .. line .. " " .. path)
    else
      tab, win = find_nvim_buffer_tabpage_and_win(buffer_handle)
      if tab == nil or win == nil
        then
          -- Open desired buffer in new tab
          vim.api.nvim_command(':tabe')
          vim.api.nvim_command(':b ' .. buffer_handle)
        else
          -- There is a tabpage with a window with the desired buffer already
          -- opened 
          vim.api.nvim_set_current_tabpage(tab)
          vim.api.nvim_set_current_win(win)
          vim.api.nvim_command(':' .. line)
        end
      end
      -- Interested in the first match, so break
      break
    end
  end

-----------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------


-- GotoError nvim command handler
local exec_command = function(data)
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


-----------------------------------------------------------
-----------------------------------------------------------
-----------------------------------------------------------
-- Script Start Here

-- Global object
  gotoerror = {
    command     = exec_command,
    regex       = "([a-zA-Z:]+:[a-zA-Z0-9:\\._\\-]+)[(]([0-9]+)[)]",
  }

-- Registering commands
vim.api.nvim_create_user_command('GotoError', gotoerror.command, { nargs = '*' })
