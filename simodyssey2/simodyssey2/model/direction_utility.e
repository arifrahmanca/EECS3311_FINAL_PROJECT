note
	description: "Summary description for {DIRECTION_UTILITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

expanded class
	DIRECTION_UTILITY

feature -- Queries

	N: INTEGER
			-- Tuple modifier for North
			-- move up one row (1)
		once
			Result := -5
		end

	E: INTEGER
			-- Tuple modifier for East
		once
			Result := 1
		end

	S: INTEGER
			-- Tuple modifier for South
		once
			Result := 5
		end

	W: INTEGER
			-- Tuple modifier for West
		once
			Result := -1
		end

	NE: INTEGER
			-- Tuple modifier for North East
			-- move up one row (1)
		once
			Result := -4
		end

	NW: INTEGER
			-- Tuple modifier for North West
		once
			Result := -6
		end

	SE: INTEGER
			-- Tuple modifier for South East
		once
			Result := 6
		end

	SW: INTEGER
			-- Tuple modifier for South West
		once
			Result := 4
		end

	dir_arr: ARRAY [INTEGER]
			-- Array of each of the cardinal direction modifiers
		once
			Result := <<N, NE, E, SE, S, SW, W, NW>>
		end

	cal_new(curr : INTEGER; rows: INTEGER; col: INTEGER; move : INTEGER) : INTEGER
		local
			h_edge_case :INTEGER
			temp : INTEGER
			i : INTEGER
			dir_e: INTEGER
			dir_w: INTEGER
		do
			h_edge_case := col - 1
			temp := curr - 1
			dir_e := curr - h_edge_case
			dir_w := curr + h_edge_case

			if curr.integer_remainder (col) = 0 and move = E then -- move E
					Result := dir_e
			else if temp.integer_remainder (col) = 0 and move = W  then --move W
					Result := dir_w
				else if curr.integer_remainder (col) = 0 and move = NE then -- move NE
						i := dir_e
						Result := i + N
					else if temp.integer_remainder (col) = 0 and move = NW then -- move NW
							i := dir_w
							Result := i + N
						else if curr.integer_remainder (col) = 0 and move = SE then --move SE
									i := dir_e
									Result := i + S
							else if temp.integer_remainder (col) = 0 and move = SW then -- move SW
									i := dir_w
									Result := i + S
								else -- regular case
									Result := curr + move
							end
						end
					end
				end
				end
			end

			if Result <= 0  then
				Result := Result + (rows*col)
			else if Result > (rows*col) then
				Result := Result.integer_remainder (rows*col)
				end
			end
		end

	num_dir (int: INTEGER): INTEGER
			-- Convert an integer encoding to a direction.
		do
			inspect int
			when 1 then
				Result := N
			when 2 then
				Result := NE
			when 3 then
				Result := E
			when 4 then
				Result := SE
			when 5 then
				Result := S
			when 6 then
				Result := SW
			when 7 then
					Result := W
			else
				Result := NW
			end
		end

end
