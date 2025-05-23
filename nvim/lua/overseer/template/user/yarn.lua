return {
  name = "yarn",
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

    -- Add common yarn commands even if not in package.json
    local common_commands = { "install", "add", "remove", "upgrade", "audit" }
    for _, cmd in ipairs(common_commands) do
      table.insert(scripts, cmd)
    end

    return {
      cmd = "yarn",
      args = function(params)
        if
          params.script == "install"
          or params.script == "add"
          or params.script == "remove"
          or params.script == "upgrade"
          or params.script == "audit"
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
      return vim.fn.filereadable(vim.fn.getcwd() .. "/yarn.lock") == 1
        or vim.fn.filereadable(vim.fn.getcwd() .. "/package.json") == 1
    end,
  },
}
