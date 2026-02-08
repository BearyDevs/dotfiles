return {
  name = "yarn",
  builder = function(params)
    return {
      cmd = { "yarn" },
      args = { params.script },
      components = {
        { "on_output_quickfix", open = true },
        "default",
      },
    }
  end,
  params = {
    script = {
      desc = "Script to run",
      type = "enum",
      choices = function()
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

        -- Add common yarn commands
        local common_commands = { "install", "add", "remove", "upgrade", "audit" }
        for _, cmd in ipairs(common_commands) do
          table.insert(scripts, cmd)
        end

        return scripts
      end,
      default = "dev",
    },
  },
  condition = {
    filetype = { "javascript", "typescript", "json", "javascriptreact", "typescriptreact" },
    callback = function()
      local cwd = vim.fn.getcwd()
      local has_package_json = vim.fn.filereadable(cwd .. "/package.json") == 1
      local has_yarn_lock = vim.fn.filereadable(cwd .. "/yarn.lock") == 1

      -- Only show yarn if both package.json and yarn.lock exist
      return has_package_json and has_yarn_lock
    end,
  },
}
