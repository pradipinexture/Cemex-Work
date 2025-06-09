var postalNotValidLabel = "Postal code is not valid";

function validatePostalCode(postalCode) {
    var apiURL = "https://app.zipcodebase.com/api/v1/search?apikey=3eeee100-cefc-11ee-b060-635cb775ed1a&codes=" + postalCode;
    var isValid = false;

    var xhr = new XMLHttpRequest();
    xhr.open("GET", apiURL, false); // synchronous request

    xhr.onload = function () {
        if (xhr.status === 200) {
            var response = JSON.parse(xhr.responseText);
            if (!response.results || response.results.length === 0) {
                console.log("No results found for the postal code: " + postalCode);
                document.getElementById("postcode-error").textContent = postalNotValidLabel;
                isValid = false;
            } else {
                console.log(response);
                document.getElementById("postcode-error").textContent = "";
                isValid = true;
            }
        } else {
            console.error("Error: " + xhr.status);
            document.getElementById("postcode-error").textContent = psValidateErrorLabel;
            isValid = false;
        }
    };

    xhr.onerror = function () {
        console.error("Request failed");
        document.getElementById("postcode-error").textContent = psValidateErrorLabel;
        isValid = false;
    };

    xhr.send();
    return isValid;
}

document.addEventListener("DOMContentLoaded", function () {
    document.getElementById("postcode").addEventListener("keyup", function () {
        var pos = this.value;
        if (pos.length >= 3) {
            var isValid = validatePostalCode(pos);
            if (isValid) {
                console.log("True Result: Postal code is valid");
            } else {
                console.log("False Result: Postal code is not valid");
            }
        } else {
            console.log("Postal code is too short");
        }
    });
});
