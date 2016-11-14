package vimStudio.haxeumlgen;

import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.Process;
import systools.Dialogs;

import rn.typext.hlp.FileSystemHelper;

using StringTools;
using rn.typext.ext.XmlExtender;

class VimStudioClient {
	static function echoRequest (request:Array<String>) : String
		return (new Process("neko", ["../../vim-studio/sys/VimStudioClient.n"].concat(request))).stdout.readAll().toString();
	
	public static function main () {
		Sys.setCwd(Path.directory(FileSystem.fullPath(
			#if neko
				neko.vm.Module.local().name
			#elseif cpp
				Sys.executablePath()
			#end
		)));
		
		var args:Array<String> = Sys.args().map(function (arg:String) return arg.replace("\\ ", " ").trim());
		
		switch(args[0]) {
			case "haxeumlgen":
				switch (args[1]) {
					case "make_uml":
						var vimStudio_path:String = args[2];
						var hx_proj_path:String = args[3];
						var uml_type:String = args[4];
						
						hx_proj_path = Path.join([Path.withoutExtension(vimStudio_path), Path.withoutDirectory(hx_proj_path)]);
						
						if (Path.extension(hx_proj_path) != "hxml")
							hx_proj_path = hx_proj_path + ".hxml";
						
						if (!FileSystem.exists(hx_proj_path)) {
							Dialogs.message("Error", "Hxml file doest not exist!", true);
							Sys.stdout().writeString("0");
							return;
						}
						
						var uml_dir:String = "";
						var uml_xml:String = "";
						
						for (line in File.getContent(hx_proj_path).split("\n")) {
							var instruction:Array<String> = line.trim().split(" ");
							
							if (instruction.length > 1 && instruction[0] == "-xml") {
								uml_dir = Path.join([Path.directory(hx_proj_path), Path.directory(instruction[1])]);
								uml_xml = Path.withoutDirectory(instruction[1]);
								
								break;
							}
						}
						
						if (uml_dir == "") {
							uml_dir = Path.join([Path.directory(hx_proj_path), "Uml"]);
							
							if (!FileSystem.exists(uml_dir))
								FileSystem.createDirectory(uml_dir);
						}
						
						if (uml_xml == "") {
							uml_xml = Path.join([uml_dir, Path.withoutExtension(Path.withoutDirectory(hx_proj_path))]);
							FileSystemHelper.appendFile(hx_proj_path, "\n-xml " + FileSystemHelper.getRelativePath(Path.directory(hx_proj_path), uml_xml));
						}
						
						Sys.setCwd(Path.directory(hx_proj_path));
						(new Process("haxe", [Path.withoutDirectory(hx_proj_path)])).stdout.readAll();
						
						Sys.setCwd(uml_dir);
						(new Process("haxelib", ["run", "HaxeUmlGen", uml_type, uml_xml])).stdout.readAll();
						
						FileSystemHelper.execUrl(switch (uml_type) { 
							case "dot":
								Path.join([uml_dir, "Root.png"]);
							case "":
								Path.join([uml_dir, Path.withoutExtension(Path.withoutExtension(Path.withoutDirectory(hx_proj_path))) + "-xmi.xml"]);
							default:
								"";
						});
						
						Sys.stdout().writeString("1");
					default:
						Sys.stdout().writeString("0");
				}
			default:
				Sys.stdout().writeString(echoRequest(args));
		}
	}
}
