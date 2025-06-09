// Function to load scripts dynamically
function loadScript(url) {
    return new Promise((resolve, reject) => {
        const script = document.createElement('script');
        script.src = url;
        script.onload = resolve;
        script.onerror = reject;
        document.head.appendChild(script);
    });
}

// Function to load CSS dynamically
function loadCSS(url) {
    return new Promise((resolve) => {
        if (document.querySelector(`link[href="${url}"]`)) {
            resolve();
            return;
        }
        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = url;
        link.onload = resolve;
        document.head.appendChild(link);
    });
}

// Define default country and preferred countries for phone input
var preferredCountries = ['GB', 'PL', 'CZ', 'FR', 'DE', 'HR', 'ES'];
var selectedCountryCodes = {};
var countryCodeValue;
var countryCodeValueModal;

function initializeIntlTelInput(preferredCountries, defaultCountryCode, inputId, errorId) {
    var phoneInputField = document.querySelector("#" + inputId);
    
    if (!phoneInputField) {
        console.error(`Phone input field with id "${inputId}" not found`);
        return null;
    }

    var phoneInput = window.intlTelInput(phoneInputField, {
        utilsScript: "https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/utils.js",
        preferredCountries: preferredCountries,
        initialCountry: defaultCountryCode,
        separateDialCode: true,
        formatOnDisplay: true
    });

    selectedCountryCodes[inputId] = defaultCountryCode;
    updateSelectedCountryCode(inputId, phoneInput.getSelectedCountryData().iso2);

    phoneInputField.addEventListener("countrychange", function() {
        var countryCode = phoneInput.getSelectedCountryData().iso2;
        selectedCountryCodes[inputId] = countryCode;
        updateSelectedCountryCode(inputId, countryCode);
    });

    phoneInputField.addEventListener("blur", function() {
        validatePhoneNumber(phoneInput, errorId);
    });

    return phoneInput;
}

function updateSelectedCountryCode(inputId, countryCode) {
    if (inputId === "phonenumber") {
        countryCodeValue = countryCode;
    } else if (inputId === "phonenumbermodal") {
        countryCodeValueModal = countryCode;
    }
}

function validatePhoneNumber(itiPhone, errorId) {
    var isValid = itiPhone.isValidNumber();
    document.getElementById(errorId).textContent = isValid ? "" : phoneNotValid;
    return isValid;
}

// Initialize everything after loading dependencies
async function initialize() {
    try {
        // Load CSS first
        await loadCSS('https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/css/intlTelInput.min.css');
        
        // Load main library
        await loadScript('https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/intlTelInput.min.js');
        
        // Load utils
        await loadScript('https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/utils.js');

        // Small delay to ensure everything is loaded
        setTimeout(() => {
            if (typeof window.intlTelInput === 'function') {
                initializeIntlTelInput(preferredCountries, 'GB', "phonenumber", "phoneNumber-error");
                initializeIntlTelInput(preferredCountries, 'GB', "phonenumbermodal", "phonenumbermodal-error");
            } else {
                console.error('intlTelInput library not loaded properly');
            }
        }, 100);
    } catch (error) {
        console.error('Error loading dependencies:', error);
    }
}

// Start initialization
initialize();
