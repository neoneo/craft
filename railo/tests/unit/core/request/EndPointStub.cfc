component extends="craft.core.request.EndPoint" accessors="true" {

	property String testPath;

	public String function path() {
		return getTestPath()
	}


}