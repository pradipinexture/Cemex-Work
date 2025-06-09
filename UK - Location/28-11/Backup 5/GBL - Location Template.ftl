
<#assign latitude=0>
<#assign longitude=0>

<#if (Geolocation.getData() !="" )>
  <#assign geolocationJSONObject=jsonFactoryUtil.createJSONObject(Geolocation.getData())>
    <#assign latitude=geolocationJSONObject.getDouble("lat")>
      <#assign longitude=geolocationJSONObject.getDouble("lng")>
</#if>

<style>
  html {
    position: relative;
    min-height: 100%;
  }

  body {
    margin-bottom: 60px;
  }

  .navbar-default {
    background-color: #ffffff !important;
  }

  .navbar-logo {
    width: 100px;
    height: auto;
  }

  .embed-responsive-100x400px {
    padding-bottom: 400px;
  }

  .btnContainer {
    padding-top: 20px;
    padding-bottom: 20px;
  }

  .btnCxBl {
    background-color: #1697f3;
    color: #ffffff;
    border-radius: 25px;
  }

  .btnCxBl:hover {
    color: #1697f3;
    background-color: #eeeeee;
  }

  .btnCxWt {
    border: thin solid #1697f3;
    border-radius: 25px;
    color: #1697f3;
  }

  .btnCxWt:hover {
    color: #1697f3;
    background-color: #eeeeee;
    border-color: #eeeeee;
  }

  .containerText {
    padding-left: 10px;
    padding-right: 10px;
  }

  .footer {
    width: 100%;
    height: 60px;
    position: absolute;
    bottom: 0;
    background-color: #023185 !important;
  }

  .footer-logo {
    width: 100px;
    height: auto;
    padding-top: 20px;
    padding-bottom: 10px;
    margin-left: auto;
    margin-right: auto;
    display: block;
  }

  .signed-in .app-root.cx-guest-view [class*="col-"],
  .signed-in .app-root.cx-guest-view [class^="col-"],
  .signed-in .app-root [class*="col-"],
  .signed-in .app-root [class^="col-"] {
    padding-left: 15px;
  }


  .app-root.cx-guest-view [class*="col-"],
  .app-root.cx-guest-view [class^="col-"],
  .app-root [class*="col-"],
  .app-root [class^="col-"] {
    padding-right: 15px;
  }

  div.phone {
    font-size: 16px;
    font-weight: 500;
    color: #001B3A;
  }

  .header-title,
  .header-back-to {
    display: none;
  }


  .fa-map-marker,
  .fa-phone {
    color: #0074D4;
  }

  .fa-map-marker:before {
    content: "\f041";
  }

  #calculator {
    display: none;
  }

  #bannerPlaceholder {
    min-height: 20px !important;
    width: 100%;
  }
  .dayname {
    width: 50%;
  }

    .map-container {
    position: relative;
    min-height: 400px;
  }
  
  .map-loader {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(255, 255, 255, 0.9);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1;
    border-radius: 25px 0 25px 0;
  }

  .spinner {
    width: 50px;
    height: 50px;
    border: 5px solid #f3f3f3;
    border-radius: 50%;
    border-top: 5px solid #1697f3;
    animation: spin 1s linear infinite;
  }

  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }

  .map-loader.hidden {
    display: none;
  }
</style>

<main>
    <div class="container">
      <#if LocationName?has_content && LocationName.getData() !="">
        <div class="row my-5">
          <div class="col-12">
            <h1 class="display-4" id="location-heading">${LocationName.getData()}</h1>
          </div>
        </div>
      </#if>

      <div class="row mb-4">
        <div class="col-md-4">
          <div class="containerText">
            <p style="font-weight:600; font-size:16px;">
              <#if (Address.getData())??>${Address.getData()}</#if>
              <#if (Address2.getData())??>${Address2.getData()}</#if>
              <#if (TownCity.getData())??>${TownCity.getData()}</#if>
              <#if (State.getData())??>${State.getData()}</#if>
              <#if (Region.getData())??>${Region.getData()}</#if>
              <#if (Country.getData())??>${Country.getData()}</#if>
              <#if (Postcode.getData())??>${Postcode.getData()}</#if>
            </p>

            <#if ProductCard?has_content && ProductCard.getSiblings()?has_content && ProductCard.getSiblings()?size !=0>
              <hr />
              <p style="font-size:16px; font-weight:600;">${languageUtil.get(locale, "availableProducts", "Available Products")}</p>
              <div class="row">
                <#list ProductCard.getSiblings() as product>
                  <div class="col-4">
                    <#if product.Name?has_content && product.Name.getData()?has_content && product.Link?has_content &&
                      product.Link.getData()?has_content>
                      <a href="${product.Link.getData()}">${product.Name.getData()}</a>
                      <#elseif product.Name?has_content && product.Name.getData()?has_content>
                        <span>${product.Name.getData()}</span>
                    </#if>
                  </div>
                </#list>
              </div>
            </#if>

            <#if PhoneNumber?has_content && PhoneNumber.getData() !="">
              <h3 style="font-size:16px; font-weight:600;">${languageUtil.get(locale, "phoneDetails", "Phone Details")}</h3>
              <div class="row">
                <div class="col-sm-6">${languageUtil.get(locale, "phoneDetails", "Phone Details")} ${languageUtil.get(locale, "main", "Main")}:</div>
                <div class="col-sm-6">
                  <a href="tel:${PhoneNumber.getData()}">${PhoneNumber.getData()}</a>
                </div>
              </div>

              <#if ContactDetail?has_content && ContactDetail.getSiblings()?has_content &&
                ContactDetail.getSiblings()?size !=0>
                <#list ContactDetail.getSiblings() as contact>
                  <#if contact.PhoneNumber1?has_content && contact.PhoneNumber1.getData()?has_content>
                    <div class="row">
                      <div class="col-sm-6">
                        <#if contact.ContactName?has_content && contact.ContactName.getData()?has_content &&
                          contact.ContactName.getData() !="-">
                          ${contact.ContactName.getData()}: 
                        <#else>
                            <p>${languageUtil.get(locale, "phoneDetails", "Phone Details")}</p>
                        </#if>
                      </div>
                      <div class="col-sm-6">
                          <a href="tel:${contact.PhoneNumber1.getData()}">${contact.PhoneNumber1.getData()}</a>
                      </div>
                    </div>
                  </#if>
                </#list>
              </#if>
            </#if>

            <#if OpeningHours?has_content && OpeningHours.getSiblings()?has_content && OpeningHours.getSiblings()?size != 0>
                <hr/>
                <p style="font-size:16px; font-weight:600;">${languageUtil.get(locale, "openingTimes", "Opening Times")}</p>

                <#list OpeningHours.getSiblings() as cur_OpeningHours>
                    <div class="row">
                        <div class="col-6">
                            <#if (cur_OpeningHours.DayName.getData())??>
                              ${languageUtil.get(locale, cur_OpeningHours.DayName.getData()?lower_case + "Label", cur_OpeningHours.DayName.getData())}
                            </#if>
                        </div>
                        <div class="col-6">

<#if getterUtil.getBoolean(cur_OpeningHours.isClosed.getData())>
    Closed
<#else>
  <#if cur_OpeningHours.Fieldset54865370.getSiblings()?has_content>
    <div class="row">
      <#list cur_OpeningHours.Fieldset54865370.getSiblings() as cur_OpeningHours_Fieldset54865370>
        
        <#if (cur_OpeningHours_Fieldset54865370.Open.getData())?? && (cur_OpeningHours_Fieldset54865370.Close.getData())??>
          <div class="col-12">${cur_OpeningHours_Fieldset54865370.Open.getData()} - ${cur_OpeningHours_Fieldset54865370.Open.getData()}</div>
        </#if> 
      </#list>
    </div>
  </#if>
</#if>
                        </div>
                    </div>
                </#list>
            </#if>
          </div>
        </div>

        <div class="col-md-8">
          <div class="containerText">
            <div class="map-container">
              <!-- Add loader -->
              <div id="mapLoader" class="map-loader">
                <div class="spinner"></div>
              </div>
              <div class="embed-responsive embed-responsive-16by9">
                <iframe 
                  style="min-height:400px; width:100%; border-radius:25px 0 25px 0; border: 1px #c7c0c0 solid;"
                  referrerpolicy="no-referrer-when-downgrade" 
                  src="" 
                  allowfullscreen="" 
                  referrerpolicy="no-referrer-when-downgrade">
                </iframe>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="row mt-4 mb-4">
        <div class="col-md-4">
          <div class="btnContainer">
            <a class="btn btnCxWt btn-block" href="#"><i class="fas fa-directions"></i>
              ${languageUtil.get(locale, "getDirections", "Get Directions")}
            </a>
          </div>
        </div>
        <div class="col-md-4">
          <div class="btnContainer">
            <a class="btn btnCxBl btn-block" id="request-a-quote" href="#"><i class="fas fa-file"></i>${languageUtil.get(locale, "getAQuote", "Get A Quote")}</a>
          </div>
        </div>
        <div class="col-md-4">
          <div class="btnContainer">
            <a class="btn btnCxWt btn-block" id="calculator" href="#"><i class="fas fa-calculator"></i>${languageUtil.get(locale, "concreteCalculator", "Concrete Calculator")}</a>
          </div>
        </div>
      </div>

      <div class="containerText">
        <hr />
      </div>

      <#if ContactDetail?has_content && ContactDetail.getSiblings()?has_content && ContactDetail.getSiblings()?size !=0>
        <#list ContactDetail.getSiblings() as contact>
          <#if !(contact.ContactName.getData()?has_content && contact.ContactName.getData() !="-" &&
            contact.EmailAddress.getData()?has_content && contact.EmailAddress.getData() !="-" &&
            contact.PhoneNumber1.getData()?has_content && contact.PhoneNumber1.getData() !="-" )>
            <#break>
          </#if>

          <div class="my-4">
            <div class="containerText">
              <p style="font-size:16px; font-weight:600;">${languageUtil.get(locale, "contactInformation", "Contact Information")}</p>
              <div class="row">
                <#list ContactDetail.getSiblings() as validContact>
                  <#if validContact.ContactName.getData()?has_content && validContact.ContactName.getData() !="-" &&
                    validContact.EmailAddress.getData()?has_content && validContact.EmailAddress.getData() !="-" &&
                    validContact.PhoneNumber1.getData()?has_content && validContact.PhoneNumber1.getData() !="-">
                    <div class="col-sm-4">
                      <p>
                        ${validContact.ContactName.getData()}<br>${validContact.EmailAddress.getData()}<br>${validContact.PhoneNumber1.getData()}
                      </p>
                    </div>
                  </#if>
                </#list>
              </div>
            </div>
          </div>
          <#break>
        </#list>
      </#if>

      <div class="row my-5">
        <div class="col-md-6">
          <div class="containerText">
            <#if RichText?has_content && RichText.getData()?has_content && RichText.getData() !="">
              <p style="font-size:16px; font-weight:600">About ${LocationName.getData()}</p>
              <p>${RichText.getData()}</p>
            </#if>

            <div class="row mt-3">
              <#if FileCard?has_content && FileCard.getSiblings()?has_content && FileCard.getSiblings()?size !=0>
                <#list FileCard.getSiblings() as fileData>
                  <#if fileData.LocationPriceList?? && fileData.LocationPriceList.getData()?has_content>
                    <div class="col-sm-6">
                      <a href="${fileData.LocationPriceList.getData()}" class="btn btn-primary btn-block"
                        style="width:100%;" download>${fileData.PriceName.getData()}</a>
                    </div>
                  </#if>
                </#list>
              </#if>
            </div>
          </div>
        </div>

        <div class="col-md-6">
          <div class="containerText">
            <#if LocationImage?? && LocationImage.getData() !="">
            <img alt="${LocationImage.getAttribute("alt")}" style="border-radius: 25px 0 25px 0 !important; width: 100%; height: 100%;" data-fileentryid="${LocationImage.getAttribute('fileEntryId')}" src="${LocationImage.getData()}" class="img-fluid rounded" />   </#if>
          </div>
        </div>
      </div>
    </div>
</main>

<script>
window.initMap = function() {
    const googleMapKey = "AIzaSyBYQKXwHhI8LwTxfxK8PQ3nFZAQc4nsjqU";
    const latitude = parseFloat("${latitude}");
    const longitude = parseFloat("${longitude}");
    const iframe = document.getElementsByTagName("iframe")[0];
    const mapLoader = document.getElementById('mapLoader');

    if (iframe) {
        let locationName = "";
        getReverseGeocodingData(latitude, longitude, function(placeQuery) {
            locationName = placeQuery;
            
            // Set the iframe source
            const iframeSrc = 
                "https://www.google.com/maps/embed/v1/place?key=" +
                googleMapKey +
                "&q=" +
                encodeURIComponent(locationName);
            
            // Add load event listener to iframe
            iframe.onload = function() {
                // Hide loader when map is loaded
                mapLoader.classList.add('hidden');
            };

            // Show loader before loading map
            mapLoader.classList.remove('hidden');
            iframe.src = iframeSrc;

            // Generate the directions URL
            const directionsUrl = 
                "https://www.google.com/maps/dir/?api=1&key=" + 
                googleMapKey +
                "&destination=" + 
                encodeURIComponent(locationName);

            // Set the href of the 'Get Directions' button
            const directionsButton = document.querySelector(".btn-primary[href='#']");
            if (directionsButton) {
                directionsButton.href = directionsUrl;
            }
        });

        // Add error handling for iframe loading
        iframe.onerror = function() {
            mapLoader.classList.add('hidden');
            console.error('Failed to load map');
        };

        // Add timeout to hide loader if map takes too long
        setTimeout(function() {
            mapLoader.classList.add('hidden');
        }, 10000); // 10 second timeout
    }
};
// Also make getReverseGeocodingData globally available
window.getReverseGeocodingData = function(latitude, longitude, callback) {
    const geocoder = new google.maps.Geocoder();
    const latlng = { lat: latitude, lng: longitude };
    
    geocoder.geocode({ location: latlng }, function(results, status) {
        if (status === "OK" && results[0]) {
            callback(results[0].formatted_address);
        }
    });
};

// Calculator logic
if (themeDisplay.getLanguageId() === "en_GB" && document.getElementById("location-heading").textContent.toLowerCase().includes('concrete')) {
    const calculator = document.getElementById('calculator');
    console.log("inner");
    calculator.setAttribute('href', 'https://www.cemex.co.uk/readymix-concrete-calculator');
    calculator.style.display = 'inline-block';
    calculator.innerHTML = '<i class="fas fa-calculator"></i>Concrete Calculator';
}
</script>

<!-- Load Google Maps API after function definitions -->
<script
    src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBYQKXwHhI8LwTxfxK8PQ3nFZAQc4nsjqU&libraries=places&callback=initMap"
    async defer>
</script>