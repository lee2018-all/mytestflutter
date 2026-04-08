'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"manifest.json": "9e07161cfbd204f4645b233624a37fbd",
"version.json": "12d7d730626a72de7123f8f83a536bd2",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"index.html": "6807d945da8aa87b84ad107022fd1aa8",
"/": "6807d945da8aa87b84ad107022fd1aa8",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"assets/AssetManifest.bin": "68d885bcb810aa62309f377a6db0afe3",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/flutter_inappwebview_web/assets/web/web_support.js": "509ae636cfdd93e49b5a6eaf0f06d79f",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/NOTICES": "e2535b0c410f75559eb7df3291cf1c3f",
"assets/AssetManifest.json": "2ea38292cb4f096c1c4638f8f9d1a27c",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/images/ground.png": "26e4e964070d349d494edbfa0fe786c0",
"assets/images/set_no.png": "02c4ad5aa2f01d67a91d7faddaaed723",
"assets/images/contact.png": "f49ab7448710d0eeb10e7e98f0b7f3da",
"assets/images/unchecked_circle.png": "617546689fc77674e4223f63f23fb189",
"assets/images/mobile.png": "cd3452f1bd960e2bd756c81d796f8a60",
"assets/images/down_gray.png": "edbb1a011c3e7e21e6ce35739e7c478f",
"assets/images/verfication.png": "81f1996336265ae43e710db9bd2323dc",
"assets/images/email.png": "89755f48cef2cce81ee3183d70b4ee79",
"assets/images/service.png": "d5b4a75f659162eaeb9724399098778b",
"assets/images/copy.png": "daf07b2e8659df333e99c60a7677dfbe",
"assets/images/checked_circle.png": "a3cb7a5f2ffc84bdcb0319c1376a7cdb",
"assets/images/pobg.png": "fd3d6e55883303cb49401c8d062e6e99",
"assets/images/star.png": "01934b7138d696a1f3b52c200266b36c",
"assets/images/genzong.png": "5c643e9290b3c88bc53e9ea6a92d5ed5",
"assets/images/bout.png": "68b2032c5373264ed68c819fb08af374",
"assets/images/main_no.png": "aab3e2d81f0d3009a14931d6a85e5d7c",
"assets/images/contact_gray.png": "6c92fb4363bed5b3de9a337f93fe9785",
"assets/images/pre.png": "b0557346eb2ace3217120ef62ed132d4",
"assets/images/screen.png": "9e31e2589931a771da681634eb74737b",
"assets/images/complete.png": "3c8ad62a5f2ee0513ba67f1b0da0b435",
"assets/images/pri.png": "5b33fdab7d9e17ef2213d99d51bc6418",
"assets/images/add.png": "ae5360ec125b7904149d333103466176",
"assets/images/white_down.png": "8807a28c6ab8705010c907a3c94760b6",
"assets/images/experience.png": "bfa2e68197c55f5cf0d2bfde30b48c1a",
"assets/images/avata.png": "5b082020ab8ad7080134df16478765e0",
"assets/images/bg.png": "b87bde74d739a87c59d407431b35fd92",
"assets/images/illustration.png": "166968cc2e47a774542e15760141015c",
"assets/images/info.png": "8610ef0efb0c5459f06d3d78ef1458ac",
"assets/images/down.png": "f31e6c5469ca0b061d03600834f21ae1",
"assets/images/main_yes.png": "dcc9a7677108f4d3cd0e2f3f2360393d",
"assets/images/set_yes.png": "8c511b3dd5525524cbafe5722b5eeda3",
"assets/images/experience_gray.png": "337b76cfdd78afca81c04186560fb928",
"assets/images/call.png": "3a193fb9281cfa29a5e12a2011871ead",
"assets/images/gauge.png": "dd488baabff754d081249d1d88f44a65",
"assets/images/po.png": "63ebe9c131710f85dac20a5a23e30f7d",
"assets/fonts/MaterialIcons-Regular.otf": "b962ca51e9314e4a4a1af244cf853461",
"assets/AssetManifest.bin.json": "8c276b5ae9dc5f24b823c07d61fa1e6e",
"flutter_bootstrap.js": "17d30f33b59b9768d8514dbcb446275c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"main.dart.js": "66d18f24d646cdbab28f229aed7e4f03"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
