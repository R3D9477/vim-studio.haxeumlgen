if exists("g:vimStudio_haxeumlgen_init")
	if g:vimStudio_haxeumlgen_init == 1
		finish
	endif
endif

let g:vimStudio_haxeumlgen_init = 1

"-------------------------------------------------------------------------

let g:vimStudio_haxeumlgen#plugin_dir = expand("<sfile>:p:h:h")

"-------------------------------------------------------------------------

function! vimStudio_haxeumlgen#generate(type)
	echo "Wait, please..."
	
	let js_result = vimStudio#request(g:vimStudio_haxeumlgen#plugin_dir, "haxeumlgen", "make_uml", ['"' . g:vimStudio#buf#mask_bufname . '"', '"' . g:vimStudio_vaxe#project . '"', '"' . a:type . '"'])
	
	echo ""
	call feedkeys("\<CR>")
	
	return js_result
endfunction

"-------------------------------------------------------------------------

function! vimStudio_haxeumlgen#on_project_before_open()
	if g:vimStudio_vaxe#is_valid_project == 1
		call add(g:vimStudio#integration#context_menu_dir, g:vimStudio_haxeumlgen#plugin_dir . "/menu")
	endif
	
	return 1
endfunction

function! vimStudio_haxeumlgen#on_before_project_close()
	let cdil = vimStudio#debug#incrase_ierarchy_level()
	
	if g:vimStudio_vaxe#is_valid_project == 1
		call remove(g:vimStudio#integration#context_menu_dir, index(g:vimStudio#integration#context_menu_dir, g:vimStudio_haxeumlgen#plugin_dir . "/menu"))
	endif
	
	return 1
endfunction

"-------------------------------------------------------------------------

function! vimStudio_haxeumlgen#on_menu_item(menu_id)
	let continue_handling = 1
	
	if g:vimStudio_vaxe#is_valid_project == 1
		let continue_handling = 0
		
		if a:menu_id == "haxeumlgen_dot"
			let result = vimStudio_haxeumlgen#generate('dot')
		elseif a:menu_id == "haxeumlgen_xmi"
			let result = vimStudio_haxeumlgen#generate('xmi')
		else
			let result = 0
			let continue_handling = 1
		endif
		
		if result == 1
			call vimStudio#project#update()
		endif
	endif
	
	return continue_handling
endfunction

"-------------------------------------------------------------------------

call vimStudio#integration#register_module("vimStudio_haxeumlgen")
