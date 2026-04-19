package = "cdescriptor"
version = "0.1.0-1"

source = {
   url = "git+https://github.com/tuusuario/cdescriptor"
}

description = {
   summary = "ESO addon — character build exporter",
   license = "MIT"
}

-- lua >= 5.1: the addon code must be 5.1-compatible, but the dev toolchain
-- (busted, luacheck) runs fine on 5.4 (the version installed by DEVCOM.Lua).
dependencies = {
   "lua >= 5.1",
   "busted >= 2.0",
   "luacheck >= 1.0"
}

build = {
   type = "none"
}
