interface {

	/**
	 * Returns the `Command` that corresponds to the idenfifier. The `CommandFactory` may return a cached `Command` instance.
	 */
	public Command function supply(required String identifier);

}