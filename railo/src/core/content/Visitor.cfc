import craft.core.content.Composite;
import craft.core.content.Document;
import craft.core.content.Leaf;
import craft.core.content.Placeholder;
import craft.core.content.Section;
import craft.core.content.Template;

interface {

	public void function visitComposite(required Composite composite);
	public void function visitDocument(required Document document);
	public void function visitLeaf(required Leaf leaf);
	public void function visitPlaceholder(required Placeholder placeholder);
	public void function visitSection(required Section section);
	public void function visitTemplate(required Template template);

}