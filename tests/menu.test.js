const { describe, it } = require('mocha')
const { assert } = require('chai')
const { DockMenu, WindowMenu } = require('../app/menu')
const { add, flip, find, propEq } = require('ramda')
const B = require('baconjs')

const assertDeepEqual = flip(assert.deepEqual)

describe('menu', () => {
	describe('DockMenu', () => {
		it('returns a stream hooking up the click event of the `New Window` menu item', () => {
			const $finish = new B.Bus()
			const $newWindowRequest = DockMenu(app, Menu)

			const $numOfNewWindowRequests = $newWindowRequest.takeUntil($finish).fold(0, add(1))

			const runActions = () => {
				const newWindowItem = app.dock.getMenu()[0]
				assertDeepEqual('New Window', newWindowItem.label)
				newWindowItem.click()
				newWindowItem.click()
				$finish.push()
			}

			$numOfNewWindowRequests.onValue(assertDeepEqual(2))

			runActions()
			return $numOfNewWindowRequests.toPromise()
		})

		describe('when dock is NOT available', () => {
			it('returns an `ended` stream', (done) => {
				const app = {}
				const $newWindowRequest = DockMenu(app, Menu)

				$newWindowRequest.onEnd(done)
			})
		})
	})

	describe('WindowMenu', () => {
		describe('New Window menu item', () => {
			it('creates a new window request with undefined message', () => {
				const $finish = new B.Bus()
				const $newWindowRequest = WindowMenu(app, Menu)

				const $newWindowRequests =
					$newWindowRequest
							.takeUntil($finish)
							.fold([], (acc, values) => acc.concat([values]))

				const runActions = () => {
					const fileSubmenu = findMenuItem('File', Menu.getApplicationMenu()).submenu
					const newWindowItem = findMenuItem('New Window', fileSubmenu)
					assertDeepEqual('New Window', newWindowItem.label)
					newWindowItem.click()
					newWindowItem.click()
					$finish.push()
				}

				$newWindowRequests.onValue(assertDeepEqual([undefined, undefined]))

				runActions()
				return $newWindowRequests.toPromise()
			})
		})

		describe('Open File menu item', () => {
			describe('with no window context', () => {
				it('creates a new window request with `open-file` message', () => {
					const $finish = new B.Bus()
					const $newWindowRequest = WindowMenu(app, Menu)

					const $newWindowRequests =
						$newWindowRequest
							.takeUntil($finish)
							.fold([], (acc, values) => acc.concat([values]))

					const runActions = () => {
						const fileSubmenu = findMenuItem('File', Menu.getApplicationMenu()).submenu
						const newWindowItem = findMenuItem('Open File...', fileSubmenu)
						assertDeepEqual('Open File...', newWindowItem.label)
						newWindowItem.click()
						newWindowItem.click()
						$finish.push()
					}

					$newWindowRequests.onValue(assertDeepEqual(['open-file', 'open-file']))

					runActions()
					return $newWindowRequests.toPromise()
				})
			})

			describe('with window context', () => {
				it('does not create a new window request', () => {
					const $finish = new B.Bus()
					const $newWindowRequest = WindowMenu(app, Menu)

					const $numOfNewWindowRequests = $newWindowRequest.takeUntil($finish).fold(0, add(1))

					const runActions = () => {
						const fileSubmenu = findMenuItem('File', Menu.getApplicationMenu()).submenu
						const newWindowItem = findMenuItem('Open File...', fileSubmenu)
						assertDeepEqual('Open File...', newWindowItem.label)
						const focusedWindow = createFocusedWindow()

						newWindowItem.click(null, focusedWindow)
						newWindowItem.click(null, focusedWindow)

						assertDeepEqual(['open-file', 'open-file'], focusedWindow.getMessages())

						$finish.push()
					}

					$numOfNewWindowRequests.onValue(assertDeepEqual(0))

					runActions()

					return $numOfNewWindowRequests.toPromise()
				})
			})
		})
	})
})

const app = {
	dock: {
		setMenu(menu) {
			this.menu = menu
		},
		getMenu() {
			return this.menu
		}
	},
	getName() {
		return 'FakeApp'
	}
}

const Menu = {
	buildFromTemplate(template) {
		return template
	},
	setApplicationMenu(menu){
		this.menu = menu
	},
	getApplicationMenu() {
		return this.menu
	}
}

const findMenuItem = (label, menu) => find(propEq('label', label), menu)

const createFocusedWindow = () => {
	const messages = []

	return {
		webContents: {
			send(msg) {
				messages.push(msg)
			}
		},
		getMessages() {
			return messages
		}
	}
}


