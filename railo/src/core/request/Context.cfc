import craft.core.output.Renderer;

/**
 * Context
 *
 * @transient
 **/
component accessors="true" {

	property PathSegment pathSegment setter="false";
	property Struct parameters setter="false";
	property ContentType contentType setter="false";
	property String requestMethod setter="false";

	public void function init(required EndPoint endPoint) {

		variables.endPoint = arguments.endPoint

		var info = arguments.endPoint.parsePath()
		variables.pathSegment = info.pathSegment
		variables.contentType = info.contentType
		variables.requestMethod = arguments.endPoint.getRequestMethod()
		variables.parameters = arguments.endPoint.getRequestParameters()

	}

	public String function createUrl(required String path, Struct parameters, String extensionName) {
		return variables.endPoint.createUrl(argumentCollection = arguments.toStruct())
	}

}