--[[This Lua script draws vertical bar indicators]]

require 'cairo'

function conky_main ()
	if conky_window == nil then return end

	local cs = cairo_xlib_surface_create (conky_window.display,
			conky_window.drawable, conky_window.visual, conky_window.width,
			conky_window.height)

	cr = cairo_create (cs)

	font = "Monospace"
	font_size = 25
	text = conky_parse ("${execi 60 bash-fuzzy-clock}"):upper()
	midx, midy = conky_window.width/2, conky_window.height/2
	local extents = cairo_text_extents_t:create()
	tolua.takeownership(extents)
	red, green, blue, alpha = 0, 0, 0, 1
	font_slant = CAIRO_FONT_SLANT_NORMAL
	font_face = CAIRO_FONT_WEIGHT_NORMAL
	
	cairo_select_font_face (cr, font, font_slant, font_face);
	cairo_set_font_size (cr, font_size)
	cairo_set_source_rgba (cr, red, green, blue, alpha)
	cairo_text_extents (cr, text, extents);
	cairo_move_to (cr, midx-(extents.width / 2 + extents.x_bearing), midy-(extents.height / 2 + extents.y_bearing))
	cairo_show_text (cr, text)

	cairo_destroy (cr)
	cairo_surface_destroy (cs)
	cr = nil

end
