var inputs = document.querySelectorAll('.form-item input');

function handleLabelMovement(input) {
    try{
        if(!input) return;
        var formItem = input.closest('.form-item');
        (input.value.trim()) ? formItem.classList.add('move-form-label') : formItem.classList.remove('move-form-label');
    } catch(e){}
}

inputs.forEach(function(input) {
    var originalDescriptor = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value');
    
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