component {

	this.name = "craft tests";
	this.mappings["/tests"] = GetDirectoryFromPath(GetCurrentTemplatePath());
	this.invokeImplicitAccessor = true;

	public Boolean function onRequestStart() {
		var nullSupport = {x: NullValue()}.keyExists("x")

		if (!nullSupport) {
			abort showerror="Null support is disabled";
		}

		return nullSupport;
	}

}