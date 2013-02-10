package
{
	import be.aboutme.nativeExtensions.udp.UDPSocket;
	import be.devine.spacegame.mobilecontroller.model.ApplicationModel;
	import be.devine.spacegame.mobilecontroller.view.CalibrationRadar;
	import be.devine.spacegame.mobilecontroller.view.ConnectionPanel;
	import be.devine.spacegame.mobilecontroller.view.SpaceGameButton;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Bitmap;
	import flash.display.NativeWindow;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.errors.IOError;
	import flash.events.AccelerometerEvent;
	import flash.events.DatagramSocketDataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TransformGestureEvent;
	import flash.sensors.Accelerometer;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	[SWF(backgroundColor="#000000")]
	public class SpaceGameClient extends Sprite
	{
		
		public static const STATE_CONNECT:String = "connect";
		public static const STATE_CONNECTING:String = "connecting";
		public static const STATE_PLAY:String = "play";
		public static const STATE_CALIBRATE:String = "calibrate";
		public static const STATE_PLAYING:String = "playing";
		public static const STATE_FINISHED:String = "finished";
		
		private var background:Bitmap;
		private var connectionPanel:ConnectionPanel;
		
		//PLAY
		private var playButton:SpaceGameButton;
		
		//CALIBRATE
		private var calibrateBackground:Bitmap;
		private var calibrationRadar:CalibrationRadar;
		
		//PLAYING
		private var playingBackground:Bitmap;
		private var red:Bitmap;
		private var green:Bitmap;
		private var mySpaceShip:Bitmap;
		private var playingNameField:TextField;
		
		//FINISHED WINNER
		private var winner:Bitmap;
		
		//FINISHED LOSER
		private var loser:Bitmap;
		
		//REPLAY
		private var replayButton:SpaceGameButton;
		
		
		private var applicationModel:ApplicationModel;
		
		private var udp:UDPSocket;
		private var serverIP:String;
		private var serverPort:int;
		
		private var lastPong:uint;
		private var pingTimer:Timer;
		private var checkConnectionTimer:Timer;
		
		private var acceleroMeter:Accelerometer;
		private var seperator:String = "|";
		
		private var f:FontContainer;
		
		private var isWinner:Boolean;
		private var playerName:String;
		private var myColor:String;
		
		private var _state:String;
		
		public function get state():String
		{
			return _state;
		}
		
		public function set state(value:String):void
		{
			if(_state != value)
			{
				_state = value;
				displayState();
			}
		}
		
		public function SpaceGameClient()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			if(Capabilities.cpuArchitecture == "ARM")
			{
				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, nativeApplicationActivateHandler);
			}
			
			if(NativeWindow.isSupported)
			{
				stage.nativeWindow.visible = true;
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
			
			applicationModel = ApplicationModel.getInstance();
			
			background = new Library.Background();
			addChild(background);
			
			connectionPanel = new ConnectionPanel();
			connectionPanel.addEventListener(Event.CONNECT, connectHandler);
			connectionPanel.visible = false;
			addChild(connectionPanel);
			
			playButton = new SpaceGameButton();
			playButton.label = "PLAY";
			playButton.visible = false;
			playButton.addEventListener(MouseEvent.CLICK, playClickHandler, false, 0, true);
			addChild(playButton);
			
			calibrateBackground = new Library.CalibrateBackground();
			calibrateBackground.visible = false;
			addChild(calibrateBackground);
			
			calibrationRadar = new CalibrationRadar();
			calibrationRadar.addEventListener(CalibrationRadar.CALIBRATED, calibratedHandler, false, 0, true);
			addChild(calibrationRadar);
			
			playingBackground = new Library.PlayingBackground();
			playingBackground.visible = false;
			addChild(playingBackground);
			
			red = new Library.Red();
			red.visible = false;
			addChild(red);
			
			green = new Library.Green();
			green.visible = false;
			addChild(green);
			
			playingNameField = new TextField();
			playingNameField.embedFonts = true;
			playingNameField.selectable = false;
			playingNameField.defaultTextFormat = new TextFormat("Silom", 30, 0xFFFFFF, null, null, null, null, null, "center");
			playingNameField.visible = false;
			addChild(playingNameField);
			
			winner = new Library.FinishedWin();
			winner.visible = false;
			addChild(winner);
			
			loser = new Library.FinishedLose();
			loser.visible = false;
			addChild(loser);
			
			replayButton = new SpaceGameButton();
			replayButton.label = "PLAY AGAIN";
			replayButton.visible = false;
			replayButton.addEventListener(MouseEvent.CLICK, playClickHandler, false, 0, true);
			addChild(replayButton);
			
			state = STATE_CONNECT;
			
			stage.addEventListener(Event.RESIZE, resizeHandler);
			resizeHandler();
		}
		
		private function nativeApplicationActivateHandler(event:Event):void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
		}
		
		private function playClickHandler(event:Event):void
		{
			joinGame();
		}
		
		private function deactivateHandler(event:Event):void
		{
			state = STATE_CONNECT;
		}
		
		private function displayState():void
		{
			calibrationRadar.player = playerName;
			//visibility booleans
			var connectionPanelVisible:Boolean = false;
			var playButtonVisible:Boolean = false;
			var calibratBackgroundVisible:Boolean = false;
			var calibrationRadarVisible:Boolean = false;
			var playingBackgroundVisible:Boolean = false;
			var playingNameFieldVisible:Boolean = false;
			var mySpaceShipVisible:Boolean = false;
			var winnerVisible:Boolean = false;
			var loserVisible:Boolean = false;
			var replayVisible:Boolean = false;
			switch(_state)
			{
				case STATE_CONNECT:
					clearSocket();
					connectionPanelVisible = true;
					break;
				case STATE_CONNECTING:
					break;
				case STATE_PLAY:
					playButtonVisible = true;
					break;
				case STATE_CALIBRATE:
					if(!Accelerometer.isSupported)
					{
						testCalibrationWithMouse();
					}
					calibratBackgroundVisible = true;
					calibrationRadarVisible = true;
					break;
				case STATE_PLAYING:
					playingBackgroundVisible = true;
					playingNameFieldVisible = true;
					mySpaceShipVisible = true;
					break;
				case STATE_FINISHED:
					if(isWinner) winnerVisible = true;
					else loserVisible = true;
					replayVisible = true;
					break;
			}
			playButton.visible = playButtonVisible;
			connectionPanel.visible = connectionPanelVisible;
			calibrateBackground.visible = calibratBackgroundVisible;
			calibrationRadar.visible = calibrationRadarVisible;
			playingBackground.visible = playingBackgroundVisible;
			playingNameField.visible = playingNameFieldVisible;
			red.visible = false;
			green.visible = false;
			if(mySpaceShip != null) mySpaceShip.visible = mySpaceShipVisible;
			winner.visible = winnerVisible;
			loser.visible = loserVisible;
			replayButton.visible = replayVisible;
			resizeHandler();
		}
		
		private function testCalibrationWithMouse():void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, testCalibrationMouseMoveHandler);
		}
		
		private function testCalibrationMouseMoveHandler(event:MouseEvent):void
		{
			calibrationRadar.targetAngle = Math.atan2((stage.mouseY - calibrationRadar.y), (stage.mouseX - calibrationRadar.x)) * 180 / Math.PI + 90;
		}
		
		private function calibratedHandler(event:Event):void
		{
			if(udp != null)
			{
				writeObject({command: "CALIBRATED"});
			}
		}
		
		private function connectHandler(event:Event):void
		{
			state = STATE_CONNECTING;
			
			serverIP = applicationModel.getSetting("hostname");
			serverPort = int(applicationModel.getSetting("port"));
			
			clearSocket();
			
			udp = new UDPSocket();
			udp.addEventListener(DatagramSocketDataEvent.DATA, socketDataHandler, false);
			udp.bind(1234);
			udp.receive();
			
			//ping pong timer
			pingTimer = new Timer(1000);
			pingTimer.addEventListener(TimerEvent.TIMER, timerHandler, false, 0, true);
			pingTimer.start();
			timerHandler();
			
			//connection timer
			checkConnectionTimer = new Timer(1000);
			checkConnectionTimer.addEventListener(TimerEvent.TIMER, checkConnectionTimerHandler, false, 0, true);
			checkConnectionTimer.start();
		}
		
		protected function checkConnectionTimerHandler(event:TimerEvent):void
		{
			if(getTimer() - lastPong > 5000)
			{
				state = STATE_CONNECT;
				clearSocket();
				if(acceleroMeter != null)
				{
					acceleroMeter.removeEventListener(AccelerometerEvent.UPDATE, acceleroMeterUpdateHandler);
				}
			}
		}
		
		protected function timerHandler(event:TimerEvent = null):void
		{
			writeObject({command: "PING", data: ""});
		}
		
		private function connected():void
		{
			state = STATE_PLAY;
			
			if(Accelerometer.isSupported)
			{
				acceleroMeter = new Accelerometer();
				acceleroMeter.addEventListener(AccelerometerEvent.UPDATE, acceleroMeterUpdateHandler);
			}
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.CLICK, mouseDownHandler);
			stage.addEventListener(TransformGestureEvent.GESTURE_SWIPE, mouseDownHandler);
		}
		
		private function clearSocket():void
		{
			lastPong = 0;
			if(udp != null)
			{
				try
				{
					udp.close();
				}
				catch(error:IOError)
				{
				}
				udp.removeEventListener(DatagramSocketDataEvent.DATA, socketDataHandler);
				udp = null;
			}
			if(pingTimer != null)
			{
				pingTimer.removeEventListener(TimerEvent.TIMER, timerHandler);
				pingTimer = null;
			}
			if(checkConnectionTimer != null)
			{
				checkConnectionTimer.removeEventListener(TimerEvent.TIMER, checkConnectionTimerHandler);
				checkConnectionTimer = null;
			}
		}
		
		private function acceleroMeterUpdateHandler(event:AccelerometerEvent):void
		{
			switch(_state)
			{
				case STATE_CALIBRATE:
					calibrationRadar.targetAngle = event.accelerationX * 180;
					//ook doorgeven aan socket
				case STATE_PLAYING:
					if(udp != null)
					{
						writeObject({command: "ACCELEROMETER", data: {x: event.accelerationX, y: event.accelerationY, z: event.accelerationZ}});
					}
					break;
			}
		}
		
		private function writeObject(o:Object):void
		{
			var b:ByteArray = new ByteArray();
			b.writeObject({command: "PORT", data: 1234});
			b.writeObject(o);
			udp.send(b, serverIP, serverPort);
		}
		
		private function joinGame():void
		{
			if(udp != null)
			{
				writeObject({command: "JOIN_SPACESHOOTER", data: {color: myColor}});
			}
		}
		
		private function mouseDownHandler(event:MouseEvent):void
		{
			if(udp != null)
			{
				writeObject({command: "SHOOT"});
			}
		}
		
		private function socketDataHandler(event:DatagramSocketDataEvent):void
		{
			//parse it
			while(event.data.bytesAvailable > 0)
			{
				try
				{
					var o:Object = event.data.readObject();
					if(o.hasOwnProperty("data") && !(o.data is String))
					{
						if(o.data.player != null)
						{
							playerName = o.data.player;
							playingNameField.text = playerName;
						}
						if(o.data.color != null)
						{
							myColor = o.data.color;
							switch(o.data.color)
							{
								case "red":
									mySpaceShip = red;
									break;
								case "green":
									mySpaceShip = green;
									break;
							}
						}
					}
					if(o.hasOwnProperty("command"))
					{
						switch(o.command)
						{
							case "PLAY":
								state = STATE_PLAY;
								break;
							case "WAITING_FOR_CONNECTIONS":
							case "CALIBRATE":
								state = STATE_CALIBRATE;
								break;
							case "COUNTING_DOWN":
							case "PLAYING":
								state = STATE_PLAYING;
								break;
							case "WIN":
								isWinner = true;
								state = STATE_FINISHED;
								break;
							case "LOSE":
								isWinner = false;
								state = STATE_FINISHED;
								break;
							case "PONG":
								lastPong = getTimer();
								if(state == STATE_CONNECTING)
								{
									connected();
								}
								break;
						}
					}
				}
				catch(e:Error)
				{
				}
			}
		}
		
		private function resizeHandler(event:Event = null):void
		{
			background.x = Math.round((stage.stageWidth - background.width) * .5);
			background.y = Math.round((stage.stageHeight - background.height) * .5);
			
			connectionPanel.x = (stage.stageWidth - connectionPanel.width) * .5;
			connectionPanel.y = (stage.stageHeight - connectionPanel.height) * .5;
			
			playButton.x = background.x + Math.round((background.width - playButton.width) * .5);
			playButton.y = background.y + Math.round((background.height - playButton.height) * .5);
			
			calibrateBackground.x = background.x + 191;
			calibrateBackground.y = background.y + 221;
			
			calibrationRadar.x = background.x + Math.round(background.width * .5) + 4;
			calibrationRadar.y = background.y + Math.round(background.height * .5) + 85;
			
			playingBackground.x = background.x + Math.round((background.width - playingBackground.width) * .5);
			playingBackground.y = background.y + Math.round((background.height - playingBackground.height) * .5);
			
			playingNameField.x = background.x;
			playingNameField.y = playingBackground.y + playingBackground.height + 20;
			playingNameField.width = background.width;
			
			red.x = green.x = playingBackground.x + 100;
			red.y = green.y = playingBackground.y + 180;
			
			winner.x = background.x + Math.round((background.width - winner.width) * .5);
			winner.y = background.y + 185;
			
			loser.x = background.x + Math.round((background.width - loser.width) * .5);
			loser.y = winner.y;
			
			replayButton.x = background.x + Math.round((background.width - replayButton.width) * .5);
			replayButton.y = winner.y + winner.height + 60;
		}
	}
}