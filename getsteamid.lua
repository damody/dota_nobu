
local cjson = require("cjson")
cjson.encode_sparse_array(true, 1)

local ltn12 = require("ltn12")
local io = require("io")
local http = require("socket.http")


function GetSteaminfo(id)

	local respbody = {} -- for the response body
	local reqbody = [[{ "UserInput" : "U:1:]]..id..[["}]]
	local result, respcode, respheaders, respstatus =  http.request{
	  url = "http://steamidfinder.com/Converter.asmx/SimpleData",
	  sink = ltn12.sink.table(respbody),
	  method = "POST",
	  headers = {
			["Host"] = "steamidfinder.com",
			["User-Agent"] = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:47.0) Gecko/20100101 Firefox/47.0",
			["Accept"] = "application/json, text/javascript, */*; q=0.01",
			["Accept-Language"] = "zh-TW,zh;q=0.8,en-US;q=0.5,en;q=0.3",
			["Accept-Encoding"] = "gzip, deflate",
			["DNT"] = "1",
			["Content-Type"] = "application/json; charset=utf-8",
			["X-Requested-With"] = "XMLHttpRequest",
			["Referer"] = "http://steamidfinder.com/",
			["Content-Length"] = tostring(#reqbody),
			["Connection"] = "keep-alive",
	  },
	  source = ltn12.source.string(reqbody),
	}
	respbody = cjson.decode(respbody[1])
	print(inspect(respbody.d))

	reqbody = [[{ "Profile" : "]]..respbody.d.steam64..[["}]]
	respbody = {}
	result, respcode, respheaders, respstatus =  http.request{
	  url = "http://steamidfinder.com/ProfileLoad.asmx/LoadProfile",
	  sink = ltn12.sink.table(respbody),
	  method = "POST",
	  headers = {
			["Host"] = "steamidfinder.com",
			["User-Agent"] = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:47.0) Gecko/20100101 Firefox/47.0",
			["Accept"] = "application/json, text/javascript, */*; q=0.01",
			["Accept-Language"] = "zh-TW,zh;q=0.8,en-US;q=0.5,en;q=0.3",
			["Accept-Encoding"] = "gzip, deflate",
			["DNT"] = "1",
			["Content-Type"] = "application/json; charset=utf-8",
			["X-Requested-With"] = "XMLHttpRequest",
			["Referer"] = "http://steamidfinder.com/",
			["Content-Length"] = tostring(#reqbody),
			["Connection"] = "keep-alive",
	  },
	  source = ltn12.source.string(reqbody),
	}
	respbody = cjson.decode(respbody[1])
	print(inspect(respbody.d))
end
GetSteaminfo(128732954)