const {app, BrowserWindow, Menu, powerSaveBlocker} = require('electron')
const {WindowMenu, DockMenu} = require('./menu')
const {equals, not} = require('ramda')
const {Windows} = require('./windows')
const B = require('baconjs')

const isDev = process.env.ELECTRON_ENV == 'development'
app.commandLine.appendSwitch('--ignore-certificate-errors')

powerSaveBlocker.start('prevent-app-suspension')

B.fromEvent(app, 'ready').onValue(() => {
	const $newWindowRequest = B.mergeAll(
		WindowMenu(app, Menu),
		DockMenu(app, Menu),
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
