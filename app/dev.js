const B = require('baconjs')

const reloadWindows = windows => windows.forEach(window => window.reload())

exports.reloadWindowsOnChange = $windows => {
	const chokidar = require('chokidar');
	const $filesChanged = B.fromEvent(chokidar.watch(['app/index.html', 'app/elm.js']), 'change')
	$windows
		.sampledBy($filesChanged)
		.onValue(reloadWindows)
}



