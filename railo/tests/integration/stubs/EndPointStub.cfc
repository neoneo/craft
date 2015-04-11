import craft.request.EndPoint;

component extends="Endpoint" accessors = true {

	property String testPath;
	property Struct testParameters;
	property String testRequestMethod;

	public String function getPath() {
		return getTestPath();
	}

	public Struct function getRequestParameters() {
		return getTestParameters() ?: {};
	}

	public String function getRequestMethod() {
		return getTestRequestMethod();
	}

}