indexing

	description: "JSON Numbers, octal and hexadecimal formats are not used."
	author: "Javier Velilla"
	date: "2008/08/24"
	revision: "Revision 0.1"
	license:"MIT (see http://www.opensource.org/licenses/mit-license.php)"

class
	JSON_NUMBER

inherit
	JSON_VALUE
		redefine
			is_equal
		end

create
	make_integer,
	make_real

feature {NONE} -- initialization

	make_integer (an_argument: INTEGER) is
			-- Initialize  an instance of JSON_NUMBER as INTEGER
		do
			item := an_argument.out
			numeric_type := INTEGER_TYPE
		end

	make_real (an_argument: DOUBLE) is
			-- Initialize an instance of JSON_NUMBER as DOUBLE
		do
			item := an_argument.out
			numeric_type := DOUBLE_TYPE
		end

feature -- Access

	item: STRING
			-- Content

	hash_code: INTEGER is
			--Hash code value
		do
			Result := item.hash_code
		end

feature -- Visitor pattern

	accept (a_visitor: JSON_VISITOR) is
			-- Accept `a_visitor'.
			-- (Call `visit_json_number' procedure on `a_visitor'.)
		do
			a_visitor.visit_json_number (Current)
		end

feature -- Status

	is_equal (other: like Current): BOOLEAN is
			-- Is `other' attached to an object of the same type
			-- as current object and identical to it?
		do
			Result := item.is_equal (other.item)
		end

feature -- Status report

	debug_output: STRING
			-- String that should be displayed in debugger to represent `Current'.
		do
			Result := item
		end

feature -- Implementation

	INTEGER_TYPE: INTEGER is 1
	DOUBLE_TYPE: INTEGER is 2

	numeric_type: INTEGER

invariant
	item_not_void: item /= Void

end
