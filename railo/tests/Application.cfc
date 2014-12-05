component {

	this.name = "craft tests";
	this.mappings["/tests"] = GetDirectoryFromPath(GetCurrentTemplatePath());
	this.invokeImplicitAccessor = true;
	processingdirective preservecase="true";

	public Boolean function onRequestStart() {
		var nullSupport = {x: NullValue()}.keyExists("x")

		if (!nullSupport) {
			abort showerror="Null support is disabled";
		}

		return nullSupport;
	}

	public void function onRequest(required String targetPage) {
		var mapping = GetDirectoryFromPath(arguments.targetPage);
		var testbox = new testbox.system.TestBox(directory = {
			mapping: mapping,
			recurse: false,
			filter: function (path) {
				var class = mapping & "." & arguments.path.listLast("/").listFirst(".")
				var metadata = GetComponentMetadata(class)
				return !(metadata.skip ?: false) && this.extends(metadata, "testbox.system.BaseSpec");
			}
		})

		WriteOutput(testbox.run())
	}

	// TODO: when all tests use TestBox, remove this function.
	public Boolean function extends(required Struct metadata, required String className) {

		var success = arguments.metadata.name == arguments.className

		if (!success && arguments.metadata.keyExists("extends")) {
			success = this.extends(arguments.metadata.extends, arguments.className)
		}

		return success;
	}

}