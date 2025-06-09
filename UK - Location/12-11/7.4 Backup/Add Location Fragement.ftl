<link rel="stylesheet" href="/documents/d/global/rte_theme_default-1">
   <script type="module" src="https://www.cemexgo.com/cdn/web-components/latest/cmx-web-components/cmx-web-components.esm.js"></script>
   <script nomodule src="https://www.cemexgo.com/cdn/web-components/latest/cmx-web-components/cmx-web-components.js"></script>

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

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/css/intlTelInput.css" />

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
                              <cwc-icon name="camera" color="bright-blue"></cwc-icon> 
                              <input type="file" id="fileInput" />
                              <label for="fileInput">${languageUtil.get(locale, "locationImage", "Upload Photo")}</label>
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
               <button type="button" class="btn btn-secondary common-btn popup-close" data-dismiss="popup">Cancel</button>
               <button type="submit" id="btnSubmit" class="btn btn-primary popup-close common-btn blue-btn submit-hours" data-dismiss="popup">Save</button>
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
                           <div class="floating-input">
                              <input class="input-focus" type="text" id="contactname" autocomplete="off" />
                              <label for="emailaddress">
                                 ${languageUtil.get(locale, "contactName", "Contact Name")}
                              </label>
                           </div>
                        </div>
                     </div>
                     <div class="col-md-6">
                        <div class="form-group">
                           <div class="form-item">
                              <select class="form-control" id="job-position">
                                  [#if jobPositionsFromObj?size gt 1]
                                      [#list jobPositionsFromObj as jobName]
                                          <option value="${jobName}">${jobName}</option>
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
                                    <input type="file" id="GMBfile" required />
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

<!-- Intial data -->
<script>

</script>

<!-- Opening hours -->
<script>
	var dynamicCountryCode = "GB"
	var days = [
       "Monday",
       "Tuesday",
       "Wednesday",
       "Thursday",
       "Friday",
       "Saturday",
       "Sunday"
   ];

   days.forEach((day) => {
	    var dayElement = "<li> <span class='row'> <span class='col-md-6'> <span class='day-value' data-day='" + day.toLowerCase() + "'>" + day + ":</span> </span>" +
	        "<span class='col-md-4'><span id='" + day.toLowerCase() + "-time-container'><input type='text' placeholder='—:— - —:—'></span> </span>" +
	        "<span class='col-md-2'><a class='edit-time " + day.toLowerCase() + "-edit' data-toggle='modal' data-target='.bs-hours-modal'>" +
	        "<cwc-icon name='edit' color='true-black'></cwc-icon></a></span> </span></li>";

	    var weekElement = document.querySelector("ul.week-list");
	    weekElement.insertAdjacentHTML('beforeend', dayElement);
	});


   // Open model with value based on the button
   function toggleCheckboxes(enableClasses, disableClasses) {
    // Disable checkboxes for the provided disable classes
       disableClasses.forEach(function (className) {
           document.querySelectorAll(className).forEach(function (checkbox) {
               checkbox.checked = false;
           });
       });

       // Enable checkboxes for the provided enable classes
       enableClasses.forEach(function (className) {
           document.querySelectorAll(className).forEach(function (checkbox) {
               checkbox.checked = true;
           });
       });
   }

   document.querySelector(".edit-all-hours").addEventListener("click", function () {
       toggleCheckboxes([".common-chekbox"], [".sat-sun", ".mon-fri"]);
   });

   document.querySelector(".mon-to-fri").addEventListener("click", function () {
       toggleCheckboxes([".mon-fri"], [".common-chekbox", ".sat-sun"]);
   });

   document.querySelector(".sat-to-sun").addEventListener("click", function () {
       toggleCheckboxes([".sat-sun"], [".mon-fri", ".common-chekbox"]);
   });

document.querySelectorAll('.edit-time').forEach(function(element) {
    element.addEventListener('click', function() {
        // Clear checked state of all checkboxes in the modal
        document.querySelectorAll('.bs-hours-modal .common-chekbox').forEach(function(checkbox) {
            checkbox.checked = false;
        });

        // Get the day name from the parent element
        let dayname = element.closest('li').querySelector('.day-value').dataset.day;

        // Check the checkbox that matches the day name
        let matchingCheckbox = document.querySelector(".bs-hours-modal input[value="+dayname+"]");
        if (matchingCheckbox) {
            matchingCheckbox.checked = true;
        }

        // Clear the type-time-container content
        document.querySelector('#type-time-container').innerHTML = '';

        // Get the time inputs from the parent row
        let timeInputs = element.closest('li').querySelectorAll('.col-md-4 input');

        if (timeInputs.length === 1) {
            setValueInTimeModel(timeInputs[0], false);
        } else {
            document.querySelector('#opening-hours-type').value = 'Splitting';
            timeInputs.forEach(function(input) {
                setValueInTimeModel(input, true);
            });
        }
    });
});

function setValueInTimeModel(timeElement, isSplit) {
    modelOpeningSave();
    let timeValue = timeElement.value;
    let idPrefix = timeElement.parentElement.id.replace('-time-container', '');
    document.querySelector("#"+idPrefix).checked = true;

    if (timeValue === 'Closed') {
        document.querySelector('#opening-hours-type').value = 'Closed';
        document.querySelector('#close-time-row').style.display = 'none';
        document.querySelector('#close').checked = true;
    } else {
        if (!isSplit) {
            document.querySelector('#opening-hours-type').value = 'Open';
        }
        addStartEndRowElement(timeValue);
    }

    document.querySelector('#close').checked = false;
    document.querySelector('#close-time-row').style.display = 'none';
    document.querySelector('#new-splitting-row').style.display = 'none';
}

function modelOpeningSave(isDisable = true) {
    document.querySelector('#btnSubmit').disabled = isDisable;
}

function addStartEndRowElement(timeValue) {
    let startTimeValue = "";
    let closeTimeValue = "";
    let times = timeValue.split(" - ");

    if (timeValue) {
        startTimeValue = times[0];
        closeTimeValue = times[1];
    }

    // String concatenation for constructing the row element
    let startEndRow = 
        '<div class="row time-row">' +
            '<div class="col-md-6">' +
                '<div class="form-group time-form-group">' +
                    '<div class="form-item time-form-item">' +
                        '<input type="time" class="form-control timepicker-24-hr start-time" value="' + startTimeValue + '" />' +
                        '<label for="start-time">Open time</label>' +
                    '</div>' +
                '</div>' +
            '</div>' +
            '<div class="col-md-6">' +
                '<div class="form-group time-form-group">' +
                    '<div class="form-item time-form-item">' +
                        '<input type="time" name="timepicker-24-hr" class="form-control timepicker-24S-hr close-time" value="' + closeTimeValue + '" />' +
                        '<label for="close-time">Close time</label>' +
                    '</div>' +
                '</div>' +
            '</div>' +
            '<div class="col-md-12">' +
                '<p class="error-message"></p>' +
            '</div>' +
        '</div>';

    document.querySelector("#type-time-container").insertAdjacentHTML('beforeend', startEndRow);
}


</script>


<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
<script src="/documents/d/global/rte-1"></script>
<script src="/documents/d/global/all_plugins-1"></script>
<script src="/documents/d/global/phone-1"></script>
<script src="/documents/d/global/googlemap-1"></script>
<script src="/documents/d/global/postalcode-1"></script>
<script
   src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBYQKXwHhI8LwTxfxK8PQ3nFZAQc4nsjqU&libraries=places&callback=initMap"
   async defer></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/intlTelInput.min.js"></script>