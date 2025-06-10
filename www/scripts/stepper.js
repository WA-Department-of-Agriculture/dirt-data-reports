function setStep(element, inputId) {
  const stepNumber = element.getAttribute("data-step");

  // Update UI
  document.querySelectorAll(".step").forEach(el => el.classList.remove("active"));
  element.classList.add("active");

  // Update mobile progress bar
  updateMobileProgressBar(parseInt(stepNumber));

  // Let Shiny know (use correct namespaced inputId!)
  Shiny.setInputValue(inputId, parseInt(stepNumber), { priority: "event" });
}

function updateMobileProgressBar(currentStep) {
  const progressPercent = (currentStep / 4) * 100;
  
  const stepTextElement = document.getElementById("progress-step-text");
  if (stepTextElement) {
    stepTextElement.textContent = `${currentStep}/4`;
  }
  
  const progressBarElement = document.getElementById("progress-bar");
  if (progressBarElement) {
    progressBarElement.style.width = `${progressPercent}%`;
  }
}