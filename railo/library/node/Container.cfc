import craft.core.layout.Component;
import craft.core.navigation.Context;

/**
 * A generic composite.
 **/
component extends="Component" accessors="true" {

	property String id;
	property Array classes;

	public Component function addClass(required String className) {

		if (IsNull(variables.classes)) {
			variables.classes = [];
		}
		if (variables.classes.findNoCase(arguments.className) == 0) {
			variables.classes.append(arguments.className);
		}

		return this;
	}

	public Component function removeClass(required String className) {

		if (!IsNull(variables.classes)) {
			// the delete member function is not case sensitive
			variables.classes.delete(arguments.className);
		}

		return this;
	}

	private String function view(required Context context) {
		return "container";
	}

	private Struct function model(required Context context) {

		var model = super.model(arguments.context);
		model.id = getId();
		model.classes = IsNull(getClasses()) ? "" : getClasses().toList(" ");

		return model;
	}

}