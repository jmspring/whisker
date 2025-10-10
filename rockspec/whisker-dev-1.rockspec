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
      ["whisker.core.story"] = "src/core/story.lua",
      ["whisker.core.passage"] = "src/core/passage.lua",
      ["whisker.core.variables"] = "src/core/variables.lua",
      ["whisker.parser.story_parser"] = "src/parser/story_parser.lua",
      ["whisker.runtime.engine"] = "src/runtime/engine.lua"
   },
   install = {
      bin = {
         whisker = "bin/whisker"
      }
   }
}