// Simplified implementation for Location Map Search using Web Content API


const { Map } = await google.maps.importLibrary("maps");
const { AdvancedMarkerElement, PinElement } = await google.maps.importLibrary("marker");
const MarkerClusterer = window.markerClusterer?.MarkerClusterer || window.MarkerClusterer;
// Configuration - adjust these based on your environment
const structureId = configuration.structureId || 33884;
const pageSize = configuration.pageSize || "200";
const defaultZoom = parseInt(configuration.defaultZoom || "5");
const defaultCenterCordinates = configuration.defaultCenterCordinates || {"lat": 54.5,"lng": -3.0};
const currentCountry = configuration.country || "United Kingdom";
const defaultUKBounds = configuration.defaultBounds || {"north": 59.478568831926395,"south": 49.82380908513249, "west": -10.8544921875, "east": 2.021484375};
const minimumClusterSize = configuration.minimumClusterSize || "3";
const filterLocally = configuration.filterLocally || true;


const baseUrl = `/o/headless-delivery/v1.0/content-structures/${structureId}/structured-contents`;
const neccesaryfieldsFromAPI = "contentFields.name,contentFields.contentFieldValue.data,contentFields.nestedContentFields.name,contentFields.nestedContentFields.contentFieldValue.data,contentFields.nestedContentFields.nestedContentFields.contentFieldValue.data,contentFields.nestedContentFields.nestedContentFields.name,contentFields.contentFieldValue.geo,taxonomyCategoryBriefs,friendlyUrlPath";

const domainWithContextPath =  "http://localhost:8080/en-GB/web/cemex-uk/w";

// DOM elements
const locationsListDiv = fragmentElement.querySelector("#locations-list #map-search__results .accordion>div");
const searchInput = fragmentElement.querySelector(`#search-${fragmentEntryLinkNamespace}`);
const searchButton = fragmentElement.querySelector(`#btn-search-${fragmentEntryLinkNamespace}`);
const noResultsElement = fragmentElement.querySelector(`#no-results`);
const productFilterBtn = fragmentElement.querySelector('#product-filter-container .accordion__title');
const stateFilterBtn = fragmentElement.querySelector('#state-filter-container .accordion__title');
const productFilterOptions = fragmentElement.querySelector('#product-filter-container .accordion__body');
const stateFilterOptions = fragmentElement.querySelector('#state-filter-container .accordion__body');
const productFilterContainer = fragmentElement.querySelector('#product-filter-container .search-filter-form');
const stateFilterContainer = fragmentElement.querySelector('#state-filter-container .search-filter-form');

// State variables
let map;
let markers = [];
let bounds;
let clusterer;
let currentSearchTerm = "";
let selectedProduct = "";
let selectedRegion = "";
let productCategories = [];
let regionList = [];
let allLocationsData = []; // Store all locations for local filtering

function convertTo12HourFormat(time24) {
    if (!time24 || !/\d{2}:\d{2}/.test(time24)) return "";
    const [hours, minutes] = time24.split(":").map(Number);
    const period = hours >= 12 ? "PM" : "AM";
    const hours12 = hours % 12 || 12;
    return `${hours12}:${String(minutes).padStart(2, '0')} ${period}`;
  }
  
  function extractOpeningHoursData(contentFields) {
    const openingHoursFields = contentFields.filter(field => field.name === 'OpeningHours');
    const openingData = {};
    openingHoursFields.forEach(hourField => {
      const nestedFields = hourField.nestedContentFields || [];
      const dayName = nestedFields.find(f => f.name === 'DayName')?.contentFieldValue?.data || '';
      if (!dayName) return;
      const isClosed = nestedFields.find(f => f.name === 'isClosed')?.contentFieldValue?.data === 'true';
      openingData[`isClosedOn${dayName}`] = isClosed;
      const dayTimesField = nestedFields.find(f => f.name === 'Fieldset54865370');
      if (dayTimesField) {
        const timeFields = dayTimesField.nestedContentFields || [];
        const openTime = timeFields.find(f => f.name === 'Open')?.contentFieldValue?.data || '';
        const closeTime = timeFields.find(f => f.name === 'Close')?.contentFieldValue?.data || '';
        openingData[`${dayName.toLowerCase()}Open`] = openTime;
        openingData[`${dayName.toLowerCase()}Close`] = closeTime;
      }
    });
    return openingData;
  }


function getStatusForDay(data) {
  if (!data) return "";
  
  const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  const now = new Date();
  const currentDay = days[now.getDay()];
  const currentTime = now.toTimeString().split(" ")[0];

  const openKey = `${currentDay.toLowerCase()}Open`;
  const closeKey = `${currentDay.toLowerCase()}Close`;
  const closedKey = `isClosedOn${currentDay}`;

  const openTime = data[openKey];
  const closeTime = data[closeKey];
  const isClosed = data[closedKey];

  if (isClosed) {
    let nextDay = (now.getDay() + 1) % 7;
    let attempts = 0;
    while (attempts < 7) {
      const nextDayName = days[nextDay];
      const nextOpenKey = `${nextDayName.toLowerCase()}Open`;
      const nextIsClosedKey = `isClosedOn${nextDayName}`;
      if (!data[nextIsClosedKey] && data[nextOpenKey]) {
        return `<span class='opening-label-closed'>Closed</span><span class='opening-dot'>.</span><span class='opening-info'>Opens ${convertTo12HourFormat(data[nextOpenKey])} ${nextDayName}</span>`;
      }
      nextDay = (nextDay + 1) % 7;
      attempts++;
    }
    return `<span class='opening-label-closed'>Closed</span><span class='opening-dot'>.</span><span class='opening-info'>indefinitely</span>`;
  } else {
    if (currentTime >= openTime && (!closeTime || currentTime < closeTime)) {
      return `<span class='opening-label-open'>Open</span><span class='opening-dot'>.</span><span class='opening-info'>Closes ${convertTo12HourFormat(closeTime) || "later today"}</span>`;
    } else if (currentTime < openTime) {
      return `<span class='opening-label-closed'>Closed</span><span class='opening-dot'>.</span><span class='opening-info'>Opens ${convertTo12HourFormat(openTime)} today</span>`;
    } else {
      let nextDay = (now.getDay() + 1) % 7;
      let attempts = 0;
      while (attempts < 7) {
        const nextDayName = days[nextDay];
        const nextOpenKey = `${nextDayName.toLowerCase()}Open`;
        const nextIsClosedKey = `isClosedOn${nextDayName}`;
        if (!data[nextIsClosedKey] && data[nextOpenKey]) {
          return `<span class='opening-label-closed'>Closed</span><span class='opening-dot'>.</span><span class='opening-info'>Opens ${convertTo12HourFormat(data[nextOpenKey])} ${nextDayName}</span>`;
        }
        nextDay = (nextDay + 1) % 7;
        attempts++;
      }
      return `<span class='opening-label-closed'>Closed</span><span class='opening-dot'>.</span><span class='opening-info'>indefinitely</span>`;
    }
  }
}
function generateFormattedOpeningHours(data) {
    const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    const entries = [];
  
    for (let i = 0; i < days.length; i++) {
      const day = days[i];
      const isClosed = data[`isClosedOn${day}`];
      const open = data[`${day.toLowerCase()}Open`] || "";
      const close = data[`${day.toLowerCase()}Close`] || "";
  
      if (isClosed || (!open && !close)) {
        entries.push({ day, status: "Closed" });
      } else {
        entries.push({ day, status: `${open} - ${close}` });
      }
    }
  
    // Group by hours
    const grouped = [];
    let current = null;
  
    entries.forEach((entry, i) => {
      if (!current) {
        current = { from: entry.day, to: entry.day, status: entry.status };
      } else if (entry.status === current.status) {
        current.to = entry.day;
      } else {
        grouped.push({ ...current });
        current = { from: entry.day, to: entry.day, status: entry.status };
      }
    });
    if (current) grouped.push(current);
  
    return grouped.map(group => {
      const dayLabel = group.from === group.to ? group.from : `${group.from} - ${group.to}`;
      const label = group.status === "Closed" ? "Closed" : `${convertTo12HourFormat(group.status.split(" - ")[0])} - ${convertTo12HourFormat(group.status.split(" - ")[1])}`;
      return `${dayLabel}: ${label}`;
    });
  }
  
function createLocationItem(location, marker) {
    const item = document.createElement("div");
    item.className = "accordion__item accordion__item_collapsed";
  
    const title = document.createElement("div");
    title.className = "accordion__title";
    title.innerHTML = `
      <div class='location__header'>
        <div class='location__excerpt'>
          <div class='u-position-relative'>
            <h4>${location.name}</h4>
            <div class="accordion__arrow" role="presentation"></div>
          </div>
          <div class='location__address'>${location.address}</div>
          ${location.keywords?.length ? `<div class="product-tags">${location.keywords.map(k => `<div class="product-tags-item">${k}</div>`).join('')}</div>` : ''}
        </div>
      </div>`;
  
    const body = document.createElement("div");
    body.className = "accordion__body d-none";
    const innerBody = document.createElement("div");
    innerBody.className = "location__body";
  
    // Opening hours section
    const openDiv = document.createElement("div");
    openDiv.className = "opening-hours";
    openDiv.innerHTML = `<div class='location-opening-items'>
      Opening hours<ul>${generateFormattedOpeningHours(location.openingData).map(line => `<li>${line}</li>`).join('')}</ul>
    </div>`;
    innerBody.appendChild(openDiv);
  
    const ctaWrapper = document.createElement("div");
    ctaWrapper.className = "location-cta-wrapper";
  
    const direction = document.createElement("a");
    direction.className = "b-button-link cta-primary";
    direction.href = `https://google.com/maps/dir//${location.latitude},${location.longitude}`;
    direction.target = "_blank";
    direction.innerHTML = `<span class='b-button-link__cta-primary__label'>Navigate</span>`;
    ctaWrapper.appendChild(direction);
  
    const pageLink = document.createElement("a");
    pageLink.className = "b-button-link cta-primary";
    pageLink.href = `${ domainWithContextPath + location.url}`;
    pageLink.target = "_blank";
    pageLink.innerHTML = `<span class='b-button-link__cta-primary__label'>Contact details</span>`;
    ctaWrapper.appendChild(pageLink);
  
    innerBody.appendChild(ctaWrapper);
    body.appendChild(innerBody);
    item.appendChild(title);
    item.appendChild(body);
  
    title.addEventListener('click', () => {
      const isOpen = !body.classList.contains('d-none');
      body.classList.toggle('d-none');
    
      if (!isOpen) {
        // Expand → activate marker
        activateMarkerByName(location.name);
        const marker = markers.find(m => m._locationName === location.name);
        if (marker) {
          map.panTo(marker.position);
          map.setZoom(15);
        }
      } else {
        // Collapse → reset all markers to blue
        markers.forEach(marker => marker._setActive(false));
        bounds = new google.maps.LatLngBounds();
        markers.forEach(m => bounds.extend(m.position));
        map.fitBounds(bounds);
      }
    });
    
    
    locationsListDiv.appendChild(item);
    return item;
  }

function activateMarkerByName(nameToActivate) {
  markers.forEach(marker => {
    const isActive = marker._locationName === nameToActivate;
    marker._setActive(isActive);
  });
}  

function addMarker(location, isActive = false) {
  if (!location.latitude || !location.longitude) return null;

  const pin = new PinElement({
    background: isActive ? "#D8000E" : "#0003B1", // red vs blue
    borderColor: isActive ? "#FF7373" : "#1697f3",
    glyphColor: "white"
  });

  const pos = { lat: location.latitude, lng: location.longitude };
  const marker = new AdvancedMarkerElement({
    map,
    position: pos,
    title: location.name,
    content: pin.element
  });

  marker._locationName = location.name; // attach reference to match later
  marker._setActive = (active) => {
    const newPin = new PinElement({
      background: active ? "#D8000E" : "#0003B1",
      borderColor: active ? "#FF7373" : "#1697f3",
      glyphColor: "white"
    });
    marker.content = newPin.element;
  };

  marker.addListener("click", () => {
    activateMarkerByName(location.name);
    map.panTo(marker.position);
    map.setZoom(15);

    // Expand corresponding accordion
    const items = locationsListDiv.querySelectorAll('.accordion__item');
    items.forEach(item => {
      const title = item.querySelector('h4');
      const body = item.querySelector('.accordion__body');
      if (title && title.textContent === location.name) {
        body.classList.remove('d-none');
        item.scrollIntoView({ behavior: 'smooth', block: 'center' });
      } else {
        body.classList.add('d-none');
      }
    });
  });

  markers.push(marker);
  bounds.extend(pos);

  return marker;
}

function showNoResultsMessage(show) {
  noResultsElement.classList.toggle("d-none", !show);
}

function clearResults() {
  locationsListDiv.innerHTML = "";
  markers.forEach(m => m.map = null);
  markers = [];
  bounds = new google.maps.LatLngBounds();
  if (clusterer) clusterer.clearMarkers();
}

function applyClustering() {
    if (clusterer) clusterer.clearMarkers();
    clusterer = new MarkerClusterer({
      map: map,
      markers: markers,
      algorithm: new markerClusterer.SuperClusterAlgorithm({ minPoints: minimumClusterSize })
  });
}  
function displayLocations(locations) {
  clearResults();
  
  if (locations.length === 0) {
    showNoResultsMessage(true);
    return;
  }

  showNoResultsMessage(false);
  
  // Add locations to map and list
  locations.forEach(location => {
    const marker = addMarker(location);
    createLocationItem(location, marker);
  });

  // Fit map to markers
  if (markers.length > 0) {
    map.fitBounds(bounds);
  }
  applyClustering();
}
function filterLocations(locations, searchTerm, product, region) {
  return locations.filter(location => {
    // Filter by search term
    const searchMatch = !searchTerm || 
      location.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      location.address.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (location.keywords && location.keywords.some(k => k.toLowerCase().includes(searchTerm.toLowerCase())));
    
    // Filter by product
    const productMatch = !product || 
      (location.taxonomyCategoryIds && location.taxonomyCategoryIds.includes(product));
    
    // Filter by region
    const regionMatch = !region || location.region === region;
    
    return searchMatch && productMatch && regionMatch;
  });
}
var isRegionInit = false;

const distanceUnit = "mi"; // change to "mi" if needed
const defaultSearchQuery = configuration.defaultSearchQuery || currentCountry;

function getDistanceFromLatLonInKm(lat1, lon1, lat2, lon2) {
  const R = distanceUnit === "mi" ? 3958.8 : 6371; // Radius of earth in miles or km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c; // Distance
}

async function getPlaceGeometry(query) {
  return new Promise((resolve, reject) => {
    const service = new google.maps.places.PlacesService(map);
    const request = {
      query,
      fields: ["geometry"]
    };
    service.findPlaceFromQuery(request, (results, status) => {
      if (status === google.maps.places.PlacesServiceStatus.OK && results.length > 0) {
        const center = results[0].geometry.location;
        resolve({ lat: center.lat(), lng: center.lng() });
      } else {
        reject("No geometry found for the query");
      }
    });
  });
}

async function loadLocations(centerQuery = defaultSearchQuery) {
  try {
    const response = await fetch(`${baseUrl}?fields=${neccesaryfieldsFromAPI}&pageSize=${pageSize}`, {
      method: 'GET',
      headers: {
        'accept': 'application/json',
        'x-csrf-token': Liferay.authToken
      }
    });

    const { items = [] } = await response.json();

    allLocationsData = items.map(item => {
      const contentFields = item.contentFields || [];
      const geoField = contentFields.find(field => field.name === 'Geolocation');
      const latitude = geoField?.contentFieldValue?.geo?.latitude || 0;
      const longitude = geoField?.contentFieldValue?.geo?.longitude || 0;
      const name = contentFields.find(field => field.name === 'LocationName')?.contentFieldValue?.data || '';
      const address = contentFields.find(field => field.name === 'Address')?.contentFieldValue?.data || '';
      const town = contentFields.find(field => field.name === 'TownCity')?.contentFieldValue?.data || '';
      const region = contentFields.find(field => field.name === 'Region')?.contentFieldValue?.data || '';
      const postcode = contentFields.find(field => field.name === 'Postcode')?.contentFieldValue?.data || '';
      const country = contentFields.find(field => field.name === 'Country')?.contentFieldValue?.data || '';
      const fullAddress = [address, town, region, postcode, country].filter(Boolean).join(', ');
      const openingData = extractOpeningHoursData(contentFields);
      const keywords = (item.taxonomyCategoryBriefs || []).map(cat => cat.taxonomyCategoryName);

      return {
        id: item.id,
        name,
        address: fullAddress,
        region,
        latitude,
        longitude,
        openingData,
        keywords,
        url: item.friendlyUrlPath ? `/${item.friendlyUrlPath}` : '',
        taxonomyCategoryIds: item.taxonomyCategoryBriefs?.map(cat => cat.taxonomyCategoryId) || []
      };
    }).filter(loc => loc.latitude && loc.longitude);
    console.log(allLocationsData)
    if (centerQuery) {
      try {
        const { lat, lng } = await getPlaceGeometry(centerQuery);
        applyProximityFilter(lat, lng);
      } catch (geoErr) {
        console.warn("Fallback to full list due to search error:", geoErr);
        displayLocations(allLocationsData);
      }
    } else {
      displayLocations(allLocationsData);
    }
  } catch (err) {
    console.error("Error loading locations:", err);
    showNoResultsMessage(true);
  }
}

function applyProximityFilter(centerLat, centerLng) {
  const filtered = allLocationsData
    .map(location => {
      const distance = getDistanceFromLatLonInKm(centerLat, centerLng, location.latitude, location.longitude);
      return { ...location, distance };
    })
    .filter(location => location.distance <= 100)
    .sort((a, b) => a.distance - b.distance);

  filtered.forEach(location => {
    location.name = `${location.name} (${location.distance.toFixed(1)} ${distanceUnit})`;
  });

  displayLocations(filtered);
}

searchButton.addEventListener("click", async () => {
  const searchTerm = searchInput.value.trim();
  currentSearchTerm = searchTerm;
  await loadLocations(searchTerm);
});

// Modify search button click to use Places API and filter locations
// searchButton.addEventListener("click", async () => {
//   const searchTerm = searchInput.value.trim();
//   currentSearchTerm = searchTerm;

//   if (!searchTerm) {
//     simulateInitialSearch(defaultSearchQuery);
//     return;
//   }

//   const service = new google.maps.places.PlacesService(map);
//   const request = {
//     query: searchTerm,
//     fields: ["geometry"],
//   };

//   service.findPlaceFromQuery(request, (results, status) => {
//     if (status === google.maps.places.PlacesServiceStatus.OK && results.length > 0) {
//       const center = results[0].geometry.location;
//       applyProximityFilter(center.lat(), center.lng());
//     } else {
//       showNoResultsMessage(true);
//     }
//   });
// });

// searchButton.addEventListener("click", () => {
//   const searchTerm = searchInput.value.trim();
//   currentSearchTerm = searchTerm;
//   loadLocations(searchTerm); 
// });

// Update initMap to trigger simulated default search
async function initMap() {
  bounds = new google.maps.LatLngBounds();
  map = new Map(fragmentElement.querySelector("#map"), {
    zoom: defaultZoom,
    center: defaultCenterCordinates,
    mapId: "LOCATIONS_MAP",
    streetViewControl: false,
    mapTypeControl: false,
  });

  initMapSearch();
  await loadLocations();
}


// Modify search button click to use Places API and filter locations
searchButton.addEventListener("click", async () => {
  const searchTerm = searchInput.value.trim();
  currentSearchTerm = searchTerm;

  if (!searchTerm) {
    loadLocations();
    return;
  }

  const service = new google.maps.places.PlacesService(map);
  const request = {
    query: searchTerm,
    fields: ["geometry"],
  };

  service.findPlaceFromQuery(request, (results, status) => {
    if (status === google.maps.places.PlacesServiceStatus.OK && results.length > 0) {
      const center = results[0].geometry.location;
      const centerLat = center.lat();
      const centerLng = center.lng();

      const filtered = allLocationsData
        .map(location => {
          const distance = getDistanceFromLatLonInKm(centerLat, centerLng, location.latitude, location.longitude);
          return { ...location, distance };
        })
        .filter(location => location.distance <= 100)
        .sort((a, b) => a.distance - b.distance);

      filtered.forEach(location => {
        location.name = `${location.name} (${location.distance.toFixed(1)} ${distanceUnit})`;
      });

      displayLocations(filtered);
    } else {
      showNoResultsMessage(true);
    }
  });
});

function initProductFilter(categories) {
  if (!categories || categories.length === 0) {
    return;
  }
  
  // Clear existing options
  while (productFilterContainer.children.length > 1) {
    productFilterContainer.removeChild(productFilterContainer.lastChild);
  }
  
  // Add product options
  categories.forEach(category => {
    const option = document.createElement('div');
    option.className = 'radio';
    option.setAttribute('aria-label', category.name);
    option.textContent = category.name;
    option.dataset.categoryId = category.id;
    
    option.addEventListener('click', () => {
      // Update selected product
      selectedProduct = category.id;
      
      // Update filter label
      const label = productFilterBtn.querySelector('.map-search__filter_selected-product');
      label.textContent = category.name;
      
      // Hide filter options
      productFilterOptions.classList.add('d-none');
      
      // Update selected class
      productFilterContainer.querySelectorAll('.radio').forEach(el => {
        el.classList.remove('selected');
      });
      option.classList.add('selected');
      
      // Reload locations with new filter
      loadLocations();
    });
    
    productFilterContainer.appendChild(option);
  });
  
  // Set up filter toggle
  productFilterBtn.addEventListener('click', () => {
    productFilterOptions.classList.toggle('d-none');
  });
  
  // Set up "All" option
  const allOption = productFilterContainer.querySelector('.radio[aria-label="All"]');
  allOption.addEventListener('click', () => {
    selectedProduct = '';
    const label = productFilterBtn.querySelector('.map-search__filter_selected-product');
    label.textContent = 'All';
    productFilterOptions.classList.add('d-none');
    
    productFilterContainer.querySelectorAll('.radio').forEach(el => {
      el.classList.remove('selected');
    });
    allOption.classList.add('selected');
    
    loadLocations();
  });
  
  // Set up close button
  const closeBtn = productFilterOptions.querySelector('.close-btn');
  closeBtn.addEventListener('click', () => {
    productFilterOptions.classList.add('d-none');
  });
  
  // Close on outside click
  document.addEventListener('click', (event) => {
    if (!productFilterBtn.contains(event.target) && !productFilterOptions.contains(event.target)) {
      productFilterOptions.classList.add('d-none');
    }
  });
}

function initRegionFilter(regions) {
  if (!regions || regions.length === 0) {
    return;
  }
  
  // Clear existing options
  while (stateFilterContainer.children.length > 1) {
    stateFilterContainer.removeChild(stateFilterContainer.lastChild);
  }
  
  // Add region options
  regions.forEach(region => {
    const option = document.createElement('div');
    option.className = 'radio';
    option.setAttribute('aria-label', region);
    option.textContent = region;
    
    option.addEventListener('click', () => {
      // Update selected region
      selectedRegion = region;
      
      // Update filter label
      const label = stateFilterBtn.querySelector('.map-search__filter_selected-product');
      label.textContent = region;
      
      // Hide filter options
      stateFilterOptions.classList.add('d-none');
      
      // Update selected class
      stateFilterContainer.querySelectorAll('.radio').forEach(el => {
        el.classList.remove('selected');
      });
      option.classList.add('selected');
      
      // Reload locations with new filter
      loadLocations();
    });
    
    stateFilterContainer.appendChild(option);
  });
  
  // Set up filter toggle
  stateFilterBtn.addEventListener('click', () => {
    stateFilterOptions.classList.toggle('d-none');
  });
  
  // Set up "All" option
  const allOption = stateFilterContainer.querySelector('.radio[aria-label="All"]');
  allOption.addEventListener('click', () => {
    selectedRegion = '';
    const label = stateFilterBtn.querySelector('.map-search__filter_selected-product');
    label.textContent = 'All';
    stateFilterOptions.classList.add('d-none');
    
    stateFilterContainer.querySelectorAll('.radio').forEach(el => {
      el.classList.remove('selected');
    });
    allOption.classList.add('selected');
    
    loadLocations();
  });
  
  // Set up close button
  const closeBtn = stateFilterOptions.querySelector('.close-btn');
  closeBtn.addEventListener('click', () => {
    stateFilterOptions.classList.add('d-none');
  });
  
  // Close on outside click
  document.addEventListener('click', (event) => {
    if (!stateFilterBtn.contains(event.target) && !stateFilterOptions.contains(event.target)) {
      stateFilterOptions.classList.add('d-none');
    }
  });
}

function initMapSearch() {
  searchButton.addEventListener("click", () => {
    currentSearchTerm = searchInput.value.trim();
    loadLocations();
  });
  
  searchInput.addEventListener("keypress", (e) => {
    if (e.key === "Enter") {
      currentSearchTerm = searchInput.value.trim();
      loadLocations();
    }
  });
}

// Start the application
initMap();