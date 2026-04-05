export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const ua = request.headers.get("user-agent") || "";

    let pathname = url.pathname;

    // ✅ Detect bots
    const isBot = /googlebot|bingbot|yandex|duckduckbot|baiduspider/i.test(ua);

    // ✅ Skip static files
    const isStatic = pathname.match(/\.(js|css|png|jpg|jpeg|gif|svg|ico|woff|woff2)$/);

    // 🚀 STEP 1: Serve prerender for bots
    if (isBot && !isStatic) {
      const rendertronUrl =
        "https://your-rendertron.onrender.com/render/" + request.url;

      return fetch(rendertronUrl, {
        cf: {
          cacheEverything: true,
          cacheTtl: 3600,
        },
      });
    }

    // 🚀 STEP 2: Your existing logic
    // Remove /tech prefix
    if (pathname.startsWith('/tech')) {
      pathname = pathname.replace('/tech', '') || '/';
    }

    // Try to serve static asset
    let assetRequest = new Request(url.origin + pathname, request);
    let response = await env.ASSETS.fetch(assetRequest);

    if (response.status !== 404) {
      return response;
    }

    // SPA fallback
    return env.ASSETS.fetch(
      new Request(url.origin + '/index.html')
    );
  },
};


// export default {
//   async fetch(request, env) {
//     const url = new URL(request.url);

//     let pathname = url.pathname;

//     // ✅ Remove /tech prefix
//     if (pathname.startsWith('/tech')) {
//       pathname = pathname.replace('/tech', '') || '/';
//     }

//     // ✅ Serve actual file if exists
//     let assetRequest = new Request(url.origin + pathname, request);
//     let response = await env.ASSETS.fetch(assetRequest);

//     if (response.status !== 404) {
//       return response;
//     }

//     // ✅ SPA fallback (ONLY for routes)
//     return env.ASSETS.fetch(
//       new Request(url.origin + '/index.html')
//     );
//   },
// };