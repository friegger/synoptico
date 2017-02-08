const {describe, it, beforeEach} = require('mocha')
const {assert} = require('chai')
const {flip} = require('ramda')
const EventEmitter = require('events');
const B = require('baconjs')
const {Windows} = require('../app/windows')
const assertDeepEqual = flip(assert.deepEqual)

describe('windows', function () {

	let fakeBrowserWindows

	beforeEach(() => {
		fakeBrowserWindows = FakeBrowserWindows()
	})

	it('initially has an empty list of windows in $windows property', () => {
		const $newWindowRequest = B.never()
		const $finish = new B.Bus()

		const $windows = Windows(fakeBrowserWindows.constructorFn, $newWindowRequest)
		const $windowsSizes = collectValuesSizesUntil($finish, $windows)

		const runActions = () => {
			$finish.push()
		}

		$windowsSizes.onValue(assertDeepEqual([0]))

		runActions()
		return $windowsSizes.toPromise()
	})

	it('stores all windows in the $windows property', () => {
		const $newWindowRequest = new B.Bus()
		const $finish = new B.Bus()

		const $windows = Windows(fakeBrowserWindows.constructorFn, $newWindowRequest)
		const $windowsSizes = collectValuesSizesUntil($finish, $windows)

		const runActions = () => {
			$newWindowRequest.push()
			$newWindowRequest.push()
			$finish.push()
		}

		$windowsSizes.onValue(assertDeepEqual([0, 1, 2]))

		runActions()
		return $windowsSizes.toPromise()
	})

	it('does hook up the BrowserWindows\'s `closed` event', () => {
		const $newWindowRequest = new B.Bus()
		const $finish = new B.Bus()
		const $windows = Windows(fakeBrowserWindows.constructorFn, $newWindowRequest)
		const $windowsSizes = collectValuesSizesUntil($finish, $windows)

		const runActions = () => {
			$newWindowRequest.push()
			$newWindowRequest.push()
			fakeBrowserWindows.emit('closed', 1)
			fakeBrowserWindows.emit('closed', 0)
			$newWindowRequest.push()
			$finish.push()
		}

		$windowsSizes.onValue(assertDeepEqual([0, 1, 2, 1, 0, 1]))

		runActions()
		return $windowsSizes.toPromise()
	})
})


const collectValuesSizesUntil =
	($finish, observable) =>
		observable
			.takeUntil($finish)
			.fold([], (acc, values) => acc.concat([values]))
			.map(values => values.map(value => value.length))


const FakeBrowserWindows = () => {
	const windows = []

	return {
		emit(eventName, windowId) {
			if (windows[windowId]) {
				windows[windowId].emit(eventName)
			} else {
				throw new Error(`Window with id ${windowId} has not been created yet.`)
			}
		},
		constructorFn: function() {
			const newWindow = new FakeBrowserWindow(new EventEmitter())
			windows.push(newWindow)
			return newWindow
		}
	}
}

class FakeBrowserWindow extends EventEmitter {
	constructor(webContents) {
		super()
		this.webContents = webContents
	}

	emit (eventName) {
		super.emit(eventName, { sender: this})
	}

	loadURL () {}
}
