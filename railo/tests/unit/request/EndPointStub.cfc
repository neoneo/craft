component extends="craft.request.EndPoint" accessors="true" {

	property String testPath;

	public String function getPath() {
		return getTestPath();
	}

}