    // Define default country and preferred countries for phone input
        const defaultCountryCode = 'US';
        const preferredCountries = ['GB', 'PL', 'CZ', 'FR', 'DE', 'HR', 'ES'];

        // Initialize the phone input field
        document.addEventListener("DOMContentLoaded", function () {
            initializeIntlTelInput(preferredCountries, defaultCountryCode, "phonenumber", "phoneNumber-error");
            initializeIntlTelInput(preferredCountries, dynamicCountryCode,"phonenumbermodal","phonenumbermodal-error");
        });
   const selectedCountryCodes = {};
    function initializeIntlTelInput(preferredCountries, defaultCountryCode, inputId, errorId) {
      const phoneInputField = document.querySelector("#" + inputId);
      const phoneInput = window.intlTelInput(phoneInputField,{
	 utilsScript: "https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/utils.js",
	 preferredCountries: preferredCountries
       });

      phoneInput.setCountry(defaultCountryCode);
      selectedCountryCodes[inputId] = defaultCountryCode;

      updateSelectedCountryCode(inputId, phoneInput.getSelectedCountryData().iso2);
      phoneInputField.addEventListener("countrychange", function () {
	 const countryCode = phoneInput.getSelectedCountryData().iso2;
     
	 selectedCountryCodes[inputId] = countryCode; 
	 updateSelectedCountryCode(inputId, countryCode);
       });
     
      phoneInputField.addEventListener("blur", function () {
	 validatePhoneNumber(phoneInput, errorId);
       });
     
      return phoneInput;
   }
     
    let countryCodeValue;
    let countryCodeValueModal;

    function updateSelectedCountryCode(inputId, countryCode) {
      if (inputId === "phonenumber") {
	 countryCodeValue = countryCode;
       } else if (inputId === "phonenumbermodal") {
	 countryCodeValueModal = countryCode;
       }
   }
     
        // Validate phone number input
        function validatePhoneNumber(itiPhone, errorId) {
            const isValid = itiPhone.isValidNumber();
            /*const errorMessages = {
                INVALID_COUNTRY_CODE: "Invalid country code",
                TOO_SHORT: "Phone number is too short",
                TOO_LONG: "Phone number is too long",
                NOT_A_NUMBER: "Not a valid number",
                DEFAULT: "Invalid phone number",
            };

            const errorCode = itiPhone.getValidationError();
            const errorMessage = isValid ? "" : errorMessages[errorCode] || errorMessages.DEFAULT;*/
            document.getElementById(errorId).textContent = phoneNotValid;
            return isValid;
        }
