// ===============================
// Table of Contents:
// 1. Table of Contents (TOC) Scroller
// 2. Stepper and Form Navigation
// 3. Progress Bar Updates
// 4. Get Current Step
// 5. Hide Non-Current Form Contents
// ===============================


document.addEventListener('DOMContentLoaded', () => {
  // Get buttons
  const wordButton = document.getElementById('wordOutput');
  const htmlButton = document.getElementById('htmlOutput');

  // Add event listeners for the buttons
  wordButton.addEventListener('click', () => {
    // Check if the button is already active
    if (wordButton.classList.contains('active')) {
      wordButton.classList.remove('active'); // Deselect the button
      Shiny.setInputValue('format', null); // Reset Shiny input
    } else {
      // Remove active class from all buttons
      document.querySelectorAll('.output-button').forEach((button) => {
        button.classList.remove('active');
      });
      // Set Word button as active
      wordButton.classList.add('active');
      Shiny.setInputValue('format', 'docx'); // Update Shiny input for Word DOCX
    }
  });

  htmlButton.addEventListener('click', () => {
    // Check if the button is already active
    if (htmlButton.classList.contains('active')) {
      htmlButton.classList.remove('active'); // Deselect the button
      Shiny.setInputValue('format', null); // Reset Shiny input
    } else {
      // Remove active class from all buttons
      document.querySelectorAll('.output-button').forEach((button) => {
        button.classList.remove('active');
      });
      // Set HTML button as active
      htmlButton.classList.add('active');
      Shiny.setInputValue('format', 'html'); // Update Shiny input for HTML
    }
  });
});


document.addEventListener('DOMContentLoaded', () => {
  // Get language buttons
  const englishButton = document.getElementById('englishLang');
  const spanishButton = document.getElementById('spanishLang');

  // Function to toggle active state
  const toggleActiveLanguage = (selectedButton) => {
    document.querySelectorAll('.language-button').forEach((button) => {
      if (button === selectedButton) {
        if (button.classList.contains('active')) {
          button.classList.remove('active'); // Deselect if already selected
          Shiny.setInputValue('language', null); // Reset Shiny input
        } else {
          button.classList.add('active'); // Select the clicked button
          Shiny.setInputValue('language', selectedButton.id === 'englishLang' ? 'template.qmd' : 'template_esp.qmd'); // Update Shiny input
        }
      } else {
        button.classList.remove('active'); // Deselect other buttons
      }
    });
  };

  // Add event listeners
  englishButton.addEventListener('click', () => toggleActiveLanguage(englishButton));
  spanishButton.addEventListener('click', () => toggleActiveLanguage(spanishButton));
});


/* ===============================
   1. Table of Contents (TOC) Scroller
   =============================== */
document.addEventListener('DOMContentLoaded', function () {
  const contentArea = document.getElementById('content-area');
  const tocContainer = document.getElementById('toc-container');
  const headerOffset = 80;
  const sectionMargin = 200;
  let currentActive = -1;

  if (!contentArea || !tocContainer) return;

  const headers = contentArea.querySelectorAll('h2');
  const tocLinks = [];
  const sections = [];

  headers.forEach((header, index) => {
    const id = header.textContent.trim().toLowerCase().replace(/\s+/g, '-');
    header.id = id;

    const link = document.createElement('a');
    link.href = `#${id}`;
    link.textContent = header.textContent;
    link.classList.add('toc-link');


    tocContainer.appendChild(link);
    tocLinks.push(link);
    sections.push(header);
  });

  const makeActive = (index) => tocLinks[index]?.classList.add('active');
  const removeAllActive = () => tocLinks.forEach((link) => link.classList.remove('active'));

  const updateActiveLink = () => {
    let sectionIndex = -1;

    if (window.innerHeight + window.pageYOffset >= document.body.offsetHeight - sectionMargin) {
      sectionIndex = sections.length - 1;
    } else {
      sections.forEach((section, index) => {
        const rect = section.getBoundingClientRect();
        if (rect.top <= headerOffset && rect.bottom > headerOffset) {
          sectionIndex = index;
        }
      });
    }

    if (sectionIndex !== -1 && sectionIndex !== currentActive) {
      removeAllActive();
      makeActive(sectionIndex);
      currentActive = sectionIndex;
    }
  };

  tocLinks.forEach((link, index) => {
    link.addEventListener('click', (event) => {
      event.preventDefault();
      const targetEl = sections[index];
      if (targetEl) {
        const offsetTop = Math.min(
          targetEl.offsetTop - headerOffset,
          document.body.scrollHeight - window.innerHeight
        );

        window.scrollTo({ top: offsetTop, behavior: 'smooth' });

        removeAllActive();
        makeActive(index);
        currentActive = index;
      }
    });
  });

  const initializeTOC = () => {
    removeAllActive();
    makeActive(0);
    currentActive = 0;
  };

  window.addEventListener('scroll', updateActiveLink);
  initializeTOC();
});

/* ===============================
   2. Stepper and Form Navigation
   =============================== */
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

// Change the current step
function setStep(step) {
  currentStep = step;
  updateFormUI();
  hideNonCurrentForms();
}

/* ===============================
   3. Progress Bar Updates
   =============================== */
function updateProgressBar() {
  const progressBar = document.getElementById('progress-bar');
  const progressStepText = document.getElementById('progress-step-text');

  const progressPercentage = (currentStep / totalSteps) * 100;

  progressBar.style.width = `${progressPercentage}%`;
  progressStepText.textContent = `${currentStep}/${totalSteps}`;
}

/* ===============================
   4. Get Current Step
   =============================== */
function getCurrentStep() {
  return currentStep;
}

/* ===============================
   5. Hide Non-Current Form Contents
   =============================== */
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
