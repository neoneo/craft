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

	public String function concatenate(required Array strings) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public String function write(required String content) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public void function addFallback(required Extension extension) {
		if (arguments.extension.getName() != getName() && variables.fallbacks.find(arguments.extension) == 0) {
			variables.fallbacks.append(arguments.extension)
		}
	}

	public void function removeFallback(required Extension extension) {
		variables.fallbacks.delete(arguments.extension)
	}

	public Array function getFallbacks() {
		return variables.fallbacks
	}

}