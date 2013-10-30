/**
 * A `Container` is a `Composite` whose children are repeatedly visited by the `Visitor`, instead of just once.
 *
 * The model (created by an ancestor node, as this class doesn't create one) should contain a collection of objects under the
 * '__collection__' key. Each of the children is then visited once for every object in the collection (at the `Visitor`'s discretion).
 */
component extends="Composite" accessors="true" {

	// // The name of the collection on the model.
	// property String collectionName setter="false";
	// // The name of the current item on the model.
	// property String itemName setter="false";

	// public void function init(required String collectionName, required String itemName) {
	// 	variables.collectionName = arguments.collectionName
	// 	variables.itemName = arguments.itemName
	// }

	public void function accept(required Visitor visitor) {
		arguments.visitor.visitContainer(this)
	}

}