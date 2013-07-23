import craft.core.layout.Composite;
import craft.core.navigation.Context;

/**
 * A generic composite.
 **/
component extends="Composite" accessors="true" {

	property String id;
	property Array classes;

	public Composite function addClass(required String className) {

		if (IsNull(variables.classes)) {
			variables.classes = [];
		}
		if (variables.classes.findNoCase(arguments.className) == 0) {
			variables.classes.append(arguments.className);
		}

		return this;
	}

	public Composite function removeClass(required String className) {

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