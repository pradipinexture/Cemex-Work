<!-- CSS Links -->
<link rel="stylesheet" href="https://unpkg.com/vanilla-datatables@latest/dist/vanilla-dataTables.min.css" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.7.2/css/all.min.css" />
<link rel="stylesheet" href="/documents/d/global/add-edit-location" />

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
                                <#assign assetEntryLocalService=serviceLocator.findService("com.liferay.asset.kernel.service.AssetEntryLocalService")>
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

<script>
    const inputs = document.querySelectorAll('.form-item input');

    function handleLabelMovement(input) {
        try{
            if(!input) return;
            const formItem = input.closest('.form-item');
            (input.value.trim()) ? formItem.classList.add('move-form-label') : formItem.classList.remove('move-form-label');
        } catch(e){}
    }

    inputs.forEach(function(input) {
        const originalDescriptor = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value');
        
        Object.defineProperty(input, 'value', {
            get: function() {
                return originalDescriptor.get.call(this);
            },
            set: function(val) {
                originalDescriptor.set.call(this, val);
                handleLabelMovement(this);
            }
        });

        input.addEventListener('focus', function() {this.closest('.form-item').classList.add('move-form-label');});
        input.addEventListener('blur', function() {handleLabelMovement(this)});
        input.addEventListener('input', () => handleLabelMovement(this));

        handleLabelMovement(input);
    });

    // Event listener for opening and closing popup modals
    document.addEventListener('click', function (e) {
       e = e || window.event;
       var target = e.target || e.srcElement;

       // Open modal when 'data-toggle="popup"' is clicked
       if (target.hasAttribute('data-toggle') && target.getAttribute('data-toggle') === 'popup') {
          if (target.hasAttribute('data-target')) {
             var m_ID = target.getAttribute('data-target');
             var modal = document.getElementById(m_ID);
             if (modal) {
                modal.classList.add('open');
             }
             e.preventDefault();
          }
       }

       // Close modal window with 'data-dismiss="popup"' or when the backdrop is clicked
       if ((target.hasAttribute('data-dismiss') && target.getAttribute('data-dismiss') === 'popup') || target.classList.contains('popup')) {
          var popupDivs = document.getElementsByClassName('popup');
          if (popupDivs && popupDivs.length > 0) {
             Array.from(popupDivs).forEach(function (item) {
                if (item.classList.contains('open')) {
                   item.classList.remove('open');
                }
             });
          }
          e.preventDefault();
       }
    }, false);

    // Close modal when elements with class "popup-close" are clicked
    var popupCloseButtons = document.querySelectorAll('.popup-close');
    popupCloseButtons.forEach(function (button) {
       button.addEventListener('click', function () {
          var backdrops = document.querySelectorAll('.modal-backdrop');
          backdrops.forEach(function (backdrop) {
             backdrop.remove();
          });

          var modals = document.querySelectorAll('.bs-file-modal');
          modals.forEach(function (modal) {
             modal.classList.remove('open'); // Mimic 'hide' in Bootstrap
          });
       });
    });


    var datatable = new DataTable("table", {
        perPage: 5,
    });

    var selectedRowsMap = {};

    // Select All functionality
    var init = function () {
        var inputs;
        
        var change = function (e) {
            var input = e.target;
            
            if (input === checkall) {
                // Get only current page checkboxes
                var currentPageCheckboxes = datatable.body.getElementsByClassName("checkbox");
                
                Array.from(currentPageCheckboxes).forEach(function(checkbox) {
                    checkbox.checked = input.checked;
                    var row = checkbox.closest('tr');
                    var rowId = row.querySelector('.location-id').textContent.trim();
                    row.classList.toggle("selected", input.checked);
                    
                    if (input.checked) {
                        selectedRowsMap[rowId] = getRowData(row);
                    } else {
                        delete selectedRowsMap[rowId];
                    }
                });
            } else {
                var row = input.closest('tr');
                var rowId = row.querySelector('.location-id').textContent.trim();
                
                if (input.checked) {
                    selectedRowsMap[rowId] = getRowData(row);
                } else {
                    delete selectedRowsMap[rowId];
                }
                row.classList.toggle("selected", input.checked);
            }
            updateSelectedCount();
            updateCheckAllState();
        };

        var update = function () {
            inputs = [].slice.call(datatable.body.getElementsByClassName("checkbox"));
            
            // Update checkbox states based on selectedRowsMap
            inputs.forEach(function(input) {
                var row = input.closest('tr');
                var rowId = row.querySelector('.location-id').textContent.trim();
                input.checked = !!selectedRowsMap[rowId];
                row.classList.toggle("selected", input.checked);
            });
            
            updateCheckAllState();
        };

        var checkall = document.createElement("input");
        checkall.type = "checkbox";
        checkall.className = "select-all-checkbox";

        var data = {
            sortable: false,
            heading: checkall,
            data: []
        };

        for (var n = 0; n < this.data.length; n++) {data.data[n] = '<input type="checkbox" class="checkbox">'}

        datatable.columns().add(data);
        update();

        datatable.container.addEventListener("change", change);

        datatable.on("datatable.page", update);
        datatable.on("datatable.perpage", update);
        datatable.on("datatable.sort", update);
    };

    function getRowData(row) {
        return {
            status: row.cells[0].textContent.trim(),
            name: row.cells[2].querySelector('a') ? row.cells[2].querySelector('a').textContent.trim() : '',
            region: row.cells[3].textContent.trim(),
            planType: row.cells[4].textContent.trim(),
            id: row.cells[5].textContent.trim()
        };
    }

    function updateCheckAllState() {
        var checkallBox = document.querySelector('.select-all-checkbox');
        if (!checkallBox) return;

        var currentPageCheckboxes = datatable.body.getElementsByClassName("checkbox");
        var allChecked = Array.from(currentPageCheckboxes).every(function(checkbox) {
            return checkbox.checked;
        });
        
        checkallBox.checked = allChecked && currentPageCheckboxes.length > 0;
    }

    function getSelectedRows() {
        return Object.values(selectedRowsMap);
    }

    function updateSelectedCount() {
        document.getElementById("selected-check-count").textContent = 
            Object.keys(selectedRowsMap).length;
    }

    document.getElementById('region-data').addEventListener('click', function(e) {
        if (e.target.tagName === 'LI') {
            var selectedRegion = e.target.dataset.filter;
            var dropdownButton = document.getElementById('filter-dropdown');
            dropdownButton.textContent = 'Region: ' + selectedRegion + ' ';
            
            var caret = document.createElement('span');
            caret.className = 'caret';
            dropdownButton.appendChild(caret);
            
            // Clear existing selections
            selectedRowsMap = {};
            updateSelectedCount();
            
            // Apply filter
            datatable.search(selectedRegion === 'All' ? '' : selectedRegion);
            
            document.getElementById('region-data').classList.remove('show');
        }
    });

    document.getElementById("filter-dropdown").addEventListener("click", function (e) {
        e.stopPropagation();
        document.getElementById("region-data").classList.toggle("show")
    });

    document.getElementById("csv-button").addEventListener("click", function (e) {
        e.stopPropagation();
        document.getElementById("download-options").classList.toggle("show");
    });

    document.addEventListener("click", function (e) {
        var regionDropdown = document.getElementById("region-data");
        var downloadDropdown = document.getElementById("download-options");
        var filterButton = document.getElementById("filter-dropdown");
        var csvButton = document.getElementById("csv-button");

        if (!filterButton.contains(e.target)) {
            regionDropdown.classList.remove("show");
        }
        if (!csvButton.contains(e.target)) {
            downloadDropdown.classList.remove("show");
        }
    });

    // Initialize
    datatable.on("datatable.init", init);
</script>

<script>
    var countryGroupId = parseInt(themeDisplay.getScopeGroupId());
    var guestRoleId = 20123;
    var csvParentFodlerId = 46690;

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

    document.getElementById('save-csv-file').addEventListener('click', async (e) => {
        
        const folderName = document.getElementById('filename').value || '-';
        const fileLabel = document.querySelector('label[for="file"]');

        try {
            const userName = themeDisplay.getUserName();

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

            const content = await readFileAsText(file);
            console.log(content);

            

        } catch (error) {
            console.error('Error in processing:', error);
            //Toast.danger('Error processing data', listingToastSetting);
        }
    });
</script>

<script src="https://unpkg.com/vanilla-datatables@latest/dist/vanilla-dataTables.min.js"></script>