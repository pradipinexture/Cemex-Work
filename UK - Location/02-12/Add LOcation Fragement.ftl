
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/css/intlTelInput.css" />
<link rel="stylesheet" href="/documents/d/global/rte_theme_default-1">
<link rel="stylesheet" href="/documents/d/global/toaster_css">

[#assign objectDefinitionId = 41054] 
[#assign parentVocabularyName = "Topic"]
[#assign parentCategoryName = "Product"]

[#assign allCatsOfProduct = ""]

[#attempt]
    [#assign productParentCategory = ""]

    [#assign assetVocabularyLocalService = staticUtil["com.liferay.asset.kernel.service.AssetVocabularyLocalServiceUtil"]]
    [#assign assetCategoryLocalService = staticUtil["com.liferay.asset.kernel.service.AssetCategoryLocalServiceUtil"]]

    [#assign parentVocabulary = assetVocabularyLocalService.getGroupVocabulary(themeDisplay.getScopeGroupId(), parentVocabularyName)]

    [#if parentVocabulary??]
        [#assign topLevelCategories = assetCategoryLocalService.getVocabularyRootCategories(parentVocabulary.getVocabularyId(), -1, -1, null)]
        [#list topLevelCategories as category]
            [#if category.getName() == parentCategoryName]
                [#assign productParentCategory = category]
                [#break]
            [/#if]
        [/#list]

        [#if productParentCategory??]
            [#assign childCategories = assetCategoryLocalService.getChildCategories(productParentCategory.getCategoryId())]
            [#assign allCatsOfProduct = childCategories]
        [/#if]
    [/#if]

[#recover]
    <script>console.log("Error: An issue occurred while retrieving categories. Please try again later.")</script>
[/#attempt]

[#assign jobPositionsFromObj = []]

[#attempt]
    [#assign ObjectEntryLocalService = serviceLocator.findService("com.liferay.object.service.ObjectEntryLocalService")]
    [#assign objectEntries = ObjectEntryLocalService.getObjectEntries(themeDisplay.getScopeGroupId(), objectDefinitionId, -1, -1)]

    [#if objectEntries?size > 0]
        [#list objectEntries as objectEntry]
            [#assign values = objectEntry.getValues()]
            [#if values?has_content && values['jobName']?has_content]
                [#assign jobPositionsFromObj = jobPositionsFromObj + [values['jobName']]]
            [/#if]
        [/#list]
    [/#if]
[#recover]
    <script>console.log("Error: An issue occurred while retrieving job positions from Object. Please try again later.")</script>
[/#attempt]

<main>
   <div class="add-location-main">
      <div class="container">
         <div class="location-modal">
            <div class="location-new-modal-content-inner">
               <div class="location-new-header">
                  <h4 id="myModalLabel">${languageUtil.get(locale, "addLocation", "Add location")}</h4>
               </div>
               <div class="location-new-body">
                  <form id="locationForm" onsubmit="return false;">
                     <div class="row">
                        <div class="col-md-6">
                           <div class="form-group">
                              <div class="form-item">
                                 <input type="text" id="locationname" class="LocationTitle" required />
                                 <label for="locationname">${languageUtil.get(locale, "locationName", "Location Name")}
                                 </label>
                              </div>
                           </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <div class="form-item">
                                    <label id="plant-label">${languageUtil.get(locale, "plantProducts", "Plant Products")}</label>
                                    <div class="multiselect" id="planttype">
                                        <div class="multiselect-container" id="selectedContainer"></div>
                                        <ul class="multiselect-dropdown" id="optionsContainer">
                                          [#if childCategories?has_content]
                                              [#list childCategories as childCategory]
                                                  <li><a class="multiselect-option" data-value="${childCategory.getCategoryId()}">${childCategory.getName()}</a></li>
                                              [/#list]
                                          [#else]
                                              <li><a class="multiselect-option" data-value="">No product categories found</a></li>
                                          [/#if]
                                        </ul>
                                        <select name="productTypes" id="hiddenSelect" multiple style="display: none;"></select>
                                    </div>
                                </div>
                            </div>
                        </div>
                     </div>
                     <div class="row">
                        <div class="col-md-6">
                           <div class="form-group">
                              <div class="form-item">
                                 <input type="text" id="address" autocomplete="off" class="Address" required />
                                 <label for="address"> ${languageUtil.get(locale, "address", "Address")} </label>
                              </div>
                           </div>
                        </div>
                        <div class="col-md-6">
                           <div class="form-group">
                              <div class="form-item">
                                 <input type="text" id="addressone" autocomplete="off" class="Address2" required />
                                 <label for="addressone">${languageUtil.get(locale, "address2","Address 2")}</label>
                              </div>
                           </div>
                        </div>
                     </div>
                     <div class="row">
                        <div class="col-md-6">
                           <div class="form-group">
                              <div class="form-item">
                                 <input type="text" id="company" autocomplete="off" class="CompanyName" required/>
                                 <label for="company"> ${languageUtil.get(locale, "companyName","companyName")}</label>
                              </div>
                           </div>
                        </div>
                        <div class="col-md-6">
                           <div class="form-group">
                              <div class="form-item">
                                 <input type="text" id="city" autocomplete="off" class="TownCity" required />
                                 <label for="city">${languageUtil.get(locale, "townCity", "City")}</label>
                              </div>
                           </div>
                        </div>
                     </div>
                     <div class="row">
                        <div class="col-md-6">
                           <div class="form-group">
                              <div class="form-item">
                                 <input type="text" id="state" autocomplete="off" class="State input-focus" />
                                 <label for="state">${languageUtil.get(locale, "state", "State")}</label>
                              </div>
                           </div>
                        </div>
                        <div class="col-md-6">
                           <div class="form-group">
                              <div class="form-item">
                                 <input type="text" id="region" autocomplete="off" class="Region" />
                                 <label for="addressone" class="focus-label">${languageUtil.get(locale, "region", "Region")}</label>
                              </div>
                           </div>
                        </div>
                     </div>
                     <div class="row">
                        <div class="col-md-6">
                           <div class="form-group">
                              <div class="form-item">
                                 <input type="text" id="postcode" autocomplete="off" class="Postcode" required />
                                 <label for="postcode"> ${languageUtil.get(locale, "postCode", "PostCode")}</label>
                                 <span class="text-danger" id="postcode-error"></span>
                              </div>
                           </div>
                        </div>
                        <div class="col-md-6">
                           <div class="form-group">
                              <div class="form-item">
                                 <select class="form-control Country" name="country" id="country" required>
                                    <option value="" disabled selected>${languageUtil.get(locale, "country", "Country")}</option>
                                 </select>
                              </div>
                           </div>
                        </div>
                     </div>
                     <div class="row">
                        <div class="col-md-6">
                           <div id="location-map" style="height: 300px; width:100%; margin-bottom: 20px;"></div>
                        </div>
                        <div class="col-md-6">
                           <div class="form-group">
                              <div class="form-item">
                                 <input type="tel" id="phonenumber" autocomplete="off" class="PhoneNumber" required />
                                 <span class="text-danger" id="phoneNumber-error"></span>
                              </div>
                           </div>
                           <div class="form-group">
                              <div class="form-item">
                                 <input type="text" id="map-address" autocomplete="off" />
                                 <label for="map-address">${languageUtil.get(locale, "geoLocation", "Map Address")}
                                 </label>
                                 <div id="address-suggestions"></div>
                              </div>
                           </div>
                           <div class="latitude">
                              <div class="form-group">
                                 <div class="form-item">
                                    <input type="text" id="latitude" autocomplete="off" required />
                                    <label for="latitude">${languageUtil.get(locale, "latitude", "Latitude")} </label>
                                 </div>
                              </div>
                              <div class="form-group">
                                 <div class="form-item">
                                    <input type="text" id="longitude" autocomplete="off" required />
                                    <label for="longitude">${languageUtil.get(locale, "longitude", "Longitude")}</label>
                                 </div>
                              </div>
                           </div>
                           <div style="margin-top: 40px">
                              <button class="current-location" type="button">
                                 ${languageUtil.get(locale, "currentLocationLabel", "Current Location")}
                              </button>
                           </div>
                        </div>
                     </div>
                     <div class="row">
                        <div class="col-md-12">
                           <h6>${languageUtil.get(locale, "openingHours", "Opening hours")}</h6>
                        </div>
                        <div class="col-md-5">
                           <ul class="week-list">
                           </ul>
                        </div>
                        <div class="col-md-5">
                           <div class="all-hours-wrapper">
                              <button class="add-contact hours-btn edit-all-hours " type="button"
                                 data-target="bs-hours-modal" data-toggle="popup">
                                 ${languageUtil.get(locale, "editAllHoursLabel", "Edit all hours")}
                              </button>
                              <button class="add-contact hours-btn mon-to-fri" type="button"
                                 data-target="bs-hours-modal" data-toggle="popup">
                                 ${languageUtil.get(locale, "editMonFriLabel", "Edit Mon-Fri")}
                              </button>
                              <button class="add-contact hours-btn sat-to-sun" type="button"
                                 data-target="bs-hours-modal" data-toggle="popup">
                                 ${languageUtil.get(locale, "editSatSunLabel", "Edit Sat-Sun")}
                              </button>
                           </div>
                        </div>
                     </div>
                     <div class="row">
                        <div class="col-md-12">
                           <span class="text-danger" id="weeklist-error"></span>
                        </div>
                     </div>
                     <div class="row contact-container">
                        <div class="col-md-12">
                           <h6>${(contactInformation?has_content)?then(contactInformation, 'Contact information')}</h6>
                           <div class="add-tag-main">
                              <button class="add-contact" type="button" data-target="bs-contact-modal"
                                 data-toggle="popup">
                                 <cwc-icon name="plus" color="bright-blue"></cwc-icon>
                                 ${languageUtil.get(locale, "addContact", "Add Contact")}
                              </button>
                           </div>
                        </div>
                        <div class="col-md-12">
                           <div class="row" id="contact-card-container">
                           </div>
                        </div>
                     </div>

                     <div class="row contact-container">

                        <div class="col-md-12">
                           <h6>${languageUtil.get(locale, "documentInformation", "Attach Documents")}</h6>

                           <div class="add-tag-main">
                              <button class="add-contact add-file add-doc" type="button" data-target="bs-file-modal"
                                 data-toggle="popup">
                                 <cwc-icon name="plus" color="bright-blue"></cwc-icon>
                                 ${languageUtil.get(locale, "addFile", "Add File")}
                              </button>
                           </div>
                        </div>

                        <div class="col-md-12">
                           <div class="row" id="file-card-container">
                           </div>
                        </div>


                     </div>
                     <div class="row contact-container">
                        <div class="col-md-12">
                           <h6>Connect Webpages</h6>

                           <div class="add-tag-main">
                              <button class="add-contact add-page add-doc" type="button" data-target="bs-page-modal"
                                 data-toggle="popup">
                                 <cwc-icon name="plus" color="bright-blue"></cwc-icon>
                                 ${languageUtil.get(locale, "addPage", "Add Page")}
                              </button>
                           </div>
                        </div>

                        <div class="col-md-12">
                           <div class="row" id="page-card-container">
                           </div>
                        </div>
                     </div>
                     <div class="row contact-container">
                        <div class="col-md-12">
                           <h6>${(plantProducts?has_content)?then(plantProducts, 'Plant Products')}</h6>
                           <div class="add-product-main">
                              <button class="add-contact add-product" type="button" data-target="bs-product-modal"
                                 data-toggle="popup">
                                 <cwc-icon name="plus" color="bright-blue"></cwc-icon>
                                 ${languageUtil.get(locale, "addProduct", "Add Product")}
                              </button>
                           </div>
                        </div>

                        <div class="col-md-12">
                           <div class="row" id="pro-link-card-container">
                           </div>
                        </div>
                     </div>
                     <div class="row contact-container">
                        <div class="col-md-12">
                           <h6>Upload Publishers</h6>
                           <div class="add-tag-main">
                              <button class="add-contact add-GMB" type="button" data-target="bs-GMB-modal"
                                 data-toggle="popup">
                                 <cwc-icon name="plus" color="bright-blue"></cwc-icon>
                                 ${languageUtil.get(locale, "addPublisher", "Add Publisher")}
                              </button>
                           </div>
                        </div>

                        <div class="col-md-12">
                           <div class="row" id="GMB-card-container">
                           </div>
                        </div>

                     </div>
                     <div class="row">
                        <div class="col-md-12">
                           <h6 style="margin-bottom: 0px;">${languageUtil.get(locale, "locationImage", "Upload Location Photo")}</h6>
                           <div class="file-upload">
                              <div id="locationimage-elems">
                                 <cwc-icon name="camera" color="bright-blue"></cwc-icon> 
                                 <input type="file" id="fileInput" />
                                 <label for="fileInput">${languageUtil.get(locale, "locationImage", "Upload Photo")}</label>
                              </div>
                              <span class="text-danger" id="image-error"></span>
                           </div>
                           <div id="imagePreview" class="imagePreview" style="display: none">
                              <button id="removeButton" type="button">
                                 <cwc-icon name="close" color="bright-blue"></cwc-icon>
                              </button>
                           </div>
                        </div>
                     </div>
                     <div class="row description-row">
                        <div class="col-md-12">
                           <div class="form-group">
                              <div class="form-item">
                                 <div id="div_editor1" class="RichText"> </div>
                                 <span class="text-danger" id="locationDescription-error"></span>
                              </div>
                           </div>
                        </div>
                     </div>

                     <div class="row">
                        <input type="checkbox" id="yextSy" name="YextSync" value="true" checked>
                        <label for="myCheckbox">${languageUtil.get(locale, "uberAllSync", "UberAll Sync")} </label>
                     </div>

                     <div class="row">
                        <div class="col-lg-12">
                           <div class="location-btn-group">
                              <button type="button" class="btn btn-default common-btn" data-dismiss="modal">
                                 ${languageUtil.get(locale, "cancelLabel", "Cancel")}
                              </button>
                              <button id="save" type="submit" class="btn btn-primary common-btn blue-btn"
                                 value="Save Location">
                                 ${languageUtil.get(locale, "saveLocationLabel", "Save Location")}
                              </button>
                           </div>
                        </div>
                     </div>
                  </form>
               </div>
            </div>
            <div id="overlay">
               <div class="cv-spinner">
                  <span class="spinner"></span>
               </div>
            </div>
         </div>
      </div>
   </div>

   <div id="bs-hours-modal" class="bs-hours-modal popup">
      <div class="popup-window">
         <div class="modal-content">
            <div class="modal-header">
               <h4 class="modal-title">${languageUtil.get(locale, "openingHours", "Opening hours")}</h4>
            </div>
            <div class="modal-body">
               <div class="row">
                  <div class="col-12">
                     <ul class="week-list-main">
                        <li>
                           <input class="common-checkbox mon-fri" type="checkbox" id="monday" value="monday" />
                           <label for="monday">M</label>
                        </li>
                        <li>
                           <input class="common-checkbox mon-fri" type="checkbox" id="tuesday" value="tuesday" />
                           <label for="tuesday">T</label>
                        </li>
                        <li>
                           <input class="common-checkbox mon-fri" type="checkbox" id="wednesday" value="wednesday" />
                           <label for="wednesday">W</label>
                        </li>
                        <li>
                           <input class="common-checkbox mon-fri" type="checkbox" id="thursday" value="thursday" />
                           <label for="thursday">T</label>
                        </li>
                        <li>
                           <input class="common-checkbox mon-fri" type="checkbox" id="friday" value="friday" />
                           <label for="friday">F</label>
                        </li>
                        <li>
                           <input class="common-checkbox sat-sun" type="checkbox" id="saturday" value="saturday" />
                           <label for="saturday">S</label>
                        </li>
                        <li>
                           <input class="common-checkbox sat-sun" type="checkbox" id="sunday" value="sunday" />
                           <label for="sunday">S</label>
                        </li>
                     </ul>
                  </div>
               </div>
               <div class="row">
                  <div class="col-12">
                     <div class="form-group">
                        <div class="form-item">
                           <select class="form-control" id="opening-hours-type">
                              <option value="Open">Open</option>
                              <option value="Splitting">Splitting</option>
                              <option value="Closed">Closed</option>
                           </select>
                        </div>
                     </div>
                  </div>
               </div>
               <div>
                  <div id="type-time-container"></div>
                  <div class="row" id="close-time-row">
                     <div class="col-12">
                        <div class="form-group close-group" style="display: none;">
                           <input type="checkbox" id="close" checked disabled />
                           <label for="close">Closed</label>
                        </div>
                     </div>
                  </div>
                  <button type="button" id="new-splitting-row" class="btn btn-secondary">Add New Splitting Row</button>
               </div>
            </div>
            <div class="modal-footer">
               <button type="button" id="hours-cancel" class="btn btn-secondary common-btn popup-close" data-dismiss="popup">Cancel</button>
               <button type="submit" id="submit-hours-button" class="btn btn-primary popup-close common-btn blue-btn submit-hours" data-dismiss="popup">Save</button>
            </div>
         </div>
      </div>
   </div>

   <div id="bs-contact-modal" class="bs-contact-modal popup ">
      <div class="popup-window">
         <div class="modal-content">
            <div class="modal-header">
               <h4 class="modal-title">
                  ${languageUtil.get(locale, "contactInformation", "Contact information")}
               </h4>
            </div>
            <form id="contactForm" onsubmit="return false;">
               <div class="modal-body">
                  <input type="hidden" value="" class="update-id" />
                  <div class="row">
                     <div class="col-md-6">
                        <div class="form-group">
                           <div class="form-item">
                              <input type="text" id="contactname"/>
                              <label for="contactname">
                                 ${languageUtil.get(locale, "contactName", "Contact Name")}
                              </label>
                           </div>
                        </div>
                     </div>
                     <div class="col-md-6">
                        <div class="form-group">
                           <div class="form-item">
                              <select class="form-control" id="job-position">
                                 <option value="" disabled="" selected="">Select Job Position</option>
                                  [#if jobPositionsFromObj?size gt 1]
                                      [#list jobPositionsFromObj as jobName]
                                          <option value="${jobName?trim}">${jobName?trim}</option>
                                      [/#list]
                                  [#else]
                                       <option value="" disabled>No Job Positions Found</option>
                                  [/#if]
                              </select>
                           </div>
                        </div>
                     </div>
                     <div class="col-md-6">
                        <div class="form-group">
                           <div class="form-item">
                              <input type="email" id="emailaddress" autocomplete="off" placeholder=" " />
                              <label for="emailaddress">
                                 ${languageUtil.get(locale, "emailAddress", "Email address")}
                              </label>
                           </div>
                        </div>
                     </div>
                     <div class="col-md-6">
                        <div class="form-group">
                           <div class="form-item">
                              <input type="tel" id="phonenumbermodal" autocomplete="off" required />
                              <span class="text-danger" id="phonenumbermodal-error"></span>
                           </div>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="modal-footer">
                  <button type="button" class="btn btn-default common-btn popup-close" data-dismiss="popup">
                      ${languageUtil.get(locale, "cancelLabel", "Cancel")}
                  </button>
                  <button id="save-contact" type="submit" class="btn btn-primary  common-btn blue-btn"
                     value="Save Contact">
                      ${languageUtil.get(locale, "saveLabel", "Save")}
                  </button>
               </div>
            </form>
         </div>
      </div>
   </div>
   <div id="bs-page-modal" class="bs-page-modal popup ">
      <div class="popup-window">
         <div class="modal-content">
            <div class="modal-header">
               <h4 class="modal-title">${languageUtil.get(locale, "pageInformation", "Page information")}</h4>
            </div>
            <form id="contactForm" onsubmit="return false;">
               <div class="modal-body">
                  <input type="hidden" value="" class="update-id" />
                  <div class="row">
                     <div class="col-md-6">
                        <div class="form-group">
                           <div class="form-item">
                              <input class="input-focus" type="text" id="pagename" autocomplete="off" required />
                              <label for="pagename" class="focus-label">${languageUtil.get(locale, "pageName", "Page Name")}</label>
                           </div>
                        </div>
                     </div>
                     <div class="col-md-6">
                        <div class="form-group">
                           <div class="form-item">
                              <input class="input-focus" type="url" id="fileUrl" autocomplete="off" name="homepage"
                                 required />
                              <label for="pagename" class="focus-label">${languageUtil.get(locale, "pageURL", "Page URL")}</label>
                           </div>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="modal-footer">
                  <button type="button" class="btn btn-default common-btn popup-close" data-dismiss="popup">
                     ${languageUtil.get(locale, "cancelLabel", "Cancel")}
                  </button>
                  <button id="save-page" type="submit" class="btn btn-primary  common-btn blue-btn" value="Save Page">
                     ${languageUtil.get(locale, "saveLabel", "Save")}
                  </button>
               </div>
            </form>
         </div>
      </div>
   </div>
   <div id="bs-product-modal" class="bs-page-modal popup ">
      <div class="popup-window">
         <div class="modal-content">
            <div class="modal-header">
               <h4 class="modal-title">${languageUtil.get(locale, "addProduct", "Add Product")}</h4>
            </div>
            <form id="" onsubmit="return false;">
               <div class="modal-body">
                  <input type="hidden" value="" class="update-id" />
                  <div class="row">
                     <div class="col-md-6">
                        <div class="form-group">
                           <div class="form-item">
                              <select class="form-control ProductType" name="product-type" id="pro-link-name">
                                 <option value="">${languageUtil.get(locale, "selectTheProduct", "Select the Product")}
                                 </option>
                                 [#if childCategories?has_content]
                                     [#list childCategories as childCategory]
                                         <option value="${childCategory.getName()}">${childCategory.getName()}</option>
                                     [/#list]
                                 [#else]
                                    <option value="">No product categories found</option>
                                 [/#if]
                              </select>
                           </div>
                        </div>
                     </div>
                     <div class="col-md-6">
                        <div class="form-group">
                           <div class="form-item">
                              <input class="input-focus" type="url" id="pro-link" autocomplete="off" required />
                               <label for="pro-link" class="focus-label">${languageUtil.get(locale, "productLink", "Product Link")}
                               </label>
                           </div>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="modal-footer">
                  <button type="button" class="btn btn-default common-btn popup-close" data-dismiss="popup">
                     ${languageUtil.get(locale, "CancelLabel", "Cancel")}
                  </button>
                  <button id="save-product" type="submit" class="btn btn-primary  common-btn blue-btn"
                     value="Save Product">${languageUtil.get(locale, "saveLabel", "Save")}
                  </button>
               </div>
            </form>
         </div>
      </div>
   </div>
   <div id="bs-file-modal" class="bs-file-modal popup ">
      <div class="popup-window">
         <div class="modal-content">
            <div class="modal-header">
               <h4 class="modal-title">
                  ${languageUtil.get(locale, "fileInformation", "File information")}
               </h4>
            </div>
            <form id="contactForm" onsubmit="return false;">
               <div class="modal-body">
                  <input type="hidden" value="" class="file-update-id" />
                  <div class="row">
                     <div class="col-md-6">
                        <div class="form-group">
                           <div class="form-item">
                              <div class="floating-input">
                                 <input class="input-focus" type="text" id="filename" autocomplete="off" required />
                                 <label for="filename" class="focus-label">${languageUtil.get(locale, "fileName", "File Name")}</label>
                              </div>
                           </div>
                        </div>
                     </div>
                     <div class="col-md-6">
                        <div class="form-group">
                           <div class="form-item">
                              <div class="form-item">
                                 <span class="control-fileupload">
                                    <label for="file"> ${languageUtil.get(locale, "chooseFileLabel ", "Choose a file : ")}</label>
                                    <input type="file" id="file" required />
                                 </span>
                              </div>
                           </div>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="modal-footer">
                  <button type="button" class="btn btn-default common-btn popup-close" data-dismiss="popup">
                     ${languageUtil.get(locale, "CancelLabel", "Cancel")}
                  </button>
                  <button id="save-file" type="submit" class="btn btn-primary  common-btn blue-btn" value="Save File">
                     ${languageUtil.get(locale, "saveLabel", "Save")}
                  </button>
               </div>
            </form>
         </div>
      </div>
   </div>
   <div id="bs-GMB-modal" class="bs-GMB-modal popup ">
      <div class="popup-window">
         <div class="modal-content">
            <div class="modal-header">
               <h4 class="modal-title">
                  ${languageUtil.get(locale, "publisherInformation", "Publisher Information")}
               </h4>
            </div>
            <form id="contactForm" onsubmit="return false;">
               <div class="modal-body">
                  <input type="hidden" value="" class="file-update-id" />
                  <div class="row">
                     <div class="col-md-12">
                        <div class="form-group">
                           <div class="form-item">
                              <div class="floating-input">
                                 <input class="input-focus" type="text" id="filePublisher" autocomplete="off"
                                    required />
                                 <label for="filename" class="focus-label">${languageUtil.get(locale, "addPublisher", "Add Publisher")}</label>
                              </div>
                           </div> 
                        </div>
                     </div>
                  </div>
                  <div class="row">
                     <div class="col-md-12">
                        <div class="form-group">
                           <div class="form-item">
                              <div class="floating-input">
                                 <span class="GMB-fileupload">
                                    <label for="fileGMB">${languageUtil.get(locale, "chooseFileLabel ", "Choose a file :")}</label>
                                    <input type="file" id="GMBfile" accept="image/png, image/jpeg, image/jpg, image/gif" required  />
                                 </span>
                              </div>
                           </div>
                        </div>
                     </div>
                  </div>
                  <div class="row">
                     <div class="col-md-12">
                        <div class="form-group">
                           <div class="form-item">
                              <div class="floating-input">
                                 <input class="input-focus" type="text" id="fileDescription" autocomplete="off"
                                    required />
                                 <label for="filename" class="focus-label"> ${languageUtil.get(locale, "description ", "Description")}</label>
                              </div>
                           </div>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="modal-footer">
                  <button type="button" class="btn btn-default common-btn popup-close" data-dismiss="popup">
                     ${languageUtil.get(locale, "CancelLabel", "Cancel")}
                  </button>
                  <button id="save-GMB-data" type="submit" class="btn btn-primary  common-btn blue-btn"
                     value="Save File">
                     ${languageUtil.get(locale, "saveLabel", "Save")}
                  </button>
               </div>
            </form>
         </div>
      </div>
   </div>
</main>

<script src="/documents/d/global/toaster_js"></script>

<script>

   // Translation Messages
   var tosterMessageSaveSuccess = "${languageUtil.get(locale, 'tosterMessageSaveSuccess', 'Data added successfully')}";
   var tosterMessageUpdateSuccess = "${languageUtil.get(locale, 'tosterMessageUpdateSuccess', 'Data updated successfully')}";
   var tosterMessageDeletedSuccess = "${languageUtil.get(locale, 'tosterMessageDeletedSuccess', 'Data removed successfully')}";
   var fillRequiredField = "${languageUtil.get(locale, 'fillRequiredField', 'Please fill in all required fields.')}";
   var contactCardRemoveMessage = "${languageUtil.get(locale, 'contactCardRemoveMessage', 'Contact removed successfully')}";
   var allValidationMessage = "${languageUtil.get(locale, 'allValidationMessage', 'All fields must be filled out with valid data in the contact form')}";
   var updateLabel = "${languageUtil.get(locale, 'updateLabel', 'Update')}";
   var postalNotValidLabel = "${languageUtil.get(locale, 'postalNotValidLabel', 'Postal code is not valid')}";
   var psValidateErrorLabel = "${languageUtil.get(locale, 'psValidateErrorLabel', 'An error occurred while validating the postal code')}";
   var updateLocationLabel = "${languageUtil.get(locale, 'updateLocationLabel', 'Update Location')}";
   var saveLabel = "${languageUtil.get(locale, 'saveLabel', 'Save')}";
   var invalidCountryCode = "${languageUtil.get(locale, 'invalidCountryCode', 'Invalid country code. Please try again.')}";
   var phoneNoShort = "${languageUtil.get(locale, 'phoneNoShort', 'The phone number is too short. Please enter a longer number.')}";
   var phoneNoLong = "${languageUtil.get(locale, 'phoneNoLong', 'The phone number is too long. Please enter a shorter number.')}";
   var invalidPhoneNo = "${languageUtil.get(locale, 'invalidPhoneNo', 'Please enter a valid phone number using only digits.')}";
   var phoneNotValid = "${languageUtil.get(locale, 'phoneNotValid', 'The phone number is not valid. Please check and try again.')}";
   var errorPhoneNo = "${languageUtil.get(locale, 'errorPhoneNo', 'An error occurred during validation. Please try again.')}";
   var fileNotUploadedRenameIt = "${languageUtil.get(locale, 'fileNotUploadedRenameIt', 'File has not uploaded. Please try again by renaming the file.')}";
   var validateAllFormFields = "${languageUtil.get(locale, 'validateAllFormFields', 'Please fill required and valid information in this form')}";
   var locationUpdateSuccess = "${languageUtil.get(locale, 'locationUpdateSuccess', 'Location is updated successfully')}";
   var locationUpdateFailMessage = "${languageUtil.get(locale, 'locationUpdateFailMessage', 'Requested location is not updated.')}";
   var locationCreatedMessage = "${languageUtil.get(locale, 'locationCreatedMessage', 'Requested location is created successfully')}";
   var locationFailMessage = "${languageUtil.get(locale, 'locationFailMessage', 'Requested location is not created.')}";
   var warnExportSelect = "${languageUtil.get(locale, 'warnExportSelect', 'Please select any location to export.')}";
   var chooseFile = "${languageUtil.get(locale, 'chooseFile', 'Choose a file')}";
   var folderCreationFail = "${languageUtil.get(locale, 'folderCreationFail', 'Failed to create folder')}";
   var uploadFileCreationFail = "${languageUtil.get(locale, 'uploadFileCreationFail', 'Failed to upload file')}";

	var zipCodeSearchApiUrl = "https://app.zipcodebase.com/api/v1/search";
	var zipApiKey = "3eeee100-cefc-11ee-b060-635cb775ed1a";	
   var countryGroupId = parseInt(themeDisplay.getSiteGroupId());
   var countryLanguageId = themeDisplay.getLanguageId();

   var articleStructureId = 38304;
   var articleTemplateId = '38405';
   var guestRoleId= 20123;
   var articleClassName = 'com.liferay.journal.model.JournalArticle';
   var fileEntryClassName = 'com.liferay.document.library.kernel.model.DLFileEntry'

   // List of eu countries with data
   var listOfEUCountries = [
       { name: 'United Kingdom', languageId: 'en_GB', wcmFolderId: 39338, documentMediaFolderId: 43560, csvParentFodlerId: 46690, productParentCatId: 41361, productTypeVocId: 41357,layoutUUID: "",code: "GB"}
   ];

   var countryFolderId;
   var documentMediaFolderId;
   var csvParentFodlerId;
   var currentCountry = "GB";
   var productParentCatId;
   var productTypeVocId;

   var currentCountry = listOfEUCountries.find(country => country.languageId === themeDisplay.getLanguageId());

   if(currentCountry) {
      countryFolderId = currentCountry.wcmFolderId;
      documentMediaFolderId = currentCountry.documentMediaFolderId;
      currentCountry = currentCountry.code;
      csvParentFodlerId = currentCountry.csvParentFodlerId;
      productParentCatId = currentCountry.productParentCatId;
      productTypeVocId = currentCountry.productTypeVocId;
   }

   var countries = [
       { code: "HR", name: "Croatia"},
       { code: "CZ", name: "Czech Republic"},
       { code: "FR", name: "France"},
       { code: "DE", name: "Germany"},
       { code: "PL", name: "Poland"},
       { code: "ES", name: "Spain"},
       { code: "GB", name: "United Kingdom"},
       { code: "BA", name: "Bosnia and Herzegovina"},
       { code: "ME", name: "Montenegro"},
       { code: "RS", name: "Serbia"}
   ];

    var countrySelect = document.getElementById("country");
    let options = '<option value="" disabled="" selected="">Country</option>';
    countries.forEach(function (country) {
        options += '<option value="' + country.name + '" ' + (country.code === currentCountry ? 'selected' : '') + '>' + country.name + '</option>';
    });
    countrySelect.innerHTML = options;


	function genericValidations() {
       var requiredValidateIds = [
           'LocationTitle', 'Address', 'TownCity', 'Country', 
           'Postcode', 'PhoneNumber', 'GeolocationData'
       ];

       for (var field of requiredValidateIds) {
           if (field === 'GeolocationData') {
               var longitude = document.getElementById("longitude").value;
               var latitude = document.getElementById("latitude").value;
               if (longitude === '' || isNaN(longitude) || latitude === '' || isNaN(latitude)) {
                   return false;
               }
           } else {
               var fieldElement = document.querySelector('.' + field);
               var fieldValue = fieldElement ? fieldElement.value : '';

               if (field === 'PhoneNumber') {
                   var phoneInput = initializeIntlTelInput(
                       preferredCountries, 
                       countryCodeValue, 
                       'phonenumber',
                       "phoneNumber-error"
                   );
                   
                   if (fieldValue === '' || !validatePhoneNumber(phoneInput, "phoneNumber-error")) {
                       return false;
                   }
               } else if (field === 'Postcode') {
                   var postcode = document.getElementById("postcode").value;
                   if (!validatePostalCode(postcode)) {
                       return false;
                   }
               } else {
                   if (fieldValue === '') return false;
               }
           }
       }
       return true;
   }
</script>
<script src="/documents/d/global/location-strcutre"></script>
<script src="/documents/d/global/liferay-functionality"></script>

<script>
   var selectedCategoryIds = new Set();

   document.addEventListener('DOMContentLoaded', () => {
       var container = document.getElementById('selectedContainer'),
           dropdown = document.getElementById('optionsContainer'),
           select = document.getElementById('hiddenSelect');
       container.addEventListener('click', () => dropdown.classList.add('show'));
       document.getElementById("plant-label").onclick = function () { setTimeout(() => document.getElementById('optionsContainer').classList.add('show'), 10) };
       document.addEventListener('click', e => !e.target.closest('.multiselect') && dropdown.classList.remove('show'));
       dropdown.addEventListener('click', e => {
           if (e.target.classList.contains('multiselect-option')) {
               var value = e.target.dataset.value;
               if(!value) return;
               if (!selectedCategoryIds.has(value)) {
                   selectedCategoryIds.add(value);
                   container.insertAdjacentHTML('beforeend',
                       '<span class="multiselect-tag" data-value="' + value + '">' + e.target.textContent + '<span class="multiselect-tag-remove">×</span></span>');
                   e.target.classList.add('selected');
               } else {
                   selectedCategoryIds.delete(value);
                   container.querySelector('[data-value="' + value + '"]').remove();
                   e.target.classList.remove('selected');
               }
               togglePlantTypeLabel()
           }
       });
       container.addEventListener('click', e => {
           if (e.target.classList.contains('multiselect-tag-remove')) {
               var tag = e.target.parentNode;
               var value = tag.dataset.value;
               selectedCategoryIds.delete(value);
               tag.remove();
               dropdown.querySelector('[data-value="' + value + '"]').classList.remove('selected');
               togglePlantTypeLabel()
           }
       });
   });

   function selectCategory(idOrName) {
       var dropdown = document.getElementById('optionsContainer'),
           option = dropdown.querySelector('[data-value="' + idOrName + '"]') ||
               Array.from(dropdown.getElementsByClassName('multiselect-option'))
                   .find(opt => opt.textContent.toLowerCase() === idOrName.toLowerCase());
       option && !selectedCategoryIds.has(option.dataset.value) && option.click();
       togglePlantTypeLabel()
   }

   function togglePlantTypeLabel() {
       var selectedContainer = document.getElementById('selectedContainer');
       var plantLabel = document.getElementById('plant-label');
       if (selectedContainer && plantLabel) {
           (selectedContainer.children.length > 0) ? plantLabel.classList.add('plant-label-focus') : plantLabel.classList.remove('plant-label-focus');
       }
   }
</script>

<!-- Generic functinality of Add Page --> 
<script>
   function getProductHTML(productName, productCatId, productLink) {
       return '<div class="col-md-4">' +
           '<div class="pro-link-card" id="pro-link-card-id-' + (productCardId++) + '">' +
               '<h2 class="pro-link-name" id="' + productCatId + '">' + productName + '</h2>' +
               '<a class="pro-link-card-edit">' +
                   '<cwc-icon name="edit" color="true-blue"></cwc-icon>' +
               '</a>' +
               '<a class="pro-link-card-remove">' +
                   '<cwc-icon name="close" color="true-blue"></cwc-icon>' +
               '</a>' +
               '<p class="pro-link">' + productLink + '</p>' +
           '</div>' +
       '</div>';
   }

   function generateProductHTMLAndAppend(productName, productCatId, productLink) {
       var productCard = getProductHTML(productName, productCatId, productLink);
       document.getElementById('pro-link-card-container').insertAdjacentHTML('beforeend', productCard);
   }

   function generateContactElement(contactName, contactJob, contactEmail, contactPhone) {
       return '<div class="col-md-4">' +
           '<div class="contact-card" id="contact-card-id-' + (contactCardId++) + '">' +
               '<h2 class="contact-name">' + contactName + '</h2>' +
               '<a class="card-edit">' +
                   '<cwc-icon name="edit" color="true-blue"></cwc-icon>' +
               '</a>' +
               '<a class="contact-card-remove">' +
                   '<cwc-icon name="close" color="true-blue"></cwc-icon>' +
               '</a>' +
               '<p class="contact-job">' + contactJob + '</p>' +
               '<p class="contact-email"><a href="mailto:' + contactEmail + '">' + contactEmail + '</a></p>' +
               '<p class="contact-phone">' + contactPhone + '</p>' +
           '</div>' +
       '</div>';
   }

   function generateGMBDiv(publisher, fileData, description) {
       return "<div class='col-md-4'>" +
            "<div class='GMB-card' id='GMB-card-id-" + (GMBCardId++) + "'>" +
            "<h2 class='file-Publisher'>" + publisher +
            "</h2>" +
            "<a class='GMB-card-edit'>" +
            "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
            "</a>" +
            "<a class='GMB-card-remove'>" +
            "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
            "</a>" +
            "<h2 class='file-Description'>" + description +
            "</h2>" +
            "<p class='file-value' data-file-response='" + JSON.stringify(fileData) + "'>" + fileData.title + "</p>" +
            "</div>" +
            "</div>";
   }

   function generateFileCard(fileName, fileData) {
       return "<div class='col-md-4'>" +
            "<div class='file-card' id='file-card-id-" + (fileCardId++) + "'>" +
            "<h2 class='file-name'>" + fileName +
            "</h2>" +
            "<a class='file-card-edit'>" +
            "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
            "</a>" +
            "<a class='file-card-remove'>" +
            "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
            "</a>" +
            "<p class='file-value' data-file-response='"+JSON.stringify(fileData)+"'>" + fileData.title + "</p>" +
            "</div>" +
            "</div>";;
   }

   function generatePageElement(pageName, PageURL) {
       return '<div class="col-md-4">' +
           '<div class="page-card" id="page-card-id-' + (pageCardId++) + '">' +
               '<h2 class="page-name">' + pageName + '</h2>' +
               '<a class="page-card-edit">' +
                   '<cwc-icon name="edit" color="true-blue"></cwc-icon>' +
               '</a>' +
               '<a class="page-card-remove">' +
                   '<cwc-icon name="close" color="true-blue"></cwc-icon>' +
               '</a>' +
               '<p class="page-url">' + PageURL + '</p>' +
           '</div>' +
       '</div>';
   }
</script>

<!-- Get Article and render data in UI.-->
<script src="/documents/d/global/render-location"></script>

<script type="module" src="https://www.cemexgo.com/cdn/web-components/latest/cmx-web-components/cmx-web-components.esm.js"></script>
<script nomodule src="https://www.cemexgo.com/cdn/web-components/latest/cmx-web-components/cmx-web-components.js"></script>
<script src="/documents/d/global/gmb-publisher-crud"></script>
<script src="/documents/d/global/file-crud"></script>
<script src="/documents/d/global/product-crud"></script>
<script src="/documents/d/global/page-crud"></script>
<script src="/documents/d/global/opening-hours"></script>
<script src="/documents/d/global/contact-card"></script>
<script src="/documents/d/global/rte-1"></script>
<script src="/documents/d/global/all_plugins-1"></script>
<script src="/documents/d/global/phone"></script>
<script src="/documents/d/global/googlemap"></script>
<script src="/documents/d/global/postalcode"></script>
<script src="/documents/d/global/save-update-location"></script>

<!-- Location Image related script-->
<script>
   document.getElementById('fileInput').addEventListener('change', async function() {    
       var result = await uploadFileToLiferay('fileInput', documentMediaFolderId, null, true);

       if(!result) {
           this.value = '';
           Toast.error(fileNotUploadedRenameIt);
           return;
       }

       this.dataset.fileResponse = JSON.stringify(result);
       Toast.success("File uploaded successfully");
   });

   var fileInput = document.getElementById("fileInput");
   var imagePreview = document.getElementById("imagePreview");
   var removeButton = document.getElementById("removeButton");

   fileInput.addEventListener("change", handleFiles);
   
   function handleFiles() {
       var file = this.files[0];
        if (validateImage()) {
            var reader = new FileReader();
            reader.onload = function () {
                imagePreview.style.backgroundImage = "url(" + reader.result + ")";
                imagePreview.style.display = "block";
                removeButton.style.display = "block";
                fileInput.style.display = "none";
           };
           reader.readAsDataURL(file);
       }
   }

   removeButton.addEventListener("click", () => {
       imagePreview.style.backgroundImage = "none";
       fileInput.value = "";
       removeButton.style.display = "none";
       fileInput.style.display = "block";
       imagePreview.style.display = "none";
   });


   function validateImage() {
      var fileInputImage = document.getElementById('fileInput');
      if (fileInputImage && fileInputImage.files && fileInputImage.files.length > 0) {      
        var fileExtension = fileInputImage.files[0].name.split('.').pop().toLowerCase();
        var allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];

        if (allowedExtensions.indexOf(fileExtension) === -1) {
            fileInputImage.value = '';
            return false;
           }
       }
      return true;
   }
</script>

<script>

</script>

<script
   src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBYQKXwHhI8LwTxfxK8PQ3nFZAQc4nsjqU&libraries=places&callback=initMap"
   async defer></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/intlTelInput.min.js"></script>