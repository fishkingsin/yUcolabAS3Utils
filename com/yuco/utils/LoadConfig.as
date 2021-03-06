﻿package com.yuco.utils
{
	import flash.events.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.display.*;
	import flash.ui.*;
	import 	flash.xml.*
	import flash.filesystem.*;
	import net.hires.debug.*;
	public class LoadConfig extends EventDispatcher
	{
		public var debugMode:Boolean;
		public var __stage:*;
		public var isMouseHide:Boolean;
		var menu:ConfigMenu;
		public var varName:Array = [];
		public var filename:String;
		var mXML:XML ;
		private var stats;
		private var logger;
		private var adddedMenu:Boolean=false;
		private var adddedLogger:Boolean=false;
		
		public function LoadConfig(_stage:*, fn:String = null)
		{
			filename = fn;
			__stage = _stage;
			var ldr:URLLoader = new URLLoader();
			//ldr.dataFormat = URLLoaderDataFormat.VARIABLES;
			ldr.addEventListener(IOErrorEvent.IO_ERROR, ldrError);
			ldr.addEventListener(Event.COMPLETE, ldrComplete,false, 0.0, true);
			if (filename!=null)
			{
				ldr.load(new URLRequest(filename));
			}
			else
			{
				ldr.load(new URLRequest("config.txt"));
			}
			isMouseHide = false;
			__stage.addEventListener(KeyboardEvent.KEY_DOWN,keyPressedDown);
			
		}
		private function keyPressedDown(event:KeyboardEvent):void
		{
			var key:uint = event.keyCode;

			Logger.debug("LoadConfig keyPressedDown "+key);
			switch (key)
			{
				case 112 ://f1
				adddedMenu = !adddedMenu;
				if(adddedMenu)
				{
					//menu call back
					__stage.addChild(menu);
					__stage.setChildIndex(menu,__stage.numChildren-1);
					__stage.focus = __stage;
					
					__stage.nativeWindow.activate();
					__stage.nativeWindow.orderToBack();
					__stage.nativeWindow.orderToFront();
					Mouse.show();
				}else
				{
					if(__stage.contains(menu))
					{
						__stage.removeChild(menu);
					}
				}
					break;
					case 8 :
					if (logger)
					{
						logger.clear();
					}
					break;
			}

		}
		private function ldrComplete(e:Event)
		{

			
			menu = new ConfigMenu();
			menu.addEventListener(ConfigMenu.CONFIRM,onConfirm);
			menu.addEventListener(ConfigMenu.APPLY,onApply);
			menu.addEventListener(ConfigMenu.SAVE,onSave);
			menu.addEventListener(ConfigMenu.CANCEL,onCancel);
			//do xml
			//Logger.debug("data: "+e.target.data);
			mXML =XML(e.target.data);
			for each (var xml:XML in mXML.children())
			{
				
				if(xml.children().length()<2)
				{
				
				varName.push(xml.name());
				menu.addVariable(xml.name(),xml);
				}
			}
			
			stats = new Stats();
			logger = new Logger(Logger.LEVEL_WARNING);
			if (stringToBoolean(menu.value("debugMode")))
			{
				adddedLogger = true;
				__stage.addChild(stats);
				__stage.addChild(logger);
				logger.x = 100;
			}
			//if (config.debugMode)
			{
				logger.x = mXML.LOGGER.X;//stats.width;
				logger.y = mXML.LOGGER.Y;//stats.width;
			}
			applyChange();
			//Logger.debug("mXML:XML");
			
			//do txt
			/*
			var urlVar:URLVariables = new URLVariables(e.target.data);
			if (urlVar.debugMode != null)
			{
				if (urlVar.debugMode.toLowerCase() == "true")
				{

					debugMode = true;

				}
				varName.push("debugMode");
				menu.addVariable("debugMode",urlVar.debugMode);
			}
			if (urlVar.alwaysOnTop != null)
			{
				if (urlVar.alwaysOnTop.toLowerCase() == "true")
				{
					__stage.nativeWindow.alwaysInFront = true;
				}
				varName.push("alwaysOnTop");
				menu.addVariable("alwaysOnTop",urlVar.alwaysOnTop.toLowerCase());
			}
			if (urlVar.FullScreen != null)
			{
				if (urlVar.FullScreen.toLowerCase() == "true")
				{
					__stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
					__stage.scaleMode = StageScaleMode.EXACT_FIT;
					__stage.align = StageAlign.TOP_LEFT;
					Logger.debug("Enter Full Screen");
				}
				varName.push("FullScreen");
				menu.addVariable("FullScreen",urlVar.FullScreen.toLowerCase());
			}
			if (urlVar.hideMouse != null)
			{
				if (urlVar.hideMouse.toLowerCase() == "true")
				{
					__stage.nativeWindow.activate();
					__stage.nativeWindow.orderToBack();
					__stage.nativeWindow.orderToFront();
					Mouse.hide();
					isMouseHide = true;
				}
				varName.push("hideMouse");
				menu.addVariable("hideMouse",urlVar.hideMouse.toLowerCase());
			}

			if (urlVar.startX != null)
			{
				__stage.nativeWindow.x = int(urlVar.startX);
				varName.push("startX");
				menu.addVariable("startX",urlVar.startX);
			}
			if (urlVar.startX != null)
			{
				__stage.nativeWindow.y = int(urlVar.startY);
				varName.push("startY");
				menu.addVariable("startY",urlVar.startY);
			}
			if (urlVar.startW != null)
			{
				__stage.nativeWindow.width = int(urlVar.startW);
				varName.push("startW");
				menu.addVariable("startW",urlVar.startW);
			}
			if (urlVar.startH != null)
			{
				__stage.nativeWindow.height = int(urlVar.startH);
				varName.push("startH");
				menu.addVariable("startH",urlVar.startH);
			}*/
			dispatchEvent( new Event( Event.COMPLETE, true ) );

		}
		private function onConfirm(e:Event)
		{
			applyChange();
			__stage.focus = __stage;
			adddedMenu = false;
		}
		private function onApply(e:Event)
		{
			applyChange();
			__stage.focus = __stage;
			adddedMenu = false;
		}
		private function onSave(e:Event)
		{
			applyChange();
			saveChange();
			__stage.focus = __stage;
			adddedMenu = false;
		}
		private function onCancel(e:Event)
		{
			__stage.focus = __stage;
			adddedMenu = false;
		}
		private function saveChange()
		{
			//var _xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<XML>\n</XML>";
			
			//var mXML:XML = XML(_xml);
			//var str:String="";
			
			for each(var val:* in varName)
			{
				for each(var xml:XML in mXML.children())
				{
					if(xml.name()==val)
					{
						xml.setChildren(XML(String(menu.value(val))));
						Logger.debug("alert : value change"+xml.name()+"->"+xml);
					}
					//Logger.debug("xml name "+xml.name());
//					Logger.debug("val name"+ val);
				}
				
				//Logger.debug("log save change : "+val+"="+menu.value(val)+"&");
				//str+=val+"="+menu.value(val)+"&";
			}
			Logger.debug(mXML);
			//str = str.slice(0,str.length-1);
			try{
				
				var file:File = new File(File.applicationDirectory.nativePath+"/"+filename);
				
				Logger.debug("filename "+file.nativePath);
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.WRITE);
				stream.writeUTFBytes(mXML);
				stream.close();
			}catch(error:Error){
				Logger.debug(error.message);
				Logger.debug(error);
			}
		}
		public static function stringToBoolean($string:String):Boolean
		{
    		return ($string.toLowerCase() == "true" || $string.toLowerCase() == "1");
		}
		private function applyChange()
		{
			debugMode = stringToBoolean(menu.value("debugMode"));
			if (stringToBoolean(menu.value("debugMode")))
			{
				__stage.addChild(stats);
				__stage.addChild(logger);
				adddedLogger = true;
			}
			else
			{
				if(adddedLogger)
				{
					adddedLogger = false;
					if(__stage.contains(stats))
					{
						__stage.removeChild(stats);
					}
					if(__stage.contains(logger))
					{
						__stage.removeChild(logger);
					}
				}
				
			}
			__stage.nativeWindow.alwaysInFront = stringToBoolean(menu.value("alwaysOnTop"));
			if (stringToBoolean(menu.value("FullScreen")))
			{
				__stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				__stage.scaleMode = StageScaleMode.EXACT_FIT;
				__stage.align = StageAlign.TOP;
			}
			else
			{
				
				__stage.displayState = StageDisplayState.NORMAL;
				__stage.scaleMode = StageScaleMode.SHOW_ALL;
				
			}
	
			if (stringToBoolean(menu.value("hideMouse")))
			{
				__stage.nativeWindow.activate();
				__stage.nativeWindow.orderToBack();
				__stage.nativeWindow.orderToFront();
				Mouse.hide();
				Logger.debug("Hide Mouse");
			}
			else
			{
				__stage.nativeWindow.activate();
				__stage.nativeWindow.orderToBack();
				__stage.nativeWindow.orderToFront();
				Mouse.show();
				Logger.debug("Show Mouse");

			}


			__stage.nativeWindow.x = menu.value("startX");
			__stage.nativeWindow.y = menu.value("startY");
			__stage.nativeWindow.width = menu.value("startW");
			__stage.nativeWindow.height = menu.value("startH");
		}

		private function ldrError(e:Event)
		{
			Logger.debug("Error loading config.txt");
		}
	}
}