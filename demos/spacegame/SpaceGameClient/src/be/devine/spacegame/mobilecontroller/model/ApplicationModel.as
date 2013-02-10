package be.devine.spacegame.mobilecontroller.model
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	
	public class ApplicationModel extends EventDispatcher
	{
		
		private static var instance:ApplicationModel;
		
		public static function getInstance():ApplicationModel
		{
			if(instance == null)
			{
				instance = new ApplicationModel(new Enforcer());
			}
			return instance;
		}
		
		public function ApplicationModel(e:Enforcer)
		{
			if(e == null)
			{
				throw new Error("be.aboutme.iosgesturesclient.model.ApplicationModel is a Singleton and cannot be instantiated");
			}
			loadSettings();
		}
		
		private var appDb:File;
		private var appDbConnection:SQLConnection;
		
		private function loadSettings():void
		{
			appDb = File.applicationStorageDirectory.resolvePath("app.db");
			
			appDbConnection = new SQLConnection();
			appDbConnection.open(appDb);
			
			var sql:String = "CREATE TABLE IF NOT EXISTS settings (" +
				"id TEXT PRIMARY KEY," +
				"value TEXT" +
				")";
			var sqlStatement:SQLStatement = new SQLStatement();
			sqlStatement.sqlConnection = appDbConnection;
			sqlStatement.text = sql;
			sqlStatement.execute();
		}
		
		public function getSetting(id:String, defaultValue:String = ""):String
		{
			var sqlStatement:SQLStatement = new SQLStatement();
			sqlStatement.sqlConnection = appDbConnection;
			sqlStatement.text = "SELECT id, value FROM settings WHERE id = @ID";
			sqlStatement.parameters["@ID"] = id;
			sqlStatement.execute();
			var result:SQLResult = sqlStatement.getResult();
			if(result.data != null && result.data.length > 0)
			{
				return result.data[0].value;
			}
			else
			{
				saveSetting(id, defaultValue);
			}
			return defaultValue;
		}
		
		public function saveSetting(id:String, value:String, isUpdate:Boolean = false):void
		{
			var sqlStatement:SQLStatement = new SQLStatement();
			sqlStatement.sqlConnection = appDbConnection;
			if(isUpdate)
			{
				sqlStatement.text = "UPDATE settings SET value = @VALUE WHERE id = @ID";
			}
			else
			{
				sqlStatement.text = "INSERT INTO settings (id, value) VALUES (@ID, @VALUE)";
			}
			sqlStatement.parameters["@ID"] = id;
			sqlStatement.parameters["@VALUE"] = value;
			sqlStatement.execute();
		}
	}
}
internal class Enforcer{};