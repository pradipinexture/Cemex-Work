<link rel="stylesheet" href="https://cdn.datatables.net/1.11.5/css/jquery.dataTables.min.css" />
<link rel="stylesheet" href="https://cdn.datatables.net/select/1.2.7/css/select.dataTables.min.css" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.7.2/css/all.min.css" />
<link rel="stylesheet" href="/documents/20152/60315374/sh_toaster.css">
<link rel="stylesheet" href="/documents/20152/60315374/view-locations.css">

<link rel="stylesheet" href="/documents/20152/60315374/add-location.css">
<script type="module"
   src="https://www.cemexgo.com/cdn/web-components/latest/cmx-web-components/cmx-web-components.esm.js"></script>
<script nomodule
   src="https://www.cemexgo.com/cdn/web-components/latest/cmx-web-components/cmx-web-components.js"></script>
<script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
<script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/select/1.2.7/js/dataTables.select.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
<script>
   define._amd = define.amd;
   define.amd = false;
</script>

<script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.js"></script>
<script>
   define.amd = define._amd;
</script>

<#assign journalService = serviceLocator.findService("com.liferay.journal.service.JournalArticleService") />
<#assign article = journalService.getArticle(20152,"60708937")/>
<#assign docXml = saxReaderUtil.read(article.getContentByLocale(themeDisplay.getLanguageId())) />
<#assign importCSV = docXml.valueOf("//dynamic-element[@name='importCSV']/dynamic-content/text()")!"" />
<#assign downloadCSV = docXml.valueOf("//dynamic-element[@name='downloadCSV']/dynamic-content/text()")!"" />
<#assign openLabel = docXml.valueOf("//dynamic-element[@name='openLabel']/dynamic-content/text()")!"" />
<#assign closeLabel = docXml.valueOf("//dynamic-element[@name='closeLabel']/dynamic-content/text()")!"" />
<#assign status = docXml.valueOf("//dynamic-element[@name='status']/dynamic-content/text()")!"" />
<#assign statusMessage = docXml.valueOf("//dynamic-element[@name='statusMessage']/dynamic-content/text()")!"" />
<#assign typeLabel = docXml.valueOf("//dynamic-element[@name='typeLabel']/dynamic-content/text()")!"" />
<#assign nameLable = docXml.valueOf("//dynamic-element[@name='nameLable']/dynamic-content/text()")!"" />
<#assign regionLabel = docXml.valueOf("//dynamic-element[@name='regionLabel']/dynamic-content/text()")!"" />
<#assign planType = docXml.valueOf("//dynamic-element[@name='planType']/dynamic-content/text()")!"" />
<#assign idLabel = docXml.valueOf("//dynamic-element[@name='idLabel']/dynamic-content/text()")!"" />
<#assign promotionLabel = docXml.valueOf("//dynamic-element[@name='promotionLabel']/dynamic-content/text()")!"" />
<#assign viewDetails = docXml.valueOf("//dynamic-element[@name='viewDetails']/dynamic-content/text()")!"" />
<#assign editLabel = docXml.valueOf("//dynamic-element[@name='editLabel']/dynamic-content/text()")!"" />
<#assign openLocation = docXml.valueOf("//dynamic-element[@name='openLocation']/dynamic-content/text()")!"" />
<#assign closeLocation = docXml.valueOf("//dynamic-element[@name='closeLocation']/dynamic-content/text()")!"" />
<#assign viewListings = docXml.valueOf("//dynamic-element[@name='viewListings']/dynamic-content/text()")!"" />
<#assign nameOfImportLabel = docXml.valueOf("//dynamic-element[@name='nameOfImportLabel']/dynamic-content/text()")!"" />
<#assign chooseFileLabel = docXml.valueOf("//dynamic-element[@name='chooseFileLabel']/dynamic-content/text()")!"" />
<#assign fileDataUploadSuccess = docXml.valueOf("//dynamic-element[@name='fileDataUploadSuccess']/dynamic-content/text()")!"" />
<#assign fileInformation  = docXml.valueOf("//dynamic-element[@name='FileInformation']/dynamic-content/text()")!"" />
<#assign fileDataAddSuccess = docXml.valueOf("//dynamic-element[@name='fileDataAddSuccess']/dynamic-content/text()")!"" />
<#assign LocationCreatedMessage  = docXml.valueOf("//dynamic-element[@name='LocationCreatedMessage']/dynamic-content/text()")!"" />
<#assign LocationUpdateSuccess = docXml.valueOf("//dynamic-element[@name='LocationUpdateSuccess']/dynamic-content/text()")!"" />
<#assign LocationFailMessage  = docXml.valueOf("//dynamic-element[@name='LocationFailMessage']/dynamic-content/text()")!"" />
<#assign FileRequireValidation  = docXml.valueOf("//dynamic-element[@name='FileRequireValidation']/dynamic-content/text()")!"" />
<#assign AddLocation  = docXml.valueOf("//dynamic-element[@name='AddLocation']/dynamic-content/text()")!"" />
<#assign selectedItems  = docXml.valueOf("//dynamic-element[@name='selectedItems']/dynamic-content/text()")!"" />
<#assign downloadSelectedLocs  = docXml.valueOf("//dynamic-element[@name='downloadSelectedLocs']/dynamic-content/text()")!"" />
<#assign downloadAllLocs  = docXml.valueOf("//dynamic-element[@name='downloadAllLocs']/dynamic-content/text()")!"" />
<#assign CancelLabel  = docXml.valueOf("//dynamic-element[@name='CancelLabel']/dynamic-content/text()")!"" />
<#assign SaveLabel  = docXml.valueOf("//dynamic-element[@name='SaveLabel']/dynamic-content/text()")!"" />
<#assign allLabel  = docXml.valueOf("//dynamic-element[@name='allLabel']/dynamic-content/text()")!"" />
<#assign searchLabel  = docXml.valueOf("//dynamic-element[@name='searchLabel']/dynamic-content/text()")!"" />

<#assign exportWait  = docXml.valueOf("//dynamic-element[@name='exportWait']/dynamic-content/text()")!"" />
<#assign noLocations  = docXml.valueOf("//dynamic-element[@name='noLocations']/dynamic-content/text()")!"" />
<#assign exportError  = docXml.valueOf("//dynamic-element[@name='exportError']/dynamic-content/text()")!"" />
<#assign atleastOne  = docXml.valueOf("//dynamic-element[@name='atleastOne']/dynamic-content/text()")!"" />
<#assign selectedDownloaded  = docXml.valueOf("//dynamic-element[@name='selectedDownloaded']/dynamic-content/text()")!"" />
<#assign missingCreate  = docXml.valueOf("//dynamic-element[@name='missingCreate']/dynamic-content/text()")!"" />
<#assign locationNotCreated  = docXml.valueOf("//dynamic-element[@name='locationNotCreated']/dynamic-content/text()")!"" />

<script>
   const searchLabel = "${(searchLabel?has_content)?then(searchLabel, 'Search')}:";
   const exportWait = "${(exportWait?has_content)?then(exportWait, 'Please wait, we are exporting the locations.')}";
   const noLocations = "${(noLocations?has_content)?then(noLocations, 'No locations available to export.')}";
   const exportError = "${(searchLabel?has_content)?then(exportError, 'Export error. Please try again.')}";
   const atleastOne = "${(atleastOne?has_content)?then(atleastOne, 'At least one location must be selected.')}";
   const selectedDownloaded = "${(selectedDownloaded?has_content)?then(selectedDownloaded, 'CSV file for the selected locations has been downloaded successfully.')}";
   const missingCreate = "${(missingCreate?has_content)?then(missingCreate, 'Location is currently missing from our website. We are in the process of creating it.')}";
   const locationNotCreated = "${(locationNotCreated?has_content)?then(locationNotCreated, 'Requested location is not created.')}";

   const fileDataUploadSuccess = "${(fileDataUploadSuccess?has_content)?then(fileDataUploadSuccess, 'location-import-status.csv file uploaded sucesssfully')}"
   const fileRequireValidation = "${(FileRequireValidation?has_content)?then(FileRequireValidation, 'Please select a file.')}";
   const locationUpdateSuccess = "${(LocationUpdateSuccess?has_content)?then(LocationUpdateSuccess, 'Location is updated successfully')}";
   const locationCreatedMessage = "${(LocationCreatedMessage?has_content)?then(LocationCreatedMessage, 'Requested location is created successfully')}";
   const locationFailMessage = "${(LocationFailMessage?has_content)?then(LocationFailMessage, 'Requested location is not created.')}";
</script>

<#assign currentUser=permissionChecker.getUser()>
<#assign userRoles=currentUser.getRoles()>
<#assign countrySet=[]>
<#assign locationRoles = ["Content Approver","Content Creator"]>
<#assign europeanAdmin = ["European Admin"]>
<#assign roleNames = []> <!-- Initialize an array to store role names -->
<#list userRoles as userRole>
<#assign roleParts=userRole.getName()?split('-')>
<#assign roleName = roleParts[0]?trim>
<#assign roleNames = roleNames + [roleName]>
<#if roleParts?size gt 1>
<#assign country=roleParts[1]?trim>
<#if country?has_content>
<#assign countrySet=countrySet + [country]>
</#if>
</#if>
</#list>
<main>
   <div class="sh-toast-container" id="shToastContainerTop"></div>
   <div class="sh-toast-container" id="shToastContainerBottom"></div>
   <div id="overlay">
      <div class="cv-spinner"></div>
   </div>
   <div class="dataTable-main newdatatable">
      <script>
         var uniqueValues = [];
      </script>
      <#if entries?has_content>
      <div class="action-main">
         <div class="dropdown" id="region-dropdown">
            <button class="btn btn-primary dropdown-toggle region-dropdown-toggle" type="button" data-toggle="dropdown" id="filter-dropdown">
            ${(regionLabel?has_content)?then(regionLabel, 'Region')} <span class="caret"></span>
            </button>
            <ul id="region-data" class="dropdown-menu" aria-labelledby="filter-dropdown">
               <li data-filter="All">${(allLabel?has_content)?then(allLabel, 'All')}</li>
            </ul>
         </div>
         <div class="action-btn">
            <span id='selected-check-count'>0</span><span> ${(selectedItems?has_content)?then(selectedItems, 'items selected')}</span>
            <button type="button" id="import-csv-button" class="btn btn-primary round-btn add-file" data-target="bs-file-modal" data-toggle="popup">
               <cwc-icon name="plus" color="bright-blue"></cwc-icon>
               ${(importCSV?has_content)?then(importCSV, 'Import CSV')}
            </button>
            <span class="dropdown" id="download-dropdown">
               <button type="button" id="csv-button" data-toggle="dropdown" class="btn btn-primary round-btn">
                  ${(downloadCSV?has_content)?then(downloadCSV, 'Download CSV')}
                  <cwc-icon name="arrow-down-rounded-fill" color="bright-blue"></cwc-icon>
               </button>
               <ul id="download-options" class="dropdown-menu">
                  <li id="download-selected">${(downloadSelectedLocs?has_content)?then(downloadSelectedLocs, 'Download Selected Locations')}</li>
                  <li id="download-all">${(downloadAllLocs?has_content)?then(downloadAllLocs, 'Download All Locations')}</li>
               </ul>
            </span>
            <button type="button" id="open-locations" class="btn btn-primary round-btn">
            ${(openLabel?has_content)?then(openLabel, 'Open')}
            </button>
            <button type="button" id="close-locations" class="btn btn-primary round-btn">
            ${(closeLabel?has_content)?then(closeLabel, 'Close')}
            </button>
         </div>
      </div>
      <table id="locationtable" class="display cemex-table" style="width: 100%">
         <thead>
            <tr>
               <th>
                  <input class="main-checkbox" style="border: none; background: transparent; font-size: 14px"
                     type="checkbox" id="master">
               </th>
               <th>${(status?has_content)?then(status, 'Status')}</th>
               <th>${(statusMessage?has_content)?then(statusMessage, 'Status message')}</th>
               <th>${(typeLabel?has_content)?then(typeLabel, 'Type')}</th>
               <th>${(nameLable?has_content)?then(nameLable, 'Name')}</th>
               <th>${(regionLabel?has_content)?then(regionLabel, 'Region')}</th>
               <th>${(planType?has_content)?then(planType, 'Plan Type')}</th>
               <th>${(idLabel?has_content)?then(idLabel, 'id')}</th>
               <th>${(promotionLabel?has_content)?then(promotionLabel, 'Promotion')}</th>
               <th></th>
            </tr>
         </thead>
         <tbody>
            <#assign entryCount=0>
            <#assign areaTitle="">
            <#list entries as curEntry>
            <#assign renderer=curEntry.getAssetRenderer()>
            <#assign className=renderer.getClassName()>
            <#if className=="com.liferay.journal.model.JournalArticle">
            <#assign journalArticle=renderer.getArticle()>
            <#assign document = saxReaderUtil.read(journalArticle.getContentByLocale(locale)) />
            <#assign document = saxReaderUtil.read(journalArticle.getContentByLocale(locale)) />
            <#assign entryTitle=document.valueOf("//dynamic-element[@name='LocationTitle'
            ]/dynamic-content") /> 
            <#assign entryRegion=document.valueOf("//dynamic-element[@name='TownCity'
            ]/dynamic-content") />
            <#assign countryField=document.valueOf("//dynamic-element[@name='Country'
            ]/dynamic-content") />
            <#assign countryCodes= []> 
            <#assign countryParts = countryField?split("-")>
            <#if countryParts?size gt 1>
            <#assign countryCode = countryParts[0]?trim>
            <#assign countryCodes = countryCodes + [countryCode]>
            </#if>
            <#assign entryId=journalArticle.articleId />
            <#assign assetEntryLocalService =  serviceLocator.findService("com.liferay.asset.kernel.service.AssetEntryLocalService")>
            <#assign assetEntry=assetEntryLocalService.getEntry("com.liferay.journal.model.JournalArticle",journalArticle.getResourcePrimKey())  />
            <#assign articleCategories=assetEntry.getCategories() />
            <#assign isClosed=document.valueOf("//dynamic-element[@name='isClosed'
            ]/dynamic-content") />
            <#assign userRoles=user.getRoles()>
            <#assign entryCountry=countrySet?seq_contains(countryCode)>
            <script>
               if ("${countryParts[0]?default("null")}" != null && "${countryParts[0]?default("null")}" != "") {
                 if (!uniqueValues.includes("${countryParts[0]?default("null")}")) {
                   uniqueValues.push("${countryParts[0]?default("null")}");
                 }
               }
            </script>
            <#if roleNames?seq_contains("European Admin") && (roleNames?size > 1)>
            <tr>
               <td><input type="checkbox" class="sub_chk" data-id=entryCount></td>
               <td>
                  <div class="<#if isClosed == 'true'>red<#else>green</#if>">
                     <#if isClosed=="true">
                     Closed
                     <#else>
                     Open
                     </#if>
                  </div>
               </td>
               <td></td>
               <td>
                  <cwc-icon name="product-line-bulk-cement" color="true-black"></cwc-icon>
               </td>
               <td>
                  <#assign viewURL = assetPublisherHelper.getAssetViewURL(renderRequest, renderResponse, renderer, entry, stringUtil.equals(assetLinkBehavior, "showFullContent")) />
                  <a href="${viewURL}" class="location">
                  ${entryTitle}
                  </a>
               </td>
               <td>${countryParts[0]?default("null")}</td>
               <td> 
                  <#list articleCategories as articleCategories>
                  ${articleCategories.getName()}      
                  </#list> 
               </td>
               <td class="location-id">${entryId}</td>
               <td>
                  <cwc-icon name="arrow-increase" color="bright-green"></cwc-icon>
               </td>
               <td>
                  <ul class="custom-dropdown">
                     <li>
                        <i class="fa fa-ellipsis-v" aria-hidden="true"></i>
                        <ul>
                           <li><a href="${viewURL}">${(viewDetails?has_content)?then(viewDetails, 'View Details')}</a></li>
                           <li><a class="edit-record" href="/add-location?articleId=${entryId}">${(editLabel?has_content)?then(editLabel, 'Edit')}</a></li>
                           <#if isClosed=="true">
                           <li><a class="open-location" href="#" data-entry-value=${entryId} >${(openLocation?has_content)?then(openLocation, 'Open Location')}</a></li>
                           <#else>
                           <li><a class="close-location" href="#" data-entry-value=${entryId}>${(closeLocation?has_content)?then(closeLocation, 'Close Location')}</a></li>
                           </#if>
                           <li><a>${(viewListings?has_content)?then(viewListings, 'View Listings')}</a></li>
                        </ul>
                     </li>
                  </ul>
               </td>
            </tr>
            <#elseif roleNames?seq_contains("European Admin") && (roleNames?size == 1)>
            <tr>
               <td><input type="checkbox" class="sub_chk" data-id=entryCount></td>
               <td>
                  <div class="<#if isClosed == 'true'>red<#else>green</#if>">
                     <#if isClosed=="true">
                     Closed
                     <#else>
                     Open
                     </#if>
                  </div>
               </td>
               <td></td>
               <td>
                  <cwc-icon name="product-line-bulk-cement" color="true-black"></cwc-icon>
               </td>
               <td>
                  <#assign viewURL = assetPublisherHelper.getAssetViewURL(renderRequest, renderResponse, renderer, entry, stringUtil.equals(assetLinkBehavior, "showFullContent")) />
                  <a href="${viewURL}" class="location">
                  ${entryTitle}
                  </a>
               </td>
               <td>${countryParts[0]?default("null")}</td>
               <td class="location-id">${entryId}</td>
               <td>
                  <cwc-icon name="arrow-increase" color="bright-green"></cwc-icon>
               </td>
               <td>
                  <ul class="custom-dropdown">
                     <li>
                        <i class="fa fa-ellipsis-v" aria-hidden="true"></i>
                        <ul>
                           <li><a href="${viewURL}">${(viewDetails?has_content)?then(viewDetails, 'View Details')}</a></li>
                           <li><a class="edit-record" href="/add-location?articleId=${entryId}">${(editLabel?has_content)?then(editLabel, 'Edit')}</a></li>
                           <#if isClosed=="true">
                           <li><a class="open-location" href="#" data-entry-value=${entryId} >${(openLocation?has_content)?then(openLocation, 'Open Location')}</a></li>
                           <#else>
                           <li><a class="close-location" href="#" data-entry-value=${entryId}>${(closeLocation?has_content)?then(closeLocation, 'Close Location')}</a></li>
                           </#if>
                           <li><a>${(viewListings?has_content)?then(viewListings, 'View Listings')}</a></li>
                        </ul>
                     </li>
                  </ul>
               </td>
            </tr>
            <#elseif locationRoles?seq_contains(roleName) && entryCountry>
            <tr>
               <td><input type="checkbox" class="sub_chk" data-id=entryCount></td>
               <td>
                  <div class="<#if isClosed == 'true'>red<#else>green</#if>">
                     <#if isClosed=="true">
                     Closed
                     <#else>
                     Open
                     </#if>
                  </div>
               </td>
               <td></td>
               <td>
                  <cwc-icon name="product-line-bulk-cement" color="true-black"></cwc-icon>
               </td>
               <td>
                  <#assign viewURL = assetPublisherHelper.getAssetViewURL(renderRequest, renderResponse, renderer, entry, stringUtil.equals(assetLinkBehavior, "showFullContent")) />
                  <a href="${viewURL}" class="location">
                  ${entryTitle}
                  </a>
               </td>
               <td>${countryParts[0]?default("null")}</td>
               <td class="location-id">${entryId}</td>
               <td>
                  <cwc-icon name="arrow-increase" color="bright-green"></cwc-icon>
               </td>
               <td>
                  <ul class="custom-dropdown">
                     <li>
                        <i class="fa fa-ellipsis-v" aria-hidden="true"></i>
                        <ul>
                           <li><a href="${viewURL}">${(viewDetails?has_content)?then(viewDetails, 'View Details')}</a></li>
                           <li><a class="edit-record" href="/add-location?articleId=${entryId}">${(editLabel?has_content)?then(editLabel, 'Edit')}</a></li>
                           <#if isClosed=="true">
                           <li><a class="open-location" href="#" data-entry-value=${entryId} >${(openLocation?has_content)?then(openLocation, 'Open Location')}</a></li>
                           <#else>
                           <li><a class="close-location" href="#" data-entry-value=${entryId}>${(closeLocation?has_content)?then(closeLocation, 'Close Location')}</a></li>
                           </#if>
                           <li><a>${(viewListings?has_content)?then(viewListings, 'View Listings')}</a></li>
                        </ul>
                     </li>
                  </ul>
               </td>
            </tr>
            </#if>
            </#if>
            </#list>
            </#if>
         </tbody>
      </table>
      <div class="add-location-main">
         <button class="btn btn-primary round-btn" id="add-location-redirect">
         <i class="fa fa-plus" aria-hidden="true">${(AddLocation?has_content)?then(AddLocation, 'Add Location')}</i>
         </button>
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
                           <div class="floating-input">
                              <input class="input-focus" type="text" id="filename" autocomplete="off" required/>
                              <label for="filename" class="focus-label">${(nameOfImportLabel?has_content)?then(nameOfImportLabel, 'Name of Import')}</label>
                           </div>
                        </div>
                     </div>
                     <div class="col-md-6">
                        <div class="form-group">
                           <div class="form-item">
                              <span class="control-fileupload">
                              <label for="file">${(chooseFileLabel?has_content)?then(chooseFileLabel, 'Choose a file Demo:')}</label>
                              <input type="file" id="file" required>
                              </span>
                           </div>
                        </div>
                     </div>
                  </div>
               </div>
               <div class="modal-footer">
                  <button type="button" class="btn btn-default common-btn popup-close" data-dismiss="popup">
                  ${(CancelLabel?has_content)?then(CancelLabel, 'Cancel')}
                  </button>
                  <button id="save-csv-file" type="submit" class="btn btn-primary  common-btn blue-btn" value="Save File"
                     >
                  ${(SaveLabel?has_content)?then(SaveLabel, 'Save')}
                  </button>
               </div>
            </form>
         </div>
      </div>
   </div>
</main>
<!-- <script src="/documents/20152/60315374/view-locations.js" defer>-->
<script src="/documents/20152/60315374/sh_toaster.js" defer></script>
<script>
const intervalId = setInterval(() => {
   const label = $("#locationtable_filter label");

   if (label.length && label.html().includes("Search:")) {
       label.html(label.html().replace("Search:", searchLabel+":"));
       clearInterval(intervalId);
   }
}, 100);

$('.input-focus').focus(function () {
   $(this).parent().addClass('focused');
});

var countryFolderId = null;
var documentMediaFolderId = null;
var coutryLanguageId = null;
var layoutUUID = null;
var importDocumentMediaFolderId = null;
var locationCSVName = "Location Application Data.csv";
var countryCompanyId = themeDisplay.getCompanyId();
var articleStructureId = '60265765';
var articleTemplateId = '60265771';
var guestRoleId = 20123;
var countryGroupId = themeDisplay.getScopeGroupId();
var productTypeVocId = 0;
var productParentCatId = 0;

var countries = [{
      code: "HR",
      name: "Croatia"
   },
   {
      code: "CZ",
      name: "Czech Republic"
   },
   {
      code: "FR",
      name: "France"
   },
   {
      code: "DE",
      name: "Germany"
   },
   {
      code: "PL",
      name: "Poland"
   },
   {
      code: "ES",
      name: "Spain"
   },
   {
      code: "GB",
      name: "United Kingdom"
   },
   {
      code: "BA",
      name: "Bosnia and Herzegovina"
   },
   {
      code: "ME",
      name: "Montenegro"
   },
   {
      code: "RS",
      name: "Serbia"
   }
];

var listingToastSetting = {
   duration: 6000
};


   // List of eu countries with data
   var listOfEUCountries = [
       { name: 'Germany', languageId: 'de_DE', wcmFolderId: 60265754, documentMediaFolderId: '60265900',layoutUUID: "a19c4060-07be-dcb9-5b60-03f5c795e4cc",code: "DE", productTypeVocId: 46179333, productParentCatId: 46185553, importDocumentMediaFolderId: 60667543
       },
       { name: 'United Kingdom', languageId: 'en_GB', wcmFolderId: 60329824, documentMediaFolderId: '60329921',layoutUUID: "a5a2ee85-4e1f-c9aa-e6ce-322fa005657b",code: "GB", productTypeVocId: 45846092, productParentCatId: 45846093, importDocumentMediaFolderId: 60655762
       },
       { name: 'Spain', languageId: 'es_ES', wcmFolderId: 60314868, documentMediaFolderId: '60315089',layoutUUID: "d9fb9a9f-999c-6401-ea51-ed8f2a8aa985",code: "ES", productTypeVocId: 46377683, productParentCatId: 49263378, importDocumentMediaFolderId: 60667810
       },
       { name: 'Czech Republic', languageId: 'cs_CZ', wcmFolderId: 60326347, documentMediaFolderId: '60326349',layoutUUID: "f8dc0ec0-0bac-3acc-4461-2ac9361a59f0",code: "CZ", productTypeVocId: 46986869, productParentCatId: 46986870, importDocumentMediaFolderId: 60667652
       },
       { name: 'Poland', languageId: 'pl_PL', wcmFolderId: 60330119, documentMediaFolderId: '60330121',layoutUUID: "d9113e4a-0025-2bfa-d448-c2ff1fa51ae6",code: "PL", productTypeVocId: 46497697, productParentCatId: 46497698, importDocumentMediaFolderId: 60667859
       },
       { name: 'France', languageId: 'fr_FR', wcmFolderId: 60353105, documentMediaFolderId: '60353107',layoutUUID: "1dfadceb-64b8-cc19-e32e-c714ba361ad8",code: "FR", productTypeVocId: 51533339, productParentCatId: 51533340, importDocumentMediaFolderId: 60667852
       },
       { name: 'Croatia', languageId: 'hr_HR', wcmFolderId: 60354285, documentMediaFolderId: '60354287',layoutUUID: "b19d49ae-6bae-1163-5e9b-308af376dc71",code: "HR", productTypeVocId: 47389540, productParentCatId: 49302889, importDocumentMediaFolderId: 60667716
       }
   ];

var currentCountry = listOfEUCountries.find(country => country.languageId === themeDisplay.getLanguageId());

var currentOrigin = window.location.origin;
var pathSegments = window.location.pathname.split('/').filter(Boolean);

if (location.pathname.includes("/web/")) {
    var webIndex = pathSegments.indexOf("web");
    currentOrigin += '/' + pathSegments.slice(0, webIndex + 2).join('/');
}

if (currentCountry) {
   importDocumentMediaFolderId = currentCountry.importDocumentMediaFolderId;
   countryFolderId = currentCountry.wcmFolderId;
   documentMediaFolderId = currentCountry.documentMediaFolderId;
   coutryLanguageId = currentCountry.languageId;
   layoutUUID = currentCountry.layoutUUID;
   productTypeVocId = currentCountry.productTypeVocId;
   productParentCatId = currentCountry.productParentCatId;
} else {
   console.error("Error while fetching current coutry from array");
}

jQuery(document).ready(function () {

   var table = jQuery('#locationtable').DataTable({
      "pageLength": 100,
      "lengthMenu": [100, 200, 300],
   });

   table.columns().iterator('column', function (ctx, idx) {
      jQuery(table.column(idx).header()).append('<span class="sort-icon"/>');
   });

   jQuery('#master').on('click', function () {
      var isChecked = $(this).is(':checked');
      $(".sub_chk").prop('checked', isChecked);
      $("#selected-check-count").text($(".sub_chk:checked").length);
   });

   jQuery(".dropdown-menu li").on("click", function () {
      var getValue = jQuery(this).text();
      jQuery(".dropdown-select").text(getValue);
   });

   AUI.$(document).ready(function () {
      AUI.$('#clickMe').on('click', function () {
         AUI.$(this).parent().addClass('highlight');
      });
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

   // Close modal window with 'data-dismiss' attribute or when the backdrop is clicked
   if ((target.hasAttribute('data-dismiss') && target.getAttribute('data-dismiss') == 'popup') || target.classList.contains('popup')) {
      const popupDiv = document.getElementsByClassName('popup');
      if (popupDiv && popupDiv?.length > 0) {
         for (let item of popupDiv) {
            if (item?.classList?.contains('open')) {
               item?.classList?.remove('open');
            }
         }
      }
      e.preventDefault();
   }
}, false);


$(".popup-close").on("click", function () {
   $('.modal-backdrop').remove();
   $('.bs-file-modal').modal('hide');
});


var regionFieldIndex = 5;

$(document).ready(function () {
   $("#overlay").fadeIn(100);

   setTimeout(function () {
      $("#overlay").fadeOut(100);
   }, 500);
});
$(document).ready(function () {

   uniqueValues.forEach(function (element) {
      element = element.trim();
      $('#region-data').append('<li data-filter="' + element + '">' + element + '</li>');
   });
   $("#region-data li").on("click", function () {
      var table = $('#locationtable').DataTable();
      var selectedRegion = $(this).data('filter');
      table.search('').columns().search('').draw();
      if (selectedRegion !== 'All') {
         table.column(regionFieldIndex).search("\\b" + selectedRegion + "\\b", true, false).draw();
      }
   });
   $("#add-location-redirect").on("click", function () {
      window.location.href = currentOrigin + "/add-location";
   });
});

$(".test-demo").on("click", function () {
   $(this).parent().addClass('Active');
});

$('.sub_chk, .main-checkbox').on('click', function () {
   $("#selected-check-count").text($(".sub_chk:checked").length);
});
$(".open-locations").click(function (event) {
   getSelectedCheckBoxAndUpdate(false)
});

$("#open-locations").click(function (event) {
   getSelectedCheckBoxAndUpdate(false)
});

$("#region-dropdown").click(() => $("#region-dropdown").addClass("open"));

$("#close-locations").click(function (event) {
   getSelectedCheckBoxAndUpdate(true)
});

function getSelectedCheckBoxAndUpdate(isClose) {
   $("#overlay").fadeIn(100);
   var promises = [];

   $(".sub_chk").each(function () {
      if ($(this).is(':checked')) {
         var value = $(this).closest('tr').find('.location-id').text();
         promises.push(openOrCloseLocation(value, isClose));
         console.log("Inside Valude" + value);
      }
   });

   Promise.all(promises).then(function () {
      window.location.reload();
   }).catch(function (error) {
      alert("Error updating locations: " + error);
   });

   $("#overlay").fadeOut(100);
}

function openOrCloseLocationByOption(locationId, isClosed) {
   openOrCloseLocation(locationId, isClosed)
      .then(function () {
         window.location.reload()
      })
      .catch(function (error) {
         console.error("Error updating location:", error);
      });
}

function openOrCloseLocation(locationId, isClosed) {
   console.log(locationId, isClosed)
   return new Promise(function (resolve, reject) {
      Liferay.Service('/journal.journalarticle/get-article', {
         groupId: countryGroupId,
         articleId: locationId
      }, function (webContent) {
         try {
            var updatedXMLString = isClosedXMlOperations(webContent.content, isClosed);
            webContent.content = updatedXMLString;

            updateLocationIsClosedField(webContent, function () {
               resolve();
            });
         } catch (error) {
            reject(error);
         }
      });
   });
}

function isClosedXMlOperations(webContentData, valueForUpdateOfClosed) {
   var parser = new DOMParser();
   var xmlDoc = parser.parseFromString(webContentData, 'application/xml');

   var isClosedElement = xmlDoc.querySelector('dynamic-element[name="isClosed"]');

   if (isClosedElement) {
      var dynamicContent = isClosedElement.querySelector('dynamic-content');
      dynamicContent.textContent = '';
      dynamicContent.appendChild(xmlDoc.createCDATASection(valueForUpdateOfClosed));
   } else {
      const dynamicElement = xmlDoc.createElement('dynamic-element');

      dynamicElement.setAttribute('name', "isClosed");
      dynamicElement.setAttribute('type', "boolean");
      dynamicElement.setAttribute('index-type', 'keyword');
      dynamicElement.setAttribute('instance-id', "dferds");

      const dynamicContent = xmlDoc.createElement('dynamic-content');
      dynamicContent.setAttribute('language-id', "" + themeDisplay.getLanguageId() + "");

      const cdata = xmlDoc.createCDATASection(valueForUpdateOfClosed);
      dynamicContent.appendChild(cdata);

      dynamicElement.appendChild(dynamicContent);

      xmlDoc.documentElement.appendChild(dynamicElement);
   }

   var serializer = new XMLSerializer();
   var updatedXmlString = serializer.serializeToString(xmlDoc);

   return updatedXmlString;
}

function updateLocationIsClosedField(finalWCM, callback) {
   console.log(finalWCM)
   Liferay.Service('/journal.journalarticle/update-article', finalWCM,
      function (obj) {
         if (callback) {
            callback();
         }
      }
   );
}

$('#csv-button').on('click', function (event) {
   event.stopPropagation();
   var $dropdown = $('#download-options');
   if ($dropdown.is(':visible')) {
      $dropdown.hide();
   } else {
      $dropdown.show();
   }
});

$(document).on('click', function (event) {
   if (!$(event.target).closest('#download-dropdown').length) {
      $('#download-options').hide();
   }
});

$('#download-selected').on('click', function () {
   getSelectedCheckBoxAndCSV();
   $('#download-options').hide();
});

$('#download-all').on('click', async function () {
   try {
      Toast.info(exportWait);
      $("#overlay").fadeIn(100);

      const articles = await fetchArticles();

      if (!articles || articles.length === 0) {
         Toast.danger(noLocations);
         return;
      }

      const promises = articles.map(async (article) => {
         return getWebcontentDataAsMap(article, null);
      });

      const locationData = await Promise.all(promises);

      let convertedLocationData = convertObjectTOCSVData(locationData);
      if (convertedLocationData) {
         downloadCSV(convertedLocationData, locationCSVName);
      }
      $("#overlay").fadeOut(100);
   } catch (error) {
      Toast.danger(exportError);
      console.error('Error fetching articles:', error);
      $("#overlay").fadeOut(100);
   }

   $('#csv-options').hide();

});
async function fetchArticles() {
   return new Promise((resolve, reject) => {
      Liferay.Service(
         '/journal.journalarticle/get-articles-by-structure-id', {
            groupId: countryGroupId,
            ddmStructureKey: articleStructureId,
            start: -1,
            end: -1,
            '-obc': ''
         },
         function (obj) {
            resolve(obj);
         },
         function (error) {
            reject(error);
         }
      );
   });
}

function getSelectedCheckBoxAndCSV() {

   if ($('.sub_chk:checked').length === 0) {
      Toast.danger(atleastOne);
      return;
   }

   $("#overlay").fadeIn(100);

   Toast.info(exportWait);
   var locationData = [];

   const promises = $(".sub_chk")
      .toArray()
      .filter((checkbox) => checkbox.checked)
      .map(async (checkbox) => {
         const value = $(checkbox).closest('tr').find('.location-id').text();
         return getWebcontentDataAsMap(null, value);
      });

   Promise.all(promises)
      .then((data) => {
         locationData = data;

         let convertedLocationData = convertObjectTOCSVData(locationData);
         if (convertedLocationData) {
            downloadCSV(convertedLocationData, locationCSVName)
         }
      })
      .catch((error) => {
         console.error(error);
         Toast.error(exportError);
         $("#overlay").fadeOut(100);
      });
}

var locationStructureFields = ["LocationId", "", "Address", "Address2", "TownCity", "Country", "Postcode", "PhoneNumber", "Monday_Separator", "Tuesday_Separator", "Wednesday_Separator", "Thursday_Separator", "Friday_Separator", "Saturday_Separator", "Sunday_Separator", "ProductCard", "ContactDetail", "Longitude", "Latitude", "isYextRestrict", "RichText", "PlantType", "CompanyName",
   "LocationImage", "FileCard", "AddPage", "PublisherImages", 'State', 'Region'
];

async function getWebcontentDataAsMap(providedWebContent, locationId) {
   try {
      var webContent = providedWebContent;
      if (!webContent) {
         webContent = await new Promise((resolve, reject) => {
            Liferay.Service('/journal.journalarticle/get-article', {
               groupId: countryGroupId,
               articleId: locationId
            }, function (webContent) {
               resolve(webContent);
            });
         });
      }

      var categories = await getWebcontentCategories(webContent.resourcePrimKey);
      var elementMap = new Map();

      if (categories && categories.length > 0) {
         elementMap.set("PlantType", [categories[0].titleCurrentValue + "(" + categories[0].categoryId + ")"]);
      }

      elementMap.set("LocationId", webContent.articleId);

      var xmlDoc = new DOMParser().parseFromString(webContent.content, 'application/xml');
      var dynamicElements = xmlDoc.getElementsByTagName('dynamic-element');

      for (var i = 0; i < dynamicElements.length; i++) {
         var dynamicElement = dynamicElements[i];
         var name = dynamicElement.getAttribute('name');

         if (!locationStructureFields.includes(name) && "GeolocationData" !== name) {
            continue;
         }

         var dynamicContent = dynamicElement.querySelector('dynamic-content');
         var value =  dynamicContent?.textContent ?? "";
         value = value.replaceAll("\n", "<br>")

         if (!elementMap.has(name))
            elementMap.set(name, []);

         if (!value) {
            elementMap.get(name).push('-');
            continue;
         }

         var nestedElements = dynamicElement.getElementsByTagName('dynamic-element');

         if (nestedElements.length > 0) {
            var cardNestedElements = dynamicElement.getElementsByTagName('dynamic-element');
            var nestedObjectGen = {};

            if (name.includes("_Separator")) {
               var closeEle = dynamicElement.querySelector('dynamic-element[name="isClosed' + name.replace("_Separator") + '"]');
               if (closeEle && closeEle.querySelector('dynamic-content').textContent == 'true') {
                  dayObject['isClosed'] = true;
                  elementMap.get(name).push(dayObject);
               } else {
                  for (let i = 0; i < dynamicElement.children.length; i++) {
                     let nestedElement = dynamicElement.children[i];
                     let nestedName = nestedElement.getAttribute('name');
                     let dayObject = {};

                     if (!nestedName.includes("isClosed")) {
                        for (let j = 0; j < nestedElement.children.length; j++) {
                           let typeOfDayElement = nestedElement.children[j];
                           let typeOfDayElementName = typeOfDayElement.getAttribute('name');
                           let dayElementValue = typeOfDayElement.querySelector('dynamic-content').textContent;

                           if (typeOfDayElementName.includes("Open")) {
                              if (dayElementValue) dayObject['openTime'] = dayElementValue;
                           } else {
                              if (dayElementValue) dayObject['closeTime'] = dayElementValue;
                           }
                        }
                        elementMap.get(name).push(dayObject);
                     }
                  }

               }


            } else {
               elementMap.get(name).push(dynamicElementToObjectList(cardNestedElements));
            }

         } else {

            if ("GeolocationData" === name) {
               var geoVal = JSON.parse(value);
               elementMap.set("Latitude", [geoVal.latitude]);
               elementMap.set("Longitude", [geoVal.longitude]);
            } else if ("LocationImage" === name) {
               if (value) {
                  var fileEntryId = dynamicContent.getAttribute('fileEntryId');
                  elementMap.get(name).push(value + "?fileEntryId=" + fileEntryId);
               }
            } else {
               elementMap.get(name).push(value);
            }

         }

      }
      return elementMap;
   } catch (error) {
      throw error;
   }
}

function dynamicElementToObjectList(cardNestedElements) {
   var nestedElementsObj = {};

   for (var j = 0; j < cardNestedElements.length; j++) {
      var nestedElement = cardNestedElements[j];
      var nestedName = nestedElement.getAttribute('name');
      var nestedContent = nestedElement.querySelector('dynamic-content');
      var nestedValue = nestedContent.textContent;

      nestedElementsObj[nestedName] = nestedValue;
   }
   return nestedElementsObj;
}

function convertObjectTOCSVData(locationData) {
   if (locationData.length === 0) {
      return null;
   }
   var csvContent = locationStructureFields.join(",") + '\n';

   locationData.forEach(location => {
      var csvRow = '';

      locationStructureFields.forEach(field => {
         var locationFieldValue = location.get(field);

         if (Array.isArray(locationFieldValue) && locationFieldValue.length !== 0) {
            if (field === "ContactDetail" || field === "FileCard" || field === "ProductCard" || field === "AddPage" || field === "PublisherImages" || field.includes("_Separator")) {
               if (locationFieldValue.length == 1 && locationFieldValue[0] == '-') {
                  if (field.includes("_Separator")) csvRow += '"' + 'Closed' + '",';
                  else csvRow += '"' + '-' + '",';
               } else {
                  var contactDetailData = locationFieldValue.map((contact, index) => {
                     return Object.entries(contact)
                        .map(([key, value]) => (key + "_" + (index + 1)) + " : " + ((value !== undefined) ? value : "-"))
                        .join(", ");
                  });
                  csvRow += '"' + contactDetailData.join("\n") + '",';
               }


            } else {
               if (locationFieldValue.length === 1 && field === "isYextRestrict") {
                  csvRow += '"' + (locationFieldValue[0] ? locationFieldValue[0] : "false") + '",';
               } else {
                  csvRow += '"' + locationFieldValue.join(",") + '",';
               }

            }
         } else {
            csvRow += '"' + (((locationFieldValue !== undefined) && (locationFieldValue !== null) && (locationFieldValue !== "")) ? locationFieldValue : "-") + '",';
         }
      });

      csvContent += csvRow.slice(0, -1) + '\n';
   });

   return csvContent;
}

function downloadCSV(csvData, fileName) {
   const csvFile = new Blob([csvData], {
      type: 'text/csv'
   });
   const downloadLink = document.createElement('a');
   downloadLink.href = window.URL.createObjectURL(csvFile);
   downloadLink.download = fileName;

   document.body.appendChild(downloadLink);
   downloadLink.click();
   document.body.removeChild(downloadLink);
   Toast.success(selectedDownloaded);
   $("#overlay").fadeOut(100);
}


$(document).ready(function () {
   $('ul li .edit-record').on('click', function (event) {
      event.preventDefault();
      window.location.href = currentOrigin + $(this).attr('href');
   });
   $('.open-location, .close-location').on('click', function (event) {
      event.preventDefault();

      if ($(this).attr('class') === "open-location") {
         openOrCloseLocationByOption($(this).data("entry-value"), false)
      } else {
         openOrCloseLocationByOption($(this).data("entry-value"), true)
      }
   });
});

async function getWebcontentCategories(resourcePK) {
   return new Promise((resolve, reject) => {
      Liferay.Service(
         '/assetcategory/get-categories', {
            className: 'com.liferay.journal.model.JournalArticle',
            classPK: parseInt(resourcePK)
         },
         function (obj) {
            resolve(obj);
         }
      );
   });
}

$(function () {
   $('.control-fileupload input[type=file]').change(function () {
      var t = $(this).val();
      var labelText = 'File : ' + t.substr(12, t.length);
      $(this).prev('label').text(labelText);
   })
});

function addFolderWithCurrentUser(repositoryId, parentFolderId, description, customString, callback) {
   Liferay.Service(
      '/user/get-user-by-id', {
         userId: themeDisplay.getUserId()
      },
      function (user) {
         var userName = user.firstName + ' ' + user.lastName;
         var folderName = customString + '_' + userName;

         Liferay.Service(
            '/dlapp/add-folder', {
               repositoryId: repositoryId,
               parentFolderId: parentFolderId,
               name: folderName,
               description: description
            },
            function (obj) {
               callback(obj);
            }
         );
      }
   );
}

function uploadFileToFolder(folderId, file, callback) {

   var formData = new FormData();
   formData.append('repositoryId', themeDisplay.getScopeGroupId());
   formData.append('folderId', folderId);
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
            var uploadedFile = JSON.parse(xhr.responseText);
            callback(null, uploadedFile);
         } else if (xhr.status === 500) {

            callback('This file already exists', null);
         } else {
            callback('Error uploading file', null);
         }
      }
   };
   xhr.send(formData);
}

$("#save-csv-file").on("click", async function (e) {

   var operationType = $("#save-csv-file").text();
   var folderName = $("#filename").val() || "-";
   var fileValue = $("#filevalue").val() || "-";
   var label = document.querySelector('label[for="file"]');
   var fileNameData = label.textContent.split(' : ')[1].trim();

   addFolderWithCurrentUser(themeDisplay.getScopeGroupId(), importDocumentMediaFolderId, '', folderName, async function (obj) {
      var fileInput = document.getElementById('file');
      var file = fileInput.files[0];

      if (file) {
         uploadFileToFolder(obj.folderId, file, async function (error, uploadedFile) {
            if (!error) {
               $("#bs-file-modal").removeClass("open");

               const reader = new FileReader();
               reader.onload = async function (event) {
                  const content = event.target.result;
                  convertCSVDatatoJson(content)
                     .then(jsonDataFromCSV => {
                        if (jsonDataFromCSV && jsonDataFromCSV.length > 0) {
                           return Promise.all(jsonDataFromCSV.map(jsonLocation => {
                              var xmlLocationData = createXMLFromJson(jsonLocation);
                              return addOrUpdateArticleAsync(jsonLocation, xmlLocationData)
                                 .catch(error => {
                                    console.error('An error occurred:', error);
                                    //Toast.danger('Requested location is not created.');
                                 });
                           }));
                        } else {
                           Toast.danger(noLocations, listingToastSetting);
                           return Promise.resolve();
                        }
                     })
                     .then(() => {
                        var fileName = 'location-import-status.csv'
                        const csvFile = createCSVFile(resultData, fileName);
                        return new Promise((resolve, reject) => {
                           uploadFileToFolder(obj.folderId, csvFile, function (error, uploadedFile) {
                              if (!error) {
                                 Toast.success(fileDataUploadSuccess, listingToastSetting);
                                 clearImportCSVModel();
                                 resolve();
                              } else {
                                 reject(error);
                              }
                           });
                        });
                     })
                     .catch(error => {
                        console.error('Error in processing:', error);
                        Toast.danger('Error processing data', listingToastSetting);
                     });
               };

               reader.readAsText(file);
            }
         });
      } else {
         Toast.danger(fileRequireValidation, listingToastSetting);
      }
   });
});

function convertToCSV(data) {
   const header = Object.keys(data[0]).join(',');
   const rows = data.map(obj => Object.values(obj).join(','));
   return header + '\n' + rows.join('\n');
}


function createCSVFile(data, fileName) {
   const csvContent = convertToCSV(data);
   const csvFile = new Blob([csvContent], {
      type: 'text/csv'
   });
   return new File([csvFile], fileName);
}

var productTypeCategories = null;

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

async function getAllProductCategories() {
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

        return response;
    } catch (error) {
        console.error("Error updating product dropdown options:", error);
        throw error;
    }
}

getAllProductCategories();


function convertCSVDatatoJson(csvContent) {
   return new Promise(async (resolve, reject) => {
      try {
         const jsonData = [];
         csvContent = csvContent.replace(/\n(?=ContactName_)/g, '<br>');
         csvContent = csvContent.replace(/\n(?=PriceName_)/g, '<br>');
         csvContent = csvContent.replace(/\n(?=Publisher_)/g, '<br>');
         csvContent = csvContent.replace(/\n(?=PageName_)/g, '<br>');
         csvContent = csvContent.replace(/\n(?=openTime_)/g, '<br>');
         csvContent = csvContent.replace(/\n(?=Name_)/g, '<br>');
         const lines = csvContent.split('\n');
         const headerLine = lines[0].trim().split(',');
         const dataLines = lines.slice(1);

         for (const line of dataLines) {
            if (line.trim() === "") {
               continue;
            }

            const columns = parseCSVLine(line);
            const rowData = {};

            for (let i = 0; i < headerLine.length; i++) {
               const header = headerLine[i];
               if (!columns[i] || columns[i] === "-") continue;
               if (header === "ContactDetail" || header === "ProductCard" || header === "FileCard" || header === "PublisherImages" || header === "AddPage" || header.includes("_Separator")) {
                  const listData = [];
                  const allElement = columns[i].split("<br>");
                  
                  for (const elem of allElement) {
                     const fieldsAndValues = elem.split(",");
                     const contactObject = {};
                     
                     for (const fieldAndValue of fieldsAndValues) {
                        const fieldName = fieldAndValue.slice(0, fieldAndValue.indexOf("_")).trim();
                        const fieldValue = fieldAndValue.slice(fieldAndValue.indexOf(":") + 1).trim();

                        if (header === "ProductCard" && fieldName === "Name") {
                           const categoryId = await getCategoryIdByName(fieldValue);
                           contactObject["categoryId"] = categoryId;
                        }

                        contactObject[fieldName] = fieldValue;
                     }
                     
                     listData.push(contactObject);
                  }
                  
                  rowData[header] = listData;
               } else if (header === "RichText") {
                  rowData[header] = columns[i].replace(/style=([^>]+)(?=\s|>)/g, 'style="$1"');
               } else {
                  rowData[header] = columns[i];
               }
            }

            jsonData.push(rowData);
         }

         resolve(jsonData);
      } catch (error) {
         reject(error);
      }
   });
}

function parseCSVLine(line) {
   const columns = [];
   let currentColumn = '';
   let insideQuotes = false;

   for (let char of line) {
      if (char === '"') {
         insideQuotes = !insideQuotes;
      } else if (char === ',' && !insideQuotes) {
         columns.push(currentColumn.trim());
         currentColumn = '';
      } else {
         currentColumn += char;
      }
   }

   columns.push(currentColumn.trim());

   return columns;
}

var xmlBuilder = null;

function createXMLFromJson(locationArticle) {

   xmlBuilder = document.implementation.createDocument(null, null);
   var idSubstrings = ["LocationTitle", "Address", "Address2", "CompanyName", "TownCity", "Country", "Postcode", "PhoneNumber", "Monday_Separator",
      "Tuesday_Separator", "Wednesday_Separator", "Thursday_Separator", "Friday_Separator", "Saturday_Separator", "Sunday_Separator", "GeolocationData", "ProductCard", "ContactDetail", "LocationImage", "isYextRestrict", "RichText", "CompanyName", "FileCard", "AddPage", "PublisherImages", "State", "Region"
   ];

   const declaration = xmlBuilder.createProcessingInstruction('xml', 'version="1.0"');
   xmlBuilder.appendChild(declaration);

   const rootElement = xmlBuilder.createElement('root');
   rootElement.setAttribute('available-locales', "" + coutryLanguageId + "");
   rootElement.setAttribute('default-locale', "" + coutryLanguageId + "");
   xmlBuilder.appendChild(rootElement);

   createDynamicElement("isCSVLocation", "boolean", "true", "isCSVLocation" + generateRandomString(6), true);

   for (const idName of idSubstrings) {
      const instanceId = (String(idName).toLowerCase()) + "InstanceId";

      if (!locationArticle[idName] && idName !== "GeolocationData") continue;

      if (idName.includes("_Separator")) {
         var dayName = idName.replace("_Separator", "")

         const mainDynamicElement = createDynamicElementOnly(idName, "selection_break", idName + generateRandomString(6))
         locationArticle[idName].forEach(function (splitingHour, index) {
            var dayInstanceId = "Timing" + index + generateRandomString(6);
            const timeSepDynamicElement = createDynamicElementOnly("TimingSeparator" + dayName, "selection_break", dayInstanceId)
            var openTime = '';
            var closeTime = '';
            var isClosedTime = '';
            var isClose = splitingHour["Close"];
            if (splitingHour["openTime"] && splitingHour["closeTime"]) {
               openTime = splitingHour["openTime"];
               closeTime = splitingHour["closeTime"];
            }

            if (isClose) isClosedTime = isClose;

            timeSepDynamicElement.append(createDynamicElement(dayName + "Open", "text", openTime, "openTime" + dayInstanceId, false))
            timeSepDynamicElement.append(createDynamicElement(dayName + "Close", "text", closeTime, "closeTime" + dayInstanceId, false))

            mainDynamicElement.append(timeSepDynamicElement)
            mainDynamicElement.append(createDynamicElement("isClosed" + dayName, "boolean", isClosedTime, "isClosed" + dayInstanceId, false))
            xmlBuilder.documentElement.appendChild(mainDynamicElement);
         })
      } else if (idName === "GeolocationData") {
         if (locationArticle["Longitude"] && locationArticle["Latitude"])
            createDynamicElement(idName, "ddm-geolocation", "{\"latitude\":\"" + locationArticle["Latitude"] + "\",\"longitude\":\"" + locationArticle["Longitude"] + "\"}", instanceId + generateRandomString(6), true);
      } else if (idName.includes("ContactDetail") || idName.includes("FileCard") || idName.includes("PublisherImages") || idName.includes("ProductCard") || idName.includes("AddPage")) {
         locationArticle[idName].forEach(function (file, fileIndex) {

            const contactInsId = (idName + "-card");
            var type = "text";
            const dynamicElement = createDynamicElementOnly(idName, "selection_break", contactInsId + generateRandomString(6))

            Object.keys(file).forEach(function (aFile, aFileIndex) {
               if (aFile === 'categoryId') {
                  return; // Skip this iteration if aFile is categoryId
               }
               if (aFile === 'LocationPriceList' || aFile === 'File') {
                  dynamicElement.appendChild(createDynamicElement(aFile, "document_library", file[aFile], file[aFile].match(/\/([\da-fA-F-]+)(?:\?|$)/)[1], false));
               } else {
                  dynamicElement.appendChild(createDynamicElement(aFile, "text", file[aFile], (contactInsId + generateRandomString(6)), false));
               }
            })

            xmlBuilder.documentElement.appendChild(dynamicElement);
         })
      } else if (idName.includes("LocationImage")) {
         createDynamicElement(idName, "image", locationArticle[idName], instanceId, true);
      } else {
         createDynamicElement(idName, "text", locationArticle[idName], instanceId, true);
      }
   }

   const xmlContent = new XMLSerializer().serializeToString(xmlBuilder);
   return xmlContent;
}

function createDynamicElement(name, type, value, instanceId, appendInXML) {
   const dynamicElement = xmlBuilder.createElement('dynamic-element');

   dynamicElement.setAttribute('name', name);
   dynamicElement.setAttribute('type', type);
   dynamicElement.setAttribute('index-type', 'keyword');
   dynamicElement.setAttribute('instance-id', instanceId);

   const dynamicContent = xmlBuilder.createElement('dynamic-content');
   dynamicContent.setAttribute('language-id', "" + coutryLanguageId + "");
   var elementValue = value;
   if (type === 'image') {
      var fileName = '';

      if (value.startsWith("/documents")) {
         const fileEntryId = value.match(/fileEntryId=(\d+)/)?.[1] || null;
         fileName = value.split("/").pop().split("?")[0];

         dynamicContent.setAttribute('type', 'document');

         if (fileEntryId) {
            dynamicContent.setAttribute('fileEntryId', fileEntryId);
            elementValue = value.replace(/\?fileEntryId=\d+/, '');
         }
      } else if (value.startsWith("/image/journal")) {
         var urlQueries = new URLSearchParams(new URL(value, window.location.href).search);
         dynamicContent.setAttribute('type', 'journal');
         fileName = urlQueries.get('fileName');
         if (!fileName) {
            fileName = urlQueries.get('img_id');
         }
      }

      dynamicContent.setAttribute('alt', fileName);
      dynamicContent.setAttribute('name', fileName);
      dynamicContent.setAttribute('title', fileName);
   }

   const cdata = xmlBuilder.createCDATASection(elementValue);
   dynamicContent.appendChild(cdata);

   dynamicElement.appendChild(dynamicContent);

   if (appendInXML) {
      xmlBuilder.documentElement.appendChild(dynamicElement);
   }

   return dynamicElement;
}

function createDynamicElementOnly(name, type, instanceId) {
   const dynamicElement = xmlBuilder.createElement('dynamic-element');

   dynamicElement.setAttribute('name', name);
   dynamicElement.setAttribute('type', type);
   dynamicElement.setAttribute('index-type', 'keyword');
   dynamicElement.setAttribute('instance-id', instanceId);

   return dynamicElement;
}

var resultData = [];

// Helper function to clean individual plant type string
const cleanPlantType = (plantType) => {
    return plantType
        .replace(/\([^)]*\)/g, '')  // Remove anything in parentheses
        .trim();  // Remove any leading/trailing spaces
};

// Main function to process plant types
const processPlantTypes = (plantTypeString) => {
    return new Promise((resolve, reject) => {
        // If no plant type or it's just a dash, return empty array
        if (!plantTypeString || plantTypeString === '-') {
            resolve([]);
            return;
        }

        // Split by comma and process each plant type
        const plantTypes = plantTypeString.split(',');
        
        // Clean each type
        const cleanedTypes = plantTypes
            .map(type => cleanPlantType(type))
            .filter(type => type.length > 0);

        // Process all types in parallel
        Promise.all(
            cleanedTypes.map(type => 
                getCategoryIdByName(type)
                    .catch(error => {
                        
                        return null;
                    })
            )
        )
        .then(categoryIds => {
            // Filter out any null values from failed lookups
            resolve(categoryIds.filter(id => id !== null));
        })
        .catch(reject);
    });
};

async function addOrUpdateArticleAsync(jsonLocation, xmlData) {
    return new Promise((resolve, reject) => {
        const currentDate = new Date();
        var PlantTypeArray = [];
        var webContentCategories = [];

        if (Array.isArray(jsonLocation.ProductCard) && jsonLocation.ProductCard.length > 0) {
            jsonLocation.ProductCard.forEach(product => {
                if (product.categoryId) {
                    webContentCategories.push(product.categoryId);
                }
            });
        }

        // Process plant types first, then continue with the rest of the function
        const processPlantTypesAndContinue = () => {
            if (jsonLocation.PlantType && jsonLocation.PlantType !== '-') {
                processPlantTypes(jsonLocation.PlantType)
                    .then(plantTypes => {
                        PlantTypeArray = plantTypes;
                        webContentCategories = [...webContentCategories, ...PlantTypeArray];
                        continueWithLiferayService();
                    })
                    .catch(error => {
                        console.error('Error processing plant types:', error);
                        // Continue with empty PlantTypeArray in case of error
                        continueWithLiferayService();
                    });
            } else {
                continueWithLiferayService();
            }
        };

        const continueWithLiferayService = () => {
            if (jsonLocation.LocationId && jsonLocation.LocationId !== "-") {
                Liferay.Service(
                    '/journal.journalarticle/get-article',
                    {
                        groupId: countryGroupId,
                        articleId: jsonLocation.LocationId
                    },
                    function(webContent) {
                        Liferay.Service(
                            '/journal.journalarticle/update-article',
                            {
                                userId: webContent.getUserId,
                                groupId: webContent.groupId,
                                folderId: webContent.folderId,
                                articleId: webContent.articleId,
                                version: webContent.version,
                                titleMap: "{" + coutryLanguageId + ": \"" + jsonLocation.LocationTitle + "\" }",
                                descriptionMap: "{" + coutryLanguageId + ": \"" + "" + "\" }",
                                content: xmlData,
                                layoutUuid: webContent.layoutUuid,
                                serviceContext: {
                                    assetCategoryIds: webContentCategories
                                }
                            },
                            function(obj) {
                                Toast.success(jsonLocation.LocationTitle + " " + locationUpdateSuccess, listingToastSetting);
                                var successMessage = jsonLocation.LocationTitle + " " + locationUpdateSuccess;
                                updateResultData(obj, successMessage, jsonLocation, currentDate);
                                resolve(obj);
                            }
                        );
                    },
                    function(error) {
                        var failMessage = jsonLocation.LocationTitle + ' ' + missingCreate;
                        Toast.danger(failMessage, listingToastSetting);
                        updateResultData(error, failMessage, jsonLocation, currentDate);
                        reject(error);
                        jsonLocation.LocationId = '-';
                        addOrUpdateArticleAsync(jsonLocation, xmlData);
                    }
                );
            } else {
                Liferay.Service(
                    '/journal.journalarticle/add-article',
                    {
                        
                        groupId: countryGroupId,
                        folderId: countryFolderId,
                        classNameId: 0,
                        classPK: 0,
                        articleId: '',
                        autoArticleId: true,
                        titleMap: {
                           ["" + coutryLanguageId + ""]: jsonLocation.LocationTitle
                        },
                        descriptionMap: {
                           ["" + coutryLanguageId + ""]: ""
                        },
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
                        serviceContext: {
                            assetCategoryIds: PlantTypeArray
                        }
                    },
                    function(obj) {
                        if (obj) {
                            addResourcesToArticle(obj);
                            Toast.success(jsonLocation.LocationTitle + ' ' + locationCreatedMessage, listingToastSetting);
                            var sucMessage = jsonLocation.LocationTitle + ' ' + locationCreatedMessage;
                            updateResultData(obj, sucMessage, jsonLocation, currentDate);
                        } else {
                            Toast.danger(jsonLocation.LocationTitle + ' ' + locationFailMessage, listingToastSetting);
                            var failMessage = jsonLocation.LocationTitle + ' ' + locationFailMessage;
                            updateResultData(obj, failMessage, jsonLocation, currentDate);
                        }
                        resolve(obj);
                    },
                    function(error) {
                        Toast.danger(locationFailMessage, listingToastSetting);
                        reject(error);
                    }
                );
            }
        };

        // Start the process
        processPlantTypesAndContinue();
    });
}

function updateResultData(obj, message, jsonLocation, currentDate) {
   if (obj) {
      resultData.push({
         Id: obj.id || '',
         Name: jsonLocation.LocationTitle,
         StatusMessage: message,
         Date: currentDate
      });
   } else {
      resultData.push({
         Id: obj.id || '',
         Name: jsonLocation.LocationTitle,
         Status: message || locationFailMessage,
         Date: currentDate
      });
   }

}

// Usage example

function convertArrayOfObjectsToCSV(data) {
   const columnHeaders = Object.keys(data[0]);
   const csvRows = [
      columnHeaders.join(','),
      ...data.map(obj => columnHeaders.map(key => obj[key]).join(',')) // Data rows
   ];
   return csvRows.join('\n');
}

function newDownloadCSV(data, filename) {
   const csv = convertArrayOfObjectsToCSV(data);
   const csvBlob = new Blob([csv], {
      type: 'text/csv;charset=utf-8;'
   });
   const csvURL = URL.createObjectURL(csvBlob);
   const link = document.createElement('a');
   link.href = csvURL;
   link.setAttribute('download', filename);
   document.body.appendChild(link);
   link.click();
   document.body.removeChild(link);
}

function addResourcesToArticle(article) {
   Liferay.Service(
      '/resourcepermission/set-individual-resource-permissions', {
         groupId: countryGroupId,
         companyId: countryCompanyId,
         name: 'com.liferay.journal.model.JournalArticle',
         primKey: article.resourcePrimKey,
         roleId: guestRoleId,
         actionIds: ["VIEW"]
      },
      function (obj) {
         console.log("Permission added on the WCM");
      }
   );
}

function generateRandomString(length) {
   const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
   let randomString = '';
   for (let i = 0; i < length; i++) {
      const randomIndex = Math.floor(Math.random() * charset.length);
      randomString += charset[randomIndex];
   }
   return randomString;
}

function clearImportCSVModel() {
   $("#filename").val("");
   var label = document.querySelector('label[for="file"]');
   var fileInput = document.getElementById('file');
   fileInput.value = '';
   label.textContent = 'File : ';
}
</script>