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
                        <ul id="region-data" class="dropdown-menu" aria-labelledby="filter-dropdown"><li data-filter="All">All</li><li data-filter="North Yorkshire">North Yorkshire</li><li data-filter="another">another</li><li data-filter="dfg">dfg</li><li data-filter="fgdsdsdfsdf">fgdsdsdfsdf</li><li data-filter="sdf">sdf</li><li data-filter="sdfsdf">sdfsdf</li><li data-filter="sdfsfsdfsfh">sdfsfsdfsfh</li><li data-filter="Random region">Random region</li></ul>
                    </div>

                    <div class="action-btn">
                        <span id="selected-check-count">0</span><span> items selected</span>
                        <button type="button" id="import-csv-button open-modal-button" class="btn btn-primary round-btn add-file" data-target="bs-file-modal" data-toggle="popup">
                            <cwc-icon name="plus" color="bright-blue" class="hydrated" data-dir="ltr"></cwc-icon>
                            Import CSV
                        </button>
                        <span class="dropdown" id="download-dropdown">
                            <button type="button" id="csv-button" data-toggle="dropdown" class="btn btn-primary round-btn">
                                Download CSV
                                <cwc-icon name="arrow-down-rounded-fill" color="bright-blue"></cwc-icon>
                            </button>
                            <ul id="download-options" class="dropdown-menu">
                                <li id="download-selected">Download Selected Locations</li>
                                <li id="download-all">Download All Locations</li>
                            </ul>
                        </span>
                        <button type="button" id="open-locations" class="btn btn-primary round-btn">Open</button>
                        <button type="button" id="close-locations" class="btn btn-primary round-btn">Close</button>
                    </div>
                </div>
                <table class="table cemex-table">
                    <thead>
                        <tr>
                            <th>Status</th>
                            <th>Type</th>
                            <th>Name</th>
                            <th>Region</th>
                            <th>Plan Type</th>
                            <th>ID</th>
                            <th>Promotion</th>
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
                                <#assign isClosed=document.valueOf( "//dynamic-element[@name='Checkbox90733914']/dynamic-content") />
                                <#assign region=document.valueOf( "//dynamic-element[@name='Field37057184']/dynamic-content") />
                                <#assign assetEntryLocalService=serviceLocator.findService("com.liferay.asset.kernel.service.AssetEntryLocalService") />
                                <#assign assetEntry=assetEntryLocalService.getEntry("com.liferay.journal.model.JournalArticle",journalArticle.getResourcePrimKey()) />
                                <#assign articleCategories=assetEntry.getCategories() />

                                <#assign viewURL= assetPublisherHelper.getAssetViewURL(renderRequest, renderResponse, curEntry, true) />
								<#assign viewURL = viewURL?split("?") />
 								
                                <tr>
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
                                                    <li><a href="#">View Details</a></li>
                                                    <li><a class="edit-record" href="/add-location?articleId=${entryId}">Edit</a></li>
                                                    <li><a class="close-location" href="#" data-entry-value="${entryId}">Close Location</a></li>
                                                    <li><a href="#">View Listings</a></li>
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
                            <h4 class="modal-title">File Information</h4>
                        </div>
                        <form id="contactForm" onsubmit="return false;">
                            <div class="modal-body">
                                <input type="hidden" value="" class="file-update-id" />
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <div class="form-item">
                                                <input class="input-focus" type="text" id="filename" autocomplete="off" required />
                                                <label for="filename">Name of Import</label>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <div class="form-item">
                                                <span class="control-fileupload">
                                                    <label for="file">Choose a file:</label>
                                                    <input type="file" id="file" required />
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-default common-btn popup-close">Cancel</button>
                                <button id="save-csv-file" type="submit" class="btn btn-primary common-btn blue-btn">Save</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <button type="button" id="" class="btn btn-danger pull-right invisible">Delete Rows</button>
                </div>
            </div>
        </div>
    </div>
    <div class="add-location-main">
            <button class="btn btn-primary round-btn" id="add-location-redirect">
               <i class="fa fa-plus" aria-hidden="true"></i> Add Location
            </button>
    </div>
</main>

<script src="/documents/d/global/toaster_js"></script>
<script src="/documents/d/global/datatable-loading"></script>

<script>
	
    const searchLabel = "Search";
    const exportWait = "Please wait, we are exporting the locations.";
    const noLocations = "No locations available to export.";
    const exportError = "Export error. Please try again.";
    const atleastOne = "At least one location must be selected.";
    const selectedDownloaded = "CSV file for the selected locations has been downloaded successfully.";
    const missingCreate = "Location is currently missing from our website. We are in the process of creating it.";
    const locationNotCreated = "Requested location is not created.";

    const fileDataUploadSuccess = "location-import-status.csv file uploaded successfully";
    const fileRequireValidation = "Please select a file.";
    const locationUpdateSuccess = "Location is updated successfully";
    const locationCreatedMessage = "Requested location is created successfully";
    const locationFailMessage = "Requested location is not created.";

    var countryGroupId = parseInt(themeDisplay.getScopeGroupId());
    var guestRoleId = 20123;
    var csvParentFodlerId = 46690;
    var countryGroupId = parseInt(themeDisplay.getSiteGroupId());
    var countryLanguageId = themeDisplay.getLanguageId();
    var countryFolderId = 39338;
    var documentMediaFolderId = 43560;
    var currentCountry = "GB";
    var articleStructureId = 38304;
    var articleTemplateId = '38405';
    var guestRoleId= 20123;
    var coutryLanguageId = themeDisplay.getLanguageId();
    var locationCSVName = "location.csv";

    function showLoader(isShow=false) {
        var overlayElement = document.getElementById('overlay');
        isShow ? overlayElement.classList.add("show") : overlayElement.classList.remove("show")
    }

    var locationFieldsIds = {
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
              phoneNumber1: {
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

    async function updateArticle(locationXMLDataUpdateTime, locationformData, articleName) {
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
                       titleMap: getMapLiferay(articleName),
                       descriptionMap: getMapLiferay(""),
                       content: locationformData,
                       layoutUuid: "",
                       serviceContext: { assetCategoryIds: [] }
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

    async function addArticle(xmlData, articleName) {
       try {
           const article = await new Promise((resolve, reject) => {
               Liferay.Service(
                   '/journal.journalarticle/add-article',
                   {
                      externalReferenceCode: '',
                      groupId: countryGroupId,
                      folderId: countryFolderId,
                      titleMap: getMapLiferay(articleName),
                      descriptionMap: getMapLiferay(""),
                      content: xmlData,
                      layoutUuid: "",
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
               //await addResourcesToArticle(article);
               //Toast.success(locationCreatedMessage);
           } else {
               //Toast.error(locationFailMessage);
               //throw new Error('Article creation failed');
           }
       } catch (error) {
            //Toast.error(locationFailMessage);
           //throw error;
       }
       //saveButtonOperation(false, false);
    }


    function getMapLiferay(eleValue) {
      return {[countryLanguageId]: eleValue}
    }

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

          return fileUploadResponse;                
      } catch (error) {
          console.error(error.message);
          return null;
      }
    }

    async function setGuestPermissionsForFileEntry(fileEntryId) {
        try {
            const formData = new FormData();
            formData.append('groupId', countryGroupId);
            formData.append('companyId', themeDisplay.getCompanyId());
            formData.append('name', 'com.liferay.document.library.kernel.model.DLFileEntry');
            formData.append('primKey', fileEntryId);
            formData.append('roleId', guestRoleId);
            formData.append('actionIds', ['VIEW']);

            const response = await fetch('/api/jsonws/resourcepermission/set-individual-resource-permissions', { method: 'POST', body: formData, headers: { 'X-CSRF-Token': Liferay.authToken } });

            if (!response.ok) {
                //throw new Error(`Permission setting failed: response.status`);
                console.error("Permission has not assigned to that file.")
            }

            console.log("Permission added successfully");
            return await response.json();
        } catch (error) {
            console.error('Permission setting failed:', error);
            return null;
        }
    }

    async function createLiferayFolder(name) {
        try {
            const formData = new FormData();
            formData.append('repositoryId', themeDisplay.getScopeGroupId());
            formData.append('parentFolderId', csvParentFodlerId);
            formData.append('name', name);
            formData.append('description', name);
            formData.append('externalReferenceCode', '');

            const response = await fetch('/api/jsonws/dlapp/add-folder', {
                method: 'POST',
                body: formData,
                headers: {
                    'X-CSRF-Token': Liferay.authToken
                }
            });

            if (!response.ok) {
                //throw new Error(`HTTP error! status: response.status`);
                console.error("Folder has not assigned to that parent folder.")
            }

            const folder = await response.json();
            
            console.log("Folder has uploaded to CSV parent folder with "+ name +" name.");
            
            return folder;

        } catch (error) {
            console.error('Error creating folder:', error);
            return null;
        }
    }

    async function fetchArticles() {
       return new Promise((resolve, reject) => {
          Liferay.Service(
             '/journal.journalarticle/get-articles-by-structure-id', {
                groupId: countryGroupId,
                ddmStructureId: articleStructureId,
                start: -1,
                end: -1,
                '-orderByComparator': ''
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

    function resetCSVModal() {
        document.getElementById('filename').value = '';
        
        const fileInput = document.getElementById('file');
        const label = document.querySelector('label[for="file"]');
        
        fileInput.value = '';
        label.textContent = 'Choose a file : ';
    }

    function readFileAsText(file) {
        return new Promise((resolve, reject) => {
            if (!(file instanceof Blob)) {
                file = new Blob([file], { type: 'text/csv' });
            }
            const reader = new FileReader();
            reader.onload = event => resolve(event.target.result);
            reader.onerror = reject;
            reader.readAsText(file);
        });
    }

    document.getElementById('file').addEventListener('change', async function() {    
        const fileInput = document.getElementById("file");
        if (!fileInput) return null;

        const file = fileInput.files[0];
        if (!file) return null;

        document.querySelector('label[for="file"]').textContent = file.name;
    });

    var csvContent;
    document.getElementById('save-csv-file').addEventListener('click', async (e) => {
        const folderName = document.getElementById('filename').value || '-';
        const fileLabel = document.querySelector('label[for="file"]');

        try {
            const userName = themeDisplay.getUserName();

            // Uncomment the folder creation and file upload if necessary
            /*
            const folder = await createLiferayFolder((folderName+"_"+userName), csvParentFodlerId);
            if (!folder) {
                console.log('Failed to create folder');
                return;
            }

            const uploadedFile = await uploadFileToLiferay("file", folder.folderId);
            if (!uploadedFile) {
                console.log('Failed to upload file');
                return;
            }
            */
            const fileInput = document.getElementById("file");
            if (!fileInput) {
                console.error("File input with id "+fileInputId+" not found");
                return null;
            }

            const file = fileInput.files[0];
            if (!file) {
                console.error('No file selected');
                return null;
            }

            // Reading file content as text
            csvContent = await readFileAsText(file);

            // Replacing specific newline characters with <br>
            csvContent = csvContent.replace(/\n(?=ContactName_)/g, '<br>');
            csvContent = csvContent.replace(/\n(?=PriceName_)/g, '<br>');
            csvContent = csvContent.replace(/\n(?=Publisher_)/g, '<br>');
            csvContent = csvContent.replace(/\n(?=PageName_)/g, '<br>');
            csvContent = csvContent.replace(/\n(?=openTime_)/g, '<br>');
            csvContent = csvContent.replace(/\n(?=Name_)/g, '<br>');

            // Splitting and filtering lines
            const lines = csvContent.split('\n').filter(line => line.trim() !== '');
            const headers = lines[0].trim().split(',');

            // Processing CSV data asynchronously
            const generatedArticleResource = await processCSVData(lines[1], headers);
            console.log(generatedArticleResource)
            if(generatedArticleResource.locationId) {
                // update
            } else {
                var addedArticle = await addArticle(generatedArticleResource.xmlData, generatedArticleResource.name);
                console.log(addedArticle)
            }

        } catch (error) {
            console.error('Error in processing:', error);
        }
    });

    async function processCSVData(line, headers) {
        // Initialize xmlBuilder as a new XML document
        var xmlBuilder = document.implementation.createDocument(null, null);
        var declaration = xmlBuilder.createProcessingInstruction('xml', 'version="1.0"');
        xmlBuilder.appendChild(declaration);

        // Create root element
        var rootElement = xmlBuilder.createElement('root');
        rootElement.setAttribute('available-locales', coutryLanguageId);
        rootElement.setAttribute('default-locale', coutryLanguageId);
        rootElement.setAttribute('version', '1.0');
        xmlBuilder.appendChild(rootElement);
        
        if (!line.trim()) return;

        var columns = parseCSVLine(line);
        var locationName = '';
        var locationId = '';

        for (let j = 0; j < headers.length; j++) {
            var header = headers[j].trim();
            var value = columns[j]?.trim() || '';

            if (!value || value === '-') continue;

            switch (header) {
                case 'ContactDetail':
                case 'FileCard':
                case 'PublisherImages':
                case 'AddPage':
                case 'ProductCard':
                    await processNestedFields(header, value);
                    break;
                default:
                    await processSimpleField(header, value);
                    break;
            }
        }

        async function processSimpleField(fieldId, value) {
            const config = locationFieldsIds[fieldId];
            if(fieldId == "LocationId") locationId = value;
            if(!value || value == "-"|| !config) return;
            if(fieldId == "LocationName") locationName = value;
            if(config.type == "image") return;
            await createDynamicElement(config.xmlFieldName, fieldId, config.type, value, true);
       }

        // Helper function to process each nested field (for ContactDetail and FileCard)
        async function processNestedFields(header, value) {
            const config = locationFieldsIds[header];

            // Split the value by line breaks
            const contacts = value.split('<br>');
            for (const contact of contacts) {
                const dynamicElement = await getDynamicElement(config.xmlFieldName, header, config.type, '');
                const details = contact.split(', ');
                
                for (const detail of details) {
                    const [rawKey, val] = detail.split(' : ').map(str => str.trim());
                    const key = rawKey.split('_')[0];

                    if (!key || !val) continue;

                    // Get the field configuration for the nested fields
                    var fieldConfig = config["nestedFields"][key.charAt(0).toLowerCase() + key.slice(1)];
                    if(config.type == "image") continue;
                    // Generate and append the dynamic XML element
                    const fieldGenXML = await createDynamicElement(fieldConfig.xmlFieldName, key, fieldConfig.type, val, false);
                    dynamicElement.appendChild(fieldGenXML);
                }

                xmlBuilder.documentElement.appendChild(dynamicElement);
            }
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
         
        return { 
            locationId : locationId,
            name : locationName,
            xmlData: new XMLSerializer().serializeToString(xmlBuilder)
        };
        
    }

    async function getRandomString(length) {
        const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        let result = '';
        for (let i = 0; i < length; i++) {
            result += characters.charAt(Math.floor(Math.random() * characters.length));
        }
        return result;
    }

    function parseCSVLine(line) {
        var columns = [];
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
</script>
			
<script>
    document.getElementById('download-selected').addEventListener('click', async function () {
        showLoader(true)
        try {
            const locationRows = getSelectedRows();

            if (locationRows.length === 0) {
                Toast.error(atleastOne);
                showLoader();
                return;
            }

            // Use Promise.all to handle all async operations in parallel
            const jsonLocations = await Promise.all(
                locationRows.map(loc => getWebcontentDataAsMap(null, loc.id))
            );
            console.log(jsonLocations);
            const convertedLocationData = await convertObjectTOCSVData(jsonLocations);

            if (convertedLocationData) {
                await downloadCSV(convertedLocationData, locationCSVName);
            }
            showLoader()
        } catch (error) {
            console.error('Error downloading locations:', error);
            Toast.error('Failed to download locations');
            showLoader()
        }
    });

    document.getElementById('download-all').addEventListener('click', async function () {
        try {
            showLoader(true);
            Toast.info(exportWait);

            const articles = await fetchArticles();

            if (!articles || articles.length === 0) {
                Toast.error(noLocations);
                showLoader();
                return;
            }

            const jsonLocations = await Promise.all(
                articles.map(loc => getWebcontentDataAsMap(loc, loc.id))
            );

            console.log(jsonLocations);
            const convertedLocationData = await convertObjectTOCSVData(jsonLocations);

            if (convertedLocationData) {
                await downloadCSV(convertedLocationData, locationCSVName);
            }
            showLoader()
        } catch (error) {
            Toast.error(exportError);
            console.error('Error fetching articles:', error);
            showLoader(true);
        }

        
    });

    var locationStructureFields = ["LocationId", "LocationName", "Address", "Address2", "TownCity", "Country", "Postcode", "PhoneNumber", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "ProductCard", "ContactDetail", "Longitude", "Latitude", "isYextRestrict", "RichText", "PlantType", "CompanyName", "LocationImage", "FileCard", "AddPage", "PublisherImages", 'State', 'Region'];

    async function getWebcontentDataAsMap(providedWebContent, locationId) {
        try {
            let webContent = providedWebContent;
            if (!webContent) {
                webContent = await new Promise((resolve, reject) => {
                    Liferay.Service('/journal.journalarticle/get-article', {
                        groupId: countryGroupId,
                        articleId: locationId
                    }, function(result, error) {
                        if (error) {
                            reject(error);
                        } else {
                            resolve(result);
                        }
                    });
                });
            }

            const categories = await getWebcontentCategories(webContent.resourcePrimKey);
            const elementMap = new Map();

            if (categories && categories.length > 0) {
                const categoryStrings = categories.map(category => category.titleCurrentValue);
                elementMap.set("PlantType", [categoryStrings.join(", ")]);
            }

            elementMap.set("LocationId", webContent.articleId);

            const xmlDoc = new DOMParser().parseFromString(webContent.content, 'application/xml');
            const rootElement = xmlDoc.querySelector('root');
            const dynamicElements = rootElement.children;

            for (const dynamicElement of dynamicElements) {
                const fieldRefValue = dynamicElement.getAttribute('name');
                const name = dynamicElement.getAttribute('field-reference');

                const dynamicContent = dynamicElement.querySelector('dynamic-content');
                let value = dynamicContent?.textContent || '';
                value = value.replace(/\n/g, "<br>");

                if (!elementMap.has(name)) elementMap.set(name, []);

                if (!value) {
                    elementMap.get(name).push('-');
                    continue;
                }

                const nestedElements = dynamicElement.getElementsByTagName('dynamic-element');
                
                if (nestedElements.length > 0) {
                    if (name == "OpeningHours") {
                        const dayObj = {};
                        const dayValue = getElementValueByName(dynamicElement, "DayName");
                        
                        if (getElementValueByName(dynamicElement, "isClosed") == "true") {
                            dayObj["isClosed"] = "true";
                        } else {
                            let openCloseCount = 1;
                            for (const op of nestedElements) {
                                const opName = op.getAttribute('field-reference');
                                if (opName != "Fieldset54865370") continue;

                                const dayOpenTime = getElementValueByName(op, "Open");
                                const dayCloseTime = getElementValueByName(op, "Close");
                                
                                if(!dayOpenTime || !dayCloseTime) continue;

                                dayObj["openTime" + openCloseCount] = dayOpenTime;
                                dayObj["closeTime" + openCloseCount++] = dayCloseTime;
                            }
                        }
                        elementMap.set(dayValue, [dayObj]);
                    } else {
                        const nestedObjectList = dynamicElementToObjectList(nestedElements, name);
                        elementMap.get(name).push(nestedObjectList);
                    }
                } else {
                    if (name == "Geolocation") {
                        const mapCordi = JSON.parse(value);
                        elementMap.set("Latitude", [mapCordi.lat]);
                        elementMap.set("Longitude", [mapCordi.lng]);
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

    async function convertObjectTOCSVData(locationData) {
        if (locationData.length === 0) return null;

        const escapeField = function(value) {
            if (typeof value === 'string') return '"' + value.replace(/"/g, '""') + '"';
            return value;
        };

        const handleJsonField = function(value) {
            if (typeof value === 'object' && value !== null) return escapeField(JSON.stringify(value));
            return value;
        };

        const csvContent = [locationStructureFields.join(",")];
        
        const rows = await Promise.all(locationData.map(async function(location) {
            const fieldValues = await Promise.all(locationStructureFields.map(async function(field) {
                let fieldValue = location.get(field);
                if ((!fieldValue && field.endsWith("day")) || (fieldValue?.length > 0 && typeof fieldValue[0] === 'object' && !Object.keys(fieldValue[0]).length)) {
                    return escapeField("Closed");
                }
                if(!fieldValue) return escapeField("-");

                if (Array.isArray(fieldValue) && fieldValue.length > 0) {
                    if (field.endsWith("day")) {
                        if (fieldValue[0].isClosed == "true") {
                            return escapeField("Closed");
                        } else {
                            const timeEntries = Object.entries(fieldValue[0])
                                .map(function(entry) {
                                    return entry[0].replace(/(\D+)(\d+)/, '$1_$2') + ' : ' + entry[1];
                                })
                                .reduce(function(acc, curr, i) {
                                    return acc + (i % 2 === 0 ? (i === 0 ? "" : "\n") + curr : ", " + curr);
                                }, "");
                            return escapeField(timeEntries);
                        }
                    } else if (!(fieldValue[0] instanceof Object)) {
                        return escapeField(fieldValue.join('", "'));
                    } else {
                        const objString = fieldValue.map(function(item, i) {
                            return Object.keys(item).map(function(key) {
                                return key + '_' + (i + 1) + ' : ' + handleJsonField(item[key]);
                            }).join(',  ');
                        }).join('\n');
                        return escapeField(objString);
                    }
                }

                fieldValue = handleJsonField(fieldValue);
                return fieldValue || escapeField("-");
            }));
            
            return fieldValues.join(',');
        }));
        
        csvContent.push(...rows);
        return csvContent.join("\n");
    }

    async function downloadCSV(csvData, fileName) {
        return new Promise((resolve, reject) => {
            try {
                const blob = new Blob([csvData], { type: 'text/csv' });
                const downloadLink = document.createElement('a');
                downloadLink.href = URL.createObjectURL(blob);
                downloadLink.download = fileName;

                document.body.appendChild(downloadLink);
                downloadLink.click();
                document.body.removeChild(downloadLink);
                Toast.success(selectedDownloaded);
                resolve();
            } catch (error) {
                reject(error);
            }
        });
    }

    function getElementValueByName(dynamicElement, key) {
        return dynamicElement.querySelector('dynamic-element[field-reference="' + key + '"]')?.querySelector('dynamic-content')?.textContent;
    }

    function dynamicElementToObjectList(cardNestedElements, name) {
        const nestedElementsObj = {};

        for (const nestedElement of cardNestedElements) {
            const nestedName = nestedElement.getAttribute('field-reference');
            const nestedContent = nestedElement.querySelector('dynamic-content');
            const nestedValue = nestedContent?.textContent;

            nestedElementsObj[nestedName] = nestedValue;
        }
        return nestedElementsObj;
    }

    async function getWebcontentCategories(resourcePK) {
        return new Promise((resolve, reject) => {
            Liferay.Service('/assetcategory/get-categories', {
                className: 'com.liferay.journal.model.JournalArticle',
                classPK: parseInt(resourcePK)
            }, function(result, error) {
                if (error) {
                    reject(error);
                } else {
                    resolve(result);
                }
            });
        });
    }	
</script>
<script src="https://unpkg.com/vanilla-datatables@latest/dist/vanilla-dataTables.min.js"></script>