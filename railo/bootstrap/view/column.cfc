import craft.output.View;

component extends="View" {

	private void function configure(required String[] spans, String[] offsets = [], String[] pulls = []) {
		this.classList = this.classes("col", arguments.spans)
			.append(this.classes("offset", arguments.offsets))
			.append(this.classes("pull", arguments.pulls))
			.toList(" ")
	}

	public Any function render(required Any model) {

		arguments.model.classList = this.classList

		return this.templateRenderer.render("bootstrap/view/column", arguments.model)
	}

	private String[] function classes(required String prefix, required String[] values) {

		var infixes = ["-xs-", "-sm-", "-md-", "-lg-"]
		var prefix = arguments.prefix

		return arguments.values.reduce(function (classes, value, index) {
			if (IsNumeric(arguments.value)) {
				// Create local references for variables that may be changed.
				var prefix = prefix
				var value = arguments.value
				if (prefix == "pull" && value < 0) {
					prefix = "push"
					value = Abs(value)
				}

				return arguments.classes.append(prefix & infixes[arguments.index] & arguments.value);
			} else {
				return arguments.classes;
			}
		}, []);
	}

}