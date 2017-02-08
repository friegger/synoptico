const {flip, reject, equals} = require('ramda')
const B = require('baconjs')
const fromEvent = flip(B.fromEvent)

const openWindow = BrowserWindow => message => {
	const window = new BrowserWindow({width: 800, height: 600})
	window.loadURL('file://' + __dirname + '/index.html')

	return {
		window,
		message
	}
}

const sendMessage = ({window, message}) => {
	if (message) {
		fromEvent('did-finish-load', window.webContents)
			.onValue((event) => {
				event.sender.send(message)
			})
	}

	return window
}

exports.Windows = (BrowserWindow, $newWindowRequest) => {
	const $windowCreated =
		$newWindowRequest
			.map(openWindow(BrowserWindow))
			.map(sendMessage)

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
