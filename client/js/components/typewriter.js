module.exports = function (arr, id, ms) {
	var j = 0
	var linesLength = arr.length
	var typeArea = document.getElementById(id)

	typeLine(arr[j])

	function typeLine(line) {
		var lineLength = line.length
		var i = 0

		addLetter()

		function addLetter(){
			setTimeout(function(){
				typeArea.innerHTML = toNthLetter(line, i)
				if(i <= lineLength) {
					i++
					addLetter()
				} else {
					setTimeout(function(){
						removeLetter()
					}, ms * 6)
				}
			}, ms)
		}

		function removeLetter(){
			setTimeout(function(){
				typeArea.innerHTML = toNthLetter(line, i)
				if(i > 0) {
					i--
					removeLetter()
				} else {
					setTimeout(function(){
						j = (j + 1) % linesLength
						typeLine(arr[j])
					}, ms * 5)
				}
			}, ms * 0.3)
		}
	}

	function toNthLetter(string, n) {
		return string.split('').splice(0, n).join('')
	}
}
