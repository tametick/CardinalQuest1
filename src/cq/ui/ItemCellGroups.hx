package cq.ui;

/**
 * a container for different itemcell groups.
 * should help merging similar itemcell classes.
 * 
 * @author joris
 */
import cq.CqInventoryDialog;
import cq.CqItem;

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
		name = name.toLowerCase();
		db.push(cells);
		db_names.push(name);
	}
	
	public function get(name:String):Array<CqInventoryCell>
	{
		name = name.toLowerCase();
		var i:Int = Lambda.indexOf(db_names, name);
		if (i < 0 || i > db.length) throw "there is no group by the name: "+name;
		return db[i];
	}
	public function has(name:String):Bool
	{
		name = name.toLowerCase();
		var b:Bool = Lambda.exists(db_names, function(ii) { return ii==name; });
		return b;
	}
	public function remove(name:String)
	{
		name = name.toLowerCase();
		var i:Int = Lambda.indexOf(db_names, name);
		db_names.splice(i, 1);
		db.splice(i, 1);
	}
	public function cellThatContainsItem(group:String,item:CqItem):CqInventoryCell 
	{
		if (has(group))
		{
			var items:Array<CqInventoryCell> = get(group);
			for ( i in 0...items.length)
			{
				var cellOB:CqInventoryItem = items[i].getCellObj();
				if (cellOB != null)
					if (cellOB.item == item) return items[i];
			}
			return null;
		}else {
			return null;
		}
	}
	public function AnyGroupCellThatContainsItem(item:CqItem):CqInventoryCell 
	{
		for (j in 0...db.length)
		{
			var items:Array<CqInventoryCell> = db[j];
			for ( i in 0...items.length)
			{
				var cellOB:CqInventoryItem = items[i].getCellObj();
				if (cellOB != null && cellOB.item == item)
					return items[i];
			}
		}
		return null;
	}
}