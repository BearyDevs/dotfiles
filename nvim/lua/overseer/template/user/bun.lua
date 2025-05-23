return {
  name = "bun",
  builder = function()
    local scripts = {}
    local package_json = vim.fn.getcwd() .. "/package.json"

    if vim.fn.filereadable(package_json) == 1 then
      local content = vim.fn.readfile(package_json)
      local json_str = table.concat(content, "\n")
      local ok, json = pcall(vim.fn.json_decode, json_str)

      if ok and json.scripts then
        for script_name, _ in pairs(json.scripts) do
          table.insert(scripts, script_name)
        end
        table.sort(scripts)
      end
    end

    -- Add common bun commands
    local common_commands = { "install", "add", "remove", "update", "run", "build", "test" }
    for _, cmd in ipairs(common_commands) do
      if not vim.tbl_contains(scripts, cmd) then
        table.insert(scripts, cmd)
      end
    end

    return {
      cmd = "bun",
      args = function(params)
        if
          params.script == "install"
          or params.script == "add"
          or params.script == "remove"
          or params.script == "update"
        then
          return { params.script }
        else
          return { params.script }
        end
      end,
      components = {
        { "on_output_quickfix", open = true },
        "default",
      },
      params = {
        script = {
          desc = "Script to run",
          type = "enum",
          choices = scripts,
          default = "dev",
        },
      },
    }
  end,
  condition = {
    filetype = { "javascript", "typescript", "json", "javascriptreact", "typescriptreact" },
    callback = function()
      return vim.fn.filereadable(vim.fn.getcwd() .. "/bun.lockb") == 1
        or vim.fn.filereadable(vim.fn.getcwd() .. "/package.json") == 1
    end,
  },
}
