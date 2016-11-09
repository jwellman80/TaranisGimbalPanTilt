--[[

SCRIPT: stick2rate.lua
AUTHOR: Mike Shellim
URL: http://rc-soar.com/opentx
DATE: 14 Sept 2014
VERSION: 1.0
DESCRIPTION:

Script to convert stick position into rate command.
Typical usage: for controlling a gimbal for smoother control and 'nudging'.
Pull SH to recentre

TESTED
OpenTx v. 2.08

INPUTS
ctrl: control stick 'ail' (default), 'ele', 'thr', 'rud'
Sens: sensitivity (1 - 100, default = 50)

INSTALLATION
1. Save script with .LUA extension, store in /SCRIPTS/MIXES folder on SD Card
2. Open Custom Scripts menu in the transmitter
3. Assign this script to empty slot
4. Open script, and test by moving aileron stick and observing 'gimb' output
5. Close Scripts menu
6. Check that [i]gimb appears in the mixer Src list

MIXER SETUP
- In the gimbal channel, create single mixer line, call it 'gimbal'
- Specify Src = [i]gimb
--]]

local _pan = 0
local _tilt = 0
local SENS_ADJUST = 2048

-------------------
-- inputs / outputs
-------------------

local inp =
    {
        { "Pan", SOURCE },
        { "Tilt", SOURCE },
        { "EnableSw", SOURCE },
        { "Sens", VALUE, 1, 100, 50 },
        { "Deadband", VALUE, 1, 100, 10 }	-- sensitivity

    }
local out = { "pan", "tilt"} 	-- output position

----------------------------
-- initialisation function
----------------------------

local function init_func()

    -- -- Store ids of permissable gimbal controls
    -- -- (saves expensive lookups in run_func)
    --
    -- control_id [1] = getFieldInfo ("ail").id
    -- control_id [2] = getFieldInfo ("ele").id
    -- control_id [3] = getFieldInfo ("rud").id
    -- control_id [4] = getFieldInfo ("thr").id
    --
    -- -- switch SH
    --
    -- control_id [5] = getFieldInfo ("sh").id

end

-------------------------------
-- periodically called function
-------------------------------

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
