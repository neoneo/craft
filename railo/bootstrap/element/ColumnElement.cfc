import craft.markup.library.CompositeElement;

component extends="CompositeElement" accessors="true" tag="column" {

	property String offset default="";
	property String pull default="";
	property String span required="true";

	this.ranges = {
		offset: {from: 0, to: 12},
		pull: {from: -12, to: 12},
		span: {from: 1, to: 12}
	}

	private Composite function create() {

		var offsets = this.offset.listToArray(" ")
		var pulls = this.pulls.listToArray(" ")
		var spans = this.span.listToArray(" ")

		this.validate("offsets", offsets)
		this.validate("pulls", pulls)
		this.validate("spans", spans)

		return this.contentFactory.create("bootstrap.component.Column", {spans: spans, offsets: offsets, pulls: pulls});
	}

	private void function validate(required String attribute, required String[] values) {

		// There should be 1 or 4 values.
		if (arguments.values.len() > 1 && arguments.values.len() < 4) {
			Throw("Invalid value(s) for attribute #arguments.attribute#", "IllegalArgumentException", "A single value or 4 space separated values are required.");
		} else {
			// Values should be integers or 'auto'.
			var range = this.ranges[arguments.attribute]
			var validValues = arguments.values.every(function (value) {
				return arguments.value == "auto" || IsValid("integer", arguments.value) && arguments.value >= range.from && arguments.value <= range.to;
			});
			if (!validValues) {
				Throw("Invalid value(s) for attribute #arguments.attribute#", "IllegalArgumentException", "Allowed values are integers between #range.from# and #range.to#, or 'auto'.");
			}
			// At least one value should be numeric.
			var containsNumeric = arguments.values.some(function (value) {
				return IsNumeric(arguments.value);
			})
			if (!containsNumeric) {
				Throw("Invalid value(s) for attribute #arguments.attribute#", "IllegalArgumentException", "At least one value should be numeric.");
			}
		}

	}

}