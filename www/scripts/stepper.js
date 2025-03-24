function setStep(element, inputId) {
  const stepNumber = element.getAttribute("data-step");

  // Update UI
  document.querySelectorAll(".step").forEach(el => el.classList.remove("active"));
  element.classList.add("active");

  // Let Shiny know (use correct namespaced inputId!)
  Shiny.setInputValue(inputId, parseInt(stepNumber), { priority: "event" });
}
