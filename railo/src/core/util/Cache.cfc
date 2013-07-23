interface {

	public any function get(required String key);
	public void function put(required String key, required any object);
	public void function remove(required String key);
	public Boolean function has(required String key);
	public void function clear();
	public Array function keys();

}