return {
  cmd = function ()
    for _, fname in ipairs({ './vendor/bin/psalm', './vendor/bin/psalm.phar' }) do
      local local_psalm = vim.fn.fnamemodify(fname, ':p')
      local stat = vim.loop.fs_stat(local_psalm)
      if stat then
        return local_psalm
      end
    end
    return 'psalm'
  end,
  args = {
    '--output-format=json',
    '--show-info=true',
    '--no-progress',
  },
  parser = function(output)
    if output == nil then
      return {}
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)

    local messages = vim.json.decode(output)
    local diagnostics = {}

    for _, message in ipairs(messages or {}) do
      if message.file_path == filename then
        table.insert(diagnostics, {
          lnum = message.line_from - 1,
          end_lnum = message.line_to - 1,
          col = message.column_from - 1,
          end_col = message.column_to - 1,
          message = message.message,
          source = 'psalm',
          severity = message.severity,
        })
      end
    end

    return diagnostics
  end,
}
