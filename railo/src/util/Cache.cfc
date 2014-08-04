interface {

	public Any function get(required String key);
	public void function put(required String key, required Any value);
	public void function remove(required String key);
	public Boolean function has(required String key);
	public void function clear();
	public String[] function keys();

}