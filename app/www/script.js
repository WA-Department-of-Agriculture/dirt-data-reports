function activateSteps(stepNumber) {
      // Loop through all steps and add the 'active' class to each step up to the clicked one
      for (let i = 1; i <= 5; i++) {
        let stepButton = document.getElementById('step' + i);
        let slide = document.getElementById('slide' + i);
        
        if (i <= stepNumber) {
          stepButton.classList.add('active');
        } else {
          stepButton.classList.remove('active');
        }

        // Show the corresponding slide and hide the others
        if (i === stepNumber) {
          slide.classList.add('active-slide');
        } else {
          slide.classList.remove('active-slide');
        }
      }
    }

function nextSlide(stepNumber) {
  activateSteps(stepNumber);
}