let currentStep = 1;
const totalSteps = 4;

// Update stepper and form UI
function updateFormUI() {
  const iconMap = {
    1: '<i class="fas fa-download"></i>',
    2: '<i class="fas fa-table"></i>',
    3: '<i class="fas fa-gear"></i>',
    4: '<i class="far fa-file-alt"></i>',
  };
  
 // const completedIcon = '<i class="fas fa-circle" style="font-size:2rem"</i>

  for (let i = 1; i <= totalSteps; i++) {
    const step = document.getElementById(`step-${i}`);
    const form = document.getElementById(`form-${i}`);
    const circle = step.querySelector('.step-circle');

    if (i === currentStep) {
      step.classList.add('active');
      step.classList.remove('completed');
     // circle.innerHTML = iconMap[i];
      circle.innerHTML = '<i class="fas fa-circle"  style="font-size:2rem"></i>';
    //  circle.innerHTML = completedIcon;
      form.classList.remove('hidden');
      form.classList.add('active');
    } else {
      step.classList.remove('active');
      form.classList.add('hidden');
      form.classList.remove('active');

      if (i < currentStep) {
        step.classList.add('completed');
        circle.innerHTML = '<i class="fas fa-check"></i>';
      } else {
        step.classList.remove('completed');
        circle.innerHTML = iconMap[i];
      }
    }
  }

  updateProgressBar();
}

function setStep(step) {
  currentStep = step;
  updateFormUI();
  hideNonCurrentForms();
}


function updateProgressBar() {
  const progressBar = document.getElementById('progress-bar');
  const progressStepText = document.getElementById('progress-step-text');

  const progressPercentage = (currentStep / totalSteps) * 100;

  progressBar.style.width = `${progressPercentage}%`;
  progressStepText.textContent = `${currentStep}/${totalSteps}`;
}


function getCurrentStep() {
  return currentStep;
}

// Event listeners for next and previous buttons
document.addEventListener('DOMContentLoaded', () => {
  document.getElementById('prev').addEventListener('click', () => {
    if (currentStep > 1) {
      currentStep -= 1;
      updateFormUI();
      hideNonCurrentForms();
    }
  });

  document.getElementById('next').addEventListener('click', () => {
    if (currentStep < totalSteps) {
      currentStep += 1;
      updateFormUI();
      hideNonCurrentForms();
    }
  });

  updateFormUI();
  hideNonCurrentForms();
});

function hideNonCurrentForms() {
  const formContents = document.querySelectorAll('.form-content');

  formContents.forEach((form, index) => {
    if (index + 1 !== currentStep) {
      form.classList.add('hidden');
    } else {
      form.classList.remove('hidden');
    }
  });
}