function calculateIOS()
{
    var userAgent = window.navigator.userAgent;
    var has11 = userAgent.search("OS 11_\\d") > 0
    var hasMacOS = userAgent.search(" like Mac OS X") > 0

    return has11 && hasMacOS;
}

module.exports = calculateIOS