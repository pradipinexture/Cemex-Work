const structureId = configuration.structureId || 33884;
const pageSize = configuration.pageSize || "200";
const defaultZoom = parseInt(configuration.defaultZoom || "5");
const defaultCenterCordinates = configuration.defaultCenterCordinates || {"lat": 54.5,"lng": -3.0};
const currentCountry = configuration.country || "United Kingdom";
const defaultUKBounds = configuration.defaultBounds || {"north": 59.478568831926395,"south": 49.82380908513249, "west": -10.8544921875, "east": 2.021484375};
const minimumClusterSize = configuration.minimumClusterSize || "3";
const filterLocally = configuration.enableClientSideFiltering || false;

const baseUrl = `/o/headless-delivery/v1.0/content-structures/${structureId}/structured-contents`;
const neccesaryfieldsFromAPI = "contentFields.name,contentFields.contentFieldValue.data,contentFields.nestedContentFields.name,contentFields.nestedContentFields.contentFieldValue.data,contentFields.nestedContentFields.nestedContentFields.contentFieldValue.data,contentFields.nestedContentFields.nestedContentFields.name,contentFields.contentFieldValue.geo,taxonomyCategoryBriefs,friendlyUrlPath";

// Google Map Pin Color Config
const focusedLocationBackColor = "#D8000E";
const focusedLocationBorderColor = "#FF7373";
const defaultLocationBackColor = "#0003B1";
const defaultLocationBorderColor = "#1697f3";

const contextPathUK = "/web/cemex-uk";
const domainWithContextPath =  location.origin + (location.href.includes(contextPathUK) ? contextPathUK : "") + "/w";

checkGoogleMapsLoaded();

const MarkerClusterer = window.markerClusterer?.MarkerClusterer || window.MarkerClusterer;

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

let map;
let markers = [];
let bounds;
let clusterer;
let currentSearchTerm = "";
let selectedProduct = "";
let selectedRegion = "";
let productCategories = [];
let regionList = [];
let allLocationsData = [];

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

function generateFormattedOpeningHours(data) {
  const entries = [];

  for (let i = 0; i < days.length; i++) {
    const day = days[i];
    const isClosed = data[`isClosedOn${day}`];
    const open = data[`${day.toLowerCase()}Open`] || "";
    const close = data[`${day.toLowerCase()}Close`] || "";

    if (isClosed || (!open && !close)) {
      entries.push({ day, status: closedTrans });
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
    const label = group.status === closedTrans ? closedTrans : `${convertTo12HourFormat(group.status.split(" - ")[0])} - ${convertTo12HourFormat(group.status.split(" - ")[1])}`;
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
      <div class='location-opening-items-title'>
      <span class="op-logo">${getLexiconIcon("time")}</span>
      ${openingHoursTrans}</div><ul>${generateFormattedOpeningHours(location.openingData).map(line => `<li>${line}</li>`).join('')}</ul>
    </div>`;
    innerBody.appendChild(openDiv);
  
    const ctaWrapper = document.createElement("div");
    ctaWrapper.className = "location-cta-wrapper";
    
    const pageLink = document.createElement("a");
    pageLink.className = "b-button-link cta-primary";
    pageLink.href = `${ domainWithContextPath + location.url}`;
    pageLink.target = "_blank";
    pageLink.innerHTML = `<span class='b-button-link__cta-primary__label'>${contactDetailsTrans}</span>`;
    ctaWrapper.appendChild(pageLink);
  
    const direction = document.createElement("a");
    direction.className = "b-button-link cta-primary navigate-button";
    direction.href = `https://google.com/maps/dir//${location.latitude},${location.longitude}`;
    direction.target = "_blank";
    direction.innerHTML = `<span class='b-button-link__cta-primary__label'>${navigateTrans} <span class='new-window-logo'>${getLexiconIcon("shortcut")}</span></span>`;
    ctaWrapper.appendChild(direction);

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

  function getLexiconIcon(iconName) {
    return `<svg aria-hidden="true" class="lexicon-icon lexicon-icon-${iconName}"><use xlink:href="/o/classic-theme/images/clay/icons.svg#${iconName}"></use></svg>`;
  }

function addMarker(location, isActive = false) {
  if (!location.latitude || !location.longitude) return null;

  var pinConfig = {
    background: isActive ? focusedLocationBackColor : defaultLocationBackColor, // red vs blue
    borderColor: isActive ? focusedLocationBorderColor : defaultLocationBorderColor,
    glyphColor: "white"
  }

  const pin = new PinElement(pinConfig);

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
      background: active ? focusedLocationBackColor : defaultLocationBackColor, // red vs blue
      borderColor: active ? focusedLocationBorderColor : defaultLocationBorderColor,
      glyphColor: "white"
    });
    marker.content = newPin.element;
  };

  marker.addListener("click", () => {
    activateMarkerByName(location.name);
    map.panTo(marker.position);
    map.setZoom(15);

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

function activateMarkerByName(nameToActivate) {
  markers.forEach(marker => {
    const isActive = marker._locationName === nameToActivate;
    marker._setActive(isActive);
  });
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
  
  locations.forEach(location => {
    const marker = addMarker(location);
    createLocationItem(location, marker);
  });

  if (markers.length > 0) {
    map.fitBounds(bounds);
  }
  applyClustering();
}
function filterLocations(locations, searchTerm, product, region) {
  return locations.filter(location => {
 
    const searchMatch = !searchTerm || 
      location.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      location.address.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (location.keywords && location.keywords.some(k => k.toLowerCase().includes(searchTerm.toLowerCase())));
    
    const productMatch = !product || 
      (location.taxonomyCategoryIds && location.taxonomyCategoryIds.includes(product));
    
    const regionMatch = !region || location.region === region;
    
    return searchMatch && productMatch && regionMatch;
  });
}

var isRegionInit = false;

async function loadLocations(forceRefresh = false) {
  try {

    let filterString = '';
    if (selectedProduct && !filterLocally) {
      filterString += `&filter=taxonomyCategoryIds/any(x:x eq ${selectedProduct})`;
    }
    if (selectedRegion && !filterLocally) {
      const regionFilter = `contentFields/Region eq '${selectedRegion}'`;
      filterString += filterString ? ` and ${regionFilter}` : `&filter=${regionFilter}`;
    }

    if (forceRefresh || !filterLocally || allLocationsData.length === 0) {
      let currentPage = 1;
      let totalPages = 1;
      allLocationsData = [];
      clearResults();

      do {
        const response = await fetch(`${baseUrl}?fields=${neccesaryfieldsFromAPI}&pageSize=${pageSize}&page=${currentPage}${currentSearchTerm && !filterLocally ? `&search="${currentSearchTerm}"` : ""}${filterString}`, {
          method: 'GET',
          headers: {
            'accept': 'application/json',
            'x-csrf-token': Liferay.authToken
          }
        });

        const result = await response.json();
        const { items = [], lastPage = 1 } = result;
        totalPages = lastPage;
        currentPage++;

        const batchLocations = items.map(item => {
          const contentFields = item.contentFields || [];
          const geoField = contentFields.find(field => field.name === 'Geolocation');
          const latitude = geoField?.contentFieldValue?.geo?.latitude || 0;
          const longitude = geoField?.contentFieldValue?.geo?.longitude || 0;

          const isInUK = latitude >= defaultUKBounds.south &&
                         latitude <= defaultUKBounds.north &&
                         longitude >= defaultUKBounds.west &&
                         longitude <= defaultUKBounds.east;

          if (!isInUK && latitude !== 0 && longitude !== 0) return null;

          const name = contentFields.find(field => field.name === 'LocationName')?.contentFieldValue?.data || '';
          const address = contentFields.find(field => field.name === 'Address')?.contentFieldValue?.data || '';
          const town = contentFields.find(field => field.name === 'TownCity')?.contentFieldValue?.data || '';
          const region = contentFields.find(field => field.name === 'Region')?.contentFieldValue?.data || '';
          const postcode = contentFields.find(field => field.name === 'Postcode')?.contentFieldValue?.data || '';
          const country = contentFields.find(field => field.name === 'Country')?.contentFieldValue?.data || '';
          const fullAddress = [address, town, region, postcode, country].filter(part => part).join(', ');

          const openingData = extractOpeningHoursData(contentFields);
          const phoneNumber = contentFields.find(field => field.name === 'PhoneNumber')?.contentFieldValue?.data || '';
          const description = contentFields.find(field => field.name === 'RichText')?.contentFieldValue?.data || '';
          const keywords = (item.taxonomyCategoryBriefs || []).map(cat => cat.taxonomyCategoryName);

          if (region && !regionList.includes(region)) {
            regionList.push(region);
          }

          return {
            id: item.id,
            name,
            address: fullAddress,
            region,
            latitude,
            longitude,
            phoneNumber,
            description,
            openingData,
            keywords,
            url: item.friendlyUrlPath ? `/${item.friendlyUrlPath}` : '',
            taxonomyCategoryIds: item.taxonomyCategoryBriefs?.map(cat => cat.taxonomyCategoryId) || []
          };
        }).filter(location => location !== null);

        allLocationsData = allLocationsData.concat(batchLocations);

        batchLocations.forEach(location => {
          const marker = addMarker(location);
          createLocationItem(location, marker);
        });
        applyClustering();
        

      } while (currentPage <= totalPages);

      if (productCategories.length === 0 && allLocationsData.length > 0) {
        const categories = [];
        allLocationsData.forEach(loc => {
          (loc.taxonomyCategoryIds || []).forEach(id => {
            const name = loc.keywords.find(k => k); 
            if (name && !categories.some(c => c.id === id)) {
              categories.push({ id, name });
            }
          });
        });
        productCategories = categories;
        initProductFilter(categories);
      }

      if (regionList.length > 0 && !isRegionInit) {
        isRegionInit = true;
        initRegionFilter(regionList.sort());
      }

      if (allLocationsData.length === 0) {
        showNoResultsMessage(true);
      }
      zoomToFitAllMarkers()
      return;
    }

    if (filterLocally) {
      const filteredLocations = filterLocations(
        allLocationsData,
        currentSearchTerm,
        selectedProduct,
        selectedRegion
      );
      displayLocations(filteredLocations);
      zoomToFitAllMarkers()
    }

  } catch (error) {
    console.error("Error loading locations:", error);
    //showNoResultsMessage(true);
  }
}

function zoomToFitAllMarkers() {
  if (markers.length === 0) return;

  bounds = new google.maps.LatLngBounds();
  markers.forEach(marker => bounds.extend(marker.position));

  map.fitBounds(bounds, {
    padding: { top: 25, bottom: 25, left: 10, right: 10 }
  });
}


function initProductFilter(categories) {
  if (!categories || categories.length === 0) {
    return;
  }
  

  while (productFilterContainer.children.length > 1) {
    productFilterContainer.removeChild(productFilterContainer.lastChild);
  }
  
  categories.forEach(category => {
    const option = document.createElement('div');
    option.className = 'radio';
    option.setAttribute('aria-label', category.name);
    option.textContent = category.name;
    option.dataset.categoryId = category.id;
    
    option.addEventListener('click', () => {

      selectedProduct = category.id;
      
      const label = productFilterBtn.querySelector('.map-search__filter_selected-product');
      label.textContent = category.name;
      
      productFilterOptions.classList.add('d-none');
      
      productFilterContainer.querySelectorAll('.radio').forEach(el => {
        el.classList.remove('selected');
      });
      option.classList.add('selected');
      
      loadLocations();
    });
    
    productFilterContainer.appendChild(option);
  });
  
  productFilterBtn.addEventListener('click', () => {
    productFilterOptions.classList.toggle('d-none');
  });
  
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
  
  const closeBtn = productFilterOptions.querySelector('.close-btn');
  closeBtn.addEventListener('click', () => {
    productFilterOptions.classList.add('d-none');
  });
  
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
  
  while (stateFilterContainer.children.length > 1) {
    stateFilterContainer.removeChild(stateFilterContainer.lastChild);
  }
  
  regions.forEach(region => {
    const option = document.createElement('div');
    option.className = 'radio';
    option.setAttribute('aria-label', region);
    option.textContent = region;
    
    option.addEventListener('click', () => {
      selectedRegion = region;
      
      const label = stateFilterBtn.querySelector('.map-search__filter_selected-product');
      label.textContent = region;
      
      stateFilterOptions.classList.add('d-none');
      
      stateFilterContainer.querySelectorAll('.radio').forEach(el => {
        el.classList.remove('selected');
      });
      option.classList.add('selected');
      
      loadLocations();
    });
    
    stateFilterContainer.appendChild(option);
  });
  
  stateFilterBtn.addEventListener('click', () => {
    stateFilterOptions.classList.toggle('d-none');
  });
  
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
  
  const closeBtn = stateFilterOptions.querySelector('.close-btn');
  closeBtn.addEventListener('click', () => {
    stateFilterOptions.classList.add('d-none');
  });
  
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

function checkGoogleMapsLoaded() {
  (window.google && window.google.maps && window.google.maps.importLibrary) ? initMap() : setTimeout(checkGoogleMapsLoaded, 100);

}

async function initMap() {
  try {
    const { Map } = await google.maps.importLibrary("maps");
    const { AdvancedMarkerElement, PinElement }  = await google.maps.importLibrary("marker");
    
    
    window.AdvancedMarkerElement = AdvancedMarkerElement;
    window.PinElement = PinElement;
    
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
  
  } catch (error) {
    console.error("Error initializing map:", error);
  }
}