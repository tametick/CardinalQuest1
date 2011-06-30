package cq.ui;

/**
 * a container for different itemcell groups.
 * should help merging similar itemcell classes.
 * 
 * @author joris
 */
import cq.CqInventoryDialog;

class ItemCellGroups 
{
	var db:Array<Array<CqInventoryCell>>;
	var db_names:Array<String>;
	public function new() 
	{
		db = [];
		db_names = [];
	}
	public function add(name:String, cells:Array<CqInventoryCell>)
	{
		db.push(cells);
		db_names.push(name);
	}
	
	public function get(name:String):Array<CqInventoryCell>
	{
		var i:Int = Lambda.indexOf(db_names, name);
		if (i < 0 || i > db.length) throw "there is no group by the name: "+name;
		return db[i];
	}
	public function has(name:String):Bool
	{
		var b:Bool = Lambda.exists(db_names, function(ii) { return ii==name; });
		return b;
	}
	public function remove(name:String)
	{
		var i:Int = Lambda.indexOf(db_names, name);
		db_names.splice(i, 1);
		db.splice(i, 1);
	}
}