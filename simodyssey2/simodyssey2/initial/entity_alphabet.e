note
    description: "[
       Alphabet allowed to appear on the galaxy board.
    ]"
    author: "Kevin Banh"
    date: "April 30, 2019"
    revision: "1"

class
    ENTITY_ALPHABET

inherit
    ANY
        redefine
            out,
            is_equal
        end

create
    make,make_empty

feature -- Constructor

    make (a_char: CHARACTER)
        do
            item := a_char
            is_attached := false
            supports_life := false
            visited := false
            landed := false
            max_fuel := 3
            create turns_left.default_create
            create id.default_create
            create sector_pos.default_create
            create luminosity.default_create
            create actions_left_until_reproduction.default_create
            if a_char = 'E' then
            	fuel := max_fuel
            	life := 3
            else
            	create fuel.default_create
            	create life.default_create
            end
            if a_char = 'J' then
            	load := 0
            end
            dies := false
        end

feature -- Attributes

    item: CHARACTER
    turns_left : INTEGER
    id : INTEGER
    sector_pos : INTEGER
    is_attached :BOOLEAN
    supports_life: BOOLEAN
    visited : BOOLEAN
    luminosity :INTEGER
    fuel : INTEGER
    life : INTEGER
    dies : BOOLEAN
    landed :BOOLEAN
    actions_left_until_reproduction : INTEGER
    max_fuel : INTEGER
    load : INTEGER


feature -- Query

	make_empty
		do
			item := '-'
		end

    out: STRING
            -- Return string representation of alphabet.
        do
            Result := item.out
        end

    is_equal(other : ENTITY_ALPHABET): BOOLEAN
        do
            Result := current.item.is_equal (other.item)
        end

    is_stationary: BOOLEAN
          -- Return if current item is stationary.
    	do
           if item = 'W' or item = 'Y' or item = '*' or item = 'O' then
           		Result := True
           end
        end

    is_moveable : BOOLEAN
    	do
    		if item = 'M' or item = 'B'or item = 'P' or item = 'J' or item = 'A' then
    			Result := true
    		end
    	end

    is_wormhole :BOOLEAN
    	do
    		if item = 'W' then
    			Result := true
    		end
    	end

    is_yellow_dwarf :BOOLEAN
    	do
    		if item = 'Y' then
    			Result := true
    		end
    	end

	is_blue_gaint :BOOLEAN
    	do
    		if item = '*' then
    			Result := true
    		end
    	end

    is_planet: BOOLEAN
    	do
    		if item = 'P' then
    			Result := true
    		end
    	end

    is_explorer: BOOLEAN
    	do
    		if item = 'E' then
    			Result := true
    		end
    	end

    is_star: BOOLEAN
    	do
    		 if item = '*' or item = 'Y' then
    			Result := true
    		end
    	end

    is_blackhole: BOOLEAN
    	do
    		 if item = 'O' then
    			Result := true
    		end
    	end

    is_benign : BOOLEAN
    	do
    		if item = 'B' then
    			Result := true
    		end
    	end

    is_malevolent : BOOLEAN
    	do
    		if item = 'M' then
    			Result := true
    		end
    	end

     is_janitaur : BOOLEAN
    	do
    		if item = 'J' then
    			Result := true
    		end
    	end

     is_asteroid : BOOLEAN
    	do
    		if item = 'A' then
    			Result := true
    		end
    	end

    is_filler : BOOLEAN
    	do
    		if item = '-' then
    			Result := true
    		end
    	end

    set_actions_left_until_reproduction(i : INTEGER)
    	do
    		actions_left_until_reproduction := i
    	end

    set_turns_left (i: INTEGER)
    	do
    		turns_left := i
    	end
	set_id (i :INTEGER)
		do
			id := i
		end
	set_sector_pos (g : GALAXY)
		local
			counter :INTEGER
		do
			across
				g.grid is s
			loop
				counter := 1
				across s.contents is a
				loop
					if a.id ~ CURRENT.id and a.item ~ CURRENT.item then
						sector_pos := counter
					end
					counter := counter + 1
				end
			end
		end

	set_luminosity(i : INTEGER)
		do
			luminosity := i
		end

	set_attached (b : BOOLEAN)
		do
			is_attached := b
		end

	set_supports_life (b: BOOLEAN)
		do
			supports_life := b
		end

	set_visited(b: BOOLEAN)
		do
			visited := b
		end

	set_landed(b:BOOLEAN)
		do
			landed := b
		end

	set_max_fuel(f : INTEGER)
		do
			max_fuel := f
		end

	dead
		do
			dies := true
			life := 0
		end

	decrease_fuel
		do
			fuel := fuel - 1
		end

	decrease_life
		do
			life := life - 1
		end

	decrease_actions_left_until_reproduction
		do
			actions_left_until_reproduction := actions_left_until_reproduction - 1
		end

	increase_fuel (i : INTEGER)
		local
			sa : SHARED_INFORMATION_ACCESS
		do
			fuel := fuel + i
			if current.is_explorer then
				if fuel > max_fuel then
					fuel := max_fuel
				end
			else
				if current.is_janitaur then
					if fuel > sa.shared_info.janitaur_max_fuel then
						fuel := sa.shared_info.janitaur_max_fuel
					end
				else
					if current.is_malevolent then
						if fuel > sa.shared_info.malevolent_max_fuel then
							fuel := sa.shared_info.malevolent_max_fuel
						end
					else
						if current.is_benign then
							if fuel > sa.shared_info.benign_max_fuel then
								fuel := sa.shared_info.benign_max_fuel
							end
						end
					end
				end
			end
		end

	increase_load
		do
			load := load + 1
		end

	set_load(i: INTEGER)
		do
			load := i
		end

invariant
    allowable_symbols:
        item = 'E' or item = 'P' or item = 'A' or item = 'M' or  item = 'J' or item = 'O' or item = 'W' or item = 'Y' or item = '*' or item='B' or item = '-'
end
