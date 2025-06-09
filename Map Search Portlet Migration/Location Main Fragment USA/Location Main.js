// Request needed libraries.
const { Map } = await google.maps.importLibrary("maps");
const { AdvancedMarkerElement, PinElement } = await google.maps.importLibrary("marker");

const locationsListDiv = fragmentElement.querySelector("#locations-list #map-search__results .accordion>div");
const baseUrl = `/o/c/locations/scopes/${Liferay.ThemeDisplay.getSiteGroupId()}`;
let isFirstLoad = true;
let selectedProduct = "";
let selectedState = ""
let currentSearchTerm = "";
let map;
let markers = [];
// Create a bounds object to fit all markers
let bounds = new google.maps.LatLngBounds();

// Helper function to remove the highlight from all location items
function removeHighlights() {
    const locationItems = locationsListDiv.querySelectorAll(".location-item");
    locationItems.forEach(item => item.classList.remove("highlight"));
}

async function getDisplayPageName(id) {
    let name = null;
    let classNameId = null;
    if (id && id > 0) {
        await Liferay.Service(
            '/layout.layoutpagetemplateentry/fetch-layout-page-template-entry',
            {
                layoutPageTemplateEntryId: id
            },
            function (obj) {
                name = obj?.layoutPageTemplateEntryKey || "";
                classNameId = obj?.classNameId || "";
            }
        );
    }
    return { name, classNameId };
}

async function generateCustomUrl(id, description, displayPageId) {
    const origin = window.location.origin;
    const pathSegments = window.location.pathname.split('/').filter(segment => segment);
    const hasWebSegment = pathSegments.includes('web');

    if (hasWebSegment) {
        // Take only the first two path segments if they exist
        const basePath = pathSegments.slice(0, 2).join('/');
        let newUrl = "";
        if (displayPageId && displayPageId > 0) {
            const { name, classNameId } = await getDisplayPageName(displayPageId);
            newUrl = `${origin}/${basePath}/e/${name}/${classNameId}/${id}`;
        } else if (description) {
            newUrl = `${origin}/${basePath}/l/${id}`;
        } else {
            newUrl = `${origin}/${basePath}/e/locations-compact/2073759/${id}`;
        }

        return newUrl;
    } else {
        const newUrl = `${origin}/l/${id}`;
        return newUrl;
    }
}

function convertTo12HourFormat(time24) {
    // Validate input: must be in "HH:MM" format
    if (!/^\d{2}:\d{2}$/.test(time24)) {
        return null;
    }

    // Split the time into hours and minutes
    const [hours, minutes] = time24.split(":").map(Number);

    // Validate hours and minutes range
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
        return null;
    }

    // Determine the period (AM or PM)
    const period = hours >= 12 ? "PM" : "AM";

    // Convert hours to 12-hour format
    const hours12 = hours % 12 || 12; // Convert 0 to 12 for midnight

    // Return formatted time
    return `${hours12}:${String(minutes).padStart(2, '0')} ${period}`;
}

function getStatusForDay(data) {
    let openingHoursTag = ``;
    if (data) {
        const days = [
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday",
        ];

        const now = new Date();
        const currentDay = days[now.getDay()]; // Get the current day name
        const currentTime = now.toTimeString().split(" ")[0]; // Get current time in HH:MM:SS format

        const openKey = `${currentDay.toLowerCase()}Open`;
        const closeKey = `${currentDay.toLowerCase()}Close`;
        const closedKey = `isClosedOn${currentDay}`;

        const openTime = data[openKey];
        const closeTime = data[closeKey];
        const isClosed = data[closedKey];

        if (isClosed) {
            // Check for the next day the location opens
            let nextDay = (now.getDay() + 1) % 7; // Start from the next day
            let attempts = 0; // To track the number of days checked (max 7)

            while (attempts < 7) { // Ensure we only check for a maximum of 7 days
                const nextDayName = days[nextDay];
                const nextOpenKey = `${nextDayName.toLowerCase()}Open`;
                const nextIsClosedKey = `isClosedOn${nextDayName}`;

                if (!data[nextIsClosedKey] && data[nextOpenKey]) {
                    openingHoursTag = `<span class="opening-label-closed">Closed</span><span class="opening-dot">.</span><span class="opening-info">Opens ${convertTo12HourFormat(data[nextOpenKey])} ${nextDayName}</span>`;
                }

                // Move to the next day
                nextDay = (nextDay + 1) % 7;
                attempts++;
            }
            // If no open day is found
            openingHoursTag = `<span class="opening-label-closed">Closed</span><span class="opening-dot">.</span><span class="opening-info">indefinitely</span>`;
        } else {

            // Determine if currently open
            if (currentTime >= openTime && (!closeTime || currentTime < closeTime)) {
                openingHoursTag = `<span class="opening-label-open">Open</span><span class="opening-dot">.</span><span class="opening-info">Closes ${convertTo12HourFormat(closeTime) || "later today"}</span>`;
            } else if (currentTime < openTime) {
                openingHoursTag = `<span class="opening-label-closed">Closed</span><span class="opening-dot">.</span><span class="opening-info">Opens ${convertTo12HourFormat(openTime)} today</span>`;
            } else {
                // Location is closed for today, check the next opening day
                let nextDay = (now.getDay() + 1) % 7; // Start from the next day

                let attempts = 0;
                while (attempts < 7) {
                    const nextDayName = days[nextDay];
                    const nextOpenKey = `${nextDayName.toLowerCase()}Open`;
                    const nextIsClosedKey = `isClosedOn${nextDayName}`;

                    if (!data[nextIsClosedKey] && data[nextOpenKey]) {
                        openingHoursTag = `<span class="opening-label-closed">Closed</span><span class="opening-dot">.</span><span class="opening-info">Opens ${convertTo12HourFormat(data[nextOpenKey])} ${nextDayName}</span>`;
                        break;
                    }
                    // Move to the next day
                    nextDay = (nextDay + 1) % 7;
                    attempts++;

                }
                if (openingHoursTag == "") {
                    // If no opening day is found 
                    openingHoursTag = `<span class="opening-label-closed">Closed</span><span class="opening-dot">.</span><span class="opening-info">indefinitely</span>`;
                }
            }
        }
    } else {
        openingHoursTag = `<span class="opening-label-closed">No Info</span><span class="opening-dot">.</span><span class="opening-info">N/A</span>`;
    }

    return openingHoursTag
}

async function setLocationsList(location) {
    const locationItem = document.createElement("div");
    locationItem.className = "accordion__item accordion__item_collapsed";

    const locationTitle = document.createElement("div");
    locationTitle.className = "accordion__title";

    const locationHeader = document.createElement("div");
    locationHeader.className = "location__header";

    const locationExcerpt = document.createElement("div");
    locationExcerpt.className = "location__excerpt";

    const locationMainTitle = document.createElement("div");
    locationMainTitle.className = "u-position-relative";
    locationMainTitle.innerHTML = `<h4>${location.name}</h4>`;

    const locationAddressProductsContainer = document.createElement("div");

    const addressContainer = document.createElement("div");
    addressContainer.innerHTML = `<div class="location__address">${location.address}</div>`;

    const productTags = document.createElement("div");
    productTags.className = "product-tags";

    location.keywords.forEach(keyword => {
        const productTagsItem = document.createElement("div");
        productTagsItem.className = "product-tags-item";
        productTagsItem.textContent = keyword;
        productTags.appendChild(productTagsItem);
    });

    locationAddressProductsContainer.appendChild(addressContainer);
    locationAddressProductsContainer.appendChild(productTags);

    locationExcerpt.appendChild(locationMainTitle);
    locationExcerpt.appendChild(locationAddressProductsContainer);

    locationHeader.appendChild(locationExcerpt);

    locationTitle.appendChild(locationHeader);

    locationItem.appendChild(locationTitle);

    //accordion body

    const accordionBody = document.createElement("div");
    accordionBody.className = "accordion__body";

    const locationBody = document.createElement("div");
    locationBody.className = "location__body";

    const openingHours = document.createElement("div");
    openingHours.className = "opening-hours";

    const locationOpeningItems = document.createElement("div");
    locationOpeningItems.className = "location-opening-items";

    const data = location.contactInformactionRel.find(item => item.isMain == true)
    const mainCallNumber = data?.phoneNumber || null;
    const openingHoursTag = getStatusForDay(location);
    locationOpeningItems.innerHTML = openingHoursTag;

    openingHours.appendChild(locationOpeningItems);

    const ctaWrapper = document.createElement("div");
    ctaWrapper.className = "location-cta-wrapper";

    //Link to map
    const linkToMap = document.createElement("a");
    linkToMap.className = "b-button-link cta-primary";
    linkToMap.setAttribute("href", `https://google.com/maps/dir//${location.latitude},${location.longitude}`);
    linkToMap.setAttribute("target", "_blank")
    linkToMap.innerHTML = `<span class="material-symbols-outlined">assistant_direction</span><span class='b-button-link__cta-primary__label'>Directions</span>`;

    //Link to Call???
    let linkToCall = undefined;
    if (mainCallNumber) {
        linkToCall = document.createElement("a");
        linkToCall.className = "b-button-link cta-primary";
        linkToCall.setAttribute("href", `tel:${mainCallNumber}`);
        linkToCall.innerHTML = ` <span class="material-symbols-outlined">call</span><span class="b-button-link__cta-primary__label">Call</span>`;
    }

    //Link to detail
    const linkToDetail = document.createElement("a");
    linkToDetail.className = "b-button-link cta-primary";
    linkToDetail.setAttribute("href", await generateCustomUrl(location.id, location.description, location.displayPageId));
    linkToDetail.innerHTML = `<span class="material-symbols-outlined">add_circle</span><span class="b-button-link__cta-primary__label">Learn More</span>`;

    ctaWrapper.appendChild(linkToMap);
    if (mainCallNumber) {
        ctaWrapper.appendChild(linkToCall);
    }
    ctaWrapper.appendChild(linkToDetail);

    locationBody.appendChild(openingHours);
    locationBody.appendChild(ctaWrapper);

    accordionBody.appendChild(locationBody);

    locationItem.appendChild(accordionBody);

    locationsListDiv.appendChild(locationItem);

    return locationItem;
}

async function addMarkers(locations) {
    // Loop through locations and add markers
    locations.forEach(async (location) => {
        // Change the background color.
        const pinBackground = new PinElement({
            background: "#FD2230",
            borderColor: "#D8000E",
            glyphColor: "white",
        });
        const pos = { lat: location.latitude, lng: location.longitude };
        const marker = new AdvancedMarkerElement({
            map: map,
            position: pos,
            title: location.name,
            content: pinBackground.element,
        });

        const locationItem = await setLocationsList(location);
        // Add click event listener to each marker
        marker.addListener("click", () => {
            map.panTo(pos);
            map.setZoom(10);

            // Scroll to the location item in the list
            locationItem.scrollIntoView({ behavior: "smooth", block: "center" });

        });

        // Extend the bounds to include each marker's position
        bounds.extend(marker.position);
        markers.push(marker)
    });
}

function getBoundsWithPadding() {
    const isMobile = window.innerWidth < 991; // Adjust breakpoint as needed
    console.log({
        left: isMobile ? 0 : 520, // Add padding to the left to show "empty space"
        top: isMobile ? 0 : 100,
        right: 0,
        bottom: 0
    })
    return {
        left: isMobile ? 0 : 520, // Add padding to the left to show "empty space"
        top: isMobile ? 0 : 100,
        right: 0,
        bottom: 0
    }
}

function fitBounds() {
    map.fitBounds(bounds, getBoundsWithPadding());
}

// Optimize resize behavior (just useful for testing)
let resizeTimeout;
window.addEventListener("resize", () => {
    clearTimeout(resizeTimeout);
    resizeTimeout = setTimeout(() => {
        fitBounds();
    }, 300);
});


function setClusterer() {
    //using market clusterer library to avoid cluttering the view
    const clusterer = new markerClusterer.MarkerClusterer({ map, markers });
}

async function initMap(locations) {
    const position = { lat: 38.7945952, lng: -106.5348379 }; //temporary

    const usBounds = {
        north: 59.3457868, // Northernmost point 
        south: 24.396308,  // Southernmost point 
        west: -125.0,      // Westernmost point 
        east: -48.71149    //  Easternmost point 
    };

    // The map, centered at Location
    map = new Map(fragmentElement.querySelector("#map"), {
        zoom: 10,
        center: position,
        mapId: "LOCATIONS_MAP_ID",
        streetViewControl: false,
        mapTypeControl: false,
    });

    if (locations == 0) {
        // No locations: Fit the map to the U.S. bounds
        map.fitBounds(usBounds, getBoundsWithPadding());

    } else {
        addMarkers(locations);
        fitBounds();
        setClusterer();
    }
}


function initMapFilterStates(states = []) {
    const statesFilterContainer = fragmentElement.querySelector(`#state-filter-container`);
    if (configuration.state.trim() != "") {
        statesFilterContainer.classList.add("d-none");
    } else {
        const mapSearchFilterTitle = statesFilterContainer.querySelector(".map-search__filter .accordion__title");
        const mapSearchFilterOptions = statesFilterContainer.querySelector(".map-search__filter .accordion__body");
        const selectedStateElement = statesFilterContainer.querySelector(".map-search__filter .map-search__filter_selected-product");
        const optionsContainer = mapSearchFilterOptions.querySelector(".search-filter-form");
        const allOptionTag = optionsContainer.querySelector(".radio.selected");
        const statesCloseButton = statesFilterContainer.querySelector(".close-btn");

        statesCloseButton.addEventListener('click', () => {
            mapSearchFilterOptions.classList.add('d-none');
        });

        document.addEventListener("click", function (event) {
            if (!statesFilterContainer.contains(event.target)) {
                mapSearchFilterOptions.classList.add('d-none');
            }
        });

        mapSearchFilterTitle.addEventListener('click', () => {
            mapSearchFilterOptions.classList.toggle('d-none');
        });

        function loadOptionsFilterTag(state, option) {
            if (state != "") {
                selectedStateElement.textContent = state;
                selectedState = state;
            } else {
                selectedStateElement.textContent = "All";
                selectedState = "";
            }
            mapSearchFilterOptions.classList.add('d-none');
            fetchObjectEntries();

            //clean selected class & assign to the selected one
            const allOptionsTags = optionsContainer.querySelectorAll(".radio");
            allOptionsTags.forEach(optionTag => {
                optionTag.classList.remove("selected");
            });
            option.classList.add("selected");
        }

        allOptionTag.addEventListener("click", () => { loadOptionsFilterTag("", allOptionTag) });

        states.forEach(product => {
            const option = document.createElement("div");
            option.setAttribute("aria-label", product);
            option.textContent = product;
            option.className = "radio";

            option.addEventListener("click", () => { loadOptionsFilterTag(product, option) });
            optionsContainer.appendChild(option);
        });
    }
}

function initMapFilterProducts(products = []) {
    const productsFilterContainer = fragmentElement.querySelector(`#product-filter-container`)
    const mapSearchFilterTitle = productsFilterContainer.querySelector(".map-search__filter .accordion__title");
    const mapSearchFilterOptions = productsFilterContainer.querySelector(".map-search__filter .accordion__body");
    const selectedProductElement = productsFilterContainer.querySelector(".map-search__filter .map-search__filter_selected-product");
    const optionsContainer = mapSearchFilterOptions.querySelector(".search-filter-form");
    const allOptionTag = optionsContainer.querySelector(".radio.selected")
    const mapSearchCloseButton = productsFilterContainer.querySelector(".close-btn");

    mapSearchCloseButton.addEventListener('click', () => {
        mapSearchFilterOptions.classList.add('d-none');
    });

    document.addEventListener("click", function (event) {
        if (!productsFilterContainer.contains(event.target)) {
            mapSearchFilterOptions.classList.add('d-none');
        }
    });

    mapSearchFilterTitle.addEventListener('click', () => {
        mapSearchFilterOptions.classList.toggle('d-none');
    });

    function loadOptionsFilterTag(product, option) {
        if (product != "") {
            selectedProductElement.textContent = product;
            selectedProduct = product;
        } else {
            selectedProductElement.textContent = "All";
            selectedProduct = "";
        }
        mapSearchFilterOptions.classList.add('d-none');
        fetchObjectEntries();

        //clean selected class & assign to the selected one
        const allOptionsTags = optionsContainer.querySelectorAll(".radio");
        allOptionsTags.forEach(optionTag => {
            optionTag.classList.remove("selected");
        });
        option.classList.add("selected");
    }

    allOptionTag.addEventListener("click", () => { loadOptionsFilterTag("", allOptionTag) });

    products.forEach(product => {
        const option = document.createElement("div");
        option.setAttribute("aria-label", product);
        option.textContent = product;
        option.className = "radio";

        option.addEventListener("click", () => { loadOptionsFilterTag(product, option) });
        optionsContainer.appendChild(option);
    });

}

function initMapInputSearch() {
    const searchInput = fragmentElement.querySelector(`#search-${fragmentEntryLinkNamespace}`);
    const searchButton = fragmentElement.querySelector(`#btn-search-${fragmentEntryLinkNamespace}`);

    function loadSearch() {
        currentSearchTerm = searchInput.value.trim();
        fetchObjectEntries();
    }

    searchButton.addEventListener("click", loadSearch);
    searchInput.addEventListener('keypress', (event) => {
        // Check if the Enter key was pressed
        if (event.key === 'Enter') {
            loadSearch();
        }
    });
}

function showNoResultsMessage(show = false) {
    const noResultsElement = fragmentElement.querySelector(`#no-results`);
    if (show) {
        noResultsElement.classList.remove("d-none");
    } else {
        noResultsElement.classList.add("d-none");
    }
}

function isLocationInsideBounds(location) {
    const bounds = [{
        name: "los angeles",
        northeastLat: 34.337306,
        northeastLong: -118.1552891,
        southwestLat: 33.7036519,
        southwestLong: -118.6681761,
    },
    {
        name: "atlanta",
        northeastLat: 33.886823,
        northeastLong: -84.2895601,
        southwestLat: 33.647946,
        southwestLong: -84.550854,
    },
    {
        name: "phoenix",
        northeastLat: 33.9183911,
        northeastLong: -111.9255209,
        southwestLat: 33.29026,
        southwestLong: -112.3240651,
    },
    {
        name: "northern california",
        northeastLat: 42.0095169,
        northeastLong: -115.6483569,
        southwestLat: 35.786579,
        southwestLong: -124.482003,
    },
    {
        name: "north florida",
        northeastLat: 31.000,
        northeastLong: -81.000,
        southwestLat: 29.000,
        southwestLong: -87.500,
    },
    {
        name: "south florida",
        northeastLat: 27.8613621,
        northeastLong: -79.974306,
        southwestLat: 24.396308,
        southwestLong: -82.987477,
    },
    {
        name: "southwest florida",
        northeastLat: 28.200,
        northeastLong: -81.200,
        southwestLat: 25.600,
        southwestLong: -83.000,
    },
    {
        name: "palm beach",
        northeastLat: 26.800000,
        northeastLong: -80.000000,
        southwestLat: 26.560000,
        southwestLong: -80.080000,
    }]

    const city = bounds.find(city => city.name == configuration.city.toLowerCase());


    return (
        location.latitude >= city.southwestLat &&
        location.latitude <= city.northeastLat &&
        location.longitude >= city.southwestLong &&
        location.longitude <= city.northeastLong
    );
}

async function fetchObjectEntries() {
    let filterString = "";
    let search = "";

    // Build filters
    const filters = [];
    if (selectedProduct) {
        filters.push(`keywords/any(k:contains(k,'${selectedProduct}'))`);
    }
    if (selectedState) {
        filters.push(`state eq '${selectedState}'`);
    }

    if (configuration.state) {
        filters.push(`state eq '${configuration.state}'`);
    }

    // Combine filters if any exist
    if (filters.length > 0) {
        filterString = `&filter=${filters.join(' and ')}`;
    }

    // Add search term if provided
    if (currentSearchTerm) {
        search = `&search=${currentSearchTerm}`;
    }


    let distinctKeywords = [];
    let distinctStates = [];

    let page = 1;



    try {
        async function recursiveCallToApi() {
            const url = `${baseUrl}?flatten=true&fields=id,displayPageId,keywords,description,taxonomyCategoryBriefs,isClosedOnSunday,mondayOpen,wednesdayOpen,fridayOpen,thursdayOpen,longitude,tuesdayOpen,fridayClose,saturdayOpen,thursdayClose,isClosedOnSaturday,name,isClosedOnWednesday,latitude,sundayClose,isClosedOnTuesday,saturdayClose,isClosedOnThursday,tuesdayClose,address,mondayClose,isClosedOnMonday,isClosedOnFriday,sundayOpen,wednesdayClose,state,contactInformactionRel,buttonsRel&nestedFields=contactInformactionRel%2CbuttonsRel&page=${page}&pageSize=50${filterString}${search}`;
            const response = await Liferay.Util.fetch(url);
            const data = await response.json();

            if (data) {

                const items = configuration.city != "" ? data.items.filter(location => isLocationInsideBounds(location)) : [...data.items];
                // Extract unique keywords
                distinctKeywords = [...new Set([...distinctKeywords, ...items.flatMap(item => item.keywords)])];
                distinctStates = [...new Set([...distinctStates, ...items.map(item => item.state)])];

                if (page <= data.lastPage) {
                    if (page == 1) {
                        //clean markers
                        markers = []
                        //clean list container
                        locationsListDiv.innerHTML = "";
                        initMap(items);
                    } else {
                        addMarkers(items);
                        fitBounds();
                        setClusterer();
                    }
                    page = data.page + 1;
                    recursiveCallToApi();
                } else {
                    if (isFirstLoad) {
                        initMapFilterProducts(distinctKeywords);
                        initMapFilterStates(distinctStates);
                    }
                    isFirstLoad = false;
                    showNoResultsMessage(items.length > 0);
                }

            }
        }

        recursiveCallToApi();

    } catch (error) {
        console.log(error);
    }
}

initMapInputSearch();
fetchObjectEntries();