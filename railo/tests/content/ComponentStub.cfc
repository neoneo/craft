component extends="craft.core.content.Composite" {

	private String function view(required Context context) {
		return "before [[children]] after"
	}

}