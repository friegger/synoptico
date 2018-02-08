const {flip, reject, equals} = require('ramda')
const B = require('baconjs')
const fromEvent = flip(B.fromEvent)

const openWindow = BrowserWindow => message => {
	const window = new BrowserWindow({width: 800, height: 600, show: false, backgroundColor: 'f6fffe'})
	window.loadURL('file://' + __dirname + '/index.html')

	return {
		window,
		message
	}
}

const showWindow = ({window, message}) => {
	fromEvent('ready-to-show', window).onValue(event => {
		if (message) {
			event.sender.send(message)
		} else {
			window.show()
		}
	})

	return window
}

exports.Windows = (BrowserWindow, $newWindowRequest) => {
	const $windowCreated =
		$newWindowRequest
			.map(openWindow(BrowserWindow))
			.map(showWindow)

	const $windowClosed =
		$windowCreated
			.flatMap(fromEvent('closed'))
			.map(event => event.sender)

	return B.update(
		[],
		[$windowCreated], (windows, window) => windows.concat(window),
		[$windowClosed], (windows, window) => reject(equals(window), windows)
	)
}
