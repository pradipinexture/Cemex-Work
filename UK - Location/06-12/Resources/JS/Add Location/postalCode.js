function validatePostalCode(postalCode) {
    var apiURL = zipCodeSearchApiUrl +"?apikey="+ zipApiKey +"&codes=" + postalCode;
    var isValid = false;

    var xhr = new XMLHttpRequest();
    xhr.open("GET", apiURL, false);

    xhr.onload = function () {
        if (xhr.status === 200) {
            var response = JSON.parse(xhr.responseText);
            if (!response.results || response.results.length === 0) {
                document.getElementById("postcode-error").textContent = postalNotValidLabel;
                isValid = false;
            } else {
                document.getElementById("postcode-error").textContent = "";
                isValid = true;
            }
        } else {
            document.getElementById("postcode-error").textContent = psValidateErrorLabel;
            isValid = false;
        }
    };

    xhr.onerror = function () {
        Toast.error(psValidateErrorLabel);
        document.getElementById("postcode-error").textContent = psValidateErrorLabel;
        isValid = false;
    };

    xhr.send();
    return isValid;
}

document.getElementById("postcode").addEventListener("blur", function () {
	var pos = this.value;
	if (pos.length >= 3) {
	    var isValid = validatePostalCode(pos);
	}
});

