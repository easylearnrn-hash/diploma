function setupOverlayInteractions() {
  if (!dom.videoGrid) return;
  let isDragging = false;
  let dragStartX = 0;
  let dragStartY = 0;
  let initX = 0;
  let initY = 0;

  // Pinch vars
  let initialPinchDist = 0;
  let initialScale = 0;

  dom.videoGrid.addEventListener('pointerdown', (e) => {
    const localTile = e.target.closest('#localVideoTile');
    if (!localTile || !state.overlayImage) return;
    
    // Only allow left click (or touch)
    if (e.pointerType === 'mouse' && e.button !== 0) return;

    isDragging = true;
    dragStartX = e.clientX;
    dragStartY = e.clientY;
    initX = state.overlayX;
    initY = state.overlayY;
    
    e.target.setPointerCapture(e.pointerId);
  });

  dom.videoGrid.addEventListener('pointermove', (e) => {
    if (!isDragging || !state.overlayImage) return;

    const localTile = e.target.closest('#localVideoTile');
    if (!localTile) return;

    // Notice: X direction is reversed because the local video is scaleX(-1) mirrored!
    const dx = e.clientX - dragStartX;
    const dy = e.clientY - dragStartY;

    // Convert pixel delta to percentage of the tile dimensions
    const rect = localTile.getBoundingClientRect();
    
    // Since video is scaleX(-1), moving mouse Right (dx > 0) means moving cursor on screen to the right, which on the mirrored image feels like moving LEFT from camera perspective. But user moves mouse on screen so they expect it to follow mouse.
    // If user drags right (dx > 0), the actual canvas graphic should move opposite to mirror to stay under mouse?
    // Wait. The composite canvas is NOT mirrored. The video element is rendering it mirrored.
    // So if the logo is at X=0% (Left edge of canvas), on video element it will appear at the RIGHT edge.
    // Therefore, moving mouse left (on screen) should move the logo Towards 0% X (Left on Canvas, Right on Screen) -- wait, no.
    // Canvas 100% X = Right edge of canvas = Left edge of SCREEN.
    // Mouse moving Right on screen (dx > 0), we want the logo to move Right on screen. 
    // Which means we want the logo to move LEFT on the canvas (decrease state.overlayX).
    const percentDx = (dx / rect.width) * 100;
    const percentDy = (dy / rect.height) * 100;

    let newX = initX - percentDx; // Invert dx due to mirror
    let newY = initY + percentDy; // Y is not mirrored

    // Clamp
    newX = Math.max(0, Math.min(100, newX));
    newY = Math.max(0, Math.min(100, newY));

    state.overlayX = newX;
    state.overlayY = newY;
  });

  dom.videoGrid.addEventListener('pointerup', (e) => {
    if (isDragging) {
      isDragging = false;
      if (e.target.releasePointerCapture) e.target.releasePointerCapture(e.pointerId);
    }
  });

  dom.videoGrid.addEventListener('pointercancel', (e) => {
    isDragging = false;
  });

  // Wheel to zoom
  dom.videoGrid.addEventListener('wheel', (e) => {
    const localTile = e.target.closest('#localVideoTile');
    if (!localTile || !state.overlayImage) return;
    
    e.preventDefault(); // prevent scroll
    
    // speed factor
    const zoomDelta = e.deltaY > 0 ? -2 : 2; 
    let newScale = state.overlayScale + zoomDelta;
    newScale = Math.max(5, Math.min(100, newScale));
    state.overlayScale = newScale;
  }, { passive: false });

  // Touch pinch zoom (Safari/Mobile)
  dom.videoGrid.addEventListener('touchstart', (e) => {
    const localTile = e.target.closest('#localVideoTile');
    if (!localTile || !state.overlayImage) return;

    if (e.touches.length === 2) {
      isDragging = false; // stop drag
      const dx = e.touches[0].clientX - e.touches[1].clientX;
      const dy = e.touches[0].clientY - e.touches[1].clientY;
      initialPinchDist = Math.sqrt(dx*dx + dy*dy);
      initialScale = state.overlayScale;
    }
  }, { passive: false });

  dom.videoGrid.addEventListener('touchmove', (e) => {
    const localTile = e.target.closest('#localVideoTile');
    if (!localTile || !state.overlayImage) return;

    if (e.touches.length === 2) {
      e.preventDefault(); // prevent zoom of page
      const dx = e.touches[0].clientX - e.touches[1].clientX;
      const dy = e.touches[0].clientY - e.touches[1].clientY;
      const dist = Math.sqrt(dx*dx + dy*dy);
      
      const scaleFactor = dist / initialPinchDist;
      let newScale = initialScale * scaleFactor;
      newScale = Math.max(5, Math.min(100, newScale));
      state.overlayScale = newScale;
    }
  }, { passive: false });
}
