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
        "<span class='col-md-2'><a class='edit-time " + day.toLowerCase() + "-edit' data-toggle='popup' data-target='.bs-hours-modal'>" +
        "<cwc-icon name='edit' color='true-black'></cwc-icon></a></span> </span></li>";

    var weekElement = document.querySelector("ul.week-list");
    weekElement.insertAdjacentHTML('beforeend', dayElement);
});

var $ = function(selector) { return document.querySelectorAll(selector); };
var getById = function(id) { return document.getElementById(id); };

   var editAllHours = document.querySelector('.edit-all-hours');
   if (editAllHours) {
       editAllHours.addEventListener('click', function() {
           resetTimer();
           $('.sat-sun').forEach(function(el) { el.checked = false; });
           $('.mon-fri').forEach(function(el) { el.checked = false; });
           $('.common-checkbox').forEach(function(el) { el.checked = true; });
       });
   }

   var monToFri = document.querySelector('.mon-to-fri');
   if (monToFri) {
       monToFri.addEventListener('click', function() {
           resetTimer();
           $('.common-checkbox').forEach(function(el) { el.checked = false; });
           $('.sat-sun').forEach(function(el) { el.checked = false; });
           $('.mon-fri').forEach(function(el) { el.checked = true; });
       });
   }

   var satToSun = document.querySelector('.sat-to-sun');
   if (satToSun) {
       resetTimer();
       satToSun.addEventListener('click', function() {
           $('.mon-fri').forEach(function(el) { el.checked = false; });
           $('.common-checkbox').forEach(function(el) { el.checked = false; });
           $('.sat-sun').forEach(function(el) { el.checked = true; });
       });
   }

   document.getElementById("hours-cancel").onclick = ()=> {resetTimer()}

   var editTimeButtons = document.querySelectorAll('.edit-time');
   editTimeButtons.forEach(function(button) {
       button.addEventListener('click', function() {
           resetTimer();
           var checkboxes = document.querySelectorAll('.bs-hours-modal .common-checkbox');
           checkboxes.forEach(function(el) { el.checked = false; });

           var dayValueEl = this.closest('li').querySelector('.day-value');
           if (dayValueEl && dayValueEl.dataset.day) {
               var dayname = dayValueEl.dataset.day;
               var checkbox = document.querySelector('.bs-hours-modal input[value="' + dayname + '"]');
               if (checkbox) checkbox.checked = true;
           }

           var timeInputs = this.closest('li').querySelectorAll('.col-md-4 input');
           var container = getById('type-time-container');
           if (container) {
               container.innerHTML = '';

               if (timeInputs.length === 1) {
                   setValueInTimeModel(timeInputs[0], false);
               } else {
                   var hoursType = getById('opening-hours-type');
                   if (hoursType) hoursType.value = 'Splitting';
                   timeInputs.forEach(function(input) { setValueInTimeModel(input, true); });
               }
           }
           document.getElementById("bs-hours-modal").classList.add("open");
       });


   var submitButton = document.querySelector('.submit-hours');
   if (submitButton) {
       submitButton.addEventListener('click', function() {
           var closeCheckbox = getById('close');
           var hoursTypeSelect = getById('opening-hours-type');
           
           if (!closeCheckbox || !hoursTypeSelect) return;

           var dayClosed = closeCheckbox.checked;
           var hoursType = hoursTypeSelect.value;

           document.querySelectorAll('.week-list-main li').forEach(function(li) {
               var checkbox = li.querySelector('input[type="checkbox"]');
               if (checkbox && checkbox.checked) {
                   var dayVal = checkbox.value;
                   var container = getById(dayVal + '-time-container');
                   if (!container) return;

                   container.innerHTML = '';

                   if (hoursType === 'Open') {
                       var startTime = document.querySelector('.start-time');
                       var closeTime = document.querySelector('.close-time');
                       if (startTime && closeTime) {
                           container.innerHTML = '<input type="text" placeholder="—:— - —:—" value="' + 
                               startTime.value + ' - ' + closeTime.value + '">';
                       }
                   } else if (hoursType === 'Splitting') {
                       var timeRows = document.querySelectorAll('#type-time-container .row');
                       timeRows.forEach(function(row) {
                           var startTime = row.querySelector('.start-time');
                           var closeTime = row.querySelector('.close-time');
                           if (startTime && closeTime) {
                               container.innerHTML += '<input type="text" placeholder="—:— - —:—" value="' + 
                                   startTime.value + ' - ' + closeTime.value + '">';
                           }
                       });
                   } else if (hoursType === 'Closed') {
                       container.innerHTML = '<input type="text" placeholder="—:— - —:—" value="Closed">';
                   }
               }
           });

           resetTimer();
       });
   }

   addStartEndRowElement();

   var newSplittingRow = getById('new-splitting-row');
   if (newSplittingRow) {
       newSplittingRow.addEventListener('click', function() {
           modelOpeningSave();
           addStartEndRowElement('');
       });
   }

   var hoursTypeSelect = getById('opening-hours-type');
   if (hoursTypeSelect) {
       hoursTypeSelect.addEventListener('change', function() {
           var selectedValue = this.value;
           modelOpeningSave();
           
           if (selectedValue === 'Closed') {
               modelOpeningSave(false);
           }
           addTimeFieldsRowByType(selectedValue);
       });
   }
});

function setValueInTimeModel(timeElement, isSplit) {
   if (!timeElement) return;

   modelOpeningSave();
   var timeValue = timeElement.value;
   var container = timeElement.closest('span');
   if (!container) return;

   var containerId = container.id.replace('-time-container', '');
   var idElement = getById(containerId);
   if (idElement) idElement.checked = true;

   var hoursType = getById('opening-hours-type');
   var closeTimeRow = getById('close-time-row');
   var closeCheckbox = getById('close');
   var newSplittingRow = getById('new-splitting-row');

   if (timeValue === 'Closed') {
       if (hoursType) hoursType.value = 'Closed';
       if (closeTimeRow) closeTimeRow.style.display = 'none';
       if (closeCheckbox) closeCheckbox.checked = true;
   } else {
       if (!isSplit && hoursType) {
           hoursType.value = 'Open';
       }
       addStartEndRowElement(timeValue);
   }

   if (closeCheckbox) closeCheckbox.checked = false;
   if (closeTimeRow) closeTimeRow.style.display = 'none';
   if (newSplittingRow) newSplittingRow.style.display = 'none';
}

function addStartEndRowElement(timeValue) {
   var container = getById('type-time-container');
   if (!container) return;

   timeValue = timeValue || '';
   var startTimeValue = '';
   var closeTimeValue = '';
   
   if (timeValue) {
       var times = timeValue.split(' - ');
       startTimeValue = times[0];
       closeTimeValue = times[1];
   }

   var row = document.createElement('div');
   row.className = 'row time-row';
   row.innerHTML = 
       '<div class="col-md-6">' +
           '<div class="form-group time-form-group">' +
               '<div class="form-item time-form-item move-form-label">' +
                   '<input type="time" class="start-time" value="' + startTimeValue + '">' +
                   '<label for="start-time">Open time</label>' +
               '</div>' +
           '</div>' +
       '</div>' +
       '<div class="col-md-6">' +
           '<div class="form-group time-form-group">' +
               '<div class="form-item time-form-item move-form-label">' +
                   '<input type="time" class="close-time" value="' + closeTimeValue + '">' +
                   '<label for="close-time">Close time</label>' +
               '</div>' +
           '</div>' +
       '</div>' +
       '<div class="col-md-12"><p class="error-message"></p></div>';

   container.appendChild(row);
}

function addTimeFieldsRowByType(selectedValue) {
   var container = getById('type-time-container');
   var newSplittingRow = getById('new-splitting-row');
   var closeTimeRow = getById('close-time-row');

   if (!container) return;
   container.innerHTML = '';

   if (!newSplittingRow || !closeTimeRow) return;

   switch(selectedValue) {
       case 'Open':
           newSplittingRow.style.display = 'none';
           addStartEndRowElement('');
           break;
       case 'Splitting':
           newSplittingRow.style.display = 'block';
           closeTimeRow.style.display = 'none';
           addStartEndRowElement('');
           break;
       case 'Closed':
           newSplittingRow.style.display = 'none';
           closeTimeRow.style.display = 'block';
           break;
   }
}

function validateTime() {
   var allValid = true;
   modelOpeningSave(true);

   document.querySelectorAll('#type-time-container .row').forEach(function(row) {
       var startTime = row.querySelector('.start-time');
       var closeTime = row.querySelector('.close-time');
       var errorMessage = row.querySelector('.error-message');
       
       if (!startTime || !closeTime || !errorMessage) return;

       errorMessage.textContent = '';
       errorMessage.style.display = 'block';

       if (!startTime.value && !closeTime.value) {
           errorMessage.textContent = fillRequiredField;
           return;
       }

       if (!startTime.value || !closeTime.value) {
           errorMessage.textContent = fillRequiredField;
           return;
       }

/*       if (startTime.value > closeTime.value) {
           errorMessage.textContent = 'Start time is not earlier than close time.';
           allValid = false;
       } else if (startTime.value === closeTime.value) {
           errorMessage.textContent = 'Start time and close time should not be same.';
           allValid = false;
       } else {
           errorMessage.style.display = 'none';
       }*/
       errorMessage.style.display = 'none';
   });

   if (allValid) modelOpeningSave(false);
   return allValid;
}

document.addEventListener('blur', function(event) {
   try {
       if (event.target.matches('.start-time, .close-time')) {
           validateTime();
       }
   } catch (error) {}
}, true);

function modelOpeningSave(isDisable) {
   var submitButton = getById('btnSubmit');
   if (!submitButton) return;
   
   isDisable = typeof isDisable !== 'undefined' ? isDisable : true;
   submitButton.disabled = isDisable;
}

function resetTimer() {
   document.querySelectorAll('.week-list-main li input').forEach(function(input) {
       input.checked = false;
   });

   modelOpeningSave();

   var hoursType = document.getElementById('opening-hours-type');
   if (hoursType) hoursType.value = 'Open';
   var closeTimeRow = document.getElementById('close-time-row');
   if (closeTimeRow) closeTimeRow.style.display = 'none';

   var timeContainer = document.getElementById('type-time-container');
   if (timeContainer) timeContainer.innerHTML = '';

   addStartEndRowElement('');
   var splittingRow = document.getElementById('new-splitting-row');
   if (splittingRow) splittingRow.style.display = 'none';
}
