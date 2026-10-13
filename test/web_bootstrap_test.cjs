const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const source = fs.readFileSync(path.join(__dirname, '../web/flutter_bootstrap.js'), 'utf8')
  .replace('{{flutter_js}}', '').replace('{{flutter_build_config}}', '');

function start(loaderError) {
  const label = { textContent: 'e-Tracker' };
  const state = { removed: false, errors: [], events: {}, label };
  const context = {
    document: { getElementById: () => ({
      remove: () => { state.removed = true; },
      querySelector: () => label,
    }) },
    window: { addEventListener: (event, callback) => { state.events[event] = callback; } },
    console: { error: (...args) => state.errors.push(args) },
    _flutter: { loader: { load: (options) => {
      state.options = options;
      return loaderError ? Promise.reject(loaderError) : Promise.resolve();
    } } },
  };
  vm.runInNewContext(source, context);
  return state;
}

async function main() {
  const success = start();
  let ran = false;
  await success.options.onEntrypointLoaded({ initializeEngine: async (config) => {
    assert.equal(config.canvasKitBaseUrl, 'canvaskit/');
    return { runApp: async () => { ran = true; } };
  } });
  assert.equal(ran, true);
  assert.equal(success.removed, false);
  assert.equal(success.options.config.renderer, undefined);
  success.events['flutter-first-frame']();
  assert.equal(success.removed, true);

  for (const stage of ['engine', 'app']) {
    const failed = start();
    await failed.options.onEntrypointLoaded({ initializeEngine: async () => {
      if (stage === 'engine') throw new Error('engine failed');
      return { runApp: async () => { throw new Error('app failed'); } };
    } });
    assert.equal(failed.removed, false);
    assert.equal(failed.label.textContent, 'Gagal membuka e-Tracker');
    assert.equal(failed.errors.length, 1);
  }

  const failedLoad = start(new Error('download failed'));
  await Promise.resolve();
  assert.equal(failedLoad.label.textContent, 'Gagal membuka e-Tracker');
  assert.equal(failedLoad.removed, false);
  console.log('Web bootstrap checks passed');
}

main().catch((error) => { console.error(error); process.exitCode = 1; });
