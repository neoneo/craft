import craft.core.layout.Leaf;

component extends="Leaf" accessors="true" {

	property String href;
	property String media default="all";

	private String function view(required Context context) {
		return "link";
	}

	private Struct function model(required Context context) {
		return {
			rel = "stylesheet",
			type = "text/css",
			href = variables.href,
			media = variables.media
		};
	}

}