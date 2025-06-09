/**
 * Location Map Search
 * A comprehensive map search component for finding and filtering locations
 */

// Configuration
const CONFIG = {
    apiKey: 'YOUR_API_KEY',
    structureId: '12345', // Replace with your actual structure ID
    pageSize: 100,
    mapCenter: { lat: 51.509865, lng: -0.118092 }, // London
    baseUrl: '/o/headless-delivery/v1.0/content-structures/',
    fieldsToFetch: 'contentFields.name,contentFields.contentFieldValue.data,contentFields.nestedContentFields.name,contentFields.nestedContentFields.contentFieldValue.data,contentFields.nestedContentFields.nestedContentFields.contentFieldValue.data,contentFields.nestedContentFields.nestedContentFields.name,contentFields.contentFieldValue.geo,taxonomyCategoryBriefs,friendlyUrlPath',
    domainWithContextPath: 'http://localhost:8080/en-GB/web/cemex-uk/w'
  };
  
  // State Management
  const state = {
    map: null,
    markers: [],
    bounds: null,
    clusterer: null,
    searchTerm: '',
    selectedProduct: '',
    selectedRegion: '',
    products: [],
    regions: [],
    locations: []
  };
  
  // DOM Elements
  let elements = {};
  
  /**
   * Initialize the application
   */
  async function init() {
    cacheElements();
    attachEventListeners();
    await initMap();
    await fetchLocations();
  }
  
  /**
   * Cache DOM elements for faster access
   */
  function cacheElements() {
    elements = {
      searchInput: document.getElementById('search-input'),
      searchButton: document.getElementById('search-button'),
      productFilter: document.getElementById('product-filter'),
      regionFilter: document.getElementById('region-filter'),
      selectedProduct: document.getElementById('selected-product'),
      selectedRegion: document.getElementById('selected-region'),
      locationResults: document.getElementById('location-results'),
      noResults: document.getElementById('no-results'),
      mapContainer: document.getElementById('map-container')
    };
  }
  
  /**
   * Attach event listeners to interactive elements
   */
  function attachEventListeners() {
    // Search functionality
    elements.searchButton.addEventListener('click', handleSearch);
    elements.searchInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') handleSearch();
    });
    
    // Filter dropdowns
    elements.productFilter.querySelector('.filter-button').addEventListener('click', (e) => {
      toggleDropdown(elements.productFilter);
      e.stopPropagation();
    });
    
    elements.regionFilter.querySelector('.filter-button').addEventListener('click', (e) => {
      toggleDropdown(elements.regionFilter);
      e.stopPropagation();
    });
    
    // Close dropdowns when clicking outside
    document.addEventListener('click', () => {
      elements.productFilter.classList.remove('open');
      elements.regionFilter.classList.remove('open');
    });
  }
  
  /**
   * Toggle dropdown display
   */
  function toggleDropdown(dropdown) {
    dropdown.classList.toggle('open');
  }
  
  /**
   * Handle search button click
   */
  function handleSearch() {
    state.searchTerm = elements.searchInput.value.trim();
    fetchLocations();
  }
  
  /**
   * Initialize Google Map
   */
  async function initMap() {
    const { Map } = await google.maps.importLibrary("maps");
    const { AdvancedMarkerElement, PinElement } = await google.maps.importLibrary("marker");
    
    state.bounds = new google.maps.LatLngBounds();
    state.map = new Map(elements.mapContainer, {
      zoom: 5,
      center: CONFIG.mapCenter,
      mapId: "LOCATIONS_MAP",
      streetViewControl: false,
      mapTypeControl: false,
      fullscreenControl: false,
      zoomControlOptions: {
        position: google.maps.ControlPosition.RIGHT_BOTTOM
      }
    });
  }
  
  /**
   * Fetch locations from API
   */
  async function fetchLocations() {
    try {
      // Clear existing results
      clearResults();
      
      // Build filter string
      let filterString = '';
      
      if (state.selectedProduct) {
        filterString += `&filter=taxonomyCategoryIds/any(x:x eq ${state.selectedProduct})`;
      }
      
      if (state.selectedRegion) {
        const regionFilter = `contentFields/Region eq '${state.selectedRegion}'`;
        filterString += filterString ? ` and ${regionFilter}` : `&filter=${regionFilter}`;
      }
      
      // Construct API URL
      const apiUrl = `${CONFIG.baseUrl}${CONFIG.structureId}/structured-contents?fields=${CONFIG.fieldsToFetch}&pageSize=${CONFIG.pageSize}${state.searchTerm ? `&search="${state.searchTerm}"` : ''}${filterString}`;
      
      // Make API request
      const response = await fetch(apiUrl, {
        method: 'GET',
        headers: {
          'accept': 'application/json',
          'x-csrf-token': Liferay?.authToken || ''
        }
      });
      
      const { items = [] } = await response.json();
      
      if (items.length === 0) {
        showNoResults(true);
        return;
      }
      
      showNoResults(false);
      
      // Process locations
      const locations = processLocationData(items);
      state.locations = locations;
      
      // Render locations on map and in list
      renderLocations(locations);
      
      // Apply marker clustering
      applyMarkerClustering();
      
      // Initialize filters if first load
      if (state.products.length === 0) {
        initProductFilter(extractProducts(items));
      }
      
      if (state.regions.length === 0) {
        initRegionFilter(extractRegions(locations));
      }
      
      // Fit map to markers
      if (state.markers.length > 0) {
        state.map.fitBounds(state.bounds);
      }
    } catch (error) {
      console.error("Error fetching locations:", error);
      showNoResults(true);
    }
  }
  
  /**
   * Process raw location data from API
   */
  function processLocationData(items) {
    return items.map(item => {
      const contentFields = item.contentFields || [];
      
      // Find geo coordinates
      const geoField = contentFields.find(field => field.name === 'Geolocation');
      const latitude = geoField?.contentFieldValue?.geo?.latitude || 0;
      const longitude = geoField?.contentFieldValue?.geo?.longitude || 0;
      
      // Extract basic fields
      const name = contentFields.find(field => field.name === 'LocationName')?.contentFieldValue?.data || '';
      const address = contentFields.find(field => field.name === 'Address')?.contentFieldValue?.data || '';
      const town = contentFields.find(field => field.name === 'TownCity')?.contentFieldValue?.data || '';
      const region = contentFields.find(field => field.name === 'Region')?.contentFieldValue?.data || '';
      const postcode = contentFields.find(field => field.name === 'Postcode')?.contentFieldValue?.data || '';
      const country = contentFields.find(field => field.name === 'Country')?.contentFieldValue?.data || '';
      
      // Combine address parts
      const fullAddress = [address, town, region, postcode, country].filter(part => part).join(', ');
      
      // Extract opening hours data
      const openingData = extractOpeningHoursData(contentFields);
      
      // Phone number
      const phoneNumber = contentFields.find(field => field.name === 'PhoneNumber')?.contentFieldValue?.data || '';
      
      // Description 
      const description = contentFields.find(field => field.name === 'RichText')?.contentFieldValue?.data || '';
      
      // Extract categories
      const keywords = (item.taxonomyCategoryBriefs || []).map(cat => cat.taxonomyCategoryName);
      
      // Return location object
      return {
        id: item.id,
        name,
        address: fullAddress,
        region,
        latitude: parseFloat(latitude),
        longitude: parseFloat(longitude),
        phoneNumber,
        description,
        openingData,
        keywords,
        url: item.friendlyUrlPath ? `/${item.friendlyUrlPath}` : '',
        taxonomyCategoryIds: item.taxonomyCategoryBriefs?.map(cat => cat.taxonomyCategoryId) || []
      };
    });
  }
  
  /**
   * Extract opening hours data from content fields
   */
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
  
  /**
   * Get current opening status
   */
  function getLocationStatus(openingData) {
    if (!openingData) return { isOpen: false, message: "Hours not available" };
    
    const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    const now = new Date();
    const currentDay = days[now.getDay()];
    const currentTime = now.toTimeString().split(" ")[0];
    
    const openKey = `${currentDay.toLowerCase()}Open`;
    const closeKey = `${currentDay.toLowerCase()}Close`;
    const closedKey = `isClosedOn${currentDay}`;
    
    const openTime = openingData[openKey];
    const closeTime = openingData[closeKey];
    const isClosed = openingData[closedKey];
    
    if (isClosed) {
      // Find next open day
      let nextDay = (now.getDay() + 1) % 7;
      let attempts = 0;
      
      while (attempts < 7) {
        const nextDayName = days[nextDay];
        const nextOpenKey = `${nextDayName.toLowerCase()}Open`;
        const nextIsClosedKey = `isClosedOn${nextDayName}`;
        
        if (!openingData[nextIsClosedKey] && openingData[nextOpenKey]) {
          return { 
            isOpen: false, 
            message: `Opens ${convertTo12HourFormat(openingData[nextOpenKey])} ${nextDayName}` 
          };
        }
        
        nextDay = (nextDay + 1) % 7;
        attempts++;
      }
      
      return { isOpen: false, message: "Closed indefinitely" };
    } else {
      if (currentTime >= openTime && (!closeTime || currentTime < closeTime)) {
        return { 
          isOpen: true, 
          message: `Closes ${convertTo12HourFormat(closeTime) || "later today"}` 
        };
      } else if (currentTime < openTime) {
        return { 
          isOpen: false, 
          message: `Opens ${convertTo12HourFormat(openTime)} today` 
        };
      } else {
        // Find next open day
        let nextDay = (now.getDay() + 1) % 7;
        let attempts = 0;
        
        while (attempts < 7) {
          const nextDayName = days[nextDay];
          const nextOpenKey = `${nextDayName.toLowerCase()}Open`;
          const nextIsClosedKey = `isClosedOn${nextDayName}`;
          
          if (!openingData[nextIsClosedKey] && openingData[nextOpenKey]) {
            return { 
              isOpen: false, 
              message: `Opens ${convertTo12HourFormat(openingData[nextOpenKey])} ${nextDayName}` 
            };
          }
          
          nextDay = (nextDay + 1) % 7;
          attempts++;
        }
        
        return { isOpen: false, message: "Closed indefinitely" };
      }
    }
  }
  
  /**
   * Generate formatted opening hours
   */
  function generateFormattedOpeningHours(openingData) {
    const days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    const entries = [];
    
    for (let i = 0; i < days.length; i++) {
      const day = days[i];
      const isClosed = openingData[`isClosedOn${day}`];
      const open = openingData[`${day.toLowerCase()}Open`] || "";
      const close = openingData[`${day.toLowerCase()}Close`] || "";
      
      if (isClosed || (!open && !close)) {
        entries.push({ day, status: "Closed" });
      } else {
        entries.push({ 
          day, 
          status: {
            open: convertTo12HourFormat(open),
            close: convertTo12HourFormat(close)
          }
        });
      }
    }
    
    // Group by hours
    const grouped = [];
    let current = null;
    
    entries.forEach((entry) => {
      if (!current) {
        current = { from: entry.day, to: entry.day, status: entry.status };
      } else if (JSON.stringify(entry.status) === JSON.stringify(current.status)) {
        current.to = entry.day;
      } else {
        grouped.push({ ...current });
        current = { from: entry.day, to: entry.day, status: entry.status };
      }
    });
    
    if (current) grouped.push(current);
    
    return grouped;
  }
  
  /**
   * Convert time from 24-hour to 12-hour format
   */
  function convertTo12HourFormat(time24) {
    if (!time24 || !/\d{2}:\d{2}/.test(time24)) return "";
    
    const [hours, minutes] = time24.split(":").map(Number);
    const period = hours >= 12 ? "PM" : "AM";
    const hours12 = hours % 12 || 12;
    
    return `${hours12}:${String(minutes).padStart(2, '0')} ${period}`;
  }
  
  /**
   * Clear all results and markers
   */
  function clearResults() {
    elements.locationResults.innerHTML = "";
    state.markers.forEach(marker => marker.map = null);
    state.markers = [];
    state.bounds = new google.maps.LatLngBounds();
    
    if (state.clusterer) {
      state.clusterer.clearMarkers();
    }
  }
  
  /**
   * Show or hide no results message
   */
  function showNoResults(show) {
    elements.noResults.classList.toggle('hidden', !show);
  }
  
  /**
   * Apply marker clustering
   */
  function applyMarkerClustering() {
    const { MarkerClusterer } = window.markerClusterer || window;
    
    if (state.clusterer) {
      state.clusterer.clearMarkers();
    }
    
    state.clusterer = new MarkerClusterer({
      map: state.map,
      markers: state.markers,
      renderer: {
        render: ({ count, position }) => {
          const color = "#0057b7";
          
          // Create a custom clusterer element
          const div = document.createElement("div");
          div.className = "custom-cluster";
          div.style.backgroundColor = color;
          div.style.borderRadius = "50%";
          div.style.color = "white";
          div.style.width = `${Math.max(36, Math.min(count * 4, 60))}px`;
          div.style.height = `${Math.max(36, Math.min(count * 4, 60))}px`;
          div.style.display = "flex";
          div.style.alignItems = "center";
          div.style.justifyContent = "center";
          div.style.boxShadow = "0 2px 8px rgba(0, 0, 0, 0.3)";
          div.style.fontSize = "14px";
          div.style.fontWeight = "bold";
          div.textContent = count;
          
          // Create an AdvancedMarkerElement for the cluster
          const marker = new google.maps.marker.AdvancedMarkerElement({
            map: state.map,
            position,
            content: div,
          });
          
          return marker;
        },
      },
    });
  }