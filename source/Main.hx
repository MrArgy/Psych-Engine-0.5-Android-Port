package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import sys.FileSystem;
import lime.app.Application;
import lime.system.System;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var fpsVar:FPS;

	private static var dataPath:String = null;

        static public function getDataPath():String 
        {
            #if android
            if (dataPath != null && dataPath.length > 0) 
            {
                return dataPath;
            } 
            else 
            {
                 dataPath = "/storage/emulated/0/Android/data/" + Application.current.meta.get("packageName") + "/files/";
            }
            return dataPath;
            #end
        }

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleState;
		#end

                #if android

                if (!FileSystem.exists("/storage/emulated/0/Android/data/" + Application.current.meta.get("packageName")))
                {
                    Application.current.window.alert("Try creating A folder Called " + Application.current.meta.get("packageName") + " in data" + "\n" + "Press Ok To Close The App", "Check Directory Error");
                    System.exit(0);//Will close the game
                }
                else if (!FileSystem.exists("/storage/emulated/0/Android/data/" + Application.current.meta.get("packageName") + "/files"))
                {
                    Application.current.window.alert("Try creating A folder Called Files in data" + Application.current.meta.get("packageName") + "\n" + "Press Ok To Close The App", "Check Directory Error");
                    System.exit(0);//Will close the game
                }
                else if (!FileSystem.exists(Main.getDataPath() + "assets"))
                {
                    Application.current.window.alert("Try copying assets/assets from apk to " + " /storage/emulated/0/Android/data/" + Application.current.meta.get("packageName") + "/files/" + "\n" + "Press Ok To Close The App", "Check Directory Error");
                    System.exit(0);//Will close the game
                }
                else if (!FileSystem.exists(Main.getDataPath() + "mods"))
                {
                    Application.current.window.alert("Try copying assets/mods from apk to " + " /storage/emulated/0/Android/data/" + Application.current.meta.get("packageName") + "/files/" + "\n" + "Press Ok To Close The App", "Check Directory Error");
                    System.exit(0);//Will close the game
                }
                else
                {
                    if (!FileSystem.exists(Main.getDataPath() + "corrupted-folder"))
	            FileSystem.createDirectory(Main.getDataPath() + "corrupted-folder");                   
                }
                #end

		ClientPrefs.loadDefaultKeys();
		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		fpsVar = new FPS(60, 0x00FF00);
		addChild(fpsVar);
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.showFPS;
		}

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
	}
}
