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
<!-- Intial data -->
<script>
	   var fileValues = []; 
   var GMBfileValues = [];
   //var GMBFileList = [];

   var updateIndexId =  null;
   var GMBupdateIndexId = null;

   var tagId = 1;
   var contactCardId = 1;
   var fileCardId = 1;
   var GMBCardId = 1;

   // Translation Messages
	var tosterMessageSaveSuccess = 'Data added successfully';
	var tosterMessageUpdateSuccess= 'Data updated successfully';

	var tosterMessageDeletedSuccess= 'Data removed successfully';
	var fillRequiredField = "Please fill in all required fields.";

	var contactCardRemoveMessage = 'Contact removed successfully';
	var allValidationMessage = 'All fields must be filled out with valid data in the contact form';
	var updateLabel = "Update";
	var postalNotValidLabel = "Postal code is not valid";
	var psValidateErrorLabel = "An error occurred while validating the postal code";
	var updateLocationLabel = "Update Location";
	var saveLabel = "Save";
	var invalidCountryCode = "Invalid country code. Please try again.";
	var phoneNoShort = "The phone number is too short. Please enter a longer number.";
	var phoneNoLong = "The phone number is too long. Please enter a shorter number.";
	var invalidPhoneNo = "Please enter a valid phone number using only digits.";
	var phoneNotValid = "The phone number is not valid. Please check and try again.";
	var errorPhoneNo = "An error occurred during validation. Please try again.";
	var fileNotUploadedRenameIt = "File has not uploaded. Please try again by renaming the file.";
   var validateAllFormFields = 'Please fill required and valid information in this form';
   var locationFailMessage = 'Requested location is not created.';
   var locationUpdateSuccess = 'Location is updated successfully';

	var zipCodeSearchApiUrl = "https://app.zipcodebase.com/api/v1/search";
	var zipApiKey = "3eeee100-cefc-11ee-b060-635cb775ed1a";	
   var countryGroupId = parseInt(themeDisplay.getSiteGroupId());
   var countryLanguageId = themeDisplay.getLanguageId();
   var countryFolderId;
   var documentMediaFolderId;
   var currentCountry = "GB";
   var articleStructureId = 38304;
   var articleTemplateId = '38405';
   var guestRoleId= 20123;

   // List of eu countries with data
   var listOfEUCountries = [
       { name: 'United Kingdom', languageId: 'en_GB', wcmFolderId: 39338, documentMediaFolderId: 43560,layoutUUID: "",code: "GB"}
   ];

   var currentCountry = listOfEUCountries.find(country => country.languageId === themeDisplay.getLanguageId());

   if(currentCountry) {
      countryFolderId = currentCountry.wcmFolderId;
      documentMediaFolderId = currentCountry.documentMediaFolderId;
      currentCountry = currentCountry.code;
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

   const locationFieldsIds = {
       'LocationName': {
           elementId: '#locationname',
           xmlFieldName: 'Text55119005',
           type: 'text'
       },
       'Address': {
           elementId: '#address',
           xmlFieldName: 'Text67160900',
           type: 'text'
       },
       'Address2': {
           elementId: '#addressone',
           xmlFieldName: 'Field90325339',
           type: 'text'
       },
       'CompanyName': {
           elementId: '#company',
           xmlFieldName: 'Field35228776',
           type: 'text'
       },
       'TownCity': {
           elementId: '#city',
           xmlFieldName: 'Field53582290',
           type: 'text'
       },
       'Country': {
           elementId: '#country',
           xmlFieldName: 'Field84466895',
           type: 'text'
       },
       'Postcode': {
           elementId: '#postcode',
           xmlFieldName: 'Field84400079',
           type: 'text'
       },
       'PhoneNumber': {
           elementId: '#phonenumber',
           xmlFieldName: 'Text84739096',
           type: 'text'
       },
       'Geolocation': {
           elementId: '#map-address',
           xmlFieldName: 'Geolocation02236727',
           type: 'geolocation',
           latitude: {
               elementId: '#latitude',
               xmlFieldName: ''
               
           },
           longitude: {
               elementId: '#longitude',
               xmlFieldName: ''
           }
       },
       'OpeningHours': {
           elementId: '-time-container',
           xmlFieldName: 'Fieldset22331654',
           type: 'fieldset',
           nestedFields: {
               dayName: {
                   xmlFieldName: 'Text14522579',
                   type: 'text'
               },
               timeSlots: {
                   xmlFieldName: 'Fieldset54865370',
                   type: 'fieldset',
                   nestedFields: {
                       open: {
                           xmlFieldName: 'Text72354453',
                           type: 'text'
                       },
                       close: {
                           xmlFieldName: 'Field82067117',
                           type: 'text'
                       }
                   }
               },
               isClosed: {
                   xmlFieldName: 'Checkbox90733914',
                   type: 'checkbox'
               }
           }
       },
       'ContactDetail': {
           elementId: '#contact-card-container',
           xmlFieldName: 'Field82242200',
           type: 'fieldset',
           nestedFields: {
               contactName: {
                   xmlFieldName: 'Field25164775',
                   type: 'text'
               },
               jobPosition: {
                   xmlFieldName: 'Text93041485',
                   type: 'text'
               },
               emailAddress: {
                   xmlFieldName: 'Field33848867',
                   type: 'text'
               },
               phoneNumber: {
                   xmlFieldName: 'Field00538252',
                   type: 'text'
               }
           }
       },
       'LocationImage': {
           elementId: '#imagePreview',
           xmlFieldName: 'Image39238044',
           type: 'image'
       },
       'RichText': {
           elementId: '#div_editor1',
           xmlFieldName: 'RichText49050010',
           type: 'rich_text'
       },
       'isYextRestrict': {
           elementId: '#yextSy',
           xmlFieldName: 'Checkbox87026811',
           type: 'checkbox'
       },
       'AddPage': {
           elementId: '#page-card-container',
           xmlFieldName: 'Field04667800',
           type: 'fieldset',
           nestedFields: {
               pageName: {
                   xmlFieldName: 'Field96200945',
                   type: 'text'
               },
               pageUrl: {
                   xmlFieldName: 'Field29236574',
                   type: 'text'
               }
           }
       },
       'ProductCard': {
           elementId: '#pro-card-container',
           xmlFieldName: 'Fieldset30777848',
           type: 'fieldset',
           nestedFields: {
               name: {
                   xmlFieldName: 'Text35595774',
                   type: 'text'
               },
               link: {
                   xmlFieldName: 'Field10244315',
                   type: 'text'
               }
           }
       },
       'FileCard': {
           elementId: '#file-card-container',
           xmlFieldName: 'Field97097822',
           type: 'fieldset',
           nestedFields: {
               priceName: {
                   xmlFieldName: 'Field62496690',
                   type: 'text'
               },
               locationPriceList: {
                   xmlFieldName: 'DocumentLibrary67644054',
                   type: 'document_library'
               }
           }
       },
       'PublisherImages': {
           elementId: '#GMB-card-container',
           xmlFieldName: 'Field92906873',
           type: 'fieldset',
           nestedFields: {
               publisher: {
                   xmlFieldName: 'Field75567888',
                   type: 'text'
               },
               file: {
                   xmlFieldName: 'DocumentLibrary64462292',
                   type: 'document_library'
               },
               description: {
                   xmlFieldName: 'Field29703218',
                   type: 'text'
               }
           }
       },
       'State': {
           elementId: '#state',
           xmlFieldName: 'Text87594312',
           type: 'text'
       },
       'Region': {
           elementId: '#region',
           xmlFieldName: 'Field37057184',
           type: 'text'
       }
   };

    const countrySelect = document.getElementById("country");
    let options = '<option value="" disabled="" selected="">Country</option>';
    countries.forEach(function (country) {
        options += '<option value="' + country.name + '" ' + (country.code === currentCountry ? 'selected' : '') + '>' + country.name + '</option>';
    });
    countrySelect.innerHTML = options;

   async function uploadFileToLiferay(fileInputId, folderId, fileName=null) {
      try {
          const fileInput = document.getElementById(fileInputId);
          if (!fileInput) {
              console.error("File input with id "+fileInputId+" not found");
              return null;
          }

          const file = fileInput.files[0];
          if (!file) {
              console.error('No file selected');
              return null;
          }

          const formData = new FormData();
          formData.append('repositoryId', themeDisplay.getScopeGroupId());
          formData.append('folderId', folderId);
          formData.append('sourceFileName', fileName ? fileName : file.name);
          formData.append('mimeType', file.type);
          formData.append('title', file.name);
          formData.append('description', '');
          formData.append('changeLog', '');
          formData.append('file', file);

          const response = await fetch('/api/jsonws/dlapp/add-file-entry', {
              method: 'POST',
              body: formData,
              headers: {
                  'X-CSRF-Token': Liferay.authToken
              }
          });
          if (!response.ok) {    
              console.error('HTTP error! status: '+response.status);
              return null;
          }
          var fileUploadResponse = await response.json();
          
          await setGuestPermissionsForFileEntry(fileUploadResponse.fileEntryId)
          
          return fileUploadResponse;                
      } catch (error) {
          console.error(error.message);
          return null;
      }
   }

   async function setGuestPermissionsForFileEntry(fileEntryId) {
       try {
           await new Promise((resolve, reject) => {
               Liferay.Service(
                   '/resourcepermission/set-individual-resource-permissions',
                   {
                       groupId: countryGroupId,
                       companyId: themeDisplay.getCompanyId(),
                       name: 'com.liferay.document.library.kernel.model.DLFileEntry',
                       primKey: fileEntryId,
                       roleId: guestRoleId,
                       actionIds: ["VIEW"]
                   },
                   (response) => {
                       console.log("Permission added to WCM successfully");
                       resolve(response);
                   },
                   (error) => {
                       console.error("Error setting permissions:", error);
                       reject('Failed to set permissions');
                   }
               );
           });
       } catch (error) {
           console.error('Permission setting failed:', error);
           throw new Error('Permission setting failed: ' + error.message);
       }
   }
   async function getWebcontentCategories(resourcePK) {
     return new Promise((resolve, reject) => {
       Liferay.Service(
         '/assetcategory/get-categories',
           {
               className: 'com.liferay.journal.model.JournalArticle',
               classPK: parseInt(resourcePK)
           },
           function(obj) {
             resolve(obj);
           }
       );
       });
   }
	
	function genericValidations() {
    const requiredValidateIds = [
        'LocationTitle', 'Address', 'TownCity', 'Country', 
        'Postcode', 'PhoneNumber', 'GeolocationData'
    ];

    for (const field of requiredValidateIds) {
        if (field === 'GeolocationData') {
            const longitude = document.getElementById("longitude").value;
            const latitude = document.getElementById("latitude").value;
            if (longitude === '' || isNaN(longitude) || latitude === '' || isNaN(latitude)) {
                return false;
            }
        } else {
            const fieldElement = document.querySelector('.' + field);
            const fieldValue = fieldElement ? fieldElement.value : '';

            if (field === 'PhoneNumber') {
                const phoneInput = initializeIntlTelInput(
                    preferredCountries, 
                    countryCodeValue, 
                    'phonenumber',
                    "phoneNumber-error"
                );
                
                if (fieldValue === '' || !validatePhoneNumber(phoneInput, "phoneNumber-error")) {
                    return false;
                }
            } else if (field === 'Postcode') {
                const postcode = document.getElementById("postcode").value;
                if (!validatePostalCode(postcode)) {
                    return false;
                }
            } else {
                if (fieldValue === '') {
                    return false;
                }
            }
        }
    }
    return true;
}
</script>

<script>
// Product Type logic
var selectedCategoryIds = new Set();

document.addEventListener('DOMContentLoaded', () => {
    const container = document.getElementById('selectedContainer'),
        dropdown = document.getElementById('optionsContainer'),
        select = document.getElementById('hiddenSelect');
    container.addEventListener('click', () => dropdown.classList.add('show'));
    document.getElementById("plant-label").onclick = function () { setTimeout(() => document.getElementById('optionsContainer').classList.add('show'), 10) };
    document.addEventListener('click', e => !e.target.closest('.multiselect') && dropdown.classList.remove('show'));
    dropdown.addEventListener('click', e => {
        if (e.target.classList.contains('multiselect-option')) {
            const value = e.target.dataset.value;
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
            const tag = e.target.parentNode;
            const value = tag.dataset.value;
            selectedCategoryIds.delete(value);
            tag.remove();
            dropdown.querySelector('[data-value="' + value + '"]').classList.remove('selected');
            togglePlantTypeLabel()
        }
    });
});

function selectCategory(idOrName) {
    const dropdown = document.getElementById('optionsContainer'),
        option = dropdown.querySelector('[data-value="' + idOrName + '"]') ||
            Array.from(dropdown.getElementsByClassName('multiselect-option'))
                .find(opt => opt.textContent.toLowerCase() === idOrName.toLowerCase());
    option && !selectedCategoryIds.has(option.dataset.value) && option.click();
    togglePlantTypeLabel()
}
function togglePlantTypeLabel() {
    const selectedContainer = document.getElementById('selectedContainer');
    const plantLabel = document.getElementById('plant-label');
    if (selectedContainer && plantLabel) {
        (selectedContainer.children.length > 0) ? plantLabel.classList.add('plant-label-focus') : plantLabel.classList.remove('plant-label-focus');
    }
}
</script>

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
<script>
   document.getElementById('fileInput').addEventListener('change', async function() {    
       var result = await uploadFileToLiferay('fileInput', documentMediaFolderId);

       if(!result) {
           this.value = '';
           Toast.error("Image has not uploaded. Please try again by renaming the file.");
           return;
       }

       this.dataset.fileResponse = JSON.stringify(result);
       Toast.success("File uploaded successfully");
   });

   
   const fileInput = document.getElementById("fileInput");
   const imagePreview = document.getElementById("imagePreview");
   const removeButton = document.getElementById("removeButton");

   fileInput.addEventListener("change", handleFiles);
   
   function handleFiles() {
       const file = this.files[0];
        if (validateImage()) {
            const reader = new FileReader();
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
   const urlParams = new URLSearchParams(window.location.search);
   const articleIdFromUrl = urlParams.get('articleId');
   var locationXMLDataUpdateTime;

   document.addEventListener('DOMContentLoaded', function () {
       const submitButton = document.getElementById("save");
       const modelHeading = document.getElementById("myModalLabel");

       // Helper function to find field config by XML name
       function findFieldConfigByXmlName(xmlName) {
           return Object.values(locationFieldsIds).find(config => config.xmlFieldName === xmlName);
       }

      function findFieldConfigByFieldRef(fieldRef) {
          return locationFieldsIds[fieldRef] || Object.entries(locationFieldsIds).find(([key, config]) => key === fieldRef)?.[1];
      }

      async function processArticle() {
           if (!articleIdFromUrl) return;

           submitButton.innerText = updateLocationLabel;
           modelHeading.innerText = updateLocationLabel;

           try {
               const webContent = await new Promise((resolve, reject) => {
                   Liferay.Service(
                       '/journal.journalarticle/get-article',
                       {
                           groupId: countryGroupId,
                           articleId: articleIdFromUrl
                       },
                       resolve,
                       reject
                   );
               });

               const parser = new DOMParser();
               locationXMLDataUpdateTime = webContent;
               const locationXmlDoc = parser.parseFromString(webContent.content, 'application/xml');

               const rootElement = locationXmlDoc.querySelector('root');
               if (!rootElement) return;

               (async () => {
                 const categories = await getWebcontentCategories(webContent.resourcePrimKey);
                 console.log(categories);
                 if (categories && categories.length !== 0) {
                     categories.forEach(function (cat) {
                         selectCategory(cat.categoryId);
                     });
                 }
               })();

               //const dynamicElements = rootElement.querySelectorAll('dynamic-element');
               const dynamicElements = rootElement.children;
               const processedFieldsets = new Set();

               for (const element of dynamicElements) {
                   const fieldReference = element.getAttribute('field-reference');
                   const name = element.getAttribute('name');
                   const type = element.getAttribute('type');

                   let fieldConfig = findFieldConfigByFieldRef(fieldReference);
                   if (!fieldConfig) continue;

                   const content = element.querySelector('dynamic-content');
                   const contentValue = content?.textContent || '';

                   if (!contentValue && type !== 'fieldset') continue;

                   const elementId = fieldConfig.elementId;
                   if (!elementId) continue;

                   switch (type) {
                       case 'fieldset':
                           if (fieldReference === 'OpeningHours') await processOpeningHours(element, fieldConfig);
                           else if (fieldReference === 'ContactDetail') await processContactDetail(element, fieldConfig);
                           else if (fieldReference === 'ProductCard') await processAllProductCards(element, fieldConfig);
                           else if (fieldReference === 'PublisherImages') await processAllPublisherImages(element, fieldConfig);
                           else if (fieldReference === 'FileCard') await processAllFileCards(element, fieldConfig);
                           else if (fieldReference === 'AddPage') await processAllAddPages(element, fieldConfig);
                           break;

                       case 'text':
                           await processSimpleField(contentValue, fieldConfig);
                           break;
                       case 'rich_text':
                           if (fieldReference === 'RichText') await processRichText(contentValue, fieldConfig);
                           break;
                       case 'geolocation':
                           await processGeolocation(contentValue, fieldConfig);
                           break;
                       case 'image':
                           if (fieldReference === 'LocationImage') await processLocationImage(contentValue, fieldConfig);
                           break;
                       case 'checkbox':
                           if (fieldReference === 'isYextRestrict') document.querySelector(elementId).checked = (contentValue === 'true');
                           break;
                   }
               }

           } catch (error) {
               console.error('Error processing article:', error);
           }
       }

       async function processOpeningHours(dayElement, fieldConfig) {
            const dayName = dayElement.querySelector(`[field-reference="DayName"] dynamic-content`)?.textContent;
            const isClosed = dayElement.querySelector(`[field-reference="isClosed"] dynamic-content`)?.textContent === 'true';
            
            const timeContainer = document.querySelector("#"+dayName.toLowerCase()+fieldConfig.elementId);
            
            if (isClosed) {
               timeContainer.innerHTML = ('<input type="text" placeholder="—:— - —:—" value="' + "Closed" + '"> ');
            } 
            else {
               var strtEndEleString = '';
               dayElement.querySelectorAll('dynamic-element[field-reference="Fieldset54865370"]').forEach((elem)=>{
                  var startTime = elem.querySelector('dynamic-element[field-reference="Open"]')?.textContent;
                  var closeTime = elem.querySelector('dynamic-element[field-reference="Close"]')?.textContent;
                  
                  if (startTime && closeTime) strtEndEleString += '<input type="text" placeholder="—:— - —:—" value="' + startTime.trim() + ' - ' + closeTime.trim() + '"> ';

               })
               timeContainer.innerHTML = strtEndEleString;
            }
       }

      async function processContactDetail(contactElement, fieldConfig) {
          const contactContainer = document.querySelector(fieldConfig.elementId);
          const contactName = contactElement.querySelector('[field-reference="ContactName"] dynamic-content')?.textContent || '';
          const jobPosition = contactElement.querySelector('[field-reference="JobPosition"] dynamic-content')?.textContent || '';
          const emailAddress = contactElement.querySelector('[field-reference="EmailAddress"] dynamic-content')?.textContent || '';
          const phoneNumber = contactElement.querySelector('[field-reference="PhoneNumber1"] dynamic-content')?.textContent || '';
          
          contactContainer.insertAdjacentHTML('beforeend', generateContactElement(contactName, jobPosition, emailAddress, phoneNumber));
      }

       async function processAllProductCards(productElement, fieldConfig) {
            const nameElement = productElement.querySelector('[field-reference="Name"] dynamic-content');
            const linkElement = productElement.querySelector('[field-reference="Link"] dynamic-content');
            
            const productName = nameElement?.textContent || '';
            const productLink = linkElement?.textContent || '';
            
            if (productName) await generateProductHTMLAndAppend(productName, "test", productLink);
       }

       async function processAllPublisherImages(element, fieldConfig) {

         const container = document.querySelector(fieldConfig.elementId);

         const publisher = element.querySelector('[field-reference="Publisher"] dynamic-content')?.textContent;
         const fileData = element.querySelector('[field-reference="File"] dynamic-content')?.textContent;
         const description = element.querySelector('[field-reference="Description"] dynamic-content')?.textContent;

         if (publisher && fileData) container.insertAdjacentHTML('beforeend', generateGMBDiv(publisher, fileData, description));
         
       }

       async function processAllFileCards(element, fieldConfig) {
           const container = document.querySelector(fieldConfig.elementId);

            const priceName = element.querySelector('[field-reference="PriceName"] dynamic-content')?.textContent;
            const fileData = element.querySelector('[field-reference="LocationPriceList"] dynamic-content')?.textContent;

            if (priceName && fileData) container.insertAdjacentHTML('beforeend', generateFileCard(priceName, fileData));
       }

       async function processAllAddPages(element, fieldConfig) {
           const container = document.querySelector(fieldConfig.elementId);
            const pageName = element.querySelector('[field-reference="PageName"] dynamic-content')?.textContent;
            const pageUrl = element.querySelector('[field-reference="PageUrl"] dynamic-content')?.textContent;

            if (pageName && pageUrl) container.insertAdjacentHTML('beforeend', generatePageElement(pageName, pageUrl));
       }

       async function processLocationImage(contentValue, fieldConfig) {
           if (!contentValue) return;

           const imageData = JSON.parse(contentValue);

           const imageElement = document.querySelector(fieldConfig.elementId);
           imageElement.style.backgroundImage = 'url(' + imageData.url + ')';
           document.querySelector("#fileInput").dataset.fileResponse = contentValue;
           imageElement.style.display = 'block';
       }

       async function processGeolocation(contentValue, fieldConfig) {
           if (!contentValue) return;

           const geolocationData = JSON.parse(contentValue);
           document.querySelector(locationFieldsIds.Geolocation.latitude.elementId).value = geolocationData.lat;
           document.querySelector(locationFieldsIds.Geolocation.longitude.elementId).value = geolocationData.lng;
           await updateMap();
       }

       async function processRichText(contentValue, fieldConfig) {
           const editorIframe = document.querySelector(fieldConfig.elementId + ' iframe');
           if (editorIframe && editorIframe.contentDocument) {
               editorIframe.contentDocument.body.innerHTML = contentValue;
           }
       }

       async function processSimpleField(contentValue, fieldConfig) {
           const element = document.querySelector(fieldConfig.elementId);
           if (element) {
               if (fieldConfig === locationFieldsIds.Country) {
                   const parts = contentValue.split(' - ');
                   element.value = parts.length === 2 ? parts[0].trim() : contentValue;
               } else {
                   element.value = contentValue;
               }
           }
       }

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
               "<p class='file-value' data-file-response='" + fileData + "'>" + JSON.parse(fileData).title + "</p>" +
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
               "<p class='file-value' data-file-response='"+fileData+"'>" + JSON.parse(fileData).title + "</p>" +
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


       processArticle().catch(error => {
           console.error('Error in main process:', error);
       });
   });
</script>

<script>
   var coutryLanguageId = themeDisplay.getLanguageId();
   var xmlBuilder;

   async function formDataToXMLString() {
       xmlBuilder = document.implementation.createDocument(null, null);

       const declaration = xmlBuilder.createProcessingInstruction('xml', 'version="1.0"');
       xmlBuilder.appendChild(declaration);

       var rootElement = xmlBuilder.createElement('root');
       rootElement.setAttribute('available-locales', '' + coutryLanguageId + '');
       rootElement.setAttribute('default-locale', '' + coutryLanguageId + '');
       rootElement.setAttribute('version', '' + "1.0" + '');
       xmlBuilder.appendChild(rootElement);

       for (var fieldId in locationFieldsIds) {
           var config = locationFieldsIds[fieldId];
           var instanceId = fieldId.toLowerCase();

           if (fieldId === 'OpeningHours') {
               await processOpeningHours(fieldId, config);
           } else if (fieldId === 'ContactDetail') {
               await processContactDetails(fieldId, config)
           } else if (fieldId === 'FileCard') {
               await processFileCards(fieldId, config)
           } else if (fieldId === 'PublisherImages') {
               await processPublisherImages(fieldId, config)
           } else if (fieldId === 'AddPage') {
               await processAddPages(fieldId, config)
           } else if (fieldId === 'ProductCard') {
               await processProductCards(fieldId, config)
           } else {
               await processSimpleField(fieldId, config);
           }
       }

       return new XMLSerializer().serializeToString(xmlBuilder);
   }

   document.getElementById('locationForm').addEventListener('submit', async (event) => {
       event.preventDefault();

       if (!genericValidations()) {
           Toast.error(validateAllFormFields);
           return;
       }

       const articleIdFromUrl = new URLSearchParams(window.location.search).get('articleId');


       saveButtonOperation(true, (articleIdFromUrl ? true : false));
       try {
           const locationformData = await formDataToXMLString();
           
           if (!articleIdFromUrl) {
               await addArticle(locationformData);
           } else {
               await updateArticle(locationformData);
           }
       } catch (error) {
           console.error('Error processing form:', error);
           Toast.error(locationFailMessage);
       }
       saveButtonOperation(false, (articleIdFromUrl ? true : false))
   });

   async function updateArticle(locationformData) {
       try {
           await new Promise((resolve, reject) => {
               Liferay.Service(
                   '/journal.journalarticle/update-article',
                   {
                       userId: locationXMLDataUpdateTime.userId,
                       groupId: locationXMLDataUpdateTime.groupId,
                       folderId: locationXMLDataUpdateTime.folderId,
                       articleId: locationXMLDataUpdateTime.articleId,
                       version: locationXMLDataUpdateTime.version,
                       titleMap: getMapLiferay(document.querySelector("#locationname").value),
                       descriptionMap: getMapLiferay(""),
                       content: locationformData,
                       layoutUuid: locationXMLDataUpdateTime.layoutUuid,
                       serviceContext: { assetCategoryIds: Array.from(selectedCategoryIds) }
                   },(result) => {
                       locationXMLDataUpdateTime = result;
                       resolve(result);
                   },
                   reject
               );
           });
           Toast.success(locationUpdateSuccess);
       } catch (error) {
           console.log("Error occurred while updating the location: " + error);
           throw error;
       }
   }

   async function addArticle(xmlData) {
       try {
           const article = await new Promise((resolve, reject) => {
               Liferay.Service(
                   '/journal.journalarticle/add-article',
                   {
                      externalReferenceCode: '',
                      groupId: countryGroupId,
                      folderId: countryFolderId,
                      titleMap: getMapLiferay(document.querySelector("#locationname").value),
                      descriptionMap: getMapLiferay(""),
                      content: xmlData,
                      ddmStructureId: articleStructureId,
                      ddmTemplateKey: articleTemplateId
                  },
                   resolve,
                   reject
               );
           });
           var locationFailMessage = 'Requested location is not created.';
           var locationCreatedMessage = 'Requested location is created successfully';
           if (article) {
               await addResourcesToArticle(article);
               Toast.success(locationCreatedMessage);
           } else {
               Toast.error(locationFailMessage);
               //throw new Error('Article creation failed');
           }
       } catch (error) {
            Toast.error(locationFailMessage);
           //throw error;
       }
       saveButtonOperation(false, false);
   }

   async function addResourcesToArticle(article) {
       try {
           await new Promise((resolve, reject) => {
               Liferay.Service(
                   '/resourcepermission/set-individual-resource-permissions',
                   {
                       groupId: countryGroupId,
                       companyId: countryCompanyId,
                       name: 'com.liferay.journal.model.JournalArticle',
                       primKey: article.resourcePrimKey,
                       roleId: guestRoleId,
                       actionIds: ['VIEW']
                   },
                   resolve,
                   reject
               );
           });
           console.log('Permission added on the WCM');
       } catch (error) {
           console.log("Error while setting permission to location : "+error)
           //throw error;
       }
   }

   function getMapLiferay(eleValue) {
      return {[countryLanguageId]: eleValue}
   }

   function saveButtonOperation(isProcess, isUpdate) {
      const saveButton = document.getElementById('save');

      if(isProcess) {
         saveButton.disabled = true;
         saveButton.textContent = (isUpdate ? 'Updating' : 'Saving') + " Location...";
      }
       
      if(!isProcess) {
         saveButton.disabled = false;
         saveButton.textContent = (isUpdate ? 'Update' : 'Save') + " Location";
      }
   }

   async function getRandomString(length) {
       const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
       let result = '';
       for (let i = 0; i < length; i++) {
           result += characters.charAt(Math.floor(Math.random() * characters.length));
       }
       return result;
   }

   async function getDynamicElement(name, fieldReference, type, indexType) {
       var dynamicElement = xmlBuilder.createElement('dynamic-element');
       dynamicElement.setAttribute('field-reference', fieldReference);
       dynamicElement.setAttribute('index-type', indexType);
       dynamicElement.setAttribute('instance-id', await getRandomString(5));
       dynamicElement.setAttribute('name', name);
       dynamicElement.setAttribute('type', type);
       
       return dynamicElement;
   }

   async function createDynamicElement(name, fieldReference, type, value, appendToRoot) {
       var dynamicElement = xmlBuilder.createElement('dynamic-element');
       dynamicElement.setAttribute('field-reference', fieldReference);
       dynamicElement.setAttribute('index-type', 'keyword');
       dynamicElement.setAttribute('instance-id', await getRandomString(5));
       dynamicElement.setAttribute('name', name);
       dynamicElement.setAttribute('type', type);
       
       var dynamicContent = xmlBuilder.createElement('dynamic-content');
       dynamicContent.setAttribute('language-id', '' + coutryLanguageId + '');

       var cdata = xmlBuilder.createCDATASection(value ?? '');
       dynamicContent.appendChild(cdata);
       dynamicElement.appendChild(dynamicContent);

       if (appendToRoot) {
           xmlBuilder.documentElement.appendChild(dynamicElement);
       }

       return dynamicElement;
   }

   async function processSimpleField(fieldId, config) {
       var field = document.querySelector(config.elementId);
       if (field) {
           var fieldValue;

           if(fieldId == "RichText") fieldValue = document.querySelector("#div_editor1 iframe").contentDocument.body.innerHTML;
           else if(fieldId == "LocationImage") fieldValue = document.querySelector("#fileInput").dataset.fileResponse;
           else if(fieldId == "isYextRestrict") fieldValue = field.checked;
           else if(fieldId == "Geolocation") fieldValue = '{"lat":"' + document.querySelector(config.latitude.elementId).value + '","lng":"' + document.querySelector(config.longitude.elementId).value + '"}';
           else fieldValue = field.value;

           if(!fieldValue) return;

           await createDynamicElement(config.xmlFieldName, fieldId, config.type, fieldValue, true);
       }
   }

   async function processOpeningHours(fieldId, config) {
       for (const day of days) {
           const containerId = day.toLowerCase() + config.elementId;
           const dayHoursContainer = document.querySelector('#' + containerId).children;
           let isClosed = false;
           const dayDynamicElementParent = await getDynamicElement(config.xmlFieldName, fieldId, config.type, '');

           await dayDynamicElementParent.appendChild(
               await createDynamicElement(config.nestedFields.dayName.xmlFieldName, "DayName", config.nestedFields.dayName.type, day, false)
           );
           
           if(dayHoursContainer.length == 1 && dayHoursContainer[0].value == "Closed") {
               isClosed = true;
               const startCloseParent = await getDynamicElement(config.nestedFields.timeSlots.xmlFieldName, config.nestedFields.timeSlots.xmlFieldName, config.nestedFields.timeSlots.type, '');

               await startCloseParent.appendChild(
                   await createDynamicElement(config.nestedFields.timeSlots.nestedFields.open.xmlFieldName, "Open", config.nestedFields.timeSlots.nestedFields.open.type, '', false)
               );
               await startCloseParent.appendChild(
                   await createDynamicElement(config.nestedFields.timeSlots.nestedFields.close.xmlFieldName, "Close", config.nestedFields.timeSlots.nestedFields.close.type, '', false)
               );

               dayDynamicElementParent.appendChild(startCloseParent);
           } else {
               const inputs = document.querySelectorAll('#' + containerId + " input");
               for (const element of inputs) {
                   const openCloseOP = element.value.split("-");
                   
                   if(openCloseOP.length != 2) continue;

                   const startCloseParent = await getDynamicElement(config.nestedFields.timeSlots.xmlFieldName, config.nestedFields.timeSlots.xmlFieldName, config.nestedFields.timeSlots.type, '');
                   
                   await startCloseParent.appendChild(
                       await createDynamicElement(config.nestedFields.timeSlots.nestedFields.open.xmlFieldName, "Open", config.nestedFields.timeSlots.nestedFields.open.type, openCloseOP[0].trim(), false)
                   );
                   
                   await startCloseParent.appendChild(
                       await createDynamicElement(config.nestedFields.timeSlots.nestedFields.close.xmlFieldName, "Close", config.nestedFields.timeSlots.nestedFields.close.type, openCloseOP[1].trim(), false)
                   );

                   dayDynamicElementParent.appendChild(startCloseParent);
               }
           }
           
           await dayDynamicElementParent.appendChild(
               await createDynamicElement(config.nestedFields.isClosed.xmlFieldName, "isClosed", config.nestedFields.isClosed.type, isClosed, false)
           );

           xmlBuilder.documentElement.appendChild(dayDynamicElementParent);
       }
   }

   async function processContactDetails(fieldId, config) {
       const contactCards = document.querySelectorAll('[id^="contact-card-id-"]');
       for (const contact of contactCards) {
           const dynamicElement = await getDynamicElement(config.xmlFieldName, fieldId, config.type, '');
           
           const contactPhone = contact.querySelector('.contact-phone').textContent.trim();

           if(!contactPhone) continue;

           const nameField = await createDynamicElement(
               config.nestedFields.contactName.xmlFieldName,
               "ContactName",
               config.nestedFields.contactName.type,
               (contact.querySelector('.contact-name').textContent.trim() ?? "General"),
               false
           );
           
           const jobField = await createDynamicElement(
               config.nestedFields.jobPosition.xmlFieldName,
               "JobPosition",
               config.nestedFields.jobPosition.type,
               contact.querySelector('.contact-job').textContent.trim(),
               false
           );
           
           const emailField = await createDynamicElement(
               config.nestedFields.emailAddress.xmlFieldName,
               "EmailAddress",
               config.nestedFields.emailAddress.type,
               contact.querySelector('.contact-email a').textContent.trim(),
               false
           );
           
           const phoneField = await createDynamicElement(
               config.nestedFields.phoneNumber.xmlFieldName,
               "PhoneNumber1",
               config.nestedFields.phoneNumber.type,
               contactPhone,
               false
           );

           dynamicElement.appendChild(nameField);
           dynamicElement.appendChild(jobField);
           dynamicElement.appendChild(emailField);
           dynamicElement.appendChild(phoneField);

           xmlBuilder.documentElement.appendChild(dynamicElement);
       }
   }

   async function processFileCards(fieldName, config) {
       const fileCards = document.querySelectorAll('[id^="file-card-id-"]');
       for (const filed of fileCards) {
           const fileName = filed.querySelector('.file-name').textContent.trim();
           const fileValue = filed.querySelector('.file-value').dataset.fileResponse.trim();

           if(!fileName || !fileValue) continue;

           const dynamicElement = await getDynamicElement(config.xmlFieldName, fieldName, config.type, '');

           await dynamicElement.appendChild(
               await createDynamicElement(config.nestedFields.priceName.xmlFieldName, 'PriceName', config.nestedFields.priceName.type, fileName, false)
           );

           await dynamicElement.appendChild(
               await createDynamicElement(config.nestedFields.locationPriceList.xmlFieldName, 'LocationPriceList', config.nestedFields.locationPriceList.type, fileValue, false)
           );

           xmlBuilder.documentElement.appendChild(dynamicElement);
       }
   }

   async function processPublisherImages(fieldName, config) {
       const publisherCards = document.querySelectorAll('[id^="GMB-card-id-"]');
       for (const filed of publisherCards) {
           const publisher = filed.querySelector('.file-Publisher').textContent.trim();
           const fileValue = filed.querySelector('.file-value').dataset.fileResponse.trim();
           const fileDescription = filed.querySelector('.file-Description').textContent.trim();

           if(!publisher || !fileValue) continue;

           const dynamicElement = await getDynamicElement(config.xmlFieldName, fieldName, config.type, '');

           await dynamicElement.appendChild(
               await createDynamicElement(config.nestedFields.publisher.xmlFieldName, 'Publisher', config.nestedFields.publisher.type, publisher, false)
           );

           await dynamicElement.appendChild(
               await createDynamicElement(config.nestedFields.file.xmlFieldName, 'File', config.nestedFields.file.type, fileValue, false)
           );

           await dynamicElement.appendChild(
               await createDynamicElement(config.nestedFields.description.xmlFieldName, 'Description', config.nestedFields.description.type, fileDescription, false)
           );

           xmlBuilder.documentElement.appendChild(dynamicElement);
       }
   }

   async function processAddPages(fieldName, config) {
       const pageCards = document.querySelectorAll('[id^="page-card-id-"]');
       for (const addPages of pageCards) {
           const dynamicElement = await getDynamicElement(config.xmlFieldName, fieldName, config.type, '');
           
           const pageName = addPages.querySelector('.page-name').textContent.trim();
           const pageLink = addPages.querySelector('.page-url').textContent.trim()

           if(!pageName || !pageLink) continue;

           await dynamicElement.appendChild(
               await createDynamicElement(config.nestedFields.pageName.xmlFieldName, 'PageName', config.nestedFields.pageName.type, pageName, false)
           );

           await dynamicElement.appendChild(
               await createDynamicElement(config.nestedFields.pageUrl.xmlFieldName, 'PageUrl', config.nestedFields.pageUrl.type, pageLink, false)
           );

           xmlBuilder.documentElement.appendChild(dynamicElement);
       }
   }

   async function processProductCards(fieldName, config) {
       const productCards = document.querySelectorAll('[id^="pro-link-card-id-"]');
       for (const addProducts of productCards) {
           const dynamicElement = await getDynamicElement(config.xmlFieldName, fieldName, config.type, '');
           const productName = addProducts.querySelector('.pro-link-name').textContent.trim();
           const productLink = addProducts.querySelector('.pro-link').textContent.trim();

           if(!productName || !productLink) continue;

           await dynamicElement.appendChild(
               await createDynamicElement(config.nestedFields.name.xmlFieldName, 'Name', config.nestedFields.name.type, productName, false)
           );

           await dynamicElement.appendChild(
               await createDynamicElement(config.nestedFields.link.xmlFieldName, 'Link', config.nestedFields.link.type, productLink, false)
           );

           xmlBuilder.documentElement.appendChild(dynamicElement);
       }
   }
</script>
<script
   src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBYQKXwHhI8LwTxfxK8PQ3nFZAQc4nsjqU&libraries=places&callback=initMap"
   async defer></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/intlTelInput.min.js"></script>