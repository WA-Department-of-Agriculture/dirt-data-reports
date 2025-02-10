
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