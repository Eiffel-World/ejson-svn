indexing
	description:"[
			JSON_VALUE represent a value in JSON. 
					A value can be
						* a string in double quotes
						* a number
						* boolean value(true, false )
						* null
						* an object
						* an array


		]"
	author: "Javier Velilla"
	date: "2008/05/19"
	revision: "Revision 0.1"
	license:"MIT (see http://www.opensource.org/licenses/mit-license.php)"


deferred class
	JSON_VALUE

inherit

	HASHABLE

feature -- Visitor pattern

	accept (a_visitor: JSON_VISITOR) is
			-- Accept `a_visitor'.
			-- (Call `visit_*' procedure on `a_visitor'.)
		require
			a_visitor_not_void: a_visitor /= Void
		deferred
		end
end