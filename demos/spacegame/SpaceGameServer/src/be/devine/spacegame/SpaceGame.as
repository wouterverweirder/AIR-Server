package be.devine.spacegame
{
	import be.aboutme.airserver.AIRServer;
	import be.aboutme.airserver.Client;
	import be.aboutme.airserver.endpoints.cocoonP2P.CocoonP2PEndPoint;
	import be.aboutme.airserver.endpoints.socket.SocketEndPoint;
	import be.aboutme.airserver.endpoints.socket.handlers.amf.AMFSocketClientHandlerFactory;
	import be.aboutme.airserver.endpoints.socket.handlers.websocket.WebSocketClientHandlerFactory;
	import be.aboutme.airserver.endpoints.udp.UDPEndPoint;
	import be.aboutme.airserver.events.MessageReceivedEvent;
	import be.aboutme.airserver.messages.Message;
	import be.aboutme.airserver.messages.serialization.JSONSerializer;
	import be.aboutme.airserver.messages.serialization.NativeObjectSerializer;
	import be.devine.spacegame.background.Auto;
	import be.devine.spacegame.background.BackgroundItem;
	import be.devine.spacegame.background.Ballon;
	import be.devine.spacegame.background.Bird;
	import be.devine.spacegame.background.MeteorHuis;
	import be.devine.spacegame.background.MeteorKoe;
	import be.devine.spacegame.controller.SpaceShipController;
	import be.devine.spacegame.controller.SpaceShipKeyboardController;
	import be.devine.spacegame.controller.SpaceShipSocketController;
	import be.happybanana.libraries.project.as3web.view.BasicSprite;
	
	import com.greensock.TweenLite;
	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import ws.tink.display.HitTest;
	
	public class SpaceGame extends BasicSprite
	{
		public static const STATE_WAITING_FOR_CONNECTIONS:String = "waitingForConnections";
		public static const STATE_WAITING_FOR_CALIBRATION:String = "waitingForCalibration";
		public static const STATE_COUNTING_DOWN:String = "countingDown";
		public static const STATE_PLAYING:String = "playing";
		public static const STATE_FINISHED:String = "finished";
		
		private static const POINT_ZERO:Point = new Point(0, 0);
		
		private var background:Bitmap;
		private var backgroundItem1:BackgroundItem;
		private var backgroundItem2:BackgroundItem;
		private var highlight:Bitmap;
		private var scoreLinksBackground:Bitmap;
		private var scoreRechtsBackground:Bitmap;
		private var scoreBoard:Bitmap;
		private var scoreCountdown:Bitmap;
		private var scoreCountdownField:TextField;
		
		private var spaceContainer:Sprite;
		private var spaceContainerMask:Shape;
		
		private var spaceShips:Array;
		private var spaceShipMap:Object;
		private var bullets:Array;
		
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
				stateChanged();
			}
		}

		private var _score1:uint;

		public function get score1():uint
		{
			return _score1;
		}

		public function set score1(value:uint):void
		{
			if(_score1 != value)
			{
				_score1 = value;
				displayScores();
			}
		}

		private var _score2:uint;

		public function get score2():uint
		{
			return _score2;
		}

		public function set score2(value:uint):void
		{
			if(_score2 != value)
			{
				_score2 = value;
				displayScores();
			}
		}
		
		private var _ipInfoVisible:Boolean;

		public function get ipInfoVisible():Boolean
		{
			return _ipInfoVisible;
		}

		public function set ipInfoVisible(value:Boolean):void
		{
			if(_ipInfoVisible != value)
			{
				_ipInfoVisible = value;
				ipInfoVisibleChanged();
			}
		}

		
		private var ipInfoButton:Sprite;
		private var ipInfoContainer:Sprite;
		
		private var countDownTimer:Timer;
		private var gameTimer:Timer;

		private var scoreField1:TextField;
		private var scoreField2:TextField;
		
		private var messageField1:TextField;
		private var messageField2:TextField;
		
		private var readyLabelField:TextField;
		private var readyCountDownField:TextField;
		
		private var p1:SpaceShip;
		private var p2:SpaceShip;
		
		private var p1Controller:SpaceShipController;
		private var p2Controller:SpaceShipController;
		
		private var ellipseA:uint = 420;
		private var ellipseB:uint = 325;
		
		private var server:AIRServer;
		
		public function SpaceGame()
		{
			super();
			
			server = new AIRServer();
			
			server.addEndPoint(new SocketEndPoint(1234, new AMFSocketClientHandlerFactory()));
			server.addEndPoint(new SocketEndPoint(1235, new WebSocketClientHandlerFactory()));
			server.addEndPoint(new UDPEndPoint(1236, new NativeObjectSerializer(), 5000));
			server.addEndPoint(new CocoonP2PEndPoint("be.devine.spacegame.SpaceGame", "225.225.225.1:30303"));
			
			server.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceivedHandler, false, 0, true);
			
			server.start();
			
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, exitingHandler, false, 0, true);
			
			background = new Library.Background();
			addChild(background);
			
			spaceContainer = new Sprite();
			spaceContainer.x = 88 + ellipseA;
			spaceContainer.y = 63 + ellipseB;
			addChild(spaceContainer);
			
			spaceContainerMask = new Shape();
			spaceContainerMask.x = spaceContainer.x;
			spaceContainerMask.y = spaceContainer.y;
			spaceContainerMask.graphics.beginFill(0xFF0000);
			spaceContainerMask.graphics.drawEllipse(-ellipseA, -ellipseB, 2 * ellipseA, 2 * ellipseB);
			spaceContainerMask.graphics.endFill();
			addChild(spaceContainerMask);
			
			spaceContainer.mask = spaceContainerMask;
			
			var itemList1:Vector.<Class> = new Vector.<Class>();
			itemList1.push(Auto);
			itemList1.push(MeteorHuis);
			itemList1.push(MeteorKoe);
			backgroundItem1 = new BackgroundItem(itemList1);
			spaceContainer.addChild(backgroundItem1);
			TweenLite.delayedCall(0.1, backgroundItem1.reset);
			
			var itemList2:Vector.<Class> = new Vector.<Class>();
			itemList2.push(Bird);
			itemList2.push(Ballon);
			backgroundItem2 = new BackgroundItem(itemList2);
			spaceContainer.addChild(backgroundItem2);
			TweenLite.delayedCall(10, backgroundItem2.reset);
			
			p1 = new SpaceShip("red");
			spaceContainer.addChild(p1);
			
			p2 = new SpaceShip("green");
			spaceContainer.addChild(p2);
			
			highlight = new Library.Highlight();
			addChild(highlight);
			
			scoreCountdown = new Library.ScoreCountdown();
			addChild(scoreCountdown);
			
			scoreLinksBackground = new Library.ScoreLinksBackground();
			addChild(scoreLinksBackground);
			
			scoreRechtsBackground = new Library.ScoreRechtsBackground();
			addChild(scoreRechtsBackground);
			
			scoreField1 = createTextField();
			scoreField1.defaultTextFormat = new TextFormat("Silom", 23, 0xFFFFFF);
			scoreField1.text = "00";
			addChild(scoreField1);
			
			scoreField2 = createTextField();
			scoreField2.defaultTextFormat = new TextFormat("Silom", 23, 0xFFFFFF);
			scoreField2.text = "00";
			addChild(scoreField2);
			
			messageField1 = createTextField();
			messageField1.defaultTextFormat = new TextFormat("Silom", 39, 0xFFFFFF);
			addChild(messageField1);
			
			messageField2 = createTextField();
			messageField2.defaultTextFormat = new TextFormat("Silom", 21, 0xFFFFFF);
			addChild(messageField2);
			
			readyLabelField = createTextField();
			readyLabelField.defaultTextFormat = new TextFormat("Silom", 65, 0xFFFFFF);
			addChild(readyLabelField);
			
			readyCountDownField = createTextField();
			readyCountDownField.defaultTextFormat = new TextFormat("Silom", 65, 0xFFFFFF);
			addChild(readyCountDownField);
			
			scoreBoard = new Library.ScoreBoard();
			addChild(scoreBoard);
			
			scoreCountdownField = createTextField();
			scoreCountdownField.defaultTextFormat = new TextFormat("GillSansStd", 10, 0xFFFFFF);
			scoreCountdownField.antiAliasType = AntiAliasType.ADVANCED;
			scoreCountdownField.text = "30";
			addChild(scoreCountdownField);
			
			ipInfoButton = new Sprite();
			ipInfoButton.buttonMode = true;
			ipInfoButton.alpha = 0;
			ipInfoButton.graphics.beginFill(0xFF0000);
			ipInfoButton.graphics.drawCircle(245, 100, 30);
			ipInfoButton.graphics.endFill();
			ipInfoButton.graphics.beginFill(0xFF0000);
			ipInfoButton.graphics.drawCircle(770, 100, 30);
			ipInfoButton.graphics.endFill();
			ipInfoButton.graphics.beginFill(0xFF0000);
			ipInfoButton.graphics.drawCircle(215, 656, 30);
			ipInfoButton.graphics.endFill();
			ipInfoButton.graphics.beginFill(0xFF0000);
			ipInfoButton.graphics.drawCircle(800, 656, 30);
			ipInfoButton.graphics.endFill();
			
			ipInfoButton.addEventListener(MouseEvent.CLICK, ipInfoButtonClickHandler, false, 0, true);
			addChild(ipInfoButton);
			
			p1.x = -200;
			p1.y = 0;
			p1.addEventListener(SpaceShip.SHOOT, shootHandler, false, 0, true);
			p1.addEventListener(SpaceShip.EXPLODED_CHANGED, explodedChangedHandler, false, 0, true);
			
			p2.x = 200;
			p2.y = 0;
			p2.addEventListener(SpaceShip.SHOOT, shootHandler, false, 0, true);
			p2.addEventListener(SpaceShip.EXPLODED_CHANGED, explodedChangedHandler, false, 0, true);
			
			spaceShips = [p1, p2];
			bullets = [];
			
			this.state = STATE_WAITING_FOR_CONNECTIONS;
			
			//test: keyboard controller
			//addSpaceShipController(new SpaceShipKeyboardController());
			//addSpaceShipController(new SpaceShipKeyboardController());
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true);
		}
		
		private function exitingHandler(event:Event):void
		{
			if(server != null)
			{
				server.stop();
			}
		}
		
		private function addedToStageHandler(event:Event):void
		{
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function removedFromStageHandler(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function ipInfoButtonClickHandler(event:Event):void
		{
			ipInfoVisible = !ipInfoVisible;
		}
		
		private function ipInfoVisibleChanged():void
		{
			if(ipInfoContainer != null && ipInfoContainer.parent != null)
			{
				ipInfoContainer.parent.removeChild(ipInfoContainer);
				ipInfoContainer = null;
			}
			if(_ipInfoVisible)
			{
				ipInfoContainer = new Sprite();
				
				ipInfoContainer.graphics.beginFill(0x000000);
				ipInfoContainer.graphics.drawRect(0, 0, 400, 300);
				ipInfoContainer.graphics.endFill();
				
				//ips opvragen en zo
				var ipInfoField:TextField = createTextField();
				ipInfoField.defaultTextFormat = new TextFormat("Silom", 24, 0xFFFFFF);
				ipInfoField.multiline = ipInfoField.wordWrap = true;
				ipInfoField.width = 380;
				ipInfoField.x = ipInfoField.y = 10;
				
				var ipInfo:String = "Server Settings:\n\n";
				var networkInterfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
				for each(var networkInterface:NetworkInterface in networkInterfaces)
				{
					if(networkInterface.active)
					{
						for each(var address:InterfaceAddress in networkInterface.addresses)
						{
							ipInfo += networkInterface.name + ": ";
							ipInfo += address.address;// + ":" + socketServerInputSource.socketServer.port;
							ipInfo += "\n";
						}
					}
				}
				ipInfoField.text = ipInfo;
				
				ipInfoContainer.addChild(ipInfoField);
				
				addChild(ipInfoContainer);
			}
		}
		
		private function messageReceivedHandler(event:MessageReceivedEvent):void
		{
			var client:Client = server.getClientById(event.message.senderId);
			if(client != null)
			{
				switch(event.message.command.toUpperCase())
				{
					case "JOIN_SPACESHOOTER":
						if(allowSocketController(client))
						{
							//preferred color?
							var preferredColor:String = null;
							if(event.message.data.color != null) preferredColor = event.message.data.color;
							addSpaceShipController(new SpaceShipSocketController(client), preferredColor);
						}
						break;
					case "PING":
						var m:Message = new Message();
						m.command = "PONG";
						client.sendMessage(m);
						break;
				}
			}
		}
		
		private function allowSocketController(client:Client):Boolean
		{
			if(p1Controller != null && p1Controller is SpaceShipSocketController && (p1Controller as SpaceShipSocketController).client == client) return false;
			if(p2Controller != null && p2Controller is SpaceShipSocketController && ((p2Controller as SpaceShipSocketController).client == client)) return false;
			return true;
		}
		
		private function addSpaceShipController(controller:SpaceShipController, preferredColor:String = null):void
		{
			var added:Boolean;
			//is there a preferred color
			var preferredController:SpaceShipController;
			if(preferredColor != null)
			{
				switch(preferredColor.toUpperCase())
				{
					case "RED":
						if(p1Controller == null)
						{
							p1Controller = controller;
							p1Controller.spaceShip = p1;
							p1Controller.playerName = "PLAYER 1";
							added = true;
						}
						break;
					case "GREEN":
						if(p2Controller == null)
						{
							p2Controller = controller;
							p2Controller.spaceShip = p2;
							p2Controller.playerName = "PLAYER 2";
							added = true;
						}
						break;
				}
			}
			//unable to take the preferred color
			if(!added)
			{
				if(p1Controller == null)
				{
					p1Controller = controller;
					p1Controller.spaceShip = p1;
					p1Controller.playerName = "PLAYER 1";
					added = true;
				}
				else if(p2Controller == null)
				{
					p2Controller = controller;
					p2Controller.spaceShip = p2;
					p2Controller.playerName = "PLAYER 2";
					added = true;
				}
			}
			if(added)
			{
				trace("added spaceship controller");
				controller.addEventListener(SpaceShipController.CALIBRATED, spaceShipControllerCalibratedHandler, false, 0, true);
				controller.addEventListener(SpaceShipController.DISCONNECTED, spaceShipControllerDisconnectedHandler, false, 0, true);
				if(p1Controller != null && p2Controller != null)
				{
					this.state = STATE_WAITING_FOR_CALIBRATION;
				}
				else
				{
					_state = STATE_WAITING_FOR_CONNECTIONS;
					stateChanged();
				}
			}
		}
		
		private function spaceShipControllerDisconnectedHandler(event:Event):void
		{
			var controller:SpaceShipController = event.currentTarget as SpaceShipController;
			controller.removeEventListener(SpaceShipController.CALIBRATED, spaceShipControllerCalibratedHandler);
			controller.removeEventListener(SpaceShipController.DISCONNECTED, spaceShipControllerDisconnectedHandler);
			if(controller.spaceShip != null)
			{
				controller.spaceShip.engine = 0;
				controller.spaceShip.steering = 0;
			}
			controller.destroy();
			if(controller == p1Controller) p1Controller = null;
			if(controller == p2Controller) p2Controller = null;
			state = STATE_WAITING_FOR_CONNECTIONS;
		}
		
		private function spaceShipControllerCalibratedHandler(event:Event):void
		{
			var controller:SpaceShipController = event.currentTarget as SpaceShipController;
			controller.calibrated = true;
			if(p1Controller != null && p2Controller != null && p1Controller.calibrated && p2Controller.calibrated && state == STATE_WAITING_FOR_CALIBRATION)
			{
				state = STATE_COUNTING_DOWN;
			}
		}
		
		private function createTextField():TextField
		{
			var t:TextField = new TextField();
			t.embedFonts = true;
			t.selectable = false;
			t.multiline = t.wordWrap = false;
			t.autoSize = TextFieldAutoSize.LEFT;
			return t;
		}
		
		private function countDownTimerHandler(event:TimerEvent = null):void
		{
			readyCountDownField.text = "" + (countDownTimer.repeatCount - countDownTimer.currentCount);
			readyCountDownField.x = Math.round(spaceContainer.x - (readyCountDownField.width * .5));
		}
		
		private function countDownCompleteHandler(event:TimerEvent):void
		{
			state = STATE_PLAYING;
		}
		
		private function gameTimerHandler(event:TimerEvent = null):void
		{
			//show it somewhere?
			setCountDownValue(gameTimer.repeatCount - gameTimer.currentCount);
		}
		
		private function setCountDownValue(value:int):void
		{
			scoreCountdownField.text = "" + value;
			scoreCountdownField.x = 510 - Math.round((scoreCountdownField.width) * .5);
		}
		
		private function gameCompleteHandler(event:TimerEvent):void
		{
			state = STATE_FINISHED;
		}
		
		private function stateChanged():void
		{
			//reset stuff
			messageField1.visible = false;
			messageField2.visible = false;
			readyLabelField.visible = false;
			readyCountDownField.visible = false;
			if(countDownTimer != null)
			{
				countDownTimer.removeEventListener(TimerEvent.TIMER, countDownTimerHandler);
				countDownTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, countDownCompleteHandler);
				countDownTimer = null;
			}
			if(gameTimer != null)
			{
				gameTimer.removeEventListener(TimerEvent.TIMER, gameTimerHandler);
				gameTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, gameCompleteHandler);
				gameTimer = null;
			}
			switch(_state)
			{
				case STATE_WAITING_FOR_CONNECTIONS:
					score1 = score2 = 0;
					setCountDownValue(30);
					messageField1.text = "WAITING FOR PLAYERS";
					messageField2.text = "Please connect with a mobile controller";
					messageField1.visible = true;
					messageField2.visible = true;
					setControllerStates(SpaceShipController.STATE_WAITING_FOR_CONNECTIONS);
					break;
				case STATE_WAITING_FOR_CALIBRATION:
					score1 = score2 = 0;
					setCountDownValue(30);
					messageField1.text = "WAITING FOR CALIBRATION";
					messageField2.text = "Please hold the controllers horizontally";
					messageField1.visible = true;
					messageField2.visible = true;
					if(p1Controller != null) p1Controller.calibrated = false;
					if(p2Controller != null) p2Controller.calibrated = false;
					setControllerStates(SpaceShipController.STATE_CALIBRATE);
					break;
				case STATE_COUNTING_DOWN:
					readyLabelField.visible = true;
					readyCountDownField.visible = true;
					readyLabelField.text = "READY?";
					readyCountDownField.text = "";
					score1 = score2 = 0;
					setCountDownValue(30);
					setControllerStates(SpaceShipController.STATE_COUNTING_DOWN);
					countDownTimer = new Timer(1000, 3);
					countDownTimer.addEventListener(TimerEvent.TIMER, countDownTimerHandler, false, 0, true);
					countDownTimer.addEventListener(TimerEvent.TIMER_COMPLETE, countDownCompleteHandler, false, 0, true);
					countDownTimer.start();
					countDownTimerHandler();
					break;
				case STATE_PLAYING:
					score1 = score2 = 0;
					setCountDownValue(30);
					setControllerStates(SpaceShipController.STATE_PLAYING);
					gameTimer = new Timer(1000, 30);
					gameTimer.addEventListener(TimerEvent.TIMER, gameTimerHandler, false, 0, true);
					gameTimer.addEventListener(TimerEvent.TIMER_COMPLETE, gameCompleteHandler, false, 0, true);
					gameTimer.start();
					gameTimerHandler();
					break;
				case STATE_FINISHED:
					//winner / loser
					if(score1 > score2)
					{
						if(p1Controller != null) p1Controller.isWinner = true;
						if(p2Controller != null) p2Controller.isWinner = false;
						messageField1.text = p1.color.toUpperCase() + " RULES THE GALAXY";
					}
					else if(score2 > score1)
					{
						if(p1Controller != null) p1Controller.isWinner = false;
						if(p2Controller != null) p2Controller.isWinner = true;
						messageField1.text = p2.color.toUpperCase() + " RULES THE GALAXY";
					}
					else
					{
						if(p1Controller != null) p1Controller.isWinner = false;
						if(p2Controller != null) p2Controller.isWinner = false;
						messageField1.text = "THERE IS A BALANCE IN THE FORCE";
					}
					messageField2.text = "Play again?";
					messageField1.visible = messageField2.visible = true;
					setControllerFinishedStates();
					break;
			}
			messageField1.x = Math.round(spaceContainer.x - (messageField1.width * .5));
			messageField2.x = Math.round(spaceContainer.x - (messageField2.width * .5));
			readyLabelField.x = Math.round(spaceContainer.x - (readyLabelField.width * .5));
			readyCountDownField.x = Math.round(spaceContainer.x - (readyCountDownField.width * .5));
		}
		
		private function setControllerFinishedStates():void
		{
			if(p1Controller != null)
			{
				p1Controller.state = (p1Controller.isWinner) ? SpaceShipController.STATE_WIN : SpaceShipController.STATE_LOSE;
				p1Controller.destroy();
			}
			
			if(p2Controller != null)
			{
				p2Controller.state = (p2Controller.isWinner) ? SpaceShipController.STATE_WIN : SpaceShipController.STATE_LOSE;
				p2Controller.destroy();
			}
			
			p1Controller = null;
			p2Controller = null;
		}
		
		private function setControllerStates(targetState:String):void
		{
			if(p1Controller != null) p1Controller.state = targetState;
			if(p2Controller != null) p2Controller.state = targetState;
		}
		
		private function displayScores():void
		{
			var t:String = "" + score1;
			while(t.length < 2)
			{
				t = "0" + t;
			}
			scoreField1.text = t;
			t = "" + score2;
			while(t.length < 2)
			{
				t = "0" + t;
			}
			scoreField2.text = t;
		}		
		
		private function enterFrameHandler(event:Event):void
		{
			//trace(getTimer());
			var alpha:Number;
			var spaceShip:SpaceShip;
			for each(spaceShip in spaceShips)
			{
				spaceShip.calculateNewCoords();
				
				//check boundaries of spaceship
				alpha = Math.atan2(-spaceShip.calculatedY, spaceShip.calculatedX);
				
				var positiveX:uint = Math.abs(spaceShip.calculatedX);
				var positiveY:uint = Math.abs(spaceShip.calculatedY);
				
				var maxX:Number = ellipseA * Math.abs(Math.cos(alpha));
				var maxY:Number = ellipseB * Math.abs(Math.sin(alpha));
				
				var distance:uint = Point.distance(POINT_ZERO, new Point(spaceShip.calculatedX, spaceShip.calculatedY));
				var maxDistance:uint = Point.distance(POINT_ZERO, new Point(maxX, maxY));
				
				var spaceShipRotation:Number = spaceShip.calculatedRotation * SpaceShip.RAD;
				
				if(distance > maxDistance)
				{
					//stick against the viewport
					spaceShip.calculatedX = maxDistance * Math.cos(-alpha);
					spaceShip.calculatedY = maxDistance * Math.sin(-alpha);
				}
				
				spaceShip.applyNewCoords();
			}
			
			var index:int;
			var bulletsToRemove:Array = [];
			var bullet:Bullet;
			for each(bullet in bullets)
			{
				bullet.update();
				for each(spaceShip in spaceShips)
				{
					if(spaceShip != bullet.spaceShip && HitTest.complexHitTestObject(spaceShip, bullet))
					{
						spaceShip.explode();
						bulletsToRemove.push(bullet);
						
						if(_state == STATE_PLAYING)
						{
							if(bullet.spaceShip.color == "red")
							{
								score1++;
							}
							else
							{
								score2++;
							}
						}
					}
				}
				if(bullet.x < -ellipseA || bullet.x > ellipseA || bullet.y < -ellipseB || bullet.y > ellipseB)
				{
					bulletsToRemove.push(bullet);
				}
			}
			for each(bullet in bulletsToRemove)
			{
				if(bullet.parent != null)
				{
					bullet.parent.removeChild(bullet);
				}
				index = bullets.indexOf(bullet);
				if(index > -1)
				{
					bullets.splice(index, 1);
				}
			}
		}
		
		private function shootHandler(event:Event):void
		{
			var spaceShip:SpaceShip = event.currentTarget as SpaceShip;
			var bullet:Bullet = new Bullet(spaceShip);
			bullet.x = spaceShip.x;
			bullet.y = spaceShip.y;
			bullet.rotation = spaceShip.rotation;
			bullet.speed = spaceShip.speed + 10;
			bullets.push(bullet);
			spaceShip.parent.addChildAt(bullet, spaceShip.parent.getChildIndex(spaceShip) - 1);
		}
		
		private function explodedChangedHandler(event:Event):void
		{
			var spaceShip:SpaceShip = event.currentTarget as SpaceShip;
			spaceShip.engine = 0;
			spaceShip.steering = 0;
			if(!spaceShip.exploded)
			{
				spaceShip.x = 0;
				spaceShip.y = 0;
			}
		}
		
		override public function layout():void
		{
			background.x = 0;
			background.y = 0;
			
			backgroundItem1.setSize(100 + ellipseA*2, 100 + ellipseB*2);
			backgroundItem2.setSize(100 + ellipseA*2, 100 + ellipseB*2);
			
			highlight.x = 86;
			highlight.y = 53;
			scoreCountdown.x = 473;
			scoreCountdown.y = 118;
			scoreCountdownField.x = 510 - Math.round((scoreCountdownField.width) * .5);
			scoreCountdownField.y = 133;
			scoreLinksBackground.x = 426;
			scoreLinksBackground.y = 74;
			scoreRechtsBackground.x = 510;
			scoreRechtsBackground.y = 74;
			scoreField1.x = 450 - 4;
			scoreField1.y = 127 - 7;
			scoreField2.x = 548 - 4;
			scoreField2.y = 127 - 7;
			scoreBoard.x = 192;
			scoreBoard.y = 0;
			
			messageField1.y = 280;
			messageField2.y = 330;
			readyLabelField.y = 267;
			readyCountDownField.y = 340;
		}
	}
}