{{flutter_js}}
{{flutter_build_config}}

const loading = document.getElementById('loading');
window.addEventListener('flutter-first-frame', () => loading?.remove(), { once: true });

function showStartupError(error) {
  console.error('Flutter startup failed', error);
  const label = loading?.querySelector('.loading-text');
  if (label) label.textContent = 'Gagal membuka e-Tracker';
}

_flutter.loader.load({
  config: { canvasKitBaseUrl: 'canvaskit/' },
  onEntrypointLoaded: async function (engineInitializer) {
    try {
      const appRunner = await engineInitializer.initializeEngine({ canvasKitBaseUrl: 'canvaskit/' });
      await appRunner.runApp();
    } catch (error) {
      showStartupError(error);
    }
  },
}).catch(showStartupError);
