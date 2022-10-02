local mason_package = require("mason-core.package")
local mason_registry = require("mason-registry")
local null_ls = require("null-ls")

local null_sources = {}

for _, package in ipairs(mason_registry.get_installed_packages()) do
        local package_categories = package.spec.categories[1]
        if package_categories == mason_package.Cat.Formatter then
                table.insert(null_sources, null_ls.builtins.formatting[package.name])
        end
        if package_categories == mason_package.Cat.Linter then
                table.insert(null_sources, null_ls.builtins.diagnostics[package.name])
        end
end

null_ls.setup({
        sources = null_sources,
})
