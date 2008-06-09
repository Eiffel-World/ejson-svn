indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JSON_PARSER
		inherit
		JSON_READER
		JSON_TOKENS

create
	make_parser
feature -- Access
    is_parsed:BOOLEAN

    current_errors:STRING

	make_parser(a_json:STRING) is
			--
			do
				make(a_json)
				is_parsed:=true
			end

    parse_json:JSON_VALUE is
    		--
    	do
    		Result:=parse
    		if extra_elements then
    			is_parsed:=false
    		end
    	end

	parse:JSON_VALUE is
			--
			local
				c:CHARACTER
			do
				if is_parsed then
					skip_withe_spaces
					c:=actual
					if c.is_equal (j_object_open) then
						Result:=parse_object
					elseif c.is_equal (j_string) then
						Result:=parse_string
					elseif c.is_equal (j_array_open) then
						Result:=parse_array
					elseif c.is_digit or c.is_equal (j_minus) or
					 	c.is_equal (j_plus) or c.is_equal (j_dot)	 then
						Result:=parse_number
					elseif is_null  then
						--
						Result:=create {JSON_NULL}
						next;next;next;
					elseif is_true then
						Result:=create {JSON_BOOLEAN}.make_boolean (true)
						next;next;next;
					elseif is_false then
						Result:=create {JSON_BOOLEAN}.make_boolean (false)
						next;next;next;next;
					else
						is_parsed:=false
						Result:=void
					end
				end
		  end

	parse_object:JSON_OBJECT is
			-- object
			-- {}
			-- {"key" : "value" [,]}

			local
				has_more:BOOLEAN
				l_json_string:JSON_STRING
				l_value:JSON_VALUE
			do
				create Result.make
				-- check if is an empty object {}
				next
				skip_withe_spaces
				if actual.is_equal (j_object_close) then
				   --is an empty object		
				else
				    -- a complex object {"key" : "value"}
					previous
					from has_more:=true until not has_more
					loop
						next
						skip_withe_spaces
						l_json_string:=parse_string
						next
						skip_withe_spaces
 						if actual.is_equal (':') then
						  	next
						  	skip_withe_spaces
						else
						  is_parsed:=false
						  --excpetions.raise("%N Input string is a not well formed JSON, expected: %":%", found:" +actual.out +"%N")
						  has_more:=false
						end

						l_value:=parse
						if is_parsed then
							Result.put (l_value,l_json_string)
							next
							skip_withe_spaces
							if actual.is_equal (j_object_close) then
								has_more:=false
							elseif not actual.is_equal (',') then
								has_more:=false
								is_parsed:=false
								--excpetions.raise("JSON Object sintactically malformed expected :%"'%" ")
							end
					    else
					    	has_more:=false
					    	-- explain the error	
					    end
					end
				end
			end

	parse_string:JSON_STRING is
			--
			local
				has_more:BOOLEAN
				l_json_string:STRING
			do
				create l_json_string.make_empty
				if actual.is_equal (j_string) then
					from
						has_more:=true
					until not has_more

					loop
						next
						if actual.is_equal (j_string) then
							has_more:=false
						elseif close_tokens.has (actual) then
						    has_more:=false
						    is_parsed:=false
						    --excpetions.raise("Input String is not well formed JSON, expected %"")
						elseif actual.is_equal ('%N') then
							next
							if not special_characters.has (actual) then
								has_more:=false
								is_parsed:=false
								-- explain exception
							else
								l_json_string.append (actual.out)
							end
						elseif special_characters.has (actual) then
								has_more:=false
								is_parsed:=false
								-- explain exception	
						else
							l_json_string.append (actual.out)
						end
					end
					create Result.make_json (l_json_string)
				else
					Result := void
		        end
			end

		parse_array:JSON_ARRAY is
			-- array
			-- []
			-- [elements [,]]
			local
				flag:BOOLEAN
				l_value:JSON_VALUE
			do
				create Result.make_array
				--check if is an empty array []
				next
				skip_withe_spaces
				if actual.is_equal (j_array_close) then
				   --is an empty array		
				else
					previous
					from
						flag:=true
					until
						not flag
					loop
						next
						skip_withe_spaces
						l_value := parse
						if is_parsed then
							Result.add (l_value)
							next
							skip_withe_spaces
							if  not actual.is_equal (j_array_close) and not actual.is_equal (',')then
								flag:=false
								is_parsed:=false
								--excpetions.raise("%NInput string is not well formed JSON, expected:  ',' or ']', and found: " +actual.out+"%N")
							elseif actual.is_equal (j_array_close)	then
							    flag:= false
							end
						else
							flag:=false
							--explain the error	
						end
					end
				end
			end

	parse_number:JSON_NUMBER is
			--
			local
				sb:STRING
				flag:BOOLEAN
			do
				create sb.make_empty
				if not actual.is_equal (j_plus) then
					sb.append (actual.out)
				end

				from
					flag:=true
				until not flag
				loop
					next
					if not has_next or close_tokens.has (actual) or actual.is_equal (',')
					  or actual.is_equal ('%N')  or actual.is_equal ('%R') then
					     flag:=false
						previous
					else
						sb.append (actual.out)
					end
				end

				if sb.is_double then
					create Result.make_real (sb.to_double)
				elseif sb.is_integer then
					create Result.make_integer (sb.to_integer)
				else
				    is_parsed:=false
				  -- excpetions.raise ("Input string is an not well formed JSON")
				  -- print ("Input string is an not well formed JSON")
				end
			end


		is_null:BOOLEAN is
			--
			local
				l_null:STRING
				l_string:STRING
			do
				l_null:="null"
				l_string:=json_substring (index,index + l_null.count - 1)
				if l_string.is_equal (l_null) then
					Result := true
				end
			end

		is_false:BOOLEAN is
			--
			local
			l_false:STRING
			l_string:STRING
			do
				l_false:="false"
				l_string:=json_substring (index,index + l_false.count - 1)
				if l_string.is_equal (l_false) then
					Result := true
				end
			end

		is_true:BOOLEAN is
				--
				local
					l_true:STRING
					l_string:STRING
				do
					l_true:="true"
					l_string:=json_substring (index,index + l_true.count - 1)
					if l_string.is_equal (l_true) then
						Result := true
					end
				end
feature {NONE}

		extra_elements:BOOLEAN is
				--has more elements?
				local
					l_string:STRING
				do

                    if has_next then
                    	next
                    end
					from
					until not actual.is_space or  not actual.is_equal ('%R') or
						  not actual.is_equal ('%U') or  not actual.is_equal ('%T')
						  or not actual.is_equal ('%N') or not has_next
					loop
						next
					end

                    if has_next then
                    	Result:=True
                    end

				end


end
