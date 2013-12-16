/**
 * The `Context` is passed to `Component`s to provide access to items and parameters pertaining to the request, as well
 * as some convenience methods.
 *
 * @transient
 **/
component {

	public void function init(required EndPoint endPoint) {

		variables._endPoint = arguments.endPoint

		var info = arguments.endPoint.parsePath()
		variables._pathSegment = info.pathSegment
		variables._contentType = info.contentType
		variables._requestMethod = arguments.endPoint.requestMethod()
		variables._parameters = arguments.endPoint.requestParameters()

	}

	public PathSegment function pathSegment() {
		return variables._pathSegment
	}

	public Struct function parameters() {
		return variables._parameters
	}

	public ContentType function contentType() {
		return variables._contentType
	}

	public String function requestMethod() {
		return variables._requestMethod
	}

	public String function createUrl(required String path, Struct parameters, String extensionName) {
		return variables._endPoint.createUrl(argumentCollection: ArrayToStruct(arguments))
	}

}