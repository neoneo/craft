component {

	this.name = "craft tests";
	this.mappings["/tests"] = GetDirectoryFromPath(GetCurrentTemplatePath());
	this.invokeImplicitAccessor = true;
	processingdirective preservecase="true";

	public Boolean function onRequestStart() {
		if (!GetPageContext().getConfig().getFullNullSupport()) {
			abort showerror="Null support is disabled";
		}

		return true;
	}

	public void function onRequest(required String targetPage) {
		// The request does not have to be directed directly at /tests, but /tests must be in the url.
		var directory = GetDirectoryFromPath(ExpandPath(arguments.targetPage));
		// The directory should start with the directory of the /tests mapping.
		var mapping = directory.replace(this.mappings["/tests"], "/tests/")

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