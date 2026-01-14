// ============================================
// COMMANDS PAGE – HARDENED
// ============================================

let commands = [];

// data MUST come from window.Commands or similar
if (typeof window.Commands === 'string') {
  try {
    commands = JSON.parse(window.Commands);
  } catch (e) {
    console.error('[ADMIN MENU] Command JSON parse failed', e);
    commands = [];
  }
} else {
  console.warn('[ADMIN MENU] No command data provided');
  commands = [];
}
