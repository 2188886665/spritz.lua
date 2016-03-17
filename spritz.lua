-- This is free and unencumbered software released into the public domain.
-- 
-- Anyone is free to copy, modify, publish, use, compile, sell, or
-- distribute this software, either in source code form or as a compiled
-- binary, for any purpose, commercial or non-commercial, and by any
-- means.
-- 
-- In jurisdictions that recognize copyright laws, the author or authors
-- of this software dedicate any and all copyright interest in the
-- software to the public domain. We make this dedication for the benefit
-- of the public at large and to the detriment of our heirs and
-- successors. We intend this dedication to be an overt act of
-- relinquishment in perpetuity of all present and future rights to this
-- software under copyright law.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
-- OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
-- 
-- For more information, please refer to <http://unlicense.org>
local spritz = {}

local function update()
  i = (i + w) % N
  j = (k + s[(j + s[i]) % N]) % N
  k = (i + k + s[j]) % N
  s[i], s[j] = s[j], s[i]
end

local function crush()
  for v = 0, N // 2 - 1 do
    local t = N - 1 - v
    if s[v] > s[t] then
      s[v], s[t] = s[t], s[v]
    end
  end
end

local function whip()
  for _ = 1, N * 2 do
    update()
  end
  w = w + 2
end

local function output()
  z = s[(j + s[(i + s[(z + k) % N]) % N]) % N]
  return z
end

local function shuffle()
  whip()
  crush()
  whip()
  crush()
  whip()
  a = 0
end

local function drip()
  if a > 0 then
    shuffle()
  end
  update()
  return output()
end

local function squeeze(l)
  if a > 0 then
    shuffle()
  end
  local r = ''
  for _ = 1, (l > N and N or l) do
    r = r .. string.char(drip())
  end
  return r
end

local function absorb_nibble(x)
  if a == N // 2 then
    shuffle()
  end
  local t = (N // 2 + x) % N
  s[a], s[t] = s[t], s[a]
  a = a + 1
end

local function absorb_stop()
  if a == N // 2 then
    shuffle()
  end
  a = a + 1
end

local function absorb_byte(b)
  absorb_nibble(b & 0xF)
  absorb_nibble(b >> 4)
end

local function absorb(m)
  for v = 1, #m do
    absorb_byte(m:byte(v))
  end
end

local function initialize_state()
  N, a, i, j, k, s, w, z = 256, 0, 0, 0, 0, {}, 1, 0
  for v = 0, N - 1 do
    s[v] = v
  end
end

local function key_setup(k)
  initialize_state()
  absorb(k)
end

function spritz.encrypt(m, k)
  key_setup(k)
  local r = ''
  for v = 1, #m do
    r = r .. string.char((m:byte(v) + drip()) % N)
  end
  return r
end

function spritz.decrypt(m, k)
  key_setup(k)
  local r = ''
  for v = 1, #m do
    r = r .. string.char((m:byte(v) - drip()) % N)
  end
  return r
end

function spritz.crypt(m, k)
  key_setup(k)
  local r = ''
  for v = 1, #m do
    r = r .. string.char((m:byte(v) ~ drip()) % N)
  end
  return r
end

function spritz.hash(m)
  local l = 32
  initialize_state()
  absorb(m)
  absorb_stop()
  absorb(string.char(l))
  return squeeze(l)
end

return spritz
