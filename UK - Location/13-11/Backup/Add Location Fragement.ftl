<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/css/intlTelInput.css" />
<link rel="stylesheet" href="/documents/d/global/rte_theme_default-1">
<link rel="stylesheet" href="/documents/d/global/sh_toaster_css">

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
               <button type="button" id="hours-cancel" class="btn btn-secondary common-btn popup-close" data-dismiss="popup">Cancel</button>
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

<script src="/documents/d/global/sh_toaster_js"></script> 


<!-- Intial data -->
<script>
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

	 var dynamicCountryCode = "GB";
   var currentCountry = "GB";
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

    const countrySelect = document.getElementById("country");
    let options = '<option value="" disabled="" selected="">Country</option>';
    countries.forEach(function (country) {
        options += '<option value="' + country.name + '" ' + (country.code === currentCountry ? 'selected' : '') + '>' + country.name + '</option>';
    });
    countrySelect.innerHTML = options;
</script>

<script type="module" src="https://www.cemexgo.com/cdn/web-components/latest/cmx-web-components/cmx-web-components.esm.js"></script>
<script nomodule src="https://www.cemexgo.com/cdn/web-components/latest/cmx-web-components/cmx-web-components.js"></script>

<script>
let productCardId = 1;

function getProductHTML(productName, productCatId, productLink) {
    return "<div class='col-md-4'>" +
           "<div class='pro-link-card' id='pro-link-card-id-" + (productCardId++) + "'>" +
           "<h2 class='pro-link-name' id='" + productCatId + "'>" + productName + "</h2>" +
           "<a class='pro-link-card-edit'>" +
           "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
           "</a>" +
           "<a class='pro-link-card-remove'>" +
           "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
           "</a>" +
           "<p class='pro-link'>" + productLink + "</p>" +
           "</div>" +
           "</div>";
}

function generateProductHTMLAndAppend(productName, productCatId, productLink) {
    const productCard = getProductHTML(productName, productCatId, productLink);
    document.getElementById('pro-link-card-container').insertAdjacentHTML('beforeend', productCard);
}

document.getElementById('save-product').addEventListener('click', function(e) {
    e.preventDefault();
    
    const operationType = document.getElementById('save-product').textContent;
    const productCatIdElement = document.getElementById('pro-link-name');
    const productCatId = productCatIdElement.value;
    const productName = productCatIdElement.options[productCatIdElement.selectedIndex].text;
    const productLink = document.getElementById('pro-link').value || '-';
    
    if (!productCatId || !productLink || productCatId=="-" || productLink=="-") {
        console.log(fillRequiredField);
        return;
    }
    
    if (operationType === "Save") {
        generateProductHTMLAndAppend(productName, productCatId, productLink);
        console.log(tosterMessageSaveSuccess);
        document.getElementById('bs-product-modal').classList.remove('open');
    } else {
        if (updateProductId) {
            const productCard = document.getElementById(updateProductId);
            productCard.querySelector('.pro-link-name').textContent = productName;
            productCard.querySelector('.pro-link').textContent = productLink;
            console.log(tosterMessageUpdateSuccess);
            document.getElementById('bs-product-modal').classList.remove('open');
        }
    }
    resetProductModal();
});

document.querySelector('.add-product').addEventListener('click', function() {
    resetProductModal();
});

function resetProductModal() {
    document.getElementById('pro-link-name').value = "";
    document.getElementById('pro-link').value = "";
    document.getElementById('save-product').textContent = saveLabel;
}

function setDataInProductModal(name, value, update) {
    resetProductModal();
    
    if (name && name !== '-') {
        document.getElementById('pro-link-name').value = name;
    }
    
    if (value && value !== '-') {
        const proLinkElement = document.getElementById('pro-link');
        proLinkElement.value = value;
        proLinkElement.parentElement.classList.add('move-form-label');
    }
    
    if (update) {
        document.getElementById('save-product').textContent = updateLabel;
    }
}

document.body.addEventListener('click', function(e) {
    if (e.target.closest('.pro-link-card-remove')) {
        const productCard = e.target.closest('.col-md-4');
        productCard.remove();
        console.log(tosterMessageDeletedSuccess);
    }
});

document.body.addEventListener('click', function(e) {
    if (e.target.closest('.pro-link-card-edit')) {
        const productCard = e.target.closest('.pro-link-card');
        const productName = productCard.querySelector('.pro-link-name').textContent.trim();
        const productLink = productCard.querySelector('.pro-link').textContent.trim();
        updateProductId = productCard.getAttribute('id');
        
        setDataInProductModal(
            productName,
            productLink,
            true
        );
        document.getElementById('bs-product-modal').classList.add('open');
    }
});
</script>
<script src="/documents/d/global/page-crud"></script>
<script src="/documents/d/global/opening-hours"></script>
<script src="/documents/d/global/contact-card"></script>
<script src="/documents/d/global/rte-1"></script>
<script src="/documents/d/global/all_plugins-1"></script>
<script src="/documents/d/global/phone-1"></script>
<script src="/documents/d/global/googlemap-1"></script>
<script src="/documents/d/global/postalcode-1"></script>

<script
   src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBYQKXwHhI8LwTxfxK8PQ3nFZAQc4nsjqU&libraries=places&callback=initMap"
   async defer></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/intlTelInput.min.js"></script>