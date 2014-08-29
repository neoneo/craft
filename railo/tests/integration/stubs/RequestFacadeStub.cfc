import craft.request.*;

component extends="Facade" {

	private EndPoint function createEndPoint() {
		 return new EndPointStub();
	}

	public EndPoint function getEndPoint() {
		return this.endPoint;
	}

}