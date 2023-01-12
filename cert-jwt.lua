local version = _VERSION:match("%d+%.%d+")
package.path = package.path .. ';./rocks/share/lua/' .. version .. '/?.lua'
package.cpath = package.cpath .. ';./rocks/lib/lua/' .. version .. '/?.so'

local jwt = require "luajwt"

if not config then
   config = {
      alg = "HS256"
   }
end

local haproxyTimestampPattern = "(%d%d)(%d%d)(%d%d)(%d%d)(%d%d)(%d%d)" -- YYMMDDhhmmss[Z]
local function toUnixEpoch(ts)
   local year, month, day, hour, minute, second = ts:match(haproxyTimestampPattern)
   return os.time({year = 2000 + year,
                   month = month,
                   day = day,
                   hour = hour,
                   min = minute,
                   sec = second})
end

function buildJwt(txn)
   if txn.f:ssl_c_used() == 1 and txn.f:req_hdr("authorization") == nil then
      local payload = {
         iss = txn.f:ssl_c_i_dn(),                   -- issuer, issuing certificate domain
         sub = txn.f:ssl_c_s_dn("CN"),               -- subject, client certificate common name
         iat = os.time(),                            -- issued at
         nbf = toUnixEpoch(txn.f:ssl_c_notbefore()), -- client certificate start date
         exp = toUnixEpoch(txn.f:ssl_c_notafter())   -- client certificate expiry date
      }
      local token, err = jwt.encode(payload, config.key, config.alg)
      txn.http:req_add_header("Authorization", "Bearer " .. token)
   end
end

-- called on load
core.register_init(function()
      config.alg = os.getenv("CERT_JWT_ALG") or config.alg
      config.key = os.getenv("CERT_JWT_KEY")

      if not config.key then
         core.Warning("Please set environment variable CERT_JWT_KEY")
      end
end)

-- called per request
core.register_action('buildJwt', {'http-req'}, buildJwt, 0)
