
gotoerror = {
  buffer_data = {}, 

  -- called when openning a buffer
  on_open_buffer = function(buffer_handle)
    gotoerror.buffer_data[buffer_handle] = {
      current_line = 0
    }
  end,

  -- called when closing a buffer
  on_close_buffer = function(buffer_handle)
    gotoerror.buffer_data[buffer_handle] = nil
  end,
}

gotoerror.on_open_buffer("test")
print(vim.inspect(gotoerror))
gotoerror.on_close_buffer("test")
print(vim.inspect(gotoerror))

