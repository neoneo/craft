import craft.request.*;

component extends="Facade" {

	private EndPoint function createEndPoint() {
		 return new EndPointStub();
	}

	public EndPoint function endPoint() {
		return variables._endPoint;
	}

	public void function handleRequest() {
		super.handleRequest()
		// Reset the content type for output in HTML.
		content type="text/html" reset="false";
	}

}