note
	description: "Summary description for {MESSAGES}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MESSAGES

create
	make

feature --constructor
	make
		do
			spacing := "  "
			intial_msg := spacing + "Welcome! Try test(3,5,7,15,30)"
			create status.make_empty
			create land.make_empty
			create liftoff.make_empty
			create abort.make_empty
			create game_over.make_empty
			create explorer.make_empty
			create planet.make_empty
			create abort_err.make_empty
			create land_err.make_empty
			create liftoff_err.make_empty
			create move_err.make_empty
			create pass_err.make_empty
			create play_err.make_empty
			create status_err.make_empty
			create test_err.make_empty
			create wormhole_err.make_empty
			create explorer_dead.make_empty
			create planet_dead.make_empty
			create deaths_this_turn.make_empty
			create movement.make_empty
			create lost_fuel.make_empty
			create explorer_properties.make_empty
		end

feature --queries

intial_msg : STRING
status : STRING
land: STRING
liftoff : STRING
abort: STRING
game_over : STRING
explorer :STRING
planet : STRING
abort_err : STRING
land_err: STRING
liftoff_err :STRING
move_err: STRING
pass_err: STRING
play_err: STRING
status_err :STRING
test_err : STRING
wormhole_err: STRING
spacing: STRING
explorer_dead : STRING
planet_dead : STRING
deaths_this_turn :STRING
movement : STRING
lost_fuel : STRING
explorer_properties : STRING

feature --setters of regular messages

	set_status(X,Y,Z,V,W: INTEGER; landed :BOOLEAN)
		do
			if landed then
				status := "  Explorer status report:Stationary on planet surface at [" + x.out + "," + y.out + "," + z.out + "]%N"
				status.append(spacing + "Life units left:" + V.out + ", " + "Fuel units left:" + W.out)
			else
				status := spacing + "Explorer status report:Travelling at cruise speed at [" + X.out + "," + Y.out + "," + Z.out + "]%N"
	    		status.append(spacing + "Life units left:" + V.out + ", " + "Fuel units left:" + W.out)
			end
		end

	set_land(has_life: BOOLEAN; X,Y: INTEGER)
		do
			if has_life then
				land:= spacing + "Tranquility base here - we've got a life!"
			else
				land:= spacing + "Explorer found no life as we know it at Sector:" + X.out + ":" + Y.out
			end
		end

	set_liftoff(landed : BOOLEAN; X,Y: INTEGER)
		do
			liftoff:= spacing + "Explorer has lifted off from planet at Sector:" + X.out + ":" + Y.out
		end

	set_abort
		do
			abort := spacing + "Mission aborted. Try test(3,5,7,15,30)"
		end

	set_game_over
		do
			game_over := spacing + "The game has ended. You can start a new game."
		end

feature --setters of error messages
	set_abort_err(playing : BOOLEAN)
		do
			if not playing then
				abort_err := spacing + "Negative on that request:no mission in progress."
			end
		end

	set_land_err(is_playing, is_landed, has_yellow_dwarf, has_planet, no_unvisited: BOOLEAN; X, Y: INTEGER) --sector x,y
		do
			if not is_playing then
				land_err := spacing + "Negative on that request:no mission in progress."
			else
				if is_landed then
					land_err := spacing + "Negative on that request:already landed on a planet at Sector:" + X.out + ":" +Y.out
				else
					if not has_yellow_dwarf then
						land_err := spacing + "Negative on that request:no yellow dwarf at Sector:" + X.out + ":" + Y.out
					else if not has_planet then
							land_err := spacing + "Negative on that request:no planets at Sector:" + X.out + ":" + Y.out
							else
								if no_unvisited then
									land_err := spacing + "Negative on that request:no unvisited attached planet at Sector:" + X.out + ":" + Y.out
--								else
--									if not is_attached then
--										land_err :=   spacing + "Negative on that request:no unvisited attached planet at Sector:" +  X.out + ":" + Y.out
--									end
								end
						end
					end
				end

			end
		end

	set_liftoff_err(playing, landed : BOOLEAN; X,Y : INTEGER) --sector x,y
		do
			if not playing then
				liftoff_err:= spacing + "Negative on that request:no mission in progress."
			else if not landed then
						liftoff_err := spacing + "Negative on that request:you are not on a planet at Sector:" + X.out + ":" + Y.out
			      end
			end
		end

	set_move_err(playing , landed, no_space : BOOLEAN; X,Y : INTEGER)
		do
			if not playing then
				move_err := spacing + "Negative on that request:no mission in progress."
			else
				if landed then
					move_err := spacing + "Negative on that request:you are currently landed at Sector:" + X.out + ":" + Y.out
				else if no_space then
						move_err := spacing + "Cannot transfer to new location as it is full."
					end
				end
			end
		end

	set_pass_err(playing : BOOLEAN)
		do
			if not playing then
				pass_err := spacing + "Negative on that request:no mission in progress."
			end
		end

	set_play_err(playing: BOOLEAN)
		do
			if playing then
				play_err := spacing + "To start a new mission, please abort the current one first."
			end
		end

	set_status_err(playing : BOOLEAN)
		do
			if not playing then
				status_err := spacing + "Negative on that request:no mission in progress."
			end
		end

	set_test_err(playing : BOOLEAN)
		do
			if playing then
				test_err := spacing + "To start a new mission, please abort the current one first."
			end
		end

	set_wormhole_err(playing, landed, has_wormhole : BOOLEAN; X,Y : INTEGER)
		do
			if not playing then
				wormhole_err:= spacing + "Negative on that request:no mission in progress."
			else if landed then
					wormhole_err := spacing + "Negative on that request:you are currently landed at Sector:" + X.out + ":" + Y.out
					else if not has_wormhole then
						wormhole_err := spacing + "Explorer couldn't find wormhole at Sector:" + X.out + ":" + Y.out
					end
				end
			end
		end

feature --death messages
	set_deaths_this_turn(deaths : ARRAY[TUPLE[e :ENTITY_ALPHABET; s : STRING]])
		local
			msg : STRING
			lands : STRING
			turns : STRING
			att : STRING
			supp_life : STRING
			vis :STRING
			counter :INTEGER
			sa : SHARED_INFORMATION_ACCESS
		do
			create msg.make_empty
			create lands.make_empty
			counter := 0
			across
				deaths is t
			loop
				counter := counter + 1
				if t.e.landed then
					lands := "T"
				else
					lands := "F"
				end
				if t.e.is_attached then
					att := "T"
				else
					att:= "F"
				end

				if t.e.supports_life then
					supp_life := "T"
				else
					supp_life := "F"
				end

				if t.e.visited then
					vis := "T"
				else
					vis := "F"
				end

				if t.e.is_attached or t.e.dies then
					turns := "N/A"
				else
					turns := t.e.turns_left.out
				end

				if t.e.is_explorer then
					explorer_properties := (spacing + spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->fuel:" + t.e.fuel.out + "/3, life:" + t.e.life.out + "/3, landed?:" + lands + ",%N" )
				else
					if counter = 1 then
						if t.e.is_planet then
							msg.append(spacing + spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->attached?:" + att + ", support_life?:" + supp_life + ", visited?:"+ vis + ", turns_left:" + turns + ",%N" )
							msg.append (spacing + spacing + spacing + "Planet got devoured by blackhole (id: -1) at Sector:3:3")
						end
						if t.e.is_malevolent then
							msg.append(spacing + spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->fuel:" + t.e.fuel.out +"/" + sa.shared_info.malevolent_max_fuel.out + ", actions_left_until_reproduction:"+ t.e.actions_left_until_reproduction.out + "/" + sa.shared_info.malevolent_reproduction.out + ", turns_left:N/A," + "%N")
							if t.s.is_empty then
								msg.append (spacing + spacing + spacing + "Malevolent got devoured by blackhole (id: -1) at Sector:3:3")
							else
								msg.append (spacing + spacing + spacing + t.s)
							end
						end
						if t.e.is_asteroid then
							msg.append(spacing + spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->turns_left:N/A," + "%N")
							if t.s.is_empty then
								msg.append (spacing + spacing + spacing + "Asteroid got devoured by blackhole (id: -1) at Sector:3:3")
							else
								msg.append (spacing + spacing + spacing + t.s)
							end
						end
						if t.e.is_janitaur then
							msg.append(spacing + spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->fuel:" + t.e.fuel.out +"/" + sa.shared_info.janitaur_max_fuel.out + ", load:"+ t.e.load.out + "/" + sa.shared_info.janitaur_max_load.out + ", actions_left_until_reproduction:"+ t.e.actions_left_until_reproduction.out + "/" + sa.shared_info.janitaur_reproduction.out + ", turns_left:N/A," + "%N")
							if t.s.is_empty then
								msg.append (spacing + spacing + spacing + "Janitaur got devoured by blackhole (id: -1) at Sector:3:3")
							else
								msg.append (spacing + spacing + spacing + t.s)
							end
						end
						if t.e.is_benign then
							msg.append(spacing + spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->fuel:" + t.e.fuel.out +"/" + sa.shared_info.benign_max_fuel.out + ", actions_left_until_reproduction:"+ t.e.actions_left_until_reproduction.out + "/" + sa.shared_info.benign_reproduction.out + ", turns_left:N/A," + "%N")
							if t.s.is_empty then
								msg.append (spacing + spacing + spacing + "Benign got devoured by blackhole (id: -1) at Sector:3:3")
							else
								msg.append (spacing + spacing + spacing + t.s)
							end
						end
					else
						if t.e.is_planet then
							msg.append("%N" + spacing + spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->attached?:" + att + ", support_life?:" + supp_life + ", visited?:"+ vis + ", turns_left:" + turns + ",%N" )
							msg.append (spacing + spacing + spacing + "Planet got devoured by blackhole (id: -1) at Sector:3:3")
						end
						if t.e.is_malevolent then
							msg.append("%N" + spacing + spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->fuel:" + t.e.fuel.out +"/" + sa.shared_info.malevolent_max_fuel.out + ", actions_left_until_reproduction:"+ t.e.actions_left_until_reproduction.out + "/" + sa.shared_info.malevolent_reproduction.out + ", turns_left:N/A," + "%N")
							if t.s.is_empty then
								msg.append (spacing + spacing + spacing + "Malevolent got devoured by blackhole (id: -1) at Sector:3:3")
							else
								msg.append (spacing + spacing + spacing + t.s)
							end
						end
						if t.e.is_asteroid then
							msg.append("%N" + spacing + spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->turns_left:N/A," + "%N")
							if t.s.is_empty then
								msg.append (spacing + spacing + spacing + "Asteroid got devoured by blackhole (id: -1) at Sector:3:3")
							else
								msg.append (spacing + spacing + spacing + t.s)
							end
						end
						if t.e.is_janitaur then
							msg.append("%N" +spacing + spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->fuel:" + t.e.fuel.out +"/" + sa.shared_info.janitaur_max_fuel.out + ", load:"+ t.e.load.out + "/" + sa.shared_info.janitaur_max_load.out + ", actions_left_until_reproduction:"+ t.e.actions_left_until_reproduction.out + "/" + sa.shared_info.janitaur_reproduction.out + ", turns_left:N/A," + "%N")
							if t.s.is_empty then
								msg.append (spacing + spacing + spacing + "Janitaur got devoured by blackhole (id: -1) at Sector:3:3")
							else
								msg.append (spacing + spacing + spacing + t.s)
							end
						end
						if t.e.is_benign then
							msg.append("%N" +spacing + spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->fuel:" + t.e.fuel.out +"/" + sa.shared_info.benign_max_fuel.out + ", actions_left_until_reproduction:"+ t.e.actions_left_until_reproduction.out + "/" + sa.shared_info.benign_reproduction.out + ", turns_left:N/A," + "%N")
							if t.s.is_empty then
								msg.append (spacing + spacing + spacing + "Benign got devoured by blackhole (id: -1) at Sector:3:3")
							else
								msg.append (spacing + spacing + spacing + t.s)
							end
						end
					end
				end
			end
			deaths_this_turn.append (msg)
		end

	set_explorer_properties(s : STRING)
		do
			explorer_properties := s
		end


	set_explorer_death(fuel : INTEGER;sector : INTEGER; galaxy : GALAXY)
		local
			x: INTEGER
			y:INTEGER
		do
			x:= galaxy.grid.at (sector).row
			y:=galaxy.grid.at (sector).column
			if galaxy.grid.at (sector).has_blackhole then
				explorer_dead := spacing + "Explorer got devoured by blackhole (id: -1) at Sector:"+ X.out + ":" + Y.out
				lost_fuel := spacing + "Explorer got devoured by blackhole (id: -1) at Sector:"+ X.out + ":" + Y.out
				set_game_over
				explorer_dead.append ("%N" + spacing + "The game has ended. You can start a new game.")
			else
				if fuel = 0 then
					explorer_dead := spacing + "Explorer got lost in space - out of fuel at Sector:"+  X.out + ":" + Y.out
					lost_fuel := spacing + "Explorer got lost in space - out of fuel at Sector:"+  X.out + ":" + Y.out
					set_game_over
					explorer_dead.append ("%N" + spacing + "The game has ended. You can start a new game.")
				end
			end

		end

	explorer_death_message(s : STRING)
		do
			explorer_dead.append (spacing + s)
			set_game_over
			explorer_dead.append ("%N" + spacing + "The game has ended. You can start a new game.")
		end

feature --movement

	set_movements_made(prev_position, new_position, prev_sector : INTEGER; t: ENTITY_ALPHABET; galaxy : GALAXY)
		do
			if prev_position = new_position and prev_sector ~ t.sector_pos then
				movement.append("%N" +spacing + spacing + "[" + t.id.out + "," + t.item.out + "]:[" + galaxy.grid.at (prev_position).row.out + "," + galaxy.grid.at (prev_position).column.out + ","+ prev_sector.out + "]")
			else
				movement.append("%N" +spacing + spacing + "[" + t.id.out + "," + t.item.out + "]:[" + galaxy.grid.at (prev_position).row.out + "," + galaxy.grid.at (prev_position).column.out + ","+ prev_sector.out + "]->[" + galaxy.grid.at (new_position).row.out + "," + galaxy.grid.at (new_position).column.out  + "," + t.sector_pos.out + "]" )
			end
		end

	kills(e : ENTITY_ALPHABET; sector : SECTOR)
		local
			x: INTEGER
			y: INTEGER
			z :INTEGER
		do
			x := sector.row
			y := sector.column
			z := e.sector_pos
			movement.append("%N" +spacing + spacing + spacing + "destroyed [" + e.id.out +"," + e.item.out + "] at [" + x.out + "," + y.out + "," + z.out + "]")
		end

	reproduced(e : ENTITY_ALPHABET; sector : SECTOR)
		local
			x: INTEGER
			y: INTEGER
			z :INTEGER
		do
			x := sector.row
			y := sector.column
			z := e.sector_pos
			movement.append("%N" +spacing + spacing + spacing + "reproduced [" + e.id.out +"," + e.item.out + "] at [" + x.out + "," + y.out + "," + z.out + "]")
		end


feature --out
	error_out : STRING
		do
			create Result.make_empty
			if not play_err.is_empty then
				Result.append(play_err)
			end
			if not move_err.is_empty then
				Result.append(move_err)
			end

			if not abort_err.is_empty then
				Result.append(abort_err)
			end
			if not land_err.is_empty then
				Result.append(land_err)
			end
			if not liftoff_err.is_empty then
				Result.append(liftoff_err)
			end
			if not pass_err.is_empty then
				Result.append(pass_err)
			end
			if not wormhole_err.is_empty then
				Result.append(wormhole_err)
			end
			if not status_err.is_empty then
				Result.append(status_err)
			end
		end

	non_error_out : STRING
		do
			create Result.make_empty
			if abort_err.is_empty then
				Result.append(abort)
			end
--			if land_err.is_empty then
--				Result.append(land)
--			end
--			if liftoff_err.is_empty then
--				Result.append(liftoff)
--			end
--			if pass_err.is_empty then
--				Result.append(pass)
--			end
--			if wormhole_err.is_empty then
--				Result.append(wormhole)
--			end
			if status_err.is_empty then
				Result.append(status)
			end
		end
end
