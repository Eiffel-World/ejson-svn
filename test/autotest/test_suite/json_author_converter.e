note
    description: "A JSON converter for AUTHOR"
    author: "Paul Cohen"
    date: "$Date: 2010-03-08 20:46:59 -0300 (Mon, 08 Mar 2010) $"
    revision: "$Revision: 82 $"
    file: "$HeadURL: https://svn.origo.ethz.ch/ejson/branches/POC-converters-factory/test/json_author_converter.e $"

class JSON_AUTHOR_CONVERTER

inherit
    JSON_CONVERTER

create
    make

feature {NONE} -- Initialization

    make
        local
            ucs: STRING_32
        do
            create ucs.make_from_string ("")
            create object.make (ucs)
        end

feature -- Access

    object: AUTHOR

feature -- Conversion

    from_json (j: like to_json): detachable like object
        local
            ucs: detachable STRING_32
        do
            ucs ?= json.object (j.item (name_key), Void)
            check ucs /= Void end
            create Result.make (ucs)
        end

    to_json (o: like object): JSON_OBJECT
        do
            create Result.make
            Result.put (json.value (o.name), name_key)
        end

feature    {NONE} -- Implementation

    name_key: JSON_STRING
        once
            create Result.make_json ("name")
        end

end -- class JSON_AUTHOR_CONVERTER
