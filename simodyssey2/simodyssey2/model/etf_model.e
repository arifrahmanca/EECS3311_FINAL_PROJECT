note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MODEL

inherit
	ANY
		redefine
			out
		end

create {ETF_MODEL_ACCESS}
	make

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		do
			playing := false
			test_m := false
			landed := false
			create msgs.make
			ok := "ok%N"
			movement_msg := "  Welcome! Try test(30)"
			create movement.make_empty
			create s.make_empty
			state := 0
			invalid := 0
			mode := "mode"
			create galaxy.make_empty
			current_position := 1
			create error.make_empty
			create sectors.make_empty
			create descriptions.make_empty
			create array_of_all_ent.make_empty
			landedx := 0
			landedy := 0
			died := false
			life_on_planet := false
		end

feature -- model attributes
	sa : SHARED_INFORMATION_ACCESS
	ok : STRING
	invalid: INTEGER
    playing : BOOLEAN
	s : STRING
	movement_msg :STRING
	movement: STRING
	mode: STRING
	state : INTEGER
	current_position : INTEGER
	direction : DIRECTION_UTILITY
	galaxy : GALAXY
	msgs : MESSAGES
	landed: BOOLEAN
	error : STRING
	test_m: BOOLEAN
	sectors :STRING
	descriptions : STRING
	array_of_all_ent:  ARRAY[TUPLE[g: INTEGER; e:ENTITY_ALPHABET]]
	landedx : INTEGER
	landedy : INTEGER
	died : BOOLEAN
	life_on_planet: BOOLEAN

feature -- model operations

	play
		local
			moveable_counter: INTEGER
			helper : CONTROLS
		do
			if playing then
				msgs.set_play_err (playing)
				invalid := invalid + 1
			else
				sa.shared_info.test (3, 5, 7, 15, 30)
				galaxy.make
				moveable_counter := 1
				invalid := 0
				state := state + 1
				movement_msg := "Movement:"
				movement := "none"
				ok := "ok%N"
				landed := false
				playing := true
				died := false
				sa.shared_info.intialize_next_id

				s:= galaxy.out
				playing := true
				test_m:=false
				life_on_planet := false
				current_position := 1
				helper.fill_up_galaxy (galaxy)

				--set id of explorer and planets
				across galaxy.grid is i
				loop
					across i.contents is j
					loop
						if j.is_moveable and not j.is_explorer then
							j.set_id(sa.shared_info.next_moveable_id)
						end
						if not j.is_filler then
							j.set_sector_pos (galaxy)
						end
						if j.is_explorer then
							j.set_id(0)
						end
						--test to check if ids are assigned correctly and if luminosity is assigned correctly
--						s.append ("%N"+ msgs.spacing + "id:" + j.id.out + " for entity: " + j.item.out + " at quadrant: " + j.sector_pos.out + "%N")
--						if j.luminosity > 0 then
--							s.append (msgs.spacing + "luminosity: " + j.luminosity.out)
--						end
					end

				end
			end
		end

	move(dir: INTEGER)
		local
			prev_explorer_position : INTEGER
			new_explorer_position : INTEGER
			prev_planet_position : INTEGER
			new_planet_position : INTEGER
			explorer : ENTITY_ALPHABET
			planet : ENTITY_ALPHABET
			cur_direction : INTEGER
			planet_to_move : ARRAY[TUPLE[g: INTEGER; e:ENTITY_ALPHABET]]
			counter : INTEGER
			mv : INTEGER
			filler : ENTITY_ALPHABET
			helper : CONTROLS
			num :INTEGER
			deaths : ARRAY[TUPLE[e :ENTITY_ALPHABET; s : STRING]]
			prev_sector :INTEGER
			check_next : INTEGER
			has_space :BOOLEAN
			str : STRING
		do
			create str.make_empty
			cur_direction := direction.num_dir (dir) -- value of direction
			check_next := direction.cal_new (current_position, galaxy.shared_info.number_rows, galaxy.shared_info.number_columns, cur_direction) -- where explorer goes after every move
			has_space := (not(galaxy.grid.at (check_next).next_available_quad <= galaxy.grid.at (check_next).contents.count))
			msgs.set_move_err (playing, landed, has_space, landedx, landedy)
			if not msgs.move_err.is_empty then
				invalid := invalid + 1
				if not playing then
					test_m := false
				end
			else
				state := state + 1
				invalid := 0
				prev_explorer_position := current_position
				create explorer.make ('E')
				create planet.make ('P')
				create planet_to_move.make_empty
				create filler.make_empty
				movement.make_empty
				s.make_empty
				create deaths.make_empty

				--add planets that need to be moved into a array of tuples
				across
					1 |..| galaxy.grid.count is i
				loop
					counter := 1
					across
						galaxy.grid.at (i).contents is p
					loop
						if not p.is_filler and not p.is_explorer then
							galaxy.grid.at (i).contents.at (counter).set_sector_pos (galaxy) --sets where planet is in current quadrant
						end
						if (p.is_planet and not p.dies and not p.is_attached) or  (p.is_moveable and not p.is_explorer and not p.is_planet) then --or (p.is_moveable and not p.is_explorer)
							planet_to_move.force ([i, p], planet_to_move.count + 1 )
						end
						if p.is_explorer and p.id = 0 then
							explorer := p
							explorer.set_sector_pos (galaxy) --set_pos of explorer in its current quadrant
							current_position := i
						end
					counter := counter + 1
					end
				end


				--MOVE EXPLORER
				prev_explorer_position := current_position
				cur_direction := direction.num_dir (dir) -- value of direction
				new_explorer_position := direction.cal_new (prev_explorer_position, galaxy.shared_info.number_rows, galaxy.shared_info.number_columns, cur_direction) -- where explorer goes after every move
				if galaxy.grid.at (new_explorer_position).next_available_quad <= galaxy.grid.at (new_explorer_position).contents.count then
					galaxy.grid.at (prev_explorer_position).contents.put_i_th (filler, explorer.sector_pos)  ---REMOVE E from its current grid position
					galaxy.grid.at (new_explorer_position).contents.put_i_th (explorer, galaxy.grid.at (new_explorer_position).next_available_quad )
					helper.check_alive (explorer, galaxy.grid.at (new_explorer_position), false) -- ensures explorer is alive aftr moving
					prev_sector := explorer.sector_pos
					explorer.set_sector_pos (galaxy) --sets sector position of explorer to where it is after being moved
				else
					new_explorer_position := prev_explorer_position
				end
				msgs.set_movements_made(prev_explorer_position, new_explorer_position,prev_sector, explorer,galaxy)
				helper.move_movables (planet_to_move, msgs,galaxy, sa) --moves all planets that need to be moved

				if explorer.dies then
					msgs.set_explorer_death(explorer.fuel, new_explorer_position, galaxy)
					deaths.force ([explorer, str], deaths.count + 1)
					msgs.set_deaths_this_turn (deaths)
					galaxy.grid.at (new_explorer_position).contents.put_i_th (filler, explorer.sector_pos)  ---REMOVE E from its current grid position
					playing := false
					died := true
				else
					current_position := new_explorer_position
				end
				--EXPLORER MOVED

				if test_m then
					--alll test mode messages
					sectors:= helper.print_all_sectors(galaxy)
					array_of_all_ent.make_empty
				across galaxy.grid is i
				loop
					across i.contents is j
					loop
						if (j.is_planet or j.is_stationary or j.is_explorer or j.is_benign or j.is_malevolent or j.is_janitaur or j.is_asteroid) and not j.dies then
							array_of_all_ent.force ([counter,j], array_of_all_ent.count + 1)
						end
					end
					counter := counter + 1
				end
					array_of_all_ent := helper.sort_by_id (array_of_all_ent)
					descriptions:= helper.print_all_descriptions(array_of_all_ent)
				end
				s.append (galaxy.out)
			end
		end

	abort
		do
			---NOT SURE IF CORRECT
			invalid := invalid + 1
			if not playing then
				msgs.set_abort_err (playing)
				test_m := false
			else
				msgs.set_abort
				s.make_empty
				playing := false
				test_m := false
			end
		end

	land
		local
			y_dwarf : BOOLEAN
			planet : BOOLEAN
			no_left_to_visit :BOOLEAN
			x : INTEGER
			y : INTEGER
			num_visited : INTEGER
			num_unvisited :INTEGER
			has_life: BOOLEAN
			planet_to_move : ARRAY [TUPLE [INTEGER_32, ENTITY_ALPHABET]]
			counter :INTEGER
			helper : CONTROLS
			explorer : ENTITY_ALPHABET
			planets_in_sector : ARRAY[ENTITY_ALPHABET]
			added : INTEGER
		do
			num_visited := 0
			num_unvisited := 0
			added:= 0
			has_life := false
			create planet_to_move.make_empty
			create explorer.make_empty
			create planets_in_sector.make_empty

			across
			1 |..| galaxy.grid.count is i
			loop
				counter := 1
				across galaxy.grid.at (i).contents is e
				loop
					if (e.is_planet and not e.dies and not e.is_attached) or (e.is_moveable and not e.is_explorer and not e.is_planet)  then --or (e.is_moveable and not e.is_explorer)
						galaxy.grid.at (i).contents.at (counter).set_sector_pos (galaxy) --sets where planet is in current quadrant
						planet_to_move.force ([i, e], planet_to_move.count + 1 )
					end
					if e.is_explorer then
						explorer := e
						x := galaxy.grid.at (i).row
						y := galaxy.grid.at (i).column
						y_dwarf := galaxy.grid.at (i).has_yellow_dwarf
						planet := galaxy.grid.at (i).has_planet
						if planet then
							across galaxy.grid.at (i).contents is p
							loop
								if p.is_planet then
									planets_in_sector.force (p, planets_in_sector.count + 1)
									if p.visited then
										num_visited := num_visited + 1
									else
										num_unvisited := num_unvisited +1
										if p.supports_life then
											has_life := p.supports_life
											life_on_planet := true
										end
									end
								end
							end
						end
					end
					counter := counter + 1
				end
			end

			if planet and num_unvisited = 0 then
				no_left_to_visit := true
			else if planet and num_unvisited >0 then
				no_left_to_visit := false
				end
			end
			msgs.set_land_err (playing, landed, y_dwarf, planet, no_left_to_visit, x, y)

			if msgs.land_err.is_empty then
				explorer.set_landed(true)
				msgs.set_land (has_life, x, y)
				landed :=true
				landedx := x
				landedy := y
				state := state + 1
				if has_life then
					playing := false
				else
					across
						planets_in_sector is a
					loop
						if not a.visited and (added = 0) then
							a.set_visited(true)
							added := 1
						end
					end
					helper.move_movables (planet_to_move, msgs,galaxy, sa) --moves all planets that need to be moved
					s := galaxy.out
				end
				if test_m then
					--alll test mode messages
					sectors:= helper.print_all_sectors(galaxy)
					array_of_all_ent.make_empty
					across galaxy.grid is i
					loop
						across i.contents is j
						loop
							if (j.is_planet or j.is_stationary or j.is_explorer or j.is_benign or j.is_malevolent or j.is_janitaur or j.is_asteroid) and not j.dies then
								array_of_all_ent.force ([counter,j], array_of_all_ent.count + 1)
							end
						end
						counter := counter + 1
					end
					descriptions:= helper.print_all_descriptions(array_of_all_ent)
				end
			else
				invalid := invalid + 1
			end
		end

	liftoff
		local
			x : INTEGER
			y : INTEGER
			helper : CONTROLS
			planet_to_move : ARRAY [TUPLE [INTEGER_32, ENTITY_ALPHABET]]
			counter : INTEGER
			explorer : ENTITY_ALPHABET
		do
			create planet_to_move.make_empty
			create explorer.make_empty
			across
				1 |..| galaxy.grid.count is i
			loop
				counter := 1
				across galaxy.grid.at (i).contents is e
				loop
					if (e.is_planet and not e.dies and not e.is_attached) or (e.is_moveable and not e.is_explorer and not e.is_planet) then --or (e.is_moveable and not e.is_explorer)
						galaxy.grid.at (i).contents.at (counter).set_sector_pos (galaxy) --sets where planet is in current quadrant
						planet_to_move.force ([i, e], planet_to_move.count + 1 )
					end
					if e.is_explorer then
						explorer := e
						x := galaxy.grid.at (i).row
						y := galaxy.grid.at (i).column
					end
					counter := counter + 1
				end
			end
			msgs.set_liftoff_err (playing, landed, x, y)

			if msgs.liftoff_err.is_empty then --if no error then set liftoff msg saying you lifted of
				msgs.set_liftoff (landed, x, y)
				landed := false
				explorer.set_landed(false)
				state := state + 1
				invalid := 0


				helper.move_movables (planet_to_move, msgs, galaxy, sa)
				if test_m then
					--alll test mode messages
					sectors:= helper.print_all_sectors(galaxy)
					array_of_all_ent.make_empty
					across galaxy.grid is i
					loop
						across i.contents is j
						loop
							if (j.is_planet or j.is_stationary or j.is_explorer or j.is_benign or j.is_malevolent or j.is_janitaur or j.is_asteroid) and not j.dies then
								array_of_all_ent.force ([counter,j], array_of_all_ent.count + 1)
							end
						end
						counter := counter + 1
					end
					descriptions:= helper.print_all_descriptions(array_of_all_ent)
				end


				s:= galaxy.out
			else
				invalid := invalid + 1
				if not playing then
					test_m := false
				end
			end
		end

	pass
		local
			helper : CONTROLS
			planet_to_move : ARRAY [TUPLE [INTEGER_32, ENTITY_ALPHABET]]
			counter : INTEGER
		do
			msgs.set_pass_err (playing)
			if msgs.pass_err.is_empty then --succesful pass
				invalid := 0
				state := state + 1
				create planet_to_move.make_empty
				across
					1 |..| galaxy.grid.count is i
				loop
					counter := 1
					across galaxy.grid.at (i).contents is e
					loop
						if (e.is_planet and not e.dies and not e.is_attached) or (e.is_moveable and not e.is_explorer and not e.is_planet) then
							galaxy.grid.at (i).contents.at (counter).set_sector_pos (galaxy) --sets where planet is in current quadrant
							planet_to_move.force ([i, e], planet_to_move.count + 1 )
						end
						counter := counter + 1
					end
				end
				helper.move_movables (planet_to_move, msgs, galaxy, sa)
				if test_m then
					--alll test mode messages
					sectors:= helper.print_all_sectors(galaxy)
					array_of_all_ent.make_empty
					across galaxy.grid is i
					loop
						across i.contents is j
						loop
							if (j.is_planet or j.is_stationary or j.is_explorer or j.is_benign or j.is_malevolent or j.is_janitaur or j.is_asteroid) and not j.dies then
								array_of_all_ent.force ([counter,j], array_of_all_ent.count + 1)
							end
						end
						counter := counter + 1
					end
					descriptions:= helper.print_all_descriptions(array_of_all_ent)
				end
				s := galaxy.out
			else
				invalid := invalid + 1
			end
		end

	status
		local
			x: INTEGER
			y: INTEGER
			z: INTEGER
			life : INTEGER
			fuel: INTEGER

		do
			invalid := invalid + 1
			msgs.set_status_err (playing)

			if msgs.status_err.is_empty then --you can check the status
				across
				1 |..| galaxy.grid.count is i
				loop
					across galaxy.grid.at (i).contents is e
					loop
						if e.is_explorer then
							x := galaxy.grid.at (i).row
							y := galaxy.grid.at (i).column
							e.set_sector_pos(galaxy)
							z := e.sector_pos
							life := e.life
							fuel := e.fuel
						end
					end
				end
				msgs.set_status (x, y, z, life, fuel, landed)
			end
		end

	test(a_threshold, j_threshold, m_threshold, b_threshold, p_threshold : INTEGER)
		local
			moveable_counter:INTEGER
			helper :CONTROLS
			arr_of_all_ent :ARRAY[TUPLE[g: INTEGER; e:ENTITY_ALPHABET]]
			counter:INTEGER
		do
			if playing then
				msgs.set_play_err (playing)
				invalid := invalid + 1
			else
				sa.shared_info.test (a_threshold, j_threshold, m_threshold, b_threshold, p_threshold)
				galaxy.make
				helper.fill_up_galaxy (galaxy)
				create 	arr_of_all_ent.make_empty
				playing := true
				test_m := true
				life_on_planet := false
				died := false
				movement_msg := "Movement:"
				movement := "none"
				s:= galaxy.out
				moveable_counter:= 1
				state := state+1
				counter := 1
				invalid := 0
				sa.shared_info.intialize_next_id

				across galaxy.grid is i
				loop
					across i.contents is j
					loop
						if j.is_planet or j.is_stationary or j.is_explorer or j.is_benign or j.is_malevolent or j.is_janitaur or j.is_asteroid then
							arr_of_all_ent.force ([counter,j], arr_of_all_ent.count + 1)
						end

						if j.is_moveable and not j.is_explorer then
							j.set_id(sa.shared_info.next_moveable_id)
						end
						j.set_sector_pos (galaxy)
					end
					counter := counter + 1
				end

				sectors := helper.print_all_sectors (galaxy)
				descriptions := helper.print_all_descriptions (arr_of_all_ent)

				array_of_all_ent := arr_of_all_ent
			end
		end

	wormhole
		local
			has_wormhole : BOOLEAN
			x : INTEGER
			y : INTEGER
			explorer : ENTITY_ALPHABET
			filler :ENTITY_ALPHABET
			temp_row : INTEGER
			temp_column : INTEGER
			added : BOOLEAN
			counter : INTEGER
			helper : CONTROLS
			planet_to_move : ARRAY[TUPLE[g: INTEGER; e:ENTITY_ALPHABET]]
			planet : ENTITY_ALPHABET
			prev_planet_position: INTEGER
			new_planet_position: INTEGER
			num : INTEGER
			mv : INTEGER
			deaths : ARRAY[ENTITY_ALPHABET]
			prev_sector : INTEGER
		do
			counter := 1
			has_wormhole := false
			create filler.make ('-')
			create explorer.make_empty
			create planet_to_move.make_empty
			create deaths.make_empty
			across
				1 |..| galaxy.grid.count is i
			loop
				counter := 1
				across galaxy.grid.at (i).contents is e
				loop
					if (e.is_planet and not e.dies and not e.is_attached) or (e.is_moveable and not e.is_explorer and not e.is_planet) then
						galaxy.grid.at (i).contents.at (counter).set_sector_pos (galaxy) --sets where planet is in current quadrant
						planet_to_move.force ([i, e], planet_to_move.count + 1 )
					end
					if e.is_explorer and not added then
						has_wormhole := galaxy.grid.at (i).has_wormhole
						x := galaxy.grid.at (i).row
						y := galaxy.grid.at (i).column
						explorer := e

						if has_wormhole then
							from
							added := false
							until
								added
							loop
								temp_row := galaxy.gen.rchoose (1, 5)
								temp_column := galaxy.gen.rchoose (1, 5)
								if (galaxy.grid[temp_row,temp_column].next_available_quad <= galaxy.grid[temp_row,temp_column].contents.count) then
									galaxy.grid[x,y].contents.put_i_th (filler, counter)
									galaxy.grid[temp_row,temp_column].contents.put_i_th (explorer, galaxy.grid[temp_row,temp_column].next_available_quad)
									prev_sector := explorer.sector_pos
									explorer.set_sector_pos (galaxy)
									current_position := ((temp_row*5) - 5) + temp_column
									added:= true
								end
								msgs.set_movements_made((((x*5) - 5) + y), current_position,prev_sector, explorer,galaxy)
							end
						end
						helper.check_alive (explorer, galaxy.grid.at (explorer.sector_pos), true)
					end
					counter := counter + 1
				end
			end


			msgs.set_wormhole_err (playing, landed, has_wormhole,x, y)

			if msgs.wormhole_err.is_empty then -- then can go through wormhole and display changes
				state := state + 1
				invalid := 0

				--move planets
				helper.move_movables (planet_to_move, msgs ,galaxy, sa) --moves all planets that need to be moved
				if test_m then
					--alll test mode messages
					sectors:= helper.print_all_sectors(galaxy)
					array_of_all_ent.make_empty
					across galaxy.grid is i
					loop
						across i.contents is j
						loop
							if (j.is_planet or j.is_stationary or j.is_explorer or j.is_benign or j.is_malevolent or j.is_janitaur or j.is_asteroid) and not j.dies then
								array_of_all_ent.force ([counter,j], array_of_all_ent.count + 1)
							end
						end
						counter := counter + 1
					end
					descriptions:= helper.print_all_descriptions(array_of_all_ent)
				end
			else
				invalid := invalid + 1
			end
			s := galaxy.out
		end

	reset
			-- Reset model state.
		do
			make
		end

feature -- queries
	out : STRING
		do
			create Result.make_from_string (msgs.spacing)
			Result.append ("state:")
			Result.append (state.out + "." + invalid.out)
			Result.append (", ")
			if (playing and not test_m) or (landed and not test_m and msgs.error_out.is_empty) or (not msgs.explorer_dead.is_empty and not test_m)  then
				Result.append (mode + ":play, ")
			else
				if (test_m and playing) or (test_m and landed and msgs.error_out.is_empty) or (died and test_m) then
					Result.append (mode + ":test, ")
				end
			end
			if not msgs.error_out.is_empty then
				ok := "error%N"
			else
				ok:= "ok%N"
			end
			Result.append (ok)
			if state = 0 and invalid = 0 then
				Result.append (msgs.intial_msg)
			end
			if not msgs.explorer_dead.is_empty then
				Result.append(msgs.explorer_dead + "%N")
			end
			if msgs.error_out.is_empty and not life_on_planet and playing and not landed and not msgs.liftoff.is_empty then
				Result.append(msgs.liftoff)
			end
			if not life_on_planet and msgs.error_out.is_empty then
				Result.append(msgs.land)
			end
			if playing and msgs.error_out.is_empty and msgs.status.is_empty and msgs.liftoff.is_empty and msgs.land.is_empty then
				Result.append (msgs.spacing + movement_msg)
				if not msgs.movement.is_empty then
					Result.append(msgs.movement)
				else
					Result.append (movement)
				end
			else
				if not msgs.movement.is_empty and msgs.liftoff.is_empty and msgs.land.is_empty then
					Result.append (msgs.spacing + movement_msg)
					Result.append(msgs.movement)
				else
					if (not msgs.movement.is_empty and not msgs.liftoff.is_empty) or (not msgs.movement.is_empty and not msgs.land.is_empty) then
						Result.append ("%N" + msgs.spacing + movement_msg)
						Result.append(msgs.movement)
					end
				end
			end
			if not msgs.error_out.is_empty then
				Result.append (msgs.error_out)
				s.make_empty
			else
				Result.append (msgs.non_error_out)
			end
			if (test_m and playing and msgs.error_out.is_empty and msgs.status.is_empty) or (test_m and died and msgs.error_out.is_empty and msgs.status.is_empty) then
				Result.append(sectors)
				Result.append(descriptions)
				if msgs.deaths_this_turn.is_empty and msgs.lost_fuel.is_empty and msgs.explorer_properties.is_empty then
					Result.append("  Deaths This Turn:none")
				else
					Result.append("  Deaths This Turn:%N")
					if died and test_m or died then
						Result.append(msgs.explorer_properties)
						Result.append(msgs.spacing + msgs.spacing + msgs.lost_fuel + "%N")
					end
					Result.append(msgs.deaths_this_turn)
				end
			end
			if not s.out.is_empty then
				Result.append (s.out)
			end
			if not error.is_empty then
				Result.append(error.out)
			end
			if died and test_m and not msgs.explorer_dead.is_empty then
				Result.append("%N" + msgs.explorer_dead)
			end
			if life_on_planet and msgs.error_out.is_empty then
				Result.append(msgs.land)
			end
			sectors.make_empty
			descriptions.make_empty
			msgs.make
			error.make_empty
			s.make_empty
		end
end
