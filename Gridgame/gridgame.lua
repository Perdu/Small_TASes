-- Bruteforcer of the different possible starts for each seed
-- Note: requires libTAS PRs that have not been merged yet as I push this. This will NOT work with libTAS 1.4.7

local memscore = "" -- only stable starting from frame 3
local cur_score = 0
local dbg = false
local use_random = true
local MAX_TRIES_PER_SEED = 10

---- Constants
MAX_TIME_BETWEEN_SCORE_GAIN = 9

---- Session vars
max_score = 0
max_x_position = 0
max_y_position = 0
nb_time_since_last_score_gain = 0
cur_x = 1
cur_y = 1
first_run = true
file = nil
nb_tries = 0
used_x_y = {}

x_map = {17, 32, 52, 64, 80, 93, 111, 123, 135, 157, 170, 182, 200, 214, 233, 247}
y_map = {18, 33, 47, 65, 75, 92, 106, 123, 139, 153, 168, 182, 198, 208, 228, 239}

function log(mess)
   if file == nil then
      print("Error: seed file not open")
   end
   print(mess)
   file:write(mess .. "\n")
   file:flush()
end

function end_session()
   -- runtime.playPause()
   file:close()
end

function restart()
   nb_time_since_last_score_gain = 0
   memscore = ""
   cur_score = 0
   if use_random then
      if nb_tries == MAX_TRIES_PER_SEED then
         log(string.format("Best solution: %d at x = %d, y = %d", max_score, max_score_x, max_score_y))
         end_session()
      else
         repeat
            cur_x = math.random(1, 16)
            cur_y = math.random(1, 16)
         until not used_x_y[cur_x .. "," .. cur_y]
         used_x_y[cur_x .. "," .. cur_y] = true
         nb_tries = nb_tries + 1
      end
   else
      cur_x = cur_x + 1
      if cur_x == 17 then
         cur_x = 1
         cur_y = cur_y + 1
         if cur_y == 17 then
            log(string.format("Best solution: %d at x = %d, y = %d", max_score, max_score_x, max_score_y))
            end_session()
         end
      end
   end
   runtime.loadState(1)
end

function onStartup()
   nb_time_since_last_score_gain = 0
   if use_random then
      cur_x = math.random(1,16)
      cur_y = math.random(1,16)
   else
      cur_x = 1
      cur_y = 1
   end
   first_run = true
   seed = movie.getInitialSystemTime()
   file, err = io.open(string.format("gridgame/%d.txt", seed), "w")
   if not file then
      print("Failed to open file:", err)
      return
   end
end

function onInput()
   local f = movie.currentFrame()
   if f == 1 then
      input.setMouseCoords(x_map[cur_x], y_map[cur_y], 0)
   end
end

function onFrame()
   local f = movie.currentFrame()
   if f == 1 then
      if first_run then
         runtime.saveState(1)
         first_run = false
      end
   elseif f == 3 then
      i = ramsearch.newsearch(9, 0, 1, 1, "==", 0, 7, "500000000000", "700000000000")
      if dbg then
         print(string.format("nb_results newsearch f3: %d", i))
      end
   elseif f == 4 then
      i = ramsearch.search(0, 0, "==")
      if dbg then
         print(string.format("nb_results search f4: %d", i))
      end
   elseif f == 15 then
      i = ramsearch.search(0, 0, ">")
      if dbg then
         print(string.format("nb_results search f15: %d", i))
      end
      if i == 1 then
         memscore = ramsearch.get_address(0)
      else
         log(string.format("%d,%d: 1", cur_x, cur_y))
         restart()
      end
   end
   if memscore ~= "" then
      local score_num = tonumber(memscore, 16)
      local score = memory.readd(score_num)
      if score == cur_score then
         nb_time_since_last_score_gain = nb_time_since_last_score_gain + 1
         if (nb_time_since_last_score_gain == MAX_TIME_BETWEEN_SCORE_GAIN) then
            local ok, result = pcall(string.format, "%d,%d: %d", cur_x, cur_y, score)
            if ok then
               log(result)
               if score > max_score then
                  max_score = score
                  max_score_x = cur_x
                  max_score_y = cur_y
               end
            else
               log(string.format("%d,%d: buggy result", cur_x, cur_y))
            end
            restart()
         end
      else
         nb_time_since_last_score_gain = 0
         cur_score = score
      end
   end
end
