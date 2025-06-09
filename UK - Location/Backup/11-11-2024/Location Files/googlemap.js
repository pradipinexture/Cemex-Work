// Default configuration
const defaultConfig = {
    latitude: 40.7128,
    longitude: -74.006,
    zoomLevel: 8
};

// Global variables
let map;
let marker;
let geocoder;

// Initialize map
function initMap() {
    const mapOptions = {
        center: { 
            lat: defaultConfig.latitude, 
            lng: defaultConfig.longitude 
        },
        zoom: defaultConfig.zoomLevel
    };

    map = new google.maps.Map(document.getElementById("location-map"), mapOptions);
    geocoder = new google.maps.Geocoder();

    // Add click event listener to map
    map.addListener("click", function(event) {
        placeMarker(event.latLng);
        updateCoordinates(event.latLng);
        getAddress(event.latLng);
    });

    // Set up event listeners
    setupEventListeners();
}

// Set up all event listeners
function setupEventListeners() {
    // Current location button click
    document.querySelector('.current-location').addEventListener('click', getCurrentLocation);

    // Coordinate input fields
    document.getElementById('latitude').addEventListener('keyup', updateMap);
    document.getElementById('longitude').addEventListener('keyup', updateMap);

    // Address input field
    document.getElementById('map-address').addEventListener('input', handleAddressInput);
}

function placeMarker(location) {
    if (marker) {
        marker.setMap(null);
    }

    marker = new google.maps.Marker({
        position: location,
        map: map
    });
}

function updateCoordinates(latLng) {
    let latitude, longitude;

    if (latLng instanceof google.maps.LatLng) {
        latitude = latLng.lat();
        longitude = latLng.lng();
    } else if (typeof latLng.lat === 'function' && typeof latLng.lng === 'function') {
        latitude = latLng.lat();
        longitude = latLng.lng();
    } else {
        latitude = latLng.lat;
        longitude = latLng.lng;
    }

    document.getElementById("latitude").value = latitude;
    document.getElementById("longitude").value = longitude;
}

function getCurrentLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            function(position) {
                const userLocation = {
                    lat: position.coords.latitude,
                    lng: position.coords.longitude
                };
                map.setCenter(userLocation);
                placeMarker(userLocation);
                updateCoordinates(userLocation);
                getAddress(userLocation);
            },
            function(error) {
                console.log("Error getting user location:", error);
            }
        );
    } else {
        console.log("Geolocation is not supported by your browser.");
    }
}

function updateMap() {
    const latitude = parseFloat(document.getElementById("latitude").value);
    const longitude = parseFloat(document.getElementById("longitude").value);

    if (isNaN(latitude) || isNaN(longitude)) {
        console.log("Please enter valid latitude and longitude.");
        return;
    }

    const newLocation = new google.maps.LatLng(latitude, longitude);
    map.setCenter(newLocation);
    placeMarker(newLocation);
    getAddress(newLocation);
}

function getAddress(latLng) {
    geocoder.geocode({ location: latLng }, function(results, status) {
        if (status === "OK") {
            if (results[0]) {
                document.getElementById("map-address").value = results[0].formatted_address;
            } else {
                document.getElementById("map-address").value = "Address not found";
            }
        } else {
            console.log("Geocoder failed due to: " + status);
        }
    });
}

function handleAddressInput(event) {
    const inputText = event.target.value;
    const suggestionsContainer = document.getElementById('address-suggestions');

    if (inputText.length > 0) {
        const service = new google.maps.places.AutocompleteService();
        service.getPlacePredictions({ input: inputText }, (predictions, status) => {
            if (status === google.maps.places.PlacesServiceStatus.OK) {
                updateAddressSuggestions(predictions);
            }
        });
    } else {
        suggestionsContainer.innerHTML = '';
    }
}

function updateAddressSuggestions(predictions) {
    const suggestionsList = document.getElementById('address-suggestions');
    suggestionsList.innerHTML = '';
    
    predictions.forEach((prediction) => {
        const suggestionItem = document.createElement('div');
        suggestionItem.textContent = prediction.description;
        suggestionItem.addEventListener('click', () => {
            suggestionsList.innerHTML = '';
            document.getElementById('map-address').value = prediction.description;
            onPlaceChanged();
        });
        suggestionsList.appendChild(suggestionItem);
        suggestionsList.style.display = 'block';
    });
}

function onPlaceChanged() {
    const address = document.getElementById('map-address').value;
    document.getElementById('address-suggestions').style.display = 'none';
    
    geocoder.geocode({ address: address }, function(results, status) {
        if (status === "OK" && results[0].geometry) {
            const location = results[0].geometry.location;
            map.setCenter(location);
            placeMarker(location);
            updateCoordinates(location);
            getAddress(location);
        } else {
            console.error("Geocoder failed due to: " + status);
        }
    });
}

// Export functions that need to be accessed globally
window.initMap = initMap;
