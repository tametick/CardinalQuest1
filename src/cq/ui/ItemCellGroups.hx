package cq.ui;

/**
 * a container for different itemcell groups.
 * should help merging similar itemcell classes.
 * 
 * @author joris
 */
import cq.CqInventoryDialog

class ItemCellGroups 
{
	var db:Dynamic;
	public function new() 
	{
		db = { };
	}
	public function add(name:String, cells:Array<CqInventoryCell>)
	{
		Reflect.setField(db, name, cells);
	}
	public function get(name:String):Array<CqInventoryCell>
	{
		return cast( Reflect.field(db, name),Array<CqInventoryCell>);
	}
	public function has(name:String):Bool
	{
		return Reflect.hasField(db, name);
	}
	public function remove(name:String)
	{
		Reflect.deleteField(db, name);
	}
	
}