local options = require "luacheck.options"
local stds = require "luacheck.stds"
local fs = require "luacheck.fs"
local utils = require "luacheck.utils"

local config = {}

-- Config must support special metatables for some keys:
-- autovivification for `files`, fallback to built-in stds for `stds`.

local special_mts = {
   stds = {__index = stds},
   files = {__index = function(files, key)
      files[key] = {}
      return files[key]
   end}
}

local function make_config_env_mt()
   local env_mt = {}
   local special_values = {}

   for key, mt in pairs(special_mts) do
      special_values[key] = setmetatable({}, mt)
   end

   function env_mt.__index(_, key)
      if special_mts[key] then
         return special_values[key]
      else
         return _G[key]
      end
   end

   function env_mt.__newindex(env, key, value)
      if special_mts[key] then
         if type(value) == "table" then
            setmetatable(value, special_mts[key])
         end

         special_values[key] = value
      else
         rawset(env, key, value)
      end
   end

   return env_mt, special_values
end

local function make_config_env()
   local mt, special_values = make_config_env_mt()
   return setmetatable({}, mt), special_values
end

local function remove_env_mt(env, special_values)
   setmetatable(env, nil)
   utils.update(env, special_values)
end

local top_options = {
   color = utils.has_type("boolean"),
   codes = utils.has_type("boolean"),
   formatter = utils.either(utils.has_type("string"), utils.has_type("function")),
   cache = utils.either(utils.has_type("string"), utils.has_type("boolean")),
   jobs = function(x) return type(x) == "number" and math.floor(x) == x and x >= 1 end,
   files = utils.has_type("table"),
   stds = utils.has_type("table"),
   exclude_files = utils.array_of("string"),
   include_files = utils.array_of("string")
}

utils.update(top_options, options.all_options)
options.add_order(top_options)

-- Returns error or nil if options are valid.
local function validate_options(option_set, opts)
   local ok, invalid_field = options.validate(option_set, opts)

   if not ok then
      if invalid_field then
         return ("invalid value of option '%s'"):format(invalid_field)
      else
         return "validation error"
      end
   end
end

-- Returns error or nil if config is valid.
local function validate_config(conf)
   local top_err = validate_options(top_options, conf)

   if top_err then
      return top_err
   end

   for path, opts in pairs(conf.files) do
      if type(path) == "string" then
         local override_err = validate_options(options.all_options, opts)

         if override_err then
            return ("%s in options for path '%s'"):format(override_err, path)
         end
      end
   end
end

-- Returns table with field `paths` containing sorted normalize paths
-- used in overrides and `options` mapping these paths to options.
local function normalize_overrides(files, abs_conf_dir)
   local overrides = {paths = {}, options = {}}

   local orig_paths = {}

   for path in pairs(files) do
      table.insert(orig_paths, path)
   end

   table.sort(orig_paths)

   for _, orig_path in ipairs(orig_paths) do
      local path = fs.normalize(fs.join(abs_conf_dir, orig_path))

      if not overrides.options[path] then
         table.insert(overrides.paths, path)
      end

      overrides.options[path] = files[orig_path]
   end

   table.sort(overrides.paths)
   return overrides
end

local function try_load(path)
   local src = utils.read_file(path)

   if not src then
      return
   end

   local func, err = utils.load(src, nil, "@"..path)
   return err or func
end

local function add_relative_loader(conf)
   local function loader(modname)
      local modpath = fs.join(conf.rel_dir, modname:gsub("%.", utils.dir_sep))
      return try_load(modpath..".lua") or try_load(modpath..utils.dir_sep.."init.lua"), modname
   end

   table.insert(package.loaders or package.searchers, 1, loader)
   return loader
end

local function remove_relative_loader(loader)
   for i, func in ipairs(package.loaders or package.searchers) do
      if func == loader then
         table.remove(package.loaders or package.searchers, i)
         return
      end
   end
end

config.default_path = ".luacheckrc"
config.empty_config = {empty = true}

-- Loads config from path, returns config object or nil and error message.
function config.load_config(path)
   local is_default_path = not path
   path = path or config.default_path

   local current_dir = fs.current_dir()
   local abs_conf_dir, rel_conf_dir = fs.find_file(current_dir, path)

   if not abs_conf_dir then
      if is_default_path then
         return config.empty_config
      else
         return nil, "Couldn't find configuration file "..path
      end
   end

   local conf = {
      abs_dir = abs_conf_dir,
      rel_dir = rel_conf_dir,
      cur_dir = current_dir
   }

   local conf_path = fs.join(rel_conf_dir, path)
   local env, special_values = make_config_env()
   local loader = add_relative_loader(conf)
   local load_ok, ret = utils.load_config(conf_path, env)
   remove_relative_loader(loader)

   if not load_ok then
      return nil, ("Couldn't load configuration from %s: %s error"):format(conf_path, ret)
   end

   -- Support returning some options from config instead of setting them as globals.
   -- This allows easily loading options from another file, for example using require.
   if type(ret) == "table" then
      utils.update(env, ret)
   end

   remove_env_mt(env, special_values)

   -- Update stds before validating config - std validation relies on that.
   if type(env.stds) == "table" then
      -- Ideally config shouldn't mutate global stds, not if `luacheck.config` becomes public
      -- interface.
      utils.update(stds, env.stds)
   end

   local err = validate_config(env)

   if err then
      return nil, ("Couldn't load configuration from %s: %s"):format(conf_path, err)
   end

   conf.options = env
   conf.overrides = normalize_overrides(env.files, abs_conf_dir)
   return conf
end

-- Adjusts path starting from config dir to start from current directory.
function config.relative_path(conf, path)
   if conf.empty then
      return path
   else
      return fs.join(conf.rel_dir, path)
   end
end

-- Requires module from config directory.
-- Returns success flag and module or error message.
function config.relative_require(conf, modname)
   local loader

   if not conf.empty then
      loader = add_relative_loader(conf)
   end

   local ok, mod_or_err = pcall(require, modname)

   if not conf.empty then
      remove_relative_loader(loader)
   end

   return ok, mod_or_err
end

-- Returns top-level options.
function config.get_top_options(conf)
   return conf.empty and {} or conf.options
end

-- Returns array of options for a file.
function config.get_options(conf, file)
   if conf.empty then
      return {}
   end

   local res = {conf.options}

   if type(file) ~= "string" then
      return res
   end

   local path = fs.normalize(fs.join(conf.cur_dir, file))

   for _, override_path in ipairs(conf.overrides.paths) do
      if fs.is_subpath(override_path, path) then
         table.insert(res, conf.overrides.options[override_path])
      end
   end

   return res
end

return config
