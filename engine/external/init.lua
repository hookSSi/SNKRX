local path = ...
if not path:find("init") then
  binser = require(path .. ".binser")
  mlib = require(path .. ".mlib")
  -- if not web then clipper = require(path .. ".clipper") end
  ripple = require(path .. ".ripple")
  utf8 = require(path .. ".utf8")
  json = require(path .. ".json")
  steam = require 'luasteam'
end
