/**
 * A `Container` is a `Composite` whose children are repeatedly visited by the `Visitor`, instead of just once.
 *
 * The model (created by an ancestor node, as this class doesn't create one) should contain an array of objects. The objects in
 * the array are passed to the children one by one via the parent model. Each of the children is thus visited once for
 * every object in the collection.
 */
component extends="Composite" accessors="true" {

	// The name of the collection on the model.
	property String collectionName setter="false";
	// The name of the current item on the model.
	property String itemName setter="false";

	public void function init(required String collectionName, required String itemName) {
		variables.collectionName = arguments.collectionName
		variables.itemName = arguments.itemName
	}

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitContainer(this)
	}

}