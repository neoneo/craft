component extends="craft.core.request.EndPoint" accessors="true" {

	property String testPath;
	property Struct testParameters;
	property String testRequestMethod;

	public String function path() {
		return getTestPath()
	}

	public Struct function requestParameters() {
		return getTestParameters() ?: {}
	}

	public String function requestMethod() {
		return getTestRequestMethod()
	}

}