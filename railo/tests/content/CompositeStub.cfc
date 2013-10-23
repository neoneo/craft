import craft.core.request.Context;

component extends="craft.core.content.Composite" {

	public String function view(required Context context) {
		return "before [[children]] after"
	}

}