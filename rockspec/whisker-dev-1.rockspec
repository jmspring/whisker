package = "whisker"
version = "dev-1"

source = {
   url = "git://github.com/jmspring/whisker.git",
   branch = "main"
}

description = {
   summary = "Interactive fiction authoring system",
   detailed = [[
      Whisker is a powerful interactive fiction engine that allows
      authors to create branching narrative experiences. Similar to
      Twine but powered by Lua.
   ]],
   homepage = "https://github.com/jmspring/whisker",
   license = "MIT"
}

dependencies = {
   "lua >= 5.1",
   "luafilesystem >= 1.8.0",
   "lpeg >= 1.0.0"
}

build = {
   type = "builtin",
   modules = {
      ["whisker.core.story"] = "lib/whisker/core/story.lua",
      ["whisker.core.passage"] = "lib/whisker/core/passage.lua",
      ["whisker.core.choice"] = "lib/whisker/core/choice.lua",
      ["whisker.core.engine"] = "lib/whisker/core/engine.lua",
      ["whisker.core.game_state"] = "lib/whisker/core/game_state.lua",
      ["whisker.format.twine_importer"] = "lib/whisker/format/twine_importer.lua",
      ["whisker.format.whisker_loader"] = "lib/whisker/format/whisker_loader.lua",
      ["whisker.tools.validator"] = "lib/whisker/tools/validator.lua",
      ["whisker.tools.debugger"] = "lib/whisker/tools/debugger.lua",
      ["whisker.tools.profiler"] = "lib/whisker/tools/profiler.lua",
      ["whisker.utils.json"] = "lib/whisker/utils/json.lua",
      ["whisker.utils.string_utils"] = "lib/whisker/utils/string_utils.lua"
   },
   install = {
      bin = {
         whisker = "bin/whisker"
      }
   }
}