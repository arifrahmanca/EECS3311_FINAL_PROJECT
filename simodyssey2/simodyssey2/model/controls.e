note
	description: "Summary description for {CONTROLS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

expanded class
	CONTROLS


feature -- main controls

	fill_up_galaxy(galaxy : GALAXY)
		local
			filler : ENTITY_ALPHABET
			sa : SHARED_INFORMATION_ACCESS
		do
			create filler.make_empty
			across
				1 |..| galaxy.grid.count is i
			loop
				across 1 |..| galaxy.grid.at (i).contents.capacity is j
				loop
					if galaxy.grid.at (i).contents.count < sa.shared_info.max_capacity then
						galaxy.grid.at (i).contents.force (filler)
					end
				end
			end
		end


--	move_movables (planets_being_moved : ARRAY[TUPLE[g: INTEGER; e:ENTITY_ALPHABET]]; msgs : MESSAGES; galaxy : GALAXY; sa : SHARED_INFORMATION_ACCESS)
--		local
--			planet : ENTITY_ALPHABET
--			filler : ENTITY_ALPHABET
--			prev_planet_position : INTEGER
--			new_planet_position : INTEGER
--			num : INTEGER
--			mv : INTEGER
--			direction : DIRECTION_UTILITY
--			deaths : ARRAY[ENTITY_ALPHABET]
--			planet_to_move :ARRAY[TUPLE[g: INTEGER; e:ENTITY_ALPHABET]]
--			prev_sector : INTEGER
--			used_wormhole : BOOLEAN
--		do
--			create filler.make_empty
--			create deaths.make_empty
--			planet_to_move := sort_by_id(planets_being_moved) -- sort list by ids then move from lowest id to highest

--			across
--				planet_to_move is a
--			loop
--				used_wormhole := false
--				planet := a.e
--				prev_planet_position := a.g
--				if planet.turns_left = 0 then
--					if planet.is_planet and galaxy.grid.at (prev_planet_position).has_star then
--						planet.set_attached (true)
--						if galaxy.grid.at (prev_planet_position).has_yellow_dwarf then
--							num := galaxy.gen.rchoose (1, 2)
--							if num = 2 then
--								planet.set_supports_life (true)
--							end
--						end
--					else
--						if galaxy.grid.at (prev_planet_position).has_wormhole and (planet.is_malevolent or planet.is_benign) then
--							new_planet_position:= prev_planet_position
--							new_planet_position := wormhole(planet, galaxy ,prev_planet_position) -- uses wormhole if malevolent of is benign and wormhole in same sector
--							used_wormhole := true
--						else
--							--move planet if not attached
--							--START OF MOVEMENT
--							mv := galaxy.gen.rchoose (1, 8) --which direction planet moves in
--							mv := direction.num_dir (mv)
--							new_planet_position := direction.cal_new (prev_planet_position, galaxy.shared_info.number_rows, galaxy.shared_info.number_columns, mv)
--							    --move planet if space in sector
--							if galaxy.grid.at (new_planet_position).next_available_quad <= galaxy.grid.at (new_planet_position).contents.count then
--								galaxy.grid.at (prev_planet_position).contents.put_i_th (filler, planet.sector_pos)  ---REMOVE E from its current grid position
--								galaxy.grid.at (new_planet_position).contents.put_i_th (planet, galaxy.grid.at (new_planet_position).next_available_quad)
--							else --if no space then it stay where it is
--								new_planet_position:= prev_planet_position
--							end
--							--MOVEMENT ENDS
--						end
--						check_alive (planet, galaxy.grid.at (new_planet_position), used_wormhole) -- ensures planet is alive aftr moving
--						prev_sector := planet.sector_pos
--						planet.set_sector_pos (galaxy) -- update position in sector
--						msgs.set_movements_made(prev_planet_position, new_planet_position,prev_sector, planet, galaxy)


--						if not planet.dies then
--							reproduce(planet, galaxy.grid.at (a.g), sa)
--							behave (planet, galaxy.grid.at (new_planet_position))
--						else
--							planet.dead
--							deaths.force (planet, deaths.count + 1)
--							galaxy.grid.at (new_planet_position).contents.put_i_th (filler, planet.sector_pos)  ---REMOVE E from its current grid position
--							--if in test do something
--						end
--					end --has star or doesnt ends here
--				else
--					planet.set_turns_left (planet.turns_left - 1)
--				end
--			end
--			--msgs add to current deaths everything thats in deaths array
--			msgs.set_deaths_this_turn(deaths)
--		end



	move_movables (moveables_being_moved : ARRAY[TUPLE[g: INTEGER; e:ENTITY_ALPHABET]]; msgs : MESSAGES; galaxy : GALAXY;sa : SHARED_INFORMATION_ACCESS )
		local
			moveable : ENTITY_ALPHABET
			filler : ENTITY_ALPHABET
			prev_movable_position : INTEGER
			new_movable_position : INTEGER
			num : INTEGER
			mv : INTEGER
			direction : DIRECTION_UTILITY
			deaths : ARRAY[TUPLE[e :ENTITY_ALPHABET; s : STRING]]
			moveable_to_move :ARRAY[TUPLE[g: INTEGER; e:ENTITY_ALPHABET]]
			prev_sector : INTEGER
			used_wormhole : BOOLEAN
			dead_from : ARRAY[TUPLE[e :ENTITY_ALPHABET; s : STRING]]
			str : STRING
		do
			create filler.make_empty
			create deaths.make_empty
			moveable_to_move := sort_by_id(moveables_being_moved) -- sort list by ids then move from lowest id to highest
			create str.make_empty
			across
				moveable_to_move is a
			loop
				used_wormhole := false
				moveable := a.e
				prev_movable_position := a.g
				if moveable.turns_left = 0 and not moveable.dies then
					if moveable.is_planet and galaxy.grid.at (prev_movable_position).has_star then
						moveable.set_attached (true)
						if galaxy.grid.at (prev_movable_position).has_yellow_dwarf then
							num := galaxy.gen.rchoose (1, 2)
							if num = 2 then
								moveable.set_supports_life (true)
							end
						end
					else
						if galaxy.grid.at (prev_movable_position).has_wormhole and (moveable.is_malevolent or moveable.is_benign) then
							new_movable_position := wormhole(moveable, galaxy ,prev_movable_position) -- uses wormhole if malevolent of is benign and wormhole in same sector
							used_wormhole := true
						else
							--move planet if not attached
							--START OF MOVEMENT
							if moveable.is_malevolent or moveable.is_benign or moveable.is_planet or moveable.is_asteroid or moveable.is_janitaur then
								mv := galaxy.gen.rchoose (1, 8) --which direction planet moves in
								mv := direction.num_dir (mv)
								new_movable_position := direction.cal_new (prev_movable_position, galaxy.shared_info.number_rows, galaxy.shared_info.number_columns, mv)
							    --move planet if space in sector
								if galaxy.grid.at (new_movable_position).next_available_quad <= galaxy.grid.at (new_movable_position).contents.count then
									galaxy.grid.at (prev_movable_position).contents.put_i_th (filler, moveable.sector_pos)  ---REMOVE E from its current grid position
									galaxy.grid.at (new_movable_position).contents.put_i_th (moveable, galaxy.grid.at (new_movable_position).next_available_quad)
								else --if no space then it stay where it is
									new_movable_position:= prev_movable_position
								end
							end
							--MOVEMENT ENDS
						end
						prev_sector := moveable.sector_pos
						moveable.set_sector_pos (galaxy) -- update position in sector
						check_alive (moveable, galaxy.grid.at (new_movable_position), used_wormhole) -- ensures planet is alive aftr moving --problem
						msgs.set_movements_made(prev_movable_position, new_movable_position, prev_sector, moveable, galaxy)

						if not moveable.dies then
							reproduce(moveable, galaxy.grid.at (new_movable_position), sa, msgs, galaxy)
							dead_from := behave (moveable, galaxy.grid.at (new_movable_position), msgs) --problem
							if not dead_from.is_empty then
								across
									dead_from is e
								loop
									deaths.force ([e.e , e.s], deaths.count + 1)
								end
							end
						else
							deaths.force ([moveable, str], deaths.count + 1)
							galaxy.grid.at (new_movable_position).contents.put_i_th (filler, moveable.sector_pos)  ---REMOVE E from its current grid position
							--if in test do something
						end
					end --has star or doesnt ends here
				else
					moveable.set_turns_left (moveable.turns_left - 1)
				end
			end
			--msgs add to current deaths everything thats in deaths array
			msgs.set_deaths_this_turn(deaths)
		end



	behave(ent: ENTITY_ALPHABET; sector : SECTOR; msgs : MESSAGES) :  ARRAY[TUPLE[e :ENTITY_ALPHABET; s: STRING]]
		local
			num : INTEGER
			gen : RANDOM_GENERATOR_ACCESS
			low_high : ARRAY[TUPLE[id : INTEGER; e : ENTITY_ALPHABET]]
			explorer : ENTITY_ALPHABET
			filler : ENTITY_ALPHABET
			deaths : ARRAY[TUPLE[e :ENTITY_ALPHABET; s: STRING]]
			string : STRING
		do
			create deaths.make_empty
			create low_high.make_empty
			create explorer.make_empty
			create filler.make_empty
			create string.make_empty
			across
				sector.contents is item
			loop
				low_high.force ([item.id, item], low_high.count + 1)
			end
			low_high := sort_by_id(low_high)
			if ent.is_asteroid then
				across
					low_high is item
				loop
					string.make_empty
					if (item.e.is_benign or item.e.is_malevolent or item.e.is_janitaur) then
						item.e.dead
						if item.e.is_malevolent then
							string := "Malevolent got destroyed by asteroid (id: " + ent.id.out + ") at Sector:" + sector.row.out +  ":" + sector.column.out
						end
						if item.e.is_janitaur then
							string := "Janitaur got destroyed by asteroid (id: " + ent.id.out + ") at Sector:" + sector.row.out +  ":" + sector.column.out
						end
						if item.e.is_benign then
							string := "Benign got destroyed by asteroid (id: " + ent.id.out + ") at Sector:" + sector.row.out +  ":" + sector.column.out
						end
						deaths.force ([item.e, string], deaths.count + 1)
						sector.contents.put_i_th (filler, item.e.sector_pos)
						msgs.kills(item.e, sector)
					end

					if item.e.is_explorer then
						item.e.dead
						msgs.kills(item.e, sector)
						string := "Explorer got destroyed by asteroid (id: " + ent.id.out + ") at Sector:" + sector.row.out +  ":" + sector.column.out
						msgs.explorer_death_message(string)
					end
				end
				ent.set_turns_left (gen.rchoose (0, 2))
			else
				if ent.is_janitaur then
					across
						low_high is item
					loop
						if item.e.is_asteroid and ent.load < 2 then
							item.e.dead
							string := "Asteroid got imploded by janitaur (id: " + ent.id.out + ") at Sector:" + sector.row.out +  ":" + sector.column.out
							deaths.force ([item.e, string], deaths.count + 1)
							ent.increase_load
							sector.contents.put_i_th (filler, item.e.sector_pos)
							msgs.kills(item.e, sector)
						end
					end
					--janitaur uses the wormhole to clear their load
					if sector.has_wormhole then
						ent.set_load(0)
					end
					ent.set_turns_left (gen.rchoose (0, 2))
				else
					if ent.is_benign then
						across
							low_high is item
						loop
							if item.e.is_malevolent then
								item.e.dead
								if item.e.is_malevolent then
									string := "Malevolent got destroyed by benign (id: " + ent.id.out + ") at Sector:" + sector.row.out +  ":" + sector.column.out
								end
								deaths.force ([item.e, string], deaths.count + 1)
								sector.contents.put_i_th (filler, item.e.sector_pos)
								msgs.kills(item.e, sector)
							end
						end
						ent.set_turns_left (gen.rchoose (0, 2))
					else
						if ent.is_malevolent then
							if sector.has_explorer and not sector.has_benign  then --sector has explorer and doesnt have benign and explorer not landed explorer life decrement by 1 if life = 0 after decrement then explorer.dead
								across
									low_high is item
								loop
									if item.e.is_explorer then
										explorer := item.e
									end
								end
								if not explorer.landed and explorer.is_explorer then
									explorer.decrease_life
									if explorer.life = 0 then
										explorer.dead
										msgs.kills(explorer, sector)
										--add killed msg
									end
								end
							end
							ent.set_turns_left (gen.rchoose (0, 2))
						else
							if ent.is_planet then
								if sector.has_star then
									ent.set_attached (true)
									if sector.has_yellow_dwarf then
										num := gen.rchoose (1,2)
										if num = 2 then
											ent.set_supports_life (true)  --set star to supports life
										end
									end
								else
									ent.set_turns_left (gen.rchoose (0,2))
								end
							end
						end
					end
				end
			end
			Result := deaths
		end

	check_alive(ent : ENTITY_ALPHABET; sector : SECTOR; used_wormhole: BOOLEAN) --only use after moving a planet and explorer
		do
			if (ent.is_benign or ent.is_janitaur or ent.is_malevolent or ent.is_explorer) and not used_wormhole then ---and never used wormhole
				ent.decrease_fuel
			end

			if (ent.is_benign or ent.is_janitaur or ent.is_malevolent or ent.is_explorer) and sector.has_star then ---FIX THIS
				if sector.has_blue_gaint then
					ent.increase_fuel (5)
				else
					ent.increase_fuel (2)
				end
			end

			if (ent.is_benign or ent.is_janitaur or ent.is_malevolent or ent.is_explorer) and ent.fuel = 0 then
				ent.dead
			end

			if sector.has_blackhole then
				ent.dead --then has blackhole so dies is true
			end
		end

	sort_by_id (moveable_to_movee : ARRAY[TUPLE[g: INTEGER; e:ENTITY_ALPHABET]]) : ARRAY[TUPLE[g: INTEGER; e:ENTITY_ALPHABET]]
		local
			a_comparator: id_COMPARATOR
			a_sorter: DS_ARRAY_QUICK_SORTER [TUPLE[g: INTEGER; e:ENTITY_ALPHABET]]
		do
			create a_comparator
			create a_sorter.make (a_comparator)
			create Result.make_empty
			across
				moveable_to_movee as e
			loop
				Result.force(e.item, Result.count + 1)
			end
			a_sorter.sort (Result)
		end

	reproduce(e: ENTITY_ALPHABET; s : SECTOR; sa : SHARED_INFORMATION_ACCESS; msgs : MESSAGES ; galaxy :GALAXY)
		--some entities may reproduce as turns pass
		local
			cpy: ENTITY_ALPHABET
			gen : RANDOM_GENERATOR_ACCESS
		do
			if e.is_malevolent or e.is_benign or e.is_janitaur then
				if (s.next_available_quad <= s.contents.count) and e.actions_left_until_reproduction = 0 then
					create cpy.make(e.item)
					cpy.set_id(sa.shared_info.next_moveable_id) --moveable id might be messed for reproduced entities

					cpy.set_turns_left (gen.rchoose (0, 2))
					s.contents.put_i_th (cpy, s.next_available_quad)
					cpy.set_sector_pos (galaxy)
					cpy.increase_fuel (3)
					cpy.set_actions_left_until_reproduction (sa.shared_info.malevolent_reproduction)
					msgs.reproduced(cpy, s)

					if e.is_janitaur then
						e.set_actions_left_until_reproduction(2)
					else
						e.set_actions_left_until_reproduction (1)
					end
				else
					if not (e.actions_left_until_reproduction = 0) then
						e.decrease_actions_left_until_reproduction
					else
						if not (s.next_available_quad <= s.contents.count) then
							--reproduce next time
							--may need to fix what goes here
						end
					end
				end
			end
		end

	wormhole(e : ENTITY_ALPHABET; galaxy : GALAXY; prev_position : INTEGER) : INTEGER
		local
			has_wormhole : BOOLEAN
			x : INTEGER
			y : INTEGER
			temp_row : INTEGER
			temp_column : INTEGER
			sa : SHARED_INFORMATION_ACCESS
			gen : RANDOM_GENERATOR_ACCESS
			s : SECTOR
			added : BOOLEAN
			current_position : INTEGER
			filler : ENTITY_ALPHABET
			prev_sector : INTEGER
		do
			create filler.make_empty
			if e.is_malevolent or e.is_benign then
				from
					added := false
				until
					added
				loop
					temp_row := gen.rchoose (1, 5)
					temp_column := gen.rchoose (1, 5)
					s := galaxy.grid[temp_row, temp_column]
					prev_sector := e.sector_pos
					if (s.next_available_quad <= s.contents.count) then
						galaxy.grid.at (prev_position).contents.put_i_th (filler, prev_sector)
						galaxy.grid[temp_row,temp_column].contents.put_i_th (e, galaxy.grid[temp_row,temp_column].next_available_quad)
						current_position := ((temp_row*5) - 5) + temp_column
						Result := current_position
						added:= true
					else
						Result := prev_position
					end
				end
			end
		end

	print_all_sectors (galaxy: GALAXY):STRING -- tells you whats in each sector
		local
			x : INTEGER
			y : INTEGER
			e : ENTITY_ALPHABET
			arr : ARRAY[TUPLE[id, it :STRING]]
			outs :STRING
			msgs : MESSAGES
			counter :INTEGER
		do
			--alll test mode messages
			create Result.make_empty
			create arr.make_empty
			create e.make_empty
			create outs.make_empty
			create msgs.make
			Result.append("%N")
			Result.append(msgs.spacing + "Sectors:")
			across
				1 |..| galaxy.grid.count is i
			loop
				Result.append("%N")
				counter := 1
				across galaxy.grid.at (i).contents.to_array is a
				loop
					if not (counter=1) then
						outs.append(",")
					end
					x := galaxy.grid.at (i).row
					y := galaxy.grid.at (i).column
					if not a.is_filler then
						outs.append("[" + a.id.out + "," + a.item.out + "]")
					else
						outs.append (a.item.out)
					end
					counter := counter + 1
				end

				Result.append(msgs.spacing + msgs.spacing +"[" + x.out + ","+ y.out + "]->"+ outs )
				outs.make_empty
			end
		end

	print_all_descriptions(arr_of_all_ent :ARRAY[TUPLE[g: INTEGER; e:ENTITY_ALPHABET]]) : STRING --give arr of all entities in graph returns print out off all descriptions
		local
			msgs:MESSAGES
			land: STRING
			att : STRING
			supp_life : STRING
			vis :STRING
			a : ARRAY[TUPLE[g: INTEGER; e:ENTITY_ALPHABET]]
			turns : STRING
			sa : SHARED_INFORMATION_ACCESS
		do
			create Result.make_empty
			a := sort_by_id(arr_of_all_ent)
			create msgs.make
			Result.append("%N" + msgs.spacing +"Descriptions:%N")

			across
				a is t
			loop
				if t.e.landed then
					land := "T"
				else
					land := "F"
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

				if t.e.is_attached then
					turns := "N/A"
				else
					turns := t.e.turns_left.out
				end

				if t.e.is_explorer and not t.e.dies then
					Result.append(msgs.spacing + msgs.spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->fuel:" + t.e.fuel.out + "/3, life:" + t.e.life.out + "/3, landed?:" + land+ "%N" )
				else
					if t.e.is_star then
						Result.append(msgs.spacing + msgs.spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->Luminosity:" + t.e.luminosity.out + "%N" )
					else
						if t.e.is_planet and not t.e.dies then
							Result.append(msgs.spacing + msgs.spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->attached?:" + att + ", support_life?:" + supp_life + ", visited?:"+ vis + ", turns_left:" + turns + "%N" )
						else
							if t.e.is_asteroid then
								Result.append(msgs.spacing + msgs.spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->" + "turns_left:"+ turns + "%N" )
							else
								if t.e.is_malevolent then
									Result.append(msgs.spacing + msgs.spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->" + "fuel:"+ t.e.fuel.out + "/" + sa.shared_info.malevolent_max_fuel.out + ", actions_left_until_reproduction:" + t.e.actions_left_until_reproduction.out + "/" + sa.shared_info.malevolent_reproduction.out + ", turns_left:"+ turns + "%N" )
								else
									if t.e.is_benign then
										Result.append(msgs.spacing + msgs.spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->" + "fuel:" + t.e.fuel.out + "/" + sa.shared_info.benign_max_fuel.out + ", actions_left_until_reproduction:" + t.e.actions_left_until_reproduction.out + "/" + sa.shared_info.benign_reproduction.out + ", turns_left:"+ turns + "%N" )
									else
										if t.e.is_janitaur then
											Result.append(msgs.spacing + msgs.spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->" + "fuel:" + t.e.fuel.out + "/" + sa.shared_info.janitaur_max_fuel.out + ", load:" + t.e.load.out + "/" + sa.shared_info.janitaur_max_load.out +  ", actions_left_until_reproduction:" + t.e.actions_left_until_reproduction.out + "/" + sa.shared_info.janitaur_reproduction.out +", turns_left:" + turns + "%N" )
										else
											if not (t.e.item = '-') and not t.e.dies then
												Result.append(msgs.spacing + msgs.spacing + "[" + t.e.id.out + "," + t.e.item.out + "]->%N" )
											end
										end
									end

								end
							end
						end
					end
				end
			end
		end
end
