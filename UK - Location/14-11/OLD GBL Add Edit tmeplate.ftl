<!-- All css libraries -->
   <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/css/intlTelInput.css">
   <link rel="stylesheet" href="/documents/20152/60315374/sh_toaster.css">
   <link rel="stylesheet" href="/documents/20152/60315374/add-location.css">

   <link rel="stylesheet" href="/documents/20152/60315374/rte_theme_default.css">
    <style>
        .time-row .error-message {
            color: red!important;
            display: none;
            margin: 5px 0px 8px 0px!important;
        }
        .time-form-group, .time-form-item {
           margin: 0;
         }
         .time-row {
            margin-bottom: 10px!important;
         }

         .pro-link-card-container .pro-link-card {
             padding: 24px;
             position: relative;
             width: 100%;
         }

         .pro-link-card {
             background-color: #fff;
             box-shadow: 0 3px 10px rgb(0 0 0 / 0.2);
             padding: 24px 300px 24px 24px;
             margin-bottom: 20px;
             border-radius: 8px;
             position: relative;
         }

         .pro-link-card h2 {
             margin-top: 0px;
             color: #001B3A;
             font-size: 16px;
             display: inline;
         }

         .pro-link-card-container .pro-link-card .pro-link-card-edit {
             right: 45px;
         }

         .pro-link-card a.pro-link-card-edit {
             top: 23px;
             position: absolute;
             right: 45px;
             cursor: pointer;
         }

         .pro-link-card-container .pro-link-card .pro-link-card-remove {
             right: 24px;
             left: inherit;
         }

         .pro-link-card a.pro-link-card-remove {
             top: 25px;
             position: absolute;
             left: 90%;
             cursor: pointer;
         }

         .pro-link-card .pro-link {
             white-space: nowrap;
             overflow: hidden;
             text-overflow: ellipsis;
             width: 230px;
         }

        .multiselect-container {
            display: block;
            width: 100%;
            height: 40px;
            background: transparent;
            border: solid 1px #B0B0B0;
            transition: all .3s ease;
            padding: 0 15px;
            border-radius: 8px;
            font-size: 16px;
            color: #333333;
            box-shadow: none;
            overflow:auto
        }
        .multiselect-tag { display: inline-block; padding: 3px 8px;margin: 7px 2px; background: #337ab7; color: white; border-radius: 3px; font-size: 12px; }
        .multiselect-tag-remove { margin-left: 5px; cursor: pointer; }
        .multiselect-tag-remove:hover { color: #ff9999; }
        .multiselect-dropdown {list-style: none; width: 100%; max-height: 200px; overflow-y: auto; display: none; position: absolute; top: 100%; left: 0; right: 0; z-index: 1000; background: white; border: 1px solid rgba(0,0,0,.15); border-radius: 4px; box-shadow: 0 6px 12px rgba(0,0,0,.175); }
        .multiselect-option { display: block; padding: 6px 12px; cursor: pointer; color: #333; }
        .multiselect-option:hover { background: #f5f5f5; text-decoration: none; }
        .multiselect-option.selected { background: #f5f5f5; color: #337ab7; font-weight: bold; }
        .show { display: block !important; }
        .plant-label-focus {top:-10px!important}

    </style>

   <script src="/documents/20152/60315374/rte.js"></script>
   <script src="/documents/20152/60315374/all_plugins.js"></script>

   <!-- All script libraries -->
   <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
   <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
   <script src="/documents/20152/60315374/sh_toaster.js"></script>
   <script type="module" src="https://www.cemexgo.com/cdn/web-components/latest/cmx-web-components/cmx-web-components.esm.js"></script>
   <script nomodule src="https://www.cemexgo.com/cdn/web-components/latest/cmx-web-components/cmx-web-components.js"></script>
   <script src="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/intlTelInput.min.js"></script>
   <script src="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/utils.js"></script>

   <#assign listOfEUCountriesdd = [
       {
           "name": "Germany",
           "languageId": "de_DE",
           "JobPosition": 60581901
       },
       {
           "name": "United Kingdom",
           "languageId": "en_GB",
           "JobPosition": 60581696
       },
       {
           "name": "Spain",
           "languageId": "es_ES",
           "JobPosition": 60581891
       },
       {
           "name": "Czech Republic",
           "languageId": "cs_CZ",
           "JobPosition": 60581986
       },
       {
           "name": "Poland",
           "languageId": "pl_PL",
           "JobPosition": 60581913
       },
       {
           "name": "France",
           "languageId": "fr_FR",
           "JobPosition": 60582034
       },
       {
           "name": "Croatia",
           "languageId": "hr_HR",
           "JobPosition": 60581954
       }
   ]>


   <#assign currentLanguageId = themeDisplay.getLanguageId()>
   <#assign jobpositionvalue = "">

   <#list listOfEUCountriesdd as country>
     <#if country.languageId == currentLanguageId>
   	    <#assign jobpositionvalue = country.JobPosition />
     </#if>
   </#list>


   <#assign ddlRecordLocalService = serviceLocator.findService("com.liferay.dynamic.data.lists.service.DDLRecordLocalService")/>
   <#assign positionRecords = ddlRecordLocalService.getRecords(jobpositionvalue)/>

   <#assign parentVocabularyName = "Topic">
<#assign parentVocabulary = staticUtil["com.liferay.asset.kernel.service.AssetVocabularyLocalServiceUtil"].getGroupVocabulary(groupId, parentVocabularyName)>

<#-- Find the "Product" category within the "Topic" vocabulary -->
<#assign productCategory = "">
<#assign topLevelCategories = staticUtil["com.liferay.asset.kernel.service.AssetCategoryLocalServiceUtil"].getVocabularyRootCategories(parentVocabulary.getVocabularyId(), -1, -1, null)>
<#list topLevelCategories as category>
    <#if category.getName() == "Product">
        <#assign productCategory = category>
        <#break>
    </#if>
</#list>

<#-- Get subcategories of the "Product" category -->
<#if productCategory?has_content>
    <#assign childCategories = staticUtil["com.liferay.asset.kernel.service.AssetCategoryLocalServiceUtil"].getChildCategories(productCategory.getCategoryId())>
<#else>
    <p>Product category not found in the Topic vocabulary.</p>
</#if>


   <#assign journalService = serviceLocator.findService("com.liferay.journal.service.JournalArticleService") />

   <#assign article = journalService.getArticle(20152,"60708937")/>
    
   <#assign docXml = saxReaderUtil.read(article.getContentByLocale(themeDisplay.getLanguageId())) />
    
   <#assign locationName = docXml.valueOf("//dynamic-element[@name='LocationName']/dynamic-content/text()")!"" />

   <#assign address  = docXml.valueOf("//dynamic-element[@name='Address']/dynamic-content/text()")!""/>

   <#assign selectPlanType  = docXml.valueOf("//dynamic-element[@name='SelectPlanType']/dynamic-content/text()")!""/>

   <#assign address2  = docXml.valueOf("//dynamic-element[@name='Address2']/dynamic-content/text()")!"" />

   <#assign companyName  = docXml.valueOf("//dynamic-element[@name='CompanyName']/dynamic-content/text()")!"" />

   <#assign townCity  = docXml.valueOf("//dynamic-element[@name='TownCity']/dynamic-content/text()")!"" />

   <#assign country  = docXml.valueOf("//dynamic-element[@name='Country']/dynamic-content/text()")!"" />

   <#assign postCode  = docXml.valueOf("//dynamic-element[@name='PostCode']/dynamic-content/text()")!"" />

   <#assign geoLocation  = docXml.valueOf("//dynamic-element[@name='GeoLocation']/dynamic-content/text()")!"" />

   <#assign phoneNumber  = docXml.valueOf("//dynamic-element[@name='PhoneNumber']/dynamic-content/text()")!"" />

   <#assign contactName  = docXml.valueOf("//dynamic-element[@name='ContactName']/dynamic-content/text()")!"" />

   <#assign jobPosition  = docXml.valueOf("//dynamic-element[@name='JobPosition']/dynamic-content/text()")!"" />

   <#assign emailAddress  = docXml.valueOf("//dynamic-element[@name='EmailAddress']/dynamic-content/text()")!"" />

   <#assign uploadPhoto  = docXml.valueOf("//dynamic-element[@name='LocationImage']/dynamic-content/text()")!"" />

   <#assign openingHours  = docXml.valueOf("//dynamic-element[@name='OpeningHours']/dynamic-content/text()")!"" />

   <#assign longitude  = docXml.valueOf("//dynamic-element[@name='Longitude']/dynamic-content/text()")!"" />

   <#assign latitude  = docXml.valueOf("//dynamic-element[@name='Latitude']/dynamic-content/text()")!"" />

   <#assign publisherInformation  = docXml.valueOf("//dynamic-element[@name='PublisherInformation']/dynamic-content/text()")!"" />

   <#assign contactInformation  = docXml.valueOf("//dynamic-element[@name='ContactInformation']/dynamic-content/text()")!"" />

   <#assign pageInformation  = docXml.valueOf("//dynamic-element[@name='PageInformation']/dynamic-content/text()")!"" />

   <#assign documentInformation  = docXml.valueOf("//dynamic-element[@name='DocumentInformation']/dynamic-content/text()")!"" />

   <#assign fileInformation  = docXml.valueOf("//dynamic-element[@name='FileInformation']/dynamic-content/text()")!"" />

   <#assign plantProducts  = docXml.valueOf("//dynamic-element[@name='plantProducts']/dynamic-content/text()")!"" />

   <#assign selectTheProduct  = docXml.valueOf("//dynamic-element[@name='selectTheProduct']/dynamic-content/text()")!"" />

   <#assign productLink  = docXml.valueOf("//dynamic-element[@name='productLink']/dynamic-content/text()")!"" />
   
   <#assign productCardRemoveMessage  = docXml.valueOf("//dynamic-element[@name='productCardRemoveMessage']/dynamic-content/text()")!"" />
   
   <#assign addFile  = docXml.valueOf("//dynamic-element[@name='AddFile']/dynamic-content/text()")!"" />

   <#assign addPage  = docXml.valueOf("//dynamic-element[@name='AddPage']/dynamic-content/text()")!"" />

   <#assign addPublisher  = docXml.valueOf("//dynamic-element[@name='AddPublisher']/dynamic-content/text()")!"" />

   <#assign addProduct  = docXml.valueOf("//dynamic-element[@name='AddProduct']/dynamic-content/text()")!"" />

   <#assign AddContact  = docXml.valueOf("//dynamic-element[@name='AddContact']/dynamic-content/text()")!"" />

   <#assign tosterMessageSaveSuccess  = docXml.valueOf("//dynamic-element[@name='TosterMessageSaveSuccess']/dynamic-content/text()")!"" />

   <#assign tosterMessageUpdateSuccess  = docXml.valueOf("//dynamic-element[@name='TosterMessageUpdateSuccess']/dynamic-content/text()")!"" />

   <#assign LocationCreatedMessage  = docXml.valueOf("//dynamic-element[@name='LocationCreatedMessage']/dynamic-content/text()")!"" />

   <#assign LocationFailMessage  = docXml.valueOf("//dynamic-element[@name='LocationFailMessage']/dynamic-content/text()")!"" />

   <#assign LocationUpdateSuccess  = docXml.valueOf("//dynamic-element[@name='LocationUpdateSuccess']/dynamic-content/text()")!"" />

   <#assign ImageValidate  = docXml.valueOf("//dynamic-element[@name='ImageValidate']/dynamic-content/text()")!"" />

   <#assign ImageExist  = docXml.valueOf("//dynamic-element[@name='ImageExist']/dynamic-content/text()")!"" />

   <#assign ValidateAllFields  = docXml.valueOf("//dynamic-element[@name='ValidateAllFields']/dynamic-content/text()")!"" />

   <#assign contactCardRemoveMessage  = docXml.valueOf("//dynamic-element[@name='contactCardRemoveMessage']/dynamic-content/text()")!"" />

   <#assign allValidationMessage  = docXml.valueOf("//dynamic-element[@name='allValidationMessage']/dynamic-content/text()")!"" />

   <#assign fileCardRemoveMessage  = docXml.valueOf("//dynamic-element[@name='fileCardRemoveMessage']/dynamic-content/text()")!"" />

   <#assign pageCardRemoveMessage  = docXml.valueOf("//dynamic-element[@name='pageCardRemoveMessage']/dynamic-content/text()")!"" />


   <#assign FileRequireValidation  = docXml.valueOf("//dynamic-element[@name='FileRequireValidation']/dynamic-content/text()")!"" />

   <#assign imageRequireValidation  = docXml.valueOf("//dynamic-element[@name='imageRequireValidation']/dynamic-content/text()")!"" />

   <#assign GMBCardRemoveMessage  = docXml.valueOf("//dynamic-element[@name='GMBCardRemoveMessage']/dynamic-content/text()")!"" />

   <#assign AddLocation  = docXml.valueOf("//dynamic-element[@name='AddLocation']/dynamic-content/text()")!"" />


   <#assign SaveLocationLabel  = docXml.valueOf("//dynamic-element[@name='SaveLocationLabel']/dynamic-content/text()")!"" />

   <#assign currentLocationLabel  = docXml.valueOf("//dynamic-element[@name='currentLocationLabel']/dynamic-content/text()")!"" />

   <#assign editAllHoursLabel  = docXml.valueOf("//dynamic-element[@name='editAllHoursLabel']/dynamic-content/text()")!"" />

   <#assign editMonFriLabel  = docXml.valueOf("//dynamic-element[@name='editMonFriLabel']/dynamic-content/text()")!"" />

   <#assign editSatSunLabel  = docXml.valueOf("//dynamic-element[@name='editSatSunLabel']/dynamic-content/text()")!"" />

   <#assign mondayLabel  = docXml.valueOf("//dynamic-element[@name='mondayLabel']/dynamic-content/text()")!"" />

   <#assign tuesdayLabel  = docXml.valueOf("//dynamic-element[@name='tuesdayLabel']/dynamic-content/text()")!"" />

   <#assign wednesdayLabel  = docXml.valueOf("//dynamic-element[@name='wednesdayLabel']/dynamic-content/text()")!"" />

   <#assign thursdayLabel  = docXml.valueOf("//dynamic-element[@name='thursdayLabel']/dynamic-content/text()")!"" />

   <#assign fridayLabel  = docXml.valueOf("//dynamic-element[@name='fridayLabel']/dynamic-content/text()")!"" />

   <#assign saturdayLabel  = docXml.valueOf("//dynamic-element[@name='saturdayLabel']/dynamic-content/text()")!"" />

   <#assign sundayLabel  = docXml.valueOf("//dynamic-element[@name='sundayLabel']/dynamic-content/text()")!"" />

   <main>
      <div class="sh-toast-container" id="shToastContainerTop"></div>
      <div class="sh-toast-container" id="shToastContainerBottom"></div>
      <div class="add-location-main">
         <div class="container">
            <div class="location-modal">
               <div class="location-new-modal-content-inner">
                  <div class="location-new-header">
                     <h4 id="myModalLabel">${(AddLocation?has_content)?then(AddLocation, 'Add location')}</h4>
                  </div>
                  <div class="location-new-body">
                     <form id="locationForm" onsubmit="return false;">
                        <div class="row">
                           <div class="col-md-6">
                              <div class="form-group">
                                 <div class="form-item">
                                    <input type="text" id="locationname" class="LocationTitle"
                                       required/>
                                    <label for="locationname">${(locationName?has_content)?then(locationName, 'Location Name')} </label>
                                 </div>
                              </div>
                           </div>
                           <div class="col-md-6">
                              <div class="form-group">
                                 <div class="form-item">
                                    <label id="plant-label">${(selectPlanType?has_content)?then(selectPlanType, 'Select Product T')}</label>
                                    <div class="multiselect" id="planttype">
                                        <div class="multiselect-container" id="selectedContainer"></div>
                                        <ul class="multiselect-dropdown" id="optionsContainer">
                                            <#list childCategories as category>
                                                <li><a class="multiselect-option" data-value="${category.getCategoryId()}">${category.getName()}</a></li>
                                            </#list> 
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
                                    <input type="text" id="address" autocomplete="off" class="Address"
                                       required />
                                    <label for="address"> ${(address?has_content)?then(address, 'Address')} </label>
                                 </div>
                              </div>
                           </div>
                           <div class="col-md-6">
                              <div class="form-group">
                                 <div class="floating-input">
                                    <input type="text" id="addressone" autocomplete="off"
                                       class="Address2 input-focus" />
                                    <label for="addressone" class="focus-label">${(address2?has_content)?then(address2, 'Address 2')}</label>
                                 </div>
                              </div>
                           </div>
                        </div>
                        <div class="row">
                           <div class="col-md-6">
                              <div class="form-group">
                                 <div class="floating-input">
                                    <input type="text" id="company" autocomplete="off" class="CompanyName input-focus" />
                                    <label for="company" class="focus-label"> ${(companyName?has_content)?then(companyName, 'Company Name')}</label>
                                 </div>
                              </div>
                           </div>
                           <div class="col-md-6">
                              <div class="form-group">
                                 <div class="form-item">
                                    <input type="text" id="city" autocomplete="off" class="TownCity"
                                       required />
                                    <label for="city"> ${(townCity?has_content)?then(townCity, 'City')}</label>
                                 </div>
                              </div>
                           </div>
                        </div>
                        <div class="row">
                           <div class="col-md-6">
                              <div class="form-group">
                                 <div class="floating-input">
                                    <input type="text" id="state" autocomplete="off" class="State input-focus" />
                                    <label for="state">State</label>
                                 </div>
                              </div>
                           </div>
                           <div class="col-md-6">
                              <div class="form-group">
                                 <div class="form-item">
                                    <input type="text" id="region" autocomplete="off" class="Region"/>
                                    <label for="addressone" class="focus-label">Region</label>
                                 </div>
                              </div>
                           </div>
                        </div>
                        <div class="row">
                           <div class="col-md-6">
                              <div class="form-group">
                                 <div class="form-item">
                                    <input type="text" id="postcode" autocomplete="off"
                                       class="Postcode" required />
                                    <label for="postcode"> ${(postCode?has_content)?then(postCode, 'PostCode')}</label>
                                        <span class="text-danger" id="postcode-error"></span>
                                 </div>
                              </div>
                           </div>
                           <div class="col-md-6">
                              <div class="form-group">
                                 <div class="form-item">
                                    <select class="form-control Country" name="country" id="country" required>
                                       <option value="" disabled selected>Country</option>
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
                                    <input type="tel" id="phonenumber" autocomplete="off"
                                       class="PhoneNumber" required />
                                    <span class="text-danger" id="phoneNumber-error"></span>
                                 </div>
                              </div>
                              <div class="form-group">
                                 <div class="form-item">
                                    <input type="text" id="map-address" autocomplete="off" required />
   				                  <label for="map-address">${(geoLocation?has_content)?then(geoLocation, 'Map Address')} </label>
                                    <div id="address-suggestions"></div>
                                 </div>
                              </div>
                              <div class="latitude">
                                 <div class="form-group">
                                    <div class="form-item">
                                       <input type="text" id="latitude" autocomplete="off" required />
                                       <label for="latitude">${(latitude?has_content)?then(latitude, 'Latitude')} </label>
                                    </div>
                                 </div>
                                 <div class="form-group">
                                    <div class="form-item">
                                       <input type="text" id="longitude" autocomplete="off" 
                                          required />
                                       <label for="longitude">${(longitude?has_content)?then(longitude, 'Longitude')} </label>
                                    </div>
                                 </div>
                              </div>
                              <div style="margin-top: 40px">
                                 <button class="current-location" type="button">
                                 ${(currentLocationLabel?has_content)?then(currentLocationLabel, 'Current Location')}
                                 </button>
                              </div>
                           </div>
                        </div>
                        <div class="row">
                           <div class="col-md-12">
                              <h6>${(openingHours?has_content)?then(openingHours, 'Opening hours')}</h6>
                           </div>
                           <div class="col-md-5">
                              <ul class="week-list">
                              </ul>
                           </div>
                           <div class="col-md-5">
                              <div class="all-hours-wrapper">
                                 <button class="add-contact hours-btn edit-all-hours " type="button" data-target="bs-hours-modal" data-toggle="popup">
                                 ${(editAllHoursLabel?has_content)?then(editAllHoursLabel, 'Edit all hours')}
                                 </button>
                                 <button class="add-contact hours-btn mon-to-fri" type="button" data-target="bs-hours-modal" data-toggle="popup">
                                 ${(editMonFriLabel?has_content)?then(editMonFriLabel, 'Edit Mon-Fri')}
                                 </button>
                                 <button class="add-contact hours-btn sat-to-sun" type="button" data-target="bs-hours-modal" data-toggle="popup">
                                 ${(editSatSunLabel?has_content)?then(editSatSunLabel, 'Edit Sat-Sun')}                             
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
                                 <button class="add-contact" type="button" data-target="bs-contact-modal" data-toggle="popup">
                                    <cwc-icon name="plus" color="bright-blue"></cwc-icon>
                                   ${(AddContact?has_content)?then(AddContact, 'Add Contact')}
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
                                <h6>${(documentInformation?has_content)?then(documentInformation, 'Attach Documents')}</h6>
                           
                                <div class="add-tag-main">
                                 <button class="add-contact add-file add-doc" type="button" data-target="bs-file-modal" data-toggle="popup">
                                     <cwc-icon name="plus" color="bright-blue"></cwc-icon>
                                   ${(addFile?has_content)?then(addFile, 'Add File')}
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
                                  <button class="add-contact add-page add-doc" type="button" data-target="bs-page-modal" data-toggle="popup">
                                   <cwc-icon name="plus" color="bright-blue"></cwc-icon>
                                    ${(addPage?has_content)?then(addPage, 'Add Page')}
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
                                  <button class="add-contact add-product" type="button" data-target="bs-product-modal" data-toggle="popup">
                                   <cwc-icon name="plus" color="bright-blue"></cwc-icon>
                                    ${(addProduct?has_content)?then(addProduct, 'Add Product')}
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
                                 <button class="add-contact add-GMB" type="button" data-target="bs-GMB-modal" data-toggle="popup">
                                     <cwc-icon name="plus" color="bright-blue"></cwc-icon>
                                     ${(addPublisher?has_content)?then(addPublisher, 'Add Publisher')}
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
                              <h6 style="margin-bottom: 0px;">${(uploadPhoto?has_content)?then(uploadPhoto, 'Upload Location Photo')} </h6>
                              <div class="file-upload">
                                 <cwc-icon name="camera" color="bright-blue"></cwc-icon>
                                 <input type="file" id="fileInput" />
                                 <label for="fileInput">Upload Photo</label>
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
                                     <div id="div_editor1" class="RichText" > </div>
                                    <span class="text-danger" id="locationDescription-error"></span>
   		    		                </div>
                              </div>
                           </div>
                        </div>
                        


   		 <div class="row">
   			<input type="checkbox" id="yextSy" name="YextSync" value="true"  checked>
   			<label for="myCheckbox"> UberAll Sync</label>
   		</div>
   			
                        <div class="row">
                           <div class="col-lg-12">
                              <div class="location-btn-group">
                                 <button type="button" class="btn btn-default common-btn" data-dismiss="modal">
                                 ${(CancelLabel?has_content)?then(CancelLabel, 'Cancel')}
                                 </button>
                                 <button id="save" type="submit" class="btn btn-primary common-btn blue-btn"
                                    value="Save Location">${(SaveLocationLabel?has_content)?then(SaveLocationLabel, 'Save Location')}
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
    
      <div id="bs-hours-modal" class="bs-hours-modal popup ">
         <div class="popup-window">
            <div class="modal-content">
               <div class="modal-header">
                  <h4 class="modal-title" >${(openingHours?has_content)?then(openingHours, 'Opening hours')}</h4>
               </div>
               <div class="modal-body">
                  <div class="row">
                     <div class="col-md-12">
                        <ul class="week-list-main ">
                           <li>
                              <input class="common-chekbox mon-fri" type="checkbox" id="monday" value="monday" />
                              <label for="monday">M</label>
                           </li>
                           <li>
                              <input class="common-chekbox mon-fri" type="checkbox" id="tuesday"
                                 value="tuesday" />
                              <label for="tuesday">T</label>
                           </li>
                           <li>
                              <input class="common-chekbox mon-fri" type="checkbox" id="wednesday"
                                 value="wednesday" />
                              <label for="wednesday">W</label>
                           </li>
                           <li>
                              <input class="common-chekbox mon-fri" type="checkbox" id="thursday"
                                 value="thursday" />
                              <label for="thursday">T</label>
                           </li>
                           <li>
                              <input class="common-chekbox mon-fri" type="checkbox" id="friday" value="friday" />
                              <label for="friday">F</label>
                           </li>
                           <li>
                              <input class="common-chekbox sat-sun" type="checkbox" id="saturday"
                                 value="saturday" />
                              <label for="saturday">S</label>
                           </li>
                           <li>
                              <input class="common-chekbox sat-sun" type="checkbox" id="sunday" value="sunday" />
                              <label for="sunday">S</label>
                           </li>
                        </ul>
                     </div>
                  </div>
                  <div class="row">
                     <div class="col-md-12">
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
                     <div id="type-time-container">
                     </div>
                     <div class="row" id="close-time-row">
                        <div class="col-md-12">
                           <div class="form-group close-group" style="display: none;">
                              <input type="checkbox" id="close" checked="true" disabled />
                              <label for="close">Closed</label>
                           </div>
                        </div>
                     </div>
                     <button type="button" id="new-splitting-row"class="btn btn-default">Add New Splitting Row</button>
                  </div>

               </div>
               <div class="modal-footer">
                  <button type="button" class="btn btn-default common-btn popup-close" data-dismiss="popup">
                  Cancel
                  </button>
                  <button type="submit" id="btnSubmit" class="btn btn-primary popup-close common-btn blue-btn submit-hours"
                     data-dismiss="popup">
                  Save
                  </button>
               </div>
            </div>
         </div>
      </div>

    
      <div id="bs-contact-modal" class="bs-contact-modal popup ">
         <div class="popup-window">
            <div class="modal-content">
               <div class="modal-header">
                  <h4 class="modal-title">${(contactInformation?has_content)?then(contactInformation, 'Contact information')}</h4>
               </div>
               <form id="contactForm" onsubmit="return false;">
                  <div class="modal-body">
                     <input type="hidden" value="" class="update-id" />        
                     <div class="row">
                        <div class="col-md-6">
                           <div class="form-group">
                              <div class="floating-input">
                                 <input class="input-focus" type="text" id="contactname" autocomplete="off" />
                                 <label for="contactname" class="focus-label"> ${(contactName?has_content)?then(contactName, 'Contact Name')}</label>
                              </div>
                           </div>
                        </div>
                        <div class="col-md-6">
                           <div class="form-group">
                              <div class="form-item">
                                 <select class="form-control" id="job-position" >
                        				<#if positionRecords?size == 0>
                        				<option value="" disabled selected>Job position</option>
                        				<#else>
                        				<option value="" disabled selected>Job Position</option>
                        				<#list positionRecords as position>
                        				<#assign formValues = position.getDDMFormValues().getDDMFormFieldValues()>
                        				<#list formValues as value>
                        				<#if value.getName() == 'JobPosition'>
                        				<option value="${value.getValue().getString(locale)}">${value.getValue().getString(locale)}</option>
                        				</#if>
                        				</#list>  
                        				</#list>
                        				</#if>    
                        				</select>
                              </div>
                           </div>
                        </div>
                        <div class="col-md-6">
                           <div class="form-group">
                              <div class="form-item">
                                 <input type="email" id="emailaddress" autocomplete="off" placeholder=" "/>
                                 <label for="emailaddress"> ${(emailAddress?has_content)?then(emailAddress, 'Email address')}</label>
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
                     Cancel
                     </button>
                     <button id="save-contact" type="submit" class="btn btn-primary  common-btn blue-btn" value="Save Contact">
                     Save
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
                  <h4 class="modal-title">${(pageInformation?has_content)?then(pageInformation, 'Page information')}</h4>
               </div>
               <form id="contactForm" onsubmit="return false;">
                  <div class="modal-body">
                     <input type="hidden" value="" class="update-id" />        
                     <div class="row">
                        <div class="col-md-6">
                           <div class="form-group">
                            <div class="form-item">
                                 <input class="input-focus" type="text" id="pagename" autocomplete="off" required />
                                 <label for="pagename" class="focus-label">Page Name </label>
                             </div> 
                           </div>
                        </div>
                        <div class="col-md-6">
                           <div class="form-group">
                            <div class="form-item">     
                                 <input class="input-focus" type="url" id="fileUrl" autocomplete="off" name="homepage" required />
                                 <label for="pagename" class="focus-label">Page URL</label>
                              </div> 
                           </div>
                        </div>
                     </div>
                  </div>
                  <div class="modal-footer">
                     <button type="button" class="btn btn-default common-btn popup-close" data-dismiss="popup">
                     Cancel
                     </button>
                     <button id="save-page" type="submit" class="btn btn-primary  common-btn blue-btn" value="Save Page"
                        >
                     Save
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
                <h4 class="modal-title">${(addProduct?has_content)?then(addProduct, 'Add Product')}</h4>
             </div>
             <form id="" onsubmit="return false;">
                <div class="modal-body">
                   <input type="hidden" value="" class="update-id" />        
                   <div class="row">
                      <div class="col-md-6">
                         <div class="form-group">
                          <div class="form-item">
                              <select class="form-control ProductType" name="product-type" id="pro-link-name">
                                  <option value="">${(selectTheProduct?has_content)?then(selectTheProduct, 'Select the Product')}</option>     
                              </select>
                           </div> 
                         </div>
                      </div>
                      <div class="col-md-6">
                         <div class="form-group">
                          <div class="form-item">     
                               <input class="input-focus" type="url" id="pro-link" autocomplete="off" required />
                               <label for="pro-link" class="focus-label">${(productLink?has_content)?then(productLink, 'Product Link')}</label>
                            </div> 
                         </div>
                      </div>
                   </div>
                </div>
                <div class="modal-footer">
                   <button type="button" class="btn btn-default common-btn popup-close" data-dismiss="popup">
                   ${(CancelLabel?has_content)?then(CancelLabel, 'Cancel')}
                   </button>
                   <button id="save-product" type="submit" class="btn btn-primary  common-btn blue-btn" value="Save Product">Save
                   </button>
                </div>
             </form>
          </div>
       </div>

      <div id="bs-file-modal" class="bs-file-modal popup ">
         <div class="popup-window">
            <div class="modal-content">
               <div class="modal-header">
                  <h4 class="modal-title">${(fileInformation?has_content)?then(fileInformation, 'File information')}</h4>
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
                                 <label for="filename" class="focus-label">File Name</label>
                              </div>
                              </div>
                           </div>
                        </div>
                        <div class="col-md-6">
                           <div class="form-group">
                              <div class="form-item">
                              <div class="form-item">
                               <span class="control-fileupload">
                                      <label for="file">Choose a file Demo:</label>
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
                     Cancel
                     </button>
                     <button id="save-file" type="submit" class="btn btn-primary  common-btn blue-btn" value="Save File">
                     Save
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
                  <h4 class="modal-title"> ${(publisherInformation?has_content)?then(publisherInformation, 'Publisher Information')}</h4>
               </div>
               <form id="contactForm" onsubmit="return false;">
                  <div class="modal-body">
                     <input type="hidden" value="" class="file-update-id" />        
                     <div class="row">
                        <div class="col-md-12">
                           <div class="form-group">
                           <div class="form-item">
                              <div class="floating-input">
                                 <input class="input-focus" type="text" id="filePublisher" autocomplete="off" required />
                                 <label for="filename" class="focus-label">Publisher</label>
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
                                      <label for="fileGMB">Choose a file :</label>
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
                                    <input class="input-focus" type="text" id="fileDescription" autocomplete="off" required/>
                                    <label for="filename" class="focus-label">Description</label>
                                 </div>
                              </div>
                             </div>
                        </div>
                     </div>
                  </div>
                  <div class="modal-footer">
                     <button type="button" class="btn btn-default common-btn popup-close" data-dismiss="popup">
                     Cancel
                     </button>
                     <button id="save-GMB-data" type="submit" class="btn btn-primary  common-btn blue-btn" value="Save File" >
                     Save
                     </button>
                  </div>
               </form>
            </div>
         </div>
      </div>
   </main>

   <!-------------------Script for the google map feature------------------->

   <script>

var selectedCategoryIds = new Set();

document.addEventListener('DOMContentLoaded', () => {
    const container = document.getElementById('selectedContainer'),
    dropdown = document.getElementById('optionsContainer'),
    select = document.getElementById('hiddenSelect');

    container.addEventListener('click', () => dropdown.classList.add('show'));
    document.getElementById("plant-label").onclick = function() {setTimeout( () => document.getElementById('optionsContainer').classList.add('show'),10)};
    document.addEventListener('click', e => !e.target.closest('.multiselect') && dropdown.classList.remove('show'));

    dropdown.addEventListener('click', e => {
        if (e.target.classList.contains('multiselect-option')) {
            const value = e.target.dataset.value;
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

    
   $(document).ready(function() {
    var editor1 = new RichTextEditor("#div_editor1");
   });

   var defaultLatitude = 40.7128;
   var defaultLongitude = -74.006;
   var defaultMapZoomLevel = 8;
       
   $('.current-location').click(function () {
       getCurrentLocation();
   });

   $('#latitude, #longitude').keyup(function () {
       updateMap()
   });


   let map;
   let marker;
   let geocoder;

   function initMap() {
       const mapOptions = {
           center: { lat: defaultLatitude, lng: defaultLongitude
       },
           zoom: defaultMapZoomLevel
   };

   map = new google.maps.Map(document.getElementById("location-map"), mapOptions);
   geocoder = new google.maps.Geocoder();

   google.maps.event.addListener(map,"click", function (event) {
           placeMarker(event.latLng);
           updateCoordinates(event.latLng);
           getAddress(event.latLng);
       });
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
               function (position) {
                   const userLocation = {
                       lat: position.coords.latitude,
                       lng: position.coords.longitude
           };
           map.setCenter(userLocation);
           placeMarker(userLocation);
           updateCoordinates(userLocation);
           getAddress(userLocation);
       },
       function (error) {
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
   getAddress(newLocation)

   }

   function getAddress(latLng) {
   geocoder.geocode({ location: latLng
   }, function (results, status) {
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
       
   document.getElementById('map-address').addEventListener('input', function () {
       const inputText = this.value;
       if (inputText.length > 0) {
           const service = new google.maps.places.AutocompleteService();
           service.getPlacePredictions({ input: inputText
           }, (predictions, status) => {
               if (status === google.maps.places.PlacesServiceStatus.OK) {
                   updateAddressSuggestions(predictions);
               }
           });
       } else {
           document.getElementById('address-suggestions').innerHTML = '';
       }
   });
   function updateAddressSuggestions(predictions) {
       const suggestionsList = document.getElementById('address-suggestions');
       suggestionsList.innerHTML = '';
       predictions.forEach((prediction) => {
           const suggestionItem = document.createElement('div');
           suggestionItem.textContent = prediction.description;
           suggestionItem.addEventListener('click', () => {
               document.getElementById('address-suggestions').innerHTML = '';
               document.getElementById('map-address').value = prediction.description;
               onPlaceChanged();
           });
           suggestionsList.appendChild(suggestionItem);
           $("#address-suggestions").show();
       });
   }

   function onPlaceChanged() {
       const address = document.getElementById('map-address').value;
       $("#address-suggestions").hide();
       geocoder.geocode({ address: address
       }, function (results, status) {
           if (status === "OK" && results[
               0
           ].geometry) {
               const location = results[
                   0
               ].geometry.location;
               map.setCenter(location);
               placeMarker(location);
               updateCoordinates(location);
               getAddress(location);
           } else {
               console.error("Geocoder failed due to: " + status);
           }
       });
   }


   </script>

   <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCC3tFBaJSuWO8_avlwxrfaFzVE-sNVVvc&libraries=places&callback=initMap" async defer></script>

   <!--<script src="/documents/20152/60315374/add-location.js"></script>-->


   <script>

   $('.input-focus').focus(function() {
     $(this).parent().addClass('focused');
   });

   $('#locationForm').on('keypress', function(e) {
     var keyPressed = e.keyCode || e.which; 

     if ($(event.target).is('textarea')) return;

     if (keyPressed === 13) {
       event.preventDefault();
       return false;
      }
   });

   var fileValues = []; 
   var GMBfileValues = [];
   //var GMBFileList = [];

   var updateIndexId =  null;
   var GMBupdateIndexId = null;

   var countryFolderId = null;
   var documentMediaFolderId = null;
   var coutryLanguageId = null;
   var layoutUUID = null;
   var productTypeVocId = 0;
   var productParentCatId = 0;
   var articleStructureId = '60265765';
   var articleTemplateId = '60265771';
   var thankYouPage = "/thank-you-for-location";
   var defaultLatitude = 40.7128;
   var defaultLongitude = -74.006;
   var defaultMapZoomLevel = 8;
   const countryGroupId = themeDisplay.getScopeGroupId();
   var countryCompanyId = themeDisplay.getCompanyId();
   var guestRoleId= 20123;

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

   var days = [
       "Monday",
       "Tuesday",
       "Wednesday",
       "Thursday",
       "Friday",
       "Saturday",
       "Sunday"
   ];

   // For coutry dropdown
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

   // List of eu countries with data
   var listOfEUCountries = [
       { name: 'Germany', languageId: 'de_DE', wcmFolderId: 60265754, documentMediaFolderId: '60265900',layoutUUID: "a19c4060-07be-dcb9-5b60-03f5c795e4cc",code: "DE", productTypeVocId: 46179333, productParentCatId: 46185553
       },
       { name: 'United Kingdom', languageId: 'en_GB', wcmFolderId: 60329824, documentMediaFolderId: '60329921',layoutUUID: "a5a2ee85-4e1f-c9aa-e6ce-322fa005657b",code: "GB", productTypeVocId: 45846092, productParentCatId: 45846093
       },
       { name: 'Spain', languageId: 'es_ES', wcmFolderId: 60314868, documentMediaFolderId: '60315089',layoutUUID: "d9fb9a9f-999c-6401-ea51-ed8f2a8aa985",code: "ES", productTypeVocId: 46377683, productParentCatId: 49263378
       },
       { name: 'Czech Republic', languageId: 'cs_CZ', wcmFolderId: 60326347, documentMediaFolderId: '60326349',layoutUUID: "f8dc0ec0-0bac-3acc-4461-2ac9361a59f0",code: "CZ", productTypeVocId: 46986869, productParentCatId: 46986870
       },
       { name: 'Poland', languageId: 'pl_PL', wcmFolderId: 60330119, documentMediaFolderId: '60330121',layoutUUID: "d9113e4a-0025-2bfa-d448-c2ff1fa51ae6",code: "PL", productTypeVocId: 46497697, productParentCatId: 46497698
       },
       { name: 'France', languageId: 'fr_FR', wcmFolderId: 60353105, documentMediaFolderId: '60353107',layoutUUID: "1dfadceb-64b8-cc19-e32e-c714ba361ad8",code: "FR", productTypeVocId: 51533339, productParentCatId: 51533340
       },
       { name: 'Croatia', languageId: 'hr_HR', wcmFolderId: 60354285, documentMediaFolderId: '60354287',layoutUUID: "b19d49ae-6bae-1163-5e9b-308af376dc71",code: "HR", productTypeVocId: 47389540, productParentCatId: 49302889
       }
   ];

   var currentCountry = listOfEUCountries.find(country => country.languageId === themeDisplay.getLanguageId());

   if(currentCountry){
     countryFolderId = currentCountry.wcmFolderId;
     documentMediaFolderId = currentCountry.documentMediaFolderId;
     coutryLanguageId = currentCountry.languageId;
     layoutUUID = currentCountry.layoutUUID;
     productTypeVocId = currentCountry.productTypeVocId;
     productParentCatId = currentCountry.productParentCatId;
   } else {
     console.error("Error while fetching current coutry from array");
   }
   var tagId = 1;
   var contactCardId = 1;
   var fileCardId = 1;
   var pageCardId = 1;
   var GMBCardId = 1;

   var idSubstrings = [
       "LocationTitle",
       "Address",
       "Address2",
       "CompanyName",
       "TownCity",
       "Country",
       "Postcode",
       "PhoneNumber",
       "Time",
       "GeolocationData",
       "Products",
       "ContactDetail",
       "LocationImage",
       "isYextRestrict",
       "RichText",
       "FileCard",
       "AddPage",
       "ProductCard",
       "PublisherImages",
       "State",
       "Region"
   ];

   var currentOrigin = window.location.origin;
   if(location.pathname.startsWith("/web/")){
     currentOrigin += ('/' + window.location.pathname.split('/').filter(Boolean).slice(0,2).join('/'));
   }

   var thankYouPageURL = currentOrigin + thankYouPage
   var needFocusedIds = [
       "company",
       "contactname",
       "addressone"
   ];

   $.each(needFocusedIds, function(index, fId) {
     $('#' + fId).on('blur', function() {
       if($("#"+ fId).val() == "") {
           $("#"+ fId).parent().removeClass("focused");
           }
       });
   });

   document.addEventListener('click', function (e) {
     e = e || window.event;
     var target = e.target || e.srcElement;
     if (target.hasAttribute('data-toggle') && target.getAttribute('data-toggle') == 'popup') {
       if (target.hasAttribute('data-target')) {
             var m_ID = target.getAttribute('data-target');
             document.getElementById(m_ID).classList.add('open');
             e.preventDefault();
           }
       }
      if ((target.hasAttribute('data-dismiss') && target.getAttribute('data-dismiss') == 'popup') || target.classList.contains('popup')) {
         const popupDiv = document.getElementsByClassName('popup');
         if(popupDiv && popupDiv?.length > 0){
             for (let item of popupDiv) {
                 if(item?.classList?.contains('open')){
                     item?.classList?.remove('open');
                   }
               }
           }
         e.preventDefault();
       }
   }, false);

   function validatePostalCode(postalCode) {
       var apiURL = "https://app.zipcodebase.com/api/v1/search?apikey=3eeee100-cefc-11ee-b060-635cb775ed1a&codes=" + postalCode;
       var isValid = false;

       $.ajax({
           url: apiURL,
           method: "GET",
           async: false, 
           success: function(response) {
               if (response.results.length === 0) {
                   console.log("No results found for the postal code: " + postalCode);
                   $("#postcode-error").text(postalNotValidLabel);
                   isValid = false;
               } else {
                   console.log(response);
                   $("#postcode-error").text(""); 
                   isValid = true;
               }
           },
           error: function(xhr, status, error) {
               console.error(error); 
               $("#postcode-error").text(psValidateErrorLabel);
               isValid = false;
           }
       });
       return isValid;
   }


   $(document).ready(function() {

   $(document).on("keyup",
       "#postcode", function() {
           var pos = $(this).val(); 
           if (pos.length >= 3) {
               validatePostalCode(pos, function(valid) {
                   if (valid) {
                       console.log("True Result: Postal code is valid");
                   } else {
                       console.log("False Result: Postal code is not valid");
                   }
               });
           } else {
               console.log("Postal code is too short"); 
           }
       });
   });

   function genericValidations() {
      var requiredValidateIds = ['LocationTitle', 'Address', 'TownCity', 'Country', 'Postcode', 'PhoneNumber', 'GeolocationData', 'LocationImage' ];

      for (var i = 0; i < requiredValidateIds.length; i++) {
        
       var field = requiredValidateIds[i];

        if (field === 'GeolocationData') {
          var longitude = $("#longitude").val();
          var latitude = $("#latitude").val();

          if (longitude === '' || isNaN(longitude) || latitude === '' || isNaN(latitude)) return false;
          } else {
          var fieldValue = $("." + field).val();

          if (field === 'PhoneNumber') {
           var phoneInputtt = initializeIntlTelInput(preferredCountries, countryCodeValue, 'phonenumber',"phoneNumber-error");
            
           if (fieldValue === ''  || !validatePhoneNumber(phoneInputtt,"phoneNumber-error")) 
               return false;
           }else if (field === 'LocationImage') {
            if (!validateImage()) return false;
           }else if(field === 'Postcode') {
            var postcoded= $("#postcode").val();
            if(!validatePostalCode(postcoded)) return false;
           } else {
               if (fieldValue === '') return false;
             }
           }
       }

      return true;
   }

   var fileInputImage = document.getElementById('fileInput');
   var uploadedImage = null;

    function validateImage() {
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

   fileInputImage.addEventListener('change', function () {
       imageGlobal = null;
       if(validateImage()){
       uploadImage();
       }else{
           Toast.danger("${(ImageValidate?has_content)?then(ImageValidate, 'Please select image only')}");
       }
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
    
   var resultList = [];
   document.getElementById('save-file').addEventListener('click', function(event) {
       
       uploadFile(function(error, response) {
          if (error) {
              console.error('Error:', error);
           } else {
              if(articleIdFromUrl != null) {        
               if(updateIndexId === null){
                  fileValues.push(response);
               }   
               
               var idNumber = null;
               if (updateIndexId) {
                   var idParts = updateIndexId.split('-');
                   if (idParts.length >= 4) {
                    idNumber = idParts[3];
                   }
               }
                   
               var itemToUpdate = fileValues.find(item => item.id == idNumber);  
               if (itemToUpdate) {
                   itemToUpdate.groupId = response.groupId;
                   itemToUpdate.folderId = response.folderId;
                   itemToUpdate.fileName = response.fileName;
                   itemToUpdate.uuid = response.uuid;
                   itemToUpdate.modifiedDate = response.modifiedDate;
                   updateIndexId = null;
                   }
               }else{
                   resultList.push(response);
               }
           }
       });
   });

   var GMBFileList = [];
   document.getElementById('save-GMB-data').addEventListener('click', function(event) { 
       uploadGMBFile(function(error, response) {      
          if (error) {
              console.error('Error:', error);
           } else {

               if(articleIdFromUrl != null) {
               if(GMBupdateIndexId === null){
                  GMBfileValues.push(response);
                  return;
               }   
               
               var idNumber = GMBupdateIndexId.split('-')[3];
               var itemToUpdate = GMBfileValues.find(item => item.id == idNumber);  
               if (itemToUpdate) {
                   itemToUpdate.groupId = response.groupId;
                   itemToUpdate.folderId = response.folderId;
                   itemToUpdate.fileName = response.fileName;
                   itemToUpdate.uuid = response.uuid;
                   itemToUpdate.modifiedDate = response.modifiedDate;
                   GMBupdateIndexId = null;
                  }
               }else{
                  GMBFileList.push(response);
               }
           }
       });
   });

   const urlParams = new URLSearchParams(window.location.search);
   const articleIdFromUrl = urlParams.get('articleId');
   var imageGlobal = null;

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

    const locationFieldsIds = {
      'LocationTitle' : '#locationname',
      'Address' : '#address',
      'Address2' : '#addressone',
      'CompanyName' : '#company',
      'TownCity' : '#city',
      'Country' : '#country',
      'Postcode' : '#postcode',
      'PhoneNumber' : '#phonenumber',
      'GeolocationData' : {
         'mapAddress' : '#map-address',
         'latitude' : '#latitude',
         'longitude' : '#longitude'
       },
    
      'Monday_Separator' : '#monday-time-container',
      'Tuesday_Separator' : '#tuesday-time-container',
      'Wednesday_Separator' : '#wednesday-time-container',
      'Thursday_Separator' : '#thursday-time-container',
      'Friday_Separator' : '#friday-time-container',
      'Saturday_Separator' : '#saturday-time-container',
      'Sunday_Separator' : '#sunday-time-container',
      'ContactDetail': '#contact-card-container',
      'LocationImage': '#imagePreview',
      'RichText' : '#div_editor1',
      'isYextRestrict': '#yextSy',
      'AddPage': '#page-card-container',
      'ProductCard': '#pro-card-container',
      'FileCard': '#file-card-container',
      'PublisherImages': '#GMB-card-container',
      'State' :'#state',
      'Region':'#region'
   }

   function needFocusOnElement() {
    var focusedIds = ["#region", "#addressone"];
       focusedIds.forEach((focEle) => {
         if($(focEle).find("input").val() != "")
      
            $(focEle).parent().addClass("focused")
       })

   }
    
   function needFocusOnElement() {
   var focusedIds = ["#region", "#addressone"];
       focusedIds.forEach((focEle) => {
           if($(focEle).find("input").val() != "")
               $(focEle).parent().addClass("focused")
       })
   } 

    $(document).ready(function () { 

    var submitButton = document.getElementById("save");
        var modelHading = document.getElementById("myModalLabel");
        if (articleIdFromUrl) {
            submitButton.innerText = updateLocationLabel;
            modelHading.innerText = updateLocationLabel;
       }
        if (articleIdFromUrl) {
       Liferay.Service(
           '/journal.journalarticle/get-article',
           {
               groupId: countryGroupId,
               articleId: articleIdFromUrl
           },
           function (webContent) {
               webData = webContent;

               (async () => {
                   const categories = await getWebcontentCategories(webContent.resourcePrimKey);
                   console.log(categories);
                   if (categories && categories.length !== 0) {
                       categories.forEach(function (cat) {
                            selectCategory(cat.categoryId)
                       })
                   }
               })();

               const parser = new DOMParser();
               const locationXmlDoc = parser.parseFromString(webContent.content, 'application/xml');

               const locationXMLRootChilds = locationXmlDoc.childNodes;
               if (locationXMLRootChilds && locationXMLRootChilds.length != 0) {
                   var allFieldElements = locationXMLRootChilds[0].children;

                   for (let i = 0; i < allFieldElements.length; i++) {
                       const locationElement = allFieldElements[i];
                       const elementName = locationElement.getAttribute('name');
                       if (!locationFieldsIds[elementName]) continue;

                       console.log(locationElement);
                       const elementContent = locationElement.querySelector('dynamic-content');
                       const elementContentValue = locationElement.querySelector('dynamic-content')?.textContent ?? ''

                       if (!elementContentValue) continue;
                       const elelemtChildren = locationElement.children;

                       if (elelemtChildren && elelemtChildren.length == 0) continue;

                       if (elementName == 'ContactDetail') {
                           var contactName = "", contactPhone = "", contactEmail = "", contactJob = "";

                           for (let j = 0; j < elelemtChildren.length; j++) {
                               const contactField = elelemtChildren[j];
                               var attrName = contactField.getAttribute('name');
                               var attrContent = contactField.querySelector('dynamic-content').textContent;

                               if (attrName == "JobPosition") contactJob = attrContent;
                               else if (attrName == "EmailAddress") contactEmail = attrContent;
                               else if (attrName == "PhoneNumber1") contactPhone = attrContent;
                               else if (attrName == "ContactName") contactName = attrContent;
                           }

                           $(locationFieldsIds[elementName]).append(generateContactElement(contactName, contactJob, contactEmail, contactPhone));
                       } else if (elementName == 'Products') {
                           if (elementContent.textContent) addProductDynamic(elementContent.textContent);
                       } else if (elementName.includes('day_Separator')) {
                           $(locationFieldsIds[elementName]).html("");
                           
                           for (let j = 0; j < elelemtChildren.length; j++) {
                               const dayElem = elelemtChildren[j];
                               var attrName = dayElem.getAttribute('name'), timeValue = '';

                               if (attrName.includes('TimingSeparator')) {
                                   var openCloseElem = dayElem.children;
                                   const startTime = openCloseElem[0].querySelector('dynamic-content').textContent;
                                   const closeTime = openCloseElem[1].querySelector('dynamic-content').textContent;

                                   if (startTime && closeTime) timeValue = (startTime + " - " + closeTime);
                               }

                               var openCloseElemValue = dayElem.querySelector('dynamic-content').textContent;
                               if (openCloseElemValue == 'true') timeValue = "Closed";

                               if (timeValue) $(locationFieldsIds[elementName]).append("<input type='text' placeholder='—:— - —:—' value='" + timeValue + "'> ");
                           }
                       } else if (elementName == 'Country') {
                           var parts = elementContentValue.split(' - ');
                           if (parts.length === 2) $(locationFieldsIds[elementName]).val(parts[0].trim());
                           else $(locationFieldsIds[elementName]).val(elementContentValue);
                       } else if (elementName == 'GeolocationData') {
                           const geolocationData = JSON.parse(elementContentValue);
                           $(locationFieldsIds[elementName]['latitude']).val(geolocationData.latitude);
                           $(locationFieldsIds[elementName]['longitude']).val(geolocationData.longitude);
                           updateMap();
                       } else if (elementName == 'isYextRestrict') {
                           var isYext = false;
                           if (elementContentValue && elementContentValue == 'true') isYext = true;

                           $(locationFieldsIds[elementName]).attr("checked", isYext);
                       } else if (elementName == 'LocationImage') {
                           const imagePre = elementContentValue;
                           imageGlobal = locationElement;

                           $(locationFieldsIds[elementName]).css({
                               "background-image": "url(" + imagePre + ")",
                               "display": "block"
                           });
                       } else if (elementName == 'AddPage') {
                           var pageName = elelemtChildren[0].querySelector('dynamic-content').textContent;
                           var pageURL = elelemtChildren[1].querySelector('dynamic-content').textContent;

                           if (pageName && pageURL) $(locationFieldsIds[elementName]).append(generatePageElement(pageName, pageURL));
                       } else if (elementName == 'ProductCard') {                           
                           (async function() {
                              var productName = elelemtChildren[0].querySelector('dynamic-content').textContent;
                              var productLink = elelemtChildren[1].querySelector('dynamic-content').textContent;
                              const categoryId = await getCategoryIdByName(productName);
                              if (productName && categoryId) generateProductHTMLAndAppend(productName, categoryId , productLink);
                           })();
                       } else if (elementName == 'FileCard') {
                           var pageName = elelemtChildren[0].querySelector('dynamic-content').textContent;
                           var pageURL = elelemtChildren[1].querySelector('dynamic-content').textContent;

                           if (!pageURL || !pageName) continue;

                           const urlParts = pageURL.substring(1).split("/");

                           const locationPriceList = {
                               id: fileCardId,
                               groupId: urlParts[1],
                               folderId: urlParts[2],
                               fileName: urlParts[3],
                               uuid: urlParts[4].split("?")[0],
                               modifiedDate: urlParts[4].split("?")[1].split("=")[1]
                           };
                           fileValues.push(locationPriceList);

                           $(locationFieldsIds[elementName]).append(generateFileCard(pageName, pageURL.split('/').slice(-2, -1)[0]));
                       } else if (elementName == 'RichText') {
                           $("#div_editor1 iframe").contents().find("body").html(elementContentValue);
                       } else if (elementName == 'PublisherImages') {
                           var publisher = elelemtChildren[0].querySelector('dynamic-content').textContent;
                           var gmbFile = elelemtChildren[1].querySelector('dynamic-content').textContent;
                           var description = elelemtChildren[2].querySelector('dynamic-content').textContent;

                           if (!publisher || !gmbFile || !description) continue;

                           const urlPartss = gmbFile.substring(1).split("/");

                           if (urlPartss.length >= 5) {
                               GMBfileValues.push({
                                   id: GMBCardId,
                                   groupId: urlPartss[1],
                                   folderId: urlPartss[2],
                                   fileName: urlPartss[3],
                                   uuid: urlPartss[4].split("?")[0],
                                   modifiedDate: urlPartss[4].split("?")[1].split("=")[1]
                               });
                           }

                           $(locationFieldsIds[elementName]).append(generateGMBDiv(publisher, description, gmbFile.split('/').slice(-2, -1)[0]));
                       } else {
                           $(locationFieldsIds[elementName]).val(elementContentValue);
                       }
                   }

                   needFocusOnElement();
               }
           }
       );
   }

   });

   function generateContactElement(contactName, contactJob, contactEmail, contactPhone) {
      return "<div class='col-md-4'>" +
      "<div class='contact-card' id='contact-card-id-" + (contactCardId++) + "'>" +
      "<h2 class='contact-name'>" + contactName +
      "</h2>" +
      "<a class='card-edit'>" +
      "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
      "</a>" +
      "<a class='contact-card-remove'>" +
         "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
         "</a>" +
      "<p class='contact-job'>" + contactJob + "</p>" +
      "<p class='contact-email'><a href='mailto:" + contactEmail + "'>" + contactEmail + "</a></p>" +
      "<p class='contact-phone'>" + contactPhone + "</p>" +
      "</div>" +
      "</div>";
   }

   function generateGMBDiv(publisher, description, fileValue) {
       return "<div class='col-md-4'>" +
       "<div class='GMB-card' id='GMB-card-id-" + (GMBCardId++) + "'>" +
       "<h2 class='file-Publisher'>" + publisher +
       "</h2><br>" + 
       "<a class='GMB-card-edit'>" +
       "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
       "</a>" +
       "<a class='GMB-card-remove'>" +
       "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
       "</a>" +
       "<h2 class='file-Description'>" + description +
       "</h2>" +
       "<p class='file-value'>" + fileValue + "</p>" +
       "</div>" +
       "</div>";
   }

   function generateFileCard(fileName,fileValue) {
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
       "<p class='file-value'>" + fileValue + "</p>" +
       "</div>" +
       "</div>";
   }

   function generatePageElement(pageName, PageURL) {
       return "<div class='col-md-4'>" +
           "<div class='page-card' id='page-card-id-" + (pageCardId++) + "'>" +
               "<h2 class='page-name'>" + pageName + "</h2>" +
               "<a class='page-card-edit'>" +
               "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
               "</a>" +
               "<a class='page-card-remove'>" +
               "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
               "</a>" +
               "<p class='page-url'>" + PageURL + "</p>" +
           "</div>" +
       "</div>";
   }

    const xmlBuilder = document.implementation.createDocument(null, null);
    
    function formDataTOXMLString() {

        const currentDate = new Date();

        const declaration = xmlBuilder.createProcessingInstruction('xml', 'version="1.0"');
        xmlBuilder.appendChild(declaration);

        const rootElement = xmlBuilder.createElement('root');
        rootElement.setAttribute('available-locales',"" + coutryLanguageId + "");
        rootElement.setAttribute('default-locale',"" + coutryLanguageId + "");
        xmlBuilder.appendChild(rootElement);

        for (const idName of idSubstrings) {
       
           const instanceId = String(idName).toLowerCase();;

              if(idName.includes("Time")){

                  days.forEach((day, index) => {
                 
                  var dayHoursContainer=$("#"+day.toLowerCase()+"-time-container").children();
                   
                   const dayDynamicElementParent = getynamicElement(day+"_Separator","selection_break","keyword", day+"_Separator"+index)

                   dayHoursContainer.each(function (index,currentEle) {
                      var fieldValue = currentEle.value;
                      var startTime = '';
                      var endTime = '';
                      var isCloseString = '';                   
                      
                      if(fieldValue) {

                       var dayDynamicElementChild = getynamicElement("TimingSeparator"+day,"selection_break","keyword","TimingSeparator"+day+index);
                       
                       if(fieldValue === "Closed") {
                           isCloseString = "true";                        
                       } else if(fieldValue.includes(" - ")) {
                           startTime = fieldValue.split(" - ")[0];
                           endTime = fieldValue.split(" - ")[1];
                       }
       
                        var startXML = createDynamicElement(day+"Open","text", startTime, day+"Open"+index, false);
                        var endXML = createDynamicElement(day+"Close","text", endTime, day+"Close"+index, false);

                        dayDynamicElementChild.append(startXML);
                        dayDynamicElementChild.append(endXML);
                        dayDynamicElementParent.append(dayDynamicElementChild);

                           if(!dayDynamicElementParent.querySelector('dynamic-element[name="isClosed'+day+'"]')) {
                               var closeXML = createDynamicElement("isClosed"+day,"boolean",isCloseString,"isClosed"+day+index, false);
                               dayDynamicElementParent.append(closeXML);
                           }
                        
                       }
                       
                   });
                   
                   xmlBuilder.documentElement.appendChild(dayDynamicElementParent);
               });
           } else if (idName.includes("Country")) {
                var countryField = $("." + idName);
                const selectedCountryObj = countries.find(country => country.name === countryField.val());
                if (selectedCountryObj) {
                   createDynamicElement(idName,"text", (countryField.val() + " - " + selectedCountryObj.code), instanceId, true);
               }
           } else if (idName.includes("GeolocationData")) {
                var latitude = $("#latitude").val();
                var longitude = $("#longitude").val();

                createDynamicElement(idName,"ddm-geolocation","{\"latitude\":\"" + latitude + "\",\"longitude\":\"" + longitude + "\"}", instanceId, true);
           } else if (idName.includes("Products")) {

                $('#tags-container [class^="product"]').toArray().forEach((product, index) => {
                   createDynamicElement("Products","text", $(product).text().replace("x",""), ("product" + index), true);
               });
           } else if (idName.includes("ContactDetail")) {

                $('[id^="contact-card-id-"]').toArray().forEach((contact, index) => {
                    const contactInsId = ("contact-detail-" + index);
                    const dynamicElement = xmlBuilder.createElement('dynamic-element');

                    dynamicElement.setAttribute('name',"ContactDetail");
                    dynamicElement.setAttribute('type',"selection_break");
                    dynamicElement.setAttribute('index-type', 'keyword');
                    dynamicElement.setAttribute('instance-id', contactInsId);

                    dynamicElement.appendChild(createDynamicElement("ContactName","text", $(contact).find(".contact-name").text().trim(), contactInsId + "-name"), false);
                    dynamicElement.appendChild(createDynamicElement("JobPosition","text", $(contact).find(".contact-job").text().trim(), contactInsId + "-job"), false);
                    dynamicElement.appendChild(createDynamicElement("EmailAddress","text", $(contact).find(".contact-email a").text().trim(), contactInsId + "-email"), false);
                    dynamicElement.appendChild(createDynamicElement("PhoneNumber1","text", $(contact).find(".contact-phone").text().trim(), contactInsId + "-phone"), false);

                    xmlBuilder.documentElement.appendChild(dynamicElement);
               });
           } else if (idName.includes("FileCard")) {

                $('[id^="file-card-id-"]').toArray().forEach((filed, index) => {

                    var fileInput = document.getElementById('file');
                    var file = fileInput.files[0];

                    const contactInsId = ("card-detail-" + index);
                    const dynamicElement = xmlBuilder.createElement('dynamic-element');

                    dynamicElement.setAttribute('name',"FileCard");
                    dynamicElement.setAttribute('type',"selection_break");
                    dynamicElement.setAttribute('index-type', 'keyword');
                    dynamicElement.setAttribute('instance-id', contactInsId);

                    dynamicElement.appendChild(createDynamicElement("PriceName","text", $(filed).find(".file-name").text().trim(), contactInsId + "-name"), false);

                    if (resultList && resultList.length > 0) {
                        resultList.forEach((result, resultIndex) => {
                           if (resultIndex === index) {
                                  var dyEle = createDynamicElementForFile(result);
                                  dynamicElement.appendChild(dyEle, false);
                           }
                       });
                   } 
                  
                   if (articleIdFromUrl != null && fileValues != null) {
                      fileValues.forEach((result, resultIndex) => {
                          if (resultIndex === index) {
                              var dyEle = createDynamicElementForFile(result);
                              dynamicElement.appendChild(dyEle, false);
                           }
                       });
                   }
                    xmlBuilder.documentElement.appendChild(dynamicElement);
               });
           }else if (idName.includes("PublisherImages")) {

                $('[id^="GMB-card-id-"]').toArray().forEach((filed, index) => {

                    var fileInput = document.getElementById('file');
                   
                    var file = fileInput.files[0];

                    const contactInsId = ("GMBcard-detail-" + index);
                    const dynamicElement = xmlBuilder.createElement('dynamic-element');

                    dynamicElement.setAttribute('name',"PublisherImages");
                    dynamicElement.setAttribute('type',"selection_break");
                    dynamicElement.setAttribute('index-type', 'keyword');
                    dynamicElement.setAttribute('instance-id', contactInsId);

                    dynamicElement.appendChild(createDynamicElement("Publisher","text", $(filed).find(".file-Publisher").text().trim(), contactInsId + "-name"), false);

                    if (GMBFileList && GMBFileList.length > 0) {
                        GMBFileList.forEach((result, resultIndex) => {
                           if (resultIndex === index) {
                                     var dyEle = createDynamicElementForGMBFile(result);
                                     dynamicElement.appendChild(dyEle, false);
                           }
                       });
                   } 
                  
                  if (articleIdFromUrl != null && GMBfileValues != null) {
                      GMBfileValues.forEach((result, resultIndex) => {
                          if (resultIndex === index) {                         
                              var dyEle = createDynamicElementForGMBFile(result);
                              dynamicElement.appendChild(dyEle, false);
                           }
                       });
                   }

                  dynamicElement.appendChild(createDynamicElement("Description","text", $(filed).find(".file-Description").text().trim(), contactInsId + "-name"), false);

                  xmlBuilder.documentElement.appendChild(dynamicElement);
               });
           } else if (idName.includes("AddPage")) {
               
                $('[id^="page-card-id-"]').toArray().forEach((addPages, index) => {
                
                    const contactInsId = ("page-detail-" + index);
                    const dynamicElement = xmlBuilder.createElement('dynamic-element');

                    dynamicElement.setAttribute('name',"AddPage");
                    dynamicElement.setAttribute('type',"selection_break");
                    dynamicElement.setAttribute('index-type', 'keyword');
                    dynamicElement.setAttribute('instance-id', contactInsId);

                   dynamicElement.appendChild(createDynamicElement("PageName","text", $(addPages).find(".page-name").text().trim(), contactInsId + "-name"), false);
                   dynamicElement.appendChild(createDynamicElement("PageUrl","text", $(addPages).find(".page-url").text().trim(), contactInsId + "-job"), false);

                    xmlBuilder.documentElement.appendChild(dynamicElement);
               });
           } else if (idName.includes("ProductCard")) {
               
                $('[id^="pro-link-card-id-"]').toArray().forEach((addProducts, index) => {
                    const contactInsId = ("product-detail-" + index);
                    const dynamicElement = xmlBuilder.createElement('dynamic-element');

                    dynamicElement.setAttribute('name',"ProductCard");
                    dynamicElement.setAttribute('type',"selection_break");
                    dynamicElement.setAttribute('index-type', 'keyword');
                    dynamicElement.setAttribute('instance-id', contactInsId);

                   var productCateId = $(addProducts).find(".pro-link-name").attr("id");

                   if(productCateId) finalProductsCategories.push(productCateId)

                   dynamicElement.appendChild(createDynamicElement("Name","text", $(addProducts).find(".pro-link-name").text().trim(), contactInsId + "-name"), false);
                   dynamicElement.appendChild(createDynamicElement("Link","text", $(addProducts).find(".pro-link").text().trim(), contactInsId + "-link"), false);

                    xmlBuilder.documentElement.appendChild(dynamicElement);
               });
           } else if (idName.includes("LocationImage")) {
                var fileInput = document.getElementById('fileInput');
                var file = fileInput.files[0];

                if (articleIdFromUrl != null && imageGlobal != null) {
                    xmlBuilder.documentElement.appendChild(imageGlobal);
               } else {
                    if (file && file.size) {
                        var dyEle = createDynamicElementForImage(uploadedImage);
                        xmlBuilder.documentElement.appendChild(dyEle);
                   }
               }
           }else if (idName.includes("RichText")){
   	     var richData = $("#div_editor1 iframe").contents().find("body").html();
   	     createDynamicElement(idName,"text", richData, instanceId, true);
           } else if (idName.includes("isYextRestrict")){
   		 
   			var checkBox = document.getElementById("yextSy");
   			var isChecked = checkBox.checked;
   			if (isChecked) {
   				createDynamicElement(idName,"text",true, instanceId, true);
               } else {
   				createDynamicElement(idName,"text",'', instanceId, true);
               }
           } else {
                var fieldValue = $("." + idName).val();
                createDynamicElement(idName,"text", fieldValue, instanceId, true);
           }
       }

        const xmlContent = new XMLSerializer().serializeToString(xmlBuilder);
        return xmlContent;
   }

    function getynamicElement(name, type, indexType, instanceId) {
        const dynamicElement = xmlBuilder.createElement('dynamic-element');

        dynamicElement.setAttribute('name', name);
        dynamicElement.setAttribute('type', type);
        dynamicElement.setAttribute('index-type',  indexType);
        dynamicElement.setAttribute('instance-id', instanceId);

        return dynamicElement;
   }

    function createDynamicElement(name, type, value, instanceId, appendInXML) {
        const dynamicElement = xmlBuilder.createElement('dynamic-element');

        dynamicElement.setAttribute('name', name);
        dynamicElement.setAttribute('type', type);
        dynamicElement.setAttribute('index-type', 'keyword');
        dynamicElement.setAttribute('instance-id', instanceId);

        const dynamicContent = xmlBuilder.createElement('dynamic-content');
        dynamicContent.setAttribute('language-id',"" + coutryLanguageId + "");

        const cdata = xmlBuilder.createCDATASection(value);
        dynamicContent.appendChild(cdata);

        dynamicElement.appendChild(dynamicContent);
        if (appendInXML) {
            xmlBuilder.documentElement.appendChild(dynamicElement);
       }

        return dynamicElement;
   }

    function createDynamicElementForImage(documentResponse) {
        const dynamicElement = xmlBuilder.createElement('dynamic-element');

        dynamicElement.setAttribute('name', 'LocationImage');
        dynamicElement.setAttribute('type', 'image');
        dynamicElement.setAttribute('index-type', 'text');
        dynamicElement.setAttribute('instance-id', 'sffadsfgdsadf');

        const dynamicContent = xmlBuilder.createElement('dynamic-content');
        dynamicContent.setAttribute('language-id', coutryLanguageId);
        dynamicContent.setAttribute('alt', documentResponse.fileName);
        dynamicContent.setAttribute('name', documentResponse.fileName);
        dynamicContent.setAttribute('title', documentResponse.fileName);
        dynamicContent.setAttribute('type', 'document');
        dynamicContent.setAttribute('fileEntryId', documentResponse.fileEntryId);

        var imagePath = "/documents/" + documentResponse.groupId + "/" + documentResponse.folderId + "/" + documentResponse.fileName;

        const cdata = xmlBuilder.createCDATASection(imagePath);
        dynamicContent.appendChild(cdata);

        dynamicElement.appendChild(dynamicContent);

        return dynamicElement;
   }

   function createDynamicElementForFile(documentResponse) {
       const dynamicElement = xmlBuilder.createElement('dynamic-element');

       dynamicElement.setAttribute('name', 'LocationPriceList');
       dynamicElement.setAttribute('instance-id', documentResponse.uuid);
       dynamicElement.setAttribute('type', 'document_library');
       dynamicElement.setAttribute('index-type', 'keyword');

       const dynamicContent = xmlBuilder.createElement('dynamic-content');
       dynamicContent.setAttribute('language-id',"" + coutryLanguageId + "");

       var filePath = "/documents/" + documentResponse.groupId + "/" + documentResponse.folderId + "/" + documentResponse.fileName + "/" +documentResponse.uuid + "?t=" +documentResponse.modifiedDate;

       const cdata = xmlBuilder.createCDATASection(filePath);
       dynamicContent.appendChild(cdata);
       dynamicElement.appendChild(dynamicContent);

       return dynamicElement;
   }

    function createDynamicElementForGMBFile(documentResponse) {
       const dynamicElement = xmlBuilder.createElement('dynamic-element');

       dynamicElement.setAttribute('name', 'File');
       dynamicElement.setAttribute('instance-id', documentResponse.uuid);
       dynamicElement.setAttribute('type', 'document_library');
       dynamicElement.setAttribute('index-type', 'keyword');

       const dynamicContent = xmlBuilder.createElement('dynamic-content');
       dynamicContent.setAttribute('language-id',"" + coutryLanguageId + "");

       var filePath = "/documents/" + documentResponse.groupId + "/" + documentResponse.folderId + "/" + documentResponse.fileName + "/" +documentResponse.uuid + "?t=" +documentResponse.modifiedDate;

       const cdata = xmlBuilder.createCDATASection(filePath);
       dynamicContent.appendChild(cdata);

       dynamicElement.appendChild(dynamicContent);

       return dynamicElement;
   }
   function uploadFile(callback, retry = false, newFileName = null) {
       var fileInput = document.getElementById('file');
       var file = fileInput.files[0];

       if (file) {
           var formData = new FormData();
           formData.append('repositoryId', themeDisplay.getScopeGroupId());
           formData.append('folderId', documentMediaFolderId);
           formData.append('sourceFileName', newFileName ? newFileName : file.name);
           formData.append('mimeType', file.type);
           formData.append('title', newFileName ? newFileName : file.name);
           formData.append('description', '');
           formData.append('changeLog', '');
           formData.append('file', file);

           var xhr = new XMLHttpRequest();
           xhr.open('POST', '/api/jsonws/dlapp/add-file-entry', true);
           xhr.setRequestHeader('Authorization', 'Basic bWFub2ouZ29oZWxAZXh0LmNlbWV4LmNvbTpDZW1leDEyMzQ1Ng==');

           xhr.onreadystatechange = function () {
               if (xhr.readyState === 4) {
                   if (xhr.status === 200) {
                       var uploadedFile = JSON.parse(xhr.responseText);
                       $("#file-error").text('');
                       callback(null, uploadedFile);
                   } else if (xhr.status === 500 && !retry) {
                       retryUploadFile(callback, file);
                   } else {
                       console.error('Error uploading file:', xhr.status, xhr.statusText);
                       callback('Error uploading file', null);
                   }
               }
           };
           xhr.send(formData);
       } else {
           Toast.danger("${(FileRequireValidation?has_content)?then(FileRequireValidation, 'Please select a file.')}");
           callback('No file selected', null);
       }
   }

   function retryUploadFile(callback, file) {
       var uniqueFileName = generateUniqueFileName(file.name);
       var formData = new FormData();
       formData.append('repositoryId', themeDisplay.getScopeGroupId());
       formData.append('folderId', documentMediaFolderId);
       formData.append('sourceFileName', uniqueFileName);
       formData.append('mimeType', file.type);
       formData.append('title', uniqueFileName);
       formData.append('description', '');
       formData.append('changeLog', '');
       formData.append('file', file);

       var xhr = new XMLHttpRequest();
       xhr.open('POST', '/api/jsonws/dlapp/add-file-entry', true);
       xhr.setRequestHeader('Authorization', 'Basic bWFub2ouZ29oZWxAZXh0LmNlbWV4LmNvbTpDZW1leDEyMzQ1Ng==');

       xhr.onreadystatechange = function () {
           if (xhr.readyState === 4) {
               if (xhr.status === 200) {
                   var uploadedFile = JSON.parse(xhr.responseText);
                   setGuestPermissionsForFileEntry(uploadedFile.fileEntryId);
                   $("#file-error").text('');
                   callback(null, uploadedFile);
               } else {
                   console.error('Error uploading file:', xhr.status, xhr.statusText);
                   callback('Error uploading file', null);
               }
           }
       };
       xhr.send(formData);
   }

   function generateUniqueFileName(originalName) {
       var timestamp = new Date().getTime();
       var fileExtension = originalName.split('.').pop();
       var baseName = originalName.substring(0, originalName.lastIndexOf('.'));
       return baseName + '-' + timestamp + '.' + fileExtension;
   }
   function uploadGMBFile(callback) {
       var fileInput = document.getElementById('GMBfile');
       var file = fileInput.files[0];

       if (file) {
           var formData = new FormData();
           formData.append('repositoryId', themeDisplay.getScopeGroupId());
           formData.append('folderId', documentMediaFolderId);
           formData.append('sourceFileName', file.name);
           formData.append('mimeType', file.type);
           formData.append('title', file.name);
           formData.append('description', '');
           formData.append('changeLog', '');
           formData.append('file', file);

           var xhr = new XMLHttpRequest();
           xhr.open('POST', '/api/jsonws/dlapp/add-file-entry', true);
           xhr.setRequestHeader('Authorization', 'Basic bWFub2ouZ29oZWxAZXh0LmNlbWV4LmNvbTpDZW1leDEyMzQ1Ng==');

           xhr.onreadystatechange = function () {
               if (xhr.readyState === 4) {
                   if (xhr.status === 200) {
                       var uploadedGMBFile = JSON.parse(xhr.responseText);
                       setGuestPermissionsForFileEntry(uploadedGMBFile.fileEntryId);
                       $("#file-error").text('');
                       callback(null, uploadedGMBFile);
                   } else if (xhr.status === 500) {
                       retryUploadFile(callback, file);
                   } else {
                       console.error('Error uploading file:', xhr.status, xhr.statusText);
                       callback('Error uploading file', null);
                   }
               }
           };
           xhr.send(formData);
       } else {
           Toast.danger("${(FileRequireValidation?has_content)?then(FileRequireValidation, 'Please select a file.')}");
           callback('No file selected', null);
       }
   }

   function uploadImage() {
        var fileInput = document.getElementById('fileInput');
        var file = fileInput.files[0];

        if (file) {
            var formData = new FormData();
            formData.append('repositoryId', themeDisplay.getScopeGroupId());
            formData.append('folderId', documentMediaFolderId);
            formData.append('sourceFileName', file.name);
            formData.append('mimeType', file.type);
            formData.append('title', file.name);
            formData.append('description', '');
            formData.append('changeLog', '');
            formData.append('file', file);

            var xhr = new XMLHttpRequest();
            xhr.open('POST', '/api/jsonws/dlapp/add-file-entry', true);
            xhr.setRequestHeader('Authorization', 'Basic bWFub2ouZ29oZWxAZXh0LmNlbWV4LmNvbTpDZW1leDEyMzQ1Ng==');

            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        uploadedImage = JSON.parse(xhr.responseText);
                        $("#image-error").text('');
                        return JSON.parse(xhr.responseText);
                   } else if (xhr.status === 500) {
                      Toast.danger("${(ImageExist?has_content)?then(ImageExist, 'This file already exists')}");
                   } else {
                        console.error('Error uploading file:', xhr.status, xhr.statusText);
                   }
               }
           };
            xhr.send(formData);
       } else {
           Toast.danger("${(imageRequireValidation?has_content)?then(imageRequireValidation, 'Please select an image.')}");
       }
        return null;
   }

    function addArticle(xmlData) {

        const currentDate = new Date();
        var locationTitle = $(".LocationTitle").val();

        var allCategoriesToPush = [...Array.from(selectedCategoryIds), ...finalProductsCategories]

        Liferay.Service(    
            '/journal.journalarticle/add-article',{
                groupId: countryGroupId,
                folderId: countryFolderId,
                classNameId: 0,
                classPK: 0,
                articleId: '',
                autoArticleId: true,
                titleMap: { ["" + coutryLanguageId + ""]: locationTitle},
                descriptionMap: {["" + coutryLanguageId + ""]: ""},
                content: xmlData,
                ddmStructureKey: articleStructureId,
                ddmTemplateKey: articleTemplateId,
                layoutUuid: layoutUUID,
                displayDateMonth: currentDate.getMonth(),
                displayDateDay: currentDate.getDate(),
                displayDateYear: currentDate.getFullYear(),
                displayDateHour: 00,
                displayDateMinute: 00,
                expirationDateMonth: currentDate.getMonth(),
                expirationDateDay: currentDate.getDate(),
                expirationDateYear: currentDate.getFullYear() + 1,
                expirationDateHour: currentDate.getHours(),
                expirationDateMinute: currentDate.getMinutes(),
                neverExpire: true,
                reviewDateMonth: currentDate.getMonth(),
                reviewDateDay: currentDate.getDate(),
                reviewDateYear: currentDate.getFullYear(),
                reviewDateHour: currentDate.getHours(),
                reviewDateMinute: currentDate.getMinutes(),
                neverReview: true,
                indexable: true,
                articleURL: '',
                serviceContext: {assetCategoryIds: allCategoriesToPush
           }
       },function (obj) {
           if (obj) {
               addResourcesToArticle(obj);
               Toast.success("${(LocationCreatedMessage?has_content)?then(LocationCreatedMessage, 'Requested location is created successfully')}");
               window.location.href = thankYouPageURL;
           } else {
               Toast.danger("${(LocationFailMessage?has_content)?then(LocationFailMessage, 'Requested location is not created.')}");
               $("#save").prop('disabled', false).text("Save Location");
           }
       },
            function (error) {
            $("#save").prop('disabled', false).text("Save Location");
               Toast.danger("${(LocationFailMessage?has_content)?then(LocationFailMessage, 'Requested location is not created.')}");    }
        );
   }

    function updateArticle(locationformData){

        var allCategoriesToPush = [...Array.from(selectedCategoryIds), ...finalProductsCategories]

       Liferay.Service('/journal.journalarticle/update-article',
       {
                userId: webData.getUserId,
                groupId: webData.groupId,
                folderId: webData.folderId,
                articleId: articleIdFromUrl,
                version: webData.version,
                titleMap: "{ "+coutryLanguageId+": \"" + webData.titleCurrentValue + "\" }",
                descriptionMap: "{ "+coutryLanguageId+": \"" + webData.descriptionCurrentValue + "\" }",
                content: locationformData, 
                layoutUuid: webData.layoutUuid,
                serviceContext: {assetCategoryIds: allCategoriesToPush}
       },
       function (obj) {
           Toast.success("${(LocationUpdateSuccess?has_content)?then(LocationUpdateSuccess, 'Location is updated successfully')}");
           window.location.href = thankYouPageURL;
       }
        );
   }

    function addResourcesToArticle(article) {
        Liferay.Service(
        '/resourcepermission/set-individual-resource-permissions',{
           groupId: countryGroupId,
           companyId: countryCompanyId,
           name: 'com.liferay.journal.model.JournalArticle',
           primKey: article.resourcePrimKey,
           roleId: guestRoleId,
           actionIds: ["VIEW"]
       },
       function (obj) {
           console.log("Permission added on the WCM");
       },
       function (error) {
           $("#save").prop('disabled', false).text("Update Location");
           Toast.danger("${'Requested location is not updated.'}");    
       }
     );
   }

   function setGuestPermissionsForFileEntry(fileEntryId) {
        Liferay.Service(
        '/resourcepermission/set-individual-resource-permissions',{
           groupId: countryGroupId,
           companyId: countryCompanyId,
           name: 'com.liferay.document.library.kernel.model.DLFileEntry',
           primKey: fileEntryId,
           roleId: guestRoleId,
           actionIds: ["VIEW"]
       },
       function (obj) {
           console.log("Permission added on the WCM");
       }
     );
   }


    var webData = null;
    $(document).ready(function() {
      $('#locationForm').submit(function() {
        if(!genericValidations()) {
           Toast.danger("${(ValidateAllFields?has_content)?then(ValidateAllFields, 'Please fill required and valid information in this form')}");
            return false;
       }
       const urlParams = new URLSearchParams(window.location.search);
       const articleIdFromUrl = urlParams.get('articleId');

       $("#save").prop('disabled', true).text( ((articleIdFromUrl) ? "Updating" : "Saving")+ " Location...");

       var locationformData = formDataTOXMLString();
        if (articleIdFromUrl == null) {
            addArticle(locationformData);
       } else {
           updateArticle(locationformData)
       }
       return true;
       });
   });

   <!-------------------Phone Number field related script------------------->
    const preferredCountries = ['GB', 'PL', 'CZ', 'FR', 'DE', 'HR', 'ES'
   ];
   const defaultCountryCode = currentCountry.code;
    document.addEventListener("DOMContentLoaded", function () {
      setFlagCountryInAllPhone(defaultCountryCode);
   });
     
   function setFlagCountryInAllPhone(dynamicCountryCode) {
      initializeIntlTelInput(preferredCountries, dynamicCountryCode,"phonenumber","phoneNumber-error");
      initializeIntlTelInput(preferredCountries, dynamicCountryCode,"phonenumbermodal","phonenumbermodal-error");
   }

    const selectedCountryCodes = {};
    $(document).ready(function () {
        function populateDropdown() {
            const select = $("#country");
            const currentCountryCode = currentCountry.code; 
            $.each(countries, function (index, country) {
                const option = $("<option></option>").attr("value", country.name).text(country.name);
                if (country.code === currentCountryCode) {
                    option.attr("selected","selected"); 
               }
               select.append(option);
           });
       }
        populateDropdown();
   });
     
    function initializeIntlTelInput(preferredCountries, defaultCountryCode, inputId, errorId) {
      const phoneInputField = document.querySelector("#" + inputId);
      const phoneInput = window.intlTelInput(phoneInputField,{
         utilsScript: "https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/utils.js",
         preferredCountries: preferredCountries
       });

      phoneInput.setCountry(defaultCountryCode);
      selectedCountryCodes[inputId] = defaultCountryCode;

      updateSelectedCountryCode(inputId, phoneInput.getSelectedCountryData().iso2);
      phoneInputField.addEventListener("countrychange", function () {
         const countryCode = phoneInput.getSelectedCountryData().iso2;
     
         selectedCountryCodes[inputId] = countryCode; 
         updateSelectedCountryCode(inputId, countryCode);
       });
     
      phoneInputField.addEventListener("blur", function () {
         validatePhoneNumber(phoneInput, errorId);
       });
     
      return phoneInput;
   }
     
    let countryCodeValue;
    let countryCodeValueModal;

    function updateSelectedCountryCode(inputId, countryCode) {
      if (inputId === "phonenumber") {
         countryCodeValue = countryCode;
       } else if (inputId === "phonenumbermodal") {
         countryCodeValueModal = countryCode;
       }
   }
     
    function validatePhoneNumber(itiPhone, errorId) {
       try {
         var isValid = itiPhone.isValidNumber();
         if (!isValid) {
            var err = itiPhone.getValidationError();
            switch (err) {
                 case window.intlTelInputUtils.validationError.INVALID_COUNTRY_CODE:
                 $("#" + errorId).text(invalidCountryCode);
                 break;

               case window.intlTelInputUtils.validationError.TOO_SHORT:
                 $("#" + errorId).text(phoneNoShort);
                 break;

               case window.intlTelInputUtils.validationError.TOO_LONG:
                 $("#" + errorId).text(phoneNoLong);
                 break;

               case window.intlTelInputUtils.validationError.NOT_A_NUMBER:
                 $("#" + errorId).text(invalidPhoneNo);
                 break;

               default:
                 $("#" + errorId).text(phoneNotValid);
                 break;
               }
            return false;
           } else {
             $("#" + errorId).text("");
             return true;
           }
       } catch (error) {
         $("#" + errorId).text(errorPhoneNo);
         return false;
       }
   }

   function validateEmailAddress(email) {        
        var emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailPattern.test(email)) {
            return false;
       }
       return true;
   }

   function validateLocationDescription() {
        var value = $("#locationDescription").val().trim();
        if (value == "") {
            $("#locationDescription-error").text("");
            return true;
       }
        else if (value.length < 10) {
            $("#locationDescription-error").text("Please enter at least 10 characters");
            return false;
       }
        else {
            $("#locationDescription-error").text("");
            return true;
       }
   }
   <!-------------------Opening Hours------------------->

   function resetTimer() {
      $(".week-list-main li input").prop('checked', false)
      modelOpeningSave()
      //$('#close').prop('checked', false);
      $("#opening-hours-type").val("Open");
      $("#close-time-row").hide();
      $("#type-time-container").html("");
      
      addStartEndRowElement("");
      $("#new-splitting-row").hide();
   }

   days.forEach((day, index) => {
        var dayElement = "<li> <span class='row'> <span class='col-md-6'> <span class='day-value' data-day='" + day.toLowerCase() + "'>" + day + ":</span> </span>" +
            "<span class='col-md-4'><span id='" + day.toLowerCase() + "-time-container'><input type='text' placeholder='—:— - —:—'></span> </span>"+
            "<span class='col-md-2'><a class='edit-time'" + day.toLowerCase() + "-edit' data-toggle='modal' data-target='.bs-hours-modal' >" +
            "<cwc-icon name='edit' color='true-black'></cwc-icon></a></span> </span></li>";

        var weekElement = $("ul.week-list");
        weekElement.append(dayElement);
   });

    $(function () {
        $(".edit-all-hours").on("click", function () {
            $(".sat-sun").prop("checked", false);
            $(".mon-fri").prop("checked", false);
            $(".common-chekbox").prop("checked", true);
       });

        $(".mon-to-fri").on("click", function () {
            $(".common-chekbox").prop("checked", false);
            $(".sat-sun").prop("checked", false);
            $(".mon-fri").prop("checked", true);
       });

        $(".sat-to-sun").on("click", function () {
            $(".mon-fri").prop("checked", false);
            $(".common-chekbox").prop("checked", false);
            $(".sat-sun").prop("checked", true);
       });

        $(".edit-time").on("click", function () {
            $(".bs-hours-modal").find(".common-chekbox").prop("checked", false);
            //let dayname = $(this).parent("li").find(".day-value").data("day");
            let dayname = $(this).parent().parent().find(".day-value").data("day")
            $(".bs-hours-modal")
                .find("input[value=" + dayname + "]")
                .prop("checked", true);

            var timeInputs = $(this).parent().parent().find(".col-md-4 input");
            $("#type-time-container").html("");
            if(timeInputs.length === 1) {
               setValueInTimeModel(timeInputs, false)
           } else {
               $("#opening-hours-type").val("Splitting")
               timeInputs.each(function () {
                  setValueInTimeModel(this, true)
               })
           }
       });

        function setValueInTimeModel(timeElement, isSplit) {
            modelOpeningSave()
            var timeValue = timeElement.val();
               $("#"+timeElement.parent().attr('id').replace("-time-container","")).prop('checked', true)
           
               if(timeValue === "Closed") {
                  $("#opening-hours-type").val("Closed")
                  $("#close-time-row").hide();
                  $('#close').prop('checked', true);
           } else {
                  if(!isSplit) {
                     $("#opening-hours-type").val("Open")
               }
              addStartEndRowElement(timeValue)
           }
           
            $('#close').prop('checked', false);
           
            $("#close-time-row").hide();
           
            $("#new-splitting-row").hide();
       }

        $(".submit-hours").on("click", function () {
            var dayClosed = $("#close").is(':checked');
            var hoursType = $("#opening-hours-type").val();
            
             $('.week-list-main li').each(function () {
                if ($(this).find('input[type="checkbox"]').is(':checked')) {
                    var dayVal = $(this).find('input[type="checkbox"]').val();
                    $("#" + dayVal + "-time-container").html("")
                   if("Open" === hoursType) {
                       $("#" + dayVal + "-time-container").append("<input type='text' placeholder='—:— - —:—' value='"+ $(".start-time").val() + " - " + $(".close-time").val() +"'> ")
                   } else if("Splitting" === hoursType) {
                       $("#type-time-container").find(".row").each(function() {
                           $("#" + dayVal + "-time-container").append("<input type='text' placeholder='—:— - —:—' value='"+ $(this).find("input.start-time").val() + " - " + $(this).find("input.close-time").val() +"'> ")
                       })
                   } else if("Closed" === hoursType) {
                       $("#" + dayVal + "-time-container").append("<input type='text' placeholder='—:— - —:—' value='Closed'> ")
                        var isClosed = $("#close").val();
                   }
               }
           });
            resetTimer();
       });
   });    

    function addStartEndRowElement(timeValue) {
      var startTimeValue = "";
      var closeTimeValue = "";
      var times = timeValue.split(" - ");

      if(timeValue) {
         startTimeValue = times[0];
         closeTimeValue = times[1];
       }

      var startEndRow = '<div class="row time-row">' +
         '<div class="col-md-6">' +
            '<div class="form-group time-form-group">' +
               '<div class="form-item time-form-item">' +
                  '<input type="time" class="timepicker-24-hr start-time" value="'+ startTimeValue + '" />' +
                  '<label for="start-time"> Open time </label>' +
               '</div>' +
            '</div>' +
         '</div>' +
         '<div class="col-md-6">' +
            '<div class="form-group time-form-group">' +
               '<div class="form-item time-form-item">' +
                  '<input type="time" name="timepicker-24-hr" class="timepicker-24S-hr close-time" value="'+ closeTimeValue + '" />' +
                  '<label for="close-time"> Close time </label>' +
               '</div>' +
            '</div>' +
         '</div>' +
         '<div class="col-md-12"><p class="error-message"></p></div>' +
      '</div>';

      $("#type-time-container").append(startEndRow);
   }

   addStartEndRowElement("");

   $("#new-splitting-row").on("click", function(){
      modelOpeningSave()
      addStartEndRowElement("")
   })

   $('#opening-hours-type').on('change', function() {
     var selectedValue = $(this).val();

     modelOpeningSave();
     if(selectedValue == "Closed") {
         modelOpeningSave(false)
     }
     addTimeFieldsRowByType(selectedValue);
   });

   function addTimeFieldsRowByType(selectedValue) {
     if(selectedValue === 'Open') {
       $("#new-splitting-row").hide();
          $("#type-time-container").html("");
          addStartEndRowElement("");
       } else if(selectedValue === 'Splitting') {
          $("#new-splitting-row").show();
          $("#type-time-container").html("");
            $("#close-time-row").hide();
          addStartEndRowElement("");
       } else if(selectedValue === 'Closed') {
          $("#new-splitting-row").hide();
          $("#type-time-container").html("");
          $("#close-time-row").show();
       }  
   }

   function validateTime() {
     let allValid = true;
     modelOpeningSave(true);
     $('#type-time-container .row').each(function(index) {
         const startTime = $(this).find('.start-time').val();
         const closeTime = $(this).find('.close-time').val();
         const errorMessage = $(this).find('.error-message');
         errorMessage.text("")
         errorMessage.show();
         
         if (startTime === "" && closeTime === "") {
             errorMessage.text("Please fill start and end time.");
             return;
         }
         
         if (startTime === "" || closeTime === "") {
             errorMessage.text("One of the fields is empty.");
             return;
         }
         
         if (startTime > closeTime) {
             errorMessage.text("Start time is not earlier than close time.");
             allValid = false;
         }else if (startTime == closeTime) {
             errorMessage.text("Start time and close time shoud not same.");
             allValid = false;
         }
          else {
             errorMessage.hide();
         }
     });
     if(allValid) modelOpeningSave(false);
     return allValid;
   }

   $(document).on('blur', '.start-time, .close-time', function() {
      validateTime();
   });

   function modelOpeningSave(isDisable=true) {
      $('#btnSubmit').prop('disabled', isDisable);
   }

   <!-------------------Contact Cards------------------->
    $(".add-contact").on("click", function () {
         resetContactModel();
         modelOpeningSave()
   });

    function resetContactModel() {
        $("#contactname").val("");
        $("#emailaddress").val("");
        $("#phonenumbermodal").val("");
        $("#job-position").val("")
        $("#save-contact").text("Save");
   }

    resetContactModel();
    
    function setDataInContactModel(name, email, phone, job, update, updateId) {
        resetContactModel();
    
        if(name && name != '-') {
           $("#contactname").val(name); 
           $("#contactname").parent().addClass("focused");
       }
        if (email && email != '-') {
           $("#emailaddress").val(email); 
           $("#emailaddress").parent().addClass("focused");
       }

        if (job && job != '-') {
           $("#job-position").val(job); 
           $("#job-position").parent().addClass("focused");
       }
        
        $("#phonenumbermodal").val(phone);
        if (update) {
            $("#save-contact").text(updateLabel);
            $(".update-id").val(updateId);
       }
   }

    $(document.body).on("click",
   ".contact-card-remove", function () {
        var contactCard = $(this).closest(".col-md-4");
        contactCard.remove();
        Toast.success("${(contactCardRemoveMessage?has_content)?then(contactCardRemoveMessage, 'Contact removed successfully')}");
   });

    $(document.body).on("click",".card-edit", function () {
        var contactCard = $(this).closest(".contact-card");
        var contactname = contactCard
            .find(".contact-name")
            .contents()
            .filter(function () {
                return this.nodeType === Node.TEXT_NODE;
       }).text().trim();

        var contactjob = contactCard.find(".contact-job").text().trim();
        var contactemail = contactCard.find(".contact-email a").text().trim();
        var contactphone = contactCard.find(".contact-phone").text().trim();
        var updateId = contactCard.attr('id');

        setDataInContactModel(
            contactname,
            contactemail,
            contactphone,
            contactjob,
       true,
            updateId
        );
        $("#bs-contact-modal").addClass("open");
   });

    $("#save-contact").on("click", function (e) {
    
       var operationType = $("#save-contact").text();

        var contactName = $("#contactname").val() || "-";
        var jobPosition = $("#job-position").val() || "-";
        var emailAddress = $("#emailaddress").val() || "-";
        var phoneNumber = $("#phonenumbermodal").val();

        var phoneInputtt = initializeIntlTelInput(preferredCountries, countryCodeValueModal, 'phonenumbermodal',"phonenumbermodal-error");

       if (phoneNumber === '' || !validatePhoneNumber(phoneInputtt,"phonenumbermodal-error") && validateEmailAddress(emailAddress)) {
            Toast.danger("${(allValidationMessage?has_content)?then(allValidationMessage, 'All fields must be filled out with valid data in the contact form')}");
            return;
       }
   	
        if (operationType === "Save") {
            let contactDiv = "<div class='col-md-4'>" +
                "<div class='contact-card' id='contact-card-id-" + (contactCardId++) + "'>" +
                "<h2 class='contact-name'>" + contactName +
                "</h2>" +
                "<a class='card-edit'>" +
                "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
                "</a>" +
                "<a class='contact-card-remove'>" +
                "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
                "</a>" +
                "<p class='contact-job'>" + jobPosition + "</p>" +
                "<p class='contact-email'><a href='mailto:" + emailAddress + "'>" + emailAddress + "</a></p>" +
                "<p class='contact-phone'>" + phoneNumber + "</p>" +
                "</div>" +
                "</div>";
            $('#contact-card-container').append(contactDiv);
            Toast.success("${(tosterMessageSaveSuccess?has_content)?then(tosterMessageSaveSuccess, 'Data added successfully')}");
          $("#bs-contact-modal").removeClass("open");
       } else {
            var contactCard = $('#' + $(".update-id").val());
            contactCard.find(".contact-name").text(contactName);
            contactCard.find(".contact-job").text(jobPosition);
            contactCard.find(".contact-email a").text(emailAddress);
            contactCard.find(".contact-phone").text(phoneNumber);
            Toast.success("${(tosterMessageUpdateSuccess?has_content)?then(tosterMessageUpdateSuccess, 'Data updated successfully')}");
            $("#bs-contact-modal").removeClass("open");
       }
        resetContactModel();
   });

   $(".add-file").on("click", function () {
       resetFileModal();
   });

    function resetFileModal() {

       $("#filename").val("");
         
       var fileInputt = document.getElementById('file');
       var label = document.querySelector('label[for="file"]');

       fileInputt.value = '';
       label.textContent = 'File : ';

       $("#save-file").text(saveLabel);
   }
   resetFileModal();

   var updateFileId = null;
   function setDataInFileModal(name, value, update) {
       resetFileModal();
      
       if (name && name !== '-') {
           $("#filename").val(name); 
           $("#filename").parent().addClass("focused");
       }
      
       if (value && value !== '-') {
            var fileInput = document.getElementById('file');
            var label = document.querySelector('label[for="file"]');

            fileInput.value = '';
            label.textContent = 'File : ' + value;
       }
       if (update) {
           $("#save-file").text(updateLabel);
       }
   }


    $(document.body).on("click",".file-card-remove", function () {
        var fileCard = $(this).closest(".col-md-4");
        var fileValue = fileCard.find(".file-value").text().trim();
        console.log(fileValue);
        fileCard.remove();
        Toast.success("${(fileCardRemoveMessage?has_content)?then(fileCardRemoveMessage, 'File card removed successfully')}");
   });


   $(document.body).on("click",
   ".file-card-edit", function () {

       var fileCard = $(this).closest(".file-card");

       var fileName = fileCard.find(".file-name").text().trim();

       var fileValue = fileCard.find(".file-value").text().trim();

       var updateId = fileCard.attr('id');

       updateIndexId = updateId;

       updateFileId = updateId;

       setDataInFileModal(
           fileName,
           fileValue,true
       );

       $("#bs-file-modal").addClass("open");
   });

   $("#save-file").on("click", function (e) {

       var operationType = $("#save-file").text();
     
       var fileName = $("#filename").val() || "-";

       var fileValue = $("#filevalue").val() || "-";

       var label = document.querySelector('label[for="file"]');

      var fileNameData = label.textContent.split(' : ')[1].trim();
      
      
       // Null check for required fields
       if (!fileName || !fileValue || !fileNameData) {
           Toast.danger("Please fill in all required fields.");
           return; // Exit the function if any required field is missing
       }

       if (operationType === "Save") {
           let fileDiv = "<div class='col-md-4'>" +
               "<div class='file-card' id='file-card-id-" + (fileCardId++) + "'>" +
               "<h2 class='file-name'>" + fileName +
               "</h2>" +
               "<a class='file-card-edit'>" +
               "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
               "</a>" +
               "<a class='file-card-remove'>" +
               "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
               "</a>" +
               "<p class='file-value'>" + fileNameData + "</p>" +
               "</div>" +
               "</div>";
           $('#file-card-container').append(fileDiv);
           Toast.success("${(tosterMessageSaveSuccess?has_content)?then(tosterMessageSaveSuccess, 'Data added successfully')}");
           $("#bs-file-modal").removeClass("open");
       } else {
            if(updateFileId) {
              var fileCard = $('#' + updateFileId);
             
               
               $("#"+updateFileId+" p:last-child").text(fileNameData);

               fileCard.find(".file-name").text(fileName);

               var fileInput = document.getElementById('file');
               var label = document.querySelector('label[for="file"]');

               fileInput.value = '';
               label.textContent = 'File : ' + fileNameData; 

               Toast.success("${(tosterMessageUpdateSuccess?has_content)?then(tosterMessageUpdateSuccess, 'Data updated successfully')}");
              $("#bs-file-modal").removeClass("open");
           } else {
           }
       }
       resetFileModal();
   });
   <!-- page logic -->
   $(".add-page").on("click", function () {
       resetPageModal();
   });

    function resetPageModal() {
       $("#pagename").val("");
       $("#fileUrl").val("");
       $("#save-page").text(saveLabel);
   }


   resetPageModal();
   var updatePageId = null;
   function setDataInPageModal(name, value, update) {

       resetPageModal();
       if (name && name !== '-') {
           $("#pagename").val(name); 
           $("#pagename").parent().addClass("focused");
       }
    
       if (value && value !== '-') {
           $("#fileUrl").val(value); 
           $("#fileUrl").parent().addClass("focused");
       }

       if (update) {
           $("#save-page").text(updateLabel);
       }
   }



    $(document.body).on("click",".page-card-remove", function () {
        var pageCard = $(this).closest(".col-md-4");
        pageCard.remove();
        Toast.success("${(pageCardRemoveMessage?has_content)?then(pageCardRemoveMessage, 'Data removed successfully')}");
   });

   $(document.body).on("click",
   ".page-card-edit", function () {

       var pageCard = $(this).closest(".page-card");

       var pageName = pageCard.find(".page-name").text().trim();

       var pageValue = pageCard.find(".page-url").text().trim();

       var updateIdd = pageCard.attr('id');

       updatePageId = updateIdd;
       
       setDataInPageModal(
           pageName,
           pageValue,true
       );

       $("#bs-page-modal").addClass("open");
   });


   $("#save-page").on("click", function (e) {
       
       e.preventDefault(); 
        var operationType = $("#save-page").text();

       var pagename = $("#pagename").val() || "-";
       var fileUrl = $("#fileUrl").val() || "-";
       
       if (!pagename || !fileUrl) {
           Toast.danger("Please fill in all required fields.");
           return; // Exit the function if any required field is missing
       }
      
       if (operationType === "Save") {

       var pageCard = "<div class='col-md-4'>" +
                          "<div class='page-card' id='page-card-id-" + (pageCardId++) + "'>" +
                              "<h2 class='page-name'>" + pagename + "</h2>" +
                              "<a class='page-card-edit'>" +
                               "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
                               "</a>" +
                               "<a class='page-card-remove'>" +
                               "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
                               "</a>" +
                              "<p class='page-url'>" + fileUrl + "</p>" +
                          "</div>" +
                      "</div>";

       $('#page-card-container').append(pageCard);
       Toast.success("${(tosterMessageSaveSuccess?has_content)?then(tosterMessageSaveSuccess, 'Data added successfully')}");
       $("#bs-page-modal").removeClass("open");
       }else {
            if(updatePageId) {
              var pageCard = $('#' + updatePageId);   
              pageCard.find(".page-name").text(pagename);
              pageCard.find(".page-url").text(fileUrl);
              Toast.success("${(tosterMessageUpdateSuccess?has_content)?then(tosterMessageUpdateSuccess, 'Data updated successfully')}");
              $("#bs-page-modal").removeClass("open");
           } else {
           }
       }
      resetPageModal();
   }); 


   var productCardId = 1;
   var updateProductId = null;
   var productTypeCategories = null;
   var finalProductsCategories = []

function getCategoryIdByName(productName) {
    if (!productTypeCategories) {
        return updateProductDropdownOptions().then(() => {
            return findCategoryId(productName);
        });
    } else {
        return Promise.resolve(findCategoryId(productName));
    }
}

function findCategoryId(productName) {
    const category = productTypeCategories.find(cat => cat.titleCurrentValue.toLowerCase() === productName.toLowerCase());
    return category ? category.categoryId : null;
}

async function updateProductDropdownOptions() {
    try {
        const response = await new Promise((resolve, reject) => {
            Liferay.Service(
                '/assetcategory/get-vocabulary-categories',
                {
                    groupId: countryGroupId,
                    parentCategoryId: productParentCatId,
                    vocabularyId: productTypeVocId,
                    start: -1,
                    end: -1,
                    "-obc": ""
                },
                function(result) {
                    resolve(result);
                },
                function(error) {
                    reject(error);
                }
            );
        });

        productTypeCategories = response;
        var $select = $('#pro-link-name');
        
        // Clear existing options
        //$select.empty();
        
        $.each(response, function(index, category) {
            $select.append($('<option>', {
                value: category.categoryId,
                text: category.titleCurrentValue
            }));
        });

        return response;
    } catch (error) {
        console.error("Error updating product dropdown options:", error);
        throw error;
    }
}

updateProductDropdownOptions();

function getProductHTML(productName, productCatId, productLink) {
   return "<div class='col-md-4'>" +
             "<div class='pro-link-card' id='pro-link-card-id-" + (productCardId++) + "'>" +
                 "<h2 class='pro-link-name' id='"+productCatId+"'>" + productName + "</h2>" +
                 "<a class='pro-link-card-edit'>" +
                  "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
                  "</a>" +
                  "<a class='pro-link-card-remove'>" +
                  "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
                  "</a>" +
                 "<p class='pro-link'>" + productLink + "</p>" +
             "</div>" +
         "</div>"
}

function generateProductHTMLAndAppend(productName, productCatId, productLink) {
      var productCard = getProductHTML(productName, productCatId, productLink);
      $('#pro-link-card-container').append(productCard);
}

$("#save-product").on("click", function (e) {
   
   e.preventDefault(); 
   var operationType = $("#save-product").text();

   var productCatId = $("#pro-link-name").val();
   var productName = $("#pro-link-name :selected").text();
   var productLink = $("#pro-link").val() || "-";
   
   if (!productCatId || !productLink) {
       Toast.danger("Please fill in all required fields.");
       return;
   }
  
   if (operationType === "Save") {
      generateProductHTMLAndAppend(productName, productCatId, productLink)

      Toast.success("${(tosterMessageSaveSuccess?has_content)?then(tosterMessageSaveSuccess, 'Data added successfully')}");
      $("#bs-product-modal").removeClass("open");
   }else {
        if(updateProductId) {
          var productCard = $('#' + updateProductId);   
          productCard.find(".pro-link-name").text(productName);
          productCard.find(".pro-link").text(productLink);
          Toast.success("${(tosterMessageUpdateSuccess?has_content)?then(tosterMessageUpdateSuccess, 'Data updated successfully')}");
          $("#bs-product-modal").removeClass("open");
       } else {
       }
   }
  resetProductModal();
}); 


$(".add-product").on("click", function () {
   resetProductModal();
});

function resetProductModal() {
   $("#pro-link-name").val("");
   $("#pro-link").val("");
   $("#save-product").text(saveLabel);
}

function setDataInProductModal(name, value, update) {
   resetProductModal();
   if (name && name !== '-') {
      (async function() {
         const categoryId = await getCategoryIdByName(name);
         $("#pro-link-name").val(categoryId); 
      })();
   }

   if (value && value !== '-') {
       $("#pro-link").val(value); 
       $("#pro-link").parent().addClass("focused");
   }

   if (update) {
       $("#save-product").text(updateLabel);
   }
}

$(document.body).on("click",".pro-link-card-remove", function () {
    var productCard = $(this).closest(".col-md-4");
    productCard.remove();
    Toast.success("${(productCardRemoveMessage?has_content)?then(productCardRemoveMessage, 'Data removed successfully')}");

});

$(document.body).on("click",".pro-link-card-edit", function () {

   var productCard = $(this).closest(".pro-link-card");

   var productName = productCard.find(".pro-link-name").text().trim();

   var productLink = productCard.find(".pro-link").text().trim();

   updateProductId = productCard.attr('id');
   
   setDataInProductModal(
       productName,
       productLink,true
   );

   $("#bs-product-modal").addClass("open");
});

   $(".add-GMB").on("click", function () {
       resetGMBModal();
   });

    function resetGMBModal() {

       $("#filePublisher").val("");
       $("#fileDescription").val("");

      
       var fileInputtDemo = document.getElementById('GMBfile');
       var labelD = document.querySelector('label[for="fileGMB"]');

       fileInputtDemo.value = '';
       labelD.textContent = 'Image : ';
       
       $("#save-GMB-data").text(saveLabel);
   }

   resetGMBModal();

   var updateGMBId = null;

   function setDataInGMBModal(filePublisher, fileDescription,GMBfileData,update) {
       
       resetGMBModal();
      
       if (filePublisher && filePublisher !== '-') {
           $("#filePublisher").val(filePublisher); 
           $("#filePublisher").parent().addClass("focused");
       }
      
       
       if (fileDescription && fileDescription !== '-') {
           $("#fileDescription").val(fileDescription); 
           $("#fileDescription").parent().addClass("focused");
       }
      

       if (GMBfileData && GMBfileData !== '-') {

            var fileInput = document.getElementById('GMBfile');
            var label = document.querySelector('label[for="fileGMB"]');
            fileInput.value = '';
            label.textContent = 'Image : ' + GMBfileData;
           
       }

       if (update) {
           $("#save-GMB-data").text(updateLabel);
       }
   }

    $(document.body).on("click",".GMB-card-remove", function () {
        var GMBCard = $(this).closest(".col-md-4");
        GMBCard.remove();
        Toast.success("${(GMBCardRemoveMessage?has_content)?then(GMBCardRemoveMessage, 'GMB removed successfully')}");
   });



   $(document.body).on("click",".GMB-card-edit", function () {

       var GMBCard = $(this).closest(".GMB-card");

       var filePublisher = GMBCard.find(".file-Publisher").text().trim();

       var fileDescription = GMBCard.find(".file-Description").text().trim();
       
       var GMBfileData = GMBCard.find(".file-value").text().trim();
       
       var updateId = GMBCard.attr('id');

       GMBupdateIndexId = updateId;

       updateGMBId = updateId;

       setDataInGMBModal(
           filePublisher,
           fileDescription,
           GMBfileData,true
       );
       $("#bs-GMB-modal").addClass("open");
   });



   $("#save-GMB-data").on("click", function (e) {

      var operationType = $("#save-GMB-data").text();
     
      var filePublisher = $("#filePublisher").val() || "-";
     
      var fileDescription = $("#fileDescription").val() || "-";
    
      var labelDemo = document.querySelector('label[for="fileGMB"]');

      var fileNameGMB = labelDemo.textContent.split(' : ')[1].trim();

       if (!filePublisher || !fileDescription || !fileNameGMB) {
           Toast.danger("Please fill in all required fields.");
           return; // Exit the function if any required field is missing
       }
       
      if (operationType === "Save"){
         let GMBDIV = "<div class='col-md-4'>" +
               "<div class='GMB-card' id='GMB-card-id-" + (GMBCardId++) + "'>" +
               "<h2 class='file-Publisher'>" + filePublisher +
               "</h2><br>" +
               "<a class='GMB-card-edit'>" +
               "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
               "</a>" +
               "<a class='GMB-card-remove'>" +
               "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
               "</a>" +
               "<h2 class='file-Description'>" + fileDescription +
               "</h2>" +
               "<p class='file-value'>" + fileNameGMB + "</p>" +
               "</div>" +
               "</div>";

        $('#GMB-card-container').append(GMBDIV);
        Toast.success("${(tosterMessageSaveSuccess?has_content)?then(tosterMessageSaveSuccess, 'Data added successfully')}");
        $("#bs-GMB-modal").removeClass("open");
       }else {
            if(updateGMBId) {

              var GMBCard = $('#' + updateGMBId);
              $("#"+updateGMBId+" p:last-child").text(fileNameGMB);

               GMBCard.find(".file-Publisher").text(filePublisher);

               GMBCard.find(".file-Description").text(fileDescription);
     
               var fileInput = document.getElementById('GMBfile');
            
               var labelData = document.querySelector('label[for="fileGMB"]');

               fileInput.value = '';
              
               labelData.textContent = 'Image : ' + fileNameGMB; 

               Toast.success("${(tosterMessageUpdateSuccess?has_content)?then(tosterMessageUpdateSuccess, 'Data updated successfully')}");
               $("#bs-GMB-modal").removeClass("open");
           } else {
           }
       }
         resetGMBModal();
   });
       
    $(".popup-close").on("click", function () {
      $('.bs-hours-modal').modal('hide');
      $('.modal-backdrop').remove();
      $('.bs-contact-modal').modal('hide');
      $('.bs-data-modal').modal('hide');
      $('.bs-page-modal').modal('hide');
      $('.bs-file-modal').modal('hide');
      $('.bs-GMB-modal').modal('hide');
   });

   $('#country').on('change', function() {
     var selectedValue = $(this).val();
     const selectedCountryObj = countries.find(country => country.name === selectedValue);

     if(selectedCountryObj) {
       setFlagCountryInAllPhone(selectedCountryObj.code)
       }
   });


   $(function() {

     $('.control-fileupload input[type=file]').change(function(){
       var t = $(this).val();
       var labelText = 'File : ' + t.substr(12, t.length);
       $(this).prev('label').text(labelText);
       })
   });


   $(function() {
     $('.GMB-fileupload input[type=file]').change(function(){
       var t = $(this).val();
       var labelText = 'Image : ' + t.substr(12, t.length);
       $(this).prev('label').text(labelText);
       })
   });
   </script>