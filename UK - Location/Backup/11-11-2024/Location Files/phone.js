    // Define default country and preferred countries for phone input
        const defaultCountryCode = 'US';
        const preferredCountries = ['GB', 'PL', 'CZ', 'FR', 'DE', 'HR', 'ES'];

        // Initialize the phone input field
        document.addEventListener("DOMContentLoaded", function () {
            initializeIntlTelInput(preferredCountries, defaultCountryCode, "phonenumber", "phoneNumber-error");
            initializeIntlTelInput(preferredCountries, dynamicCountryCode,"phonenumbermodal","phonenumbermodal-error");
        });

        function initializeIntlTelInput(preferredCountries, defaultCountryCode, inputId, errorId) {
            const phoneInputField = document.querySelector("#" + inputId);
            const phoneInput = window.intlTelInput(phoneInputField, {
                utilsScript: "https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/utils.js",
                preferredCountries: preferredCountries,
            });

            phoneInput.setCountry(defaultCountryCode);
            phoneInputField.addEventListener("countrychange", () => {
                const countryCode = phoneInput.getSelectedCountryData().iso2;
                console.log("Selected country code:", countryCode); // Log the selected country code
            });
            
            phoneInputField.addEventListener("blur", function () {
                validatePhoneNumber(phoneInput, errorId);
            });
        }

        // Validate phone number input
        function validatePhoneNumber(itiPhone, errorId) {
            const isValid = itiPhone.isValidNumber();
            const errorMessages = {
                INVALID_COUNTRY_CODE: "Invalid country code",
                TOO_SHORT: "Phone number is too short",
                TOO_LONG: "Phone number is too long",
                NOT_A_NUMBER: "Not a valid number",
                DEFAULT: "Invalid phone number",
            };

            const errorCode = itiPhone.getValidationError();
            const errorMessage = isValid ? "" : errorMessages[errorCode] || errorMessages.DEFAULT;
            document.getElementById(errorId).textContent = errorMessage;
            return isValid;
        }
