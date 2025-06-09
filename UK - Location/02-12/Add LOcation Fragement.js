document.addEventListener("DOMContentLoaded", function() {
    var editor1 = new RichTextEditor("#div_editor1");
    // editor1.setHTMLCode("Use inline HTML or setHTMLCode to init the default content.");
});


var inputs = document.querySelectorAll('.form-item input');

function handleLabelMovement(input) {
    if(!input) return;
    var formItem = input.closest('.form-item');
    (input.value.trim()) ? formItem.classList.add('move-form-label') : formItem.classList.remove('move-form-label');
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

document.addEventListener('click', function (e) {
    // Prevent default behavior
    e = e || window.event;
    var target = e.target || e.srcElement;

    // Check if the element has a 'data-toggle' attribute for opening the modal
    if (target.hasAttribute('data-toggle') && target.getAttribute('data-toggle') === 'popup') {
        if (target.hasAttribute('data-target')) {
            var m_ID = target.getAttribute('data-target');
            document.getElementById(m_ID).classList.add('open');
            e.preventDefault();
        }
    }

    // Check if the element has a 'data-dismiss' attribute for closing the modal or if it's a background overlay
    if ((target.hasAttribute('data-dismiss') && target.getAttribute('data-dismiss') === 'popup') || target.classList.contains('popup')) {
        var popupDivs = document.getElementsByClassName('popup');
        if (popupDivs.length > 0) {
            for (var i = 0; i < popupDivs.length; i++) {
                if (popupDivs[i].classList.contains('open')) {
                    popupDivs[i].classList.remove('open');
                }
            }
        }
        e.preventDefault();
    }
}, false);