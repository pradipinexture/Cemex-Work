<!-- CSS Links -->
<link rel="stylesheet" href="https://unpkg.com/vanilla-datatables@latest/dist/vanilla-dataTables.min.css" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.7.2/css/all.min.css" />
<link rel="stylesheet" href="/documents/d/global/add-edit-location" />
<link rel="stylesheet" href="/documents/d/global/toaster_css">

<script src="https://unpkg.com/vanilla-datatables@latest/dist/vanilla-dataTables.min.js"></script>
<script type="module" src="https://www.cemexgo.com/cdn/web-components/latest/cmx-web-components/cmx-web-components.esm.js"></script>
<script nomodule src="https://www.cemexgo.com/cdn/web-components/latest/cmx-web-components/cmx-web-components.js"></script>
<style>
    .form-item.move-form-label label
    {
        font-size: 11px;
        top: -5px;
    }
</style>
<script>var uniqueValues = []</script>
<main>
    <div id="overlay">
        <div class="cv-spinner"></div>  
    </div>
    <div class="container location-table dataTable-main newdatatable">
        <div class="row">
            <div class="col-md-12">
                <div class="action-main">
                    <div class="dropdown" id="region-dropdown">
                        <button class="btn btn-primary dropdown-toggle region-dropdown-toggle" type="button" data-toggle="dropdown" id="filter-dropdown">Region <span class="caret"></span></button>
                        <ul id="region-data" class="dropdown-menu" aria-labelledby="filter-dropdown"><li data-filter="All">All</li></ul>
                    </div>

                    <div class="action-btn">
                        <span id="selected-check-count">0</span><span> items selected</span>
                        <button type="button" id="import-csv-button open-modal-button" class="btn btn-primary round-btn add-file" data-target="bs-file-modal" data-toggle="popup">
                            <cwc-icon name="plus" color="bright-blue" class="hydrated" data-dir="ltr"></cwc-icon>
                            ${languageUtil.get(locale, "importCSV", "Import CSV")}
                        </button>
                        <span class="dropdown" id="download-dropdown">
                            <button type="button" id="csv-button" data-toggle="dropdown" class="btn btn-primary round-btn">
                                ${languageUtil.get(locale, "downloadCSV", "Download CSV")}
                                <cwc-icon name="arrow-down-rounded-fill" color="bright-blue"></cwc-icon>
                            </button>
                            <ul id="download-options" class="dropdown-menu">
                                <li id="download-selected">${languageUtil.get(locale, "downloadSelectedLocs", "Download Selected Locations")}</li>
                                <li id="download-all">${languageUtil.get(locale, "downloadAllLocs", "Download All Locations")}</li>
                            </ul>
                        </span>
                        <button type="button" id="open-locations" class="btn btn-primary round-btn">${languageUtil.get(locale, "openLabel", "Open")}</button>
                        <button type="button" id="close-locations" class="btn btn-primary round-btn">${languageUtil.get(locale, "closeLabel", "Close")}</button>
                    </div>
                </div>
                <table class="table cemex-table">
                    <thead>
                        <tr>
                            <th>${languageUtil.get(locale, "status", "Status")}</th>
                            <th>${languageUtil.get(locale, "typeLabel", "Type")}</th>
                            <th>${languageUtil.get(locale, "nameLable", "Name")}</th>
                            <th>${languageUtil.get(locale, "regionLabel", "Region")}</th>
                            <th>${languageUtil.get(locale, "planType", "Plant Type")}</th>
                            <th>ID</th>
                            <th>${languageUtil.get(locale, "promotionLabel", "Promotion")}</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <#if entries?has_content>
                            <#list entries as curEntry>

                                <#assign renderer=curEntry.getAssetRenderer()>
                                <#assign className=renderer.getClassName()>
                                <#assign journalArticle=renderer.getArticle()>
                                <#assign document=saxReaderUtil.read(journalArticle.getContentByLocale(locale)) />
                                
                                <#assign entryId=journalArticle.articleId />
                                <#assign entryTitle=document.valueOf( "//dynamic-element[@name='Text55119005']/dynamic-content") />
                                <#assign isClosed=document.valueOf( "//dynamic-element[@name='Field53243791']/dynamic-content") />
                                <#assign region=document.valueOf( "//dynamic-element[@name='Field37057184']/dynamic-content") />
                                <#assign assetEntryLocalService=serviceLocator.findService("com.liferay.asset.kernel.service.AssetEntryLocalService") />
                                <#assign assetEntry=assetEntryLocalService.getEntry("com.liferay.journal.model.JournalArticle",journalArticle.getResourcePrimKey()) />
                                <#assign articleCategories=assetEntry.getCategories() />

                                <#assign viewURL= assetPublisherHelper.getAssetViewURL(renderRequest, renderResponse, curEntry, true) />
                                <#assign viewURL = viewURL?split("?") />
                                
                                <tr>
                                    <script>
                                        var regionVal = "${region?default('')}".trim();

                                        if (regionVal && regionVal !== 'null') {
                                            if (!uniqueValues.includes(regionVal)) {
                                                uniqueValues.push(regionVal);
                                            }
                                        }
                                    </script>

                                    <td><div class="<#if isClosed=='true'>red<#else>green</#if>"><#if isClosed=='true'>Closed<#else>Open</#if></div></td>
                                    <td><cwc-icon name="product-line-bulk-cement" color="true-black"></cwc-icon></td>
                                    <td><a href="${viewURL[0]}" class="location">${entryTitle}</a></td>
                                    <td>${region!!!"-"}</td>
                                    <td>
                                        <#if articleCategories?has_content><#list articleCategories as articleCategory>${articleCategory.getName()}<#if articleCategory?has_next>, </#if></#list><#else>-</#if>
                                    </td>
                                    <td class="location-id">${entryId}</td>
                                    <td><cwc-icon name="arrow-increase" color="bright-green"></cwc-icon></td>
                                    <td>
                                        <ul class="custom-dropdown">
                                            <li>
                                                <i class="fa fa-ellipsis-v" aria-hidden="true"></i>
                                                <ul>
                                                    <li><a href="${viewURL[0]}" data-senna-off="true">${languageUtil.get(locale, "viewDetails", "View Details")}</a></li>
                                                    <li><a class="edit-record" href="/en-GB/web/location-application-uk/add-page?articleId=${entryId}" data-senna-off="true">${languageUtil.get(locale, "editLabel", "Edit")}</a></li>
                                                    <li><a class="close-location" href="#" data-entry-value="${entryId}">${languageUtil.get(locale, "closeLocation", "Close Location")}</a></li>
                                                    <li><a class="open-location" href="#" data-entry-value="${entryId}">${languageUtil.get(locale, "openLocation", "Open Location")}</a></li>
                                                </ul>
                                            </li>
                                        </ul>
                                    </td>
                                </tr>
                            </#list>                        
                        </#if>

                    </tbody>
                </table>
            </div>

            <div id="bs-file-modal" class="bs-file-modal popup" style="display: none;">
                <div class="popup-window">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h4 class="modal-title">${languageUtil.get(locale, "fileInformation", "File Information")}</h4>
                        </div>
                        <form id="contactForm" onsubmit="return false;">
                            <div class="modal-body">
                                <input type="hidden" value="" class="file-update-id" />
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <div class="form-item">
                                                <input class="input-focus" type="text" id="filename" autocomplete="off" required />
                                                <label for="filename">${languageUtil.get(locale, "nameOfImportLabel", "Name of Import")}</label>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <div class="form-item">
                                                <span class="control-fileupload">
                                                    <label for="file">${languageUtil.get(locale, "chooseFileLabel", "Choose a file")}:</label>
                                                    <input type="file" id="file" required />
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-default common-btn popup-close">${languageUtil.get(locale, "cancelLabel", "Cancel")}</button>
                                <button id="save-csv-file" type="submit" class="btn btn-primary common-btn blue-btn">${languageUtil.get(locale, "saveLabel", "Save")}</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="add-location-main">
            <button class="btn btn-primary round-btn" id="add-location-redirect">
               <i class="fa fa-plus" aria-hidden="true"></i>${languageUtil.get(locale, "addLocation", "Add Location")}
            </button>
    </div>
</main>

<script src="/documents/d/global/toaster_js"></script>
<script>
    var searchLabel = "${languageUtil.get(locale, 'searchLabel', 'Search')}";
    var exportWait = "${languageUtil.get(locale, 'exportWait', 'Please wait, we are exporting the locations.')}";
    var noLocations = "${languageUtil.get(locale, 'noLocations', 'No locations available to export.')}";
    var exportError = "${languageUtil.get(locale, 'exportError', 'Export error. Please try again.')}";
    var atleastOne = "${languageUtil.get(locale, 'atleastOne', 'At least one location must be selected.')}";
    var selectedDownloaded = "${languageUtil.get(locale, 'selectedDownloaded', 'CSV file for the selected locations has been downloaded successfully.')}";
    var missingCreate = "${languageUtil.get(locale, 'missingCreate', 'Location is currently missing from our website. We are in the process of creating it.')}";
    var locationNotCreated = "${languageUtil.get(locale, 'locationNotCreated', 'Requested location is not created.')}";
    var fileDataUploadSuccess = "${languageUtil.get(locale, 'fileDataUploadSuccess', 'location-import-status.csv file uploaded successfully')}";
    var fileRequireValidation = "${languageUtil.get(locale, 'fileRequireValidation', 'Please select a file.')}";
    var locationUpdateSuccess = "${languageUtil.get(locale, 'locationUpdateSuccess', 'Location is updated successfully')}";
    var locationUpdateFailMessage = "${languageUtil.get(locale, 'locationUpdateFailMessage', 'Requested location is not updated.')}";
    var locationCreatedMessage = "${languageUtil.get(locale, 'locationCreatedMessage', 'Requested location is created successfully')}";
    var locationFailMessage = "${languageUtil.get(locale, 'locationFailMessage', 'Requested location is not created.')}";
    var warnExportSelect = "${languageUtil.get(locale, 'warnExportSelect', 'Please select any location to export.')}";
    var chooseFile = "${languageUtil.get(locale, 'chooseFile', 'Choose a file')}";
    var folderCreationFail = "${languageUtil.get(locale, 'folderCreationFail', 'Failed to create folder')}";
    var uploadFileCreationFail = "${languageUtil.get(locale, 'uploadFileCreationFail', 'Failed to upload file')}";

    // Dynamic value assignation based on the country
    var listOfEUCountries = [
        { 
            name: 'United Kingdom', 
            languageId: 'en_GB', 
            wcmFolderId: 39338,
            documentMediaFolderId: 43560,
            csvParentFodlerId: 46690,
            productParentCatId: 41361,
            productTypeVocId: 41357,
            code: "GB"
        }
    ];

    var csvParentFodlerId;
    var countryFolderId;
    var documentMediaFolderId;
    var currentCountry = "GB";
    var productParentCatId;
    var productTypeVocId;

    var currentCountryConfig = listOfEUCountries.find(country => country.languageId === themeDisplay.getLanguageId());

    if (currentCountryConfig) {
        csvParentFodlerId = currentCountryConfig.csvParentFodlerId;
        countryFolderId = currentCountryConfig.wcmFolderId;
        documentMediaFolderId = currentCountryConfig.documentMediaFolderId;
        productParentCatId = currentCountryConfig.productParentCatId;
        productTypeVocId = currentCountryConfig.productTypeVocId;
        currentCountry = currentCountryConfig.code;
    }

	var countryGroupId = parseInt(themeDisplay.getScopeGroupId());
    var guestRoleId = 20123;
    var countryGroupId = parseInt(themeDisplay.getSiteGroupId());
    var countryLanguageId = themeDisplay.getLanguageId();
    var articleStructureId = 38304;
    var articleTemplateId = '38405';

    var locationCSVName = "Downloaded Locations.csv";
    var articleClassName = 'com.liferay.journal.model.JournalArticle';
    var fileEntryClassName = 'com.liferay.document.library.kernel.model.DLFileEntry'

    function showLoader(isShow=false) {
        var overlayElement = document.getElementById('overlay');
        isShow ? overlayElement.classList.add("show") : overlayElement.classList.remove("show")
    }
	
	uniqueValues.forEach(function(element) {
        element = element.trim();
        
        const regionData = document.getElementById('region-data');
        const li = document.createElement('li');
        li.setAttribute('data-filter', element);
        li.textContent = element;
        regionData.appendChild(li);
    });

</script>

<script src="/documents/d/global/location-strcutre"></script>
<script src="/documents/d/global/datatable-loading"></script>
<script src="/documents/d/global/export-locations"></script>
<script src="/documents/d/global/liferay-functionality"></script>
<script src="/documents/d/global/import-locations"></script>
<script src="/documents/d/global/open-close-location"></script>

<script src="https://unpkg.com/vanilla-datatables@latest/dist/vanilla-dataTables.min.js"></script>