import craft.core.output.*;

component implements="ContentType" {

	public String function name() {}
	public String function mimeType() {}
	public String function convert(required Array strings) {}
	public String function write(required String content) {}

}