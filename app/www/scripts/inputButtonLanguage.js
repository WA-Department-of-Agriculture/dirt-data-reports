document.addEventListener('DOMContentLoaded', () => {
  // Get language buttons
  const englishButton = document.getElementById('englishLang');
  const spanishButton = document.getElementById('spanishLang');
  const languageButtons = document.querySelectorAll('.language-button');

  // Ensure one button is always selected
  const ensureSelection = () => {
    const activeButton = document.querySelector('.language-button.active');
    if (!activeButton) {
      englishButton.classList.add('active'); // Default to English
      Shiny.setInputValue('language', 'template.qmd');
    }
  };

  // Function to toggle active state
  const toggleActiveLanguage = (selectedButton) => {
    // If already active, do nothing (prevents deselection)
    if (selectedButton.classList.contains('active')) {
      return;
    }

    // Remove 'active' class from all buttons
    languageButtons.forEach(button => button.classList.remove('active'));

    // Add 'active' class to the selected button
    selectedButton.classList.add('active');

    // Update Shiny input
    Shiny.setInputValue('language', selectedButton.id === 'englishLang' ? 'template.qmd' : 'template_esp.qmd');
  };

  // Add event listeners
  englishButton.addEventListener('click', () => toggleActiveLanguage(englishButton));
  spanishButton.addEventListener('click', () => toggleActiveLanguage(spanishButton));

  // Ensure one button is always active on page load
  ensureSelection();
});
