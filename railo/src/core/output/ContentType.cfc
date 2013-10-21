/**
 * @abstract
 **/
component {

	public void function init() {
		variables.fallbacks = []
	}

	public String function getName() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public String function getMimeType() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public String function convert(required Array strings) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public String function write(required String content) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public void function addFallback(required ContentType contentType) {
		if (arguments.contentType.getName() != getName() && variables.fallbacks.find(arguments.contentType) == 0) {
			variables.fallbacks.append(arguments.contentType)
		}
	}

	public void function removeFallback(required ContentType contentType) {
		variables.fallbacks.delete(arguments.contentType)
	}

	public Array function getFallbacks() {
		return variables.fallbacks
	}

}