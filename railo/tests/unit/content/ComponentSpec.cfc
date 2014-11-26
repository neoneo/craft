import craft.content.Component;
import craft.content.Composite;

component extends="testbox.system.BaseSpec" {

	function run() {

		describe("Component", function () {

			beforeEach(function () {
				component = new Component()
			})

			describe("parent relationship", function () {

				beforeEach(function () {
					parent = CreateObject("Composite")
				})

				it("accessors should set and get the parent", function () {
					component.parent = parent
					$assert.isSameInstance(parent, component.parent)
				})

				it("hasParent should return whether the component has a parent", function () {
					expect(component.hasParent).toBeFalse()

					component.parent = parent

					expect(component.hasParent).toBeTrue()

					component.parent = null

					expect(component.hasParent).toBeFalse()
				})

			})

		})

	}

}