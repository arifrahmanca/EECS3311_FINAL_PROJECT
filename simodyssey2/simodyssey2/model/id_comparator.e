note
	description: "Summary description for {ID_COMPARATOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ID_COMPARATOR

inherit
	KL_COMPARATOR[TUPLE[g: INTEGER; e:ENTITY_ALPHABET]]

create
	default_create

feature
	attached_less_than (e1, e2: attached TUPLE[g: INTEGER; e:ENTITY_ALPHABET]): BOOLEAN
			-- effect e1 < e2
		do
			Result := e1.e.id < e2.e.id
		end

end
