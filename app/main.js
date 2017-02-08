const {app, BrowserWindow} = require('electron')
const {Menu, DockMenu} = require('./menu')
const {equals, not} = require('ramda')
const {Windows} = require('./windows')
const B = require('baconjs')

const isDev = process.env.ELECTRON_ENV == 'development'

B.fromEvent(app, 'ready').onValue(() => {
	const $newWindowRequest = B.mergeAll(
		Menu(),
		DockMenu(),
		B.once()
	)

	const $windows = Windows(BrowserWindow, $newWindowRequest)
	$windows.onError(err => console.log(err))

	if (isDev) {
		require('./dev').reloadWindowsOnChange($windows)
	}
})

B.fromEvent(app, 'window-all-closed')
	.filter(not(equals(process.platform, 'darwin')))
	.onValue(app, 'quit')
