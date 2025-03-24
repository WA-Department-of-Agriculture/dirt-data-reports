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
