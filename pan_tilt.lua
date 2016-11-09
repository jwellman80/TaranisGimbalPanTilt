--[[

pan_tilt.lua

Created By: Jared Wellman
For: OpenTX Pan/Tilt with Gimbal like control (speed rather than position)

Last Modified: 2016/11/08

--]]

local _pan = 0
local _tilt = 0
local SENS_ADJUST = 2048

-- inputs

local inp =
    {
        { "Pan", SOURCE },
        { "Tilt", SOURCE },
        { "EnableSw", SOURCE },
        { "Sens", VALUE, 1, 100, 50 },
        { "Deadband", VALUE, 1, 100, 10 }

    }

-- outputs

local out = { "pan", "tilt"}

----------------------------
-- init function
----------------------------

local function init_func()

end


local function condition_output(val)

  if val > 1024 then
    return 1024
  end

  if val < -1024 then
    return -1024
  end

  return val
end

local function condition_input(val, deadband)
  if val < 0 and val < -1 * deadband then
    return val
  elseif val > 0 and val > deadband then
    return val
  end

  return 0
end

local function run_func(pan, tilt, enablesw, sens, deadband)
  if enablesw > 500 then
    _pan = _pan + condition_input(pan, 10) * (sens / SENS_ADJUST)
    _tilt = _tilt + condition_input(tilt, 10) * (sens/SENS_ADJUST)

    _pan = condition_output(_pan)
    _tilt = condition_output(_tilt)
  end

  return _pan, _tilt
end



return {init=init_func, run=run_func, input=inp, output=out}
