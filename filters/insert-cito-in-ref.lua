-- Copyright © 2021 Albert Krewinkel
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.

local List = require 'pandoc.List'
local utils = require 'pandoc.utils'
local citation_properties

local function meta_citation_properties (meta)
  citation_properties = meta.citation_properties
end

local function cito_properties(cite_id)
  local props = citation_properties[cite_id]
  if not props then return {} end

  return List(props):map(
    function (x)
      return pandoc.Strong{
        pandoc.Space(),
        pandoc.Str '[cito:',
        pandoc.Str(utils.stringify(x)),
        pandoc.Str ']'
      }
    end
  )
end

local function add_cito (div)
  local cite_id = div.identifier:match 'ref%-(.*)'
  if cite_id and div.classes:includes 'csl-entry' then
    return pandoc.walk_block(
      div,
      {
        Span = function (span)
          if span.classes:includes 'csl-right-inline' then
            span.content:extend(cito_properties(cite_id))
            return span
          end
        end
      }
    )
  end
end

return {
  {Meta = meta_citation_properties},
  {Div = add_cito},
}
